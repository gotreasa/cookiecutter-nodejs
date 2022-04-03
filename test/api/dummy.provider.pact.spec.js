const path = require('path');
const { Verifier } = require('@pact-foundation/pact');
const provider = require('../../app');

describe('Test Dummy Provider', () => {
  afterAll(async () => {
    await provider.close();
  });

  test('tests dummmy api routes', async () => {
    try {
      const output = await new Verifier({
        providerBaseUrl: 'http://localhost:9080',
        pactUrls: [
          path.resolve(
            __dirname,
            '../../pact/pacts/dummy_client-dummy_app.json',
          ),
        ],
        matchingRules: {
          body: {},
        },
      }).verifyProvider();
      expect(output).toContain('0 failures');
    } catch (error) {
      console.log(error.message);
      // eslint-disable-next-line jest/no-conditional-expect
      expect(error).toBeNull();
    }
  });
});
