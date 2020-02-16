#!/bin/bash
DIR=$PWD
# INSTALA DEPENDENCIA COUNTER PROCESSOR
counter="/tmp/v0.0.1.tar.gz"
link=https://github.com/CDLUC3/counter-processor/archive/v0.0.1.tar.gz
cd /tmp/
rm -rf counter-processor-0.0.1
rm -rf /usr/local/counter-processor
if [ -f "$counter" ]; then
    ls $counter
    if [ "$(md5sum $counter)" == "de4f375f0c68c404e8adc52092cb8334  /tmp/v0.0.1.tar.gz" ]; then
        tar xvfz v0.0.1.tar.gz
    fi
else
    rm $counter
    wget $link
    tar xvfz v0.0.1.tar.gz
fi
cp -R counter-processor-0.0.1 /usr/local/counter-processor
cd /usr/local/counter-processor
cp $PWD/GeoLite2-Country GeoLite2-Country.tar.gz
tar xvfz GeoLite2-Country.tar.gz
cp GeoLite2-Country_*/GeoLite2-Country.mmdb maxmind_geoip
# ADICIONA USUARIO COUNTER
useradd counter
chown -R counter:counter /usr/local/counter-processor
python3.6 -m ensurepip
cd /usr/local/counter-processor
pip3 install -r requirements.txt