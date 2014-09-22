#!/bin/bash

# -------------------------------------------------------------------------- #
# deletedocs.sh - Remove documentos do indice
# -------------------------------------------------------------------------- #
#     Entrada:	PARM1 com o nome do indice a processar
#		PARM2 com a expressao de busca dos documentos a eliminar
#		opcoes de execucao
#		 --changelog		Mostra historico de alteracoes
#		 -d N, --debug N	Nivel de depuracao
#		 -e, --no-error		Ignora deteccao de erros
#		 -h, --help		Mostra o help
#		 -p, --producao		Efetua delete no indice da producao
#		 -P, --prova		Efetua delete no indice da homologacao
#		 -V, --versao		Mostra a versao
#	Saida:	Indice 'limpo' dos documento indicados para delecao
#		Codigos de retorno:
#		 0 - operacao ok
#		 1 - causas diversas nao espefcifico
#		 2 - Syntax Error
#		 3 - Configuration Error
#		 4 - Configuration Failure
#    Corrente:	/bases/iahx/proc/<INSTANCIA>/main
#     Chamada:	deletedocs.sh <ID_INDEX> <SEARCH_EXPR>
#     Exemplo:	deletedocs.sh -d 2 bioetica *:*
# Objetivo(s):	Retirar documentos do indice
# Comentarios:	-
# Observacoes:	DEBUG eh uma variavel mapeada por bit conforme
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
vrs:  0.00 20100000, VAA
	- Edicao original
vrs:  1.00 20121011, FJLopes
	- Adaptacao para servidor generico
vrs:  1.01 20140310, FJLopes
	- Preparo para formacao de pacote de distribuicao
HISTORICO
# ========================================================================== #
#  Carga de Bibliotecas
# ========================================================================== #
#source $PATH_EXEC/inc/_process_.inc
# Incorpora biblioteca especifica de iAHx
source	$PATH_EXEC/inc/iAHx2.inc
# Conta com as funcoes:
#	rdANYTHING	PARM1	Retorna o ID do indice, por qualquer item
#	rdINDEX		PARM1	Retorna o nome do indice
#	rdINSTANCIA	PARM1	Retorna o nome da instancia
#	rdDIRETORIO	PARM1	Retorna o diretorio de processamento
#	rdINDEXROOT	PARM1	Retorna o caminho da raiz do indice
#	rdHOMOLOG	PARM1	Retorna o nome do servidor de homologacao
#	rdPRODUCAO	PARM1	Retorna o nome do servidor de producao
#	rdINBOX		PARM1	Retorna o diretorio de dados no INBOX
#	rdLILDEBIWEB	PARM1	Retorna o caminho para bases externas em LilDBI-Web

source	$PATH_EXEC/inc/infi_exec.inc
# Conta com as funcoes:
#	isNumber	PARM1	Retorna FALSE se PARM1 nao for numerico
# -------------------------------------------------------------------------- #
# Texto de ajuda de utilizacao do comando

#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
AJUDA_USO="
Uso: $TREXE [OPCOES] <PARM1>

OPCOES:
 --changelog         Exibe o historico de alteracoes
 -d, --debug  NIVEL  Define nivel de depuracao com valor numerico positivo
 -e, --no-error      Ignora deteccao de erros
 -h, --help          Exibe este texto de ajuda e para a execucao
 -p, --producao      Efetua delete no indice da producao
 -P, --prova         Efetua delete no indice da homologacao
 -V, --version       Exibe a versao corrente do comando e para a execucao

PARAMETROS:
 PARM1   Identificador do indice a commitar
 PARM2   Expressao de busca dos documentos a eliminar
"

# -------------------------------------------------------------------------- #
# Assume valores default

