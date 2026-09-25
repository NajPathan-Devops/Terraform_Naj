terraform {
  backend "s3" {
    bucket       = "terraform-naj-tfstate-493628259216"
    key          = "terraform-naj/part3/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
