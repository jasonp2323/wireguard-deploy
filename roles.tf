resource "aws_iam_role" "WireGuardLambdaRole" {
    name = "WireGuardLambdaRole"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Principal = {
                    Service = "lambda.amazonaws.com"
                },
                Action = "sts:AssumeRole"
            }
        ]
    })
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "WireGuardLambdaPolicy" {
    name        = "WireGuardLambdaPolicy"
    description = "A policy for WireGuard Lambda functions"
    policy      = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Action = [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ],
                Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/WireGuard*:*"
            },
            {
                Effect = "Allow",
                Action = [
                    "ec2:StartInstances",
                    "ec2:StopInstances"
                ],
                Resource = aws_instance.wireguard-server.arn
            },
            {
                Effect = "Allow",
                Action = [
                    "ec2:DescribeInstances"
                ],
                Resource = "*"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "WireGuardLambdaRoleAttachment" {
    role       = aws_iam_role.WireGuardLambdaRole.name
    policy_arn = aws_iam_policy.WireGuardLambdaPolicy.arn
}