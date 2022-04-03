const app = require('./src/api/app');

const server = app.listen('9080', () => {
  console.log(
    `🚀 Template NodeJS app listening at http://localhost:${
      server.address().port
    }`,
  );
});

module.exports = server;
