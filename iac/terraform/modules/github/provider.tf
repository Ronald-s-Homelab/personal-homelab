provider "github" {
  app_auth {
    pem_file = file("/secrets/privkey-gh-app.pem")
  }
}
