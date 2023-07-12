# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Define the security group for the instance
resource "aws_security_group" "windowSG" {
  name_prefix = "windowSG-"

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EBS Volume
resource "aws_ebs_volume" "WinVol" {
  availability_zone = "us-east-1c"
  size              = 60
  tags = {
    Name = "WindowsVol"
  }
}

# Define the EC2 instance
resource "aws_instance" "windows-server" {
  ami               = "ami-0e38fa17744b2f6a5"
  availability_zone = "us-east-1c"
  instance_type     = "t2.xlarge"
  key_name          = "AWSKEYPAIR"
  vpc_security_group_ids = [
    aws_security_group.windowSG.id,
  ]

  root_block_device {

    volume_type = "gp2"
    volume_size = 60
    delete_on_termination = true
    encrypted = true
  }

  lifecycle {
  ignore_changes = [
      root_block_device
    ]
  }

  user_data = <<EOF
    <powershell>
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

    choco install virtualbox -y
    choco install git -y
    choco install vagrant -y
    choco install jdk8 -y
    choco install maven -y
    choco install vscode -y
    choco install awscli -y
    choco install googlechrome -y
    mkdir C:\jenkins
    </powershell>
EOF
  # cpu_options {
  #   core_count = 2
  #   threads_per_core = 2
  #   virtualization_type = "hvm"
  # }
  tags = {
    Name = "Windows11Instance"
  }
}



# resource "aws_volume_attachment" "WinVol_attachment" {
#   device_name = "/dev/sdf"
#   volume_id   = aws_ebs_volume.WinVol.id
#   instance_id = aws_instance.windows-server.id
# }


