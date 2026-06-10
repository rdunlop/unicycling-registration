data "aws_iam_user" "app" {
  user_name = var.iam_user_name
}

resource "aws_iam_user_policy" "acm_and_elb" {
  name = "unicycling-acm-elb-${var.environment}"
  user = data.aws_iam_user.app.user_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "acm:RequestCertificate",
          "acm:DescribeCertificate",
          "acm:ListCertificates",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:AddListenerCertificates",
          "elasticloadbalancing:DescribeListenerCertificates",
        ]
        Resource = "*"
      }
    ]
  })
}
