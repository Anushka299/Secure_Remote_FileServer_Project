#!/bin/bash
# ------------------------------
# OpenVPN Server + UFW Firewall
# ------------------------------

echo "[+] Updating system..."
sudo apt update -y

echo "[+] Installing OpenVPN and Easy-RSA..."
sudo apt install openvpn easy-rsa ufw -y

echo "[+] Setting up Easy-RSA PKI directory..."
make-cadir ~/openvpn-ca
cd ~/openvpn-ca

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

echo "[+] Server VPN + Firewall setup completed.\
You need to create the server.conf file in /etc/openvpn directory"

