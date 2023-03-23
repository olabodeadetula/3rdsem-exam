provider "aws" {
  region = "eu-west-2"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version ="~> 3.0"  
    }
  }

}

# Create VPC

resource "aws_vpc" "thirdexam-vpc" {
  cidr_block           = "10.0.0.0/16"

  tags = {
    Name = "thirdexam-vpc"
  }
}

# Create Internet Gateway

resource "aws_internet_gateway" "thirdexam-igw" {
  vpc_id = aws_vpc.thirdexam-vpc.id
  tags = {
    Name = "thirdexam-igw"
  }
}

# Create private and public subnets

resource "aws_subnet" "thirdexam-private-subnet1a" {
  vpc_id                  = aws_vpc.thirdexam-vpc.id
  cidr_block              = "10.0.0.0/19"
  availability_zone       = "eu-west-2a"
  tags = {
    "Name"                            = "thirdexam-private-subnet1a"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/exam"      = "owned"
  }
}

resource "aws_subnet" "thirdexam-private-subnet1b" {
  vpc_id                  = aws_vpc.thirdexam-vpc.id
  cidr_block              = "10.0.32.0/19"
  availability_zone       = "eu-west-2b"
  tags = {
    "Name"                            = "thirdexam-private-subnet1b"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/exam"      = "owned"
  }
}

resource "aws_subnet" "thirdexam-public-subnet1a" {
  vpc_id                  = aws_vpc.thirdexam-vpc.id
  cidr_block              = "10.0.64.0/19"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-2a"
  tags = {
    "Name"                            = "thirdexam-public-subnet1a"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/exam"      = "owned"
  }
}

resource "aws_subnet" "thirdexam-public-subnet1b" {
  vpc_id                  = aws_vpc.thirdexam-vpc.id
  cidr_block              = "10.0.96.0/19"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-2b"
  tags = {
    "Name"                            = "thirdexam-public-subnet1b"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/exam"      = "owned"
  }
}

# Create NAT Gateway

resource "aws_eip" "thirdexam-ngw" {
  vpc = true

  tags = {
    Name = "thirdexam-ngw"
  }
}

resource "aws_nat_gateway" "thirdexam-ngw" {
  allocation_id = aws_eip.thirdexam-ngw.id
  subnet_id     = aws_subnet.thirdexam-public-subnet1a.id

  tags = {
    Name = "thirdexam-ngw"
  }

  depends_on = [aws_internet_gateway.thirdexam-igw]
}

# Create routing tables and associate with subnets

resource "aws_route_table" "thirdexam-private" {
  vpc_id = aws_vpc.thirdexam-vpc.id

  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = aws_nat_gateway.thirdexam-ngw.id
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      gateway_id                 = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    },
  ]

  tags = {
    Name = "thirdexam-private"
  }
}

resource "aws_route_table" "thirdexam-public" {
  vpc_id = aws_vpc.thirdexam-vpc.id

  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.thirdexam-igw.id
      nat_gateway_id             = ""
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    },
  ]

  tags = {
    Name = "thirdexam-public"
  }
}

resource "aws_route_table_association" "thirdexam-private-subnet1a" {
  subnet_id      = aws_subnet.thirdexam-private-subnet1a.id
  route_table_id = aws_route_table.thirdexam-private.id
}

resource "aws_route_table_association" "thirdexam-private-subnet1b" {
  subnet_id      = aws_subnet.thirdexam-private-subnet1b.id
  route_table_id = aws_route_table.thirdexam-private.id
}

resource "aws_route_table_association" "thirdexam-public-subnet1a" {
  subnet_id      = aws_subnet.thirdexam-public-subnet1a.id
  route_table_id = aws_route_table.thirdexam-public.id
}

resource "aws_route_table_association" "thirdexam-public-subnet1b" {
  subnet_id      = aws_subnet.thirdexam-public-subnet1b.id
  route_table_id = aws_route_table.thirdexam-public.id
}

# Create EKS Cluster

resource "aws_iam_role" "exam" {
  name = "examsekscluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "exam-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.exam.name
}

resource "aws_eks_cluster" "exam" {
  name     = "exam"
  role_arn = aws_iam_role.exam.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.thirdexam-private-subnet1a.id,
      aws_subnet.thirdexam-private-subnet1b.id,
      aws_subnet.thirdexam-public-subnet1a.id,
      aws_subnet.thirdexam-public-subnet1b.id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.exam-AmazonEKSClusterPolicy]
}

# Create a single instance group

resource "aws_iam_role" "thirdexamnodes" {
  name = "exam-eks-nodegroup"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.thirdexamnodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.thirdexamnodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.thirdexamnodes.name
}

resource "aws_eks_node_group" "thirdexam-private-nodes" {
  cluster_name    = aws_eks_cluster.exam.name
  node_group_name = "thirdexam-private-nodes"
  node_role_arn   = aws_iam_role.thirdexamnodes.arn

  subnet_ids = [
    aws_subnet.thirdexam-private-subnet1a.id,
    aws_subnet.thirdexam-private-subnet1b.id
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.large"]

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  # taint {
  #   key    = "team"
  #   value  = "devops"
  #   effect = "NO_SCHEDULE"
  # }

  # launch_template {
  #   name    = aws_launch_template.eks-with-disks.name
  #   version = aws_launch_template.eks-with-disks.latest_version
  # }

  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
  ]
}

# resource "aws_launch_template" "eks-with-disks" {
#   name = "eks-with-disks"

#   key_name = "local-provisioner"

#   block_device_mappings {
#     device_name = "/dev/xvdb"

#     ebs {
#       volume_size = 50
#       volume_type = "gp2"
#     }
#   }
# }


# Create IAM OIDC

data "tls_certificate" "eks" {
  url = aws_eks_cluster.exam.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.exam.identity[0].oidc[0].issuer
}

