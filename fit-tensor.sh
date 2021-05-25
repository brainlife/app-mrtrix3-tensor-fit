#!/bin/bash

#### CODE COPIED FROM APP-MRTRIX3-ACT. Written by Brent McPherson (bcmcpher@iu.edu)

## define number of threads to use
NCORE=8

#number of max seconds to run tckgen.
#sometime tckgen gets stuck running for hours.. with no hope of finding enough fiber.
#we don't want to waste computing hours when this happen as this App has a long walltime (36 hours)
TCKGEN_TIMEOUT=7200

## export more log messages
set -x
set -e

##
## parse inputs
##

## raw inputs
DIFF=`jq -r '.diff' config.json`
BVAL=`jq -r '.bval' config.json`
BVEC=`jq -r '.bvec' config.json`
ANAT=`jq -r '.anat' config.json`
MASK=`jq -r '.mask' config.json`

## models to fit / data sets to make
TENSOR_FIT=`jq -r '.tensor_fit' config.json`

## perform multi-tissue intensity normalization
NORM=`jq -r '.norm' config.json`

##
## begin execution
##

## working directory labels
rm -rf ./output
mkdir ./output

## define working file names
difm=dwi
mask=mask
anat=t1

## convert input diffusion data into mrtrix format
echo "Converting raw data into MRTrix3 format..."
mrconvert -fslgrad $BVEC $BVAL $DIFF ${difm}.mif --export_grad_mrtrix ${difm}.b -force -nthreads $NCORE -quiet

## create mask of dwi data - use bet for more robust mask
if [ ! -f ${MASK} ]; then
    bet $DIFF bet -R -m -f 0.3
    mrconvert bet_mask.nii.gz ${mask}.mif -force -nthreads $NCORE -quiet
else
    mrconvert ${MASK} ${mask}.mif -force -nthreads $NCORE -quiet
fi

## create b0 
dwiextract ${difm}.mif - -bzero -nthreads $NCORE -quiet | mrmath - mean b0.mif -axis 3 -nthreads $NCORE -quiet -force

## check if b0 volume successfully created
if [ ! -f b0.mif ]; then
    echo "No b-zero volumes present."
    NSHELL=`mrinfo -shell_bvalues ${difm}.mif | wc -w`
    NB0s=0
    EB0=''
else
    ISHELL=`mrinfo -shell_bvalues ${difm}.mif | wc -w`
    NSHELL=$(($ISHELL-1))
    NB0s=`mrinfo -shell_sizes ${difm}.mif | awk '{print $1}'`
    EB0="0,"
fi

## determine single shell or multishell fit
if [ $NSHELL -gt 1 ]; then
    MS=1
    echo "Multi-shell data: $NSHELL total shells"
else
    MS=0
    echo "Single-shell data: $NSHELL shell"
    if [ ! -z "$TENSOR_FIT" ]; then
    echo "Ignoring requested tensor shell. All data will be fit and tracked on the same b-value."
    fi
fi

## print the # of b0s
echo Number of b0s: $NB0s 

## extract the shells and # of volumes per shell
BVALS=`mrinfo -shell_bvalues ${difm}.mif`
COUNTS=`mrinfo -shell_sizes ${difm}.mif`

## echo basic shell count summaries
echo -n "Shell b-values: "; echo $BVALS
echo -n "Unique Counts:  "; echo $COUNTS

## check if $TENSOR_FIT shell exists in the data and subset data if it does, otherwise ignore
if [ ! -z $TENSOR_FIT ]; then

    ## look for the requested shell
    TFE=`echo $BVALS | grep -o $TENSOR_FIT`

    ## if it finds it
    if [ ! -z $TFE ]; then
        echo "Requested b-value for fitting the tensor, $TENSOR_FIT, exists within the data."
        echo "Extracting b-${TENSOR_FIT} shell for tensor fit..."    
        dwiextract ${difm}.mif ${difm}_ten.mif -bzero -shell ${EB0}${TENSOR_FIT} -force -nthreads $NCORE -quiet
        dift=${difm}_ten
    else
        echo "Requested b-value for fitting the tensor, $TENSOR_FIT, does not exist within the data."
        echo "The single-shell tensor fit will be ignored; the tensor will be fit across all b-values."
        dift=${difm}
        TENSOR_FIT=''
    fi

else

    ## just pass the data forward
    dift=${difm}
    
fi    

## fit the tensor
if [ $MS -eq 0 ]; then

    ## estimate single shell tensor
    echo "Fitting tensor model..."
    dwi2tensor -mask ${mask}.mif ${dift}.mif dt.mif -bvalue_scaling false -force -nthreads $NCORE -quiet

else

    ## if single shell tensor is requested, fit it
    if [ ! -z $TENSOR_FIT ]; then

    ## fit the requested single shell tensor for the multishell data
    echo "Fitting single-shell b-value $TENSOR_FIT tensor model..."
    dwi2tensor -mask ${mask}.mif ${dift}.mif dt.mif -bvalue_scaling false -force -nthreads $NCORE -quiet

    else

    ## estimate multishell tensor w/ kurtosis and b-value scaling
    echo "Fitting multi-shell tensor model..."
    dwi2tensor -mask ${mask}.mif ${dift}.mif -dkt dk.mif dt.mif -bvalue_scaling true -force -nthreads $NCORE -quiet

    fi

fi

## create tensor metrics either way
tensor2metric -mask ${mask}.mif -adc md.mif -fa fa.mif -ad ad.mif -rd rd.mif -cl cl.mif -cp cp.mif -cs cs.mif dt.mif -force -nthreads $NCORE -quiet

## tensor outputs
mrconvert fa.mif -stride 1,2,3,4 ./output/fa.nii.gz -force -nthreads $NCORE -quiet
mrconvert md.mif -stride 1,2,3,4 ./output/md.nii.gz -force -nthreads $NCORE -quiet
mrconvert ad.mif -stride 1,2,3,4 ./output/ad.nii.gz -force -nthreads $NCORE -quiet
mrconvert rd.mif -stride 1,2,3,4 ./output/rd.nii.gz -force -nthreads $NCORE -quiet

## westin shapes (also tensor)
mrconvert cl.mif -stride 1,2,3,4 ./output/cl.nii.gz -force -nthreads $NCORE -quiet
mrconvert cp.mif -stride 1,2,3,4 ./output/cp.nii.gz -force -nthreads $NCORE -quiet
mrconvert cs.mif -stride 1,2,3,4 ./output/cs.nii.gz -force -nthreads $NCORE -quiet

## tensor itself
mrconvert dt.mif -stride 1,2,3,4 ./output/tensor.nii.gz -force -nthreads $NCORE -quiet

## kurtosis, if it exists
if [ -f dk.mif ]; then
    mrconvert dk.mif -stride 1,2,3,4 ./output/kurtosis.nii.gz -force -nthreads $NCORE -quiet
fi