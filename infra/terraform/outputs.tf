output "ec2_public_ip" {
  value       = aws_instance.app_server.public_ip
  description = "Adresse IP publique de l'instance EC2"
}
