terraform {
  backend "s3" {
    bucket = "leumi-tf-statefile"
    key    = "tfstate"
    region = "eu-north-1"
  }
}