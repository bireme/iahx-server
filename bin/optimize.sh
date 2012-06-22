scriptpath=$0

case $scriptpath in 
 ./*)  SCRIPT_PATH=`pwd`;;
  * )  SCRIPT_PATH=`dirname $scriptpath`
esac

INICIO=`date`

if [ "$#" -ne 1 ]
then   
   echo "iAHx OPTIMIZE" 
   echo "Uso:     optimize.sh <indice>"
   echo 
   echo "Exemplo: optimize.sh example"
   echo
   exit
fi

INDEX=${1}

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

echo "Optimize index ${INDEX}"

java -jar ${SCRIPT_PATH}/postXML.jar http://localhost:$PORT/${INDEX}/update ${SCRIPT_PATH}/optimize.xml

