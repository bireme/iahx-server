#!/bin/sh
scriptpath=$0

case $scriptpath in 
 ./*)  SCRIPT_PATH=`pwd`;;
  * )  SCRIPT_PATH=`dirname $scriptpath`
esac

echo "SCRIPT_PATH: $SCRIPT_PATH"

SERVER="-server"
HEAPSIZE="-Xmx1024m"
PERMSIZE="-XX:PermSize=128m -XX:MaxPermSize=256m -XX:+UseParallelGC"


#look for bundled jre
if [ -f $SCRIPT_PATH/../jre/bin/java ]
then
  JAVA_HOME=$SCRIPT_PATH/../jre
  JVM=$JAVA_HOME/../jre/bin/java
else
  JVM=java
  #does the jvm support -server?
  $JVM -server -version > /dev/null 2>&1
  if [ $? != "0" ]; then
    SERVER=""
  fi
fi

JAVA_OPTS="$SERVER $HEAPSIZE $PERMSIZE" 
export JAVA_OPTS JAVA_HOME
export CATALINA_PID=${SCRIPT_PATH}/../instances/1/iahx-server.pid

cd ${SCRIPT_PATH}/../instances/1

${SCRIPT_PATH}/../instances/1/bin/catalina.sh $@

cd -
