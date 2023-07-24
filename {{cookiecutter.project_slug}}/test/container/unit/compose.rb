control 'compose.yml' do
  title 'Inspect docker compose file'

  describe file('compose.yml') do
    its('content') { should match (/version: '3.8'/) }
    its('content') { should match (/{{cookiecutter.project_slug}}-app:/) }
    its('content') { should match (/container_name: {{cookiecutter.project_slug}}/) }
    its('content') { should match (/context: \./) }
    its('content') { should match (%r{dockerfile: \./Dockerfile}) }
    its('content') do
      should match (%r{volumes:\n\s*- \.:/src\n\s*- goss:/goss})
    end
    its('content') { should match (/environment:\n\s*NODE_ENV: production/) }
    its('content') { should match (/ports:\n\s*- 9080:9080/) }
    its('content') do
      should match (
                     %r{healthcheck:\n\s*test: \['CMD', '/goss/goss', 'validate'\]}
                   )
    end
    its('content') { should match (/{{cookiecutter.project_slug}}-goss:/) }
    its('content') { should match (%r{image: aelsabbahy/goss}) }
    its('content') { should match (/container_name: goss/) }
    its('content') { should match (%r{volumes:\n\s*- goss:/goss}) }
    its('content') { should match (/volumes:\n\s*goss:/) }
  end
end
