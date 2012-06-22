#!/bin/sh
scriptpath=$0
case $scriptpath in 
 ./*)  SCRIPT_PATH=`pwd` ;;
  * )  SCRIPT_PATH=`dirname $scriptpath`
esac

SOLR_HOME=$SCRIPT_PATH/../indexes/bvs/local/


#look for bundled jre
if [ -f $SCRIPT_PATH/../jre/bin/java ]
then
  JVM=$SCRIPT_PATH/../jre/bin/java
else
  JVM=java
fi

ARGS=${@:--index "$SOLR_HOME/data/index/" -ro}
echo $ARGS

exec $JVM -jar lukeall.jar $ARGS

