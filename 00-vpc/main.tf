module "vpc" {
    source = "git::https://github.com/Ashish20004/terraform_aws_vpc.git"
    project = var.project
    environment = var.environment
    is_peering_required = false
}