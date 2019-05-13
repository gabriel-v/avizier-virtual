#!/bin/bash -ex
docker build . -t gabrielv/avizier-virtual:local
docker push gabrielv/avizier-virtual:local
