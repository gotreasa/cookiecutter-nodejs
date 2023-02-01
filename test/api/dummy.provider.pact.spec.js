const path = require('path');
const { versionFromGitTag } = require('@pact-foundation/absolute-version');
const { Verifier } = require('@pact-foundation/pact');
const server = require('../../app');

const providerOptions = {
  logLevel: 'INFO',
  providerBaseUrl: `http://localhost:${process.env.SERVER_PORT || 9080}`,
  provider: 'dummy_app',
  providerVersion: versionFromGitTag(),
  matchingRules: {
    body: {},
  },
  stateHandlers: {
    'Initial state': () => {
      return true;
    },
  },
};

if (process.env.CI || process.env.PACT_PUBLISH_RESULTS) {
  Object.assign(providerOptions, {
    pactBrokerUrl: 'https://gotreasa.pactflow.io/',
    publishVerificationResult: true,
  });
} else {
  Object.assign(providerOptions, {
    pactUrls: [
      path.resolve(__dirname, '../../pact/pacts/dummy_client-dummy_app.json'),
    ],
  });
}

describe('Test Dummy Provider', () => {
  afterAll(async () => {
    await server.close();
  });

  test('tests dummmy api routes', async () => {
    try {
      const output = await new Verifier(providerOptions).verifyProvider();
      console.log(output);
      expect(output).toContain('finished: 0');
    } catch (error) {
      console.log(error.message);
      // eslint-disable-next-line jest/no-conditional-expect
      expect(error).toBeNull();
    }
  });
});
