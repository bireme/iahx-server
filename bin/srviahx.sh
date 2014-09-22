#!/bin/bash

# -------------------------------------------------------------------------- #
# srviahx.sh - Controla operacao (START/STOP) dos servidores iahx
# -------------------------------------------------------------------------- #
#     Entrada:	PARM1 com o identificador do servidor a operar [1..3]
#		PARM2 com a operacao START ou STOP
#		PARM3 se presente deve valor -force (mudando o tempo no STOP)
#               Opcoes de execucao:
#		 -h, --help             Exibe texto de ajuda
#		 -V, --version          Exibe a versao corrente
#		 -d, --debug  NIVEL     Define nivel de depuracao
#		 --changelog            Exibe o historico de alteracoes
#		 --config ARQU_CONF     Arquivo de configuracao dos servidores
#		        (Default: /home/javaapps/iahx-server/bin/srviahx.conf)
#		 -m, --MEMO QTDE        Qtd de memoria a alocar em megabytes
#		        (Default: 4 Gbytes, ou 4096)
#	Saida:	Servidor apontado ligado ou desligado
#    Corrente:	indiferente
#     Chamada:	$PATH_IAHX/srviahx.sh <SERVER_No> <start|stop> [-force]
#     Exemplo:	srviahx.sh 1 stop -force
# Objetivo(s):	Ligar e desligar o iahx-server
# Comentarios:	-
# Observacoes:  DEBUG eh uma variavel mapeada por bit conforme
		_BIT0_=1;	# Aguarda tecla <ENTER>
		_BIT1_=2;	# Mostra mensagens de DEBUG
		_BIT2_=4;	# Modo verboso
		_BIT3_=8;	# Modo debug de linha -v
		_BIT4_=16;	# Modo debug de linha -x
		_BIT5_=32;	# .
		_BIT6_=64;	# .
		_BIT7_=128;	# Opera em modo FAKE
#        Notas: Deve ser executado como usuario 'tomcat'
# Dependencias: Variaveis de ambiente que devem estar previamente ajustadas:
#		  TRANSFER	username para troca de dados entre servidores
#		 PATH_IAHX	caminho para os executaveis do pcte
#		 PATH_PROC	caminho para a area de processamento
#		PATH_INPUT	caminho para os dados de entrada
#		INDEX_ROOT	Raiz dos indices de busca
#		    SRVPRD	hostname do servidor de producao
#		    SRVHOM	hostname do servidor de homologacao
#		    SRVTST	hostname do servidor de teste
# -------------------------------------------------------------------------- #
#  Centro Latino-Americano e do Caribe de Informação em Ciências da Saúde
#     é um centro especialidado da Organização Pan-Americana da Saúde,
#           escritório regional da Organização Mundial da Saúde
#                       BIREME / OPS / OMS (P)2012-14
# -------------------------------------------------------------------------- #
# Historico
# versao data, Responsavel
#       - Descricao

cat > /dev/null <<HISTORICO
vrs:  0.00 20100000, VAAntonio
        - Edicao original
vrs:  0.01 20130122, FJLopes
        - Inclusao de controles de execucao
vrs:  0.02 20130219, FJLopes
	- Tempos de guarda reajustados para start e stop
vrs:  0.03 20130613, FJLopes
	- Tempos de guarda personalizados por servidor operado
vrs:  0.04 20140225, FJLopes
	- Preparo para formacao de pacote de distribuicao
HISTORICO

# ========================================================================== #
#                                  Funcoes                                   #
# ========================================================================== #
# isNumber - Determina se o parametro eh numerico
# PARM $1  - String a verificar se eh numerica ou nao
# Obs.    `-eq` soh opera bem com numeros portanto se nao for numero da erro
#
isNumber() {
	[ "$1" -eq "$1" ] 2> /dev/null
	return $?
}

# ========================================================================== #
# PegaValor - Obtem valor de uma clausula
# PARM $1 - Item de configuracao a ser lido
# Obs: O arquivo a ser lido eh o contido na variavel CONFIG
#
PegaValor () {
	if [ -f "$CONFIG" ]; then
		grep "^$1" $CONFIG > /dev/null
		RETORNO=$?
		if [ $RETORNO -eq 0 ]; then
			RETORNO=$(grep "^$1" $CONFIG | tail -n "1" | cut -d "=" -f "2" | tr "#" "=")
			echo $RETORNO
		else
			false
		fi
	else
		false
	fi
	return
}
#
# ========================================================================== #

