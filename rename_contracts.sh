#!/bin/bash

for name in  $(find . -depth -type d -name 'contract*');  
 do   
    foldername=$(basename "$name")
    pathname=${name%$foldername}
    newname=agreement"$(echo "$foldername" | cut -c9-)"; 
    newfullname="$pathname$newname"
    mv "$name" "$newfullname"
done


