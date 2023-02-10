provider "github" {
  owner = var.org_name
  app_auth {
    pem_file = try(file("/home/runner/.secrets/privkey-gh-app.pem"), file("/home/ronald/Downloads/personal-terrafom.2023-02-07.private-key.pem"))
  }
}
