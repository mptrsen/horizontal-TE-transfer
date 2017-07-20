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

SPECIES="${SPECIES:=SPECIES_NAME}" # this really really needs input
RMDIR="${INPUTDIR:=INPUTDIR}"      # this really really needs input

if [[ "$SPECIES" == "SPECIES_NAME" ]]; then 
	die "Input error: SPECIES not supplied (is still 'SPECIES_NAME', you need to change this)"
fi
if [[ "$RMDIR" == "INPUTDIR" ]]; then
	die "Input error: RMDIR not supplied (is still 'INPUTDIR', you need to change this)"
fi

PERL="${PERL:=/opt/perl/bin/perl}"
LINSI="${LINSI:=/share/scientific_bin/mafft/7.309we/bin/linsi}"
HMMBUILD="${HMMBUILD:=/share/scientific_bin/hmmer/3.1b2/bin/hmmbuild}"
HMMSEARCH="${HMMSEARCH:=/share/scientific_bin/hmmer/3.1b2/bin/hmmsearch}"
PREFIX="${PREFIX:=/share/pool/malte/analyses}"
DATABASE="${DATABASE:=$PREFIX/results/hmms/$SPECIES.hmm}"
OUTDIR="${OUTDIR:=$PREFIX/results/hmmsearch/$SPECIES}"
NCPU=$NSLOTS # takes number of CPUs from SGE variable

cd $PREFIX

run mkdir -p "results/hmms/$SPECIES"
echo "## Building HMMs"
run time $PERL code/fetch-families-from-repeatmodeler-consensi.pl \
	--ncpu 7 \
	--species "$SPECIES" \
	--outdir "results/hmms/$SPECIES" \
	--rmdir "$RMDIR" \
	--path-to-linsi "$LINSI" \
	--path-to-hmmbuild "$HMMBUILD" \
	 > "results/hmms/$SPECIES.log"
echo "## Concatenating HMMs"
run bash -c "cat 'results/hmms/$SPECIES'/*.hmm > 'results/hmms/$SPECIES.hmm'"
echo "## Zipping HMMs"
run tar -cjf "hmms-$SPECIES.tar.bz2" "results/hmms/$SPECIES"/*.hmm "results/hmms/$SPECIES.log"
echo "## Cleaning up"
run rm -rf "results/hmms/$SPECIES" "results/hmms/$SPECIES.log"
echo "## Done"
echo "## SHA256 checksum:"
run sha256sum "hmms-$SPECIES.tar.bz2"
