terraform {
  backend "s3" {
    bucket = "terraform-state-valente"
    key    = "Prod/terraform.tfstate"
    region = "sa-east-1"
  }
}