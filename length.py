#!/usr/bin/python


#this script makes a png file of the distribution of contig length



from Bio import SeqIO
import csv

my_seqfile = '/Users/macmanes/tuco29dec11.fa' #starting contig file
my_csv = '/Users/macmanes/Desktop/lgth.csv' #file that contains list of contig lengths

sizes = [len(rec) for rec in SeqIO.parse(my_seqfile, "fasta")]  #get sizes

out = csv.writer(open(my_csv,"w"), delimiter='\n')
out.writerow(sizes) #send sizes to csv
