variable "region" { default = "ap-south-1" }
variable "project_name" { default = "trend" }
variable "key_pair_name" { description = "Existing EC2 key pair to SSH" }
variable "jenkins_instance_type" { default = "t3.medium" }
variable "allowed_cidr" { default = "0.0.0.0/0" } # tighten in prod