N_DEB=0
DEBUG="0"
NOERRO="0"
OPC_ERRO=""
SERVIDOR="localhost"

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
			N_DEB=$(expr $((DEBUG & 6)) / 2)
                ;;

		-e | --no-error)
			NOERRO="1"
			OPC_ERRO="-e"
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

		-p | --producao)
			SERVIDOR="PRODU"
		;;

		-P | --prova)
			SERVIDOR="HOMOL"
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
# Para DEBUG assume valor DEFAULT antecipadamente
isNumber $DEBUG
[ $? -ne 0 ]         && DEBUG="0"
[ "$DEBUG" -ne "0" ] && PARMD="-d $DEBUG"
# Avalia nivel de depuracao
[ $(($DEBUG & $_BIT3_)) -ne 0 ] && set -v
[ $(($DEBUG & $_BIT4_)) -ne 0 ] && set -x

# --------------------------------------------------------------------------- #
echo "[TIME-STAMP] $HRINI [:INI:] $TREXE $LCORI"
#     1234567890123456789012345
echo "[delete]  1         - Document DELETE"

# -------------------------------------------------------------------------- #
# Garante que a instancia esta definida (sai com codigo de erro 2 - Syntax Error)
if [ -z "$PARM1" ]; then
        echo "[delete]  1.01      - Erro na chamada falta o parametro 1"
        echo
        echo "Syntax error:- Missing PARM1"
        echo "$AJUDA_USO"
        exit 2
fi
if [ -z "$PARM2" ]; then
        echo "[delete]  1.01      - Erro na chamada falta o parametro 2"
        echo
        echo "Syntax error:- Missing PARM2"
        echo "$AJUDA_USO"
        exit 2
else
	QUERY=$PARM2
fi

# -------------------------------------------------------------------------- #
# Garante existencia da tabela de configuracao (sai com codigo de erro 3 - Configuration Error)
#                                        1234567890123456789012345
[ $N_DEB -ne 0 ]                    && echo "[delete]  0.00.01   - Testa se ha tabela de configuracao"
[ ! -s "$PATH_EXEC/tabs/iAHx.tab" ] && echo "[delete]  1.01      - Tabela iAHx nao encontrada" && exit 3

unset   IDIDX   INDEX
# Garante existencia do indice indicado na tabela de configuracao (sai com codigo de erro 4 - Configuration Failure)
# alem de tomar nome oficial do indice para o SOLR
#                                        1234567890123456789012345
[ $N_DEB -ne 0 ] && echo "[delete]  0.00.02   - Testa se o indice eh valido"
IDIDX=$(rdANYTHING $PARM1)
[ $? -eq 0 ]     && INDEX=$(rdINDEX $IDIDX)
[ -z "$INDEX" ]  && echo "[delete]  1.01      - PARM2 nao indica um indice valido" && exit 4

# Toma os dados de configuracao para o indice indicado
[ $N_DEB -ne 0 ] && echo "[commit]  0.00.03   - Carrega as configuracoes do indice apontado"
INSTA=$(rdINSTANCIA $IDIDX)
DIRET=$(rdDIRETORIO $IDIDX)
COMUM=$(rdINDEXROOT $IDIDX)
HOMOL=$(rdHOMOLOG   $IDIDX); [ "$SERVIDOR" = "HOMOL" ] && SERVIDOR=$HOMOL
PRODU=$(rdPRODUCAO  $IDIDX); [ "$SERVIDOR" = "PRODU" ] && SERVIDOR=$PRODU

# Toma a chamada e determina o PATH para este script
[ "$PRGDR" = "." ] && PRGDR=$(pwd)

