data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20181024-x86_64-gp2"]
  }
}

data "aws_ecr_repository" "example_app" {
  name = "snowiow/example-app"
}

data "template_file" "user_data" {
  template = "${file("user_data.sh")}"

  vars {
    mongodb_dsn    = "mongodb://${mongodbatlas_database_user.this.username}:${mongodbatlas_database_user.this.password}@${substr(mongodbatlas_cluster.this.mongo_uri_with_options, 10, -1)}"
    docker_img_url = "${data.aws_ecr_repository.example_app.repository_url}"
  }
}

data "aws_iam_policy_document" "assume" {
  statement {
    sid     = "AllowAssumeByEC2"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "example_app" {
  name               = "example-app-iam-role"
  assume_role_policy = "${data.aws_iam_policy_document.assume.json}"
}

data "aws_iam_policy_document" "ecr" {
  statement {
    sid    = "AllowECRAuthorization"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowECRDownload"
    effect = "Allow"

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
    ]

    resources = ["${data.aws_ecr_repository.example_app.arn}"]
  }
}

resource "aws_iam_policy" "ecr" {
  name        = "ExampleAppECRAccess"
  description = "Gives right to get an ECR authorization token and pull images"
  policy      = "${data.aws_iam_policy_document.ecr.json}"
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = "${aws_iam_role.example_app.name}"
  policy_arn = "${aws_iam_policy.ecr.arn}"
}

resource "aws_iam_instance_profile" "this" {
  name = "example-app-instance-profile"
  role = "${aws_iam_role.example_app.name}"
}

resource "aws_security_group" "this" {
  name   = "sg"
  vpc_id = "${aws_vpc.this.id}"

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_instance" "this" {
  ami                  = "${data.aws_ami.amazon_linux.id}"
  instance_type        = "t2.micro"
  subnet_id            = "${aws_subnet.this.id}"
  user_data            = "${data.template_file.user_data.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.this.name}"
  security_groups      = ["${aws_security_group.this.id}"]
}

output "example_app" {
  value = "${aws_instance.this.public_ip}"
}
