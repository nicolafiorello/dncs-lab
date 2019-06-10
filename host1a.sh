export DEBIAN_FRONTEND=noninteractive
sudo su
apt-get update
apt-get install -y curl --assume-yes
apt-get install -y tcpdump --assume-yes
ip link set dev eth1 up
ip add add 192.168.200.2/24 dev eth1
ip route add 192.168.128.0/17 via 192.168.200.1
