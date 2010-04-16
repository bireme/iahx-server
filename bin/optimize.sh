scriptpath=$0

case $scriptpath in 
 ./*)  SCRIPT_PATH=`pwd`;;
  * )  SCRIPT_PATH=`dirname $scriptpath`
esac

INICIO=`date`

if [ "$#" -ne 1 ]
then   
   echo "iAHx - optimize index" 
   echo "Usage:   optimize.sh <indice>"
   echo 
   echo "Ex.: optimize.sh example"
   echo
   exit
fi

INDEX=${1}

# IAHX-SERVER 
IAHX_SERVER="localhost"
IAHX_PORT="8080"

echo "Optimize index ${INDEX}"

java -jar ${SCRIPT_PATH}/postXML.jar http://${IAHX_SERVER}:${IAHX_PORT}/${INDEX}/update ${SCRIPT_PATH}/optimize.xml

. ./checkerror $? "optimize fail for index $1"
