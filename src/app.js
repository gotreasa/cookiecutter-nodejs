const express = require('express');
const helmet = require('helmet');

const app = express();
app.use(helmet());

app.get('/api/v1/dummy', (_, response) => (response.status(200).json()));

const server = app.listen('9080', () => {
  console.log(`🚀 Template NodeJS app listening at http://localhost:${server.address().port}`);
});
