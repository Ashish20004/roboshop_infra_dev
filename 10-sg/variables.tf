variable "project" {
    type = string
    default   = "roboshop"

}

variable "environment" {
    type  = string
    default  = "dev"
}

variable "sg_names" {
    type = list 
    default = [
        #Database
        "mongodb", "redis", "mysql", "rabbitmq",

        #Backend
        "catalogue", "cart", "user", "payment", "shipping", 

        #frontend
        "frontend",

        #BackendALB
        "backend_alb",

        # Frontend ALB
        "frontend_alb",

        # Bastion
        "bastion",

        # Openvpn
        "openvpn"
    ]


    }
