# First, we need a role to play with Lambda
resource "aws_iam_role" "iam_role_for_lambda" {
  name = "iam_role_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# function that will run the code `rtcm_lambda.handler`
module "lambda" {
  source  = "./lambda"
  name    = "rtcm_lambda"
  runtime = "python2.7"
  role    = "${aws_iam_role.iam_role_for_lambda.arn}"
}

# Now, we need an API to expose those functions publicly
resource "aws_api_gateway_rest_api" "cloudgnss_api" {
  name = "cloudgnss API"
  binary_media_types = ["application/octet-stream"]
}

# The API requires at least one "endpoint", or "resource" in AWS terminology.
# The endpoint created here is: /rtcm
resource "aws_api_gateway_resource" "cloudgnss_api_res_rtcm" {
  rest_api_id = "${aws_api_gateway_rest_api.cloudgnss_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.cloudgnss_api.root_resource_id}"
  path_part   = "rtcm"
}

# Until now, the resource created could not respond to anything. We must set up
# a HTTP method (or verb) for that!
# This is the code for method POST /rtcm, that will talk to the lambda
module "cloudgnss" {
  source      = "./api_method"
  rest_api_id = "${aws_api_gateway_rest_api.cloudgnss_api.id}"
  resource_id = "${aws_api_gateway_resource.cloudgnss_api_res_rtcm.id}"
  method      = "POST"
  path        = "${aws_api_gateway_resource.cloudgnss_api_res_rtcm.path}"
  lambda      = "${module.lambda.name}"
  region      = "${var.aws_region}"
  account_id  = "${data.aws_caller_identity.current.account_id}"
}


# We can deploy the API now! (i.e. make it publicly available)
resource "aws_api_gateway_deployment" "rtcm_api_deployment" {
  rest_api_id = "${aws_api_gateway_rest_api.cloudgnss_api.id}"
  stage_name  = "production"
  description = "Deploy methods: ${module.cloudgnss.http_method}"
}

output "endpoint" {
  value = "https://${aws_api_gateway_rest_api.cloudgnss_api.id}.execute-api.${var.aws_region}.amazonaws.com/production/rtcm"
}