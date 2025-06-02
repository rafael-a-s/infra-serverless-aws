const express = require('express');
const AWS = require('aws-sdk');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.json());

const dynamoDb = new AWS.DynamoDB.DocumentClient();

app.post('/pedido', async (req, res) => {
    const {
        id,
        nome,
        valor,
        // Dados do usuário
        usuario_id,
        usuario_nome,
        usuario_email,
        usuario_telefone,
        usuario_cpf,
        // Localização
        endereco_rua,
        endereco_numero,
        endereco_bairro,
        endereco_cidade,
        endereco_estado,
        endereco_cep,
        coordenadas_lat,
        coordenadas_lng,
        // Pagamento
        forma_pagamento,
        status_pagamento,
        valor_desconto,
        valor_total,
        // Dados do pedido
        descricao,
        categoria,
        quantidade,
        status_pedido,
        data_criacao,
        data_entrega_prevista,
        observacoes
    } = req.body;

    const params = {
        TableName: 'Pedidos',
        Item: {
            id,
            nome,
            valor,
            // Dados do usuário
            usuario_id,
            usuario_nome,
            usuario_email,
            usuario_telefone,
            usuario_cpf,
            // Localização
            endereco_rua,
            endereco_numero,
            endereco_bairro,
            endereco_cidade,
            endereco_estado,
            endereco_cep,
            coordenadas_lat,
            coordenadas_lng,
            // Pagamento
            forma_pagamento,
            status_pagamento,
            valor_desconto,
            valor_total,
            // Dados do pedido
            descricao,
            categoria,
            quantidade,
            status_pedido,
            data_criacao: data_criacao || new Date().toISOString(),
            data_entrega_prevista,
            observacoes
        }
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