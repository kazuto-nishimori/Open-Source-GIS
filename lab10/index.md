# GeoPandas and Data Management around Python

## Table of Contents

1. [Objective](#goal)
2. [Software and Documentation](#sw)
3. [Getting started with python](#pyt)
   1. [Installing Anaconda](#pyt-a)
   2. [Setting up environment](#pyt-b)
   3. [Installing other modules](#pyt-c)
4. [The Research Question and Data](#rq)
5. [Maps and Plots on GeoPandas](#gp)
   1. [Setting up](#gp-a)
   2. [Editing Columns](#gp-b)
   3. [Precinct level voter distribution](#gp-c)
   4. [District level voter distribution](#gp-d)
   5. [Exporting to Shapefile](#gp-e)
6. [Interpreting Results](#res)   


## Objective <a name="goal"></a>
 
This objective of this project is more learning oriented. I will get acquainted with the vast python ecosystem, and learn how to manage the numerous packages and modules into 'environments'. Then, I will use an opensource geospatial package called GeoPandas to create maps and plots and attempt to visualize partisan gerrymandering in Wisconsin. I will export these visualizations so that the analysis can be continued on other plaforms. 

## Software and Documentation <a name="sw"></a>

### Software and modules used

- [Anaconda 2019.10 Python 3.7 Version](https://www.anaconda.com/distribution/) 
- [Python 3.6.7](https://www.python.org/)
- [GeoPandas 0.6.2](https://geopandas.readthedocs.io/en/latest/install.html)
- [Matplotlib 3.1.2](https://matplotlib.org/)
- [Jupyter 5.3.3](https://jupyter.org/)
- And all other dependencies. 
  
### Documentation Referenced

- [A helpful youtube tutorial](https://www.youtube.com/watch?v=slqZVgB8tIg&t=253s)
- [Geopandas userguide](http://geopandas.org/data_structures.html)


## Getting started with python  <a name="pyt"></a>
The python software ecosystem is vast and complicated and it can be overwhelming at first. Here is a quick guide to all you should know. 

### Installing Anaconda <a name="pyt-a"></a>

Due to the complexity of the python environment, there exists dedicated software to manage workspace environments. In this project, I will be using the most common one, the free and opensource Anaconda. Anaconda is a great platform for managing ‘packages’. Most python tools, GeoPandas included, have ‘dependencies’ i.e. other modules on which it is dependent to run at all. Finding and installing each of these modules is a pain, but Anaconda automates this process. In addition, Anaconda facilitates the creation and maintenance of ‘environments’. It is recommended to create separate environments for each project, because projects could require different versions of the same module (or even python itself). Once Anaconda is installed, it will be accessible by its navigator software or through command-line.

### Setting up environment<a name="pyt-b"></a>
To create an environment for GeoPandas, I used the following command that I borrowed from GeoPandas [installation guide](https://geopandas.readthedocs.io/en/latest/install.html). 

``` 
conda create -n geo_env
conda activate geo_env
conda config --env --add channels conda-forge
conda config --env --set channel_priority strict
conda install python=3 geopandas

```

### Installing other modules <a name="pyt-c"></a>

Let us install the other packages. To do this through command-line, first type in the following to load the environment. Any command from this point will be executed within the environment. 

```
conda activate geo_env
``` 

We will now install Jupyter and Matplotlib. Jupyter is a platform that integrates a file browser, live python code, and visual outputs into a format called a notebook. It is much more user-friendly than a command-line terminal, and it facilitates file organization as well. Matplotlib will be used later to output the analysis onto a map. 

```
conda install matplotlib
conda install jupyter
```

<img src="jupyter.png" width=800>


## The Research Question and Data <a name="rq"></a>

Redistricting has been one of the most important political issues in the last few years. It is a pressing one too, now that the 2020 census is in sight. In June, there was also the [Supreme Court case] (https://www.nytimes.com/2019/06/27/us/politics/supreme-court-gerrymandering.html) where the conservative majority deemed the federal government powerless in regulating partisan gerrymandering. Some say that it is a menace to the democratic process, others point out that it is old as democracy itself, and after over two centuries of debate, we cannot decide on what counts as gerrymandering.  

Identifying gerrymandering is difficult, since to claim that a district is gerrymandered partially implies that there exists a ‘correct’ way to draw the border, which simply is not true. However, many people agree there are incorrect ways to draw them, and Wisconsin is a prime example. Wisconsin’s districts are drawn by the state assembly and in 2011, the Republican-controlled assembly redrew its districts with the explicit purpose of electing a strong Republican majority from a minority of voters, and it [worked]( https://www.jsonline.com/story/news/blogs/wisconsin-voter/2018/12/06/wisconsin-gerrymandering-data-shows-stark-impact-redistricting/2219092002/). Republicans have had an uncontested stronghold in the state assembly ever since. In this project, I will attempt to visualize the effects of Wisconsin’s partisan gerrymandering through maps and plots created on GeoPandas.  

I will use precinct level voter [data]( https://github.com/mggg-states/WI-shapefiles) assembled by the [Metric Geometry and Gerrymandering Group]( https://mggg.org/research) (MGGG), a Boston-based research team that pursues cutting edge research on gerrymandering. They also provide opensource tools and data to give the public access to the research as well.  

## Maps and Plots on GeoPanda <a name="gp"></a>

### Setting up <a name="gp-a"></a>
The first step is open jupyter through Anaconda as shown below. This opens a file browser. Locate the folder in which the shapefiles are saved and create a new python file. 
<img src="jupyter2.png" width=800>

``` python
import geopandas as gpd
import matplotlib as mpl
import pandas
wisc = gpd.read_file("WI_ltsb_corrected_final.shp")
```
This code imports the packages I will be using. Matplotlib is used to output the maps and plots later. 

### Editing Columns <a name="gp-b"></a>

Editing attribute tables in GeoPanda is very easy. There is no need to even make a new column before populating it. I looked at the metadata on [MGGG](https://github.com/mggg-states/WI-shapefiles) to identify the columns I need for this analysis: the Democratic and Republican voter counts for the Wisconsin state senate and assembly. When there exist multiple candidates from a given party, I will sum them to get the total votes for that party. 

The following operation will make three new columns. The sum of votes to the state senate and assembly are calculated for Republicans and Democrats. Then, they are added to find the 'total' voter pool (excluding third parties but their contribution is negligible). Finally, the useful columns are isolated, including `ASM` which denotes the assembly district number. This will be used later to perform a dissolve. `wisc.head()` prints out the first five rows to make sure the operation was done correctly. 

```python
wisc['strepvt'] = wisc.WSSREP12 + wisc.WSSREP212 + wisc.WSAREP12 + wisc.WSAREP212
wisc['stdemvt'] = wisc.WSSDEM12 + wisc.WSADEM12 + wisc.WSADEM212
wisc['sttotvt'] = wisc.strepvt + wisc.stdemvt
wisc = wisc[['geometry','ASM','sttotvt','strepvt','stdemvt']]
wisc.head()
```
### Precinct level voter distribution <a name="gp-c"></a>

I will calculate the ratio of Democratic votes to total votes which should give a number between 0 and 1 (0 being strongly Republican and 1 being strongly Democrat. However, before doing this, I must remove all the precincts with zero total votes to avoid errors. 

```python
pre = wisc.loc[wisc['sttotvt'] != 0]
pre['stdemnorm'] = pre.stdemvt/pre.sttotvt
pre.head()
```
Now, I will create a histogram of this ratio and save it as a png image file. `bins` signifies the number of bars in the chart.

```python
pre.hist(column='stdemnorm', bins=20)
mpl.pyplot.title('Percentage of Democrat Votes to WI Assembly 2012, Precinct Level')
mpl.pyplot.savefig("precinct-hist.png", dpi=300)
```
<img src="/lab10/precinct-hist.png" width=400>

Before creating a map, I will check its coordinate reference system with this command:
```
pre.crs
```
It returned a number `26916`, which corresponds to NAD83, zone 16N which is appropriate for this region. I will proceed with mapping. 

```python
pre.plot(column='stdemnorm', cmap='RdBu', legend=True);
mpl.pyplot.title('Votes to WI Assembly 2012, Precinct Level')
mpl.pyplot.savefig("precinct-choro.png", dpi=300)
```
<img src="/lab10/precinct-choro.png" width=400>

### District level voter distribution <a name="gp-d"></a>

Let us perform a dissolve. This is incredibly simple. Only two criteria are needed: the column on which this dissolve is based and the aggregation function, which in our case is a simple sum. I calculated the ratio of Democratic votes much in the same way, but there was no need to remove zeros this time, as all districts have non-zero entries. 

``` python
dist = wisc.dissolve(by='ASM', aggfunc='sum')
dist['stdemnorm'] = dist.stdemvt/dist.sttotvt
dist.head()
```
A plot and a map was created in the same way as I did in the precinct-level analysis. 

<img src="/lab10/district-hist.png" width=400>
<img src="/lab10/district-choro.png" width=400>

### Exporting Shapefile <a name="gp-e"></a>

Exporting to shapefile is done with one function. 

```
pre.to_file("precinct.shp")
dist.to_file("district.shp")
```
## Interpreting Results<a name="res"></a>
|District|Precinct|
|------|-----|
|<img src="/lab10/district-choro.png" width=500>|<img src="/lab10/precinct-choro.png" width=500>|

Looking at the district and precinct level choropleths side by side, it is immediately clear that the borders were drawn to contain the heavily democratic precincts. This will increase 'wasted votes' since any votes after a majority will not affect election results. However, this does not necessarily reflect partisan gerrymandering. People of similar ideology often live in the same geography that is bounded by both physical and cultural boundaries. There is an argument to be made to draw district borders that reflect these different pockets of population. However, looking at the histogram, the effects of partisan gerrymandering is clearly seen. 

|District|Precinct|
|------|-----|
|<img src="/lab10/district-hist.png" width=500>|<img src="/lab10/precinct-hist.png" width=500>|

At the precinct-level, we see a more or less even distribution of percentages with a peak in the 45 - 50% democrat range(and a strong peak around the 100% mark). However, the district-level distribution looks very different. The width of the distribution has shrunk considerably, and the peak has shifted to the 40 - 45% range. The shrinking of the width suggests that precincts with slight Democratic majority were grouped with those with Republican majorities to suppress representation. 



