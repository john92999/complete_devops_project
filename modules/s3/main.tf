resource "aws_s3_bucket" "complete_project" {
    bucket = var.aws_s3_bucket_name
    tags = {
        name = "devops_complete_project_bucket"
    }
    force_destroy = true
}

