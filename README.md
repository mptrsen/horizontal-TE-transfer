# Horizontal transfer of unclassified TEs in insects

## Helper scripts and other tools:

### fetch-families-from-repeatmodeler-consensi.pl

Reads a `consensi.fa.classified` file from RepeatModeler, fetches the sequences
from the corresponding RM output directory, makes a multiple sequence alignment
for each family, and constructs a HMM for each family for future searching.

### make-hmms-for-rmodeler-results.sh

Calls the script `fetch-families-from-repeatmodeler-consensi.pl` for each entry
in the input table. The input table must have two whitespace-separated columns
(I usually use a tab):

	Drosophila_melanogaster /home/mpetersen/data/repeats/repeatmodeler/ncbi/dmela/RM_26226.TueDec230307382014
	#Drosophila_miranda     /home/mpetersen/data/repeats/repeatmodeler/ncbi/dmira/RM_17510.TueDec231330262014

Entries starting with a `#` are commented out, i.e., will be skipped. The
script proceeds to create the output directory and takes care of everything.

### make-hmms-and-search-everything.sh

Sources the two files `rm2hmm.sh` and `hmmsearch-all-genomes.sh` to form a
full-fledged analysis pipeline: It uses the above-mentioned Perl script
`fetch-families-from-repeatmodeler-consensi` to construct HMMs for the TE
families, concatenates them into one big HMM database and then proceeds to
search all genome assemblies with that database.

Dependencies:

* `rm2hmm.sh`
* `hmmsearch-all-genomes.sh`
