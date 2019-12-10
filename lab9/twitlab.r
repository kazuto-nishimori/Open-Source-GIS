#search and analyze twitter data, by Joseph Holler, 2019, modified by Kazuto Nishimori, 2019
#following tutorial at https://www.earthdatascience.org/courses/earth-analytics/get-data-using-apis/use-twitter-api-r/
#also get advice from the rtweet page: https://rtweet.info/
#to do anything, you first need a twitter API token: https://rtweet.info/articles/auth.html 

#install packages for twitter, census, data management, and mapping
install.packages(c("rtweet","tidycensus","tidytext","maps","RPostgres","igraph","tm", "ggplot2","RColorBrewer","rccmisc","ggraph"))


#initialize the libraries. this must be done each time you load the project
library(rtweet)
library(igraph)
library(dplyr)
library(tidytext)
library(tm)
library(tidyr)
library(ggraph)
library(tidycensus)
library(ggplot2)
library(RPostgres)
library(RColorBrewer)
library(DBI)
library(rccmisc)

help(rtweet) # put a library name or function in the help function to get help on anything!

#set up twitter API information
#this should launch a web browser and ask you to log in to twitter
#replace app, consumer_key, and consumer_secret data with your own developer acct info
twitter_token <- create_token(
  app = "APP",  					#replace ??? with your app name
  consumer_key = "KEY",  		#replace ??? with your consumer key
  consumer_secret = "SECRET",  #replace ??? with your consumer secret
  access_token = NULL,
  access_secret = NULL
)

#reference for search_tweets function: https://rtweet.info/reference/search_tweets.html 
#don't add any spaces in between variable name and value. i.e. n=1000 is better than n = 1000
#evoTweets will be a new data frame object holding the Twitter data found by search_tweets function
#the first parameter in quotes is the search string, searching tweet contents and hashtags
#n=10000 asks for 10,000 tweets
#if you want more than 18,000 tweets, change retryonratelimit to TRUE and wait 15 minutes for every batch of 18,000
#include_rts=FALSE excludes retweets.
#token refers to the twitter token you defined above for access to your twitter developer account
#geocode is equal to a string with three parts: longitude, latidude, and distance with the units mi for miles or km for kilometers

#try changing the region and the search parameters to something of your own interest in the past 3-4 days
evoTweets <- search_tweets("Morales OR Evo", n=10000, retryonratelimit=FALSE, include_rts=FALSE, token=twitter_token, geocode="28.3,-81.6,350km")


############# TEMPORAL ANALYSIS ############# 

#create temporal data frame & graph it
evoTweetHours <- ts_data(evoTweets, by="hours")
ts_plot(evoTweets, by="hours")



############# FIND ONLY PRECISE GEOGRAPHIES ############# 

#reference for lat_lng function: https://rtweet.info/reference/lat_lng.html
#adds a lat and long field to the data frame, picked out of the fields you indicate in the c() list
#sample function: lat_lng(x, coords = c("coords_coords", "bbox_coords"))

# list unique/distinct place types to check if you got them all
unique(evoTweets$place_type)

# list and count unique place types
# NA results included based on profile locations, not geotagging / geocoding. If you have these, it indicates that you exhausted the more precise tweets in your search parameters
count(evoTweets, place_type)

#this just copied coordinates for those with specific geographies
#do not use geo_coords! Lat/Lng will come out inverted

#convert GPS coordinates into lat and lng columns
evoTweets <- lat_lng(evoTweets,coords=c("coords_coords"))

#select any tweets with lat and lng columns (from GPS) or designated place types of your choosing
evoTweetsGeo <- subset(evoTweets, place_type == 'city'| place_type == 'neighborhood'| place_type == 'poi' | !is.na(lat))

#convert bounding boxes into centroids for lat and lng columns
evoTweetsGeo <- lat_lng(evoTweetsGeo,coords=c("bbox_coords"))



############# NETWORK ANALYSIS ############# 

#create network data frame. Other options for 'edges' in the network include
evoTweetNetwork <- network_graph(evoTweetsGeo, c("quote"))

plot.igraph(evoTweetNetwork)
#Please, this is incredibly ugly... if you finish early return to this function and see if we can modify its parameters to improve aesthetics



############# TEXT / CONTEXTUAL ANALYSIS ############# 

evoTweetsGeo$text <- plain_tweets(evoTweetsGeo$text)

evoText <- select(evoTweetsGeo,text)
evoWords <- unnest_tokens(evoText, word, text)

# how many words do you have including the stop words?
count(evoWords)

