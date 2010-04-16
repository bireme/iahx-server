scriptpath=$0

case $scriptpath in 
 ./*)  SCRIPT_PATH=`pwd`;;
  * )  SCRIPT_PATH=`dirname $scriptpath`
esac

INICIO=`date`

if [ "$#" -ne 1 ]
then   
   echo "iAHx - commit updates on index" 
   echo "Usage:  commit.sh <indice>"
   echo 
   echo "Ex.: commit.sh  example"
   echo
   exit
fi

INDEX=${1}

# IAHX-SERVER 
IAHX_SERVER="localhost"
IAHX_PORT="8080"

echo "Commit index ${INDEX}"

java -jar ${SCRIPT_PATH}/postXML.jar http://${IAHX_SERVER}:${IAHX_PORT}/${INDEX}/update ${SCRIPT_PATH}/commit.xml

. ./checkerror $? "commit fail for index $1"
