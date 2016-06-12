Used publicly available data from:

    | **Quantitative assessment of the robustness of next-generation sequencing
      of antibody variable gene repertoires from immunized mice.**
    | Greiff, V. et al.
    | *BMC Immunol. 2014. 15(1):40. doi:10.1186/s12865-014-0040-5.*

Which may be downloaded from the EBI European Nucleotide Archive under
accession ID: ERP003950. For this example, the first 25,000
sequences of sample Replicate-1-M1 (accession: ERR346600) were used, which may
downloaded using fastq-dump.

    fastq-dump --split-files -X 25000 ERR346600

Primers sequences are available in additional file 1 of the publication and included here.

M1_atleast-2.fasta was used as input to HighVQuest. 

Mouse reference sequences are included as IMGT_MOUSE_IGH[VDJ].fasta files.

ChangeO commands used:
MakeDb.py imgt -i Greiff2014.txz -s /home/ian/NextGenSeq/Greiff2014/output/M1_atleast-2.fasta --regions --scores
ParseDb.py select -d Greiff2014_db-pass.tab -f FUNCTIONAL -u T
ParseDb.py fasta -d Greiff2014_db-pass_parse-select.tab --if SEQUENCE_ID --sf SEQUENCE_IMGT --mf V_CALL DUPCOUNT
DefineClones.py bygroup -d Greiff2014_db-pass_parse-select.tab --act set --model m1n --sym min --norm len --dist 0.25
CreateGermlines.py -d ./HighVQuestOutput/Greiff2014_db-pass_parse-select_clone-pass.tab -r IMGT_MOUSE_IGH[VDJ].fasta -g dmask --cloned
