#!/bin/bash
# ------------------------------
# Samba File Server Configuration
# ------------------------------

echo "[+] Installing Samba..."
sudo apt update
sudo apt install samba -y

echo "[+] Creating directory for shared files..."
sudo mkdir -p /srv/samba/shared
sudo chmod -R 777 /srv/samba/shared

echo "[+] Adding Samba user..."
departments=("IT_dep" "HR_dep" "Finance_dep")
for dept in "${departments[@]}"; do
  echo "[+] Creating user for $dept department..."
  read -p "Enter username for $dept: " smbuser
  
  # Create user with department-specific shell
  sudo useradd -m -s /bin/bash -c "$dept Department User" -G sambashare "$smbuser"
  
  # Set password for system account
  echo "Setting system password for $smbuser..."
  sudo passwd "$smbuser"
  
  # Add to Samba
  echo "Setting Samba password for $smbuser..."
  sudo smbpasswd -a "$smbuser"
  
  echo "User $smbuser created for $dept department"
  echo "----------------------------------------"
done

echo "All users created successfully!"

echo "[+] Backing up smb.conf..."
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

echo "[+] Writing new Samba share configuration..."
sudo bash -c 'cat <<EOF >> /etc/samba/smb.conf

[IT]
   path = /srv/samba/IT_dep
   read only = no
   valid users = @IT_grp

[HR]
   path = /srv/samba/HR_dep
   read only = no
   valid users = @HR_grp

[Finance]
   path = /srv/samba/Finance_dep
   read only = no
   valid users = @Finance_grp

EOF'

echo "[+] Restarting Samba..."
sudo systemctl restart smbd
sudo systemctl enable smbd

echo "[+] Samba share created successfully."

