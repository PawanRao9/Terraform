output "instance-ip" {
  value = aws_instance.my-server.public_ip

}

output "instance_url" {
  value = "http://${aws_instance.my-server.public_ip}"
}

