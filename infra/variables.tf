variable "region" {
  description = "AWS region for the S3 bucket. CloudFront itself is global."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Used as the bucket name prefix, the OAC name and the Project tag."
  type        = string
  default     = "cloud-resume-site"
}

variable "domain_name" {
  description = "Apex domain of the site. Registered at Registro.br; DNS is delegated to Route 53."
  type        = string
  default     = "pedrobortolini.com.br"
}
