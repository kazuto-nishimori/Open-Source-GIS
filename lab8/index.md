# Lab Eight: Reproducibility, Replicability, and Uncertainty Propagation

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
    3. [Uncertainty propagation end ethics of data presentation](#rac-c)
6. [Reproducing Vulnerablity Map](#rv)
    1. [Data used](#rv-a)
    2. [Retracing the steps](#rv-b)
    3. [Sources of uncertainty](#rv-c)
7. [Comments on Uncertainty in Vulnerability Research, Reproducibility, and Replicability](#conc)
    

## Objective <a name="goal"></a>
This lab has two large goals. Firstly, we will reproduce a vulnerability map published in Applied Geography by Malcolm, Weaver, and Krakowka using the datasets and methodologies outlined in their article. Secondly, we will critique the methods used by the authors and discuss the broader issue of replicability in vulnerability analysis. This lab is an opportunity to dive deep into the reproducibility and replicability discussion that is becoming a hot issue in the social science community. 

## Software and Documentation <a name="sw"></a>

### Software used

- [QGIS 3.8.1](https://www.qgis.org/en/site/) with [GRASS 7.6.1](https://grass.osgeo.org/download/) and [GDAL 3.0.2](https://gdal.org/download.html)
- [PostGIS 2.5.3](https://postgis.net/source/)
- [PostgreSQL 11.5](https://www.postgresql.org/download/)
- raster2pgsql plugin (comes with PostGIS)

### Documentation Referenced
- Lab Instructions by Professor Holler: [request document by email](jholler@middlebury.edu)
- https://www.w3resource.com/

#### Works cited
- Hinkel, Jochen. “‘Indicators of Vulnerability and Adaptive Capacity’: Towards a Clarification of the Science–policy Interface.” Global Environmental Change, vol. 21, no. 1, Jan. 2011, pp. 198–208. EBSCOhost, doi:10.1016/j.gloenvcha.2010.08.002.
- Malcomb, Dylan W., et al. “Vulnerability Modeling for Sub-Saharan Africa: An Operationalized Approach in Malawi.” Applied Geography, vol. 48, Mar. 2014, pp. 17–30. EBSCOhost, doi:10.1016/j.apgeog.2014.01.004.
- Tate, Eric. “Uncertainty Analysis for a Social Vulnerability Index.” Annals of the Association of American Geographers, vol. 103, no. 3, 2013, p. 526. EBSCOhost, doi:10.1080/00045608.2012.700616.
- National Academies of Sciences, Engineering, and Medicine 2019. Reproducibility
and Replicability in Science. Washington, DC: The National Academies Press. https://doi.org/10.17226/25303.

## Reproducibility and Replicability <a name="randr"></a>

Reproducibility and replicability, which has always been an important consideration in the natural sciences, has been an increasingly important topic of discussion in the social sciences as well. The National Academies of Sciences, Engineering, and Medicine in their report on this issue defines the terms as the following:

_Reproducibility is obtaining consistent results using the same input data, computational steps, methods, and code, and conditions of analysis. This definition is synonymous with “computational reproducibility,” and the terms are used interchangeably in this report. Replicability is obtaining consistent results across studies aimed at answering the same scientific question, each of which has obtained its own data._ (2019)

Reproducibility is often neglected in the field of geography. The analysis done by geographers is often a black box, where neither the raw data, code, nor the minute details of their methodology is ever published. In a way, we are expected to just ‘take their word’. Even in the digital age, where it is increasingly simple to attach supplemental documents of all types to a publication, this is not at all commonplace. In fields like mathematics, a paper has no significance until every step is thoroughly checked by peers, but the same kind of rigorous peer-review is simply impossible. In this lab, this is precisely what I will attempt to do.

Replicability translated into geography can be understood in two ways. The first is whether two geographers arrive to the same conclusion about a place by using separate data sources but identical methodology. Unless the study is conducted in a data-rich place (or the extent is small so that data collection can be done by a small team of researchers), it is of course difficult to test this kind of replicability. The second is whether the same methodology employed with a different dataset from another place leads to the same conclusion. This is a tricky undertaking because no two places are alike, and different places experience different sociopolitical, environmental and economic forces. For example, a study on the segregation pattern in American suburbs cannot be meaningfully replicated in the context of a French suburb. In this lab, we will explore what replicability means in vulnerability research. 

## Malcomb et al.: Conceptualization and Methodology <a name="malc"></a>

### Conceptual rationale <a name="malc-a"></a>

Malawi is small landlocked nation in Southeastern Africa, and despite its size, its population density is one of the highest in the region, and is expected to double by 2035. 85% of the population live in rural areas and most rely on rain-fed agriculture; food security is a growing concern. Facing climate change, there is a strong interest in measuring vulnerability to ensure that funding streams of development loans are directed to the households most in need. As Hinkel has pointed out, “Assessing vulnerability thus has moved from being an academic exercise to being a political necessity” (2011). However, existing indices of vulnerability, they claim, have largely neglected the human dimensions, only focusing on indicators of flood, drought, precipitation and temperature. The goal of the authors is to create a new model of vulnerability assessment that “accounts for the complex physical and cultural dynamics at the household level” and one that is easily replicable to other countries. 

### Methodology <a name="malc-b"></a>

The model the authors created is a hierarchical one that divides vulnerability into four ‘metathemes’ which they identified through field work and interviews. These interviews were intended to reveal the “household social and economic practices in the context of environmental uncertainty”. This community level interview was interpreted with the help of local government, NGO’s, and development organizations. 

 1)	Assets of land, livestock, and income
 2)	Access to markets, food, water, healthcare and labor
 3)	Livelihood sensitivity based market exposure, crop productivity and use of natural resources for coping with disasters
 4)	Physical exposure to recurring floods and droughts. 

These metathemes were subdivided into indicators based on the interviews and data availability. Each indicator was then reclassified into a quintile score and their weighted sum produced the final resilience score. 

<img src="/lab8/metatheme.png" width="800">

## Reproducing Adaptive Capacity Map <a name="rac"></a>

### Data Used <a name="rac-a"></a>

#### Demographic and Health Surveys (DHS)

[DHS]( https://dhsprogram.com/What-We-Do/Survey-Types/DHS.cfm) is conducted by [USAID]( https://www.usaid.gov/) every five years and collects nationally representative high-volume data on health and population in developing countries. This survey is conducted at the household level, but to protect confidentiality, the geospatial information is not available at this scale. Instead, several neighboring households are grouped together into a cluster, and the cluster’s coordinates are randomized within a certain area (5km radius for rural areas and 2km for urban) that does not cross the district border. There are around 850 clusters in Malawi (area of 120,000 km2). This data contains several hundred columns for each household documenting anything from the number and type of cattle to respondent’s smoking habit. We used data from 2010 as the authors had done, but unfortunately it cannot be shared due to DHS’s policy. Fortunately, the data is easily obtainable via their website but it does require a formal request. Here you can download the metadata: [DHS_metadata.text](/DHS_metadata.text), [DHS_Survey_Vars.pdf](/DHS_Survey_Vars.pdf).

#### Traditional Authority shape file
The shape file for the TA was obtained via the [GADM database](http://www.gadm.org). 

#### Malawi lakes shape file
The shape file for the major lakes of Malawi made by OpenStreetMap was obtained through the [Malawi Spatial Data Platform]( http://www.masdap.mw/).

#### Download files
Download Malawi lake shapefile [here](/major_lakes.shp).
Download TA and DHS cluster shapefiles [here](/mwi_data.zip).

### Retracing the steps <a name="rac-b"></a>
We followed Malcolm et al.’s methodology and instructions (where they existed) to attempt to reproduce the Adaptive Capacity map. However, the results were much less than satisfactory, even though we started with the same dataset as the authors. We attribute this to the significant holes in their explanation of important decisions (i.e. sources of biases) that went into the production of the map.

To create this map, the first step was to add a column to our survey data table that indicates the id of the TA in which it resides, since the results would later be aggregated by TA. However, the survey data has no coordinate information, only the cluster id. So, we added a TA id column to a separate shapefile containing the point geometries of the clusters and this column was populated using a simple `st_intersects()` operation with the TA layer. Then, this TA id column was joined to the survey table via cluster id.  

Then, we looked through at the metadata of the survey to locate the columns that the authors referenced. There was some guesswork involved, for example, the authors did not specify what animals count as livestock. These were the columns we chose to use. 

```
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
```

It was also important to identify via metadata, how the null values are signified, because this depends on the column. For example, the no-data value could be ‘9’, ‘99’ or ‘98’. Rows containing null values were deleted. 

The next step involved quantifying the survey results and dividing into quintiles. This step was the hardest to reproduce, and there was a lot of guesswork, as few details were ever published by the authors. Even the steps written down by the authors are unclear at times, for example the authors mention that the data was split into quintiles where the lowest quintile was given a score of 0 and the highest, a 5. This makes no sense as a scale from 0 to 5 is in fact a sextile. An example of the kind of guesswork involved is the binary yes-no question. How a binary is mapped to a quintile has rather significant implications because it affects its weight: 1 for no and 5 for yes carries a much larger weight than 2 and 4 respectively. Considering 5 out of the 7 criteria in the access category is a binary question, this is an unacceptable oversight. 

Next, the scores were weighed and added to recreate the final adaptive capacity score for each household. We weighed the scores in such a way (scale of 0.4 to 2) that the total household resilience score would be on a scale of 1 to 5. It is unclear how the authors scaled their score, as the capacity score is reported to have a range of -0.80 to 39.33 at the household level. The negative score is curious, since it is unclear how a quantile score ranging from 0 to 5 could possibly produce such a number, but this is not explained. Finally these scores were aggregated using their TA id, averaged and joined with the TA layer to create this map: 

<img src="/lab8/capacity-comp.png">

The map we created is similar but it is no reproduction of the one by Malcomb et al.. Although we tried our best, the lack of important instructions in the methodology of Malcolm et al. made it impossible to reproduce the map, even with same data set. 

The SQL file for all the operations done in this step is found [here](/vulnerabilitySQL.sql). You can look through the code to see how we decided to quantify the results. 


### Uncertainty propagation and ethics of data presentation<a name="rac-c"></a>

Attempting to reproduce the map raised questions of uncertainty propagation that was never brought up by the authors. As Tate (2013) reminds us, when we deal with aggregation, we must always consider the areal unit problem which "manifests as a combination of a scale problem, where correlations between variables often increase with the level of aggregation, and an aggregation problem, in which correlations between enumeration units might depend as much on the manner of the aggregation as the relationships between variables". 

We propose that the method of data collection by the DHS makes this dataset not suitable for aggregation at the TA scale. As we discussed earlier, the survey is designed to be representative of the population of Malawi at the national scale. Although not explicitly stated, we can infer that this is also true at the district scale. We saw that the coordinates of the clusters were randomized in such way to never cross the district borders. This we presume is because the clusters were chosen to be representative of their district.

A similar guarantee does not exist at the level of the traditional authorities. There are 203 traditional authorities in the small nation of Malawi. This makes the coordinate randomization of 2-5km a very significant source of uncertainty; a point that was in a given TA could easily have been randomized to end up in a neighboring one. Malcolm et al. chose to aggregate at this level because they believed that at the district level, local hotspots of vulnerability could be averaged out and made invisible. They claim TA to be the lowest meaningful administrative level for aggregation, but with so much uncertainty, I disagree with their rationale and decision.   

This also raises a question about the ethics of data presentation by the USAID. Although the DHS survey is extensive, there are only 850 clusters nationwide; that is, on average 30 clusters chosen per district to best represent that district. Then, how much do the real coordinates of those clusters truly mean? Put another way, imagine you are tasked to find 30 people in a large concert hall to best represent the audience. The real coordinates of these 30 people, i.e. their seat numbers, mean very little, in so much as guaranteeing that they were in fact attending the concert. The seat numbers cannot be used to conclude anything about the population geography within the concert hall, but the 30 people as a sample together can be used to infer conclusions about the population geography within the larger city: the kind of person who attends a certain concert hall in a certain neighborhood. Thus, the geolocations of the clusters are only useful, in so much as guaranteeing that they lie within the district. This raises the question of whether it is even appropriate/ethical on the part of USAID to publish point data that can be used inappropriately. Is it not more fitting to publish the survey data with their district name but without cluster numbers? 


## Reproducing Vulnerability Map <a name="rv"></a>

### Data used <a name="rv-a"></a>

The vulnerability map is the synthesis of the map created above, the livelihood sensitivity map, and the physical exposure map. Two additional data sources are required. 

#### Famine Early Warning System Network (FEWSNET) and Malawi Vulnerability Assessment Committee (MVAC) 
11 livelihood zones were established by FEWSNET to group populations with similar farming practices and coping strategies. Vulnerability was calculated using the distribution of economic class within these zones along with metrics of food security, income source, susceptibility to market shocks and their coping strategies in the time of crisis. FEWSNET makes available the shape file for these zones on the internet, however, MVAC has no internet presence and its 2005 livelihood sensitivity data used by the authors could not be found. So, unfortunately reproduction of the complete vulnerability map is impossible. Download the livelihood zone shape files [here](/MW_LHZ_2009.shp).
<img src="/lab8/livelihood-zn.PNG" width="400">

#### UN Environment Programme’s flood and drought rasters 

[UNEP Global Risk Platform]( https://preview.grid.unep.ch/ ) is a multi-agency effort to make available, the global natural hazard risk and exposure data. The article specifically uses the data for estimated flood risk and physical exposure to drought events. You can download the raster for the whole world, but it is more useful to use their `Data-Extraction` feature to download the raster with Malawi’s extent. 

The authors used the Drought Physical Exposure raster from 2012. The file I found was time-stamped 2014 on the [website](https://preview.grid.unep.ch/index.php?preview=data&events=droughts&evcat=1&lang=eng) but the xml metadata file was stamped 2009. So, I am unsure exactly what year the data is from, and whether I have the same raster as the authors’. However, 2012 lies between 2009 and 2014, so I will say that the raster I used was at least very similar to the one used by Malcolm et al.The raster reports the absolute number of inhabitants at risk. This raster was created using three data sources, and its provenance is detailed in the website. The extent of the raster covers Malawi (32.66, -17.08 : 35.82, -9.33), its reference system is WGS84 and has a spatial resolution of 0.04166 degrees or 600 meters. 

The flood risk data was however, problematic. The file when downloaded using the `Data-Extraction` feature had the wrong extent, and was corrupt. Therefore, it was necessary (although not ideal) to download the global raster. It had to be cropped later. This raster gives a quintile scale based on the amount of risk. The data is from in 2011, same as the authors’. The reference system is WGS84 with spatial resolution of 0.08333 in decimal degrees or 1200 meters. 

### Retracing the steps <a name="rv-b"></a>

Because of data unavailability, only the sensitivity portion could not be reproduced. The final map (which is 80% of Malcolm et al.’s map) is the weighted sum of the capacity map, converted into raster form and the two reclassified rasters for drought and flood. 

Although it would have been a good learning exercise to perform the next sequence in PostGIS, in the interest of time, we used GRASS and GDAL tools instead. However, in my independent project, I completed this section using PostGIS. For this lab, we used the Graphical Modeler on QGIS to automate parts of the process. 

<img src="/lab8/model1.PNG" width="800">

Since we are dealing with rasters of varying spatial resolution, the first step was to decide on the spatial resolution for the final output. Conventional wisdom says that we should match the output resolution with that of the lowest resolution raster. However, the author takes the opposite approach and in this exercise, I made two versions. I only explain in detail the steps taken to create the low-resolution map (0.0833 deg.), but making the high-res map involves only a tiny modification to the QGIS model. 

The first step was to create three rasters for capacity, drought, and flood, with identical domain and spatial resolution. The domain of this map is based on data availability of the capacity map and the domain of the livelihood zones. Therefore, the first step is to convert the capacity map into a raster map with the correct domain and cell size. Then, the second step is to rescale the cell sizes on the two remaining rasters, and use the capacity map as a sort of stencil to match the domain on all three rasters. 

Before converting the vector capacity layer into a raster, the null values were filtered out using `Extract by expression`. Then the output was cropped with the `Clip` function to match the extent of the livelihood zones shapefile. This was then fed through `Rasterize` with cell size as 0.0833 degrees to create the capacity raster. The flood layer has the correct cell size, but it was first cropped to match the extent of the drought raster: `Clip raster by extent`. Then it was further cropped using the capacity raster with `Clip`. Finally, the cell size of the drought layer was changed to 0.0833 and it was cropped using the capacity raster as well. 

With all three rasters having the correct domain and cell size, the last step was to reclassify into quintiles before performing a weighted sum. Luckily, the flood layer was already in a quintile form (0-4) so only the drought layer needed to be reclassified. First, we used the GRASS extension `r.Quantile`, which outputs the quintile breaks in html form. These breaks were then inputted to `r.Recode` to reclassify the raster. The final step was performed with GDAL `Raster Calculator`. Malcolm et al. calculated their score as _Adaptive Capacity + Livelihood Sensitivity - Physical Exposure_ which means that like their capacity map, a low number represents high vulnerability. Thus, we had to invert the quintile numbers for the flood and drought rasters (by subtracting from 6) before adding. Since the capacity layer had already been weighted, it was just added:

```
FINAL_SCORE = (6 - (DROUGHT_QUINTILE + (FLOOD + 1))) * 0.2 + CAPACITY
```

<img src="/lab8/final.png">

Download the models used for [low-res](/vulnerability.model3) and [high-res](/vulnerability-2.model3). 

### Sources of uncertainty <a name="rv-c"></a>

Looking at the map we created and the one created by the authors, the difference is immediately apparent. Although the southern portion looks more or less similar, the region to the West and North of Lilongwe is completely unalike. Of course, this is likely due in part to the 20% of data we are lacking. However, there might be more to it. The map by the authors cite the ‘Dartmouth Flood Observatory Data 1999-2007’ as one of their data sources in the map, even though they claimed to have used the UNEP flood data in their paper. Did they encounter the same error when trying to download the flood data from UNEP and changed data sources? If so, it is appalling that the authors did not mention so in their article. 

In addition, this map again raises question about uncertainty. The authors chose to match the spatial resolution of the final output to that of the highest resolution data source: the drought raster. In my map, the pitfalls of this strategy are evident, as most of the fine details comes uniquely from the drought raster. Just have a look at the drought raster and the similarities are clear:

<img src="/lab8/drought-hr.png" width="300">

This is because for each pixel in the flood raster, there are four pixels in the drought raster. The traditional authorities have an even lower spatial resolution at only 203 unique elements across the entire map. If the small details in the map do not point to small variations in vulnerability, but only to the small variations in one of the layers, it makes little sense to output the final map at this high of a resolution. Here is a lower resolution alternative to our final map: 

<img src="/lab8/lowres.png" width="500">

The drought layer brings another source of uncertainty and error. Unlike the other layers, this raster presents its data in absolute terms: the number of prople exposed to drought. Tate (2013) mentions in his paper that "using absolute size, the areas of greatest vulnerability will always be those with the greatest population". To be consistent with the other layers, the authors ought to have normalized the values by population before reclassifying it into quintiles. 

## Comments on Uncertainty in Vulnerability Research, Reproducibility, and Replicability <a name="conc"></a>

In attempting to reproduce the maps made by Malcomb et al., we have discovered uncertainty at the micro-level. When decisions are made without regard to the uncertainty of the dataset, these uncertainties will be propagated and even be magnified, potentially altering the final output in significant ways. For example, we saw this when the authors aggregated data at a higher spatial resolution than appropriate, creating misleading outputs. We also observed the sensitivity of vulnerability models to small variations in procedure. The capacity map was recreated using the same data and method, but small differences in procedure lead to significantly different outputs. 

There is also another, more macro-level source of uncertainty. As Jochen Hinkel (2011) points out, vulnerability cannot be ‘measured’, because it does not denote an observable phenomenon, but it is rather a theoretical concept. What we can do is to make the concept operational, using indicators: to map it using observable concepts. Therefore, the choice of indicator is the most consequential decision to be made in a vulnerability assessment. However, there exist no formalized strategies to do this; there is no consensus on what inputs to use or how to weigh these inputs, and this precisely is the greatest source of uncertainty in the vulnerability assessment. Despite the repeated assurance by the authors that the inputs selected were ‘evidence based’, I must agree with Hinkel that due to the complexity of the systems, the many variables needed, and the little amount of data available, there is too much uncertainty for a vulnerability study at this scale to be useful. 

In their conclusion, the authors claim that their new multi-scale, multi-indicator approach is flexible enough to be expanded into 43 other countries in Africa where there exists similar DHS data. They are essentially claiming that their results are replicable across the whole continent: let us examine this in detail. In the methodology section, they tell the readers that the “selection of alternate indicators from the DHS surveys and expert-based weighting of variables are two measures of flexibility offered to policy-makers when employing this model”. In the same paragraph, they acknowledge that for the Malawi model, they went through multiple iterations of the weighting schemes until it finally outputted a map that matched their expected distribution of vulnerability based on the interviews they conducted. Essentially, Malcolm et al.’s claim to replicability is that the model’s indicators and the model itself can be altered and iterated until it outputs a map that satisfies the policy-maker’s idea of vulnerability. This assertion of replicability is absurd, and it further supports the argument by Hinkel that “indicators are often only used ‘symbolically’ for legitimizing decisions that would have been taken anyway” and are therefore subject to misuse. Of course, Malcolm et al. intended this flexibility, not for the misuse by policy makers, but to make the model adaptable to the varying environmental, sociopolitical and economic drivers of vulnerability across space and time. However, if these drivers are so divergent and require a case-by-case consideration, it seems that there is no place for replicability in the study of vulnerability (at least at the national scale). 

