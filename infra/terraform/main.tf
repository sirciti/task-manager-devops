resource "aws_instance" "app_server" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux AMI (exemple)
  instance_type = var.instance_type

  tags = {
    Name = "DevOps-App-Server"
  }
}