source	$PATH_EXEC/inc/infi_exec.inc

# -------------------------------------------------------------------------- #
# Texto de ajuda de utilizacao do comando

#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
AJUDA_USO="
Uso: $TREXE [OPCOES] <PARM1> <PARM2> [PARM3]

OPCOES:
 --changelog            Exibe o historico de alteracoes
 --config ARQU_CONF     Arquivo de configuracao dos servidores
                        (Default: /home/javaapps/iahx-server/bin/srviahx.conf)
 -d, --debug  NIVEL     Define nivel de depuracao com valor numerico positivo
 -h, --help             Exibe este texto de ajuda e para a execucao
 -m, --MEMO QTDE        Qtd de memoria a alocar em megabytes p.ex. 6144
 -V, --version          Exibe a versao corrente do comando e para a execucao
                        (Default: 4 Gbytes, ou 4096)

PARAMETROS:
 PARM1   Numero da instancia de servidor a controlar entre $MINSRV e $MAXSRV
 PARM2   Operacao a realizar start | stop
 PARM3   -force acrescenta um kill apos o stop
"

# Valores DEFAULT (Valores conservadores)
CONFIG="/home/javaapps/iahx-server/bin/srviahx.conf"
HEAP_0="8192"
MEMO=$HEAP_0
PERM_0=""
PERM=$PERM_0
TIME_0="241"
TIME=$TIME_0

# Numero de servidor esta entre uma faixa delimitada aqui
MINSRV=1
MAXSRV=3

# -------------------------------------------------------------------------- #
# Tratamento das opcoes de linha de comando (qdo houver alguma)
while test -n "$1"
do
        case "$1" in

                -h | --help)
                        echo "$AJUDA_USO"
                        exit
                ;;

                -V | --version)
                        echo -e -n "\n$TREXE "
                        grep '^vrs: ' $PRGDR/$TREXE | tail -1
                        echo
                        exit
                ;;

                -d | --debug)
                        shift
                        isNumber $1
                        [ $? -ne 0 ] && echo -e "\n$TREXE: O argumento da opcao DEBUG deve existir e ser numerico.\n$AJUDA_USO" && exit 2
                        DEBUG=$1
                ;;

		--config)
			shift
			CONFIG="$1"
			if [ ! -s "$CONFIG" ]; then
				echo "Arquivo de configuracao $CONFIG nao localizado ou vazio"
				exit 1
			fi
		;;

		-force)
			PARM3=$1
		;;

		-m | --MEMO)
			shift
			PARM4=$1
			isNumber $1
			[ $? -ne 0 ] && echo "Valor não numérico assumindo o DEFAULT de 4096" && PARM4=$HEAP_0
		;;

                --changelog)
                        TOTLN=$(wc -l $0 | awk '{ print $1 }')
                        INILN=$(grep -n "<SPICEDHAM" $0 | tail -1 | cut -d ":" -f "1")
                        LINHAI=$(expr $TOTLN - $INILN)
                        LINHAF=$(expr $LINHAI - 2)
                        echo -e -n "\n$TREXE "
                        grep '^vrs: ' $PRGDR/$TREXE | tail -1
                        echo -n "==> "
                        tail -$LINHAI $0 | head -$LINHAF
                        echo
                        unset TOTLN     INILN   LINHAI  LINHAF
                        exit
                ;;

                *)
                        if [ $(expr index "$1" "-") -ne 1 ]; then
                                if test -z "$PARM1"; then PARM1=$1; shift; continue; fi
                                if test -z "$PARM2"; then PARM2=$1; shift; continue; fi
                                if test -z "$PARM3"; then PARM3=$1; shift; continue; fi
                                if test -z "$PARM4"; then PARM4=$1; shift; continue; fi
                                if test -z "$PARM5"; then PARM5=$1; shift; continue; fi
                                if test -z "$PARM6"; then PARM6=$1; shift; continue; fi
                                if test -z "$PARM7"; then PARM7=$1; shift; continue; fi
                                if test -z "$PARM8"; then PARM8=$1; shift; continue; fi
                                if test -z "$PARM9"; then PARM9=$1; shift; continue; fi
                        else
                                echo "Opcao nao valida! ($1)"
                        fi
                ;;
        esac
        # Argumento tratado, desloca os parametros e trata o proximo
        shift
