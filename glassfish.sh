#!/bin/bash
DIR=$PWD
systemctl stop glassfish
# DOWNLOAD DEPENDENCIA GLASSFISH SERVER
glassfish="/tmp/glassfish-4.1.zip"
link=https://dlc-cdn.sun.com/glassfish/4.1/release/glassfish-4.1.zip
cd /tmp/
if [ -f "$glassfish" ]
then
    ls $glassfish
    md5sum $glassfish
else
    wget $link
fi
rm -rf glassfish-4.1
unzip glassfish-4.1.zip
# INSTALA DEPENDENCIA GLASSFISH SERVER EM /usr/local
rm -rf /usr/local/glassfish4
mv glassfish4 /usr/local/
# ADICIONA USUARIO 
cd /usr/local/glassfish4/glassfish/modules
# ATUALIZA MODULO WELD-OSGI
rm -f weld-osgi-bundle.jar
curl -L -O https://search.maven.org/remotecontent?filepath=org/jboss/weld/weld-osgi-bundle/2.2.10.Final/weld-osgi-bundle-2.2.10.Final-glassfish4.jar
# wget http://central.maven.org/maven2/org/jboss/weld/weld-osgi-bundle/2.2.10.SP1/weld-osgi-bundle-2.2.10.SP1-glassfish4.jar
# CONFIGURA GLASSFISH DE CLIENTE PARA SERVIDOR
cd /usr/local/glassfish4/glassfish/domains/domain1/config/
rm -f domain.xml
cp $DIR/domain.xml .
# ATUALIZA CERTIFICADO SSL DO GLASSFISH
rm -rf /usr/local/glassfish4/glassfish/domains/domain1/config/cacerts.jks
cp -f /usr/lib/jvm/java-1.8.0-openjdk/jre/lib/security/cacerts /usr/local/glassfish4/glassfish/domains/domain1/config/cacerts.jks
# ALTERA PERMICOES PARA USUARIO glassfish
useradd glassfish
chown -R root:root /usr/local/glassfish4
chown glassfish /usr/local/glassfish4/glassfish/lib
chown -R glassfish:glassfish /usr/local/glassfish4/glassfish/domains/domain1
# chown -R glassfish:glassfish /usr/local/glassfish4
# ATIVA SERVICO GLASSFISH PARA INICIALIZAR COM SISTEMA
rm -f /usr/lib/systemd/system/glassfish.service
cp $DIR/glassfish.service /usr/lib/systemd/system/
systemctl daemon-reload
echo "Starting glassfish!"
systemctl start glassfish
systemctl enable glassfish
# STATUS DO SERVICO GLASSFISH
systemctl status glassfish
echo "GLASSFISH_DIRECTORY	/usr/local/glassfish4" >> default.config
echo "GLASSFISH_USER	glassfish" >> default.config
