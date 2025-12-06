resource "aws_lambda_function" "StartEC2Instance" {
    function_name = "StartEC2Instance"
    handler = "StartEC2Instances.lambda_handler"
    runtime = "python3.13"
    filename = "${path.module}/scripts/StartEC2Instances.zip"
    role = aws_iam_role.WireGuardLambdaRole.arn
}

resource "aws_lambda_function" "StopEC2Instance" {
    function_name = "StopEC2Instance"
    handler = "StopEC2Instances.lambda_handler"
    runtime = "python3.13"
    filename = "${path.module}/scripts/StopEC2Instances.zip"
    role = aws_iam_role.WireGuardLambdaRole.arn
}

# Define the EventBridge rule for stopping instances at 10PM
resource "aws_cloudwatch_event_rule" "every_night_10pm" {
  name                = "StopInstancesAt10PM"
  description         = "Triggers Lambda function at 10 PM every night"
  schedule_expression = "cron(0 22 * * ? *)"
}

# Define the EventBridge rule for starting instances at 6AM
resource "aws_cloudwatch_event_rule" "every_morning_6am" {
  name                = "StartInstancesAt6AM"
  description         = "Triggers Lambda function at 6 AM every morning"
  schedule_expression = "cron(0 6 * * ? *)"
}

# Define the EventBridge target for StartEC2Instance Lambda function
resource "aws_cloudwatch_event_target" "start_ec2_instance_target" {
  rule      = aws_cloudwatch_event_rule.every_morning_6am.name
  target_id = "StartEC2Instance"
  arn       = aws_lambda_function.StartEC2Instance.arn
}

# Define the EventBridge target for StartEC2Instance Lambda function
resource "aws_cloudwatch_event_target" "stop_ec2_instance_target" {
  rule      = aws_cloudwatch_event_rule.every_night_10pm.name
  target_id = "StopEC2Instance"
  arn       = aws_lambda_function.StopEC2Instance.arn
}

# Create the necessary permissions for StartEC2Instance Lambda function
resource "aws_lambda_permission" "allow_eventbridge_to_invoke_start" {
  statement_id  = "AllowStartExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.StartEC2Instance.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_morning_6am.arn
}

# Create the necessary permissions for StopEC2Instance Lambda function
resource "aws_lambda_permission" "allow_eventbridge_to_invoke_stop" {
  statement_id  = "AllowStopExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.StopEC2Instance.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_night_10pm.arn
}