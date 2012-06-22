INDEX=bvs-local

for i in *.xml
do
	echo "Indexing ${i} file"
	../bin/index.sh $i ${INDEX}
done

../bin/commit.sh ${INDEX}