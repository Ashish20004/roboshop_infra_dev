# VPC Infrastructure

This folder sets up the network that everything else in the **RoboShop Dev environment** runs on. Before any servers, databases, or load balancers can exist, they need somewhere to live, and this is that place.

Instead of writing raw AWS resources here, we use a reusable Terraform VPC module. That keeps the code short, consistent, and easy to reuse for other environments (qa, prod) later.

---

## What Gets Created

Running this configuration gives you:

- **VPC** with the CIDR block you provide
- **Public subnets** for anything that needs to be reachable from the internet (like load balancers)
- **Private subnets** for application servers (catalogue, cart, user, etc.)
- **Database subnets** for MongoDB, MySQL, Redis, and RabbitMQ, kept isolated from everything else
- **Internet Gateway** so public subnets can talk to the internet
- **NAT Gateway + Elastic IP** so private subnets can reach the internet (for updates, package installs) without being exposed
- **Route tables** for public, private, and database tiers, each associated with the right subnets

### Architecture at a Glance

```
                    Internet
                       |
                [Internet Gateway]
                       |
   +-------------------+--------------------+
   |                  VPC                   |
   |                                        |
   |  Public Subnets   (1a, 1b)             |
   |     |-- NAT Gateway                    |
   |                                        |
   |  Private Subnets  (1a, 1b)             |
   |     |-- App servers -> via NAT         |
   |                                        |
   |  Database Subnets (1a, 1b)             |
   |     |-- Databases (no direct internet) |
   +----------------------------------------+
```

> Adjust the availability zones above to match what you actually use.

---

## Prerequisites

Before you run anything, make sure you have:

- Terraform installed (version `>= x.x.x`, update with your version)
- AWS CLI configured with credentials that can create VPC, subnet, route table, gateway, and SSM resources
- Access to the remote backend (S3 bucket and DynamoDB table for state locking), if your setup uses one

---

## Inputs

| Variable | Description | Default |
|----------|-------------|---------|
| `project` | Project name, used for naming and tagging | `roboshop` |
| `environment` | Environment name | `dev` |
| `vpc_cidr` | CIDR block for the VPC | `10.0.0.0/16` |
| `public_subnet_cidrs` | List of CIDRs for public subnets | |
| `private_subnet_cidrs` | List of CIDRs for private subnets | |
| `database_subnet_cidrs` | List of CIDRs for database subnets | |

> Update this table so it matches the variables in your `variables.tf`.

---

## How to Run

```bash
terraform init
terraform plan
terraform apply
```

To tear it down:

```bash
terraform destroy
```

**Order matters.** This is the foundation of the environment, so apply it **first**, before security groups, databases, and servers. When destroying, do it **last**, otherwise AWS will refuse to delete a VPC that still has resources inside it.

---

## Where the Module Comes From

The networking resources come from a reusable module:

```hcl
module "vpc" {
  source = "<module-source-path-or-git-url>?ref=<version>"
  # inputs...
}
```

> Replace the source with your actual module location, and pin a version or tag so changes in the module never surprise you.

---

## Sharing Values Through SSM Parameter Store

Once the VPC is built, its important IDs are saved in **AWS Systems Manager Parameter Store**. Other Terraform folders (security groups, databases, app servers) read these values from there, so nobody has to copy and paste IDs by hand or hardcode them.

| Parameter Name | What It Holds |
|----------------|---------------|
| `/roboshop/dev/vpc_id` | VPC ID |
| `/roboshop/dev/public_subnet_ids` | Public subnet IDs |
| `/roboshop/dev/private_subnet_ids` | Private subnet IDs |
| `/roboshop/dev/database_subnet_ids` | Database subnet IDs |

> Make sure these names match what your code actually creates.

### Using These Values in Another Component

```hcl
data "aws_ssm_parameter" "vpc_id" {
  name = "/roboshop/dev/vpc_id"
}

# Use it like this:
# data.aws_ssm_parameter.vpc_id.value
```

Subnet IDs are stored as a comma-separated string, so split them when you need a list:

```hcl
data "aws_ssm_parameter" "private_subnet_ids" {
  name = "/roboshop/dev/private_subnet_ids"
}

locals {
  private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
}
```

### Why Bother With This?

- No hardcoded resource IDs anywhere
- Each Terraform component can be applied on its own
- Easier to maintain as the infrastructure grows
- The same pattern works across environments

---

## Terraform Outputs

The following values are also available as outputs, in case you want to reference them directly:

- `vpc_id`
- `public_subnet_ids`
- `private_subnet_ids`
- `database_subnet_ids`

---

## Known Limitations / TODO

- Dev uses a **single NAT Gateway** to save cost. If that AZ goes down, private subnets lose outbound internet. For prod, use one NAT Gateway per AZ.
- No VPC peering or VPN yet.
- No VPC endpoints (S3, SSM) yet. Adding them would reduce NAT traffic and cost.

---

## Status

The VPC, all three subnet tiers, gateways, route tables, SSM parameters, and outputs are all in place and working.