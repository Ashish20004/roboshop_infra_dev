resource "aws_instance" "catalogue" {
  ami           = local.ami_id
  instance_type = "t3.micro"
  subnet_id     = local.subnet_ids
  vpc_security_group_ids = [local.catalogue_sg_id]

  tags = merge(
    {
        Name = "${var.project}-${var.environment}-catalogue"
    },
    local.common_tags
  )
}

resource "terraform_data" "catalogue_instance" {
   triggers_replace = [
      aws_instance.catalogue.id
   ]

   connection {
    type        = "ssh"
    user        = "ec2-user"
    password    = "DevOps321"
    host        = aws_instance.catalogue.private_ip
   }

   provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
   }

   provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/bootstrap.sh",
        "sudo sh /tmp/bootstrap.sh catalogue ${var.environment} ${var.app_version}"
    ]
   }

}

resource "aws_ec2_instance_state" "catalogue_state" {
  instance_id = aws_instance.catalogue.id
  state       = "stopped"
  depends_on  = [terraform_data.catalogue_instance]
}

resource "aws_ami_from_instance" "catalogue_ami" {
  name               = "${var.project}-${var.environment}-catalogue-ami"
  source_instance_id = aws_instance.catalogue.id
  depends_on         = [aws_ec2_instance_state.catalogue_state]
}

resource "aws_lb_target_group" "catalogue_tg" {
    name      =  "${var.project}-${var.environment}-catalogue-tg"
    port      = 8080
    protocol  = "HTTP"
    vpc_id    = local.vpc_id
    deregistration_delay = 60

    health_check {
        healthy_threshold   = 2
        interval             = 10
        matcher              = "200-299"
        path                 = "/health"
        port                 = 8080
        protocol             = "HTTP"
        timeout              = 2
        unhealthy_threshold   = 2
    }
}

resource "aws_launch_template" "catalogue_lt" {
    name   = "${var.project}-${var.environment}-catalogue-lt"
    image_id = aws_ami_from_instance.catalogue_ami.id

#when the auto scale sees less traffic it will termiante the instance
    instance_initiated_shutdown_behavior = "terminate"
    instance_type = "t3.micro"
    vpc_security_group_ids = [local.catalogue_sg_id]

## each time we apply terraform this version will be updated as default
    update_default_version = true

    tag_specifications {
        resource_type = "instance"
        tags = merge(
            {
                Name = "${var.project}-${var.environment}-catalogue"
            },
            local.common_tags
        )
    }

    # tags for volumes created by instances
  tag_specifications {
    resource_type = "volume"

    tags = merge(
        {
            Name = "${var.project}-${var.environment}-catalogue"
        },
        local.common_tags
    )
  }
  # tags for launch template
  tags = merge(
        {
            Name = "${var.project}-${var.environment}-catalogue"
        },
        local.common_tags
    )
}

resource "aws_autoscaling_group" "catalogue_asg" {
    name     = "${var.project}-${var.environment}-catalogue-asg"
    max_size = 10
    min_size = 2
    desired_capacity = 3
    health_check_type = "ELB"
    health_check_grace_period = 120
    force_delete = false

    launch_template {
        id     = aws_launch_template.catalogue_lt.id
        version = "$Latest"
    }

    vpc_zone_identifier = [local.subnet_ids]
    target_group_arns = [aws_lb_target_group.catalogue_tg.arn]

    instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }

    dynamic "tag" {
    for_each = merge(
        {
            Name = "${var.project}-${var.environment}-catalogue"
        },
        local.common_tags
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  # with in 15min autoscaling should be successful
  timeouts {
    delete = "15m"
  }

}

resource "aws_autoscaling_policy" "catalogue_asg_scale_up" {
    autoscaling_group_name = aws_autoscaling_group.catalogue_asg.name
    name                   = "${var.project}-${var.environment}-catalogue-asg-scale-up"
    policy_type            = "TargetTrackingScaling"
    estimated_instance_warmup = 120

    target_tracking_configuration {
        predefined_metric_specification {
            predefined_metric_type  = "ASGAverageCPUUtilization"  
        }
        target_value = 70.0
    }
}

resource "aws_lb_listener_rule" "catalogue_listner_rule" {
    listener_arn = local.listener_arn
    priority = 10

    action {
        type              = "forward"
        target_group_arn = aws_lb_target_group.catalogue_tg.arn
    }

    condition {
        host_header {
            values = ["catalogue.backend-alb-${var.environment}-${var.domain_name}"]
        }
    }

}

resource "terraform_data" "catalogue_delete" {
    triggers_replace = [
        aws.instance.catalogue.id
    ]
    depends_on = [aws_autoscaling_policy.catalogue_asg_scale_up]

    provisioner "local-exec" {
        command = "aws ec2 terminate-instances --instance-ids ${aws_instance.catalogue.id} --region us-east-1"
      
    }
}