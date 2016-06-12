#!/usr/bin/env bash
# Example pRESTO pipeline for Stranded MiSeq 2x250 data.
# Data from Greiff et al, 2014, BMC Immunol.
# 
# Author:  Jason Anthony Vander Heiden
# Date:    2016.03.04

# Define run parameters and input files
R1_FILE=$(readlink -f ERR346600_1.fastq)
R2_FILE=$(readlink -f ERR346600_2.fastq)
R1_PRIMERS=$(readlink -f Greiff2014_CPrimers.fasta)
R2_PRIMERS=$(readlink -f Greiff2014_VPrimers.fasta)
OUTDIR="output"
OUTNAME="M1"
NPROC=4
PIPELINE_LOG="Pipeline.log"
ZIP_FILES=true

# Make output directory and empty log files
mkdir -p $OUTDIR; cd $OUTDIR
echo '' > $PIPELINE_LOG

# Start
echo "OUTPUT DIRECTORY: ${OUTDIR}"
echo -e "START"
STEP=0

# Assemble paired ends via mate-pair alignment
printf "  %2d: %-*s $(date +'%H:%M %D')\n" $((++STEP)) 24 "AssemblePairs align"
AssemblePairs.py align -1 $R2_FILE -2 $R1_FILE --coord sra --rc tail \
	--outname $OUTNAME --outdir . --log AP.log --nproc $NPROC >> $PIPELINE_LOG

# Remove low quality reads
printf "  %2d: %-*s $(date +'%H:%M %D')\n" $((++STEP)) 24 "FilterSeq quality"
FilterSeq.py quality -s "${OUTNAME}_assemble-pass.fastq" -q 20 \
	--outname $OUTNAME --log FS.log --nproc $NPROC >> $PIPELINE_LOG

# Identify forward and reverse primers
printf "  %2d: %-*s $(date +'%H:%M %D')\n" $((++STEP)) 24 "MaskPrimers score"
MaskPrimers.py score -s "${OUTNAME}_quality-pass.fastq" -p $R2_PRIMERS \
	--mode mask --start 4 --outname "${OUTNAME}-FWD" --log MPV.log \
	--nproc $NPROC >> $PIPELINE_LOG
MaskPrimers.py score -s "${OUTNAME}-FWD_primers-pass.fastq" -p $R1_PRIMERS \
	--mode cut --start 4 --revpr --outname "${OUTNAME}-REV" --log MPC.log \
	--nproc $NPROC >> $PIPELINE_LOG

# Expand primer field
printf "  %2d: %-*s $(date +'%H:%M %D')\n" $((++STEP)) 24 "ParseHeaders expand"
ParseHeaders.py expand -s "${OUTNAME}-REV_primers-pass.fastq" \
    -f PRIMER >> $PIPELINE_LOG

# Rename primer fields
printf "  %2d: %-*s $(date +'%H:%M %D')\n" $((++STEP)) 24 "ParseHeaders rename"
ParseHeaders.py rename -s "${OUTNAME}-REV_primers-pass_reheader.fastq" \
    -f PRIMER1 PRIMER2 -k VPRIMER CPRIMER --outname $OUTNAME >> $PIPELINE_LOG
	
# Remove duplicate sequences
printf "  %2d: %-*s $(date +'%H:%M %D')\n" $((++STEP)) 24 "CollapseSeq"
CollapseSeq.py -s "${OUTNAME}_reheader.fastq" -n 20 \
	--uf CPRIMER --cf VPRIMER --act set --inner \
	--outname $OUTNAME >> $PIPELINE_LOG

# Subset to sequences observed at least twice
printf "  %2d: %-*s $(date +'%H:%M %D')\n" $((++STEP)) 24 "SplitSeq group"
SplitSeq.py group -s "${OUTNAME}_collapse-unique.fastq" -f DUPCOUNT --num 2 \
	--outname $OUTNAME >> $PIPELINE_LOG

# Create annotation table of final unique sequences
printf "  %2d: %-*s $(date +'%H:%M %D')\n" $((++STEP)) 24 "ParseHeaders table"
ParseHeaders.py table -s "${OUTNAME}_atleast-2.fastq" \
    -f ID DUPCOUNT CPRIMER VPRIMER >> $PIPELINE_LOG

# Process log files
printf "  %2d: %-*s $(date +'%H:%M %D')\n" $((++STEP)) 24 "ParseLog"
ParseLog.py -l AP.log -f ID LENGTH OVERLAP ERROR PVALUE > /dev/null &
ParseLog.py -l FS.log -f ID QUALITY > /dev/null &
ParseLog.py -l MP[VC].log -f ID PRIMER ERROR > /dev/null &
wait

# Zip intermediate and log files
if $ZIP_FILES; then
    LOG_FILES_ZIP=$(ls AP.log FS.log MP[VC].log)
    tar -zcf LogFiles.tar.gz $LOG_FILES_ZIP
    rm $LOG_FILES_ZIP

    TEMP_FILES_ZIP=$(ls *.fastq | grep -vP "collapse-unique.fastq|atleast-2.fastq")
    tar -zcf TempFiles.tar.gz $TEMP_FILES_ZIP
    rm $TEMP_FILES_ZIP
fi

# End
printf "DONE\n\n"
cd ../
