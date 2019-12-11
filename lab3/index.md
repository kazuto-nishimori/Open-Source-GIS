# Global DEM and Error Propagation 

## Table of Contents

1. [Objective](#goal)
2. [Software and Documentation](#sw)
3. [ollecting and Preparing Data](#data)
    1. [NASA](#data-a)
    2. [Preparing Rasters in SAGA](#data-b)
    3. [Extracting precise geographies](#rs-c)
    4. [Network analysis](#rs-d)
    5. [Text analysis](#rs-e)
    6. [Spatial analysis](#rs-f)


## Objective <a name="goal"></a>
The goal of this lab is 

## Software and Documentation <a name="sw"></a>

### Software used

- [SAGA 6.2](https://www.qgis.org/en/site/) 
- [Python]

### Documentation Referenced
- Lab Instructions by Professor Holler: [request document by email](mailto:jholler@middlebury.edu)
- http://www.saga-gis.org/saga_tool_doc/7.4.0/index.html
- https://www.w3resource.com/

#### Works cited



This page will go over the very basics of terrain analysis using publicly availble NASA DEM data, as well as the open source software SAGA. [SAGA](http://www.saga-gis.org/en/index.html) been around since 2004, and it is a software ideal for physical geography analysis using raster data. 

## Data <a name="data"></a>

### NASA Earthdata Portal 

The [NASA Earthdata Portal](https://search.earthdata.nasa.gov/search) is a great resource for downloading high resolution digital elevation models from anywhere in the world. It is free to use, but require an account. For this lab, we will be using Shuttle Radar Topography Mission (SRTM) 1 arcsecond dataset and looking at Mount Kilimanjaro in Tanzania. This data was obtained in a Space Shuttle mission, where during orbit, two radar sensors were placed at a significant distance apart to measure the elevation of the terrain from parallax. 1 arcsecond, i.e. 30 meters per pixel width, should provide the adequate definition for our project today. In the later sections, I will compare this SRTM dataset with another comparable dataset collected by a join US-Japanese satellite mission called the Aster Global DEM. We will explore the strengths and weakness of the datasets in the context of Mount Kilimanjaro. 

Aster Data?

## SAGA Analysis
An important note: Be sure to save the file often, as SAGA can crash unexpectedly.

### Mosaic 

Let us import the raster layers to SAGA. If there are multiple rasters covering the area of interest, as is the case with mine, there will be an obvious discontinuity between the rasters when opened in the same map. Fortunately, this is (probably) not due to the dataset, but the representation of the data, as colors are assigned based on the relative highs and lows of each raster. To fix this, I will make a mosaic of the rasters `Tools -> Mosaicking`. Choose the bilinear interpolation for the sampling method, since this is a quantitative raster. I will chose the appropriate bounding box coordinates to crop my final mosaic. Lastly, I will reproject the layer to the correct UTM zone `Tools -> Projection -> Proj.4 -> UTM Projection (Grid)`.
<details><summary>Before Mosaic</summary>
<img src="/lab3/Capture1.PNG" width="500">
</details>
<details><summary>After Mosaic</summary>
<img src="/lab3/Capture2.PNG" width="500">
</details>

### Hillshade

Hillshading is a great place to start, as it facilitates the visualisation of our data. `Tools -> Terrain Analysis -> Lighting, Visibility -> Analytical Hillshading`. Parameters should be modified as desired. One thing to note is that the default position of the sun is often at an angle that is physically impossible i.e. rays from the north in the northern hemisphere. Especially in fields such as cartography, it is important to make a conscious decision about the placement of the sun, whether to favor realism or legibility (the default setting looks natural to right-handed individuals who illuminate their desk from the upper left position).

<img src="/lab3/Capture3.PNG" width="500">

### Preprocessing: sink drainage and removal

Let us perform a preprocessing step to prepare our raster for hydrological analysis. First, I run the sink drainage route tool to detect sinks based on unusual water flow `Tools -> Terrain Analysis -> Preprocessing -> Sink Drainage Route`. Sinks are usually due to noise in the dataset that causes bumps in the terrain:

<img src="/lab3/sink.png" width="300">

<details><summary>Sink drainage output</summary>
<img src="/lab3/Capture4.PNG" width="400">
   </details> 
<details><summary>Zoomed in</summary>
<img src="/lab3/Capture5.PNG" width="500">
</details>

To get accurate water flow route and channels, these sinks must be removed using the sink removal tool `Tools -> Terrain Analysis -> Preprocessing -> Sink Removal`. The output is identical to the original DEM to the naked eye. 

### Flow accumulation 

Next, I will run the flow accumulation function `Tools -> Terrain Analysis -> Hydrology -> Flow Accumulation (Top-Down)`. This tool maps out, for each cell, how many cells contribute to its water flow. This is helpful in detecting where streams start and how they build up. 

<details><summary>Flow Accumulation Output</summary>
<img src="/lab3/Capture6.PNG" width="500">
    </details>
<details><summary>Zoom in</summary>
<img src="/lab3/Capture7.PNG" width="500">
</details>

### Channel Network 

Finally, a useful tool is the channel network tool that creates both a raster and vector layer of water channels. They can be exported to be used in other GIS software. `Tools -> Terrain Analysis -> Channels -> Chanel Network`

<details><summary>Channel network output</summary>
<img src="/lab3/Capture8.PNG" width="500">
    </details>
<details><summary>Zoom in</summary>
<img src="/lab3/Capture9.PNG" width="500">
</details>


## SAGA automation with Batch Script 

SAGA analysis does not have to be done on the graphic user interface. Instead, there is a command-line tool, so one could easily write up a batch script to automate the analysis I did in the above section. This requires a little getting-used-to but it is exceedingly straightforward. 
<img src="/lab3/Capture.PNG" width="600">

Firstly, I will set all appropriate directories so that the command module can find the SAGA commands, input files, and output directory. Then, I include the tools to be executed.  All the SAGA tools in command line format is available on this [website](http://www.saga-gis.org/saga_tool_doc/7.4.0/index.html). Alternatively, right clicking on any tool in SAGA will reveal a `copy as command-line` option that is usually more convenient. Finally, I reference the website and include all appropriate inputs and outputs for each command, save and run!

#### Useful trick
Using variables with the `set` function can minimize mistakes and make the batch file easily adaptable. For example, the input and output directories can be defined using a variable, so that if these directories should change, it is only necessary to modify it once: no need to go through each command to change them. 

The files I used are available for download here:
- [batch file](test.bat)
- [DEM file](ASTKilimanjaroDEMmosaic.sgrd) 

## Comparing Datasets

Now that we have successfully automated the process, we can easily run a different dataset. I ran both the SRTM and ASTER rasters through the batch file. However, before doing that, I had to mosaic and reproject the rasters. The batch file for this process can be downloaded [here](/mosaic_utmproj_dem_AST.bat).

Once I ran all of the SAGA analysis, I first took the difference of the rasters using `Grid -> Calculus -> Grid Difference`. This was done to show where the two rasters disagreed:

<img src="/lab3/difference.PNG" width="600">

Two places stick out immedeately. The first is near the peak of Mount Kilimanjaro. The second is the lake. 
<details><summary>Zoom in to Mt. Kilimanjaro</summary>
<img src="/lab3/difference-zm.PNG" width="600">
    </details>
<details><summary>Zoom in to the lakes</summary>
<img src="/lab3/difference-zm2.PNG" width="600">
    </details>
    
The difference around the lakes is plain and simple: it signifies the difference in calibration. However, the peak is curious. Let us take a close look at the hillshade around this region. I visualized the following in QGIS: 

<img src="/lab3/comp-1.png" width="600">
<img src="/lab3/comp-2.png" width="600">
