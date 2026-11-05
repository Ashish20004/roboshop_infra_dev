resource "aws_ssm_parameter" "listner_arn" {
    name  = "/${var.project}/${var.environment}/backend_alb_listener_arn"
    type  = "String"
    value = aws_lb_listener.http.arn
}