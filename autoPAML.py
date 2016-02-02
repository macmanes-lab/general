#!/usr/bin/python

#usage  python autoPAML.py alignment.fasta tree.nexus paml.output

from __future__ import division
from Bio.Phylo.PAML import codeml ##Biopython PAML
import sys

if len(sys.argv) != 4:
        print "Error.  There should be three inputs. An alignment in fasta format, a tree file, and the name for the output file"
        quit()

cml = codeml.Codeml()
cml.read_ctl_file("codeml.ctl")
cml.alignment = sys.argv[1]
cml.tree = sys.argv[2]
cml.out_file = sys.argv[3]

name=sys.argv[1]
print name

cml.run()
