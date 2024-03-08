# Qubicli Miner Installer
## Offical Url  
[qubic-client](https://github.com/qubic-li/clienthttps://github.com/qubic-li/client)  
[qubicli-miner-installer](https://github.com/Qubic-World/qubicli-miner-installer)  
## Ubuntu22 CPU
### Requirements
```bsah
apt-get update && apt-get install -y libicu-dev && apt-get clean all
```
### Run Script
```bash 
bash installer.sh -v 1.8.6 -m miner_Alias -c threads -a -t token
```
### update version
```bash 
bash installer.sh -v 1.8.7 -m miner_Alias -c threads -a -t token
```

## Ubuntu22 GPU
appsetting.json add config
```bash
"allowHwInfoCollect": true, "overwrites": {"CUDA": "12"}"overwrites": {"CUDA": "12"}
```
