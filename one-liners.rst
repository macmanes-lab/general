===============
UNIX WIZARDRY
===============

The explicit goal of this tutorial is to provide you with some tricks and tools and to make your unix life happier. 

|

**LAUNCH AN INSTANCE**: Get something small, for instance ``t2.small`` and update it.

::

  sudo apt-get update && apt-get -y upgrade
  sudo apt-get install libncurses5-dev build-essential tmux git gcc make g++ python-dev unzip default-jre zlib1g-dev

**ALIASES**: These are 'shortcuts' for make doing stuff more efficient.

::

  alias c='clear'
  alias gh='history | grep'
  alias ll='logout'
  alias l='ls -lth'
  alias mv='mv -i'
  alias cp='cp -i' 
  alias targz='tar -zcf'
  alias utargz='tar -zxf'

**INSTALL TRINITY**

::

  git clone https://github.com/trinityrnaseq/trinityrnaseq.git
  cd trinityrnaseq
  make -j4
  PATH=$PATH:$(pwd)

**.profile customization**

::

  nano ~/.profile

**DOWNLOAD SOME DATA**

::

  mkdir /home/ubuntu/data
  cd /home/ubuntu/data
  curl -LO https://www.dropbox.com/s/5fymuyb1f2l8kfj/ngsfile.tar.gz?
  utargz ngsfile.tar.gz


**Find a file**

::

  cd $HOME
  find / -name Trinity.fasta
  find / -type f -size +10M 2> /dev/null

**sed**

::

  cd ngs2015/
  less Trinity.fasta
  sed 's_|_-_g' Trinity.fasta | grep ^'>' | head
  sed -i 's_|_-_g' Trinity.fasta
  

**awk**

::

  less Trinity.counts.RNAseq.txt
  awk '{print $1 "\t" $2}' Trinity.counts.RNAseq.txt | head
  awk '$1 == "c996_g1_i1"' Trinity.counts.RNAseq.txt


========================
SAMTOOLS
========================

Let's learn something about samtools

**INSTALL**

::

  cd $HOME
  git clone https://github.com/samtools/htslib.git
  cd htslib && make -j4 && cd ../
  git clone https://github.com/samtools/samtools.git
  cd samtools && make -j4 && PATH=$PATH:$(pwd) && cd ../


**EXPLORE**

::

  cd $HOME/ngs2015/
  
  samtools sort ngs.bam -o test.sort.bam -O bam -T temp
  
  samtools index test.sort.bam
  
  samtools idxstats test.sort.bam | less
  
  samtools bam2fq -s se.fq --reference Trinity.fasta test.sort.bam > from.bam.fastq
  
  samtools depth -a test.sort.bam | grep 'TR1|c0_g1_i1' | less
  samtools depth -a test.sort.bam | awk '$1 == "TR1|c0_g1_i1"' | less

  samtools flagstat test.sort.bam
  
  samtools view -h test.sort.bam > test.sort.sam
  
  samtools view -hs 0.1 test.sort.bam > test.subsamp.sam

========================
TERMINATE YOUR INSTANCE
========================
