#!/bin/bash -ex

public_address=$(ip route get 8.8.8.8 | awk '{ print $7; exit }')

if [ ! -z "$RESET" ]; then
  docker swarm leave --force || true
  sudo rm -rf ./volumes
  docker swarm init --advertise-addr=$public_address
  sleep 1
fi

ls secrets.env || cp example-secrets.env secrets.env
mkdir -p volumes/static || true
docker stack deploy --prune -c docker-compose.yml avizier
until docker exec $(docker ps -q --filter label=com.docker.swarm.service.name=avizier_web) python --version; do sleep 1; done
docker exec $(docker ps -q --filter label=com.docker.swarm.service.name=avizier_web) python ./manage.py collectstatic --noinput
docker exec $(docker ps -q --filter label=com.docker.swarm.service.name=avizier_web) python ./manage.py migrate --noinput
