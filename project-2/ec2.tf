resource "aws_instance" "my-server" {
  ami                         = ""
  instance_type               = "t3_micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = aws_security_group.nginx-sg.id
  associate_public_ip_address = true

  user_data = <<-EOF
             !/bin/bash
             sudo yum install nginx -y
             sudo systemctl start nginx
            EOF

  tags = {
    "name" = my-server
  }

}
