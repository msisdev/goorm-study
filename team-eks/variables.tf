# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# variable "region" {
#   description = "AWS region"
#   type        = string
#   default     = "us-east-2"
# }

variable "AWS_ACCESS_KEY_ID" {
  description = "AWS Access Key"
  type        = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS Secret Key"
  type        = string
}

# variable "AWS_SSH_KEY_NAME" {
#   description = "Name of the SSH keypair to use in AWS."
#   type        = string
# }

variable "AWS_DEFAULT_REGION" {
  description = "AWS Region"
  type        = string
}
