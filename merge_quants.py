#this is originally from Lisa Cohen as part of ANGUS 2016

#USAGE: python merge_counts.py

import os
from os import path
import pandas as pd


# get txp names as index
listofsamples = os.listdir("dry/")
quants = {}
data = None
for sample in listofsamples:
    if os.path.isdir("dry/"+sample):
        if os.path.isfile("dry/"+sample+"/quant.sf"):
            quant_file = "dry/"+sample+"/quant.sf"
            data=pd.DataFrame.from_csv(quant_file,sep='\t')
            numreads = data['NumReads']
            quants[sample] = numreads

counts = pd.DataFrame.from_dict(quants)
counts.set_index(data.index,inplace=True)
counts.to_csv("counts.csv")
