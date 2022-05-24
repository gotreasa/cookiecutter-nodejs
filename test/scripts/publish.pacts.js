const pact = require('@pact-foundation/pact-node');
const { versionFromGitTag } = require('@pact-foundation/absolute-version');
const path = require('path');

const options = {
  pactFilesOrDirs: [path.resolve(__dirname, '../../pact/pacts')],
  pactBroker: 'https://gotreasa.pactflow.io/',
  pactBrokerToken: process.env.PACT_BROKER_TOKEN,
  consumerVersion: versionFromGitTag(),
  tags: ['dev'],
};

pact
  .publishPacts(options)
  .then(() => {
    console.log('Pact contract publishing complete!');
  })
  .catch((error) => {
    console.log('Pact contract publishing failed: ', error);
  });
