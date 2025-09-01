module "networking" {
  source         = "./modules/networking"
  vpc_cidr_block = "10.20.0.0/20" // 10.10.64.0 - 10.10.95.255/21 - maximo de 4 subnets https://www.site24x7.com/tools/ipv4-subnetcalculator.html
  public_subnets = [
    { cidr_block = "10.20.2.0/23", zone = "${var.region}a", name = "subnet-a-pub1" },
    { cidr_block = "10.20.6.0/23", zone = "${var.region}b", name = "subnet-b-pub1" },
    { cidr_block = "10.20.10.0/23", zone = "${var.region}c", name = "subnet-c-pub1" }
  ]
  private_subnets = [
    { cidr_block = "10.20.0.0/23", zone = "${var.region}a", name = "subnet-a-priv1" },
    { cidr_block = "10.20.4.0/23", zone = "${var.region}b", name = "subnet-b-priv1" },
    { cidr_block = "10.20.8.0/23", zone = "${var.region}c", name = "subnet-c-priv1" }
  ]
  customer_group = "conta-comigo"
  env            = "dev"

}
