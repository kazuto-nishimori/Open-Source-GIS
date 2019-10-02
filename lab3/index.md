This page will go over the very basics of terrain analysis using publicly availble NASA DEM data, as well as the open source software SAGA. [SAGA](http://www.saga-gis.org/en/index.html) been around since 2004, and it is a software ideal for physical geography analysis using raster data. 


Firstly, let us collect data from the [NASA Earthdata portal](https://search.earthdata.nasa.gov/search). In the search box, we enter the type of data, in this case, I am opting for the Shuttle Radar Topography Mission (SRTM) 1 arcsecond dataset. This data was obtained in one of the Space Shuttle missions, where during orbit, two radar sensors were placed at a significant distance apart to measure the elevation of the terrain from parallax. 1 arcsecond, i.e. 30 meters per pixel width, should provide the adequate definition for our project today. Alternatively, the Aster Global DEM dataset collected by a join US-Japanese satellite mission is also useful.

![Finding Data](Capture.PNG)

We then prepare the dataset for analysis. The raster data is imported into SAGA and opened in a map. If there are multiple rasters covering the area of interest, as is the case with mine, there will be an obvious discontinuity between the rasters upon opening them in the same map. However, this is (probably) not due to the dataset, but the representation of the data, as colors are assigned based on the relative highs and lows of each raster. To fix this, we must make a mosaic of the rasters (Tools -> Mosaicking). Chose the bilinear interpolation for the sampling method, since this is a quantitative raster. I will chose the appropriate Left, Right, Top, and Bottom coordinates to crop my final mosaic. Lastly, we will reproject the layer to the correct UTM zone (Tools -> Projection -> Proj.4 -> UTM Projection (Grid)).

![Pre-Mosaic](Capture1.PNG)
![Post-Mosaic](Capture2.PNG)

From here, all sorts of things are possible in SAGA. However, before continuing, be sure to save the file, as SAGA can crash unexpectedly from time to time. Hillshading is a great place to start, as it facilitates the visualisation of our data. (Tools -> Terrain Analysis -> Lighting, Visibility -> Analytical Hillshading). Parameters should be modified as desired. One thing to note is that the default position of the sun is often at an angle that is physically impossible i.e. rays from the north in the northern hemisphere. Especially in fields such as cartography, one must make a conscious decision about the placement of the sun, whether to favor realism or legibility (the default setting looks natural to right-handed individuals who often illuminate their desk from the upper left position).

![Hillshade](Capture3.PNG)

We will also tryout a hydrological analysis. First, let us run the sink drainage route tool to detect sinks and which direction water would flow upon encountering a sink (Tools -> Terrain Analysis -> Preprocessing -> Sink Drainage Route). We then fill in these sinks using the sink removal tool (Tools -> Terrain Analysis -> Preprocessing -> Sink Removal). 

![Sink](sink.png)

This graphic can be helpful in understanding sinks in an hydrological system. The sink removal tool fills in these sinks and gives us a new elevation model.

![Sink Drainage Route](Capture4.PNG)
![Sink Drainage Route Zoom](Capture5.PNG)


Next, we will try the flow accumulation model (Tools -> Terrain Analysis -> Hydrology -> Flow Accumulation (Top-Down)). This tool maps out, for each cell, how many cells contribute to its water flow. This is helpful in detecting where stream starts and how they build up. 

![Flow Accumulation](Capture6.PNG)
![Flow Accumulation Zoom](Capture7.PNG)

Finally, a useful tool is the channel network tool that creates both a raster and vector representation of these channels that we can export and use in other GIS software. (Tools -> Terrain Analysis -> Channels -> Chanel Network)

![Channel Network](Capture8.PNG)
![Channel Network Zoom](Capture9.PNG)

