#!/bin/bash

set -e
set -o pipefail

if [[ $# -ne 1 ]]; then echo "Usage: $0 TABLE"; exit 1; fi

INPUT_TABLE=$1

N=$(grep -c -v '^#' $INPUT_TABLE)

declare -i i=0

grep -v '^#' $INPUT_TABLE | while read SPECIES DIR; do
	let i=$i+1
	NSEQS=$(grep -c '>' $DIR/consensi.fa.classified)
	echo "# Making HMMS for '$SPECIES' ($i/$N, $NSEQS seqs)"
	mkdir -p results/hmms/$SPECIES
	perl code/fetch-families-from-repeatmodeler-consensi.pl --ncpu 7 --outdir results/hmms/$SPECIES --rmdir $DIR > results/hmms/$SPECIES.log
	cat results/hmms/$SPECIES/*.hmm > results/hmms/$SPECIES.hmm
	rm -f results/hmms/$SPECIES/*.afa
done
echo "# All done"
