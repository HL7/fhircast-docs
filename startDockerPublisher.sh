#!/bin/sh

docker build -t dbuild docker-builder/

docker run \
    --rm -it \
    -v $(pwd):/home/publisher/ig \
    dbuild
    # hl7fhir/ig-publisher-base
