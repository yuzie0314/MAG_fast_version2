#!/usr/bin/env python
import glob
import argparse
import logging
import re
import os 
import pandas as pd
import matplotlib.pyplot as plt
import json

global data
data = {"names":[], "total_reads":[], "total_bases":[], "q30_rate":[], "duplication":[]}
def main():
    parser = argparse.ArgumentParser(prog=__file__, formatter_class=argparse.ArgumentDefaultsHelpFormatter, description=__doc__)
    parser.add_argument('-fastp',  "--fastp", required=True, help="folder of fastp")
    parser.add_argument('-output',  "--output", required=True, help="folder for fastp stats statistics file")
    parser.add_argument('-v', '--verbose', action='count', default=0, help="Increase verbosity")
    parser.add_argument('-q', '--quiet', action='count', default=0, help="Decrease verbosity")
    args = parser.parse_args()

    logging_level = logging.WARN + 10*args.quiet - 10*args.verbose
    logging.basicConfig(level=logging_level)
    logger = logging.getLogger(__name__)
    logger.debug('args verbose {}:'.format(args.verbose))
    logger.debug('args quiet {}:'.format(args.quiet))
    logger.debug('logging_level {}:'.format(logging_level))
    fns = getfiles(args.fastp)
    [proc_fastp(fn) for fn in fns]
    df = pd.DataFrame.from_dict(data)

    if not os.path.exists(args.output):
         os.makedirs(args.output, exist_ok=True)

    df.to_csv(args.output + "/fastp.stats.csv", index=False)
    #print(df)
    #plot(df)

def getfiles(d):
    fns = glob.glob(d + "/*.fastp.json")
    return fns

def proc_fastp(fn):    
    basename = os.path.basename(fn)
    reResult = re.search("(.*).fastp.json", basename) 
    if reResult:
        sample_name = reResult.group(1)  
        data['names'].append(sample_name)        

    with open(fn, newline='') as jsonfile:
        myjson = json.load(jsonfile)
        total_reads = myjson['summary']['before_filtering']['total_reads']
        data['total_reads'].append(total_reads)
        total_bases = myjson['summary']['before_filtering']['total_bases']
        data['total_bases'].append(total_bases)
        q30_rate = myjson['summary']['before_filtering']['q30_rate']
        data['q30_rate'].append(q30_rate)
        duplication = myjson['duplication']['rate']
        data['duplication'].append(duplication)

def plot(data):
    df = data[['>0x', '>=5x', '>=10x', '>=20x', '>=30x', '>=40x', '>=50x', '>=60x', '>=70x', '>=80x', '>=90x', '>=100x']]
    df.index = data['names']
    df = df.T    
    #print(df)
    line = df.plot.line()
    plt.show()    

if __name__ == '__main__':
    main()