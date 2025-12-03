#! /bin/bash
# --------------------------
# Client Configuration File
# --------------------------

read -p "Enter your server machine IP address: " IpAddress

# The output file
Conf_file="client.conf"

# Certificate files
CA_FILE="$HOME/Desktop/openvpn-ca/pki/ca.crt"
CERT_FILE="$HOME/Desktop/openvpn-ca/pki/issued/client1.crt"
KEY_FILE="$HOME/Desktop/openvpn-ca/pki/private/client1.key"
TA_FILE="$HOME/Desktop/openvpn-ca/ta.key"

# Extract CA
CA_CERT=$(awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/' "$CA_FILE")

# Extract ONLY the certificate block from client.crt
CLIENT_CERT=$(awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/' "$CERT_FILE")

# Extract ONLY the key block
CLIENT_KEY=$(awk '/BEGIN PRIVATE KEY/,/END PRIVATE KEY/' "$KEY_FILE")

# Extract ONLY the key block
TA_KEY=$(awk '/BEGIN OpenVPN Static key V1/,/END OpenVPN Static key V1/' "$TA_FILE")

# create the client configuration file
cat <<EOF > "$Conf_file"
client
dev tun
proto udp
remote $IpAddress 1194
resolve-retry infinite
nobind
presist-key
presist-tun
remote-cert-tls server
auth SHA256
cipher AES-256-CBC
verb 3

<ca>
$CA_CERT
</ca>

<cert>
$CLIENT_CERT
</cert>

<key>
$CLIENT_KEY
</key>

<tls-auth>
$TA_KEY
</tls-auth>
key-direction 1
EOF

echo "Client configuration file is created in /etc/openvpn directory. You need to tranfer it to the client machine\
Then use this command to run it --> sudo openvpn --config client.conf"
