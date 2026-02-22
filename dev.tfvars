ami_name = "ami-019715e0d74f695be"

instance_type_name = "t2.medium"

ebs_volumes = {
  volume1 = {
    size = 40
  }
}

key_name = "demoapp"
private_key_path = "/var/lib/jenkins/.ssh/demoapp.pem"