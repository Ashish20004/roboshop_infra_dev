module "sg" {
    count         = length(var.sg_names)
    source        = "git::https://github.com/Ashish20004/aws_security_group.git"
    project       = var.project
    environment   = var.environment
    vpc_id        = local.vpc_id
    sg_name       = replace(var.sg_names[count.index], "_", "-")

}