const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand, ScanCommand } = require("@aws-sdk/lib-dynamodb");

// Criar cliente DynamoDB
const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

const getPedido = async (event) => {
    try {
        // Verificar se há ID nos pathParameters
        const id = event.pathParameters?.id;

        if (id && id !== 'all') {
            // Buscar pedido específico por ID
            const command = new GetCommand({
                TableName: 'Pedidos',
                Key: { id }
            });

            const data = await docClient.send(command);

            if (!data.Item) {
                return {
                    statusCode: 404,
                    body: JSON.stringify({ message: 'Pedido não encontrado' })
                };
            }

            return {
                statusCode: 200,
                body: JSON.stringify(data.Item)
            };
        } else {
            // Listar todos os pedidos (sem ID ou com ID = "all")
            const command = new ScanCommand({
                TableName: 'Pedidos'
            });

            const data = await docClient.send(command);

            return {
                statusCode: 200,
                body: JSON.stringify(data.Items || [])
            };
        }
    } catch (error) {
        console.error('Erro ao buscar pedidos:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({
                error: 'Erro interno do servidor',
                message: error.message
            })
        };
    }
};

module.exports = { getPedido };