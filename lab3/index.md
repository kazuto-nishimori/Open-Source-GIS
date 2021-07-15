# Global DEM and Error Propagation

## Table of Contents

1. [Objective](#goal)
2. [Software and Documentation](#sw)
3. [NASA Data Portal](#data)
4. [SAGA Analysis](#saga)
    1. [Mosaic](#saga-a)
    2. [Hillshade](#saga-b)
    3. [Sink drainage and removal](#saga-c)
    4. [Flow accumulation ](#saga-d)
    5. [Channel Network ](#saga-e)
5. [SAGA automation with Batch Script ](#saga)
6. [Comparing ASTER and SRTM](#comp)
<br>
---
<br>
## 1. Objective <a name="goal"></a>
This lab has two learning goals: 1) to become familiar with the open source terrain analysis software [SAGA](http://www.saga-gis.org/en/index.html) and 2) to learn to examine and compare raster datasets with a critical lens. SAGA is an opensource terrain analysis software has been around since 2004, and it is ideal for physical geography analysis using raster data. I will use two datasets, ASTER and SRTM, and through the analysis I will identify the dataset that is better suited for the study region.
<br>
---
<br>
## 2. Software and Documentation <a name="sw"></a>

### 2.1 Software used

- [SAGA 6.2](https://www.qgis.org/en/site/)
- [QGIS 3.8.1](https://www.qgis.org/en/site/)

### 2.2 Documentation Referenced
- Lab Instructions by Professor Holler: [request document by email](mailto:jholler@middlebury.edu)
- [SAGA help documentation](http://www.saga-gis.org/saga_tool_doc/7.4.0/index.html)
<br>
---
<br>
## 3. NASA Earthdata Portal  <a name="data"></a>

The [NASA Earthdata Portal](https://search.earthdata.nasa.gov/search) is a great resource for downloading high resolution digital elevation models from anywhere in the world. It is free to use, but require an account. For this lab, I will be examining Mount Kilimanjaro in Tanzania using two datasets: Shuttle Radar Topography Mission (SRTM) and the Advanced Spaceborne Thermal Emission and Reflection Radiometer (ASTER). SRTM data was obtained in the Space Shuttle missions, where during orbit, two radar sensors were placed at a significant distance apart to measure the elevation of the terrain from parallax. ASTER, a joint US and Japanese venture uses a satellite to capture stereoscopic visible and infrared images. For both datasets, I will be using rasters at a resolution of 1 arcsecond, i.e. 30 meters per pixel width, which should provide enough definition. In the later sections, I will discuss the strengths and weaknesses of the datasets for our study region of Mount Kilimanjaro.
<br>
---
<br>
## 4. SAGA Analysis <a name="saga"></a>
An important note: Be sure to save the file often, as SAGA can crash unexpectedly.

### 4.1 Mosaic <a name="saga-a"></a>

Let us import the raster layers to SAGA. If there are multiple rasters covering the area of interest, as is the case with mine, there will be an obvious discontinuity between the rasters when opened in the same map. Fortunately, this is (probably) not due to the dataset, but the representation of the data, as colors are assigned based on the relative highs and lows of each raster. To fix this, I will make a mosaic of the rasters `Tools -> Mosaicking`. Choose the bilinear interpolation for the sampling method, since this is a quantitative raster. I will chose the appropriate bounding box coordinates to crop my final mosaic. Lastly, I will reproject the layer to the correct UTM zone `Tools -> Projection -> Proj.4 -> UTM Projection (Grid)`.
<details><summary>Before Mosaic</summary>
<img src="img/Capture1.PNG" width="500">
</details>
<details><summary>After Mosaic</summary>
<img src="img/Capture2.PNG" width="500">
</details>
<br>
### 4.2 Hillshade <a name="saga-b"></a>

Hillshading is a great place to start, as it facilitates the visualisation of our data. `Tools -> Terrain Analysis -> Lighting, Visibility -> Analytical Hillshading`. Parameters should be modified as desired. One thing to note is that the default position of the sun is often at an angle that is physically impossible i.e. rays from the north in the northern hemisphere. Especially in fields such as cartography, it is important to make a conscious decision about the placement of the sun, whether to favor realism or legibility (the default setting looks natural to right-handed individuals who illuminate their desk from the upper left position).

<img src="img/Capture3.PNG" width="500">
<br>

### 4.3 Sink drainage and removal <a name="saga-c"></a>

Let us perform a preprocessing step to prepare our raster for hydrological analysis. First, I run the sink drainage route tool to detect sinks based on unusual water flow `Tools -> Terrain Analysis -> Preprocessing -> Sink Drainage Route`. Sinks are usually due to noise in the dataset that causes bumps in the terrain:

<img src="img/sink.png" width="300">

<details><summary>Sink drainage output</summary>
<img src="img/Capture4.PNG" width="400">
   </details>
<details><summary>Zoomed in</summary>
<img src="img/Capture5.PNG" width="500">
</details>

To get accurate water flow route and channels, these sinks must be removed using the sink removal tool `Tools -> Terrain Analysis -> Preprocessing -> Sink Removal`. The output is identical to the original DEM to the naked eye.

### 4.4 Flow accumulation <a name="saga-d"></a>

Next, I will run the flow accumulation function `Tools -> Terrain Analysis -> Hydrology -> Flow Accumulation (Top-Down)`. This tool maps out, for each cell, how many cells contribute to its water flow. This is helpful in detecting where streams start and how they build up.

<details><summary>Flow Accumulation Output</summary>
<img src="img/Capture6.PNG" width="500">
    </details>
<details><summary>Zoom in</summary>
<img src="img/Capture7.PNG" width="500">
</details><br>

### 4.5 Channel Network <a name="saga-e"></a>

Finally, a useful tool is the channel network tool that creates both a raster and vector layer of water channels. They can be exported to be used in other GIS software. `Tools -> Terrain Analysis -> Channels -> Chanel Network`

<details><summary>Channel network output</summary>
<img src="img/Capture8.PNG" width="500">
    </details>
<details><summary>Zoom in</summary>
<img src="img/Capture9.PNG" width="500">
</details><br>
<br>
---
<br>
## 5. SAGA automation with Batch Script <a name="auto"></a>

SAGA analysis does not have to be done on the graphic user interface. Instead, there is a command-line tool, so one could easily write up a batch script to automate the analysis I did in the above section. This requires a little getting-used-to but it is exceedingly straightforward.
<img src="img/Capture.PNG" width="600">

Firstly, I will set all appropriate directories so that the command module can find the SAGA commands, input files, and output directory. Then, I include the tools to be executed.  All the SAGA tools in command line format is available on this [website](http://www.saga-gis.org/saga_tool_doc/7.4.0/index.html). Alternatively, right clicking on any tool in SAGA will reveal a `copy as command-line` option that is usually more convenient. Finally, I reference the website and include all appropriate inputs and outputs for each command, save and run!

#### Useful trick
Using variables with the `set` function can minimize mistakes and make the batch file easily adaptable. For example, the input and output directories can be defined using a variable, so that if these directories should change, it is only necessary to modify it once: no need to go through each command to change them.

The files I used are available for download here:
- [batch file](test.bat)
- [DEM file](ASTKilimanjaroDEMmosaic.sgrd)
<br>
---
<br>
## 6. Comparing ASTER and SRTM <a name="comp"></a>

Now that we have successfully automated the process, we can easily run a different dataset. I ran both the SRTM and ASTER rasters through the batch file. However, before doing that, I had to mosaic and reproject the rasters. The batch file for this process can be downloaded [here](mosaic_utmproj_dem_AST.bat).

Once I ran all of the SAGA analysis, I first took the difference of the rasters using `Grid -> Calculus -> Grid Difference`. This was done to show where the two rasters disagreed:

<img src="img/difference.PNG" width="600">

Two places stick out immedeately. The first is near the peak of Mount Kilimanjaro. The second is the lake.
<details><summary>Zoom in to Mt. Kilimanjaro</summary>
<img src="img/difference-zm.PNG" width="600">
    </details>
<details><summary>Zoom in to the lakes</summary>
<img src="img/difference-zm2.PNG" width="600">
    </details>

The difference around the lakes is plain and simple: it signifies the difference in calibration. However, the peak is curious. Let us take a close look at the hillshade around this region. I visualized the following in QGIS:

<img src="img/comp-1.png" width="1100">

Clearly, there is something going on in the SRTM layer. It appears as though huge chunks of data are missing, and filled in with interpolated results. Let us look at the num file for this region. Num files are metadata raster files that signify the provenance of the data. Indeed, the problematic area was derived from another source: GMTED2010 7.5 arcsecond. Compared to the 1 arcsecond SRTM data, the resolution is 8 times worse which explains the lack of detail. Perhaps the SRTM could not capture data here because of perpetual clouds over the valleys, but this is only speculation.

<img src="img/num.png" width="1000">

When we look at the channel network in the mountain peak region, both the SRTM and ASTER reveal errors. It seems like there is something about high elevation that makes data capture difficult. However, SRTM stands out as being much more affected (blue line)

<img src="img/peak.PNG" width="1000">

Looking at the hillshade revealed another problematic area in the SRTM. There appears to be unnatural striations in the data. This is not present in the ASTER dataset. I presume this has something to do with error caused while the shuttle was orbiting and scanning the region.

<img src="img/comp-2.png" width="600">

The striations were severe enough to affect the channel simulations in this region.

<img src="img/srtmdem2-1.PNG" width="600">

Finally, I noticed channel network gets confused in extremely flat areas. This might not have to do so much with the accuracy of the DEM; small differences in elevation will have significant effects in how the channel networks are drawn. Examine this close-up of a farm and a lake. The channel networks do badly in the flat farmland, and go haywire on the lake.

<img src="img/flat.PNG" width="600"><br>
<br>
---
<br>
#### 7. Which is better?

It is quite clear from these comparisons that ASTER data is a much more reliable digital elevation model compared to the SRTM, at least in the region around Mount Kilimanjaro.
