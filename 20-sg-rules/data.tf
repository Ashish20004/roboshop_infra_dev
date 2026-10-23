data "http" "my_public_ip_v4" {
  url = "https://ipv4.icanhazip.com"
}

output "my_ipv4_address" {
  value = chomp(data.http.my_public_ip_v4.response_body)
}


data "aws_ssm_parameter" "bastion_sg_id" {
    name = "/${var.project}/${var.environment}/bastion.sg_id"
}

data "aws_ssm_parameter" "mongodb_sg_id" {
    name    = "/${var.project}/${var.environment}/mongodb.sg_id"
}

data "aws_ssm_parameter" "catalogue_sg_id" {
    name    = "/${var.project}/${var.environment}/catalogue.sg_id"
}

data "aws_ssm_parameter" "cart_sg_id" {
    name    = "/${var.project}/${var.environment}/cart.sg_id"
}

data "aws_ssm_parameter" "user_sg_id" {
    name    = "/${var.project}/${var.environment}/user.sg_id"
}

data "aws_ssm_parameter" "shipping_sg_id" {
    name    = "/${var.project}/${var.environment}/shipping.sg_id"
}

data "aws_ssm_parameter" "payment_sg_id" {
    name    = "/${var.project}/${var.environment}/payment.sg_id"
}