done
# -------------------------------------------------------------------------- #
# Para DEBUG assume valor DEFAULT antecipadamente
isNumber $DEBUG
[ $? -ne 0 ] && DEBUG=0
[ "$DEBUG" -ne "0" ] && PARMD="-d $DEBUG"

# Le configuracao do arquivo se este existir
if [ -s "$CONFIG" ]; then
	[ $(($DEBUG & $_BIT2_)) -ne 0 ] && echo "[SrviAHx]  0.00.01   - Carrega valores opcionais do arquivo de configuracao"
	TEMP=$(PegaValor HEAP_1);	[ -n "$TEMP" ] && MEMO1=$TEMP
	TEMP=$(PegaValor PERM_1);	[ -n "$TEMP" ] && PERM1=$TEMP
	TEMP=$(PegaValor TIME_1);	[ -n "$TEMP" ] && TIME1=$TEMP
	TEMP=$(PegaValor HEAP_2);	[ -n "$TEMP" ] && MEMO2=$TEMP
	TEMP=$(PegaValor PERM_2);	[ -n "$TEMP" ] && PERM2=$TEMP
	TEMP=$(PegaValor TIME_2);	[ -n "$TEMP" ] && TIME2=$TEMP
	TEMP=$(PegaValor HEAP_3);	[ -n "$TEMP" ] && MEMO3=$TEMP
	TEMP=$(PegaValor PERM_3);	[ -n "$TEMP" ] && PERM3=$TEMP
	TEMP=$(PegaValor TIME_3);	[ -n "$TEMP" ] && TIME3=$TEMP
fi

# Avalia o nivel de depuracao
[ $(($DEBUG & $_BIT3_)) -ne 0 ] && set -v
[ $(($DEBUG & $_BIT4_)) -ne 0 ] && set -x

echo "[TIME-STAMP] $HRINI [:INI:] $TREXE $LCORI"
if [ "$DEBUG" -gt "1" ]; then
        echo "==============================="
        echo "$PRGDR/$TREXE $LCORI"
        echo "= DISPLAY DE VALORES INTERNOS ="
        echo "==============================="

        echo "PRGDR = $PRGDR"
        echo "TREXE = $TREXE"
        echo "LCORI = $LCORI"
        echo "CURRD = $CURRD"
        echo
	test -n "$PARM1" && echo "PARM1 = $PARM1 (Server Nº)"
	test -n "$PARM2" && echo "PARM2 = $PARM2 (Action)"
	test -n "$PARM3" && echo "PARM3 = $PARM3 (OPTION)"
	test -n "$PARM4" && echo "PARM4 = $PARM4 (Memory)"
        test -n "$PARM5" && echo "PARM5 = $PARM5"
        test -n "$PARM6" && echo "PARM6 = $PARM6"
        test -n "$PARM7" && echo "PARM7 = $PARM7"
        test -n "$PARM8" && echo "PARM8 = $PARM8"
        test -n "$PARM9" && echo "PARM9 = $PARM9"
        echo
        echo "DEBUG level = $DEBUG"
	echo "     MINSRV = $MINSRV"
	echo "     MAXSRV = $MAXSRV"

	echo "     HEAP 0 = $HEAP_0"
	echo "     HEAP 1 = $MEMO1"
	echo "     HEAP 2 = $MEMO2"
	echo "     HEAP 3 = $MEMO3"
	echo "     HEAP 4 = $MEMO4"
	echo "     HEAP 5 = $MEMO5"
	echo "     HEAP 6 = $MEMO6"
	echo "     HEAP 7 = $MEMO7"
	echo "     HEAP 8 = $MEMO8"
	echo "     HEAP 9 = $MEMO9"

	echo "     PERM 0 = $PERM0"
	echo "     PERM 1 = $PERM1"
	echo "     PERM 2 = $PERM2"
	echo "     PERM 3 = $PERM3"
	echo "     PERM 4 = $PERM4"
	echo "     PERM 5 = $PERM5"
	echo "     PERM 6 = $PERM6"
	echo "     PERM 7 = $PERM7"
	echo "     PERM 8 = $PERM8"
	echo "     PERM 9 = $PERM9"

	echo "     TIME 0 = $TIME_0"
	echo "     TIME 1 = $TIME1"
	echo "     TIME 2 = $TIME2"
	echo "     TIME 3 = $TIME3"
	echo "     TIME 4 = $TIME4"
	echo "     TIME 5 = $TIME5"
	echo "     TIME 6 = $TIME6"
	echo "     TIME 7 = $TIME7"
	echo "     TIME 8 = $TIME8"
	echo "     TIME 9 = $TIME9"

        echo "==============================="
	echo "       MEMO = $MEMO"
	echo "       PERM = $PERM"
	echo "       TIME = $TIME"
        echo "==============================="
        echo
