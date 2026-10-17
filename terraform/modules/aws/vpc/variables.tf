variable "name" {
  description = "Short lowercase prefix for VPC resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.name))
    error_message = "name must start with a letter and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "cidr_block" {
  description = "IPv4 CIDR for the VPC. Public and private subnets are carved from this block."
  type        = string

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "cidr_block must be a valid IPv4 CIDR."
  }
}

variable "availability_zones" {
  description = "Availability zone names, in subnet order. Names are pinned so a newly announced zone cannot change the layout."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2 && length(var.availability_zones) <= 3
    error_message = "Provide two or three availability zone names."
  }
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway for every private subnet. Set false for one NAT gateway per availability zone."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Extra tags applied to taggable resources. Provider default_tags are merged by AWS as well."
  type        = map(string)
  default     = {}
}
