module "component" {
    for_each = var.components
    source   = "git::https://github.com/Ashish20004/roboshop_components_module.git?ref=main"
    component = each.key
    rule_priority = each.value.rule_priority
  
}