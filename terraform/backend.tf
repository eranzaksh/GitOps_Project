terraform {
  backend "s3" {
    bucket = "gitops-tf-statefile"
    key    = "tfstate"
    region = "eu-north-1"
  }
}