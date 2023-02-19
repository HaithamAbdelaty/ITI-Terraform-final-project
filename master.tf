#-----------dec-vpc----------------------
module "vpc" {
 #------------vpc------------
  source = "./vpc"
  vpc_cider   = var.vpc_cider
 #-----------subnets---------
  cider-sub = var.ciders
  zones = var.zones
  zones1 = var.zones1
  cider-route = var.cider-route
  publicecid1  = module.ec2.publicecid1
  publicecid2  = module.ec2.publicecid2
  privateecid1 = module.ec2.privateecid1
  privateecid2 = module.ec2.privateecid2  
}
module "ec2" {
  source          = "./ec2"
  ami-id          = var.ami-id
  ec-type         = var.ec-type
  key-pair = var.key-pair
  key-pair1 = var.key-pair
  security-gid = module.vpc.security
  public-sub1-id     = module.vpc.public-sub1
  public-sub2-id      = module.vpc.public-sub-2
  private-sub1-id     = module.vpc.private-sub-1
  private-sub2-id    = module.vpc.private-sub-2



  provisionerdata =["sudo apt update -y",
      "sudo apt install -y nginx",
      "echo 'server { \n listen 80 default_server; \n  listen [::]:80 default_server; \n  server_name _; \n  location / { \n  proxy_pass http://${module.vpc.pivatedns-lb}; \n  } \n}' > default",
      "sudo mv default /etc/nginx/sites-enabled/default",
      "sudo systemctl stop nginx",
      "sudo systemctl start nginx"]
    
}