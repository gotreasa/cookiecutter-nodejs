# NodeJS Cookiecutter

This is a cookiecutter project that allows you to spin up a new NodeJS repository.  This will give you a working repository pushed to Github including the working Github actions, Sonar, Snyk, etc.  

To use the project run either:
```sh
cookiecutter cookiecutter-nodejs
```
or
```sh
cookiecutter https://github.com/gotreasa/cookiecutter-nodejs/
```

You will be prompted for the different values needed, however, there are some secrets that are not prompted.  To be able get those values you will need to set up:
`~/.cookiecutterrc`

In there you will need:

```properties
default_context:
    "_okteto_token": "REPLACE_ME"
    "_pact_broker_token": "REPLACE_ME"
    "_sonar_token": "REPLACE_ME"
    "_snyk_token": "REPLACE_ME"
```

You will need to replace the above values with your secrets.