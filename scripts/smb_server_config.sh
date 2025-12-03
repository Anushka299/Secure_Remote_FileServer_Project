#!/bin/bash
# ------------------------------
# Samba File Server Configuration
# ------------------------------

echo "[+] Installing Samba..."
sudo apt update
sudo apt install samba -y

echo "[+] Creating directory for shared files..."
sudo mkdir /srv/samba/IT_dep
sudo mkdir /srv/samba/HR_dep
sudo mkdir /srv/samba/Finance_dep

echo "[+] Adding Samba user..."
groups=("IT_grp" "HR_grp" "Finance_grp")
for grp in "${groups[@]}"; do
  echo "[+] Creating user for $grp group..."
  read -p "Enter username for $grp: " smbuser
  
  # adding user to specific group
  sudo useradd -m "$smbuser" -G "$grp"
  
  # Add to Samba
  echo "Setting Samba password for $smbuser..."
  sudo smbpasswd -a "$smbuser"

  echo "User $smbuser created for $grp department"
  echo "----------------------------------------"
done

echo "[+] apply permissions..."
sudo chown -R :IT_grp /srv/samba/IT_dep
sudo chmod -R 770 /srv/samba/IT_dep
sudo chown -R :HR_grp /srv/samba/HR_dep
sudo chmod -R 770 /srv/samba/HR_dep
sudo chown -R :Finance_grp /srv/samba/Finance_dep
sudo chmod -R 770 /srv/samba/Finance_dep

echo "[+] All users created successfully!"

echo "[+] Backing up smb.conf..."
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
echo "[+] Backup smb.conf save as smb.conf.bak"

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
