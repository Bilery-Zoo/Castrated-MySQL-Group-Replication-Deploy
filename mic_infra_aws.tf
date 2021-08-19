/*
* author    : Bilery Zoo(bilery.zoo@gmail.com)
* create_ts : 2021-08-20
* remark    : This Terraform tf file is to generally create a POC infra environment of castrated MySQL InnoDB Cluster(MIC) at AWS
*/


resource "aws_vpc" "mic-vpc-poc" {
  assign_generated_ipv6_cidr_block = false
  cidr_block                       = "24.24.24.0/28"
  enable_classiclink               = false
  enable_classiclink_dns_support   = false
  enable_dns_hostnames             = true
  enable_dns_support               = true
  instance_tenancy                 = "default"
  tags = {
    "Name"    = "mic-vpc-poc"
    "Service" = "MySQL,MySQL Router,"
    "Utility" = "pmm,"
  }
}

resource "aws_subnet" "mic-subnet-poc" {
  assign_ipv6_address_on_creation = false
  cidr_block                      = "24.24.24.0/28"
  map_public_ip_on_launch         = false
  tags = {
    "Name"    = "mic-subnet-poc"
    "Service" = "MySQL,"
  }
  vpc_id = aws_vpc.mic-vpc-poc.id
}

resource "aws_security_group" "mic-admin-sg-poc" {
  description = "admin servers sg"
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description = ""
      from_port   = 0
      ipv6_cidr_blocks = [
        "::/0",
      ]
      prefix_list_ids = []
      protocol        = "-1"
      security_groups = []
      self            = false
      to_port         = 0
    },
  ]
  ingress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "mysqlrouter classic"
      from_port        = 33066
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 33066
    },
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "mysqlrouter mysqlx"
      from_port        = 33099
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 33099
    },
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "pmm"
      from_port        = 443
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 443
    },
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "pmm"
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    },
    {
      cidr_blocks = [
        "24.24.24.0/28",
      ]
      description      = "pmm"
      from_port        = 7771
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 7771
    },
  ]
  name = "mic-admin-sg-poc"
  tags = {
    "Name"    = "mic-admin-sg-poc"
    "Role"    = "admin,"
    "Service" = "MySQL Router,"
    "Utility" = "pmm,"
  }
  vpc_id = aws_vpc.mic-vpc-poc.id
}

resource "aws_security_group" "mic-node-sg-poc" {
  description = "node servers sg"
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description = ""
      from_port   = 0
      ipv6_cidr_blocks = [
        "::/0",
      ]
      prefix_list_ids = []
      protocol        = "-1"
      security_groups = []
      self            = false
      to_port         = 0
    },
  ]
  ingress = [
    {
      cidr_blocks = [
        "24.24.24.0/28",
      ]
      description      = ""
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
    {
      cidr_blocks = [
        "24.24.24.0/28",
      ]
      description      = ""
      from_port        = 3306
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 3306
    },
    {
      cidr_blocks = [
        "24.24.24.0/28",
      ]
      description      = "mgr"
      from_port        = 33033
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 33033
    },
    {
      cidr_blocks = [
        "24.24.24.0/28",
      ]
      description      = "mysqlx plugin"
      from_port        = 33060
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 33060
    },
    {
      cidr_blocks = [
        "24.24.24.0/28",
      ]
      description      = "pmm"
      from_port        = 42000
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 42002
    },
    {
      cidr_blocks = [
        "24.24.24.0/28",
      ]
      description      = "pmm"
      from_port        = 8428
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 8428
    },
  ]
  name = "mic-node-sg-poc"
  tags = {
    "Name"    = "mic-node-sg-poc"
    "Role"    = "node,"
    "Service" = "MySQL,"
    "Utility" = "pmm,"
  }
  vpc_id = aws_vpc.mic-vpc-poc.id
}

resource "aws_internet_gateway" "mic-admin-igw-poc" {
  tags = {
    "Name"    = "mic-admin-igw-poc"
    "Role"    = "admin,"
    "Service" = "MySQL Router,"
    "Utility" = "pmm,"
  }
  vpc_id = aws_vpc.mic-vpc-poc.id
}

