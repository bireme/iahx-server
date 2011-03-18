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
   echo "iAHx INDEX" 
   echo "Uso:     index.sh <arquivo xml> <indice>"
   echo 
   echo "Exemplo: index.sh example.xml example"
   echo
   exit
fi

XML=${1}
INDEX=${2}

# discovery where index are instaled 
for instance in `ls ${SCRIPT_PATH}/../instances/`
do
  if [ -f ${SCRIPT_PATH}/../instances/${instance}/conf/Catalina/localhost/${INDEX}.xml ];
  then
     SERVER=${instance}
     break
  fi     	 
done

if [ "$SERVER" = "" ];
then
   echo
   echo "ERROR: Index are not available on intances servers"
   echo
   exit
fi     

# concat default 898 to server number. ex. 8981 to server1 parameter 
PORT="898${SERVER}"

echo "Indexing ${XML} in ${INDEX} on server ${SERVER}: $INICIO" 

java -Xmx128m -jar ${SCRIPT_PATH}/postXML.jar http://localhost:${PORT}/${INDEX}/update ${XML}


FINAL=`date`

echo "Finished index of ${XML} in ${INDEX}: $FINAL" 



