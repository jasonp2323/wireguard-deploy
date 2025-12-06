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
                Resource = "arn:aws:logs:*:*:*"
            },
            {
                Effect = "Allow",
                Action = [
                    "ec2:Start*",
                    "ec2:Stop*",
                    "ec2:Describe*"
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