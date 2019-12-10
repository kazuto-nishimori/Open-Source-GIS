# Lab Nine: Big Data and Twitter API

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
4. [Twitter Activity during Hurricane Dorian](#dor)
    1. [Conceptual rationale](#malc-a)
    2. [Methodology](#malc-b)

## Objective <a name="goal"></a>
 

## Software and Documentation <a name="sw"></a>

### Software used

- [QGIS 3.8.1](https://www.qgis.org/en/site/) 
- [PostGIS 2.5.3](https://postgis.net/source/)
- [PostgreSQL 11.5](https://www.postgresql.org/download/)
- rStudio
  - library 1
  - library 2
  - library 3
  

### Documentation Referenced
- Lab Instructions by Professor Holler: [request document by email](mailto:jholler@middlebury.edu)
- https://www.w3resource.com/

#### Works cited


## Getting started with twitter API  <a name="twit"></a>

### Creating developer account <a name="twit-a"></a>

We must first create a [developer account on twitter]( https://developer.twitter.com/). The approval process takes anywhere from a day to a few days, so it is important to do this ASAP. Once approved, twitter requires us to create an ‘app’ which is as simple as filling a form. They instantly give you a consumer API key that can be used by external software to access data.  

<img src="/lab9/token.png" width="500">

### Important considerations with twitter data <a name="twit-b"></a>

Twitter’s data is becoming more monetized and restricted for non-paying developers. With a free account, we are limited to tweets from the past 7 days, and only 18,000 tweets can be downloaded every 15 minutes. In addition, all developers must abide by these [restricted use cases](https://developer.twitter.com/en/developer-terms/more-on-restricted-use-cases). Most notably, twitter forbids developers to extract sensitive data such as race, sexual orientation, religious and political beliefs about its users. In addition, redistribution of twitter data is restricted to 50,000 per day per user, and they can never be published (in a paper or a public Github repository). Instead, if one wishes to publish data for research reproducibility, one can publish only the unique tweet id’s, which can then be ‘rehydrated’ by a third party. Of course, this third party must own a paid developer account. 

## Learning rStudio <a name="rs"></a>

### Setting up the environment <a name="rs-a"></a>

<details><summary>  </summary>
<p>
   

rStudio is an opensource data science software with a diverse ecosystem of libraries. I will be using quite a few of these including 'rtweet', to connect with twitter API and 'tidycensus' to connect with the US census API. The first step is to install these libraries into the project using the following command:
```
install.packages(c("rtweet","tidycensus","tidytext","maps","RPostgres","igraph","tm", "ggplot2","RColorBrewer","rccmisc","ggraph"))
```
Let us test the rtweet library by importing some tweets. I was working on this lab in early November during the aftermath of the coup attempt in Bolivia and the resignation of Evo Morales. I thought it would be interesting to analyze tweets in Florida relating to this event. 
    
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
The `search_tweets` command uses the API information we obtained earlier to search for tweets with keywords “Evo” or “Morales” in a 350km radius around central Florida (28.3, -81.6) and populates a table called “evoTweets”. No retweets were included. Now that I have the tweets, there is a plethora of things I can do with this data. 

</p>
</details>

### Temporal analysis <a name="rs-b"></a>
The twitter data downloaded with rtweet is neatly organized into a usable table. The column ‘hours’ contains the time stamp of each tweet. Dealing with timestamps is often a headache in coding because there exists a myriad of formats used. Thankfully, rtweet’s `ts_plot` function makes it extremely straight forward to create a plot with respect to time: 
```
evoTweetHours <- ts_data(evoTweets, by="hours")
ts_plot(winterTweets, by="hours")
```
<img src="/lab9/Rplot00.png" width="500">
The plot agrees with what I expected. There is a sudden spike in tweets mentioning Evo Morales on the night of November 10, the day he announced his resignation. The tweets fluctuate up and down reflecting the waking hours of the tweeters, and each day the peaks diminish in height as they slowly lose interest in the topic. 

### Extracting precise geographies <a name="rs-c"></a>

As geographers, we are naturally interested in tweets with precise geographic information. However, since users must opt-in to share this data, it is only available in about 1-5 percent of all tweets. There are two types of geographic information in tweets, the first being the GPS coordinates that give the precise location of the user. Of course, not everyone is comfortable sharing their location with this much precision, so they might opt to share a place name instead, which could range in extent from a point-of-interest, neighborhood, town, to state. This place information is reported as a bounding box instead of a point. Let us select all tweets that report geographic information at the city level or smaller.  
```
evoTweets <- lat_lng(evoTweets,coords=c("coords_coords"))
evoTweetsGeo <- subset(evoTweets, place_type == 'city'| place_type == 'neighborhood'| place_type == 'poi' | !is.na(lat))
evoTweetsGeo <- lat_lng(evoTweetsGeo,coords=c("bbox_coords"))
```
The first line converts the GPS coordinates into latitude and longitude coordinates. The second and third lines select all bounding boxes of the desired extent and find the centroid of these boxes. The centroids and GPS points make up a new table named 'evoTweetsGeo'. Now I have point geometries that can be used for analysis. 

### Network analysis <a name="rs-d"></a>
I can perform network analysis on rStudio using the igraph library. 

```
evoTweetNetwork <- network_graph(evoTweetsGeo, c("quote"))
plot.igraph(evoTweetNetwork)
```
<img src="/lab9/Rplot03.png" width="500">

Since I excluded retweets, there isn’t much here to see. This analysis would be useful to visualize who the 'gatekeepers' of tweets are. As Wang et al. mentioined, on twitter there exists a few elite users and opinion leaders whom many users rely on for information. If I had retweet data, these users would be immediately visible as the major nodes of the network. 

### Textual analysis <a name="rs-e"></a>

The first step in text analysis is to isolate the words from the text which is done in the first three lines of the code. Then we must remove stop words. These are words such as articles and short function words (e.g. "the", "and", "like") that are not useful in natural language processing. The SMART list is a handy tool that contains all the major stop words in the English language. In line five, I delete all stop words from our list of words. 
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
Then I made a graph of the most common words that appeared in the tweets. 
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
<img src="/lab9/Rplot01.png" width="500">

The words "Evo" and "Morales" topped the charts, which is unsurprising since that was our search criteria. The usual suspects follow like "Bolivia", "pueblo" meaning people, and "fraude" because of the election fraud accusations he was facing at the time of his resignation.  

Let us also visualize a word cloud that maps the interconnectivity of words; the closer the words, the more they were mentioned in conjunction. To do this, the first step is to create word pairs. Then, these pairs are counted by the number of occurrences and a network graph is created based on their frequency:
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
[r file](/twitlab.r)
[List of tweet IDs](/evoTweetID.csv)

## Textual Analysis of Twitter Activity During Dorian
<img src="/lab9/dorian-word-count.png" width="500">
<img src="/lab9/dorian-word-plot.png" width="500">

## Geographic Analysis of Twitter Activity During Dorian

