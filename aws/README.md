# PayPal IPN Code Sample for Amazon Web Services (AWS) 

![Home Image](https://raw.githubusercontent.com/wiki/paypal/PayPal-PHP-SDK/images/homepage.jpg)


**This /aws/ subfolder contains sample code to deploy a working solution to receive and validate PayPal IPN messages into your AWS account, placing the validated messages onto an AWS queue (SQS) ready for further processing**.

## How to run this sample

* You will require an AWS account
* Open up AWS console and got to the Cloudformation service
* Create a new cloudformation template and paste in the content of paypal-ipn-cloudformation.yml
* Give the template a name and click through the pages to create it
* After creation get the webhook URL from cloudformation outputs and configure that url into your paypal sandbox as the IPN receiver URL.

** the above instructions assume a little familiarity with AWS and paypal sandbox!

## What gets created

There's an AWS API gateway configured to recieve IPN messages and pass them on to an AWS Lambda function.  This lambda recieves and logs the message and notifies a second Lambda with the content of the IPN message.  This second Lambda calls back to Paypal to verify the message and posts it to an SQS delivery queue if it's valid (else drops it).

To assist with automated order processing, if you fail to process the message three times it is moved to a dead-letter queue which has a long retention period so you can review why it failed processing.

There are no cloudwatch monitors/ exception triggers on the solution, but every message will be logged by the lambdas -> cloudwatch logs.  By default these cloudwatch logs are forever and there is a small storage cost so do prune them! 

## What does it cost to run

It's a serverless implementation, so no order messages; no cost. Eg I was testing with 4x synthetic messages a day and along with a bunch of other services the cost worked out around 9c / month.  You should test this yourself eg AWS Cost Explorer / daily.

## Will it scale up to handle more messages

It should scale up easily (no servers or routers to upgrade because it's serverless), but I have added parameters that initially limit incoming messages to 2 (burst) a second.  AWS default is 1000/second so no problem increasing these.

