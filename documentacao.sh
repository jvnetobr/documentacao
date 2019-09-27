#!/bin/sh
#!/bin/bash

###############################################################################
#    Criado por José Vieira da Costa Neto                                     #
#    http://blog.vieira.net.br | contato@vieira.net.br                        #
# 									      #
#    Este programa é um software livre; você pode redistribuí-lo e/ou         #
#    modificá-lo dentro dos termos da Licença Pública Geral GNU como          #
#    publicada pela Fundação do Software Livre (FSF); na versão 3 da          #
#    Licença, ou (na sua opinião) qualquer versão.                            #
#									      #
#    Este programa é distribuído na esperança de que possa ser útil, 	      #
#    mas SEM NENHUMA GARANTIA; sem uma garantia implícita de ADEQUAÇÃO	      #
#    a qualquer MERCADO ou APLICAÇÃO EM PARTICULAR. Veja a		      #
#    Licença Pública Geral GNU para maiores detalhes.			      #
#									      #
#    Você deve ter recebido uma cópia da Licença Pública Geral GNU junto      #
#    com este programa. Se não, veja <http://www.gnu.org/licenses/>.          #
#                                                                             #
#                                                                             #
###############################################################################
#
# Versão 1.0 (26/02/2016)
# - Versão original
# 
# Versão 1.1 (27/02/2016)
# - Remoção de acentuação e caracteres especiais, para maior compatibilidade
# - Adicionado cabeçalho ao documento
# - Adicionadas mais saídas na tela
# 
# Versão 1.2 (29/02/2016
# - Alteração na opção do comando "free"
# - Alteração no uso do comando "nmap"
# - Adicionadas mais saídas na tela
# 
# Versão 1.3 (03/03/2016)
# - Alteração no tratamento de saída do comando "ifconfig" para maior compatibilidade
# - Alteração no tratamento de saída do comando "free" para maior compatibilidade
#
# Versão 1.4 (26/12/2016)
# - Adição de lista de pacotes do servidor;
#
USUARIO=`whoami`
if [ "$USUARIO" != "root" ];
  then
	echo "Este script precisa ser executado com permissao de superusuario!!!"
  exit 1
fi

clear
#Criação da documentação 
#echo "------------------------------------------------------------------------------"
#echo "                           SISTEMA DE DOCUMENTACAO"
#echo "------------------------------------------------------------------------------"
DOC="Documentacao - `uname -n`.txt"
touch `pwd`/"$DOC"
chmod 755 `pwd`/"$DOC"
echo "Criando documentacao..."

echo "DOCUMENTACAO DO SERVIDOR `uname -n` " > $DOC
#echo "Jose Vieira da Costa Neto" >> $DOC
echo "Ultima atualizacao em: `date`" >> $DOC
echo >> $DOC

echo "----------------------------" >> $DOC
echo "= INFORMACOES DE HARDWARE =" >> $DOC
echo "----------------------------" >> $DOC

echo "Hostname - `uname -n`" >> $DOC

echo "Digite a localizacao do servidor"
read LOCAL
echo "Local - $LOCAL" >> $DOC

NUM_CPU="`cat /proc/cpuinfo | grep ^"model name" | cut -d: -f2 | wc -l`"
MODEL_CPU="`cat /proc/cpuinfo | grep ^"model name" | cut -d: -f2 | sed '1!d'`"
echo "Processador - $NUM_CPU x$MODEL_CPU" >> $DOC

echo "Memoria - `free -m | grep ^Mem | cut -d: -f2 | sed 's/^[ \t]*//' | cut -d" " -f1` MB" >> $DOC

echo "Swap - `free -m | grep ^Swap | cut -d: -f2 | sed 's/^[ \t]*//' | cut -d" " -f1` MB" >> $DOC

RHEL="/etc/redhat-release"
if [ -e "$RHEL" ]
  then
	echo "Sistema Operacional - `cat $RHEL`" >> $DOC
  else
	echo "Sistema Operacional - `cat /etc/issue  | sed 's/.\{5\}$//'`" >> $DOC
fi

echo "Versao do kernel - `uname -r`" >>  $DOC

echo >> $DOC
echo "----------------------------" >> $DOC
echo "= INFORMACOES DE REDE =" >> $DOC

IFACES=`ifconfig | cut -d" " -f1 | sed '/^$/d' | sed '/lo/d'`
NUM_IFACES=`ifconfig | cut -d" " -f1 | sed '/^$/d' | sed '/lo/d' | wc -l`
for numero in $(seq $NUM_IFACES)
do
IFACE=`ifconfig | cut -d" " -f1 | sed '/^$/d' | sed '/lo/d'| sed -n -r $numero'p'`
	echo "----------------------------" >> $DOC
        echo "Dispositivo - $IFACE" >> $DOC
        echo "IPv4 - `ifconfig $IFACE | egrep "inet end|inet addr" | cut -d: -f2 | sed 's/^[ ]*//' | cut -d" " -f1`" >> $DOC
        echo "Mascara - `ifconfig $IFACE | egrep "Masc|Mask" | cut -d: -f4`" >> $DOC
        echo "MAC - `ifconfig $IFACE | grep HW | cut -d"W" -f2 | cut -d" " -f2`" >> $DOC
done

echo >> $DOC
echo "----------------------------" >> $DOC
echo "= INFORMACOES DE PARTICOES =" >> $DOC
echo "----------------------------" >> $DOC

df -hT >> $DOC

echo >> $DOC
echo "----------------------------" >> $DOC
echo "= SERVICOS NO SERVIDOR =" >> $DOC
echo "----------------------------" >> $DOC

echo "Adquirindo informacoes de servicos do servidor..."
echo "Aguarde..."

#nmap -sS -sU -sV 127.0.0.1 -p0-65535 | sed '/^$/d'| sed '1,4d' | sed '/done/d' >> $DOC
nmap -sS -sU -sV 127.0.0.1 | sed '/^$/d'| sed '1,4d' | sed '/done/d' >> $DOC
#netstat -tlunp | awk -F "/" '/\// && !/PID/{gsub(/ |:/, ""); print $2"," | "sort -u" }' 

echo >> $DOC
echo "----------------------------" >> $DOC
echo "= LISTA DE PACOTES DO SERVIDOR =" >> $DOC
echo "----------------------------" >> $DOC

echo "Listando pacotes instalados no servidor..."
echo "Aguarde..."

if [ -e "$RHEL" ]
  then
        rpm -qa >> $DOC
  else
        dpkg --get-selections | awk '{if ($2=="install") print $1}' >> $DOC
fi

echo
echo "Documentacao criada com sucesso!"
echo "Ela pode ser visualizada em `pwd`/$DOC"
echo
