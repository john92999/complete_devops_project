variable "ami_name" {
    description = "Name of the AMI image"
    type = string
}

variable "instance_type_name" {
    description = "Type of the instance"
    type = string
}

variable "ingress_rules_complete_project" {
    description = "Ingress rules for ec2 machine"
    type = list(number)
    default = [80,8080,443]
}

variable "vpc_id" {
    description = "VPC ID from the VPC module"
    type = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "ebs_volumes" {
  description = "Extra EBS volumes"
  type = map(object({
    size = number
  }))
}
