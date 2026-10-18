terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "6.33.0"
        }
    }
    backend "s3" {
    bucket = "remote-bucketdemo"
    key    = "roboshop-dev-vpc"
    region = "us-east-1"
    encrypt = true
    use_lockfile = true
}
}



provider "aws" {
    region = "us-east-1"
}
