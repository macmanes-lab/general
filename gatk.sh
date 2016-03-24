#! /bin/bash


####USAGE####
#
# ./gatk.sh -t 8 -r SRR9236492
# 
#  This script will take in the read file in gz format, and output a indel-realigned BAM file, named realigned.SRR080896.bam
#
# -t for the number of threads you want to use
#
# -s for the ID of the sample

####SETUP INSTANCE

# sudo apt-get update
# sudo apt-get upgrade
# sudo apt-get -y install hmmer cmake tmux git curl bowtie libncurses5-dev samtools gcc make ncbi-blast+ g++ python-dev libboost-iostreams-dev libboost-system-dev libboost-filesystem-dev unzip
# sudo add-apt-repository ppa:webupd8team/java
# sudo apt-get update
# sudo apt-get install oracle-java8-installer
#
# cd $HOME
# curl -LO https://github.com/broadinstitute/picard/releases/download/2.1.0/picard-tools-2.1.0.zip
# unzip picard-tools-2.1.0.zip
#
#
## ftp://ftp.broadinstitute.org/bundle/hg38/hg38bundle/
#






if [[ "$1" =~ ^((-{1,2})([Hh]$|[Hh][Ee][Ll][Pp])|)$ ]]; then
   print_usage; exit 1
else
   while [[ $# -gt 0 ]]; do
    opt="$1"
    shift;
    current_arg="$1"
    if [[ "$current_arg" =~ ^-{1,2}.* ]]; then
       echo "WARNING: You may have left an argument blank. Double check your command."
    fi
    case "$opt" in
       "-s"|"--sample"      ) SAMPLE="$1"; shift;;
       "-t"|"--threads"     ) TC="$1"; shift;;
       *                   ) echo "ERROR: Invalid option: \""$opt"\"" >&2
                             exit 1;;
    esac
  done
fi

if [[ "$SAMPLE" == "" ]]; then
  echo "ERROR: Options -s requires an argument." >&2
  exit 1
fi

#### MAIN RUN!!!

if [ -s Homo_sapiens_assembly38.fasta ] ;
then
    echo "I have te reference fastA"
else
    curl -LO ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/hg38/hg38bundle/Homo_sapiens_assembly38.fasta.gz
    gzip -d Homo_sapiens_assembly38.fasta.gz
fi

if [ -s Homo_sapiens_assembly38.dict ] ;
then
    echo "I have the dict file"
else
    curl -LO ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/hg38/hg38bundle/Homo_sapiens_assembly38.dict
fi

if [ -s Homo_sapiens_assembly38.known_indels.vcf ] ;
then
    echo "I have the vcf file"
else
    curl -LO ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/hg38/hg38bundle/Homo_sapiens_assembly38.known_indels.vcf.gz
    gzip -d Homo_sapiens_assembly38.known_indels.vcf.gz
fi

if [ -s Homo_sapiens_assembly38.fasta.fai ] ;
then
    echo "done with faidx"
else
    samtools faidx Homo_sapiens_assembly38.fasta
fi

if [ -s hg38.sa ] ;
then
    echo "done making index"
else
    bwa index -p hg38 Homo_sapiens_assembly38.fasta
fi

bwa mem hg38 -t "${TC}" "${SAMPLE}"_1.fastq.gz "${SAMPLE}"_2.fastq.gz | samtools view -@4 -Sb - | samtools sort -m1G -@4 - "${SAMPLE}"

java -jar "$HOME"/picard-tools-2.1.0/picard.jar MarkDuplicates \
    I="${SAMPLE}".bam \
    O=mark_dups."${SAMPLE}".bam \
    M=mark_dups_"${SAMPLE}".metrics.txt


java -jar "$HOME"/picard-tools-2.1.0/picard.jar AddOrReplaceReadGroups \
      I=mark_dups."${SAMPLE}".bam \
      O=RG.mark_dups."${SAMPLE}".bam \
      RGID="${SAMPLE}" \
      RGLB=lib"${SAMPLE}" \
      RGPL=illumina \
      RGPU=unit1 \
      RGSM="${SAMPLE}"

#### Index BAM


samtools index RG.mark_dups."${SAMPLE}".bam


#### Indel Realign

java -jar "$HOME"/GenomeAnalysisTK.jar \
    -T RealignerTargetCreator \
    -R Homo_sapiens_assembly38.fasta \
    -I RG.mark_dups."${SAMPLE}".bam \
    -known Homo_sapiens_assembly38.known_indels.vcf \
    -o realignment_targets.RG.mark_dups."${SAMPLE}".list


java -jar "$HOME"/GenomeAnalysisTK.jar \
-T IndelRealigner \
-R Homo_sapiens_assembly38.fasta \
-I RG.mark_dups."${SAMPLE}".bam \
-targetIntervals realignment_targets.RG.mark_dups."${SAMPLE}".list \
-o realigned."${SAMPLE}".bam
