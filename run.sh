#!/bin/bash -ex

bridge_name=avizier-bridge
bridge_address=10.66.60.2
public_address=$(ip route get 8.8.8.8 | awk '{ print $7; exit }')

if ! ip link show $bridge_name; then
  sudo ip link add name $bridge_name type bridge
  sudo ip link set dev $bridge_name up
  sudo ip address add dev $bridge_name $bridge_address/24

  sudo iptables -t nat -A PREROUTING \
    -d $public_address -p tcp --dport 80 \
    -j DNAT --to-destination $bridge_address
  sudo iptables -t nat -A PREROUTING \
    -d $public_address -p tcp --dport 443 \
    -j DNAT --to-destination $bridge_address

  sudo iptables -t nat -A POSTROUTING -o $bridge_name -j MASQUERADE

  sudo bash -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'

  echo "Network set up successfully." > /dev/null

  docker swarm leave || true
  docker swarm init --advertise-addr=$bridge_address
  echo "Docker swarm set up successfully."
fi

docker stack deploy -c docker-compose.yml avizier
