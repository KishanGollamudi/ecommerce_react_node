# Define the shared naming prefix used for IAM roles.
variable "name_prefix" {
  description = "Prefix used when naming IAM roles."
  type        = string
}

# Define the common tags applied to IAM resources.
variable "tags" {
  description = "Common tags applied to IAM resources."
  type        = map(string)
  default     = {}
}
