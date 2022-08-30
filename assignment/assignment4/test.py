
ec2client = boto3.client('ec2', region_name=regionname)
instanceresponse = ec2client.describe_instances()
for reservation in instanceresponse["Reservations"]:
        for instance in reservation["Instances"]:
            print(instance["InstanceId"])