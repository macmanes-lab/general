================================================ 
Kallisto and Sleuth for REAL SAMPLES
================================================

Kallisto: https://liorpachter.wordpress.com/2015/05/10/near-optimal-rna-seq-quantification-with-kallisto/ and http://pachterlab.github.io/kallisto/starting.html

Sleuth: https://liorpachter.wordpress.com/2015/08/17/a-sleuth-for-rna-seq/


**RUN KALLISTO**: Kallisto can use a genome, but transcriptome is better for this work. See https://twitter.com/PeroMHC/status/633621603759165440 and discussion. 

::

  mkdir -p /mnt/kallisto/results/ && cd /mnt/kallisto
  tmux new -s kallisto

  curl -LO curl -LO curl -LO ftp://ftp.ensembl.org/pub/release-75/fasta/drosophila_melanogaster/cdna/Drosophila_melanogaster.BDGP5.75.cdna.all.fa.gz

  kallisto index -i dros Drosophila_melanogaster.BDGP5.75.cdna.all.fa.gz
  

  samples[1]=ORE_w_r1
  samples[2]=ORE_w_r2
  samples[3]=ORE_sdE3_r1
  samples[4]=ORE_sdE3_r2
  samples[5]=OREf_SAMm_sdE3
  samples[6]=SAM_sdE3_r1
  samples[7]=SAM_sdE3_r2
  samples[8]=SAMf_OREm_sdE3
  samples[9]=OREf_SAMm_w
  samples[10]=SAM_w_r1
  samples[11]=SAM_w_r2
  samples[12]=SAMf_OREm_w
 
 #Trimming:
 
 
  for i in 1 2 3 4 5 6 7 8 9 10 11 12
  do
      sample=${samples[${i}]}
      java -Xmx10g -jar $HOME/Trimmomatic-0.33/trimmomatic-0.33.jar PE \
      -threads 16 -baseout ${sample}.fq \
      /mnt/reads/${sample}_*_R1_001.fastq.gz \
      /mnt/reads/${sample}_*_R2_001.fastq.gz \
      ILLUMINACLIP:$HOME/Trimmomatic-0.33/adapters/TruSeq3-PE.fa:2:30:10 \
      SLIDINGWINDOW:4:10 \
      LEADING:10 \
      TRAILING:10 \
      MINLEN:30
  done

 

  for i in 1 2 3 4 5 6 7 8 9 10 11 12
  do
      sample=${samples[${i}]}
      mkdir -p results/${sample}/kallisto
      kallisto quant -i dros --threads=16 --bootstrap-samples=100 \
      --output-dir=results/${sample}/kallisto \
      /mnt/trimming/${sample}_1P.fq \
      /mnt/trimming/${sample}_2P.fq
  done

**Download data from EC2 to laptop**: Make directory on your laptop.. ``mkdir ~/Downloads/sleuth/`` for the MAC people. 

::

  scp -r -i your.pem ubuntu@ec2-xx-x-xxx-xxx.compute-1.amazonaws.com:/mnt/kallisto/results ~/Downloads/sleuth/


**SETUP EXPERIMENT DETAILS**

::

  nano ~/Downloads/kallisto

  #paste in this stuff

  name condition wt
  OREf_SAMm_w ORE yes
  SAM_w_r1 SAM yes
  SAM_w_r2 SAM yes
  SAMf_OREm_w SAM yes
  ORE_w_r1 ORE yes
  ORE_w_r2 ORE yes
  SAMf_OREm_sd1 SAM no
  SAM_sd1_r2 SAM no
  SAM_sd1_r1 SAM no
  OREf_SAMm_sd1 ORE no
  ORE_sd1_r2 ORE no
  ORE_sd1_r1 ORE no

**LAUNCH SLEUTH**

::
  
  #to Launch into RStudio
  source("http://bioconductor.org/biocLite.R")
  biocLite("rhdf5")
  install.packages('devtools')
  devtools::install_github('pachterlab/sleuth')
  library("sleuth")

  #Change project dir in R

  base_dir <- "~/Downloads/sleuth"
  sample_id <- dir(file.path(base_dir,"results"))
  kal_dirs <- sapply(sample_id, function(id) file.path(base_dir, "results", id, "kallisto"))
  s2c <- read.table(file.path(base_dir,"experiment2.info"), header = TRUE,   stringsAsFactors=FALSE)
  s2c <- dplyr::select(s2c, sample = name, condition)
  mart <- biomaRt::useMart(biomart = "ensembl", dataset = "dmelanogaster_gene_ensembl")
  t2g <- biomaRt::getBM(attributes = c("ensembl_transcript_id", "ensembl_gene_id",
      "external_gene_name"), mart = mart)
  t2g <- dplyr::rename(t2g, target_id = ensembl_transcript_id,
      ens_gene = ensembl_gene_id, ext_gene = external_gene_name)
  so <- sleuth_prep(kal_dirs, s2c, ~ condition, target_mapping = t2g)
  so <- sleuth_fit(so)
  so <- sleuth_test(so, which_beta = 'conditionyes')
  sleuth_live(so)
