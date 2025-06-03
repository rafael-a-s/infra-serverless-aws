const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, DeleteCommand } = require("@aws-sdk/lib-dynamodb");

// Criar cliente DynamoDB
const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

const deletePedido = async (event) => {
    const { id } = event.pathParameters;

    const command = new DeleteCommand({
        TableName: 'Pedidos',
        Key: { id }
    });

    try {
        await docClient.send(command);
        return { statusCode: 200, body: JSON.stringify({ message: 'Pedido deletado com sucesso' }) };
    } catch (error) {
        return { statusCode: 500, body: JSON.stringify({ error: error.message }) };
    }
};

module.exports = { deletePedido };