# Output the EKS cluster name for kubectl, CI/CD, and Argo CD integration.
output "eks_cluster_name" {
  description = "Name of the Amazon EKS cluster."
  value       = module.eks.cluster_name
}

# Output the EKS API server endpoint for kubeconfig generation and cluster access.
output "eks_cluster_endpoint" {
  description = "API server endpoint for the Amazon EKS cluster."
  value       = module.eks.cluster_endpoint
}

# Output the ECR repository URLs used to push frontend and backend container images.
output "ecr_repository_urls" {
  description = "Map of ECR repository names to repository URLs."
  value       = module.ecr.repository_urls
}
