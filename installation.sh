### https://free5gc.org/guide/3-install-free5gc/#a-prerequisites ###
### ubuntu 20.04


# remove go
sudo rm -rf /usr/local/go
dpkg -l | grep golang
sudo apt-get remove golang*
# install go 1.18
wget https://dl.google.com/go/go1.18.10.linux-amd64.tar.gz
sudo tar -C /usr/local -zxvf go1.18.10.linux-amd64.tar.gz
mkdir -p ~/go/{bin,pkg,src}
# The following assume that your shell is bash:
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
echo 'export PATH=$PATH:$GOPATH/bin:$GOROOT/bin' >> ~/.bashrc
echo 'export GO111MODULE=auto' >> ~/.bashrc
source ~/.bashrc
go version

# Install mongodb 4.4 for control-plane
sudo apt -y update
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod

# User-plane Supporting Packages
sudo apt -y update
sudo apt -y install git gcc g++ cmake autoconf libtool pkg-config libmnl-dev libyaml-dev

# Linux Host Network Settings
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o <dn_interface> -j MASQUERADE
sudo iptables -A FORWARD -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1400
sudo systemctl stop ufw
sudo systemctl disable ufw

# install control-plane
cd ~
git clone --recursive -b v3.3.0 -j `nproc` https://github.com/free5gc/free5gc.git
cd free5gc
make amf
make

# Install User Plane Function (UPF)
git clone -b v0.8.2 https://github.com/free5gc/gtp5g.git
cd gtp5g
make
sudo make install
cd ~/free5gc
make upf

# Install WebConsole
# Note: 2GB or more of OS memory is recommended. WebConsole may be failed to build if memory is less then 1GB.
sudo apt remove cmdtest yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt install -y nodejs yarn
cd ~/free5gc
make webconsole









