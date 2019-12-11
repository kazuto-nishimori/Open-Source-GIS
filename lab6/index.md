# OpenStreetMap Data on PostGIS

## Table of Contents

1. [Objective](#goal)
2. [Setting Up the Environment](#env)
    1. [Loading OSM data to PostGIS](#env-a)
    2. [Loading RA data to PostGIS](#env-b)
3. [Software and Documentation](#sw)
4. [Looking at the Data](#look)
    1. [OSM data](#look-a)
    2. [RA data](#look-b)
5. [Workflow](#flow)
6. [Analysis](#ana)
    1. [Quantifying trash score](#ana-a)
    2. [Creating blocked waterway buffer](#ana-b)    
    3. [Selecting targeted waste sites](#ana-c)
    4. [Summing the trash score](#ana-d) 
7. [Visualising Results](#res)  
8. [Interpreting Results](#int)  

## Objective <a name="goal"></a>

The goal of this lab is to use OpenStreetMap (OSM) and Tanzania Resilience Academy (RA) data to quantify a dimension of vulnerability, and create a visualization at the sub-ward level to aid policy action. I will specifically be looking at the vulnerability caused by the build-up of rubbish in areas that are near existing drain blockages, but are inaccessible by vehicle. The goal of my final visualization is to highlight the sub-wards that are in dire need of reviewing its road and trash-collection infrastructure to lower their vulnerability to the next big flood. 

<img src="https://www.straitstimes.com/sites/default/files/styles/article_pictrure_780x520_/public/articles/2017/01/05/40648403_-_23_11_2016_-_tanzania-weather-daily-life.jpg?itok=K8AwbN0r&timestamp=1483572716">

source:[The Straight Times](https://www.straitstimes.com/world/africa/tanzania-slum-uses-drones-to-map-out-flood-risk)

## Software and Documentation <a name="sw"></a>

### Software used

- [QGIS 3.8.1](https://www.qgis.org/en/site/) 
- [PostGIS 2.5.3](https://postgis.net/source/)
- [PostgreSQL 11.5](https://www.postgresql.org/download/)
- [OSM2PGSQL Plugin](https://github.com/openstreetmap/osm2pgsql)

### Documentation Referenced
- Lab Instructions by Professor Holler: [request document by email](mailto:jholler@middlebury.edu)
- https://www.w3resource.com/

## Setting Up the Environment <a name="env"></a>

The first step is always to find and import data. The two datasets used in this study, OSM and RA, offer community mapping data collected by volunteering citizens. There is a strong interest in this type of crowdsourced data in geospatial analysis, not only for the sheer volume of data newly available (think of OSM’s efforts in Haiti) but also for the method with which the data was collected: data collection by community leaders and members who have lived experience in the area concerned. 

<img src="/lab6/RA-Shield_Horizantal.png" height ="200"> <img src="/lab6/Openstreetmap_logo.svg.png" height ="200">

### Loading OSM dataset to PostGIS server <a name="env-a"></a>

We will be using a command line tool called [OSM2PGSQL](https://github.com/openstreetmap/osm2pgsql) to import the OSM data into our PostGIS server. Professor Holler has kindly set up the tool ready to be used for this lab. The `dsm-osm.osm` file was downloaded straight from OpenStreetMap using its export feature. The `dsm.style` file instructs the tool, which features to load and which tags to use. You should look through the file and add/modify any features or tags not already mentioned. For my analysis, this was not necessary. Finally, the `convertOSM.bat` file performs the import function. The code locates the OSM2PGSQL tool, `dsm_osm.osm` file and the PostGIS server; the addresses must be modified accordingly. When it is done, run the batch file. 

- Download the [OSM data](https://www.openstreetmap.org/export#map=11/-6.8240/39.3026) (unfortunately my file was too large to be uploaded to Github, so the link takes you to OSM) 
- Download the [batch script](convertOSM.bat) and [style file](dsm.style)

### Loading RA dataset to PostGIS server <a name="env-b"></a>

The RA data can be downloaded to QGIS straight from its Web Feature Server (WFS) and then imported to our database. In QGIS `Browser`, right-click `WFS` and go to `New Connection` and enter the URL https://geonode.resilienceacademy.ac.tz/geoserver/ows. Open the ‘Dar es Salaam Waste Sites’ layer in QGIS. Then open `DB manager`, click `Import Layer/File`, and chose the layer. Be sure to rename it to have all lowercase, as SQL does not fare well with uppercase letters. I renamed by layer ‘ws’. Do the same for the ‘Dar es Salaam Administrative Subward’ layer. The data table of this layer has many incomplete rows including on the id column. The 'fid' column however is complete, so during import, you must designate the id column to ‘fid. 

## Looking at the Data <a name="look"></a>

### OSM data <a name="look-a"></a>

Let us visualize the OSM data we will be working with, namely the waterway data. Certain segments of the waterways have a tag indicating that it has a blockage. We will visualize both using a few lines of SQL in the Database Manager.

The following code isolates the waterway line segments. 
```sql
SELECT* FROM planet_osm_line
WHERE waterway IS NOT NULL
```
Then, click on load as new layer. I will do the same for blockages. 
```sql
SELECT* FROM planet_osm_line
WHERE waterway IS NOT NULL AND blockage IS NOT NULL AND blockage <> ‘no’
```
			
<img src="/lab6/image0.PNG" width="800">

Blocked waterways in magenta, layered on top. Waterways in green. 

We see that the line segments are mostly concentrated at the downtown area in the center of the map. Since waterways include not only manmade drainage systems but also streams and rivers, this is a flaw in the dataset; some areas are simply not mapped. However, this should not pose a problem to our research as the data is complete in the areas we are most interested: highly populated, low elevation/coastal regions where flood risk and vulnerability are highest. Comparing with the population map, we see that the waterway map is complete in the highly-populated districts. So, I conclude that this data is complete enough for our research. 

<img src="https://www.researchgate.net/profile/Marcia_Castro4/publication/42346117/figure/fig1/AS:340846374342658@1458275516854/Population-density-by-ward-and-major-roads-in-Dar-es-Salaam-Tanzania-2006-Ward.png" width="400">

<sub><sup>Source: Penrose, Katherine & Castro, Marcia & Werema, Japhet & Ryan, Edward. (2010). Informal Urban Settlements and Cholera Risk in Dar es Salaam, Tanzania. PLoS neglected tropical diseases. 4. e631. 10.1371/journal.pntd.0000631.<sup><sub>

<img src="/lab6/image01.PNG" width="400">

#### A note on possible source of error

Zooming in, we see inconsistency in the way blockage is labeled. For some waterways, the entirety of its length is tagged as blocked. In others, only a small segment of the waterway (presumably the segment where the blockage is) is tagged. This will obviously create inconsistencies in the final analysis. 

### Resilience Academy Waste Site Data <a name="look-b"></a>

Let us also visualize the RA’s data using QGIS. Each point corresponds to a waste site. 

<img src="/lab6/image1.PNG" width="800">

The points are concentrated in the downtown area as one would expect, but half of the wards do not have a single data point. For the underpopulated, peripheral regions, this makes sense. However, there is a notable lack in data in the southern portion of central Dar es Salaam, namely the Mbagala and Kurasini areas. This will introduce a significant gap of knowledge to our study, since these areas are of extreme interest: highly populated and with significant drain blockages. 

Several columns in this dataset are unique and interesting, and they prompted me to conduct this research in the first place. The access_typ column shows the accessibility for each waste site: foot only, by cart or by truck. The trash_size column reveals the size of the site: handful, bagful, cartload, or truckload. These two columns are the most useful for our research. Since we are interested in the inaccessible sites, the points with foot only access will be isolated. We can easily isolate the points of interest with a quick SQL line in the DB manager. 
```sql
SELECT* FROM ws
WHERE access_typ = `Foot only`
```
Then, click on `load as new layer`. I used symbology to differentiate the trash size. Blue is handful and red is truckload.

<img src="/lab6/image2.PNG" width="400">
<img src="/lab6/image3.PNG" width="400">

#### A note on possible source of error

Zooming into the data reveals another possible source of error to our analysis. Many points hover around the border between sub-wards, possibly because these borders were defined by some geographical feature that has since become a dumping ground, most likely a river or a stream. Therefore, aggregating data in terms of sub-wards in fact does not make too much geographic sense; a blockage at the border is a problem for both neighboring sub-wards. However, I will continue with this aggregation method since it makes political sense: policy changes happen within these borders.  


## The Workflow <a name="flow"></a>

The workflow for this analysis is simple. In the end, I want to have within my sub-ward table, a column with a score, normalized by area, based on the amount of trash that is near existing blocked waterways. The steps are the following:
1)	Quantify the amount of trash for each site into a ‘trash score’. 
2)	Create a buffer from the blocked waterways. 
3)	Select all sites that are only accessible by foot, and lie inside the buffer.
4)	For each sub-ward, sum the trash scores of the sites of interest within its border, and normalize it by the area. 

## The Analysis <a name="ana"></a>

### Quantifying trash score <a name="ana-a"></a>

We must convert the qualitative indication of trash size (handful to truckload) to a quantitative score. This must necessarily introduce an element of bias: the choice of number here is completely arbitrary. In fact, there will be two layers of bias if we count the bias at the data collection stage, since one person’s handful could be another’s bagful. I chose a handful as our unit, bagful as 10 units, cartload as 50 and truckload as 250. I presumed that the ‘truck’ here referred to a pick-up truck so 25 bags seemed an appropriate amount. 
```sql
ALTER TABLE ws ADD trash_score INT;
UPDATE ws 
SET trash_score = 
CASE 
WHEN trash_size = `Handful` THEN 1
WHEN trash_size = `Bagful` THEN 10
WHEN trash_size = `Cartload` THEN 50
WHEN trash_size = `Truckload` THEN 250
END
```
### Creating blocked waterway buffer <a name="ana-b"></a>

We will create a new table for the buffer. Whenever creating a new table, it is paramount to include a unique id as one of our columns as I have done in the `SELECT` line. You might also notice that I put all the columns I wish migrate to the new table, namely the blockage and waterway columns. The last part of the `SELECT` line selects the 20-meter buffer and designates it the new geometry column for the table. The `WHERE` line makes sure that I only select only the blocked waterways. 
```sql
CREATE TABLE waterway_buffer AS 
SELECT osm_id, blockage, waterway, st_buffer(geography(a.way), 20)::geometry(`polygon,4326`) AS geom
FROM planet_osm_line as a
WHERE blockage IS NOT NULL AND blockage <> = `no`
```
### Selecting targeted waste sites <a name="ana-c"></a>

Now, we create a Boolean column indicating whether it lies within the buffer. After we make the column, we set it to false. We then change it to true for all points that intersects the buffer, an operation performed by `st_coveredby`.
```sql
ALTER TABLE ws ADD near_blockage BOOLEAN; 
UPDATE ws SET near_blockage = FALSE;
UPDATE ws
SET near_blockage = TRUE
FROM waterway_buffer as a
WHERE st_coveredby(ws.geom,a.geom)
```
Let us make a new table called `ws_mod` that only consists of the sites we are interested in, namely those with foot only access, near a blockage, and have a trash score. 
```sql
CREATE TABLE ws_mod AS
SELECT* FROM ws
WHERE access_typ = `Foot only` AND near_blockage = TRUE AND trash_score IS NOT NULL
```

### Summing the trash score <a name="ana-d"></a>

To perform zonal statistics, we must first add a column in the waste site table that indicates the sub-ward district it is in. Then, we group the sites by their sub-ward ID and sum the score. This sum will be added to a new column in the sub-ward table. 

Let us add a sub-ward id column to the `ws_mod` table. 
```sql
ALTER TABLE ws_mod
ADD COLUMN sw_id INT;
UPDATE ws_mod
SET sw_id = subwards.fid FROM subwards
WHERE st_intersects(ws_mod.geom,subwards.geom);
```
We then add columns to the subwards table for the score, area of the sub-ward, and the normalized score. Notice that I calculate the area using the `st_area` function. We also set the `score_sum` to be 0 for now. 
```sql
ALTER TABLE subwards
ADD COLUMN score-sum INT;
ALTER TABLE subwards
ADD COLUMN area FLOAT;
ALTER TABLE subwards
ADD COLUMN score-norm FLOAT;
UPDATE subwards
SET area = st_area(geom);
UPDATE subwards
SET score_sum = 0;
```

Finally, we are ready to perform the zonal statistics. This is where it gets tricky. We create a temporary table, which we call b. The `GROUP BY` function groups the trash scores into rows based on `sw_id`. The `sum` function adds the grouped scores. (One could swap in another function here such as `count` and `avg` to perform other kinds of statistics.) Once this temporary table b is made, the `score_sum` column is set to equal the output of the `sum` function, given that its sub-ward ID matches that of the other table. Finally, the column for the normalized score is updated.
```sql
UPDATE subwards
SET score_sum = a
FROM ( 
	SELECT sum(trash_score) AS a, sw_id
	FROM ws_mod WHERE sw_id IS NOT NULL
	GROUP BY sw_id 
) as b
WHERE subwards.fid = b.sw_id;
UPDATE subwards
SET score_norm = score_sum/area
```
And we are done!

## Visualizing Results <a name="res"></a>

One thing PostGIS cannot do is visualizing data: this must be done in QGIS. Drag and drop the `subward` table from the database manager to the main console of QGIS and it should create a new layer. I used symbology to create a choropleth map from the normalized trash score. The score was separated into five classes with natural breaks, but I added an extra class just for the value 0. This is because as we saw earlier, there is a gap in the waste site data, so a zero score does not necessarily mean zero vulnerability; it could simply be due to a lack of data. Therefore, I believed that it was important to visually distinguish the 0 values from low but non-zero values. 

<img src="/lab6/image5.PNG" width="400">
<img src="/lab6/image6.PNG" width="800">


Below is a map comparing the distribution of waste site points to our final map. Notice that there are zero values in data-rich regions in the west. These areas are true-zeros whereas the zeros in and around Mbagala and Kurasini are most likely due to the lack of data. I suppose we can distinguish these regions by giving these true-zero sub-wards (sub-wards that intersect with waste sites) a value of zero, and giving other sub-wards a null value. However, this is beyond the scope of this lab. 

<img src="/lab6/image8.PNG" width="400">

In the [next lab](/lab7), we will be going into more depth about visualizing data from this lab, and how to upload an [interactive map](/lab7/qgis2web_2019_12_02-00_18_52_126796) to the web! 

## Interpreting Results <a name="int"></a>

