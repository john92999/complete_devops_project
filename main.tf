module "aws_s3_bucket"{
    source = "./modules/s3"
    aws_s3_bucket_name = "complete-devops-project-bucket"
}

module "vpc" {
    source = "./modules/vpc"
}

data "aws_subnets" "default" {
    filter {
        name = "vpc-id"
        values = [module.vpc.vpc_id]
    }
}

variable "ami_name" {
  type = string
}

variable "instance_type_name" {
  type = string
}

variable "ebs_volumes" {
  type = map(object({
    size = number
  }))
}

module "ec2" {
    source = "./modules/ec2"
    ami_name = var.ami_name
    subnet_ids    = data.aws_subnets.default.ids
    vpc_id        = module.vpc.vpc_id
    instance_type_name = var.instance_type_name
    ebs_volumes   = var.ebs_volumes
}