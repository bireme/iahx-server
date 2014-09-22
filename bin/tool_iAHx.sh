#!/bin/bash

# -------------------------------------------------------------------------- #
# tool_iAHx.sh - Pesquisa existencia de uma instancia nos servidores
# -------------------------------------------------------------------------- #
#     Entrada:	PARM1 nome do indice a ser procurado
#		Opcoes de execucao:
#		 -h, --help             Mostra o help
#		 -V, --version          Mostra a versao
#		 -d, --debug NIVEL      Define nivel de depuracao
#		 --changelog            Mostrar historico de alteracoes
#	Saida:	NENHUMA
#    Corrente:	inespecifico
#     Chamada:	psx [-d N]
#     Exemplo:	psx
# Objetivo(s):	Mostrar processos de iah-server ativos
# Comentarios:	-
# Observacoes:	DEBUG eh uma variavel mapeada por bit conforme
		_BIT0_=1;       # Aguarda tecla <ENTER>
		_BIT1_=2;       # Mostra mensagens de DEBUG
		_BIT2_=4;       # Modo verboso
		_BIT3_=8;       # Modo debug de linhas -v
		_BIT4_=16;      # Modo debug de linhas -x
		_BIT5_=32;      # .
		_BIT6_=64;      # .
		_BIT7_=128;     # Opera em modo FAKE
#        Notas: Um link simbolico psiahx pode ser provido
# Dependencias: 
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
vrs:  0.00 20100000, VAA
        - Edicao original
vrs:  1.00 20121109, FJLopes
        - Adaptacao para servidor generico
vrs:  1.01 20140224, FJLopes
        - Preparo para formacao de pacote de distribuicao
HISTORICO
# ========================================================================== #
#  Carga de Bibliotecas
# ========================================================================== #
#source $PATH_EXEC/inc/_process_.inc
# Incorpora biblioteca especifica de iAHx
source	$PATH_EXEC/inc/iAHx2.inc
# Conta com as funcoes:
#	rdANYTHING	PARM1	Retorna o identificador unico do indice
#	rdINDEX		PARM1	Retorna o nome do indice (ou FALSE)
#	rdINSTANCIA	PARM1	Retorna o nome da instancia
#	rdDIRETORIO	PARM1	Retorna o diretorio de processamento
#	rdINDEXROOT	PARM1	Retorna o caminho da raiz de indices
#	rdHOMOLOG	PARM1	Retorna o nome do servidor de homologacao
#	rdPRODUCAO	PARM1	Retorna o nome do servidor de producao
#	rdINBOX		PARM1	Retorna o diretorio de dados no INBOX
#	rdURL		PARM1	Retorna o endereco padrao da interface
#	rdLILDBIWEB	PARM1	Retorna o caminho para bases externas em LilDBI-Web
#
source  $PATH_EXEC/inc/infi_exec.inc
# Conta com as funcoes:
#       isNumber        PARM1   Retorna FALSE se PARM1 nao for numerico
# -------------------------------------------------------------------------- #
# Texto de ajuda de utilizacao do comando

#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
AJUDA_USO="
Uso: $TREXE [OPCOES] <PARM1>

OPCOES:
 -h, --help             Exibe este texto de ajuda e para a execucao
 -V, --version          Exibe a versao corrente do comando e para a execucao
 -d, --debug  NIVEL     Define nivel de depuracao com valor numerico positivo
 --changelog            Exibe o historico de alteracoes

PARAMETROS:
 PARM1  Com o nome do indice a ser localizado
"

# -------------------------------------------------------------------------- #
# Texto de sintaxe do comando

SINTAXE="

Uso: $TREXE [OPCOES] <PARM1>

"

# -------------------------------------------------------------------------- #
# Assume valores default

DEBUG="0"
unset SRVNM

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

# --------------------------------------------------------------------------- #
echo "[TIME-STAMP] $HRINI [:INI:] $TREXE $LCORI"
#     1234567890123456789012345
echo "[tool]  1         - Inicia a busca"

# -------------------------------------------------------------------------- #
# Garante que a instancia esta definida (sai com codigo de erro 2 - Syntax Error)
if [ -z "$PARM1" ]; then
        echo "[tool]  1.01      - Erro na chamada falta o parametro 1"
        echo
        echo "Syntax error:- Missing PARM1"
        echo "$AJUDA_USO"
        exit 2
fi

# -------------------------------------------------------------------------- #
# Garante existencia da tabela de configuracao (sai com codigo de erro 3 - Configuration Error)
#                                        1234567890123456789012345
[ $(($DEBUG & $_BIT2_)) -ne 0 ]     && echo "[tool]  0.00.01   - Testa se ha tabela de configuracao"
#                                            1234567890123456789012345
[ ! -s "$PATH_EXEC/tabs/iAHx.tab" ] && echo "[tool]  1.01      - Tabela iAHx nao encontrada" && exit 3

unset   IDIDX   INDEX
# Garante existencia do indice indicado na tabela de configuracao (sai com codigo de erro 4 - Configuration Failure)
# alem de tomar nome oficial do indice para o SOLR
#                                        1234567890123456789012345
[ $(($DEBUG & $_BIT2_)) -ne 0 ] && echo "[tool]  0.00.02   - Testa se o indice eh valido"
IDIDX=$(rdANYTHING $PARM1)
[ $? -eq 0 ]                    && INDEX=$(rdINDEX $IDIDX)
[ -z "$INDEX" ]                 && echo "[tool]  1.01      - PARM2 nao indica um indice valido" && exit 4


for instance in $(ls ${PATH_IAHX}/../instances/)
do
	[ "$DEBUG" -gt "1" ] && echo "[tool]  1.0$instance - Polling server number $instance"
	if [ -f ${PATH_IAHX}/../instances/${instance}/conf/Catalina/localhost/${INDEX}.xml ]; then
		SRVNM=${instance}
		break
	fi
done

[ "$DEBUG" -gt "1" ] && echo -n "[tool]  2.        - "
if [ -z "$SRVNM" ]; then
	echo "Fatal: Index \"$INDEX\" not available in any server instance"
	exit 4
else
	echo -n "$INDEX on server "
fi
echo $SRVNM

source  $PATH_EXEC/inc/inff_exec.inc

echo "[TIME-STAMP] $HRFIM [:FIM:] $TREXE $LCORI"
# -------------------------------------------------------------------------- #
# Pertencentes a infraestrutura de processamento
unset   LGRAIZ  LGPRD
unset   TREXE   PRGDR   LCORI   CURRD
unset   HINIC   HFINI   HRINI   HRFIM
unset   MTPROC  HTPROC  STPROC  TPROC   THUMAN
unset   _BIT0_  _BIT1_  _BIT2_  _BIT3_
unset   _BIT4_  _BIT5_  _BIT6_  _BIT7_
unset   PARM1   PARM2   PARM3   PARM4   PARM5
unset   PARM6   PARM7   PARM8   PARM9   PARMD
unset   TEMP    DEBUG   CONFIG  MIDNAME AJUDA_USO
unset   _DIA_   _MES_   _ANO_

# -------------------------------------------------------------------------- #
cat > /dev/null <<SPICEDHAM
CHANGELOG
20100000 Forma original por VAA
20121011 Inclusao do mecanismos de apoio e depuracao
20140224 Ajuste no mapeamento de diretorios
SPICEDHAM