#create list of stop words (useless words) and add "t.co" twitter links to the list
data("stop_words")
stop_words <- stop_words %>% add_row(word="t.co",lexicon = "SMART") %>% add_row(word="de" )%>% add_row(word="la" )%>% add_row(word="el" )%>% add_row(word="en" )%>% add_row(word="se" )%>% add_row(word="es" )%>% add_row(word="los" )%>% add_row(word="lo" )%>% add_row(word="por" )%>% add_row(word="con" )%>% add_row(word="del" )%>% add_row(word="su" )%>% add_row(word="para" )%>% add_row(word="al" )%>% add_row(word="las" )%>% add_row(word="le"  )%>% add_row(word="si" )%>% add_row(word="como" )%>% add_row(word="pero" )%>% add_row(word="una" )%>% add_row(word="te"  )%>% add_row(word="te" ) %>% add_row(word="ser" ) %>% add_row(word="sus" ) %>% add_row(word="eso" ) %>% add_row(word="est" ) %>% add_row(word="esta" ) %>% add_row(word="fue" )%>% add_row(word="va" ) %>% add_row(word="tu" ) %>% add_row(word="a" )

evoWords <- evoWords %>%
  anti_join(stop_words) 

# how many words after removing the stop words?
count(evoWords)

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

evoWordPairs <- evoTweetsGeo %>% select(text) %>%
  mutate(text = removeWords(text, stop_words$word)) %>%
  unnest_tokens(paired_words, text, token = "ngrams", n = 2)

evoWordPairs <- separate(evoWordPairs, paired_words, c("word1", "word2"),sep=" ")
evoWordPairs <- evoWordPairs %>% count(word1, word2, sort=TRUE)

#graph a word cloud with space indicating association. you may change the filter to filter more or less than pairs with 10 instances
evoWordPairs %>%
  filter(n >= 10) %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  geom_edge_link(aes(edge_alpha = n, edge_width = n)) +
  geom_node_point(color = "darkslategray4", size = 3) +
  geom_node_text(aes(label = name), vjust = 1.8, size = 3) +
  labs(title = "Word Network: Tweets in Florida after failed coup in Bolivia",
       subtitle = "November 2019 - Text mining twitter data ",
       x = "", y = "") +
  theme_void()

############# SPATIAL ANALYSIS ############# 

#get a Census API here: https://api.census.gov/data/key_signup.html
#replace the key text 'yourkey' with your own key!
Counties <- get_estimates("county",product="population",output="wide",geometry=TRUE,keep_geo_vars=TRUE, key="YOUR KEY")

#select only the states you want, with FIPS state codes in quotes in the c() list
#Warning: I missed washington DC in this list! It's selecting by FIPS codes
#look up fips codes here: https://en.wikipedia.org/wiki/Federal_Information_Processing_Standard_state_code 
NorthEastCounties <- filter(Counties,STATEFP %in% c("12") )

#map results with GGPlot
#note: cut_interval is an equal interval classification function, while cut_numer is a quantile / equal count function
#you can change the colors, titles, and transparency of points
ggplot() +
  geom_sf(data=NorthEastCounties, aes(fill=cut_number(DENSITY,5)), color="grey")+
  scale_fill_brewer(palette="GnBu")+
  guides(fill=guide_legend(title="Population Density"))+
  geom_point(data = evoTweetsGeo, aes(x=lng,y=lat),
             colour = 'purple', alpha = .5) +
  labs(title = "Locations of Tweet mentioning Evo Morales during the coup")+
  theme(plot.title=element_text(hjust=0.5),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())
  


############### UPLOAD RESULTS TO POSTGIS DATABASE ###############

#Connectign to Postgres
#Create a con database connection with the dbConnect function.
#Change the database name, user, and password to your own!
con <- dbConnect(RPostgres::Postgres(), dbname='YOUR DATABASE', host='YOUR HOST', user='YOUR USERNAME', password='YOUR PASSWORD') 

#list the database tables, to check if the database is working
dbListTables(con) 

#create a simple table for uploading
evo <- select(evoTweetsGeo,c("user_id","status_id","text","lat","lng"),starts_with("place"))

#write data to the database
#replace new_table_name with your new table name
#replace dhshh with the data frame you want to upload to the database 
dbWriteTable(con,'floridatweets',evo, overwrite=TRUE)

#SQL to add geometry column of type point and crs NAD 1983: 
#SELECT AddGeometryColumn ('public','evo','geom',4269,'POINT',2, false);
#SQL to calculate geometry: update evo set geom = st_transform(st_makepoint(lng,lat),4326,4269);

#make all lower-case names for this table
necounties <- lownames(NorthEastCounties)
dbWriteTable(con,'floridacounties',necounties, overwrite=TRUE)
#SQL to update geometry column for the new table: select populate_geometry_columns('necounties'::regclass);

#disconnect from the database
dbDisconnect(con)

##################   EXPORT TWEET ID #########################
evoTweetId <- select(evoTweets,c("user_id","status_id"))
write.csv(evoTweetId,file="evoTweetID.csv")