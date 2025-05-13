##### <Libraries load> #####
library(gstat)
library(sp)
library(raster)
library(viridis)
library(dplyr)
library(gridExtra)
library(tidyr)


##### <1. Data load> #####
setwd("C:/Users/minyy/Documents/Kriging") # Specify your working directory.

# 1.1. Synthetic reference flood map (ground truth)
True_file <- "C:/Users/minyy/Documents/Kriging/data/A1_max_inun_rr1.00.asc" # Replace with path to file in the data folder
True_raster <- raster(True_file)

# 1.2. Additional flood map (over- or under-estimated)
Add_file <- "C:/Users/minyy/Documents/Kriging/data/A1_max_inun_rr1.25.asc" # Replace with path to file in the data folder
Add_raster <- raster(Add_file)

# 1.3. Road map
Road_file <- "C:/Users/minyy/Documents/Kriging/data/A1_road.asc" # Replace with path to file in the data folder
Road_raster <- raster(Road_file)
Road_binary <- calc(Road_raster, fun = function(x) ifelse(is.na(x), 0, 1))


##### <2. Synthetic point-based observation (flood risk level)> #####
# 2.1. Flooding threshold
Threshold <- 0.15 # Areas with water depth above 0.15 m are considered flooded
True_binary <- calc(True_raster, fun = function(x) ifelse(x < Threshold, NA, 1))

# 2.2. Clustering and small cluster removal
clust_1 <- clump(True_binary, directions = 8)

cluster_freq_1 <- freq(clust_1)
small_clusters_1 <- cluster_freq_1[cluster_freq_1[, "count"] < 63, "value"] # Extract cluster IDs with fewer than 63 cells (~0.001 km²)

filtered_clust_1 <- calc(clust_1, fun = function(x) {ifelse(x %in% small_clusters_1, NA, x)})
filtered_clust_1 <- calc(filtered_clust_1, fun = function(x) ifelse(!is.na(x), 1, NA))

# 2.3. Extract road & Calculating Distance to flood
filtered_clust_on_road_1 <- mask(filtered_clust_1, Road_binary, maskvalue = 0)

if (!file.exists("dist_map_A1_1.00.RData")) {dist_map_A1_1.00 <- distance(filtered_clust_on_road_1) 
save(dist_map_A1_1.00, file = "dist_map_A1_1.00.RData")} else {load("dist_map_A1_1.00.RData")}

# 2.4. Point sampling
set.seed(1000)
num_points <- 5000
all_coords <- spsample(as(extent(dist_map_A1_1.00), "SpatialPolygons"), num_points, type = "random")
distance_values_all <- raster::extract(dist_map_A1_1.00, all_coords)

epsilon <- 30
distance_prob <- 1 / (distance_values_all + epsilon) 
distance_prob <- distance_prob / sum(distance_prob)

selected_indices <- sample(1:num_points, size = 100, prob = distance_prob, replace = FALSE)
selected_coords <- coordinates(all_coords)[selected_indices, ]

distance_values <- raster::extract(dist_map_A1_1.00, selected_coords)

user <- data.frame(
  Longitude = selected_coords[, 1],
  Latitude = selected_coords[, 2],
  DistanceToFlood = distance_values)

user$RiskLevel <- case_when(
  user$DistanceToFlood >= 50 ~ 1, # Risk level 1 (50m or more from flood)
  user$DistanceToFlood < 50 ~ 2) # Risk level 2 (less than 50m from flood)

user$RiskLevel1 <- ifelse(user$RiskLevel == 1, 1, 0)
user$RiskLevel2 <- ifelse(user$RiskLevel == 2, 1, 0)


##### <3. Flood depth & Distance to flood> #####
# 3.1. Flooding threshold
Add_binary <- calc(Add_raster, fun = function(x) ifelse(x < Threshold, NA, 1))

# 2.2. Clustering and small cluster removal
clust_2 <- clump(Add_binary, directions = 8)

cluster_freq_2 <- freq(clust_2)
small_clusters_2 <- cluster_freq_2[cluster_freq_2[, "count"] < 63, "value"]

filtered_clust_2 <- calc(clust_2, fun = function(x) {ifelse(x %in% small_clusters_2, NA, x)})
filtered_clust_2 <- calc(filtered_clust_2, fun = function(x) ifelse(!is.na(x), 1, NA))

# 2.3. Extract road & Calculating Distance to flood
filtered_clust_on_road_2 <- mask(filtered_clust_2, Road_binary, maskvalue = 0)

if (!file.exists("dist_map_A1_1.25.RData")) {dist_map_A1_1.25 <- distance(filtered_clust_on_road_2) 
save(dist_map_A1_1.25, file = "dist_map_A1_1.25.RData")} else {load("dist_map_A1_1.25.RData")}

# 2.5. Save Flood value and Distance to flood 
coordinates(user) <- ~Longitude + Latitude

user$FloodValue_2 <- raster::extract(Add_raster, user)
user$DistanceToFlood_2 <- raster::extract(dist_map_A1_1.25, user)


##### <4. Generating flood risk probability map> #####
# 4.1. Kriging model & Variogram setup
g <- gstat(id = "Risk1", formula = RiskLevel1 ~ 1, data = user,
           nmax = 7, set = list(order = 2, zero = 1e-05, nocheck = 1))
g <- gstat(g, id = "Risk2", formula = RiskLevel2 ~ 1, data = user,
           nmax = 7, set = list(order = 2, zero = 1e-05, nocheck = 1))
