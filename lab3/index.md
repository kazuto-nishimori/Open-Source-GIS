This page will go over the very basics of terrain analysis using publicly availble NASA DEM data, as well as the open source software SAGA. [SAGA](http://www.saga-gis.org/en/index.html) been around since 2004, and it is a software ideal for physical geography analysis using raster data. 


Firstly, let us collect data from the [NASA Earthdata portal](https://search.earthdata.nasa.gov/search). In the search box, we enter the type of data, in this case, I am opting for the Shuttle Radar Topography Mission (SRTM) 1 arcsecond dataset. This data was obtained in one of the Space Shuttle missions, where during orbit, two radar sensors were placed at a significant distance apart to measure the elevation of the terrain from parallax. 1 arcsecond, i.e. 30 meters per pixel width, should provide the adequate definition for our project today. Alternatively, the Aster Global DEM dataset collected by a join US-Japanese satellite mission is also useful.
![Finding Data](Capture.PNG)

We then open SAGA and import the raster data and open it in a map. If there are multiple rasters covering the area of interest, as is the case with mine, when opening them into one map, there will be an obvious discontinuity between the rasters. However, this is (probably) not due to the dataset, but the representation of the data, as colors are assigned based on the relative highs and lows of each raster. To fix this, we must make a mosaic of the rasters (Tools -> Mosaicking). Chose the bilinear interpolation for the sampling method, since this is a quantitative raster. I will chose the appropriate Left, Right, Top, and Bottom quantities to crop my final mosaic. 
![Pre-Mosaic](Capture1.PNG)
![Post-Mosaic](Capture2.PNG)
