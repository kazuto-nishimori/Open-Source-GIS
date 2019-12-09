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

rStudio is an opensource data science software with a diverse ecosystem of libraries. We will be using quite a few of these including 'rtweet', to connect with twitter API and 'tidycensus' to connect with the US census API. The first step is to install these libraries into the project using the following command:
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
This command uses the API information we obtained earlier to search for tweets with keywords “Evo” or “Morales” in a 350km radius around central Florida (28.3, -81.6) and populates a table called “evoTweets”. No retweets were included. Now that we have the tweets, there is a plethora of things we can do with this data. 

### Temporal analysis <a name="rs-b"></a>
The twitter data downloaded with rtweet is neatly organized into a usable table. The column ‘hours’ contains the time stamp of each tweet. Dealing with timestamps is often a headache in coding because there exists a myriad of formats used. Thankfully, rtweet’s `ts_plot` function makes it extremely straight forward to create a plot with respect to time: 
```
evoTweetHours <- ts_data(evoTweets, by="hours")
ts_plot(winterTweets, by="hours")
```
<img src="/lab9/Rplot.png" width="500">
The plot agrees with what we expected. There is a sudden spike in tweets mentioning Evo Morales on the night of November 10, the day he announced his resignation. The tweets fluctuate up and down reflecting the waking hours of the tweeters, and each day the peaks diminish in height as they slowly lose interest in the topic. 

### Extracting precise geographies <a name="rs-c"></a>

### Network analysis <a name="rs-d"></a>
<img src="/lab9/Rplot03.png" width="500">

### Text analysis <a name="rs-e"></a>
<img src="/lab9/Rplot01.png" width="500">
<img src="/lab9/Rplot02.png" width="500">
<img src="/lab9/Rplot02-edit.png" width="500">

### Spatial analysis <a name="rs-f"></a>
Census shit
<img src="/lab9/Rplot04.png" width="500">

### Uploading results to PostGIS for further spatial analysis <a name="rs-g"></a>

