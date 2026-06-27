import boto3
import os

ec2 = boto3.client('ec2', region_name=os.environ.get('AWS_REGION', 'us-east-1'))

def find_instances_by_tag(tag_key, tag_value):
    response = ec2.describe_instances(
        Filters=[
            {
                'Name': f'tag:{tag_key}',
                'Values': [tag_value]
            }
        ]
    )

    instances = []
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            instances.append(instance['InstanceId'])

    return instances

def lambda_handler(event, context):
    instances = find_instances_by_tag('Name', 'wireguard-server')
    ec2.stop_instances(InstanceIds=instances)
    print(f'Stopped {len(instances)} instance(s)')