fi

#     1234567890123456789012345
echo "[srviahx]  1         - Controle de execucao do servidor iAHx"

# Garante condicoes de operacao
[ -z "$PARM1" ] && echo "Syntax error missing parameter $AJUDA_USO" && exit 2

# Deve ser uma instancia 
isNumber $PARM1
[ "$?" -ne 0 ] && echo "Syntax error parameter 1 must be a number $AJUDA_USO" && exit 2

# Deve ser uma instancia valida
if [ "$PARM1" -lt "$MINSRV" -o "$PARM1" -gt "$MAXSRV" ]; then
	echo "Syntax error mistyped parameter 1 $AJUDA_USO"
	exit 2
fi

case	"$PARM1"	in

	1)
		MEMO="${MEMO1}"
		PERM="${PERM1}"
		TIME="${TIME1}"
		;;

	2)
		MEMO="${MEMO2}"
		PERM="${PERM2}"
		TIME="${TIME2}"
		;;

	3)
		MEMO="${MEMO3}"
		PERM="${PERM3}"
		TIME="${TIME3}"
		;;

	4)
		MEMO="${MEMO4}"
		PERM="${PERM4}"
		TIME="${TIME4}"
		;;

	5)
		MEMO="${MEMO5}"
		PERM="${PERM5}"
		TIME="${TIME5}"
		;;

	6)
		MEMO="${MEMO6}"
		PERM="${PERM6}"
		TIME="${TIME6}"
		;;

	7)
		MEMO="${MEMO7}"
		PERM="${PERM7}"
		TIME="${TIME7}"
		;;

	8)
		MEMO="${MEMO8}"
		PERM="${PERM8}"
		TIME="${TIME8}"
		;;

	9)
		MEMO="${MEMO9}"
		PERM="${PERM9}"
		TIME="${TIME9}"
		;;
esac

# Assume porcao de memoria conforme servidor ou opcao de chamada
if [ ! -z "$PARM4" ]; then
	MEMO=$PARM4
fi

if [ "$DEBUG" -gt 1 ]; then
	echo "***"
	echo "   MEMO = $MEMO"
	echo "   PERM = $PERM"
	echo "   TIME = $TIME"
	echo "***"
fi

