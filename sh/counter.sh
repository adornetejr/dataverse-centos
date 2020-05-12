#!/bin/bash
DIR=$PWD
yum install -y python36
# INSTALA DEPENDENCIA COUNTER PROCESSOR
FILE="v0.0.1.tar.gz"
LOCATION="/tmp/$FILE"
LINK=https://github.com/CDLUC3/counter-processor/archive/v0.0.1.tar.gz
cd /tmp/
rm -rf counter-processor-0.0.1
rm -rf /usr/local/counter-processor
if [ -f "$LOCATION" ]; then
    ls $LOCATION
    if [ "$(md5sum $LOCATION)" == "25ffe6a101675ec51439db40172f2424  $LOCATION" ]; then
        tar xvfz $FILE -C /tmp
    else
        rm $LOCATION
        wget $LINK -P /tmp
        tar xvfz $FILE -C /tmp
    fi
else
    wget $LINK -P /tmp
    tar xvfz $FILE -C /tmp
fi
cp -R counter-processor-0.0.1 /usr/local/counter-processor
cd /usr/local/counter-processor
cp $DIR/bin/GeoLite2-Country GeoLite2-Country.tar.gz
tar xvfz GeoLite2-Country.tar.gz
cp GeoLite2-Country_*/GeoLite2-Country.mmdb maxmind_geoip
# ADICIONA USUARIO COUNTER
useradd counter
chown -R counter:counter /usr/local/counter-processor
sudo -S -u counter python3.6 -m ensurepip
cd /usr/local/counter-processor
sudo -S -u counter pip3 install -r requirements.txt
