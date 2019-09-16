# SHELL SCRIPT DATAVERSE 4.9.1

## Dataverse

O Dataverse é um aplicativo da Web de código-fonte aberto para compartilhar, preservar, citar, explorar e analisar dados de pesquisa. Desenvolvido em sua maior parte na linguagem Java, utiliza o servidor de aplicação Glassfish como serviço de back-end. Várias dependências são necessárias para a sua instalação funcionar corretamente, logo criamos um Shell Script que ajuda na instalação destas.

## Versão

Este Shell Script foi feito exclusivamente para o sistema CentOS 7, cujo o mesmo é a recomendação dos guias de instalação do Dataverse. A versão instalada é do Dataverse 4.9.1 (16/09/2019).

## Installation

Primeiro passo é clonar o repositório para sua máquina.

### Clone

``` bash
$ git clone https://github.com/ginfo-cflex/dataverse.git
```

Segundo passo é mudar as permições de execução do script e executa-lo

### Run shell script

``` bash
$ chmod 744 install.sh
$ ./install.sh
```