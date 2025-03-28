const { deletePedido } = require('./handler');

exports.handler = async (event) => {
    return await deletePedido(event);
};