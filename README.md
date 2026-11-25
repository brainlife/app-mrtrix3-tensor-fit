<h1 align="center">Fit Tensor Model using MRtrix3</h1>

<p align="center">
  Diffusion tensor maps (FA, MD, AD, RD, Westin shapes, the tensor itself and, for multi-shell data, kurtosis) from a DWI, fitted with MRtrix3.
</p>

<p align="center">
  <a href="https://github.com/brainlife/abcd-spec"><img src="https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg" alt="ABCD Spec v1.1"></a>
  <a href="https://doi.org/10.25663/brainlife.app.528"><img src="https://img.shields.io/badge/Brainlife-brainlife.app.528-blue.svg" alt="Run on brainlife.io"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-lightgrey.svg" alt="MIT license"></a>
</p>

## 🧠 At a glance

<!-- brainlife-app:begin (generated from the App manifest; edit the manifest, not this block) -->

> **Fits the diffusion tensor model to DWI with MRtrix3 dwi2tensor and outputs FA, MD, AD, RD, Westin shape maps and the tensor (plus kurtosis for multi-shell data).**

Converts the DWI to MRtrix format, uses the provided brain mask or computes one with FSL bet, fits the tensor with dwi2tensor (optionally on a single chosen shell) and writes tensor2metric maps. For multi-shell data without a chosen shell it fits diffusional kurtosis too. Use it to get standard DTI maps for tract or ROI statistics. The norm parameter is read but not used by this branch's script.

