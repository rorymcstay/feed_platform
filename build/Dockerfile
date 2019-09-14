FROM python:alpine

ARG CLI_VERSION=1.16.236

RUN apk -uv add --no-cache groff jq less && \
    pip install --no-cache-dir awscli==$CLI_VERSION

WORKDIR /aws

RUN /bin/bash "source   `file build.sh"

RUN
RUN source build.sh
RUN source build.sh

CMD sh