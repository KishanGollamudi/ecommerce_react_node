# Define the shared naming prefix used for all repositories.
variable "name_prefix" {
  description = "Prefix used when naming ECR repositories."
  type        = string
}

# Define how many images to keep per repository for storage cost control.
variable "image_retention_count" {
  description = "Number of images to retain in each ECR repository."
  type        = number
}

# Define the tags applied to each repository.
variable "tags" {
  description = "Common tags applied to ECR repositories."
  type        = map(string)
  default     = {}
}
