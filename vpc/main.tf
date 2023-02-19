resource "aws_vpc" "vpc1" {
    cidr_block = var.vpc_cider
    enable_dns_hostnames = "true"
  tags = {
    Name = "test_vpc"
  }
  
}
#--------------AZ1---------------------
#--------------subnets-----------------
resource "aws_subnet" "pub-sub1" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = var.cider-sub[0]
  availability_zone = var.zones
  tags = {
    Name = "public1-sub"
  }
}

resource "aws_subnet" "private-sub1" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = var.cider-sub[1]
  availability_zone = var.zones
  tags = {
    Name = "private1-sub"
  }
}
#--------------subnets-AZ2-----------------
resource "aws_subnet" "pub-sub2" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = var.cider-sub[2]
  availability_zone = var.zones1
  tags = {
    Name = "public1-sub"
  }
}

resource "aws_subnet" "private-sub2" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = var.cider-sub[3]
  availability_zone = var.zones1
  tags = {
    Name = "private1-sub"
  }
}
#------------------routtable-pub & association & igw---------------
resource "aws_route_table" "route" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = var.cider-route
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "pub-table1"
  }
}
#---------------public-ass1-------------------
resource "aws_route_table_association" "one" {
  subnet_id      = aws_subnet.pub-sub1.id
  route_table_id = aws_route_table.route.id
}
#---------------------public-ass2---------------
resource "aws_route_table_association" "two" {
  subnet_id      = aws_subnet.pub-sub2.id
  route_table_id = aws_route_table.route.id
}
#---------------
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "igw-vpc1"
  }
}
#------------------routtable-priv & association & nat---------------
resource "aws_route_table" "route-1" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block     = var.cider-route
    nat_gateway_id = aws_nat_gateway.nat1.id
  }

  tags = {
    Name = "priv-table1"
  }
}
#---------------------private-ass1---------------
resource "aws_route_table_association" "private-1" {
  subnet_id      = aws_subnet.private-sub1.id
  route_table_id = aws_route_table.route-1.id
}
#---------------------privite-ass2---------------
resource "aws_route_table_association" "private-2" {
  subnet_id      = aws_subnet.private-sub2.id
  route_table_id = aws_route_table.route-1.id
}
#------------nat & elip-------
resource "aws_eip" "nat_eip" {
  vpc = true
}
resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.pub-sub1.id
  tags = {
    Name = "gw NAT1"
  }
  depends_on = [aws_internet_gateway.gw]
}
#-------------end---------
#----------security--------------
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cider-route]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.cider-route]

  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cider-route]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cider-route]
  }

  tags = {
    Name = "allow_tls"
  }
}
#-----------------end AZ------------------
#------------------public-loadbalancer------------
resource "aws_lb" "public-lb" {
  name               = "pub-lb"
  internal           = false
  load_balancer_type = "application"
   ip_address_type = "ipv4"
  security_groups    = [aws_security_group.allow_tls.id]
  subnets            = [aws_subnet.pub-sub1.id,aws_subnet.pub-sub2.id]
  
}
resource "aws_lb_target_group" "publicgroup" {
  name     = "pub-targetGroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc1.id
}

resource "aws_lb_target_group_attachment" "attach-proxy1" {
  target_group_arn = aws_lb_target_group.publicgroup.arn
  target_id        = var.publicecid1
  port             = 80
}
resource "aws_lb_target_group_attachment" "attach-proxy2" {
  target_group_arn = aws_lb_target_group.publicgroup.arn
  target_id        = var.publicecid2
  port             = 80
}
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.public-lb.arn
  protocol          = "HTTP"
  port              = 80
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.publicgroup.arn
  }
}
#------------------private-loadbalancer------------
resource "aws_lb" "private-lb" {
  name               = "priv-lb"
  internal           = true
  ip_address_type = "ipv4"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_tls.id]
  subnets            = [aws_subnet.private-sub1.id, aws_subnet.private-sub2.id]  
}
resource "aws_lb_target_group" "privategroup" {
  name     = "priv-targetGroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc1.id
}
resource "aws_lb_target_group_attachment" "attach-priv1" {
  target_group_arn = aws_lb_target_group.privategroup.arn
  target_id        = var.privateecid1
  port             = 80
}
resource "aws_lb_target_group_attachment" "attach-priv2" {
  target_group_arn = aws_lb_target_group.privategroup.arn
  target_id        = var.privateecid2
  port             = 80
}
resource "aws_lb_listener" "listener1" {
  load_balancer_arn = aws_lb.private-lb.arn
  protocol          = "HTTP"
  port              = 80
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.privategroup.arn
  }
}
