const { pactWith } = require('jest-pact');
const axios = require('axios');

const port = 9999;
const instance = axios.create({
  baseURL: `http://localhost:9999`,
});

const OK = 200;

pactWith(
  { port, consumer: 'dummy_client', provider: 'dummy_app' },
  (provider) => {
    describe('dummmy API', () => {
      beforeEach(() => {
        return provider.addInteraction({
          state: 'Initial state',
          uponReceiving: 'a request for the dummy API',
          withRequest: {
            method: 'GET',
            path: '/api/v1/dummy',
          },
          willRespondWith: {
            status: OK,
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
            },
            body: {},
          },
        });
      });

      test('should return a response of OK', async () => {
        const response = await instance.get('/api/v1/dummy');
        expect(response.status).toBe(OK);
      });
    });
  },
);
