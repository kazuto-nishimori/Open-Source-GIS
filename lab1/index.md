# Lab: Creating a QGIS Model: Introduction to Open Source

## Table of Contents
1. [Objective](#goal)
2. [Software and Documentation](#sw)
3. [The Distance and Direction QGIS Model](#model)
    1. [Obtaining Data](#model-a)
    2. [Understanding the Model](#model-b)
    3. [Outputs](#model-c)
    4. [Plotting Results in DataPlotly](#model-d)
    5. [Possible Future Modifications](#model-e)
4. [Discussion](#disc)

## Objective <a name="goal"></a>

The goal of this lab is to be acquainted with the open source GIS environment; this can mean several things. In a myopic sense, this means learning to use QGIS, an open source GIS software. However, ‘open source’ is so much more than the software per se: it signifies the whole ecosystem of professionals and hobbyists that engage in the bottom up, grassroots creation of useful tools. This environment revolves around online forums and repositories like Github. Therefore, getting acquainted with open source means creating a tool, publishing it on the web, and creating helpful documentation to allow others to use and modify it. This is precisely the goal of this lab.   

## Software and Documentation <a name="sw"></a>

### Software used

- [QGIS 3.8.1](https://www.qgis.org/en/site/)
- [DataPlotly 2.3](https://github.com/ghtmtt/DataPlotly)

### Documentation Referenced
- Lab Instructions by Professor Holler: [request document by email](mailto:jholler@middlebury.edu)
#### Works cited


## The Distance and Direction QGIS Model <a name="model"></a>

My model was designed to be used to be used in urban geography analysis: there exist many theories like the distance-decay model that conceptualize the urban space as being organized radially out from the central business district. Our tool calculates the distance and direction with respect to the central business district for each polygon in the input shapefile. So, we believe the most appropriate input for this model to be a shapefile of an urban area at the census-tract level.  (Although you might find other uses too!) 
- Download the model [here](/dist_dir.model3) 

### The Input <a name="model-a"></a>

Shapefile at the census-tract level can be easily found through the US census [website](https://www.census.gov/geographies/mapping-files/time-series/geo/carto-boundary-file.html). I was interested in San Antonio, so I downloaded the data for the whole of Texas. The attribute table of the shapefile only contains basic information like the tract id, state id, land area etc. so we must populate it with data we are interested in. We can find census attribute data easily through [American Fact Finder]( https://factfinder.census.gov/). 

<img src="/lab1/factfinder.PNG" width="600">

In the “Advanced Search” section, we can set the geographies to census tracts, and chose a state or counties. I chose to download the data for the 8 counties that make up the Greater San Antonio Metropolitan Area. I was interested in median rent and Hispanic population, so I chose to download tables `B25064` and `B03002` from the 2017 ACS 5-year estimate dataset. Of course, you may choose any other tables depending on your analysis. 

Now that we have all the data, let us open QGIS. (The csv file should be imported through `Layer -> Add Layer -> Add Delimited Text Layer`) We will select only the San Antonio counties from the shapefile and export to new layer, then join the rent and Hispanic values to the tracts using appropriate columns (GEOID). Important consideration here is that the census reports numbers as a string, so it is necessary to create integer columns for both data, and perform raster calculator to fill these columns. 

<img src="/lab1/Capture.PNG" width="400">

If you would like to test my model without going through these steps, you may download the San Antonio shapefile already populated with data [here](/sa_joined.shp)

### Understanding the Model <a name="model-b"></a>

<img src="/lab1/model.PNG" width="400">

### Outputs <a name="model-c"></a>

### Plotting Results in DataPlotly <a name="model-d"></a>

### Possible Future Modifications <a name="model-e"></a>

## Discussion <a name="disc"></a>

