terraform {
  backend "s3" {
    bucket = "terraform"
    key    = "oracle-infra/terraform.tfstate"

    endpoint                    = "https://minio.ronaldmiranda.com.br"
    region                      = "main"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
}
