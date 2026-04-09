# Keep this module intentionally narrow and create only the application repositories
# required by this project.
locals {
  repository_names = toset(["frontend", "backend"])
}

# Create the two ECR repositories used by the frontend and backend services.
# Scan on push is enabled to get basic vulnerability visibility without extra infrastructure.
resource "aws_ecr_repository" "this" {
  for_each = local.repository_names

  name                 = "${var.name_prefix}/${each.value}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    var.tags,
    {
      Name      = "${var.name_prefix}-${each.value}"
      CostScope = "container-registry"
    }
  )
}

# Expire older images so repository storage remains small and predictable over time.
# This keeps only a limited number of recent images in each repository for cost efficiency.
resource "aws_ecr_lifecycle_policy" "this" {
  for_each = aws_ecr_repository.this

  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the most recent images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.image_retention_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
