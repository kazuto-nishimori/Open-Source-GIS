# Lab Eight: Reproducibility, Replicability, and Uncertainty Propagation

## STATUS: UNDER CONSTRUCTION 

## Table of Contents

1. [Objective](#goal)
2. [Software and Documentation](#sw)
3. [Reproducibility and Replicability](#randr)
4. [Malcomb et al.: Conceptualization and Methodology](#malc)
    1. [Conceptual rationale](#malc-a)
    2. [Methodology](#malc-b)
5. [Reproducing Adaptive Capacity Map](#rac)
    1. [Data used](#rac-a)
    2. [Retracing the steps](#rac-b)
    3. [Uncertainty propagation](#rac-c)
6. [Reproducing Household Resilience Map](#flow)
 

## Objective <a name="goal"></a>

## Software and Documentation <a name="sw"></a>

### Software used

- [QGIS 3.8.1](https://www.qgis.org/en/site/) 
- [PostGIS 2.5.3](https://postgis.net/source/)
- [PostgreSQL 11.5](https://www.postgresql.org/download/)

### Documentation Referenced
- Lab Instructions by Professor Holler: [request document by email](jholler@middlebury.edu)
- https://www.w3resource.com/

## Reproducibility and Replicability <a name="randr"></a>

## Malcomb et al.: Conceptualization and Methodology <a name="malc"></a>

### Conceptual rationale <a name="malc-a"></a>

### Methodology <a name="malc-b"></a>

## Reproducing Adaptive Capacity Map <a name="rac"></a>

### Data Used in Adaptive Capacity map <a name="rac-a"></a>

#### Demographic and Health Surveys (DHS)

[DHS]( https://dhsprogram.com/What-We-Do/Survey-Types/DHS.cfm) is conducted by [USAID]( https://www.usaid.gov/) every five years and collects nationally representative high-volume data on health and population in developing countries. This survey is at the household level, but to protect confidentiality, the geospatial information is not available at this scale. Instead, several neighboring households are grouped together into a cluster, and the cluster’s coordinates are randomized within a certain area (5km radius for rural areas and 2km for urban) that does not cross the district border. There are around 850 clusters in Malawi (area of 120,000 km2). This data contains several hundred columns for each household documenting anything from the number and type of cattle to respondent’s smoking habit. We used data from 2010 as the authors had done, but unfortunately it cannot be shared due to DHS’s policy. Fortunately, the data is easily obtainable but it does require a formal request. Here ere you can download the metadata: [DHS_metadata.text](/DHS_metadata.text), [DHS_Survey_Vars.pdf](/DHS_Survey_Vars.pdf. 
)
### Traditional Authority shape file
The shape file for the TA was obtained here

### Malawi lakes shape file
The shape file for the major lakes of Malawi was obtained through the [Malawi Spatial Data Platform]( http://www.masdap.mw/)

## Retracing the steps <a name="rac-b"></a>
We followed Malcolm et al.’s methodology and instructions (where they existed) to attempt to reproduce the Adaptive Capacity map. However, the results were much less than satisfactory, even though we started with the same dataset as the authors. We attribute this to the significant holes in their explanation of the important decisions (i.e. sources of biases) that went into the production of the map.

To create this map, the first step is to add a column to our survey data table that indicates the id of the TA in which it resides, since the results will later be aggregated by TA. However, the survey data has no coordinate information, only the cluster id. So, we added a TA id column to the DHS cluster shapefile and this column was populated using a simple `st_intersects()` operation with the TA layer. Then, this TA id column was joined to the survey table via cluster id.  

Then, we looked at the metadata of the survey to locate the columns that the authors referenced. There was some guesswork involved, for example, the authors did not specify what animals count as livestock. These are the columns we chose to use. 

‘’’
household id: hhid
cluster id:
livestock: HV246a + hv246a + hv246d + hv246e + hv246g
sick: hv248
land: hv245
wealth: hv271, or should it have been hv270 (already on scale of 5?)
orphans: hv251
watertime: hv204
electricity: hv206
cookingfuel: hv226
gender: hv219
cellphone: hv243a
radio: hv207
urban: Joined from DHS clusters shapefile
‘’’

It is also important to identify via metadata, how the null values are signified, because this depends on the column. For example, the no-data value could be ‘9’, ‘99’ or ‘98’. Rows containing null values were deleted. 

The next step involved quantifying the survey results and dividing into quintiles. This step was the hardest to reproduce, and a lot of guesswork went in, as few details were ever published by the authors. Even the steps written down by the authors are unclear at times, for example the authors mention that the data was split into quintiles where the lowest quintile was given a score of 0 and the highest, a 5. This makes no sense as a scale from 0 to 5 is in fact a sextile. An example of the kind of guesswork involved is the binary yes-no question. How a binary is mapped to a quintile has rather significant implications because it affects its weight: 1 for no and 5 for yes carries a much larger weight than 2 and 4 respectively. Considering 5 out of the 7 criteria in the access category is a binary question, this is an unacceptable oversight. 

Next, the scores were weighed and added to recreate the final adaptive capacity score for each household. We weighed the scores in such a way (scale of 0.4 to 2) that the total household resilience score is on a scale of 1 to 5. Although not explicitly stated, Malcolm et al most likely scored the scores to have a score out of 100, seeing that they report a range of -0.80 to 39.33 at the household level. The negative score is curious, since it is unclear how a “quintile” from 0 to 5 could possibly produce such a number, but this is not explained. Finally these scores were aggregated using their TA id, averaged and joined with the TA layer to create this map: 

The map we recreated is no reproduction of the one by Malcomb et al.. Although we tried our best, the lack of important instructions in the methodology of Malcolm et al. made it impossible to reproduce the map, even with same data set. 

The SQL file for all the operations done in this step is found here. You can look through the code to see how we decided to quantify the results. 
The final capacity map is found here. (Courtesy of Professor Holler) 

## Uncertainty propagation <a name="rac-c"></a>

Attempting to reproduce the map raised questions of uncertainty propagation that was never brought up by the authors. We propose that the method of data collection by the DHS makes this dataset not suitable for aggregation at the TA scale. As we discussed earlier, the survey is designed to be representative of the population of Malawi at the national scale. Although not explicitly stated, we can infer that this is also true at the district scale. We saw that the coordinates of the clusters were randomized in such way to never cross the district borders. This we presume is because the clusters were chosen to be representative of their district.

A similar guarantee does not exist at the level of the traditional authorities. There are 250 traditional authorities in the small nation of Malawi. This makes the coordinate randomization of 2-5km a very significant source of uncertainty; a point that was in fact in some given TA could easily have been randomized to end up in a neighboring one. Malcolm et al. chose to aggregate at this level because they believed that at the district level, local hotspots of vulnerability could be averaged out and made invisible. They claim TA to be the lowest meaningful administrative level for aggregation, but with so much uncertainty, I disagree with their rationale and decision.   

This also raises a question about the ethics of data presentation by the USAID. Although the DHS survey is extensive, there are only 850 clusters nationwide; that is, on average 30 clusters chosen per district to best represent that district. Then, how much do the real coordinates of those clusters truly mean? Put another way, imagine you are tasked to find 30 people in a large concert hall to best represent the audience. The real coordinates of these 30 people, i.e. their seat numbers, mean very little, in so much as guaranteeing that they were in fact attending the concert. The seat numbers cannot be used to conclude anything about the population geography within the concert hall, but the 30 people as a sample together can be used to infer conclusions about the population geography within the larger city: the kind of person who attends a certain concert hall in a certain neighborhood. Thus, the geolocations of the clusters are only useful, in so much as guaranteeing that they lie within the district. This raises the question of whether it is even appropriate/ethical on the part of USAID to publish point data that can be used inappropriately. Is it not more fitting to publish the survey data with their district name but without cluster numbers? 
