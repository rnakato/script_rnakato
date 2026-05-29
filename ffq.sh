for id in
do
    id=SRR11857894
    echo $id
    ffq $id > $id
    name=`getfilename_fromjson.py $id.json $id name`
    sp=`getfilename_fromjson.py $id.json $id species`
    #    echo -e "$id\t$name\t$sp" > $id.filename
    echo -e "$name" > $id.filename
done
