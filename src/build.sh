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

WAR_NAME="iahx-server-$1".war

jar cvf $WAR_NAME .

mv $WAR_NAME ../resources/

echo
echo "Build $WAR_NAME created and available on ../resources directory"
echo 
