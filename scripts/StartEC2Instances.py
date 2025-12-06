import boto3
ec2 = boto3.client('ec2', region_name='us-east-1')

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

instances = find_instances_by_tag('Name', 'wireguard-server')

def lambda_handler(event, context):
    ec2.start_instances(InstanceIds=instances)
    print('stopped your instances: ' + str(instances))