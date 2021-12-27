terraform {
  required_version = ">= 1.1, < 1.2"

  backend "s3" {
    # Define backend Bucket in file bucket.backend
    region         = "eu-north-1"
    key            = "tg-notify-me.tfstate"
    dynamodb_table = "tg-notify-me-tflock"
  }

  required_providers {
    aws = {
      version = ">= 3.70.0, < 4.0.0"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "eu-north-1"

  default_tags {
    tags = {
      ManagedBy = "terraform"
    }
  }
}
