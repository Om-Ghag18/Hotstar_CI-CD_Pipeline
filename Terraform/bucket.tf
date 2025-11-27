terraform {
  backend "s3" {
    bucket = "parking2025"
    key    = "EKS/terraform.tfstate"
    region = "ap-south-1"
  }
}