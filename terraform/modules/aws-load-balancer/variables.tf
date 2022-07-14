variable "eks_cluster_name" {
  type = string
}

variable "eks_oidc_provider_arn" {
  type = string
}

variable "tags" {
  type = map(string)
}
