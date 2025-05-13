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
### Data Description
The data/ directory contains synthetic flood simulation results and supplementary spatial data used for indicator cokriging analysis. These files are based on a physics-based urban flood model simulating the August 25, 2014 flood event in the Oncheon-cheon catchment in Busan, South Korea (Area 1).

| 파일 이름                    | 설명 |
|-----------------------------|------|
| A1_max_inun_rr1.00.asc      | 기준 강우 (rr = 1.00)에 대한 최대 침수심 시뮬레이션 결과 |
| A1_max_inun_rr0.75.asc      | 강우량을 25% 줄인 경우 (rr = 0.75)에 대한 침수 결과 |
| A1_max_inun_rr1.25.asc      | 강우량을 25% 증가시킨 경우 (rr = 1.25)에 대한 침수 결과 |
| A1_road.asc                 | Area 1의 도로 정보를 담은 래스터 파일 |

# Getting Started
## Prerequisites
Ensure you have the following installed:
