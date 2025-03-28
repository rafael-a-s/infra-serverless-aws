const AWS = require('aws-sdk');
const dynamoDb = new AWS.DynamoDB.DocumentClient();

const deletePedido = async (event) => {
    const { id } = event.pathParameters;

    const params = {
        TableName: 'Pedidos',
        Key: { id }
    };

    try {
        await dynamoDb.delete(params).promise();
        return { statusCode: 200, body: JSON.stringify({ message: 'Pedido deletado com sucesso' }) };
    } catch (error) {
        return { statusCode: 500, body: JSON.stringify({ error: error.message }) };
    }
};

module.exports = { deletePedido };