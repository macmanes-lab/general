#!/usr/bin/python


#this script makes a png file of the distribution of contig length



from Bio import SeqIO
import csv

sizes = [len(rec) for rec in SeqIO.parse(sys.argv[1], "fasta")]  #get sizes

out = csv.writer(open(sys.argv[2],"w"), delimiter='\n')
out.writerow(sizes) #send sizes to csv
