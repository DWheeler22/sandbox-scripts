# Gateway Script

## Install
```
git clone https://github.com/DWheeler22/sandbox-scripts
cd sandbox-scripts
sudo cp ./gateway.sh /usr/local/sbin/gateway
sudo chmod /usr/local/sbin/gateway
```

## Usage::

Turn on gateway (Kali should be configured to use both VMNet8 as NAT and VMNet5 as a virtual switch without a host adapter or VMWare DHCP):
```
gateway on
```

Turn off gateway:
```
gateway off
```

Check status:
```
gateway status
```




