resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  vpc_security_group_ids      = [aws_security_group.sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  key_name                    = aws_key_pair.ec2.id
  associate_public_ip_address = true
  root_block_device {
    volume_size = 20
  }
  provisioner "remote-exec" {
    on_failure = fail
    connection {
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }

    inline = [
      "curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE=644 sh -",
      "sudo apt update -y",
      "kubectl create namespace argocd",
      "kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml",
      "export KUBECONFIG=~/.kube/config",
      "mkdir ~/.kube 2> /dev/null",
      "sudo k3s kubectl config view --raw > \"$KUBECONFIG\"",
      "chmod 600 \"$KUBECONFIG\"",
      "sudo apt update -y",
      "curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash",
      "helm repo add falcosecurity https://falcosecurity.github.io/charts",
      "helm repo update",
      "helm install falco falcosecurity/falco --namespace falco --create-namespace --set falcosidekick.enabled=true --set falcosidekick.webui.enabled=true --set config.aws.cloudwatchlogs.loggroup=falco"
    ]
  }
}

resource "aws_key_pair" "ec2" {
  key_name   = "ec2"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "sg" {
  vpc_id = data.aws_vpc.default.id
  name   = "allow_ssh"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "test_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "test_profile"
  role = aws_iam_role.ec2_role.name
}

data "aws_iam_policy_document" "allow_cloudwatch_logs" {
  statement {
    effect    = "Allow"
    actions   = ["logs:*"]
    resources = ["arn:aws:logs:*:*:*"]
  }
}
resource "aws_iam_role_policy" "cloudwatch_policy" {
  name   = "ec2_policy"
  role   = aws_iam_role.ec2_role.id
  policy = data.aws_iam_policy_document.allow_cloudwatch_logs.json
}
