# {{cookiecutter.project_name}}

[![Sonarcloud Status](https://sonarcloud.io/api/project_badges/measure?project={{cookiecutter.sonar_org}}_{{cookiecutter.project_slug}}&metric=alert_status)](https://sonarcloud.io/dashboard?id={{cookiecutter.sonar_org}}_{{cookiecutter.project_slug}})
[![Known Vulnerabilities](https://snyk.io/test/github/{{cookiecutter.github_org}}/{{cookiecutter.project_slug}}/badge.svg)](https://snyk.io/test/github/{{cookiecutter.github_org}}/{{cookiecutter.project_slug}})
[![Build Status](https://travis.ibm.com/{{cookiecutter.github_org}}/{{cookiecutter.project_slug}}.svg?token=qUvyKZdxoFqWxS8YbzZZ&branch=main)](https://travis.ibm.com/{{cookiecutter.github_org}}/{{cookiecutter.project_slug}})

API: [https://{{cookiecutter.project_slug}}-app.wdc1a.ciocloud.nonprod.intranet.ibm.com/api/v1/dummy]

## TODO

- ⚠⚠⚠⚠ Replace all occurences of `{{cookiecutter.project_slug}}` with your project name in all files ⚠⚠⚠⚠
- Setup environment variables in Travis:
  - `IBMCLOUD_APIKEY`
  - `APP_HOST` for smoke tests
