# infant 3T/7T precision imaging codebase
This code repo contains the code used to create the figures in the publication  "Precision functional imaging in infants using multi-echo fMRI at 7T", including the code used for calculating safe power limits for scanning infants at the 7T Terra scanner at the Center for Magnetic Resonance Research (RefVolCalculator).

For reading in connectivity matrices in Matlab, the packages 'cifti-matlab' and gifti' and Connectome Workbench commands are used in Matlab.

https://www.mathworks.com/matlabcentral/fileexchange/56783-washington-university-cifti-matlab https://github.com/gllmflndn/gifti https://www.humanconnectome.org/software/workbench-command

The manuscript is currently available on bioRxiv: https://www.biorxiv.org/content/10.1101/2025.11.09.687453v1

Data associated with this manuscript will be published upon journal publication. Instructions on how to access the data will be added to this README. 

Please see the description below for information on the structure of the available neuroimaging data. Additional source data for a subset of Figures in the paper is available with the journal publication. 

# infant 3T/7T precision imaging data

Data in this repository are organized following [BIDS standard](https://bids.neuroimaging.io/).

For each of the six "Precision Baby" (PB) subjects included in this manuscript, input data as well as data derivatives are available. 

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

