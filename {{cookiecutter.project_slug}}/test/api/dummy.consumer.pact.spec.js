const { pactWith } = require('jest-pact');
const axios = require('axios');

const OK = 200;

pactWith(
  { consumer: 'dummy_client', provider: 'dummy_app' },
  (provider) => {
    describe('Dummy API', () => {
      let instance;

      beforeAll(() => {
        instance = axios.create({
          baseURL: provider.mockService.baseUrl,
        });
      });

      describe('Health Endpoint', () => {
        beforeEach(() => {
          return provider.addInteraction({
            state: 'health check',
            uponReceiving: 'a request the health endpoint',
            withRequest: {
              method: 'GET',
              path: '/health',
            },
            willRespondWith: {
              status: OK,
            },
          });
        });

        test('should return a response of OK for the health endpoint', async () => {
          const response = await instance.get('/health');
          expect(response.status).toBe(OK);
        });
      });

      describe('OpenAPI Endpoint', () => {
        beforeEach(() => {
          return provider.addInteraction({
            state: 'openapi endpoint',
            uponReceiving: 'a request the openapi endpoint',
            withRequest: {
              method: 'GET',
              path: '/api-docs/',
            },
            willRespondWith: {
              status: OK,
            },
          });
        });

        test('should return a response of OK for the OpenAPI endpoint', async () => {
          const response = await instance.get('/api-docs/');
          expect(response.status).toBe(OK);
        });
      });

      describe('App API', () => {
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
            },
          });
        });

        test('should return a response of OK', async () => {
          const response = await instance.get('/api/v1/dummy');
          expect(response.status).toBe(OK);
        });
      });
    });
  },
);
