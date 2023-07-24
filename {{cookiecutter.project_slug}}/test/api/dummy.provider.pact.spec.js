const path = require('path');
const { versionFromGitTag } = require('@pact-foundation/absolute-version');
const { Verifier } = require('@pact-foundation/pact');
const server = require('../../app');

let baseUrl;
if (process.env.SMOKE_TEST) {
  baseUrl = process.env.APP_HOST;
} else {
  baseUrl = `http://localhost:${process.env.SERVER_PORT || 9080}`;
}

const providerOptions = {
  logLevel: 'INFO',
  providerBaseUrl: baseUrl,
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
    pactBrokerUrl: 'https://{{cookiecutter.pact_flow_username}}.pactflow.io/',
    /**
     * @TODO: update the code based on the error:
     * pactBrokerUrl requires one of the following properties: pactUrls,consumerVersionSelectors,consumerVersionTags
     */
    pactUrls: [
      path.resolve(
        __dirname,
        '../../pact/pacts/dummy_client-dummy_app.json',
      ),
    ],
    publishVerificationResult: true,
  });
} else {
  Object.assign(providerOptions, {
    pactUrls: [
      path.resolve(
        __dirname,
        '../../pact/pacts/dummy_client-dummy_app.json',
      ),
    ],
  });
}

describe('Test Dummy Provider', () => {
  afterAll(async () => {
    await server.close();
  });

  test('tests dummmy api routes', async () => {
    const output = await new Verifier(providerOptions).verifyProvider();
    console.log(output);
    expect(output).toContain('finished: 0');
  });
});
