'use strict';
const express    = require('express');
const roteador   = express.Router();
const Controlador = require('../controller/media.controlador');
const { verificarToken, apenasAdmin }  = require('../middleware/autenticacao.middleware');
const { uploadUnico }                  = require('../middleware/upload.middleware');
const { registarActividade }           = require('../middleware/registo.middleware');

roteador.post('/enviar',         verificarToken, uploadUnico, registarActividade('UPLOAD', 'media_files'), Controlador.enviarFicheiro);
roteador.get('/peca/:idPeca',    verificarToken, Controlador.listarPorPeca);
roteador.get('/:id/transmitir',  verificarToken, registarActividade('STREAM_VOD', 'media_files'), Controlador.transmitir);
roteador.get('/:id/transferir',  verificarToken, registarActividade('DOWNLOAD',  'media_files'), Controlador.transferir);
roteador.delete('/:id',          verificarToken, apenasAdmin, registarActividade('ELIMINAR_MEDIA', 'media_files'), Controlador.eliminar);

module.exports = roteador;
