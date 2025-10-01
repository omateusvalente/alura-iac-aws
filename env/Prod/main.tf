module "aws-prod" {
  source = "../../infra"
  instancia = "t2.small"
  regiao_aws = "us-west-1"
  chave = "IaC-PROD"
}
