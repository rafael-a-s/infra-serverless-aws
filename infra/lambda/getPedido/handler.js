const AWS = require('aws-sdk');
const dynamoDb = new AWS.DynamoDB.DocumentClient();

const getPedido = async (event) => {
    const { id } = event.pathParameters;
    
    const params = {
        TableName: 'Pedidos',
        Key: { id }
    };

    try {const AWS = require('aws-sdk');
        const dynamoDb = new AWS.DynamoDB.DocumentClient();

        const getPedido = async (event) => {
            // Verificar se há ID nos pathParameters
            const id = event.pathParameters?.id;

            if (id) {
                // Buscar pedido específico por ID
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
            } else {
                // Listar todos os pedidos
                const params = {
                    TableName: 'Pedidos'
                };

                try {
                    const data = await dynamoDb.scan(params).promise();
                    return {
                        statusCode: 200,
                        body: JSON.stringify(data.Items)
                    };
                } catch (error) {
                    return { statusCode: 500, body: JSON.stringify({ error: error.message }) };
                }
            }
        };

        module.exports = { getPedido };
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