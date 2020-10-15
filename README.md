# Dataverse e Shibboleth para Autenticação Federada

Este script foi criado durante um [estudo](http://hdl.handle.net/20.500.11959/1204) de planejamento para implantação de uma Comunidade Produtora de Dados para o [Repositório Rede de Dados da Pesquisa](https://dadosabertos.rnp.br/) - [RDP Brasil](https://dadosdepesquisa.rnp.br/).

Com o objetivo de faciliar a instalação e configuração inicial de um ambiente de testes do Dataverse e suas dependências, GlassFish, Solr, PostgreSQL, Rserve, Apache e Shibboleth, entre outros ajustes no sistema possibilitando o login acadêmico da Federação CAFe Expresso.

[Documentação de Apoio](http://hdl.handle.net/20.500.11959/1264)

## Início rápido

Primeiro passo é clonar o repositório e atualizar os submodulos.

### Clone

```bash
$ git clone https://github.com/ginfo-cflex/dataverse-centos.git
$ cd dataverse-centos
$ git submodule init
$ git submodule update
```

Segundo passo é a execução do script como sudo ou root.

### Shell script

```bash
chmod +x install.sh
sudo /bin/bash install.sh
```

## O Dataverse

O Dataverse é um aplicativo da Web de código-fonte aberto para compartilhar, preservar, citar, explorar e analisar dados de pesquisa. Desenvolvido em sua maior parte na linguagem Java, utiliza o servidor de aplicação Glassfish como serviço de back-end.

## O Shibboleth

O Shibboleth é um projeto de código aberto que fornece recursos de Single Sign On e permite que os sites tomem decisões de autorização informadas para acesso individual a recursos online protegidos de maneira a preservar a privacidade.

## Versões

Atualmente, o script funciona apenas em CentOS 7 e implementa o Dataverse v4.20 e Shibboleth v3 com SAML2 com todos os serviços e dependências em execução na mesma máquina. Recomenda-se o uso de um servidor dedicado para execução do script pois ele realizará alterações de funcionamento do sistema.

## Problemas

O script não roda em máquinas virtualizadas no VirtualBox devido ao Glassfish criar JVM's para rodar o Dataverse.

## Componentes principais

- Payara server (Java EE application server)
  - Local padrão: _/user/local/payara5_
  - Arquivo padrão de configuração: _/usr/local/payara5/glassfish/domains/domain1/config/domain.xml_
  - `$ sudo systemctl {start|stop|restart|status} glassfish`
- Solr (indexing)
  - Arquivo padrão de configuração: _/usr/local/solr/example/solr/collection1/conf/schema.xml_
  - `$ sudo systemctl {start|stop|restart|status} solr`
- Rserve (tabular data)
  - Arquivo padrão de configuração: _/home/rserve/r_
  - `$ sudo systemctl {start|stop|restart|status} rserve`
- Postgres (database)
  - Local padrão de configuração: _/var/lib/pgsql/9.6/data/_
  - `$ sudo systemctl {start|stop|restart|status} postgresql-9.6`
- Apache (httpd)
  - Usado como proxy front-end para o Glassfish (e Shibboleth, se abilitado).
  - Local padrão de configuração: _/etc/httpd/conf.d_
  - `$ sudo systemctl {stop|start|restart|status} httpd`
- Shibboleth (shibd)
  - Fornece um provedor de autenticação federada.
  - Arquivo padrão de configuração: _/etc/shibboleth/shibboleth2.xml_
  - Serviço opcional, não configurado por padrão.
  - `$ sudo systemctl {start|stop|restart|status} shibd`

## Configurações extras

Especificações de [hardware](http://guides.dataverse.org/en/latest/installation/prep.html#hardware-requirements).

Instalação, customização, administração e informações adicionais sobre o Dataverse podem ser encontradas nos [Guias](http://guides.dataverse.org/en/latest/) do site.

[![Build Status](https://travis-ci.org/IQSS/dataverse.svg?branch=develop)](https://travis-ci.org/IQSS/dataverse)

<div flex="left">
  <a href="https://www.rnp.br/"><img src="https://www.rnp.br/sites/site-publico/themes/bootstrap_barrio/sitepublico/logo.png" alt="Rede Nacional de Ensino e Pesquisa" width="160" /></a>
  <a href="http://www.ufrgs.br/"><img src="http://www.ufrgs.br/ufrgs/logo.jpg" alt="Universidade Federal do Rio Grande do Sul" width="125" /></a>
  <a href="https://furg.br/"><img src="https://api.furg.br/account/assets/furg-logo.png" alt="Universidade Federal do Rio Grande" width="150" /></a>
  <a href="http://www.c3.furg.br"><img src="http://www.c3.furg.br/images/logo.png" alt="Centro de Ciências Computacionais" width="200" /></a>
  <a href="https://dataverse.org/"><img src="https://dataverse.org/files/dataverseorg/files/dataverse_r_project.png" alt="Dataverse Project" width="150" /></a>
</div>
