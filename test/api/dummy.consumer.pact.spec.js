const { pactWith } = require('jest-pact');
const axios = require('axios');

const OK = 200;

pactWith({ consumer: 'dummy_client', provider: 'dummy_app' }, (provider) => {
  describe('dummmy API', () => {
    let instance;

    beforeAll(() => {
      instance = axios.create({
        baseURL: provider.mockService.baseUrl,
      });
    });

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
