terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region                      = "ap-northeast-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  endpoints {
    ecr = "http://localhost:4566"
  }
}

// MySQL
resource "aws_db_instance" "mysql" {
  identifier             = "prod-mysql"
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password
  allocated_storage      = 20
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.db.id]
}

// Redis
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "prod-redis"
  engine               = "redis"
  engine_version       = "7.2"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  auth_token           = var.redis_password
}

resource "aws_instance" "go_api" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t4g.nano"
  user_data     = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y golang git

    git clone https://github.com/lecterkn/magl-backend.git go_app

    go install github.com/rubenv/sql-migrate/...@latest

    go go_app/build -o go_app

    echo "MY_ANIMEGAME_LIST_MYSQL_DATABASE=myaglist" > .env
    echo "MY_ANIMEGAME_LIST_MYSQL_USERNAME=${var.db_username}" >> .env
    echo "MY_ANIMEGAME_LIST_MYSQL_PASSWORD=${var.db_password}" >> .env
    echo "MY_ANIMEGAME_LIST_MYSQL_ROOT_PASSWORD=${var.db_root_password}" >> .env
    echo "MYSQL_DSN=${var.db_username}:${var.db_password}@tcp(${aws_db_instance.mysql.address})" >> .env

    echo "MY_ANIMEGAME_LIST_REDIS_PASSWORD=${var.redis_password}" >> .env
    echo "REDIS_ADDRESS=${aws_elasticache_cluster.redis.cluster_address}" >> .env
    
    echo "ECHO_SERVER_PORT=8080" >> .env

    sql-migrate up -env=\"production\" && ./go_app
  EOF
}

