#!/usr/bin/python

from __future__ import division
from Bio.Phylo.PAML import codeml
import sys
import os
import shutil
import time
from math import sqrt
from rpy2 import robjects

def compare_models(m1_lnl, m2_lnl, df):
    likelihood = 2*(abs(m2_lnl-m1_lnl))
    p = 1 - robjects.r.pchisq(likelihood, df)[0]
    return p

results = codeml.read(sys.argv[1])
nssites = results.get("NSsites")
m1 = nssites.get(1)
m1_lnl = m1.get("lnL")
nssites = results.get("NSsites")
m2 = nssites.get(2)
m2_lnl = m2.get("lnL")
nssites = results.get("NSsites")
m7 = nssites.get(7)
m7_lnl = m7.get("lnL")
nssites = results.get("NSsites")
m8 = nssites.get(8)
m8_lnl = m8.get("lnL")
m2_p_pos = compare_models(m1_lnl,m2_lnl,2)
m8_p_pos = compare_models(m7_lnl,m8_lnl,2)

print 'M1vM2_p-value {} {}'.format(sys.argv[1], m2_p_pos)
print 'M7vM8_p-value {} {}'.format(sys.argv[1], m8_p_pos)