# Determina caminho para os 'executaveis'
scriptpath=$0
case $scriptpath in 
	./*)  SCRIPT_PATH=$(pwd);;
	  *)  SCRIPT_PATH=$(dirname $scriptpath);;
esac
[ "$DEBUG" -gt "1" ] && echo "SCRIPT_PATH: $SCRIPT_PATH"

SERVER="-server"
#HEAPSIZE="-Xmx4096M"
#HEAPSIZE="-Xmx6144M"
HEAPSIZE="-Xmx${MEMO}M" 
PERMSIZE="$PERM"

[ $DEBUG -gt 1 ] && echo "HEAPSIZE a alocar para o servidor $PARM1 => $HEAPSIZE"
[ $DEBUG -gt 1 ] && echo "PERMZISE a  ser usado no servidor $PARM1 => $PERMSIZE"

#look for bundled jre
if [ -f $SCRIPT_PATH/../jre/bin/java ]; then
	JAVA_HOME=$SCRIPT_PATH/../jre
	JVM=$JAVA_HOME/../jre/bin/java
else
	JVM=java
	#does the jvm support -server?
	$JVM -server -version > /dev/null 2>&1
	[ $? != "0" ] && SERVER=""
fi

JAVA_OPTS="$SERVER $HEAPSIZE $PERMSIZE"

export JAVA_OPTS JAVA_HOME
export CATALINA_PID=${SCRIPT_PATH}/../instances/$PARM1/iahx-server.pid

[ "$DEBUG" -gt "1" ] && echo "JAVA_HOME=$JAVA_HOME"
[ "$DEBUG" -gt "1" ] && echo "      JVM=$JVM"
[ "$DEBUG" -gt "1" ] && echo "   SERVER=$SERVER"
[ "$DEBUG" -gt "1" ] && echo " HEAPSIZE=$HEAPSIZE"

cd ${SCRIPT_PATH}/../instances/$PARM1
[ "$DEBUG" -gt "1" ] && echo "Diretorio corrente: $(pwd)"

# prevent java.io.IOException: Map failed
ulimit -v unlimited

echo "[srviahx]  2         - Operando o servico, aguarde..." 
echo
echo ${SCRIPT_PATH}/../instances/$PARM1/bin/catalina.sh "$PARM2" "$PARM3" "$PARM4"
echo
[ "$DEBUG" -gt "1" ] && echo "${SCRIPT_PATH}/../instances/$PARM1/bin/catalina.sh $PARM2 $PARM3 $PARM4"
${SCRIPT_PATH}/../instances/$PARM1/bin/catalina.sh $PARM2 $PARM3 $PARM4
RETORNO=$?
cd -

cat > /dev/null <<COMMENT
  debug             Start Catalina in a debugger
  debug -security   Debug Catalina with a security manager
  jpda start        Start Catalina under JPDA debugger
  run               Start Catalina in the current window
  run -security     Start in the current window with security manager
  start             Start Catalina in a separate window
  start -security   Start in a separate window with security manager
  stop              Stop Catalina
  stop -force       Stop Catalina (followed by kill -KILL)
  version     
COMMENT

if [ $RETORNO -eq 0 -a "$PARM2" != "version" ]; then
	# Aguarda passar 4 minutos mostrando alguma atividade
	if [ "$PARM2" = "stop" ]; then
		if [ -z "$PARM3" ]; then
			ESPERA=${TIME}
		else
			ESPERA=2
		fi
	else
		ESPERA=${TIME}
	fi
	[ "$DEBUG" -gt 1 ] && echo -e "\n\n\nESPERA = $ESPERA\n\n\n"
	while [ $ESPERA -gt 0  ]
	do
		ESPERA=$(expr $ESPERA - 1)
		echo -e -n "\r$ESPERA   "
		sleep 1
	done
fi
echo
echo "[srviahx]  3         - Finaliza execucao" 

source	$PATH_EXEC/inc/inff_exec.inc

echo "[TIME-STAMP] $HRFIM [:FIM:] $TREXE $LCORI"
# -------------------------------------------------------------------------- #
# Pertencentes a infraestrutura de processamento
unset   TPR     MSG
unset   LGDTC   LGRAIZ  LGPRD
unset   TREXE   PRGDR   LCORI   CURRD
unset   HINIC   HFINI   HRINI   HRFIM
unset   MTPROC  HTPROC  STPROC  TPROC   THUMAN
unset   _BIT0_  _BIT1_  _BIT2_  _BIT3_
unset   _BIT4_  _BIT5_  _BIT6_  _BIT7_
unset   PARM1   PARM2   PARM3   PARM4   PARM5
unset   PARM6   PARM7   PARM8   PARM9   PARMD
unset   TEMP    DEBUG   CONFIG  MIDNAME AJUDA_USO
unset   _DIA_   _MES_   _ANO_

# Especificos da aplicacao
unset   ETORNO	HEAPSIZE	SERVER	SCRIPT_PATH
# -------------------------------------------------------------------------- #
cat > /dev/null <<SPICEDHAM
CHANGELOG
20130122 Inclusao de controles diversos
20130219 Ajustamento nos tempos de espera pos START e STOP do servidor
	 Eliminacao do arquivo que armazena o ID do processo do servidor
	 Eliminacao formal de variaveis utilizadas no SCRIPT
20130613 Tempo de guarda definido pelo servidor operado
20140225 Ajuste no mapeamento de diretorios
SPICEDHAM

