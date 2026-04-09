# Allow only the Amazon EKS service to assume the control plane role.
# This trust policy limits who can use the role and is the first layer of least privilege.
data "aws_iam_policy_document" "eks_cluster_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

# Allow only Amazon EC2 instances in the managed node group to assume the worker role.
# This keeps the node role scoped to EKS worker nodes instead of arbitrary principals.
data "aws_iam_policy_document" "eks_node_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Create the IAM role used by the EKS control plane.
# The role itself has no inline permissions; access is granted only through the attached AWS managed policy below.
resource "aws_iam_role" "eks_cluster" {
  name               = "${var.name_prefix}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json
  tags               = merge(var.tags, { Name = "${var.name_prefix}-eks-cluster-role" })
}

# Create the IAM role used by the EKS managed node group.
# As with the cluster role, permissions stay explicit through specific managed policy attachments only.
resource "aws_iam_role" "eks_node" {
  name               = "${var.name_prefix}-eks-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json
  tags               = merge(var.tags, { Name = "${var.name_prefix}-eks-node-role" })
}

# Attach the minimum AWS managed policy required for standard EKS control plane operation.
# This avoids adding broader administrator-style permissions to the cluster role.
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Attach the policy required for worker nodes to join and communicate with the EKS cluster.
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Attach the VPC CNI policy so worker nodes can manage pod networking.
# This is required for pods to receive IP addresses in the VPC.
resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# Attach read-only ECR access so worker nodes can pull images without receiving push or admin permissions.
resource "aws_iam_role_policy_attachment" "eks_ecr_read_only_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
