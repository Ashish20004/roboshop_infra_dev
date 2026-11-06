resource "aws_security_group_rule" "bastion_internet" {
    type        = "ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip]
    security_group_id   = local.bastion_sg_id

}

resource "aws_security_group_rule" "mongodb_bastion" {
    type                    = "ingress"
    from_port               = 22
    to_port                 = 22
    protocol                = "tcp"
    source_security_group_id= local.bastion_sg_id
    security_group_id       = local.mongodb_sg_id
}

resource "aws_security_group_rule" "mongodb_catalogue" {
    type                    = "ingress"
    from_port               = 27017
    to_port                 = 27017
    protocol                = "tcp"
    source_security_group_id= local.catalogue_sg_id
    security_group_id       = local.mongodb_sg_id
}

resource "aws_security_group_rule" "mongodb_user"{
    type                    = "ingress"
    from_port               = 27017
    to_port                 = 27017
    protocol                = "tcp"
    source_security_group_id= local.user_sg_id
    security_group_id       = local.mongodb_sg_id 
}
#redis

resource "aws_security_group_rule" "redis_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  # Where traffic is coming from
  source_security_group_id = local.bastion_sg_id
  security_group_id = local.redis_sg_id
}


resource "aws_security_group_rule" "redis_user" {
    type                    = "ingress"
    from_port               = 6379
    to_port                 = 6379
    protocol                = "tcp"
    source_security_group_id= local.user_sg_id
    security_group_id       = local.redis_sg_id 
}

resource "aws_security_group_rule" "redis_cart"{
    type                    = "ingress"
    from_port               = 6379
    to_port                 = 6379
    protocol                = "tcp"
    source_security_group_id= local.cart_sg_id
    security_group_id       = local.redis_sg_id
}

# MySQL
resource "aws_security_group_rule" "mysql_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  # Where traffic is coming from
  source_security_group_id = local.bastion_sg_id
  security_group_id = local.mysql_sg_id
}
# RabbitMQ
resource "aws_security_group_rule" "rabbitmq_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  # Where traffic is coming from
  source_security_group_id = local.bastion_sg_id
  security_group_id = local.rabbitmq_sg_id
}

resource "aws_security_group_rule" "mysql_shipping" {
    type                    = "ingress"
    from_port               = 3306
    to_port                 = 3306
    protocol                = "tcp"
    source_security_group_id= local.shipping_sg_id 
    security_group_id       = local.mysql_sg_id
}

resource "aws_security_group_rule" "rabbitmq_payment" {
    type                    = "ingress"
    from_port               = 5672
    to_port                 = 5672
    protocol                = "tcp"
    source_security_group_id= local.payment_sg_id
    security_group_id       = local.rabbitmq_sg_id
}

resource "aws_security_group_rule" "catalogue_bastion" {
    type                    = "ingress"
    from_port               = 22
    to_port                 = 22
    protocol                = "tcp"
    source_security_group_id= local.bastion_sg_id
    security_group_id       = local.catalogue_sg_id
}

resource "aws_security_group_rule" "catalogue_backend_alb" {
    type                    = "ingress"
    from_port               = 8080
    to_port                 = 8080
    protocol                = "tcp"
    source_security_group_id= local.backend_alb_sg_id
    security_group_id       = local.catalogue_sg_id
}