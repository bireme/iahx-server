#!/bin/sh
# Index shell script

scriptpath=$0

case $scriptpath in 
 ./*)  SCRIPT_PATH=`pwd`;;
  * )  SCRIPT_PATH=`dirname $scriptpath`
esac

INICIO=`date`

if [ "$#" -ne 2 ]
then   
   echo "iAHx - send xml file for indexing" 
   echo "Uso: index.sh <arquivo xml> <indice>"
   echo 
   echo "Ex.: index.sh example.xml example"
   echo
   exit
fi

XML=${1}
INDEX=${2}

# IAHX-SERVER 
IAHX_SERVER="localhost"
IAHX_PORT="8080"

echo "Indexing ${XML} in ${INDEX} on server ${SERVER}: $INICIO" 

java -Xmx128m -jar ${SCRIPT_PATH}/postXML.jar http://${IAXH_SERVER}:${IAHX_PORT}/${INDEX}/update ${XML}

. ./checkerror $? "Problem indexing ${XML}"

FINAL=`date`

echo "Finished index of ${XML} in ${INDEX}: $FINAL" 