| | |
|---|---|
| 📥 **Inputs** | `neuro/dwi` · `neuro/mask` (optional) |
| 📤 **Outputs** | `neuro/tensor` |
| 🐳 **Container** | `brainlife/mrtrix3:3.0_RC3` |
| ⚙️ **Resources** | 1 CPUs · 20 GB memory · 0.5 h walltime |
| 🔗 **Run it** | [doi.org/10.25663/brainlife.app.528](https://doi.org/10.25663/brainlife.app.528) |

#### 📥 Inputs

| Input | Datatype | Required | Description |
|---|---|---|---|
| `dwi` | `neuro/dwi` | yes | Diffusion-weighted image with bvals and bvecs. |
| `mask` | `neuro/mask` (dwi, brain) | no | Optional DWI brain mask; computed with FSL bet when absent. |

#### 📤 Outputs

| Output | Datatype | Description |
|---|---|---|
| `output` | `neuro/tensor` | Tensor datatype: tensor.nii.gz and FA, MD, AD, RD, CL, CP, CS maps (kurtosis.nii.gz for multi-shell fits). |

<details>
<summary><b>⚙️ Parameters</b> (2)</summary>

| Parameter | Type | Default | Description |
|---|---|---|---|
| `norm` | boolean | `false` | Normalize diffusion data before fit |
| `tensor_fit` | number |  | If user wants to fit tensor to a specific shell, specify here. otherwise will fit on entire diffusion data |

</details>

<!-- brainlife-app:end -->

## 🚀 Running the App

### ☁️ On brainlife.io

Open the App at [doi.org/10.25663/brainlife.app.528](https://doi.org/10.25663/brainlife.app.528), choose a `neuro/dwi` dataset (and, optionally, a DWI brain mask) from your project and press **Execute**. The App works on single- and multi-shell data; to fit the tensor to one shell only, set `tensor_fit` to its b-value. The results are archived as a `neuro/tensor` dataset tagged `mrtrix3`, ready for tract-profile and ROI statistics Apps.

How the tensor is fitted:

- **Single-shell data**: `dwi2tensor` on all volumes; `tensor_fit` is ignored.
- **Multi-shell data with `tensor_fit` set**: the b0 volumes and the requested shell are extracted and fitted; if that b-value is not in the data, all volumes are used.
- **Multi-shell data without `tensor_fit`**: a tensor and diffusional kurtosis are fitted across all shells (`dwi2tensor -dkt`).

Without a mask input, a brain mask is computed with FSL `bet -R -m -f 0.3`. The `norm` parameter is read but not used by this version.

### 💻 Locally

You need [Singularity/Apptainer](https://apptainer.org/) and [`jq`](https://jqlang.github.io/jq/). The App runs MRtrix3 and FSL from the `brainlife/mrtrix3:3.0_RC3` container.

1. Clone this repository and check out the App branch: `git checkout v1.0`.
2. Create `config.json` with the paths to your inputs (omit `mask` to have one computed, and leave `tensor_fit` empty to use all shells):

   ```json
   {
       "diff": "./input/dwi/dwi.nii.gz",
       "bvec": "./input/dwi/dwi.bvecs",
       "bval": "./input/dwi/dwi.bvals",
       "mask": "./input/mask/mask.nii.gz",
       "norm": false,
       "tensor_fit": ""
   }
   ```

3. Run the App:

   ```bash
   ./main
   ```

## 📦 Outputs

```text
output/
├── tensor.nii.gz             diffusion tensor
├── fa.nii.gz, md.nii.gz      fractional anisotropy, mean diffusivity
├── ad.nii.gz, rd.nii.gz      axial and radial diffusivity
├── cl.nii.gz, cp.nii.gz, cs.nii.gz   Westin linear, planar and spherical shape measures
└── kurtosis.nii.gz           diffusional kurtosis (multi-shell fits only)
```

## 🩺 Troubleshooting

- **`something went wrong. check derivatives`**: `output/tensor.nii.gz` was not written. Check the log for the MRtrix3 error, and that the bvals and bvecs match the DWI.

## 📚 Citing

> [!TIP]
> If you use this App in your work, please cite the App, the software it builds on and brainlife.io (below). GitHub's **Cite this repository** button gives the App citation in APA and BibTeX.

- Basser PJ, Mattiello J, LeBihan D. Estimation of the effective self-diffusion tensor from the NMR spin echo. *J Magn Reson B* 103:247–254 (1994).
- Veraart J, Sijbers J, Sunaert S, Leemans A, Jeurissen B. Weighted linear least squares estimation of diffusion MRI parameters: strengths, limitations, and pitfalls. *NeuroImage* 81:335–346 (2013).
- Tournier J-D, Smith RE, Raffelt D, Tabbara R, Dhollander T, Pietsch M, Christiaens D, Jeurissen B, Yeh C-H, Connelly A. MRtrix3: A fast, flexible and open software framework for medical image processing and visualisation. *NeuroImage* 202:116137 (2019).
- Fit Tensor Model using MRTrix3. brainlife.io App. [doi:10.25663/brainlife.app.528](https://doi.org/10.25663/brainlife.app.528)
- Jenkinson et al. FSL. *NeuroImage* 62:782-790 (2012). [doi:10.1016/j.neuroimage.2011.09.015](https://doi.org/10.1016/j.neuroimage.2011.09.015)
- Tournier et al. MRtrix3: A fast, flexible and open software framework for medical image processing and visualisation. *NeuroImage* 202:116137 (2019). [doi:10.1016/j.neuroimage.2019.116137](https://doi.org/10.1016/j.neuroimage.2019.116137)
- Hayashi S, Caron BA, Heinsfeld AS, et al. brainlife.io: a decentralized and open-source cloud platform to support neuroscience research. *Nature Methods* 21:809–813 (2024). [doi:10.1038/s41592-024-02237-2](https://doi.org/10.1038/s41592-024-02237-2)
- Avesani P, McPherson B, Hayashi S, et al. The open diffusion data derivatives, brain data upcycling via integrated publishing of derivatives and reproducible open cloud services. *Scientific Data* 6:69 (2019). [doi:10.1038/s41597-019-0073-y](https://doi.org/10.1038/s41597-019-0073-y)

## 👥 Authors

- Brent McPherson
- Bradley Caron
- Soichi Hayashi

**Contributors:** Franco Pestilli

The fitting code was taken directly from [brainlife/app-mrtrix3-act](https://github.com/brainlife/app-mrtrix3-act), written by Brent McPherson for the anatomically-constrained tractography Apps; all credit for it goes to him.

## 💰 Funding

[![Wellcome-226486/Z/22/Z](https://img.shields.io/badge/Wellcome-226486%2FZ%2F22%2FZ-purple.svg)](https://wellcome.org/)
[![NIH-NINDS-U24NS140384](https://img.shields.io/badge/NIH_NINDS-U24NS140384-green.svg)](https://reporter.nih.gov/project-details/11261037)
[![NIH-NINDS-UM1NS132207](https://img.shields.io/badge/NIH_NINDS-UM1NS132207-green.svg)](https://reporter.nih.gov/project-details/11411328)
[![NIH-NIBIB-R01EB029272](https://img.shields.io/badge/NIH_NIBIB-R01EB029272-green.svg)](https://reporter.nih.gov/project-details/10262925)
[![NIH-NIBIB-R01EB030896](https://img.shields.io/badge/NIH_NIBIB-R01EB030896-green.svg)](https://reporter.nih.gov/project-details/10428625)
[![NIH-NIMH-R01MH126699](https://img.shields.io/badge/NIH_NIMH-R01MH126699-green.svg)](https://reporter.nih.gov/project-details/10460628)
[![NIH-NIDCD-R01DC020088](https://img.shields.io/badge/NIH_NIDCD-R01DC020088-green.svg)](https://reporter.nih.gov/project-details/11140284)
[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-2203524](https://img.shields.io/badge/NSF_BCS-2203524-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2203524)
[![NSF-IIS-1636893](https://img.shields.io/badge/NSF_IIS-1636893-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1636893)
[![NSF-OAC-2148729](https://img.shields.io/badge/NSF_OAC-2148729-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2148729)
[![NSF-IIS-1912270](https://img.shields.io/badge/NSF_IIS-1912270-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1912270)
[![NSF-IIS-2148700](https://img.shields.io/badge/NSF_IIS-2148700-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2148700)
[![NSF-OAC-1916518](https://img.shields.io/badge/NSF_OAC-1916518-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1916518)

<sub>brainlife.io is publicly funded, and acknowledging that support helps keep it running. This App was developed with support from Wellcome, the U.S. National Institutes of Health (including the BRAIN Initiative BRAIN CONNECTS program: The Axonal Projectome EXchange, U24NS140384, and the Center for Mesoscale Connectomics, UM1NS132207) and the U.S. National Science Foundation.</sub>

## ⚖️ License

[MIT](LICENSE). MRtrix3 and FSL are distributed under their own licenses.
