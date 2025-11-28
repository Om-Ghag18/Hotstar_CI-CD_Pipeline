terraform {
  backend "s3" {
    bucket = "parking2002"
    key    = "EKS/terraform.tfstate"
    region = "ap-south-1"
  }
}
