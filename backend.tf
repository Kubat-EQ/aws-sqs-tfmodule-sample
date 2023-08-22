terraform {
  backend "s3" {
    bucket               = "company-prod-infosec-tfstate-us-east-1"
    key                  = "aws-sqs-tfmodules.tfstate"
    workspace_key_prefix = "aws-sqs-tfmodules"
    region               = "us-east-1"
    dynamodb_table       = "tfstate-lock"
    profile              = "company-prod-infosec-terraform"
  }
}
