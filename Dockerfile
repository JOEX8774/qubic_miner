FROM ubuntu:latest
WORKDIR /app
RUN apt-get update && apt-get install -y wget \
    && apt install libicu-dev -y \
    && apt-get clean all
RUN wget https://raw.githubusercontent.com/JOEX8774/qubic_miner/main/installer.sh \
    && chmod u+x installer.sh
ENV qubic_version=1.8.6
ENV miner_name=qubic_miner_01
ENV threads=4
ENV qubic_token=accesstoken
CMD ["/bin/bash","-c","./installer.sh -v $qubic_version -m $miner_name -c $threads -t $qubic_token"]
