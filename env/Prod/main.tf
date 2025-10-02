module "aws-prod" {
  source = "../../infra"
  instancia = "t2.micro"
  regiao_aws = "us-east-1"
  chave = "IaC-PROD"
  grupoDeSeguranca = "prod"
  minimo = 1
  maximo = 10
  nomeGrupo = "prod"
  producao = true
}