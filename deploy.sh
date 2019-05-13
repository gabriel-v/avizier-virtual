#!/bin/bash -ex

bridge_name=avizier-bridge
bridge_address=10.66.60.2
public_address=$(ip route get 8.8.8.8 | awk '{ print $7; exit }')

if [ ! -z "$RESET" ]; then
  docker swarm leave --force || true
  sudo ip link del $bridge_name || true
  sudo iptables -t nat -D PREROUTING -d $public_address -p tcp --dport 80  -j DNAT --to-destination $bridge_address
  sleep 1
fi

if ! ip link show $bridge_name; then
  sudo ip link add name $bridge_name type bridge
  sudo ip link set dev $bridge_name up
  sudo ip address add dev $bridge_name $bridge_address/24

  #for port in 80; do
  #  sudo iptables -t nat -A PREROUTING -d $public_address -p tcp --dport 80  -j DNAT --to-destination $bridge_address
  #done
  #sudo iptables -t nat -A PREROUTING -d $public_address -p tcp --dport 443 -j DNAT --to-destination $bridge_address
  #sudo iptables -t nat -A POSTROUTING -o $bridge_name -j MASQUERADE
  #sudo bash -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'

  echo "Network set up successfully." > /dev/null

  docker swarm leave || true
  docker swarm init --advertise-addr=$bridge_address
  echo "Docker swarm set up successfully."
fi

docker stack deploy -c docker-compose.yml avizier
until docker exec $(docker ps -q --filter label=com.docker.swarm.service.name=avizier_web) python --version; do sleep 1; done
docker exec $(docker ps -q --filter label=com.docker.swarm.service.name=avizier_web) python ./manage.py migrate
