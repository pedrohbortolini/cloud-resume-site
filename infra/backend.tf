# Remote state in S3 with native locking (a .tflock object next to the state, no DynamoDB).
# Partial configuration: the bucket name lives in backend.hcl (gitignored), so the
# public repo carries no bucket name. Init with:
#   terraform init -backend-config=backend.hcl
terraform {
  backend "s3" {
    key          = "cloud-resume-site/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
