resource "aws_security_group_rule" "bastion_internet" {
    type        = "ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip]
    security_group_id   = local.bastion.sg_id

}

resource "aws_security_group_rule" "mongodb_bastion" {
    type                    = "ingress"
    from_port               = 22
    to_port                 = 22
    protocol                = "tcp"
    source_security_group_id= local.bastion.sg_id
    security_group_id       = local.mongodb.sg_id
}

resource "aws_security_group_rule" "mongodb_catalogue" {
    type                    = "ingress"
    from_port               = 27017
    to_port                 = 27017
    protocol                = "tcp"
    source_security_group_id= local.catalogue.sg__id
    security_group_id       = local.mongodb.sg_id
}

resource "aws_security_group_rule" "mongodb_user"{
    type                    = "ingress"
    from_port               = 27017
    to_port                 = 27017
    protocol                = "tcp"
    source_security_group_id= "local.user.sg_id"
    security_group_id       = local.mongodb.sg_id 
}