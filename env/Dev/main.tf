module "aws-dev" {
  source = "../../infra"
  instancia = "t2.micro"
  regiao_aws = "us-west-2"
  chave = "IaC-DEV"
  grupoDeSeguranca = "dev"
  minimo = 0
  maximo = 1
  nomeGrupo = "dev"
}