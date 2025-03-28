const { getPedido } = require('./handler');

exports.handler = async (event) => {
    return await getPedido(event);
};