if [ $N_DEB -ne 0 ]; then
        echo "==============================="
        echo "$PRGDR/$TREXE $LCORI"
        echo "= DISPLAY DE VALORES INTERNOS ="
        echo "==============================="

        test -n "$PARM1" && echo "   PARM1 = $PARM1"
        test -n "$PARM2" && echo "   PARM2 = $PARM2"
        test -n "$PARM3" && echo "   PARM3 = $PARM3"
        echo
	echo "   DEBUG = $DEBUG"
	echo "   N_DEB = $N_DEB"
        echo "   PRGDR = $PRGDR"
        echo "   TREXE = $TREXE"
        echo "   LCORI = $LCORI"
        echo "   CURRD = $CURRD"
        echo "   IDIDX = $IDIDX"
        echo "   INDEX = $INDEX"
	echo "   INSTA = $INSTA"
	echo "   DIRET = $DIRET"
	echo "   COMUM = $COMUM"
	echo "   HOMOL = $HOMOL"
	echo "   PRODU = $PRODU"
	echo "  NOERRO = $NOERRO"
        echo "OPC_ERRO = $OCP_ERRO"
	echo "SERVIDOR = $SERVIDOR"
	echo
	if [ $N_DEB -gt 2 ]; then
	        echo "Lista de instancias configuradas neste servidor ($HOSTNAME)"
        	ls -l ${PRGDR}/../instances/?/conf/Catalina/localhost/*.xml
	fi
        echo "==============================="
        echo
fi

[ "$HOMOL" = "." -a $N_DEB -ne 0 ] && echo "[commit]  1.02      - Instancia sem homologacao ou homologacao no processamento"

# Monta XMl de delecao de documentos
  echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >  deletedocs.xml
  echo "<delete><query>${QUERY}</query></delete>"   >> deletedocs.xml

if [ $N_DEB -gt 1 ]; then
	echo "========================================"
	echo "      nome do indice (Param1): $INDEX"
	echo "expressao de delecao (Param2): $QUERY"
	echo
	cat deletedocs.xml
	echo "========================================"
fi

# Discovery if and where index is instaled
#     1234567890123456789012345"
echo "[delete]  2         - Prepara a delecao"
echo "[delete]  2.01      - Descobre em qual servidor esta o indice"
for instance in $(ls ${PATH_IAHX}/../instances/)
do
        [ $N_DEB -gt 1 ] && echo "[delete]  2.01.0$instance   - Varrendo server numero $instance"
        if [ -f ${PATH_IAHX}/../instances/${instance}/conf/Catalina/localhost/${INDEX}.xml ]; then
                SERVERNO=${instance}
                break
        fi
done

if [ "$SERVERNO" = "" ]; then
        echo
        echo "[delete]  2.02      - Fatal: Index are not available on insances servers"
        echo
        exit 4
fi

# Concatenate default 898 to server number. ex. 898 to server1 parameter resulting 8981
PORT="898${SERVERNO}"
#                           1234567890123456789012345
[ $N_DEB -gt 1 ] && echo "[delete]  2.02.00   - PORT = $PORT"

echo "[delete]  2.02      - Delete document(s) '$QUERY' in index ${INDEX} on iahx-server ${SERVERNO} in ${SERVIDOR} at $HRINI"

[ $N_DEB -ne 0 -a "$SERVIDOR" != "." ] && echo "java -jar $PATH_IAHX/postXML.jar http://${SERVIDOR}:${PORT}/${INDEX}/update deletedocs.xml"
# Se nao eh execucao FAKE manda deletar
if [ $(($DEBUG & $_BIT7_)) -eq 0 -a "$SERVIDOR" != "." ]; then
			  java -jar $PATH_IAHX/postXML.jar http://${SERVIDOR}:${PORT}/${INDEX}/update deletedocs.xml
			  RSP=$?; [ "$NOERRO" = "1" ] && RSP=0
			  source checkerror $RSP "delete fail for index $1"
fi

[ -f "deletedocs.xml" ] && rm -f deletedocs.xml
source	$PATH_EXEC/inc/inff_exec.inc

echo "[TIME-STAMP] $HRFIM [:FIM:] $TREXE $LCORI"
# -------------------------------------------------------------------------- #
cat > /dev/null <<SPICEDHAM
CHANGELOG
20100000 Forma original por VAA
20140225 Ajuste no mapeamento de diretorios
20140310 Atendimento a delecao em servidor de processamento, homologacao e producao por opcao de chamada
SPICEDHAM

