terraform {
  backend "s3" {
    bucket = "complete-devops-project-bucket"
    key = "stateFile"
    region = "ap-south-1"
  }
}