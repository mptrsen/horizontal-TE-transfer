set -e
set -o pipefail

# this script cannot run on its own; it needs a wrapper script
# (make-hmms-and-search-everything.sh) to supply the global variables listed
# below. It also requires the functions 'die' and 'run'.

# make sure this file is sourced
if [[ "$0" == "$BASH_SOURCE" ]]; then
	echo 'Error: must be sourced from wrapper script!'
	exit 1
fi

# parameter expansion: ${param:=word} assigns a default value if parameter is
# unset or null. this is used in case somebody should actually run this script
# without its parent wrapper.

SPECIES="${SPECIES:=SPECIES_NAME}" # only this really really requires setting

if [[ "$SPECIES" == "SPECIES_NAME" ]]; then 
	die "Input error: SPECIES not supplied (is still 'SPECIES_NAME', you need to change this)"
fi

PREFIX="${PREFIX:=/share/pool/malte/analyses}"
HMMSEARCH="${HMMSEARCH:=/share/scientific_bin/hmmer/3.1b2/bin/hmmsearch}"
DATABASE="${DATABASE:=$PREFIX/results/hmms/$SPECIES.hmm}"
OUTDIR="${OUTDIR:=$PREFIX/results/hmmsearch/$SPECIES}"
NCPU=$NSLOTS # takes number of CPUs from SGE variable

if [[ ! -s "$DATABASE" ]]; then
	die "Error: HMM database not found or empty: '$DATABASE'"
fi

echo "## Searching"

cd $PREFIX

run mkdir -p $OUTDIR
for TARGET_ASSEMBLY in "$PREFIX"/data/genomes/species/*/genome/assembly/*.fa; do
        TARGET_SPECIES=$(basename "$TARGET_ASSEMBLY" .fa)
        echo "### Searching $TARGET_SPECIES (started $(date --rfc-3339=seconds))"
        run time $HMMSEARCH \
                --cpu $NCPU \
                --tblout "$OUTDIR/$SPECIES-vs-$TARGET_SPECIES.tbl" \
                --domtblout "$OUTDIR/$SPECIES-vs-$TARGET_SPECIES.domtbl" \
                -o "$OUTDIR/$SPECIES-vs-$TARGET_SPECIES.out" \
                "$DATABASE" "$TARGET_ASSEMBLY"
done

echo "## Zipping results"
run tar -cjf "hmmsearch-$SPECIES.tar.bz2" "$OUTDIR"

echo "## Cleaning up"
run rm -rf "$OUTDIR"

echo "## SHA256 checksum"
run sha256 "hmmsearch-$SPECIES.tar.bz2"