g <- gstat(g, id = "DistanceToFlood_2", formula = DistanceToFlood_2 ~ 1, data = user,
           nmax = 7, set = list(order = 2, zero = 1e-05, nocheck = 1))
g <- gstat(g, id = "FloodValue_2", formula = FloodValue_2 ~ 1, data = user,
           nmax = 7, set = list(order = 0, zero = 1e-05, nocheck = 1))

psill <- round(exp(mean(log(1 + c(
  var(user$RiskLevel1),
  var(user$RiskLevel2),
  var(user$DistanceToFlood_2),
  var(user$FloodValue_2)
)))) - 1, 2)
nugget <- round(psill / 10, 2)
cutoff <- 700
model_type <- "Gau"

g1 <- gstat(g, model = vgm(psill = psill, 
                           model = "Gau", 
                           range = 233, 
                           nugget = nugget), fill.all = TRUE)
v1 <- variogram(g1, cutoff = 700, width = 43)
fit1 <- fit.lmc(v1, g1)
plot(v1, model = fit1)

# 4.2. Kriging
grid_points <- rasterToPoints(True_raster, spatial = TRUE)
zk <- predict(fit1, newdata = grid_points, indicators = TRUE)

# 4.3. Normalize
normalize <- function(x) {
  (x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
} 
zk@data$Risk2.pred <- normalize(zk@data$Risk2.pred)
grid_points@data$Risk2.pred <- zk@data$Risk2.pred # Assign normalized predictions

# 4.4. Road mask
RiskLevel_raster <- raster(ext = extent(True_raster), res = res(True_raster)) # Create a grid template raster
risk2_raster <- rasterize(grid_points, RiskLevel_raster, field = "Risk2.pred", fun = mean) # Rasterize

road_binary_resampled <- resample(Road_binary, RiskLevel_raster, method = "ngb") # Resample road mask to match grid
risk2_masked <- mask(risk2_raster, road_binary_resampled, maskvalue = 0, updatevalue = 0)
plot(risk2_masked, col = turbo(256), main = "Predicted Risk Level 2 (Masked by Road)", legend = TRUE)

# 4.5. Specific probabilities mask
risk2_thresh <- calc(risk2_masked, fun = function(x) ifelse(x >= 0.78, 1, 0))
plot(risk2_thresh, col = c("white", "blue"), main = "Predicted Risk Level 2 (thresh)", legend = FALSE)


##### <5. Evaluation and visualization> #####
# 5.1. Set up metrics
evaluate_metrics <- function(truth, prediction) {
  hit <- overlay(truth, prediction, fun = function(t, p) ifelse(t == 1 & p == 1, 1, NA))
  false_alarm <- overlay(truth, prediction, fun = function(t, p) ifelse(t == 0 & p == 1, 1, NA))
  miss <- overlay(truth, prediction, fun = function(t, p) ifelse(t == 1 & p == 0, 1, NA))
  
  hits <- sum(values(hit), na.rm = TRUE)
  false_alarms <- sum(values(false_alarm), na.rm = TRUE)
  misses <- sum(values(miss), na.rm = TRUE)
  
  hit_rate <- hits / (hits + misses)
  false_alarm_ratio <- false_alarms / (hits + false_alarms)
  csi <- hits / (hits + misses + false_alarms)
  error_bias <- (misses * (1 - false_alarms)) / ((1 - misses) * false_alarms)
  
  combined <- overlay(hit, miss, false_alarm, fun = function(h, m, f) {
    ifelse(!is.na(h), 1, ifelse(!is.na(m), 3, ifelse(!is.na(f), 2, NA)))
  })
  
  list(
    metrics = data.frame(
      Metric = c("Hit Rate", "False Alarm Ratio", "Critical Success Index", "Error Bias"),
      Value = c(hit_rate, false_alarm_ratio, csi, error_bias)
    ),
    raster = combined
  )
}

# 5.2. evaluation
truth_for_eval <- calc(filtered_clust_on_road_1, fun = function(x) ifelse(is.na(x), 0, x))
results <- evaluate_metrics(truth_for_eval, risk2_thresh)

# 5.3. display metrics table
results$metrics$Map <- "Risk Level 2"

formatted <- results$metrics %>%
  pivot_wider(names_from = Map, values_from = Value) %>%
  mutate(across(where(is.numeric), ~ sprintf("%.3f", .)))

grid.arrange(tableGrob(formatted), ncol = 1)

# 5.4. Plot figure
plot(Road_binary, col = c("white", "lightgrey"), legend = FALSE)
plot(results$raster, col = c("#67ae6e", "#ef5a6f", "#6182ff"), add = TRUE, legend = FALSE)
points(
  user$Longitude, user$Latitude,
  col = adjustcolor("#353535", alpha.f = 0.35),
  pch = c(4, 1)[user$RiskLevel],
  cex = 1.5, lwd = 2
)
legend("topright", inset = c(-0.21, 0), xpd = TRUE,
       legend = c("Hit", "False alarm", "Miss", "Risk 1", "Risk 2"),
       fill = c("#67ae6e", "#ef5a6f", "#6182ff", NA, NA),
       border = c("#353535", "#353535", "#353535", NA, NA),
       pch  = c(NA, NA, NA, 4, 1),
       col  = c(NA, NA, NA, "#353535", "#353535"),
       pt.cex = 1.2, pt.lwd = 2, bty = "n")