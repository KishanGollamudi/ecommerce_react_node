# Configure Terraform to store state remotely in Amazon S3.
# Best practice: keep state outside the local machine so teams and CI/CD use a single source of truth.
terraform {
  backend "s3" {
    # S3 bucket that stores the Terraform state file.
    # Replace this placeholder with the name of an existing dedicated state bucket.
    bucket = "replace-with-terraform-state-bucket"

    # Path to the state file inside the S3 bucket.
    # Using an environment-specific key keeps state isolated per workspace or environment.
    key = "env/dev/terraform.tfstate"

    # AWS region where the S3 bucket and DynamoDB lock table exist.
    # Keep this aligned with the backend infrastructure region.
    region = "ap-south-1"

    # Encrypt the state file at rest in S3.
    # This should remain enabled because Terraform state can contain sensitive values.
    encrypt = true

    # DynamoDB table used for state locking and consistency checks.
    # Replace this placeholder with the name of an existing lock table.
    dynamodb_table = "replace-with-terraform-lock-table"
  }
}
