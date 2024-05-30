# ---------- network/providers.tf ----------

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }

  backend "s3" {
    bucket         = "nis342-network-tfstate"
    key            = "network"
    region         = "eu-west-1"
    dynamodb_table = "nis342-network-tfstate"
  }
}

provider "aws" {
  alias  = "awsnvirginia"
  region = var.aws_regions.nvirginia
}

provider "aws" {
  alias  = "awsireland"
  region = var.aws_regions.ireland
}

provider "aws" {
  alias  = "awsohio"
  region = var.aws_regions.ohio
}