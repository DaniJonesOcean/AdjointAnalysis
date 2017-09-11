#!/bin/sh

# Find record number from a tmp file
FNAMES=(adxx_*.tmp.0000000012.meta)
#echo $FNAMES
recnum="$(grep -r nrecords ${FNAMES[0]} | grep -o '[0-9]\+')"
#echo 'Using nrecords = '$recnum

# Find all meta files 
FNAMES=('adxx_*.0000000012.meta')

re='^[0-9]+$'

# Replace 1 with recnum in all meta files
if [[ $recnum =~ $re ]]; then
    echo 'Replacing nrecords with '$recnum

    for filename in ${FNAMES[@]}
    do
	echo $filename
	sed -i -e "/nrecords/s/\s1\s]/ $recnum ]/" $filename 
    done
else
    echo 'nrecord not a number'
fi


