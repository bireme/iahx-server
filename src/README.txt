Update of solr component

- extract apache-solr distribution war file 
  jar -xvf ~/Downloads/apache-solr-3.6.0/dist/apache-solr-3.6.0.war

- copy additional jar files (ex. DeCSAnalyzer) to WEB-INF/lib folder

  cp ~/iahx-analyzer/dist/iahx-analyzer-1.1.jar WEB-INF/lib

- run ./build.sh [version_number] to maker a new war file
