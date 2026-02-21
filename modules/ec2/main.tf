resource "aws_instance" "complete_project_ec2" {
    availability_zone = local.availability_zone
    ami = var.ami_name
    instance_type = var.instance_type_name
    key_name = "demoapp"
    vpc_security_group_ids = [aws_security_group.complete_project_security_group.id]
    tags = {
      Name = "complete_project_ec2_machine"
    }
}

resource "aws_security_group" "complete_project_security_group" {
    name        = "complete_project_sg"
    description = "Security group for complete project"
    vpc_id      = var.vpc_id
    dynamic "ingress" {
        for_each = var.ingress_rules_complete_project
        content {
        from_port = ingress.value
        to_port = ingress.value
        protocol = "tcp"
        cidr_blocks = local.cidr_block_number
        }
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = local.cidr_block_number
    }
}

resource "aws_ebs_volume" "complete_project_ebs" {
    for_each = var.ebs_volumes
    availability_zone = local.availability_zone
    size = each.value.size
    type = "gp3"
    tags = {
    Name = each.key
  }

}

resource "aws_volume_attachment" "complete_project_attachment" {
  for_each = var.ebs_volumes
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.complete_project_ebs[each.key].id
  instance_id = aws_instance.complete_project_ec2.id
}   
