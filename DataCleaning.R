##### Load Packages #####

##### Indicator #####
DATACLEANING_on <- T
##### Clean the DCdf data #####

##### Clean Site Characteristic Data #####

FreshIds <- SiteChars %>%
  filter(fresh == 1) %>%
  transmute(
    siteid
  ) #^ this makes a list of site IDs that are freshwater

NewSiteChars <- SiteChars %>%
  filter(
    fresh != 1 | is.na(fresh) #This is just a quirk of Dplyr since Nate's DF has NA's
  ) %>% #^ This drops any freshwater sites since they make little sense in our model
  transmute(
    siteid,
    #trips,           # Congestion has endogeneity stuff, I'll worry about this later
    Cape_Cod,
    exposed,
    sheltered,
    has_docks,
    has_rocks,
    armored,
    rocky,
    sand,
    vegetated,
    beac_mea_1,      # beac_mean_daysclosed
    All_Pathog,
    All_Nutrie,
    All_Biolog,
    All_Contam,
    All_Other,
    #shellfish_class, # Needs to be seperated into dummies probably
    clarity_ra,
    mci_raster,
    poly_clari,
    poly_mci_r
    #Impervious,      # This may just be error from remote sensing missing data
  ) ### This has kept only variables that have enough data to use.

#### NewDCdf ####
# what follows is just some df gymnastics to get a list of column names 
# to drop from DCdf 
# I guess I could of done this with Dplyr::select(matches(.)) 
# and a regular expression, but...

DropId1 <- FreshIds %>%
  transmute(
    ColName = paste('costsd', siteid, sep='')
  )

DropId2 <- FreshIds %>%
  transmute(
    ColName = paste('trips', siteid, sep='')
  )

DropId <- DropId1 %>%
  full_join(DropId2, by = 'ColName')

# Create Cleaned Data Frame #

NewDCdf <- DCdf %>%
  select(
    -one_of(DropId$ColName)
  ) #^ haleluja it worked. Now only contains info on non-fresh sites.
