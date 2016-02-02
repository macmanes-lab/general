#! /bin/bash

usage=$(cat << EOF
   # This script runs a pipeline that takes a fasta file and BAMfiles and tests for selection:
   #

   align.sh [options]
   Options:
      -t <v> : *required* Numberof threads to use.
EOF
);


while getopts f:b:o:t: option
do
        case "${option}"
        in
		t) TC=${OPTARG};;
        esac
done



##Align
END=$(ls | wc -l | awk '{print $1}')
START=1
i=`ps -all | grep java | wc -l`


for inputaln in $(ls *fasta); do
    F=`basename $inputaln .fasta`;
    if [ $i -lt $TC ] ;
    then
        echo 'I have a core to use'
        java -Xmx2000m -jar /share/bin/macse_v1.01b.jar -prog alignSequences -seq $inputaln -out_NT $F.aln &
    else
        echo 'Dont wake me up until there is something else to do'
        sleep 25s
    fi
done
