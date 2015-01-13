#!/bin/bash


usage=$(cat << EOF
   # This script runs a pipeline that takes a fasta file and BAMfiles and tests for selection:

   crb_genes.sh [options]

   Options:
      -f <v> : *required* Specify the FASTA file.
      -n <v> : *required* The name of the gene.
      -t <v> : *required* Number of threads to use.
EOF
);


while getopts f:n:t: option
do
    case "${option}"
    in
        f) FA=${OPTARG};;
        n) NA=${OPTARG};;
        t) TC=${OPTARG};;
    esac
done




for i in $(ls /home/macmanes/coral/prot_data/*prot); do F=$(basename $i .prot); \
crb-blast --query $FA --target $i --threads $TC --output $F.crb; done

for i in $(ls *crb); do awk '{print $2}' $i >> list; done

for i in $(ls /home/macmanes/coral/prot_data/*prot); do grep -A1 --max-count=1 -w -f list $i >> $NA.prot; done

rm *psq *pin *phr
