#!/bin/bash
DIR=$PWD
systemctl stop glassfish
yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel jq ImageMagick
# DOWNLOAD DEPENDENCIA GLASSFISH SERVER
FILE="glassfish-4.1.zip"
LOCATION="/tmp/$FILE"
LINK=https://dlc-cdn.sun.com/glassfish/4.1/release/glassfish-4.1.zip
rm -rf /tmp/glassfish4
rm -rf /usr/local/glassfish4
if [ -f "$LOCATION" ]; then
    ls $LOCATION
    if [ "$(md5sum $LOCATION)" == "2fd41ad9af8d41d1c721c1b25191f674  $LOCATION" ]; then
        unzip /tmp/$FILE -d /tmp
    else
        rm $LOCATION
        wget $LINK -P /tmp
        unzip /tmp/$FILE -d /tmp
    fi
else
    wget $LINK -P /tmp
    unzip /tmp/$FILE -d /tmp
fi
# INSTALA DEPENDENCIA GLASSFISH SERVER EM /usr/local
mv /tmp/glassfish4 /usr/local/
# ATUALIZA MODULO WELD-OSGI
mv /usr/local/glassfish4/glassfish/modules/weld-osgi-bundle.jar /usr/local/glassfish4/glassfish/modules/weld-osgi-bundle.jar.1.bkp
curl -L -o /usr/local/glassfish4/glassfish/modules/weld-osgi-bundle.jar https://search.maven.org/remotecontent?filepath=org/jboss/weld/weld-osgi-bundle/2.2.10.Final/weld-osgi-bundle-2.2.10.Final-glassfish4.jar
# wget http://central.maven.org/maven2/org/jboss/weld/weld-osgi-bundle/2.2.10.SP1/weld-osgi-bundle-2.2.10.SP1-glassfish4.jar
# CONFIGURA GLASSFISH DE CLIENTE PARA SERVIDOR
mv /usr/local/glassfish4/glassfish/domains/domain1/config/domain.xml /usr/local/glassfish4/glassfish/domains/domain1/config/domain.xml.1.bkp
cp $DIR/xml/domain.xml /usr/local/glassfish4/glassfish/domains/domain1/config/domain.xml
# ATUALIZA CERTIFICADO SSL DO GLASSFISH
mv /usr/local/glassfish4/glassfish/domains/domain1/config/cacerts.jks /usr/local/glassfish4/glassfish/domains/domain1/config/cacerts.jks.1.bkp
cp -f /usr/lib/jvm/java-1.8.0-openjdk/jre/lib/security/cacerts /usr/local/glassfish4/glassfish/domains/domain1/config/cacerts.jks
# ALTERA PERMICOES PARA USUARIO glassfish
useradd glassfish
chown -R root:root /usr/local/glassfish4
# chown -R glassfish:glassfish /usr/local/glassfish4
chown glassfish /usr/local/glassfish4/glassfish/lib
chown -R glassfish:glassfish /usr/local/glassfish4/glassfish/domains/domain1
# ATIVA SERVICO GLASSFISH PARA INICIALIZAR COM SISTEMA
mv /usr/lib/systemd/system/glassfish.service /usr/lib/systemd/system/glassfish.service.bkp
cp $DIR/service/glassfish.service /usr/lib/systemd/system/glassfish.service
systemctl daemon-reload
echo "GLASSFISH_USER    glassfish" >>$DIR/default.config
echo "GLASSFISH_DIRECTORY	/usr/local/glassfish4" >>$DIR/default.config
echo "Starting glassfish!"
systemctl enable glassfish
systemctl start glassfish
# STATUS DO SERVICO GLASSFISH
systemctl status glassfish
