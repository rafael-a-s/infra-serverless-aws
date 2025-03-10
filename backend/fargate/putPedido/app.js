const express = require('express');
const AWS = require('aws-sdk');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.json());

const dynamoDb = new AWS.DynamoDB.DocumentClient();

app.put('/pedido/:id', async (req, res) => {
    const { id } = req.params;
    const { nome, valor } = req.body;

    const params = {
        TableName: 'Pedidos',
        Key: { id },
        UpdateExpression: "set nome = :nome, valor = :valor",
        ExpressionAttributeValues: {
            ":nome": nome,
            ":valor": valor
        }
    };

    try {
        await dynamoDb.update(params).promise();
        res.status(200).json({ message: 'Pedido atualizado com sucesso' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.listen(3000, () => console.log('Servidor rodando na porta 3000'));

module.exports = app;
