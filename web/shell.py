#!/bin/bash -ex
docker exec -it $(docker ps -q --filter label=com.docker.swarm.service.name=avizier_web) bash
