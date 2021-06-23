import base64
import json
import boto3
import io
import csv

s3 = boto3.client('s3')


def lambda_handler(event, context):
    recordId = event['records'][0]['recordId']
    fileName = recordId + '.csv'
    bucket = 'clean-pp-as'
    payloadCleaned = getPayLoad(event)
    writeSingleCSV(payloadCleaned,fileName,bucket)
    return {'records': getOutPut(recordId,payloadCleaned)}

def getOutPut(recordId,payloadCleaned):
    output=[]
    body = io.StringIO()
    csv_writer = csv.writer(body)
    csv_writer.writerow(payloadCleaned.values())
    output_record = {
            'recordId': recordId,
            'result': 'Ok',
            'data': base64.b64encode(str.encode(body.getvalue()))
        }
    output.append(output_record)
    return output    
    
def writeSingleCSV(payloadCleaned,fileName,bucket):
    body = io.StringIO()
    csv_writer = csv.writer(body)
    header = payloadCleaned.keys()
    csv_writer.writerow(header)
    csv_writer.writerow(payloadCleaned.values())
    s3.put_object(Bucket = bucket, Key = fileName, Body = body.getvalue())
    
    
def getPayLoad(event):
    output=[]
    for record in event['records']:
        data = record['data']
        payload = base64.b64decode(data).decode('utf-8')[1:-1]
        payload = json.loads(payload)
        cleaned = {i:payload[i] for i in payload if i in ['id','name','abv','target_fg','target_og','ebc','srm','ph','ibu']}
    return cleaned
