scriptpath=$0

case $scriptpath in 
 ./*)  SCRIPT_PATH=`pwd`;;
  * )  SCRIPT_PATH=`dirname $scriptpath`
esac

INICIO=`date`

if [ "$#" -ne 2 ]
then   
   echo "iAHx DELETEDOCS" 
   echo "Uso:     deletedocs.sh <indice> <query>"
   echo 
   echo "Exemplo: deletedocs.sh example title:solr"
   echo
   exit
fi

INDEX=${1}
QUERY=${2}

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


echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > deletedocs.xml
echo "<delete><query>${QUERY}</query></delete>" >> deletedocs.xml


echo "Delete docs from index ${INDEX}"

java -jar ${SCRIPT_PATH}/postXML.jar http://localhost:$PORT/${INDEX}/update deletedocs.xml

. checkerror $? "delete fail for index $1"

rm deletedocs.xml
