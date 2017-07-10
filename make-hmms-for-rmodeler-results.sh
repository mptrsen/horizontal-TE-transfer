#!/bin/bash

set -e
set -o pipefail

N=$(grep -c -v '^#' doc/repeatmodeler-dirs.txt)

declare -i i=0

grep -v '^#' doc/repeatmodeler-dirs.txt | while read SPECIES DIR; do
	let i=$i+1
	NSEQS=$(grep -c '>' $DIR/consensi.fa.classified)
	echo "# Making HMMS for $SPECIES ($i/$N, $NSEQS seqs)"
	mkdir -p results/hmms/$SPECIES
	perl code/fetch-families-from-repeatmodeler-consensi.pl --ncpu 7 --outdir results/hmms/$SPECIES --rmdir $DIR > results/hmms/$SPECIES.log
	cat results/hmms/$SPECIES/*.hmm > results/hmms/$SPECIES.hmm
	rm -f results/hmms/$SPECIES/*.afa
done
echo "# All done"
