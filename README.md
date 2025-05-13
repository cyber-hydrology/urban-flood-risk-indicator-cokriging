# urban-flood-risk-indicator-cokriging

This repository contains R code and data for a synthetic experiment on enhancing street-level urban flood risk information by combining observations with physical modeling using indicator cokriging. 
This repository accompanies the paper [**Enhancing street-level urban flood risk information combining observations with physical modeling using indicator cokriging: a synthetic experiment**] (in review) (Hyeonjin Choi, Minyoung Kim, Bomi Kim, Junyeong Kum, Haeseong Lee, Myungho Lee, Seong Jin Noh ) and managed by the Hydrology and Water Resources Lab (Noh Lab, https://cyber-hydrology.github.io/) at Kumoh National Institute of Technology.

## Project Overview
Urban flooding poses significant challenges in densely populated areas. This project aims to improve flood risk assessments by integrating multi point-based observation data with physics-based flood model through indicator cokriging techniques.

## Repository Structure
```
urban-flood-risk-indicator-cokriging/
├── data/               # Synthetic datasets and input files
├── code/               # R scripts for modeling and analysis
├── results/            # Output figures and result summaries
├── README.md           # Project overview and instructions
```
### 1. Data Description
The `data/`  directory contains synthetic flood simulation results and supplementary spatial data used for indicator cokriging analysis. These files are based on a physics-based urban flood model simulating the August 25, 2014 flood event in the Oncheon-cheon catchment in Busan, South Korea (Area 1).

| File Name                    | Description |
|-----------------------------|------|
| A1_max_inun_rr1.00.asc      | Simulated maximum inundation depth for Area 1 under the base rainfall condition (rr = 1.00). |
| A1_max_inun_rr0.75.asc      | Simulated inundation result for reduced rainfall (rr = 0.75), representing an underestimation scenario. |
| A1_max_inun_rr1.25.asc      | Simulated inundation result for increased rainfall (rr = 1.25), representing an overestimation scenario. |
| A1_road.asc                 | Rasterized road network data for Area 1 used as an auxiliary variable in cokriging. |

### 2. Code Description
The `code/` directory contains R scripts that perform indicator cokriging analysis based on synthetic flood simulation data. Each script corresponds to a specific rainfall scenario and evaluates flood risk using 100% of the available sampling points in Area 1.
| File Name              | Description |
|------------------------|-------------|
| `A1_rr0.75_100p.R`     | Performs indicator cokriging for the **reduced rainfall** scenario (rr = 0.75) using 100% of the sampling points. |
| `A1_rr1.25_100p.R`     | Performs indicator cokriging for the **increased rainfall** scenario (rr = 1.25) using 100% of the sampling points. |

# Getting Started
## Prerequisites
Ensure you have the following installed:
