# cert-manager

Deploy do cert-manager via Helm, usando o chart wrapper em `../../stable/cert-manager`
(dependência do chart oficial da Jetstack).

## CRDs ficam fora do Helm

Os CRDs do cert-manager **não** são gerenciados pela release Helm. No
`stable/cert-manager/values.yaml`:

```yaml
cert-manager:
  crds:
    enabled: false
```

Eles são aplicados manualmente com `kubectl apply`, a partir do manifesto oficial
de cada versão.

**Por quê:** os CRDs existentes no cluster foram criados via `kubectl` e não têm os
metadados de ownership do Helm (`app.kubernetes.io/managed-by: Helm`,
`meta.helm.sh/release-name`, `meta.helm.sh/release-namespace`). Se o chart tentar
renderizá-los (`crds.enabled: true` ou o antigo `installCRDs: true`), o upgrade falha com:

```
Error: UPGRADE FAILED: rendered manifests contain a resource that already exists.
Unable to continue with update: CustomResourceDefinition "challenges.acme.cert-manager.io"
in namespace "" exists and cannot be imported into the current release: invalid ownership metadata ...
```

Manter os CRDs fora do Helm também evita que um `helm uninstall` apague os CRDs e,
junto com eles, todos os `Certificate`, `Issuer` e `ClusterIssuer` do cluster.

## Processo de update

### 1. Leia as notas de upgrade

Antes de subir a versão, leia as notas de cada minor entre a versão atual e a nova:
<https://cert-manager.io/docs/releases/>

Veja a versão em execução:

```bash
kubectl get deploy -n cert-manager cert-manager \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

### 2. Atualize a versão do chart

Em `stable/cert-manager/Chart.yaml`, altere a versão da dependência e, para manter o
`helm list` legível, também `version`/`appVersion` do wrapper:

```yaml
version: 1.21.3
appVersion: 1.21.3

dependencies:
  - name: cert-manager
    version: "1.21.3"
    repository: "https://charts.jetstack.io"
```

### 3. Aplique os CRDs da nova versão

**Sempre antes do upgrade do Helm.** O controller novo pode depender de campos que só
existem nos CRDs novos.

```bash
VERSION=v1.21.3
kubectl apply --server-side --force-conflicts \
  -f https://github.com/cert-manager/cert-manager/releases/download/${VERSION}/cert-manager.crds.yaml
```

- `--server-side`: os CRDs são grandes e estouram o limite da anotação
  `last-applied-configuration` do apply client-side.
- `--force-conflicts`: assume os campos que antes foram aplicados por outro field manager
  (por exemplo, um `kubectl apply` client-side anterior).

Confira:

```bash
kubectl get crd -l app.kubernetes.io/name=cert-manager \
  -o custom-columns=NAME:.metadata.name,VERSION:.metadata.labels.app\\.kubernetes\\.io/version
```

Todos devem mostrar a nova versão.

### 4. Dry-run

```bash
DRY_RUN=y ./run.sh
```

O `run.sh` roda em dry-run por padrão. Confira que não há erro e que nenhum
`kind: CustomResourceDefinition` aparece no manifesto renderizado.

> O `run.sh` usa `--reset-values`, então só vale o que está em
> `stable/cert-manager/values.yaml`. Qualquer valor setado à mão via `--set` em
> releases anteriores é descartado.

### 5. Upgrade

```bash
DRY_RUN=n ./run.sh
```

### 6. Validação

```bash
helm list -n cert-manager
kubectl get pods -n cert-manager
kubectl get deploy -n cert-manager \
  -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.template.spec.containers[0].image}{"\n"}{end}'
kubectl get certificates -A
kubectl logs -n cert-manager deploy/cert-manager --tail=200 | grep -iE '^E|error'
```

Esperado: pods `Running` na nova imagem, todos os `Certificate` com `READY=True` e
nenhum erro nos logs do controller.

## Rollback

O `helm rollback cert-manager -n cert-manager` volta o controller, mas **não** os CRDs.
Os CRDs do cert-manager são compatíveis com versões anteriores dentro do mesmo
`apiVersion` (`cert-manager.io/v1`), então em geral basta voltar o controller. Se for
preciso voltar os CRDs também, reaplique o manifesto da versão anterior (passo 3 com o
`VERSION` antigo).
