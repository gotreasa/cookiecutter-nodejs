#!/bin/bash

if [ -z $IS_COOKIECUTTER ]; then
    npm run detect-secrets $@
else
    echo 'skipping detecting secrets'
    exit 0
fi