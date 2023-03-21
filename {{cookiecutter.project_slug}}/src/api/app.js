const express = require('express');
const helmet = require('helmet');

const swaggerUi = require('swagger-ui-express');
const openApiSpecification = require('../../openapi.json');

const app = express();
app.use(helmet());

app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(openApiSpecification));
app.get('/api/v1/dummy', (_, response) => response.status(200).json());

module.exports = app;
