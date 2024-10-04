
variable vpc_cidr_block {
    type = string
    default = "10.0.0.0/16"
}
variable subnet_1_cidr_block {
    type = string
    default = "10.0.10.0/24"
}
variable avail_zone {
    type = string
    default = "us-east-1a"
}
variable env_prefix {
    type = string
    default = "dev"
}
variable instance_type {
    type = string
    default = "t2.micro"
}
variable ssh_key {
    type = string
    default = "path/to/your/key"
}
