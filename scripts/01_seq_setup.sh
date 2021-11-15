#!/bin/bash

# This script is to set up SEQ data on talapas in BIDS (ish) format
# Run 01_seq_setup.sh first, then create TSV files on local computer and transfer to 'bids_data/$SSID/func/' (or figure out a  way to create json files instead)

#SBATCH --account=mayrlab --time=0-2:00:00 --output=logs/01_setup_%j.txt


SSID=$1

WDIR=/projects/mayrlab/shared/SEQ
SCANDIR=/projects/lcni/dcm/mayrlab/Mayr/Sequence
FACEDIR=/projects/mayrlab/shared/deface_templates
BIDSDIR=$WDIR/bids_data

for s in $SSID
do

mkdir -p $BIDSDIR/sub-${s}
mkdir -p $BIDSDIR/sub-${s}/func
mkdir -p $BIDSDIR/sub-${s}/anat
mkdir -p $BIDSDIR/sub-${s}/anat/mri_deface
mkdir -p $BIDSDIR/sub-${s}/beh
mkdir -p $WDIR/raw/sub-${s}

echo "................................................"
echo "Copying the raw data"
cd $SCANDIR
cp -r SEQ${SSID}_*/* $WDIR/raw/sub-${s}


# Functionals

echo "................................................"
echo "Converting each exposure run"
for r in 1 2 3 4 5 6 7 8
do
    cd $WDIR/raw/sub-${s}/
    cd $(find ./ -type d -name "*Run"${r} |sed 1q)
    dcm2niix -b y -z y *
    mv *Run${r}*.nii.gz $BIDSDIR/sub-${s}/func/sub-${s}_run-${r}_bold.nii.gz
    mv *Run${r}*.json $BIDSDIR/sub-${s}/func/sub-${s}_run-${r}_bold.json
done


# Structurals

echo "................................................"
echo "Get the structurals"
cd $WDIR/raw/sub-${s}/
cd $(find ./ -type d -name "*mprage_p2_ND" |sed 1q)
dcm2niix -b y -z y *
mv *mprage_p2_ND*.nii.gz $BIDSDIR/sub-${s}/anat/T1w.nii.gz
mv *mprage_p2_ND*.json $BIDSDIR/sub-${s}/anat/T1w.json

echo "................................................"
echo "De-identify MPRAGE for public dissemination"
cd $BIDSDIR/sub-${s}/anat/mri_deface T1w.nii.gz $FACEDIR/talairach_mixed_with_skull.gca $FACEDIR/face.gca T1w.nii.gz

done

echo "It worked... I think."