resource "aws_route_table" "mic-admin-rtb-poc" {
  propagating_vgws = []
  route = [
    {
      carrier_gateway_id         = ""
      cidr_block                 = "0.0.0.0/0"
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      gateway_id                 = aws_internet_gateway.mic-admin-igw-poc.id
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      nat_gateway_id             = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    },
  ]
  tags = {
    "Name"    = "mic-admin-rtb-poc"
    "Role"    = "admin,"
    "Service" = "MySQL Router,"
    "Utility" = "pmm,"
  }
  vpc_id = aws_vpc.mic-vpc-poc.id
}

# Your attention to define your public key below
resource "aws_key_pair" "mic-poc" {
  key_name   = "mic-poc"
  public_key = "ssh-rsa ****** "
  tags       = {
    "Name"    = "mic-poc"
    "Service" = "MySQL,MySQL Router,"
    "Utility" = "pmm,"
  }
}

resource "aws_instance" "mic-admin-ec2-poc" {
  ami                                  = "ami-01f328f87670cc361"
  associate_public_ip_address          = true
  availability_zone                    = "ap-northeast-1a"
  disable_api_termination              = false
  ebs_optimized                        = false
  get_password_data                    = false
  hibernation                          = false
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = "t2.small"
  ipv6_address_count                   = 0
  ipv6_addresses                       = []
  key_name                             = "mic-poc"
  monitoring                           = false
  secondary_private_ips                = []
  security_groups                      = []
  source_dest_check                    = true
  subnet_id                            = aws_subnet.mic-subnet-poc.id
  tags = {
    "Name" = "mic-admin-ec2-poc"
  }
  tenancy = "default"
  vpc_security_group_ids = [
    aws_security_group.mic-admin-sg-poc.id,
  ]

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  credit_specification {
    cpu_credits = "standard"
  }

  enclave_options {
    enabled = false
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "optional"
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = false
    iops                  = 100
    tags = {
      "Name" = "mic-admin-ec2-poc"
    }
    throughput  = 0
    volume_size = 10
    volume_type = "gp2"
  }
}

resource "aws_instance" "mic-node-primary-ec2-poc" {
  ami                                  = "ami-01f328f87670cc361"
  associate_public_ip_address          = true
  availability_zone                    = "ap-northeast-1a"
  disable_api_termination              = false
  ebs_optimized                        = false
  get_password_data                    = false
  hibernation                          = false
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = "t2.small"
  ipv6_address_count                   = 0
  ipv6_addresses                       = []
  key_name                             = "mic-poc"
  monitoring                           = false
  secondary_private_ips                = []
  security_groups                      = []
  source_dest_check                    = true
  subnet_id                            = aws_subnet.mic-subnet-poc.id
  tags = {
    "Name"    = "mic-node-primary-ec2-poc"
    "Role"    = "node,"
    "Service" = "MySQL,"
    "Utility" = "pmm,"
  }
  tenancy = "default"
  vpc_security_group_ids = [
    aws_security_group.mic-node-sg-poc.id,
  ]

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  credit_specification {
    cpu_credits = "standard"
  }

  enclave_options {
    enabled = false
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "optional"
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = false
    iops                  = 100
    tags = {
      "Name" = "mic-node-primary-ec2-poc"
    }
    throughput  = 0
    volume_size = 10
    volume_type = "gp2"
  }
}

resource "aws_instance" "mic-node-secondary-ec2-poc" {
  ami                                  = "ami-01f328f87670cc361"
  associate_public_ip_address          = true
  availability_zone                    = "ap-northeast-1a"
  disable_api_termination              = false
  ebs_optimized                        = false
  get_password_data                    = false
  hibernation                          = false
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = "t2.small"
  ipv6_address_count                   = 0
  ipv6_addresses                       = []
  key_name                             = "mic-poc"
  monitoring                           = false
  secondary_private_ips                = []
  security_groups                      = []
  source_dest_check                    = true
  subnet_id                            = aws_subnet.mic-subnet-poc.id
  tags = {
    "Name"    = "mic-node-secondary-ec2-poc"
    "Role"    = "node,"
    "Service" = "MySQL,"
    "Utility" = "pmm,"
  }
  tenancy = "default"
  vpc_security_group_ids = [
    aws_security_group.mic-node-sg-poc.id,
  ]

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  credit_specification {
    cpu_credits = "standard"
  }

  enclave_options {
    enabled = false
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "optional"
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = false
    iops                  = 100
    tags = {
      "Name"    = "mic-node-secondary-ec2-poc"
      "Role"    = "node,"
      "Service" = "MySQL,"
      "Utility" = "pmm,"
    }
    throughput  = 0
    volume_size = 10
    volume_type = "gp2"
  }
}
