#!/bin/bash
#$ -cwd
#$ -j y
#$ -S /bin/bash
#$ -M mptrsen@uni-bonn.de
#$ -m be
#$ -N rm2hmm-SPECIES_NAME

set -e
set -o pipefail

# these variables must be set; everything else is derived from them
SPECIES="SPECIES_NAME" # this really really needs input
RMDIR="INPUTDIR"       # this really really needs input
PREFIX="/share/pool/malte/analyses" # set this too

# for the functions 'die' and 'run'
source ~/.bash_functions

PERL="${PERL:=/opt/perl/bin/perl}"
LINSI="${LINSI:=/share/scientific_bin/mafft/7.309we/bin/linsi}"
HMMBUILD="${HMMBUILD:=/share/scientific_bin/hmmer/3.1b2/bin/hmmbuild}"
HMMSEARCH="${HMMSEARCH:=/share/scientific_bin/hmmer/3.1b2/bin/hmmsearch}"
DATABASE="${DATABASE:=$PREFIX/results/hmms/$SPECIES.hmm}"
OUTDIR="${OUTDIR:=$PREFIX/results/hmmsearch/$SPECIES}"
NCPU=${NSLOTS:=1} # takes number of CPUs from SGE variable or defaults to 1
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
