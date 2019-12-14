# Big Data and Twitter API

## Table of Contents

1. [Objective](#goal)
2. [Software and Documentation](#sw)
3. [Something brief on twitter data and VGI](#intro)
4. [Getting Started with twitter API](#twit)
    1. [Creating developer account ](#twit-a)
    2. [Important considerations with twitter data](#twit-b)
5. [Learning rStudio](#rs)
    1. [Setting up the environment](#rs-a)
    2. [Temporal analysis](#rs-b)
    3. [Extracting precise geographies](#rs-c)
    4. [Network analysis](#rs-d)
    5. [Text analysis](#rs-e)
    6. [Spatial analysis](#rs-f)
    7. [Uploading results to PostGIS for further spatial analysis](#rs-g)
4. [Textual Analysis of Twitter Activity During Dorian](#text)
    1. [Outputs](#text-a)
    2. [Discussion](#text-b)
5. [Geographic Analysis of Twitter Activity During Dorian](#geog)
    1. [Setting up PostGIS](#geog-a)
    2. [Spatial Operations in PostGIS](#geog-b)
    3. [Spatial Hotspot Analysis with GeoDa](#geog-c)
    4. [Kernel Density Map in QGIS](#geog-d)
    5. [Discussion](#geog-e)

## Objective <a name="goal"></a>
 
Recently, big data has gathered the interest of many, and in the geography community, its use in the study of natural disasters and its potential as a tool for emergency responders are being examined closely. In this lab, the goal is to become familiar with twitter's API through rStudio, and import the geolocated tweets to PostGIS and GeoDa to perform spatial analysis. Specifically, we will examine activity during Hurricane Dorian that devastated the Bahamas and affected the East Coast of the United States. Of course, this event was in part overshadowed by DJT's infamous 'sharpiegate'. By examining twitter activity, I wish to uncover whether such a controversy could alter tweet activity in significant ways to affect emergency responders or academic research. 

## Software and Documentation <a name="sw"></a>

### Software used

- [QGIS 3.8.1](https://www.qgis.org/en/site/) 
- [PostGIS 2.5.3](https://postgis.net/source/)
- [PostgreSQL 11.5](https://www.postgresql.org/download/)
- [GeoDa 1.10.0.8](https://geodacenter.github.io/)
- [rStudio 1.2.1335](https://rstudio.com/)
<details><summary>Libraries Used</summary>
    
  1. rtweet
  2. tidycensus
  3. maps
  4. RPostgres
  5. igraph
  6. tm
  7. ggplot2
  8. RColorBrewer
  9. rccmisc
  10. ggraph

</details>
  
### Documentation Referenced
- Lab Instructions by Professor Holler: [request document by email](mailto:jholler@middlebury.edu)
- https://www.w3resource.com/
- spatialreference.org 

#### Works cited
- Kate Crawford, and Megan Finn. “The Limits of Crisis Data: Analytical and Ethical Challenges of Using Social and Mobile Data to Understand Disasters.” GeoJournal, vol. 80, no. 4, 2015, p. 491. EBSCOhost, search.ebscohost.com/login.aspx?direct=true&db=edsjsr&AN=edsjsr.44076312&scope=site.
- Sarah Elwood, et al. “Researching Volunteered Geographic Information: Spatial Data, Geographic Research, and New Social Practice.” Annals of the Association of American Geographers, vol. 102, no. 3, 2012, p. 571. EBSCOhost, doi:10.1080/00045608.2011.595657.
- Wang, Z. (. 1. )., et al. “Spatial, Temporal, and Content Analysis of Twitter for Wildfire Hazards.” Natural Hazards, vol. 83, no. 1, pp. 523–540. EBSCOhost, doi:10.1007/s11069-016-2329-6. Accessed 11 Dec. 2019.

## Getting started with twitter API  <a name="twit"></a>

### Creating developer account <a name="twit-a"></a>

We must first create a [developer account on twitter]( https://developer.twitter.com/). The approval process takes anywhere from a day to a few days, so it is important to do this ASAP. Once approved, twitter requires us to create an ‘app’ which is as simple as filling a form. They instantly give you a consumer API key that can be used by external software to access data.  

<img src="/lab9/token.png" width="500">

### Important considerations with twitter data <a name="twit-b"></a>

Twitter’s data is becoming more monetized and restricted for non-paying developers. With a free account, we are limited to tweets from the past 7 days, and only 18,000 tweets can be downloaded every 15 minutes. In addition, all developers must abide by these [restricted use cases](https://developer.twitter.com/en/developer-terms/more-on-restricted-use-cases). Most notably, twitter forbids developers to extract sensitive data such as race, sexual orientation, religious and political beliefs about its users. In addition, redistribution of twitter data is restricted to 50,000 per day per user, and they can never be published (in a paper or a public Github repository). Instead, if one wishes to publish data for research reproducibility, one can publish only the unique tweet id’s, which can then be ‘rehydrated’ by a third party. Of course, this third party must own a paid developer account. 

## Learning rStudio <a name="rs"></a>
In this section, I cover how to import tweets and census data, as well as how to create graphs visualisations in rStudio. Since I will only be using some of these techniques in the lab, I have collapsed the sections that are not immedeately relevant. 
    
### Setting up the environment <a name="rs-a"></a>
    
rStudio is an opensource data science software with a diverse ecosystem of libraries. I will be using quite a few of these including 'rtweet', to connect with twitter API and 'tidycensus' to connect with the US census API. The first step is to install these libraries into the project using the following command:
```
install.packages(c("rtweet","tidycensus","tidytext","maps","RPostgres","igraph","tm", "ggplot2","RColorBrewer","rccmisc","ggraph"))
```
Let us test the rtweet library by importing some tweets. I was working on this lab in early November during the aftermath of the coup attempt in Bolivia and the resignation of Evo Morales. I thought it would be interesting to analyze tweets in Florida relating to this event. 

<details><summary> Show Code </summary>
    
```
twitter_token <- create_token(
  app = “YOUR_APP_NAME", 
  consumer_key = "YOUR_API_KEY", 
  consumer_secret = "YOUT_API_SECRET_KEY", 
  access_token = NULL,
  access_secret = NULL
)
evoTweets <- search_tweets("Evo OR Morales", n=10000, retryonratelimit=FALSE, include_rts=FALSE, token=twitter_token, geocode="28.3,-81.6,350km")
```   

</details>
The `search_tweets` command uses the API information we obtained earlier to search for tweets with keywords “Evo” or “Morales” in a 350km radius around central Florida (28.3, -81.6) and populates a table called “evoTweets”. No retweets were included. Now that I have the tweets, there is a plethora of things I can do with this data. 


### Temporal analysis <a name="rs-b"></a>
<details><summary> Expand </summary>

The twitter data downloaded with rtweet is neatly organized into a usable table. The column ‘hours’ contains the time stamp of each tweet. Dealing with timestamps is often a headache in coding because there exists a myriad of formats used. Thankfully, rtweet’s `ts_plot` function makes it extremely straight forward to create a plot with respect to time: 

```
evoTweetHours <- ts_data(evoTweets, by="hours")
ts_plot(winterTweets, by="hours")
```
<img src="/lab9/Rplot00.png" width="500">
The plot agrees with what I expected. There is a sudden spike in tweets mentioning Evo Morales on the night of November 10, the day he announced his resignation. The tweets fluctuate up and down reflecting the waking hours of the tweeters, and each day the peaks diminish in height as they slowly lose interest in the topic. 
</details>

### Extracting precise geographies <a name="rs-c"></a>

As geographers, we are naturally interested in tweets with precise geographic information. However, since users must opt-in to share this data, it is only available in about 1-5 percent of all tweets. There are two types of geographic information in tweets, the first being the GPS coordinates that give the precise location of the user. Of course, not everyone is comfortable sharing their location with this much precision, so they might opt to share a place name instead, which could range in extent from a point-of-interest, neighborhood, town, to state. This place information is reported as a bounding box instead of a point. Let us select all tweets that report geographic information at the city level or smaller. 
<details><summary> Show Code </summary>
    
```
evoTweets <- lat_lng(evoTweets,coords=c("coords_coords"))
evoTweetsGeo <- subset(evoTweets, place_type == 'city'| place_type == 'neighborhood'| place_type == 'poi' | !is.na(lat))
evoTweetsGeo <- lat_lng(evoTweetsGeo,coords=c("bbox_coords"))
```
       
`lat_lng()` converts the GPS coordinates into latitude and longitude coordinates. `sub_set()` selects all bounding boxes of the desired extent `lat_long` is used again to find the centroid of these boxes. The centroids and GPS points make up a new table named 'evoTweetsGeo'. Now I have point geometries that can be used for analysis. 
</details>

### Network analysis <a name="rs-d"></a>
<details><summary> Expand </summary>
    
I can perform network analysis on rStudio using the igraph library. 

```
evoTweetNetwork <- network_graph(evoTweetsGeo, c("quote"))
plot.igraph(evoTweetNetwork)
```
<img src="/lab9/Rplot03.png" width="500">

Since I excluded retweets, there isn’t much here to see. This analysis would be useful to visualize who the 'gatekeepers' of tweets are. As Wang et al. mentioined, on twitter there exists a few elite users and opinion leaders whom many users rely on for information. If I had retweet data, these users would be immediately visible as the major nodes of the network. 
</details>

### Textual analysis <a name="rs-e"></a>

The first step in text analysis is to isolate the words from the text which is done in the first three lines of the code. Then we must remove stop words. These are words such as articles and short function words (e.g. "the", "and", "like") that are not useful in natural language processing. The SMART list is a handy tool that contains all the major stop words in the English language. In line five, I delete all stop words from our list of words. 
<details><summary> Show Code </summary>
    
```
evoTweetsGeo$text <- plain_tweets(evoTweetsGeo$text)
evoText <- select(evoTweetsGeo,text)
evoWords <- unnest_tokens(evoText, word, text)
data("stop_words")
stop_words <- stop_words %>% add_row(word="t.co",lexicon = "SMART")
evoWords <- evoWords %>%
anti_join(stop_words) 
 ```
 
Unfortunately, most of our tweets were in Spanish, so the SMART list was not very useful. I could not easily find a similar list for the Spanish language, so it was done manually. In the fifth line, I added the following code for each word I wanted removed. 
```
%>% add_row(word="SPANISH_STOP_WORD")
``` 
</details>
Then I made a graph of the most common words that appeared in the tweets. 
<details><summary> Show Code </summary>
    
```
  evoWords %>%
  count(word, sort = TRUE) %>%
  top_n(15) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(x = word, y = n)) +
  geom_col() +
  xlab(NULL) +
  coord_flip() +
  labs(x = "Count",
       y = "Unique words",
       title = "Count of unique words found in tweets")
```

</details>
<img src="/lab9/Rplot01.png" width="500">

The words "Evo" and "Morales" topped the charts, which is unsurprising since that was our search criteria. The usual suspects follow like "Bolivia", "pueblo" meaning people, and "fraude" because of the election fraud accusations he was facing at the time of his resignation.  

Let us also visualize a word cloud that maps the interconnectivity of words; the closer the words, the more they were mentioned in conjunction. To do this, the first step is to create word pairs. Then, these pairs are counted by the number of occurrences and a network graph is created based on their frequency:
<details><summary> Show Code </summary>
    
```
evoWordPairs <- evoTweetsGeo %>% select(text) %>%
  mutate(text = removeWords(text, stop_words$word)) %>%
  unnest_tokens(paired_words, text, token = "ngrams", n = 2)
evoWordPairs <- separate(evoWordPairs, paired_words, c("word1", "word2"),sep=" ")
evoWordPairs <- evoWordPairs %>% count(word1, word2, sort=TRUE)
evoWordPairs %>%
  filter(n >= 10) %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  geom_node_point(color = "darkslategray4", size = 3) +
  geom_node_text(aes(label = name), vjust = 1.8, size = 3) +
  labs(title = "Word Network: Tweets in Florida after failed coup in Bolivia",
       subtitle = "November 2019 - Text mining twitter data ",
       x = "", y = "") +
  theme_void()
  ```
  
</details>
<img src="/lab9/Rplot02.png" width="500">
<img src="/lab9/Rplot02-edit.png" width="300">

Curiously enough, the word cloud reveals the political fragmentation within the twitter userbase. On the one hand, there is the political right tweeting about the election fraud charges. On the other hand there is the left tweeting about the army and the coup attempt. These two groups occupy different places on the map. 

### Spatial analysis <a name="rs-f"></a>
I can even do spatial analysis on r. To do this, let us import county shapefiles using the US census API. I first signed up for an account on their [website](https://api.census.gov/data/key_signup.html). Then I can use the ‘tidycensus’ library to import the files. I will filter just the Florida counties for this exercise.
```
Counties <- get_estimates("county",product="population",output="wide",geometry=TRUE,keep_geo_vars=TRUE, key="YOUR_API_KEY")
floridaCounties <- filter(Counties,STATEFP %in% c("12") )
```
The `ggplot()` function can then be used to visualize the counties and the tweet locations. With very little code, it outputs a usable map, which is surprising. 
<details><summary> Show Code </summary>

``` 
ggplot() +
  geom_sf(data=floridaCounties, aes(fill=cut_number(DENSITY,5)), color="grey")+
  scale_fill_brewer(palette="GnBu")+
  guides(fill=guide_legend(title="Population Density"))+
  geom_point(data = evoTweetsGeo, aes(x=lng,y=lat),
             colour = 'purple', alpha = .5) +
  labs(title = "Locations of Tweet mentioning Evo Morales during the coup")+
  theme(plot.title=element_text(hjust=0.5),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())
```

</details>
<img src="/lab9/Rplot04.png" width="500">

### Uploading results to PostGIS for further spatial analysis <a name="rs-g"></a>
Finally, I will upload the data to PostGIS so that I can apply the toolset I have acquired throughout the semester. This is extremely simple with the use of the library `RPostgres`. Make sure to select only the columns needed as I did in line 2. There are certain operations that must be done in the PostGIS side, and I will discuss this in detail in the following sections.
```
con <- dbConnect(RPostgres::Postgres(), dbname='yourdatabase', host='hostname', user='yourUserName', password='yourPassword') 
evo <- select(evoTweetsGeo,c("user_id","status_id","text","lat","lng"),starts_with("place"))
dbWriteTable(con,'evo',evo, overwrite=TRUE)
dbDisconnect(con)
```
### Download materials used <a name="rs-h"></a>
- [r file](/twitlab.r)
- [List of tweet IDs](/evoTweetID.csv)


## Textual Analysis of Twitter Activity During Dorian <a name="text"></a>

[Download the r file used in this portion of the lab.](/final.r)

Now that we have the toolset, let us answer the original research question. Did DJT's sharpiegate have an effect on twitter activity that was significant enough to alter emergency responders or academic research that would rely on these tweets? I will first look at the outputs from the textural analysis. 

### Outputs <a name="text-a"></a>
<img src="/lab9/dorian-word-count.png" width="500">
<img src="/lab9/plot.png" width="500">

### Discussion <a name="text-b"></a>

In terms of word count, 'sharpiegate' along with mentions of DJT dominates the discussion on twitter. However, word count is not always a useful indicator of people's interest. This is because there is not an equivalent 'buzzword' for calling out for help, or expressing support to the victims. It makes sense that the words that top the charts are controversial, 'viral' topics that are marketed well using buzzwords. Looking at the word cloud, the mentions of 'sharpiegate' all but disappear. It appears that most tweets mention the victims, or give some words of encouragement and support. DJT makes an appearence on the map but only occupies the periphery of the word cloud.

## Geographic Analysis of Twitter Activity During Dorian <a name="geog"></a>

It will be interesting to see the geographic distribution of twitter activity during the hurricane. From rStudio, I will import the US counties, Dorian tweets, as well as tweets from November which I can compare as a baseline twitter activity. A comparison of Dorian tweets with baseline activity can be more telling than a simple population-based normalization, since twitter is not as universal as other socialmedia such as facebook. 


### Setting up PostGIS <a name="geog-a"></a>

Exporting data to PostGIS on the rStudio side is covered in the "Learning rStudio" section. Once this is done, we will firstly install the lambert conformal conic (ESRI:102004) spatial reference system to PostGIS. (This projection preserves shapes well) A website called spatialreference.org provides SQL queries that you can copy-and-paste. 

<details><summary>Show Code </summary>
    
```sql
INSERT into spatial_ref_sys (srid, auth_name, auth_srid, proj4text, srtext) values ( 102004, 'esri', 102004, '+proj=lcc +lat_1=33 +lat_2=45 +lat_0=39 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs ', 'PROJCS["USA_Contiguous_Lambert_Conformal_Conic",GEOGCS["GCS_North_American_1983",DATUM["North_American_Datum_1983",SPHEROID["GRS_1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]],PROJECTION["Lambert_Conformal_Conic_2SP"],PARAMETER["False_Easting",0],PARAMETER["False_Northing",0],PARAMETER["Central_Meridian",-96],PARAMETER["Standard_Parallel_1",33],PARAMETER["Standard_Parallel_2",45],PARAMETER["Latitude_Of_Origin",39],UNIT["Meter",1],AUTHORITY["EPSG","102004"]]');
``` 

</details>

The tables that were imported from rStudio do not yet have usable geometry columns. I will add this with a `addgeometry()` function (and be sure to add the projection that was just imported!).

<details><summary>Show Code </summary>
    
``` sql
select addgeometrycolumn('novembertweets', 'geom', 102004, 'point', 2);
UPDATE  novembertweets
SET geom = st_transform (st_setsrid(st_makepoint(lng,lat),4326),102004);
```

</details>

Do the same for the Dorian tweets table and US counties. Now the layers are ready for spatial analysis. 

### Spatial Operations in PostGIS <a name="geog-b"></a>

#### Dropping states outside of study area

Our analysis is focused on twitter activity in the Eastern US. I will use the following command to remove all counties that lie outside of these states using their `statefp`. 

<details><summary>Show Code </summary>
    
``` sql
alter table uscounties
drop column geometry
SELECT populate_geometry_columns('uscounties'::regclass);
DELETE FROM uscounties
WHERE statefp NOT IN ('54', '51', '50', '47', '45', '44', '42', '39', '37', '36', '34', '33', '29', '28', '25', '24', '23', '22', '21', '18', '17', '13', '12', '11', '10', '09', '05', '01');
```

</details>

#### Spatial Intersection 

I want to count the number of tweets in each county. To do so, let us first create a column in both tweet layers to indicate the county in which they reside. Then, I will perform `st_intersects` with the counties layer to populate this column.

<details><summary>Show Code </summary>

``` sql
ALTER TABLE novembertweets
ADD COLUMN geoid varchar(5);  
UPDATE novembertweets
SET geoid= uscounties.geoid
from uscounties 
where st_intersects (novembertweets.geom, uscounties.geom);
SELECT count(status_id), geoid
FROM novembertweets 
where geoid is not null 
GROUP BY geoid

ALTER TABLE doriantweets
ADD COLUMN geoid varchar(5);  
UPDATE doriantweets
SET geoid= uscounties.geoid
from uscounties 
where st_intersects (doriantweets.geom, uscounties.geom);
SELECT count(status_id), geoid
FROM doriantweets 
where geoid is not null 
GROUP BY geoid
```

</details>

Now, let us perform the other half of zonal statistics by adding a counting column to the counties layer for the Dorian and November tweets. For each county, the `group by` function groups all tweets by county ID, and the number of tweets are recorded in the counting column. This, we have seen many times before. 

<details><summary>Show Code </summary>
    
    
``` sql
ALTER TABLE uscounties
ADD COLUMN  doriancount varchar(5); 
ALTER TABLE uscounties
ADD COLUMN novembercount varchar(5);

UPDATE uscounties 
SET doriancount = a 
from (SELECT count(status_id) as a, geoid
FROM doriantweets 
where geoid is not null 
GROUP BY geoid) as ct
where uscounties.geoid = ct.geoid

UPDATE uscounties 
SET novembercount = 0;
UPDATE uscounties 
SET novembercount = a
from (SELECT count(status_id) as a, geoid
FROM novembertweets 
where geoid is not null 
GROUP BY geoid) as ct
where uscounties.geoid = ct.geoid
```

</details>

Finally the rate of tweets per 10,000 people is calculated for each county by normalizing the Dorian tweets by the population. We calculated a normalized difference score of Dorian tweet activity with respect to November tweets as a baseline number. A higher score would indicate higher than baseline activity during Dorian.

<details><summary>Show Code </summary>
    
    
``` sql
ALTER TABLE uscounties
ADD COLUMN twrate float;
ALTER TABLE uscounties
ADD COLUMN ndti float;
UPDATE uscounties 
SET twrate = cast(doriancount as float) * 10000 / cast(pop as float);
UPDATE uscounties 
SET ndti = (cast(doriancount as float) - cast(novembercount as float))/((cast(doriancount as float) + cast(novembercount as float) )*1.0)
where (cast(doriancount as float) + cast(novembercount as float) ) > 0;
UPDATE uscounties 
SET ndti = 0 where ndti is NULL
```

</details>

Now the county layer is ready to be imported by GeoDa for spatial hotspot analysis. 

### Spatial Hotspot Analysis with GeoDa <a name="geog-c"></a>

GeoDa in an open source spatial statistics software and I will be using their G* function in this lab. G* is akin to a Z score, but tailored to geographic analysis; it reveals clusters of hot- and cold-spots in the map. I will make hotspot maps for both tweet rate and the normalized difference index.

The first step is to connect to the PostGIS database. Then, I will create a spatial weights matrix, which is a matrix table that contains information about which features neighbor another. The `weights file id variable`, is the feature id, which in this case is the county id or `GEOID` column. The default settings are kept for the `Threshold distance`.

Then go to `Space -> Local G* cluster map`. Make sure to include a significance map, cluster map, and row-standardized weights. Making a hotspot map is as simple as that. 

<img src="/lab9/tw-rate-clust.PNG" width="600">
<img src="/lab9/tw-rate-sig.PNG" width="600">

The tweet rate cluster map shows that there are sections of high tweet activity along the Eastern Seaboard from Southern Florida to the Chesapeake Bay. Tweet rate is low inland. The significance map shows how statistically significant the data is, and it appears that the significance is extremely good in the areas of interest, namely the hurricane's actual path along the coast, and Southern Alabama, where DJT sharpied-in the fictitious hurricane path. 

On the other hand, the normalized difference twitter index map showed a behaviour that was the complete opposite of what was predicted. This I believe could be due to the fact that the score ranges from -1 to 1, and somehow the negative numbers confused the algorithm. 

<img src="/lab9/ndti-clust.PNG" width="600">

### Kernel Density Map in QGIS <a name="geog-d"></a>
Finally, I created a kernel density heatmap of the tweet rate during the hurricane. The algorithm requires point data, not shapefiles, so I will reduce the counties into centroids using the following code.

<details><summary>Show Code </summary>
    
``` sql
convert counties to centroid
CREATE VIEW countiescentroids AS
SELECT geoid, st_centroid(wkb_geometry) AS geom, tweetrate
FROM countieseastg
```

</details>

The `Kernel Density Estimation` algorithm is found under processing toolbox. Running this with radius 100km and pixel size 500 meters produced a usable heatmap. I decided to overlay this with state borders for clarity. I isolated the borders in SQL from the Eastern counties layer with the following command:
<details><summary>Show Code </summary>
    
``` sql 
CREATE TABLE usstates AS
SELECT statefp,
  	   ST_Union(geom) as geom
FROM uscounties
GROUP BY statefp
```

</details>

Download all the  SQL queries [here](/twit.sql)

### Discussion  <a name="geog-e"></a>

So did the DJT's sharpie gate have a significant influence on twitter activity? Let us take a look:

<img src="/lab9/kd.png" width="600">
<img src="/lab9/twrate_clust_1.png" width="600">
<details><summary>Significance map</summary>
    <img src="/lab9/twrate_sig_1.png" width="600">
</details>

It seems that no, however dominant DJT might be in twitter discourse, his sharpied-in hurricane path to Alabama did not cause an upsurge of Dorian related tweets in that region. This we can conclude with statistical significance from the significance map. Instead, the tweet rate clearly highlights the actual path taken by Dorian along the Eastern Coast of USA. This supports Wang et al's finding that there is a correlation with areas with disaster-related tweets, and the actual affected geography (2016). 

Wang et al. argues that social media data is useful in disaster research and response, not just for the temporal and spatial accuracy of its distribution, but because it provides a human-centric perspective on disaster sensing. Elwood et al. further supports this notion and in response to possible criticism that social media data can be unreliable, they argue that in a case of an emergency, "decision makers must make choices between acting immediately with questionable data and waiting for better data to arrive" (2011) and usually the former is better. Furthermore, from our tweet rate distributions, it seems to point to the fact that these tweets are not in fact as questionable as one might expect. 

However, one must also realize that there are significant downsides, even dangers in using social media data mining for disaster responses. As Crawford et al. points out when typhoon Yolanda struck the Philippines, the social media activity in the worst affected areas in fact dropped by as much as 20% due to power outages (2015). Furthermore, the authors argue that disaster analysis using social media perpetuate the wrong notion that disasters are singular events, a break from the norm. It could be too easy to overlook the social processes that create and perpetuate vulnerability and to look at disasters only as an inevitable act of god. 







