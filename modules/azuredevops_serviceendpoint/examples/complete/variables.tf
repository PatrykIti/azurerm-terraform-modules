variable "project_id" {
  description = "Azure DevOps project ID."
  type        = string
}

variable "github_endpoint_name" {
  description = "GitHub service endpoint name."
  type        = string
  default     = "ado-github-complete"
}

variable "github_personal_access_token" {
  description = "GitHub personal access token."
  type        = string
  sensitive   = true
}

variable "aws_endpoint_name" {
  description = "AWS service endpoint name."
  type        = string
  default     = "ado-aws-complete"
}

variable "aws_access_key_id" {
  description = "AWS access key ID."
  type        = string
}

variable "aws_secret_access_key" {
  description = "AWS secret access key."
  type        = string
  sensitive   = true
}

variable "kubernetes_endpoint_name" {
  description = "Kubernetes service endpoint name."
  type        = string
  default     = "ado-k8s-complete"
}

variable "kubernetes_api_url" {
  description = "Kubernetes API server URL."
  type        = string
  default     = "https://example.kubernetes.local"
}

variable "kubeconfig_content" {
  description = "Kubeconfig content used for the Kubernetes service endpoint."
  type        = string
  default     = <<EOT
apiVersion: v1
clusters:
- cluster:
    certificate-authority: fake-ca-file
    server: https://1.2.3.4
  name: development
contexts:
- context:
    cluster: development
    namespace: default
    user: developer
  name: dev-default
current-context: dev-default
kind: Config
preferences: {}
users:
- name: developer
  user:
    client-certificate: fake-cert-file
    client-key: fake-key-file
EOT
}

variable "kubeconfig_context" {
  description = "Context name inside the kubeconfig."
  type        = string
  default     = "dev-default"
}
