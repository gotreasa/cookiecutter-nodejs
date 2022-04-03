const express = require('express');
const helmet = require('helmet');
const cors = require('cors');

const app = express();
app.use(helmet());
app.use(cors());

app.get('/api/v1/dummy', (_, response) => response.status(200).json());

module.exports = app;
