#!/bin/bash
#$ -cwd
#$ -j y
#$ -S /bin/bash
#$ -M mptrsen@uni-bonn.de
#$ -m be
#$ -N rm2hmm-SPECIES_NAME

set -e
set -o pipefail

# parameter expansion: ${param:=word} assigns a default value if parameter is
# unset or null. 

SPECIES="${SPECIES:=SPECIES_NAME}" # this really really needs input
RMDIR="${RMDIR:=INPUTDIR}"      # this really really needs input
PREFIX="${PREFIX:=/share/pool/malte/analyses}"

# for the functions 'die' and 'run'
source ~/.bash_functions

if [[ "$SPECIES" == "SPECIES_NAME" ]]; then 
	die "Input error: SPECIES not supplied (is still '$SPECIES', you need to change this)"
fi
if [[ "$RMDIR" == "INPUTDIR" ]]; then
	die "Input error: RMDIR not supplied (is still '$RMDIR', you need to change this)"
fi

PERL="${PERL:=/opt/perl/bin/perl}"
LINSI="${LINSI:=/share/scientific_bin/mafft/7.309we/bin/linsi}"
HMMBUILD="${HMMBUILD:=/share/scientific_bin/hmmer/3.1b2/bin/hmmbuild}"
HMMSEARCH="${HMMSEARCH:=/share/scientific_bin/hmmer/3.1b2/bin/hmmsearch}"
DATABASE="${DATABASE:=$PREFIX/results/hmms/$SPECIES.hmm}"
OUTDIR="${OUTDIR:=$PREFIX/results/hmmsearch/$SPECIES}"
NCPU=$NSLOTS # takes number of CPUs from SGE variable
MAKE_HMMS=1
SEARCH_ALL=1
DRY_RUN=1

cd $PREFIX

if [[ $MAKE_HMMS -ne 0 ]]; then
	echo "-------------------------"
	echo "# Start part 1: HMM construction for $SPECIES"
	echo "-------------------------"

	# make HMMs
	source code/job-scripts/rm2hmm.sh

fi

if [[ $SEARCH_ALL -ne 0 ]]; then
	echo "-------------------------"
	echo "# Start part 2: HMM search for $SPECIES"
	echo "-------------------------"

	# search everything
	source code/job-scripts/hmmsearch-all-genomes.sh

fi

echo "# All done"
echo "-------------------------"
echo "### use this command to transfer the files from lore to your current directory:"
echo "scp lore:$(pwd)/hmms*-$SPECIES.tar.bz2 ./"
