# Expose the IAM role ARN required by the EKS control plane.
output "cluster_role_arn" {
  description = "IAM role ARN used by the EKS control plane."
  value       = aws_iam_role.eks_cluster.arn
}

# Expose the IAM role ARN required by EKS worker nodes.
output "node_role_arn" {
  description = "IAM role ARN used by the EKS worker nodes."
  value       = aws_iam_role.eks_node.arn
}
