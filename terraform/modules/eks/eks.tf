module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.26.3"

  cluster_name                    = var.name
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  cluster_ip_family               = "ipv4"
  tags                            = var.tags

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
      addon_version     = "v1.8.7-eksbuild.1"
    }
    kube-proxy = {
      resolve_conflicts = "OVERWRITE"
      addon_version     = "v1.22.6-eksbuild.1"
    }
    vpc-cni = {
      resolve_conflicts        = "OVERWRITE"
      addon_version            = "v1.11.2-eksbuild.1"
      service_account_role_arn = module.vpc_cni_ipv4_irsa_role.iam_role_arn
    }
  }

  create_kms_key                  = true
  kms_key_deletion_window_in_days = 7
  enable_kms_key_rotation         = true
  cluster_encryption_config = [{
    resources = ["secrets"]
  }]

  cluster_tags = {
    Name = var.name
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  manage_aws_auth_configmap = false

  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    aws_lb_controller_webhook = {
      description                   = "Cluster API to AWS LB Controller webhook"
      protocol                      = "all"
      from_port                     = 8443
      to_port                       = 8443
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  eks_managed_node_group_defaults = {
    ami_type                   = "AL2_x86_64"
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
    default_node_group = {
      min_size       = 1
      max_size       = 10
      desired_size   = 2
      instance_types = ["t3.small"]
      capacity_type  = "SPOT"
      disk_size      = 50
    }
  }
}
