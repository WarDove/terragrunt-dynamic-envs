output "subnets" {
  value = {
    public  = aws_subnet.public
    private = aws_subnet.private
  }
}

output "security_groups" {
  value = {
    public  = aws_security_group.public
    private = aws_security_group.private
  }
}