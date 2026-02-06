output "elk_instance_ip" {
  value = aws_instance.elk_instance.public_ip
}