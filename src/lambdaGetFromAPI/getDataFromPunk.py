import json
import requests
import boto3

def lambda_handler(event, context):
    kinesis = create_client('kinesis')
    stream_name = "stream_data_from_lambda"
    data = requests.get('https://api.punkapi.com/v2/beers/random')
    
    return send_kinesis(kinesis,stream_name,data.json())


def create_client(service):
    return boto3.client(service)    

def send_kinesis(kinesis_client,kinesis_stream_name,data):  
    encodedValues = json.dumps(data).encode("utf-8")
    response = kinesis_client.put_record(
                Data=encodedValues,
                StreamName = kinesis_stream_name,
                PartitionKey = str(1)
            )
    return response