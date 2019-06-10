# DNCS-LAB Assignment A.Y. 2018-2019

## Table of contents
* [The project](#the-projecgt)
* [Network Map](#network-map)
* [The solution](#the-solution)  
  * [IP Subnetting](#ip-subnetting)  
  * [Ip address](#ip-address)
  * [VLAN](#vlan)
  * [Vagrant File](#vagrant-file)
* [Testing](#testing)  
* [Routing](#routing)  


# The project
This project is an Assignment given by Nicola Arnoldi for the course "Design of Networks and Communication Systems" @ UniTN.

The task given is the following:
"Based the Vagrantfile and the provisioning scripts available at: https://github.com/dustnic/dncs-lab the candidate is required to design a functioning network where any host configured and attached to router-1 (through switch) can browse a website hosted on host-2-c.  
The sub-netting needs to be designed to accommodate the following requirement:  
- Up to 130 hosts in the same subnet of host-1-a  
- Up to 25 hosts in the same subnet of host-1-b  
- Consume as few IP addresses as possible"

And should be done taking care about those requirements:
 - 10GB disk storage
 - 2GB free RAM
 - Virtualbox
 - Vagrant (https://www.vagrantup.com)
 - Internet

# Network Map

      +----------------------------------------------------------------+
      |                                              192.168.251.2/30  |
      |                              192.168.251.1/30   ^              |
      |                                        ^        |              |eth0
      +--+--+                   +------------+ |        |  +------------+
      |     |                   |            | |        |  |            |
      |     |               eth0|            |eth2     eth2|            |
      |     +-------------------+  router-1  +-------------+  router-2  |
      |     |                   |            |             |            |
      |     |                   |            |             |            |
      |  M  |                   +------------+             +------------+
      |  A  |                         |eth1                   eth1| 192.168.175.1/30
      |  N  |       192.168.200.1/24  |  eth1.11                  |
      |  A  |       192.168.150.1/27  |  eth1.12              eth1| 192.168.175.2/30
      |  G  |                         |                     +-----+----+
      |  E  |                         |eth1                 |          |
      |  M  |               +-------------------+           |          |
      |  E  |           eth0|    TRUNK PORT     |           | host-2-c |
      |  N  +---------------+      SWITCH       |           |          |
      |  T  |               | 11             12 |           |          |
      |     |               +-------------------+           +----------+
      |  V  |                  |eth2         |eth3                |eth0
      |  A  |                  |             |                    |
      |  G  |                  |             |                    |
      |  R  | 192.168.200.2/24 |eth1     eth1| 192.168.150.2/27   |
      |  A  |           +----------+     +----------+             |
      |  N  |           |          |     |          |             |
      |  T  |       eth0|          |     |          |             |
      |     +-----------+ host-1-a |     | host-1-b |             |
      |     |           |          |     |          |             |
      |     |           |          |     |          |             |
      ++-+--+           +----------+     +----------+             |
      | |                                 |eth0                   |
      | |                                 |                       |
      | +---------------------------------+                       |
      |                                                           |
      |                                                           |
      +-----------------------------------------------------------+

# The solution

## IP Subnetting
The network was splitted in 4 subnets:
-**A**: it contains host-1-a and eth.11, the router-1 port.  [Vlan based]
-**B**: it contains host-1-b and eth.12, the router-1 port.  [Vlan based]  
-**C**: it contains host-2-c and eth1, the router-2 port.  
-**D**: it contains eth2 port, the one shared by routers.

## Ip address
Only the needed addresses were allocated, in order to save as most IPs as possible.
This is my choice for the addresses:

| Network |    Ip/Network Mask    |
|:-------:|:---------------------:|
|   **A** |   192.168.200.0/24    |
|   **B** |   192.168.150.0/27    |
|   **C** |   192.168.175.0/30    |
|   **D** |   192.168.251.0/30    |

In order to be as close as possible to the requested ip numbers, I considered that dedicating *M* bits to the hosts in the addresses,
the available IPs are **((2^M)-2)** (two are required for broadcast and network).
8 bits were reserved in network A, 5 bits in network B and 2 in networks C and D, obtaining this result:

| Network | Available IPs |
|:-------:|:-------------:|
|   **A** |      254      |
|   **B** |      30       |
|   **C** |      2        |
|   **D** |      2        |  

## VLAN
The switch broadcast area of hosts 1a and  1b should be separated: VLAN can split the switch in two virtual switches and make it possible.
The network interface of **A** and **B** became this:

| IP            | ETH       | Device     |
|:-------------:|:---------:|:----------:|
| 192.168.249.1 | eth1.11   | `router-1` |
| 192.168.249.2 | eth1      | `host-1-a` |  
| 192.168.250.1 | eth1.12   | `router-1` |
| 192.168.250.2 | eth1      | `host-1-b` |

## Vagrant File
A Vagrant file conatining commands line in this format:
`[VirtualMachine].provision "shell", path: "[ItsFile.sh]"`
allowed me to auto-initialize all the virtual machines and their links via the script saved in [ItsFile.sh].

- host1a.sh

```
1 export DEBIAN_FRONTEND=noninteractive  
2 sudo su  
3 apt-get update  
4 apt-get install -y curl --assume-yes  
5 apt-get install -y tcpdump --assume-yes  
6 ip link set dev eth1 up  
7 ip add add 192.168.200.2/24 dev eth1  
8 ip route add 192.168.128.0/17 via 192.168.200.1  

```

- host1b.sh


```
1 export DEBIAN_FRONTEND=noninteractive
2 sudo su
3 apt-get update
4 apt-get install -y curl --assume-yes
5 apt-get install -y tcpdump --assume-yes
6 ip link set dev eth1 up
7 ip add add 192.168.150.2/27 dev eth1
8 ip route add 192.168.128.0/17 via 192.168.150.1

```

- host2c.sh

```
1 export DEBIAN_FRONTEND=noninteractive
2 sudo su
3 apt-get update
4 apt-get install -y apt-transport-https ca-certificates curl software-properties-common --assume-yes --force-yes
5 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
6 add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
7 apt-get update
8 apt-get install -y docker-ce --assume-yes --force-yes
9 ip link set dev eth1 up
10 ip add add 192.168.175.2/30 dev eth1
11 ip route add 192.168.128.0/17 via 192.168.175.1
12
13 docker rm $(docker ps -a -q)
14 docker run -dit --name SRwebserver -p 8080:80 -v /home/user/website/:/usr/local/apache2/htdocs/ httpd:2.4
15
16 echo "
<html>
<head>
    <meta charset="UTF-8">
    <title>
       A useless webpage
    </title>
</head>
<body>
<center>
   <div style="padding:10px; border:2px solid black;" onmouseover="this.style.display='none';">
      CLICK ME, IF YOU CAN :D
   </div>
</center>
</body>
</html>
"> /home/user/website/index.html

```

- switch.sh

```
1 export DEBIAN_FRONTEND=noninteractive
2 sudo su
3 apt-get update
4 apt-get install -y tcpdump --assume-yes
5 apt-get install -y openvswitch-common openvswitch-switch apt-transport-https ca-certificates curl software-properties-common
6 ovs-vsctl --if-exists del-br switch
7 ovs-vsctl add-br switch
8 ovs-vsctl add-port switch eth1
9 ovs-vsctl add-port switch eth2 tag=11
10 ovs-vsctl add-port switch eth3 tag=12
11 ip link set dev eth1 up
12 ip link set dev eth2 up
13 ip link set dev eth3 up
14 ip link set dev ovs-system up

```

- Router1.sh

```
1 export DEBIAN_FRONTEND=noninteractive
2 sudo su
3 apt-get update
4 apt-get install -y tcpdump apt-transport-https ca-certificates curl software-properties-common --assume-yes --force-yes
5 wget -O- https://apps3.cumulusnetworks.com/setup/cumulus-apps-deb.pubkey | apt-key add -
6 add-apt-repository "deb [arch=amd64] https://apps3.cumulusnetworks.com/repos/deb $(lsb_release -cs) roh-3"
7 apt-get update
8 apt-get install -y frr --assume-yes --force-yes
9 sysctl net.ipv4.ip_forward=1
10 ip link set dev eth1 up
11 ip link add link eth1 name eth1.11 type vlan id 11
12 ip link add link eth1 name eth1.12 type vlan id 12
13 ip link set dev eth1.11 up
14 ip link set dev eth1.12 up
15 ip link set dev eth2 up
16 ip add add 192.168.251.1/30 dev eth2
17 ip add add 192.168.200.1/24 dev eth1.11
18 ip add add 192.168.150.1/27 dev eth1.12
19 sed -i "s/\(zebra *= *\). */\1yes/" /etc/frr/daemons
20 sed -i "s/\(ospfd *= *\). */\1yes/" /etc/frr/daemons
21 service frr restart
22 vtysh -c 'conf t' -c 'router ospf' -c 'redistribute connected' -c 'exit' -c 'interface eth2' -c 'ip ospf area 0.0.0.0' -c 'exit' -c 'exit' -c 'write'

```
- Router2.sh

```
1 export DEBIAN_FRONTEND=noninteractive
2 sudo su
3 apt-get update
4 apt-get install -y tcpdump apt-transport-https ca-certificates curl software-properties-common --assume-yes --force-yes
5 wget -O- https://apps3.cumulusnetworks.com/setup/cumulus-apps-deb.pubkey | apt-key add -
6 add-apt-repository "deb [arch=amd64] https://apps3.cumulusnetworks.com/repos/deb $(lsb_release -cs) roh-3"
7 apt-get update
8 apt-get install -y frr --assume-yes --force-yes
9 sysctl net.ipv4.ip_forward=1
10 ip link set dev eth1 up
11 ip link set dev eth2 up
12 ip add add 192.168.251.2/30 dev eth2
13 ip add add 192.168.175.1/30 dev eth1
14 sed -i "s/\(zebra *= *\). */\1yes/" /etc/frr/daemons
15 sed -i "s/\(ospfd *= *\). */\1yes/" /etc/frr/daemons
16 service frr restart
17 vtysh -c 'conf t' -c 'router ospf' -c , while supporting multiple protocols and standards.1 and id 12'redistribute connected' -c 'exit' -c 'interface eth2' -c 'ip ospf area 0.0.0.0' -c 'exit' -c 'exit' -c 'write'

```

# Testing

After installing Virtualbox and Vagrant, the project can be tested following those commands:
```
git clone https://github.com/nicolafiorello/dncs-lab
cd dncs-lab
~/dncs-lab$ vagrant up --provision
 vagrant status
```
- You should get somethihng like this, that confirms that network components are running:
```
Current machine states:

router-1                  running (virtualbox)
router-2                  running (virtualbox)
switch                    running (virtualbox)
host-1-a                  running (virtualbox)
host-1-b                  running (virtualbox)
host-2-c                  running (virtualbox)
```

In order to log in a specific virtual machine, you can just run this command:
`vagrant ssh [machine]`
where [machine] is `router-1`, `router-2`, `host-1a` etc.
You should get an Ubuntu's welcome message.

 In order to get the web-page, this command can be runned from hosts 1a and 1b:
```
   curl 192.168.252.2:8080/index.html
```  

## Routing

The routing tables fot each VM are following:

IP routing table host 1a

| Destination     | Gateway         | Genmask         |
|:--------------:|:--------------:|:--------------:|
| 0.0.0.0         | 10.0.2.2        | 0.0.0.0         |
| 10.0.2.0        | 0.0.0.0         | 255.255.255.0   |
| 192.168.248.0   | 192.168.200.1   | 255.255.248.0   |
| 192.168.200.0   | 0.0.0.0         | 255.255.255.0   |

IP routing table host 1b

| Destination     |  Gateway        |  Genmask        |
|:--------------:|:--------------:|:--------------:|
| 0.0.0.0         | 10.0.2.2        | 0.0.0.0         |
| 10.0.2.0        | 0.0.0.0         | 255.255.255.0   |
| 192.168.248.0   | 192.168.150.1   | 255.255.248.0   |
| 192.168.150.0   | 0.0.0.0         | 255.255.255.224 |


IP routing table router 1

| Destination     | Gateway         | Genmask         |
|:--------------:|:--------------:|:--------------:|
| 0.0.0.0         | 10.0.2.2        | 0.0.0.0         |
| 10.0.2.0        | 0.0.0.0         | 255.255.255.0   |
| 192.168.200.0   | 0.0.0.0         | 255.255.255.0   |
| 192.168.150.0   | 0.0.0.0         | 255.255.255.224 |
| 192.168.251.0   | 0.0.0.0         | 255.255.255.175 |
| 192.168.175.0   | 192.168.175.2   | 255.255.255.175 |


IP routing table router 2

| Destination     | Gateway         | Genmask         |
|:--------------:|:--------------:|:--------------:|
| 0.0.0.0         | 10.0.2.2        | 0.0.0.0         |
| 10.0.2.0        | 0.0.0.0         | 255.255.255.0   |
| 192.168.248.0   | 192.168.251.2   | 255.255.248.0   |
| 192.168.200.0   | 192.168.251.1   | 255.255.255.0   |
| 192.168.150.0   | 192.168.251.1   | 255.255.255.224 |
| 192.168.251.0   | 0.0.0.0         | 255.255.255.175 |
| 192.168.175.0   | 0.0.0.0         | 255.255.255.175 |


IP routing table host 2c

| Destination     | Gateway         | Genmask         |
|:--------------:|:--------------:|:--------------:|
| 0.0.0.0         | 10.0.2.2        | 0.0.0.0         |
| 10.0.2.0        | 0.0.0.0         | 255.255.255.0   |
| 172.17.0.0      | 0.0.0.0         | 255.255.0.0     |
| 192.168.248.0   | 192.168.175.1   | 255.255.248.0   |
| 192.168.175.0   | 0.0.0.0         | 255.255.255.175 |
