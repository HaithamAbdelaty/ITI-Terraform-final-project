output "vpc-id" {
  value = aws_vpc.vpc1.id
}
output "security" {
  value = aws_security_group.allow_tls.id
}
output "public-sub1"{
 value = aws_subnet.pub-sub1.id  
}
output "public-sub-2"{
 value = aws_subnet.pub-sub2.id   
}
output "private-sub-1"{
 value = aws_subnet.private-sub1.id  
}
output "private-sub-2"{
 value = aws_subnet.private-sub2.id  
}
output "sec-id" {
value = aws_security_group.allow_tls.id   
}
output "pivatedns-lb" {
  value = aws_lb.private-lb.dns_name
}