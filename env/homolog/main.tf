module "Homologacao" {
  source = "../../Infra"

  nome = "homologacao"
  descricao = "aplicacao-de-homologacao"
  max = 3
  maquina = "t2.micro"
  ambiente = "homolog"
}