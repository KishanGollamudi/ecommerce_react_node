# Expose the repository URLs keyed by logical repository name.
output "repository_urls" {
  description = "Map of ECR repository names to repository URLs."
  value = {
    for repository_name, repository in aws_ecr_repository.this :
    repository_name => repository.repository_url
  }
}

# Expose the frontend repository URL directly for CI/CD pipelines.
output "frontend_repository_url" {
  description = "Repository URL for the frontend image."
  value       = aws_ecr_repository.this["frontend"].repository_url
}

# Expose the backend repository URL directly for CI/CD pipelines.
output "backend_repository_url" {
  description = "Repository URL for the backend image."
  value       = aws_ecr_repository.this["backend"].repository_url
}
