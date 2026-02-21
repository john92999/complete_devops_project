output "vpc_id" {
    description = "VPC ID"
    value = data.aws_vpc.default.id
}