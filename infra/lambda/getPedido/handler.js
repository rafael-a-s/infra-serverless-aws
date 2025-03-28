const AWS = require('aws-sdk');
const dynamoDb = new AWS.DynamoDB.DocumentClient();

const getPedido = async (event) => {
    const { id } = event.pathParameters;
    
    const params = {
        TableName: 'Pedidos',
        Key: { id }
    };

    try {
        const data = await dynamoDb.get(params).promise();
        return {
            statusCode: 200,
            body: JSON.stringify(data.Item)
        };
    } catch (error) {
        return { statusCode: 500, body: JSON.stringify({ error: error.message }) };
    }
};

module.exports = { getPedido };