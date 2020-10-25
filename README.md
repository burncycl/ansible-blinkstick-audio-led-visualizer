### 2020/06 BuRnCycL

Ansible Automation to automatically provision Raspberry Pi as Blinkstick LED Visualizer devices.

Primary use case is to provision a single transmit node and numerous receive nodes quickly. Although can be used for a default install. The Application repo includes an install script.

### Raspberry Pi Pre-configuration 

Assuming a virgin Raspberry Pi running Raspios Buster Lite. Boot and run.

#### Raspi-Config (Enable SSH + Localisation options)

##### SSH

As pi user
```
sudo raspi-config
```
Interfacing Options -> SSH -> Enable "yes"

##### Localisation options

Be sure to set this up before configuring the Wifi.

In my case, I'm in the United State. Raspberry Pi defaults to U.K. locale. Obviously, tailor to your region locale.

* Localisation options -> 
- Change Locale ->  en_US.UTF-8 UTF-8 -> en_US.UTF-8
- Change Time Zone -> US -> Region (e.g. Mountain) 
- Change Keyboard Layout -> Generic 101-key PC or Generic 104-key PC (with Windows key) -> Other -> English (US) -> English (US) _top choice_ -> The default for the keyboard layout -> No compose key

##### WiFi (optional)
If you would desire wireless connectivity. Be sure to setup localisation options first (otherwise you may mistype password for wifi).

Network Options -> Wireless LAN -> US United State (or your country) -> SSID (2.4ghz only without dongle) -> Password

##### Install Raspberry Pi Prerequisites
```
sudo apt install -y python3 python3-pip ssh
```

On the machine you will be running Ansible from create an SSH Public/Private key pair if you haven't already.
```
cd ~/.ssh/
ssh-keygen -t rsa -b 4096
```
Do not create with password (unless you like typing the password every time).

Copy the public key
```
cat ~/.ssh/id_rsa.pub
```

Back on the Raspberry pi, add the public key to authorized_keys (as pi user)
```
mkdir ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 644 ~/.ssh/authorized_keys
```

Paste the public key you copied from the `cat` earlier command.
```
vi ~/.ssh/authorized_keys
```
### Networking 
Type the following to grab the ip address of the Raspberry Pi
```
ifconfig
```
Note the IP address down, as it will be used for Ansible inventory shortly.

### Ansible Prerequisites 

#### Create ansible-vault secret
Reference `secrets.yml.example`
```
cp secrets.yml.example secrets.yml
```
Modify the `ansible_sudo_pass` variable if using non-default password.
```
vi secrets.yml
```

Encrypt the file with a password. 

```
ansible-vault encrypt secrets.yml
```
Your other choice is to setup a password file and use that instead, which won't prompt.

Create a password file, so you won't be prompted every time you run Ansible automation.
```
sudo mkdir /secrets
touch /secrets/.vaultpw
chown -R youruser:youruser /secrets
chmod -R 600 /secrets
```
If you don't like this location, place it elsewhere. But, we be sure to update the Makefile VAULTPW variable with the new location (optional).
```
vi Makefile
```

### Install

Modify variables in `./group_vars/all.yml` to your liking. 

Modify `./inventory` to point to the targeted hosts you noted earlier.

Install blinkstick led visualizer script (could take a long time on a virgin install). Defaults to network mode.
```
make bsv 
```

Install blinkstick LED Control App (same deal, modify inventory prior, as bsvapp targets transmit nodes). Default to network mode.
```
make bsvapp
```

If you get error, you may need to re-run the automation. For some reason apt packages sometimes borks. If it still fails, on the node manually run
```
apt -y update
apt -y upgrade
apt -y dist-upgrade
apt -y autoremove
```
Includes startup script, which launches the application at boot (if told to do so - set in `./group_vars/all.yml`). Set,
```
install_as_startup_service: True
```

