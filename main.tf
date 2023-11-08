#Create a VPC
resource "aws_vpc" "vpc_demo" {

    cidr_block = "12.0.0.0/16"

    enable_dns_support = "true" #gives you an internal domain name

    enable_dns_hostnames = "true" #gives you an internal host name

    instance_tenancy = "default"

    tags = {
        Name = "my-vpc"
    }
}

#Create a Public Subnet
resource "aws_subnet" "sub1" {
    vpc_id = aws_vpc.vpc_demo.id
    cidr_block = "12.0.1.0/24"
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = "ap-south-1a"
    tags = {
        Name = "pub-sub"
    }
}

#Create a Private Subnet
resource "aws_subnet" "sub2" {
    vpc_id = aws_vpc.vpc_demo.id
    cidr_block = "12.0.10.0/24"
    map_public_ip_on_launch = "false"
    availability_zone = "ap-south-1b"
    tags = {
        Name = "pri-sub"
    }
}

#Create Internet Gateway and attach it to VPC
resource "aws_internet_gateway" "igw" {
   vpc_id = aws_vpc.vpc_demo.id
   tags = {
       Name = "my_igw"
   }
}

#Create a Public Route Table
resource "aws_route_table" "pubRT" {
  vpc_id = aws_vpc.vpc_demo.id
  tags = {
       Name = "public-routetable"
  }
}

#Create a Private Route Table
resource "aws_route_table" "privRT" {
  vpc_id = aws_vpc.vpc_demo.id
  tags = {
       Name = "private-routetable"
  }
}

#Associate Public Subnet to Public Route Table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.pubRT.id
}

#Associate Private Subnet to Private Route Table
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.privRT.id
}

#Add a rule for allowing anyone to connect to public subnet instance via internet gateway
resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.pubRT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

#Create a security group which allows HTTP and SSH traffic
resource "aws_security_group" "pub_sg" {
  vpc_id = aws_vpc.vpc_demo.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#Create an EC2 instance in public subnet and launch apache web server in it
resource "aws_instance" "pub_ec2" {

  ami           = var.ec2_ami

  instance_type = var.inst_type

  availability_zone = var.inst_az

  key_name = "kv-key"

  vpc_security_group_ids      = [aws_security_group.pub_sg.id]

  subnet_id = aws_subnet.sub1.id

  user_data = <<-EOF
  #!/bin/bash
  yum update -y
  yum install httpd -y
  systemctl start httpd
  systemctl enable httpd
  echo "<h1> Hello World </h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "pub_myec2_inst"
  }
}
