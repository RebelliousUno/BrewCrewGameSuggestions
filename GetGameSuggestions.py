import json
import boto3

def get_game_suggestions(dynamodb=None):
    if not dynamodb:
        dynamodb = boto3.resource('dynamodb')
        table = dynamodb.Table('game_suggestions')
        response = table.scan()
        return response
    else:
        return nil

def getApiKey():
    client = boto3.client('ssm')
    param = client.get_parameter(Name='sergeApiToken')
    return param['Parameter']['Value']


def lambda_handler(event, context):
    # TODO implement
    
    api_key = getApiKey()
    
    key = event['queryStringParameters']['key']
    if not key or key != api_key:
        return {
            'statusCode': 403,
            'body': "Missing API Key"
            
        }
    
    games = get_game_suggestions()
    return {
        'statusCode': 200,
        'headers': {
            "Access-Control-Allow-Headers" : "Content-Type",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "OPTIONS,GET"
        },
        'body': json.dumps(games)
    }
