#!/bin/bash
DIR=$PWD
# DOWNLOAD DEPENDENCIA GLASSFISH SERVER
cd /tmp/
rm -rf glassfish-4.1.zip
wget https://dlc-cdn.sun.com/glassfish/4.1/release/glassfish-4.1.zip
rm -rf glassfish-4.1
unzip glassfish-4.1.zip
# INSTALA DEPENDENCIA GLASSFISH SERVER EM /usr/local
rm -rf /usr/local/glassfish4
mv glassfish4 /usr/local/
# ADICIONA USUARIO 
cd /usr/local/glassfish4/glassfish/modules
# ATUALIZA MODULO WELD-OSGI
rm -f weld-osgi-bundle.jar
wget http://central.maven.org/maven2/org/jboss/weld/weld-osgi-bundle/2.2.10.SP1/weld-osgi-bundle-2.2.10.SP1-glassfish4.jar
# CONFIGURA GLASSFISH DE CLIENTE PARA SERVIDOR
cd /usr/local/glassfish4/glassfish/domains/domain1/config/
rm -f domain.xml
cp $DIR/domain.xml .
# ATUALIZA CERTIFICADO SSL DO GLASSFISH
rm -rf /usr/local/glassfish4/glassfish/domains/domain1/config/cacerts.jks
cp -f /usr/lib/jvm/java-1.8.0-openjdk/jre/lib/security/cacerts /usr/local/glassfish4/glassfish/domains/domain1/config/cacerts.jks
# ATIVA SERVICO GLASSFISH PARA INICIALIZAR COM SISTEMA
cd /usr/lib/systemd/system
rm -f glassfish.service
cp $DIR/glassfish.service .
systemctl daemon-reload
systemctl start glassfish.service
systemctl enable glassfish.service
# ALTERA PERMICOES PARA USUARIO glassfish
useradd glassfish
chown -R glassfish:glassfish /usr/local/glassfish4
# STATUS DO SERVICO GLASSFISH
systemctl status glassfish.service