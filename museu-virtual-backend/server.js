const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Permite que o teu telemóvel/Flutter aceda ao backend
app.use(cors());

// Permite que o servidor entenda dados em formato JSON
app.use(express.json());

// Rota de teste para sabermos se o servidor está vivo
app.get('/', (req, res) => {
    res.json({ mensagem: "Bem-vindo ao Backend do Museu Virtual de Carros!" });
});

// Liga o servidor na porta especificada
app.listen(PORT, () => {
    console.log(`🚀 Servidor a rodar com sucesso na porta ${PORT}`);
});