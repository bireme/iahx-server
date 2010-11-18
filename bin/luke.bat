cd %0\..\
set JVM=java
IF EXIST ..\jre\bin\java.exe SET JVM=..\jre\bin\java

IF "%1"=="" GOTO NOARGS
%JVM% -jar lukeall.jar %*
GOTO DONE
:NOARGS
%JVM% -jar lukeall.jar -index solr/data/index -ro

:DONE
::SET /P M=Press ENTER: 

