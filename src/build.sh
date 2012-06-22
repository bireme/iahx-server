echo 
echo Build iahx-server web archive file   
echo  

if [ "$#" -ne 1 ]
then
   echo Inform version number of the war file  
	   echo Ex: ./build.sh 1.3_02
   echo
   exit
fi

WAR_NAME="iahx-solr-$1".war

jar cvf $WAR_NAME .

#update instances resources folder
cp $WAR_NAME ../instances/1/resources/
cp $WAR_NAME ../instances/2/resources/

rm $WAR_NAME

echo
echo "Build $WAR_NAME created and available on instances directory"
echo 
