# urban-flood-risk-indicator-cokriging

This repository contains R code and data for a synthetic experiment on enhancing street-level urban flood risk information by combining observations with physical modeling using indicator cokriging. 

This repository accompanies the paper [**Enhancing street-level urban flood risk information combining observations with physical modeling using indicator cokriging: a synthetic experiment**] (in review) (Hyeonjin Choi, Minyoung Kim, Bomi Kim, Junyeong Kum, Haeseong Lee, Myungho Lee, Seong Jin Noh) and managed by the Hydrology and Water Resources Lab (Noh Lab, https://cyber-hydrology.github.io/) at Kumoh National Institute of Technology.

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
The `code/` directory contains R scripts that perform indicator cokriging analysis based on synthetic flood simulation data. Each script corresponds to a specific rainfall scenario and evaluates flood risk using the 100 sampling points in Area 1.
| File Name              | Description |
|------------------------|-------------|
| `A1_rr0.75_100p.R`     | Performs indicator cokriging for the **reduced rainfall** scenario (rr = 0.75) using the sampling points. |
| `A1_rr1.25_100p.R`     | Performs indicator cokriging for the **increased rainfall** scenario (rr = 1.25) using the sampling points. |

# Getting Started
### Step-by-step Workflow
1. **Set your working directory**  
   Edit the first few lines of the script to point to your local folder:
   ```r
   setwd("your/local/path/to/urban-flood-risk-indicator-cokriging")
   ```

2. **Load required libraries**  
   Make sure all the following packages are installed:
   ```r
   library(gstat)
   library(sp)
   library(raster)
   library(viridis)
   library(dplyr)
   library(gridExtra)
   library(tidyr)
   ```

3. **Load input data**
   - `A1_max_inun_rr1.00.asc`: base flood simulation
   - `A1_max_inun_rr0.75.asc`: adjusted flood scenario (reduced rainfall)
   - `A1_road.asc`: road network raster

4. **Generate synthetic point-based observations**
   - Extract flood-affected clusters and their proximity to roads
   - Sample 100 flood-risk points weighted by distance to flood edge

5. **Prepare cokriging variables**
   - Extract flood depth and distance-to-flood from the adjusted map
   - Assign risk levels and build spatial dataset

6. **Run indicator cokriging**
   - Fit variogram model
   - Predict flood risk probabilities for Risk Level 2
   - Mask predictions by road area

7. **Evaluate model performance**
   - Compute hit rate, false alarm ratio, and critical success index
   - Generate risk prediction and evaluation maps

8. **Visualize results**
   - Plot risk maps and overlay user locations
   - Display performance metrics as a table
