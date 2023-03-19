provider "github" {
  owner = var.org_name
  app_auth {
    pem_file = try(file("/home/runner/.secrets/privkey-gh-app.pem"), var.privkey_gh_app)
  }
}
