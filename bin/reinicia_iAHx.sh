#!/bin/bash

# -------------------------------------------------------------------------- #
# reinicia_iAHx.sh - Promove um restart de todos os iahx-servers             #
# -------------------------------------------------------------------------- #
#  Diretorio: -
#    Exemplo: nohup reinicia_iAHx.sh &>> ~/restart_iAHx.txt &
# IMPORTANTE: deve ser executado com user 'tomcat'
# -------------------------------------------------------------------------- #
#   Centro Latino-Americano e do Caribe de Informação em Ciências da Saúde
#      é um centro especialidado da Organização Pan-Americana da Saúde,
#            escritório regional da Organização Mundial da Saúde
#                         BIREME / OPS / OMS (P)2014
# -------------------------------------------------------------------------- #
# Historico
# versao data, Responsavel
#       - Descricao
cat > /dev/null <<HISTORICO
vrs:  0.00 20140818, FJLopes
        - Edicao original
HISTORICO
# ========================================================================== #
#                                BIBLIOTECAS                                 #
# ========================================================================== #
source /usr/local/bireme/misc/infoini.inc
source $PATH_EXEC/inc/iAHx2.inc

# -------------------------------------------------------------------------- #
# Texto de ajuda de utilizacao do comando
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
AJUDA_USO="
Uso: $TREXE [OPCOES]

OPCOES:
 --changelog         Exibe o historico de alteracoes
 -d, --debug  NIVEL  Define nivel de depuracao com valor numerico positivo
 -h, --help          Exibe este texto de ajuda e para a execucao
 -V, --version       Exibe a versao corrente do comando e para a execucao

NOTAS:
 Determina quantos servidores estao instalados e efetua restart em todos eles

"

# -------------------------------------------------------------------------- #
# Ajustes de ambiente

FAKE=0
N_DEB=0
DEBUG="0"

# -------------------------------------------------------------------------- #
# Tratamento das opcoes de linha de comando (qdo houver alguma)

while test -n "$1"
do
	case "$1" in

		-h | --help)
			echo "$AJUDA_USO"
			exit 0
		;;

		-V | --version)
			echo -e -n "\n$TREXE "
			grep '^vrs: ' $PRGDR/$TREXE | tail -1
			echo
			exit 0
		;;

		-d | --debug)
			shift
			isNumber $1
			[ $? -ne 0 ] && echo -e "\n$TREXE: O argumento da opcao DEBUG deve existir e ser numerico.\n$AJUDA_USO" && exit 1
			DEBUG=$1
			N_DEB=$(expr $(($DEBUG & 6)) / 2)
			FAKE=$(expr $(($DEBUG & _BIT7_)) / 128)
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
			exit 0
		;;

		*)
			if [ $(expr index "$1" "-") -ne 1 ]; then
				if test -z "$PARM1"; then PARM1=$1; shift; continue; fi
				if test -z "$PARM2"; then PARM2=$1; shift; continue; fi
			else
				echo "Opcao nao valida! ($1)"
			fi
		;;
	esac
	# Argumento tratado, desloca os parametros e trata o proximo
	shift
done

# Para DEBUG assume valor DEFAULT antecipadamente
isNumber $DEBUG
[ $? -ne 0 ]         && DEBUG=0
[ "$DEBUG" -ne "0" ] && PARMD="-d $DEBUG"
# Avalia nivel de depuracao
[ $(($DEBUG & $_BIT3_)) -ne 0 ] && set -v
[ $(($DEBUG & $_BIT4_)) -ne 0 ] && set -x

# Determina a quantidade de servidores iAHx instalados
QTDiAHx=$(ls $PATH_IAHX/../instances | wc -l)

for i in $(seq $QTDiAHx)
do
	# Para cada instancia encontrada que esteja em execucao
	[ "$N_DEB" != "0" ] && echo "Tentando parar o iahx-server $i"
	psx $i
	[ $? -eq 0 ] && srviahx.sh $i stop -force
done
for i in $(seq $QTDiAHx)
do
	# Para cada instancia instalada
	[ "$N_DEB" != "0" ] && echo "Colocando iahx-server $i em atividade"
	srviahx.sh $i start
done

# Faz cinco segundos de charme
[ "$N_DEB" != "0" ] && echo "Tempo minimo para novas operacoes"
sleep 5

source /usr/local/bireme/misc/infofim.inc
#
cat > /dev/null <<COMMENT

     Entrada:	Sem parametros (soh opcoes)
		Opcoes de execucao
		 --changelog           Mostra historico de alteracoes
		 -d N, --debug N       Nivel de depuracao
		 -h, --help            Mostra o help
		 -V, --version         Mostra a versao
       Saida:	sem saidas definidas
    Corrente:	qualquer
     Chamada:	$PATH_IAHX/reinicia_iAHx.sh
     Exemplo:	reinicia_iAHx.sh
 Objetivo(s):	Reiniciar todos os iahx-servers da maquina
 Comentarios:	Trabalha em conjunto com a versao 2 da biblioteca iAHx
 Observacoes:	DEBUG eh uma variavel mapeada por bit conforme
		_BIT0_	Aguarda tecla <ENTER>
		_BIT1_	Mostra mensagens de DEBUG
		_BIT2_	Modo verboso
		_BIT3_	Modo debug de linha -v
		_BIT4_	Modo debug de linha -x
		_BIT5_	.
		_BIT6_	.
		_BIT7_	Execucao FAKE
       Notas:	Deve ser executado como 'tomcat'
Dependencias:	Relacoes de dependencia para execucao:
		Variaveis de ambiente que devem estar previamente ajustadas:
		geral	    BIREME - Path para o diretorio com especificos de BIREME
		geral	      MISC - Path para o diretorio de miscelaneas de BIREME
		geral	      TABS - Path para as tabelas de uso geral da BIREME
		geral	    _BIT0_ - 00000001b
		geral	    _BIT1_ - 00000010b
		geral	    _BIT2_ - 00000100b
		geral	    _BIT3_ - 00001000b
		geral	    _BIT4_ - 00010000b
		geral	    _BIT5_ - 00100000b
		geral	    _BIT6_ - 01000000b
		geral	    _BIT7_ - 10000000b
		iAHx	     ADMIN - e-mail ofi@bireme.br
		iAHx	 PATH_IAHX - Path para o cerne de iAHx
		iAHx	 PATH_EXEC - Path para os executaveis gerais de iAHx
		iAHx	PATH_INPUT - Path para o deposito de entrada do iAHx
		iAHx	INDEX_ROOT - Path para o topo da arvore de indices de iAHx
		iAHx	 PATH_PROC - Path para a raiz de processamento iAHx
		iAHx	    SHiAHx - Nome do servidor de homologacao de iAHx
		iAHx	    SPiAHx - Nome do servidor de producao do iAHx
		iAHx	    STiAHx - Nome do servidor de teste do iAHx
COMMENT
cat > /dev/null <<SPICEDHAM
CHANGELOG
20140818 Edicao original
SPICEDHAM

