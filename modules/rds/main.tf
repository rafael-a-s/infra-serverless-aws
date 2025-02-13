resource "aws_db_instance" "pedidos_db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine              = "postgres"
  engine_version      = "13.7"
  instance_class      = "db.t3.micro"
  identifier          = "pedidos-db"
  username            = "admin"
  password            = "SuperSenhaSegura"
  publicly_accessible = false
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
}

resource "aws_db_subnet_group" "default" {
  name       = "default"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_security_group" "db_sg" {
  name        = "db-security-group"
  description = "Permite acesso à DB apenas da VPC"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Apenas recursos internos podem acessar
  }
}