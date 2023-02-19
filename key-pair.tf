module "key-pair" {
  source       = "./key"
  encrypt-kind = "RSA"
  encrypt-bits = 4096
}