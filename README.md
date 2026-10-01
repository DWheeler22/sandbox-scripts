# Gateway Script

## Install
```
git clone https://github.com/DWheeler22/sandbox-scripts
cd sandbox-scripts
sudo cp ./gateway.sh /usr/bin/gateway
sudo chmod +x /usr/bin/gateway
```
Note: If there is ever a package called 'gateway' then putting this in `/usr/bin/` could create conflicts with apt/dpkg. Consider just running the script in place e.g. `sudo ./gateway.sh status`.

## Usage::

Turn on gateway (Kali should be configured to use both VMNet8 as NAT and VMNet5 as a virtual switch without a host adapter or VMWare DHCP):
```
sudo gateway on
```

Turn off gateway:
```
sudo gateway off
```

Check status:
```
sudo gateway status
```




