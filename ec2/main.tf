resource "aws_instance" "publicec1" {
 ami           = var.ami-id
 instance_type = var.ec-type
 associate_public_ip_address = true
 subnet_id = var.public-sub1-id
 vpc_security_group_ids = [var.security-gid]
  key_name = var.key-pair
 tags = {
    Name = "publicec1"
  }
 provisioner "local-exec" {
  when = create
   command = "echo public_ip1  ${self.public_ip} >> ./ip.txt"
 }
 
}

resource "aws_instance" "publicec2" {
  ami           = var.ami-id
  instance_type = var.ec-type
  associate_public_ip_address = true
  subnet_id = var.public-sub2-id
  vpc_security_group_ids = [var.security-gid]
  key_name = var.key-pair1
  tags = {
    Name = "publicec2"
  }
  provisioner "local-exec" {
    when = create
   command = "echo public_ip2  ${self.public_ip} >> ./ip.txt"
 }
}

resource "aws_instance" "privateec1" {
  ami           = var.ami-id
  instance_type = var.ec-type
  associate_public_ip_address = false
  subnet_id = var.private-sub1-id
  vpc_security_group_ids = [var.security-gid]
  tags = {
    Name = "privateec2"
  }
  
  user_data = file("ec2/install.sh")

}

resource "aws_instance" "privateec2" {
  ami           = var.ami-id
  instance_type = var.ec-type
  associate_public_ip_address = false
  subnet_id = var.private-sub2-id
  vpc_security_group_ids = [var.security-gid]
  tags = {
    Name = "privateec2"
  }
  
  user_data = file("ec2/install.sh")
}
