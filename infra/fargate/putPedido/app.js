const express = require('express');
const AWS = require('aws-sdk');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.json());

const dynamoDb = new AWS.DynamoDB.DocumentClient();

app.put('/pedido/:id', async (req, res) => {
    const { id } = req.params;
    const {
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
        data_entrega_prevista,
        observacoes
    } = req.body;

    const params = {
        TableName: 'Pedidos',
        Key: { id },
        UpdateExpression: `set 
            nome = :nome, 
            valor = :valor,
            usuario_id = :usuario_id,
            usuario_nome = :usuario_nome,
            usuario_email = :usuario_email,
            usuario_telefone = :usuario_telefone,
            usuario_cpf = :usuario_cpf,
            endereco_rua = :endereco_rua,
            endereco_numero = :endereco_numero,
            endereco_bairro = :endereco_bairro,
            endereco_cidade = :endereco_cidade,
            endereco_estado = :endereco_estado,
            endereco_cep = :endereco_cep,
            coordenadas_lat = :coordenadas_lat,
            coordenadas_lng = :coordenadas_lng,
            forma_pagamento = :forma_pagamento,
            status_pagamento = :status_pagamento,
            valor_desconto = :valor_desconto,
            valor_total = :valor_total,
            descricao = :descricao,
            categoria = :categoria,
            quantidade = :quantidade,
            status_pedido = :status_pedido,
            data_entrega_prevista = :data_entrega_prevista,
            observacoes = :observacoes,
            data_atualizacao = :data_atualizacao`,
        ExpressionAttributeValues: {
            ":nome": nome,
            ":valor": valor,
            // Dados do usuário
            ":usuario_id": usuario_id,
            ":usuario_nome": usuario_nome,
            ":usuario_email": usuario_email,
            ":usuario_telefone": usuario_telefone,
            ":usuario_cpf": usuario_cpf,
            // Localização
            ":endereco_rua": endereco_rua,
            ":endereco_numero": endereco_numero,
            ":endereco_bairro": endereco_bairro,
            ":endereco_cidade": endereco_cidade,
            ":endereco_estado": endereco_estado,
            ":endereco_cep": endereco_cep,
            ":coordenadas_lat": coordenadas_lat,
            ":coordenadas_lng": coordenadas_lng,
            // Pagamento
            ":forma_pagamento": forma_pagamento,
            ":status_pagamento": status_pagamento,
            ":valor_desconto": valor_desconto,
            ":valor_total": valor_total,
            // Dados do pedido
            ":descricao": descricao,
            ":categoria": categoria,
            ":quantidade": quantidade,
            ":status_pedido": status_pedido,
            ":data_entrega_prevista": data_entrega_prevista,
            ":observacoes": observacoes,
            ":data_atualizacao": new Date().toISOString()
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