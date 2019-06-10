export DEBIAN_FRONTEND=noninteractive
sudo su
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common --assume-yes --force-yes
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce --assume-yes --force-yes
ip link set dev eth1 up
ip add add 192.168.175.2/30 dev eth1
ip route add 192.168.128.0/17 via 192.168.175.1

docker rm $(docker ps -a -q) #this command kills all containers if present, is useful if a user load the VM more than once.
docker run -dit --name SRwebserver -p 8080:80 -v /home/user/website/:/usr/local/apache2/htdocs/ httpd:2.4

echo "
<!DOCTYPE html>

</html>"
> /home/user/website/index.html
