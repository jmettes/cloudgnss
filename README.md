# cloudgnss

## Setup
Requires terraform 0.8.2 (includes binary media type support) or later.

In `variables.tf` you may want to change the `aws_region` and `aws_profile`.

## Running

<pre>
<b>$ make build
$ terraform apply</b>
<i>...
Apply complete! Resources: 10 added, 0 changed, 0 destroyed.

The state of your infrastructure has been saved to the path
below. This state is required to modify and destroy your
infrastructure, so keep it safe. To inspect the complete state
use the `terraform show` command.

State path: terraform.tfstate

Outputs:

endpoint = https://iczhquw2z7.execute-api.ap-southeast-2.amazonaws.com/production/rtcm</i>
</pre>

Using this endpoint URL, we can send it a binary RTCM encoded message:

<pre>
<b>$ curl -X POST -H "Content-Type: application/octet-stream" --data-binary "@1004_msg.bin" \
https://iczhquw2z7.execute-api.ap-southeast-2.amazonaws.com/production/rtcm</b>
<i>"RTCM3: type=1004 len=168"</i>
</pre>

## pyrtcm

This project includes [pyrtcm](https://github.com/jmettes/pyrtcm) (python wrappers the RTCM library) module. The module comes pre-built on an `ami-48d38c2b` AMI instance to ensure it can run on the same environment as AWS Lambda will run it with.