# infant 3T/7T precision imaging codebase
This code repo contains the code used to create the figures in the publication  "Precision functional imaging in infants using multi-echo fMRI at 7T", including the code used for calculating safe power limits for scanning infants at the 7T Terra scanner at the Center for Magnetic Resonance Research (RefVolCalculator).

For reading in connectivity matrices in Matlab, the packages 'cifti-matlab' and gifti' and Connectome Workbench commands are used in Matlab.

https://www.mathworks.com/matlabcentral/fileexchange/56783-washington-university-cifti-matlab https://github.com/gllmflndn/gifti https://www.humanconnectome.org/software/workbench-command

The manuscript is currently available on bioRxiv: https://www.biorxiv.org/content/10.1101/2025.11.09.687453v1

Data associated with this manuscript will be published upon journal publication. Instructions on how to access the data will be added to this README. 

Please see the description below for information on the structure of the available neuroimaging data. Additional source data for a subset of Figures in the paper is available with the journal publication. 

# infant 3T/7T precision imaging data

Data in this repository are organized following [BIDS standard](https://bids.neuroimaging.io/).

For each of the six "Precision Baby" (PB) subjects included in this manuscript, input data as well as data derivatives are available. Shared data for each subject is organized in the following way:

```bash
PB0XX
├── BIDSinput
│   ├── dataset_description.json
│   └── sub-PB0XX
│       └── ses-MENORDIC
│           ├── anat
│           ├── fmap
│           └── func
├── NiBabiesDerivatives
│   ├── dataset_description.json
│   ├── sub-PB0XX_ses-MENORDIC.html
│   ├── logs
│   └── sub-PB0XX
│       ├── figures
│       └── ses-MENORDIC
│           ├── anat
│           ├── fmap
│           └── func
├── XCPDderivatives
    ├── dataset_description.json
    ├── sub-PB00XX.html
    ├── sub-PB0XX_ses-MENORDIC_executive_summary.html
    ├── atlases
    ├── logs
    └── sub-PB0XX
        ├── figures
        ├── log
        └── ses-MENORDIC
            ├── anat
            ├── fmap
            └── func
```

BISD input data has already undergone termal noise removal with NORDIC (see for example [Vizioli et al. 2021](https://www.nature.com/articles/s41467-021-25431-8)). NiBabies version 25.0.1 ([Goncalves & Moser et al. 2025, bioRxiv](https://www.biorxiv.org/content/10.1101/2025.05.14.654069v1)) and XCP-D version 0.10.5 ([Mehta et al., 2024](https://direct.mit.edu/imag/article/doi/10.1162/imag_a_00257/123715/XCP-D-A-robust-pipeline-for-the-post-processing-of)) were used for preprocessing. 

All data (3T and 7T) are combined withing the respective 'func' directories. They are differentiated using the BIDS format `acq` label (`acq-3T2mm`; `acq-7T16mm` (for 1.6mm resolution) and `acq-7T125mm` (for 1.25mm resolution)).

Please refer to the manuscript for a more detailed description of the input data and preprocessing steps. 
