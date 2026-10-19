resource   "aws_ssm_parameter" "sg_ids" {
    count = length(var.sg_names)
    type  = "String"
    name  = "/${var.project}/${var.environment}/${var.sg_names[count.index]}.sg_id"
    value = module.sg[count.index].sg_id
}