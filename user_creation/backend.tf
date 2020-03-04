terraform {
  backend "s3" {
    bucket = "terraform-state-sr"
    key = "terraform/Jenkins_Automation"
    region = "us-east-1"
  }
}

