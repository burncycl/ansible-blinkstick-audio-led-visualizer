### 2020/06 BuRnCycL

Ansible Automation to automatically provision Raspberry Pi as Blinkstick LED Visualizer devices.

### Pre-configuration 

Assuming a virgin Raspberry Pi running Raspios Buster Lite. Boot and run.

#### Raspi-Config (Enable SSH + Localisation options)

*SSH*

As pi user
```
sudo raspi-config
```
Interfacing Options -> SSH -> Enable "yes"

*Localisation options*

In my case, I'm in the United State. Raspberry Pi defaults to U.K. locale.

* Localisation options -> 
- Change Locale ->  en_US.UTF-8 UTF-8 -> en_US.UTF-8
- Change Time Zone -> US -> Region (e.g. Mountain) 
- Change Keyboard Layout -> Generic 101-key PC or Generic 104-key PC (with Windows key) -> Other -> English (US) -> English (US) _top choice_ -> The default for the keyboard layout -> No compose key
