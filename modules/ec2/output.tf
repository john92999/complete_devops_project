output "instance_ip" {
    value = aws_instance.complete_project_ec2.public_ip
}

output "volume_id" {
    value = [for v in aws_ebs_volume.complete_project_ebs: v.id]
}