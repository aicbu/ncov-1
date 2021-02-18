"""
Mask initial bases from alignment FASTA
"""
import argparse
from random import shuffle
from collections import defaultdict
import numpy as np


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="generate priorities files based on genetic proximity to focal sample",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument("--sequence-index", type=str, required=True, help="sequence index file")
    parser.add_argument("--proximities", type = str, required=True, help="tsv file with proximities")
    parser.add_argument("--Nweight", type = float, default=0.003, required=False, help="parameterizes de-prioritization of incomplete sequences")
    parser.add_argument("--crowding-penalty", type = float, default=0.05, required=False, help="parameterizes how priorities decrease when there is many very similar sequences")
    parser.add_argument("--output", type=str, required=True, help="tsv file with the priorities")
    args = parser.parse_args()

    proximities = pd.read_csv(args.proximities, sep='\t', index_col=0)
    index = pd.read_csv(args.sequence_index, sep='\t', index_col=0)
    d = pd.concat([proximities, index], axis=1)

    closest_matches = d.groupBy('closest strain')
    candidates = {}
    for focal_seq, seqs in closest_matches.groups.items():
        tmp = p1.loc[seqs, ["distance", "Ns"]]
        tmp.priority = -tmp.distance + tmp.Ns*Nweight
        candidates[focal_seq] = sorted(shuffle([(name, d.proximity) for name, d in tmp.iterrows()]), key:lambda x:x[1])

    # export priorities
    crowding = args.crowding_penalty
    with open(args.output, 'w') as fh:
        for cs in candidates.values():
            for i, (name, pr) in enumerate(cs):
                fh.write(f"{name}\t{pr+i*crowding:1.2f}\n")
