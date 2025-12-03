#!/bin/bash
# ------------------------------
# OpenVPN Server + UFW Firewall
# ------------------------------

echo "[+] Updating system..."
sudo apt update -y

echo "[+] Installing OpenVPN and Easy-RSA..."
sudo apt install openvpn easy-rsa ufw -y

echo "[+] Setting up Easy-RSA PKI directory..."
make-cadir ~/Desktop/openvpn-ca
cd ~/Desktop/openvpn-ca

echo "[+] Building CA..."
./easyrsa init-pki
./easyrsa build-ca

echo "[+] Generating server certificate..."
./easyrsa gen-req server nopass
./easyrsa sign-req server server

echo "[+] Generating client certificate..."
./easyrsa gen-req client1 nopass
./easyrsa sign-req client clinet1 

echo "[+] Generating Diffie-Hellman..."
./easyrsa gen-dh

echo "[+] Copying certificates to OpenVPN directory..."
sudo cp pki/ca.crt pki/dh.pem pki/issued/server.crt pki/private/server.key ../ta.key /etc/openvpn/

echo "[+] creating server configuration file..."
echo "port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
auth SHA256
tls-auth ta.key 0
topology subnet
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
keepalive 10 120
cipher AES-256-CBC
persist-key
persist-tun
status openvpn-status.log
verb 3" >> /etc/openvpn/server.conf
echo "[+] server file created in /etc/openvpn directory"  

echo "[+] Configuring UFW firewall rules..."
sudo ufw allow 1194/udp
sudo ufw allow 22/tcp

# BLOCK SMB by default
sudo ufw deny 139/tcp
sudo ufw deny 445/tcp

# Allow SMB ONLY via VPN subnet
sudo ufw allow in on tun0 to any port 139
sudo ufw allow in on tun0 to any port 445
sudo ufw reload
sudo ufw enable

echo "[+] Server VPN + Firewall setup completed."
