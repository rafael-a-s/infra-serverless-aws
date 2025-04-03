const express = require('express');
const AWS = require('aws-sdk');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.json());

const dynamoDb = new AWS.DynamoDB.DocumentClient();

app.post('/pedido', async (req, res) => {
    const { id, nome, valor } = req.body;

    const params = {
        TableName: 'Pedidos',
        Item: { id, nome, valor }
    };

    try {
        await dynamoDb.put(params).promise();
        res.status(201).json({ message: 'Pedido criado com sucesso' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.listen(3000, () => console.log('Servidor rodando na porta 3000'));

module.exports = app;
