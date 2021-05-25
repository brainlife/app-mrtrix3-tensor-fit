[![Abcdspec-compliant](https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg)](https://github.com/brain-life/abcd-spec)
[![Run on Brainlife.io](https://img.shields.io/badge/Brainlife-bl.app.346-blue.svg)](https://doi.org/10.25663/brainlife.app.346)

# Fit tensor model (DTI) using mrtrix3
This app will fit the diffusion tensor model (DTI) to a dMRI input using MRTrix3. The app can run on multi-shell or single shell data, and the user can specify which shell to use. This app can also normalize the diffusion data before model fitting based on user input. This app will output the neuro/tensor output on brainlife, including individual nifti files for FA, MD, AD, and RD, the tensors nifti, westin-shape niftis, and a kurtosis nifti if multi-shell data. This app takes a neuro/dwi datatype as input, and an optional neuro/mask dwi brain datatype input. If mask not inputted, will generate mask.
Note: this code was originally written by Brent McPherson (bcmcpher@iu.edu) for the Anatomically-constrained white matter tractography applications. This code was taken directly from brainlife/app-mrtrix3-act. All credit should go to Brent McPherson.

### Authors
- [Brent McPherson](bcmcpher@iu.edu)
- [Bradley Caron](bacaron@iu.edu)
- [Soichi Hayashi](hayashis@iu.edu)

### Contributors
- [Franco Pestilli](frakkopesto@gmail.com)

### Funding Acknowledgement
brainlife.io is publicly funded and for the sustainability of the project it is helpful to Acknowledge the use of the platform. We kindly ask that you acknowledge the funding below in your publications and code reusing this code.

[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-1636893](https://img.shields.io/badge/NSF_BCS-1636893-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1636893)
[![NSF-ACI-1916518](https://img.shields.io/badge/NSF_ACI-1916518-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1916518)
[![NSF-IIS-1912270](https://img.shields.io/badge/NSF_IIS-1912270-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1912270)
[![NIH-NIBIB-R01EB029272](https://img.shields.io/badge/NIH_NIBIB-R01EB029272-green.svg)](https://grantome.com/grant/NIH/R01-EB029272-01)

### Citations
We kindly ask that you cite the following articles when publishing papers and code using this code. 

1. Avesani, P., McPherson, B., Hayashi, S. et al. The open diffusion data derivatives, brain data upcycling via integrated publishing of derivatives and reproducible open cloud services. Sci Data 6, 69 (2019). [https://doi.org/10.1038/s41597-019-0073-y](https://doi.org/10.1038/s41597-019-0073-y)
2. Basser, P.J.; Mattiello, J.; LeBihan, D. Estimation of the effective self-diffusion tensor from the NMR spin echo. J Magn Reson B., 1994, 103, 247–254.
3. Veraart, J.; Sijbers, J.; Sunaert, S.; Leemans, A. & Jeurissen, B. Weighted linear least squares estimation of diffusion MRI parameters: strengths, limitations, and pitfalls. NeuroImage, 2013, 81, 335-346
4. Tournier, J.-D.; Smith, R. E.; Raffelt, D.; Tabbara, R.; Dhollander, T.; Pietsch, M.; Christiaens, D.; Jeurissen, B.; Yeh, C.-H. & Connelly, A. MRtrix3: A fast, flexible and open software framework for medical image processing and visualisation. NeuroImage, 2019, 202, 116137


#### MIT Copyright (c) 2020 brainlife.io The University of Texas at Austin and Indiana University


## Running the App 

### On Brainlife.io

You can submit this App online at [https://doi.org/10.25663/bl.app.1](https://doi.org/10.25663/bl.app.1) via the "Execute" tab.

### Running Locally (on your machine)

1. git clone this repo.
2. Inside the cloned directory, create `config.json` with something like the following content with paths to your input files.

```json
{
	"diff": "./input/dtiinit/dwi_aligned_trilin_noMEC.nii.gz",
	"bvec": "./input/dtiinit/dwi_aligned_trilin_noMEC.nii.bvecs",
	"bval": "./input/dtiinit/dwi_aligned_trilin_noMEC.nii.bvals",
        "mask": 360,
        "norm": false,
	"tensor_fit":	null
}
```

3. Launch the App by executing `main`

```bash
./main
```

### Sample Datasets

If you don't have your own input file, you can download sample datasets from Brainlife.io, or you can use [Brainlife CLI](https://github.com/brain-life/cli).

```
npm install -g brainlife
bl login
mkdir input
bl dataset download 5a0dcb1216e499548135dd27 && mv 5a0dcb1216e499548135dd27 input/dtiinit
```

## Output

All output files will be generated under the output directory. The main outputs of this App are nifti files for each of the main measures from the DTI model.

### Dependencies

This App only requires [singularity](https://www.sylabs.io/singularity/) to run. If you don't have singularity, you will need to install following dependencies.  

  - jsonlab: https://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab-a-toolbox-to-encode-decode-json-files
  - singularity: https://sylabs.io/guides/3.0/user-guide/installation.html

#### MIT Copyright (c) 2020 brainlife.io The University of Texas at Austin and Indiana University
