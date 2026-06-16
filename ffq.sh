mkdir -p ffq

for id in
do
    id=SRR11857894
    echo $id
    ffq $id > ffq/$id.json
    name=`getfilename_fromjson.py ffq/$id.json $id name`
    sp=`getfilename_fromjson.py ffq/$id.json $id species`
    #    echo -e "$id\t$name\t$sp" > $id.filename
    echo -e "$name" > ffq/$id.filename
done
