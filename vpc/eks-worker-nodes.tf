#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#

resource "aws_iam_role" "demo-node" {
  name = "terraform-eks-demo-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.demo-node.name}"
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.demo-node.name}"
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.demo-node.name}"
}

resource "aws_security_group" "tf-eks-node" {
    name        = "terraform-eks-node"
    description = "Security group for all nodes in the cluster"
    vpc_id      = "${aws_vpc.demo.id}"
 
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
 
    tags = {
        Name = "terraform-eks"
    }
}
 
resource "aws_security_group_rule" "tf-eks-node-ingress-workstation-ssh" {
  cidr_blocks       = ["${local.workstation-external-cidr}"]
  description       = "Allow workstation to communicate with the Kubernetes nodes directly."
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.tf-eks-node.id}"
  to_port           = 22
  type              = "ingress"
}

resource "aws_eks_node_group" "demo" {
  cluster_name    = "${aws_eks_cluster.demo.name}"
  node_group_name = "demo"
  node_role_arn   = "${aws_iam_role.demo-node.arn}"
  subnet_ids      = "${aws_subnet.private[*].id}"

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  remote_access {
    ec2_ssh_key = "${var.keypair}"
  #  source_security_group_ids = 
  }

  depends_on = [
    "aws_iam_role_policy_attachment.demo-node-AmazonEKSWorkerNodePolicy",
    "aws_iam_role_policy_attachment.demo-node-AmazonEKS_CNI_Policy",
    "aws_iam_role_policy_attachment.demo-node-AmazonEC2ContainerRegistryReadOnly",
  ]
}

resource "aws_security_group_rule" "update-for-8080" {
  cidr_blocks       = ["${aws_network_interface.nic2.private_ip}/32"]
  description       = "Allow 8080"
  from_port         = 8080
  protocol          = "tcp"
  security_group_id = "${aws_eks_node_group.demo.resources.0.remote_access_security_group_id}"
  to_port           = 8080
  type              = "ingress"

  depends_on = [
    "aws_eks_node_group.demo"
  ]
}
