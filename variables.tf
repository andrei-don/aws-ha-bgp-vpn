variable "cloud_vpc_cidr" {
  type        = string
  description = "CIDR range for cloud vpc"
}

variable "onprem_vpc_cidr" {
  type        = string
  description = "CIDR range for onprem vpc"
}

variable "region" {
  type        = string
  description = "Region used for deployment"
}

variable "cloud_subnet_cidr_a" {
  type        = string
  description = "CIDR range for first cloud subnet"
}

variable "cloud_subnet_cidr_b" {
  type        = string
  description = "CIDR range for second cloud subnet"
}

variable "onprem_subnet_public_cidr" {
  type        = string
  description = "CIDR range for first cloud subnet"
}

variable "onprem_subnet_cidr_a" {
  type        = string
  description = "CIDR range for first private onprem subnet"
}

variable "onprem_subnet_cidr_b" {
  type        = string
  description = "CIDR range for second private onprem subnet"
}

variable "onprem_bgp_asn" {
  type        = number
  description = "The BGP ASN for the onprem network"
}