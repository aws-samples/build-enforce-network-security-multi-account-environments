import json
import boto3
import os
from botocore.exceptions import ClientError

cloudwan_client = boto3.client('networkmanager')
cn_id = os.environ['CORE_NETWORK_ID']

def lambda_handler(event, context):
              
    print("Received event:", event)
              
    if 'InputTemplate' in event and isinstance(event['InputTemplate'], str):
        try:
            event_data = json.loads(event['InputTemplate'])
        except json.JSONDecodeError as e:
            print(f"Error decoding nested JSON: {str(e)}")
            return {
                'statusCode': 400,
                'body': 'Invalid nested JSON input'
            }
    else:
        event_data = event
                  
    finding_type = event_data.get('Finding_Type', 'No Data received')
    finding_description = event_data.get('Finding_description', 'No Data received')
    instance_id = event_data.get('instanceId', 'No Data received')
    region = event_data.get('region', 'No Data received')
    severity = float(event_data.get('severity', 'No Data received'))
    vpc_id = event_data.get('vpcId', 'No Data received')
    account_id = context.invoked_function_arn.split(":")[4]

    try:
        response = cloudwan_client.list_attachments(
            CoreNetworkId=cn_id,
            EdgeLocation=region
        )
        print("CloudWan Response:", json.dumps(response, default=str))

        AttachId = None

        for attachment in response.get('Attachments', []):
            if vpc_id in attachment.get('ResourceArn', ''):
                AttachId = attachment['AttachmentId']
                break

        if AttachId:
            resource_arn = f"arn:aws:networkmanager::{account_id}:attachment/{AttachId}"
            print(f"Constructed ResourceArn: {resource_arn}")

            # Determine tags based on severity
            if severity <= 3.9:
                tags = [{'Key': 'domain', 'Value': 'inspected'}]
            elif severity <= 6.9:
                tags = [{'Key': 'domain', 'Value': 'onlyshared'}]
            elif severity <= 8.9:
                tags = [{'Key': 'domain', 'Value': 'blocked'}]

            tag_response = cloudwan_client.tag_resource(
                ResourceArn=resource_arn,
                Tags=tags
            )
                      
            print("Tagging has been placed correctly on:", resource_arn)
            print("Tags:", tags)
                      
        else:
            print("No matching AttachmentId found for the provided vpc_id")
            tag_response = {}

    except ClientError as e:
        print(f"An error occurred: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': e.response['Error']['Message']})
        }

    return {
        'statusCode': 200,
        'body': json.dumps({
            'Finding Type': finding_type,
            'Finding Description': finding_description,
            'Instance ID': instance_id,
            'Region': region,
            'Severity': severity,
            'VPC ID': vpc_id,
            'Matching AttachmentId': AttachId if AttachId else "Not Found",
            'Tagging Response': tag_response
        }, default=str)
    }