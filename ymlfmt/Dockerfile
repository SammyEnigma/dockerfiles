FROM python:3.9-alpine3.14

RUN set -eux; \
	apk add --no-cache --virtual .build-deps gcc libc-dev; \
# https://pypi.org/project/ruamel.yaml/
	pip install --no-cache-dir ruamel.yaml==0.16.5; \
	apk del .build-deps

COPY ymlfmt /usr/local/bin/
