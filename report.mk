#!/usr/bin/make -rRsf


# ./report.mk ASSEMBLY=test.fasta READ1=1.subsamp_1.cor.fq READ2=1.subsamp_2.cor.fq LINEAGE=eukaryota

SHELL=/bin/bash -o pipefail

MAKEDIR := $(dir $(firstword $(MAKEFILE_LIST)))
DIR := ${CURDIR}
BUSCO ?= ${shell which BUSCO_v1.1b1.py}
BUSCODIR := $(dir $(firstword $(BUSCO)))
CPU=16
ASSEMBLY=
READ1=
READ2=
LINEAGE=
BUSCOUT := BUSCO_$(basename ${ASSEMBLY} .fasta)

all:busco.done transrate.done report
busco:busco.done
transrate:transrate.done

.DELETE_ON_ERROR:
.PHONY:report

busco.done:${ASSEMBLY}
        python3 ${BUSCODIR}BUSCO_v1.1b1.py -in ${ASSEMBLY} -m trans --cpu $(CPU) -l ${BUSCODIR}${LINEAGE} -o ${BUSCOUT} 2> /dev/null
        touch busco.done

transrate.done:${ASSEMBLY}
        transrate -o transrate_${basename ${ASSEMBLY} .fasta}  -a ${ASSEMBLY} --left ${READ1} --right ${READ2} -t $(CPU)
        touch transrate.done

report:
        printf "\n\n*****  QUALITY REPORT FOR: ${ASSEMBLY} **** \n\n"
        printf "*****  BUSCO SCORE ~~~~~>           " | tee qualreport.${basename ${ASSEMBLY} .fasta}
        cat $$(find run_${BUSCOUT} -name short*) | sed -n 5p  | tee -a qualreport.${basename ${ASSEMBLY} .fasta}
        printf "*****  TRANSRATE SCORE ~~~~~>           " | tee -a qualreport.${basename ${ASSEMBLY} .fasta}
        cat $$(find transrate_${basename ${ASSEMBLY} .fasta} -name assemblies.csv) | awk -F , '{print $$41}' | sed -n 2p | tee -a qualreport.${basename ${ASSEMBLY} .fasta}
        printf "*****  TRANSRATE OPTIMAL SCORE ~~~~~>   " | tee -a qualreport.${basename ${ASSEMBLY} .fasta}
        cat $$(find transrate_${basename ${ASSEMBLY} .fasta} -name assemblies.csv) | awk -F , '{print $$42}' | sed -n 2p | tee -a qualreport.${basename ${ASSEMBLY} .fasta}
        printf " \n\n"
