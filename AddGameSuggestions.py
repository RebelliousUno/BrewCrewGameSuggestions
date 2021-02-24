import json
import boto3



#Check if game exists
# If Game doesn't exist add it
# If Game does exist - Check if user has already suggested
# If not already suggested then add new suggestion
# Else Return Already suggested by you

def check_game_exist(game, dynamodb=None):
    if not dynamodb:
        dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('game_suggestions')
    try:
        response = table.get_item(Key={'gamename': game})
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        
        return 'Item' in response
                
def add_new_game(game, who, why, dynamodb=None):
    if not dynamodb:
        dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('game_suggestions')
    response = table.put_item(
        Item = {
            'gamename': game,
            'played': False,
            'suggested': [{
                'person': who,
                'reason': why
            }]
        })
    return response
    
def check_game_reason(game, who, dynamodb=None):
    if not dynamodb:
        dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('game_suggestions')
    try:
        response = table.get_item(Key={'gamename': game})
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        print(response['Item']['suggested'])
        return any(d['person'] == who for d in response['Item']['suggested'])
        

def add_new_reason(game, who, why, dynamodb=None):
    if not dynamodb:
        dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('game_suggestions')
    response = table.update_item(
        Key={
            'gamename': game
        },
        UpdateExpression="set suggested = list_append(suggested,:s)", 
        ExpressionAttributeValues={
            ':s': [{
                'person': who,
                'reason': why
            }]
        }
    )
    return response

def add_game_suggestion(game, who, why, dynamodb=None):
    if not dynamodb:
        dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('game_suggestions')
    if check_game_exist(game):
        if check_game_reason(game, who):
            return {'statusCode': 409, 'body': 'Already Exists'}
        else:
            add_new_reason(game, who, why)
            return {'statusCode': 201, 'body': 'Reason Added'}
    else: 
        add_new_game(game, who, why)
        return {'statusCode': 201, 'body': 'Game Added'}
        
    return {'statusCode' :500, 'body': "Something went wrong"}
    

def getApiKey():
    client = boto3.client('ssm')
    param = client.get_parameter(Name='sergeApiToken')
    return param['Parameter']['Value']

def lambda_handler(event, context):
    api_key = getApiKey()
    
    print(event)
    body = json.loads(event['body'])
    key = body['key']
    if not key or key != api_key:
        return {
            'statusCode': 403,
            'body': "Missing API Key"
            
        }
    game = body['game']
    who = body['who']
    why = body['why']
    
    res = add_game_suggestion(game, who, why)
    
    # TODO implement
    return res
