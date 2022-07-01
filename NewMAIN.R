##### This is the main code for Travel Cost Modeling (following Murdock 2006) #####
# This file was started April 19, 2022
# The goal of this file is to take in a DF for a discrete choice model, 
# and estimate travel cost ASCs.

# Required packages
require(haven) # reads .dta
require(dplyr) # Blessed are the plumbers
require(readxl)  # reads .xlsx
require(Rchoice) # pkg for choice modeling w/ random parameters.

###############################################################################
#### Data read-in ####

filepath <- 'C:/Users/Avery/Desktop/Research_Folder/Nutrient_Pollution/TravelCostRCode/GDriveData/'

DCdf <- read_dta(paste(filepath,
                       'gexport.dta',
                       sep='')) 
#^ has trip costs and counts from origins to destinations
#^ also contains 'individual' characteristics (from county census)

NumSites <- 445 # 553 before dropping freshwater, 108 fresh

SiteChars <- read_xlsx(paste(filepath,
                             'destinations_attributes_nov2021.xlsx',
                             sep=''))
#^ contains all the site chars that Nate sent us.

###############################################################################

#### what follows is just some df gymnastics to get a list of column names to drop from DCdf ####
# I guess I could of done this with Dplyr::select(matches(.)) and a regular expression, but...

FreshIds <- SiteChars %>%
  filter(fresh == 1) %>%
  transmute(
    siteid
  ) #^ this makes a list of site IDs that are freshwater

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

#### Create Cleaned Data Frames ####

NewDCdf <- DCdf %>%
  select(
    -one_of(DropId$ColName)
  ) #^ haleluja it worked. Now only contains info on non-fresh sites.

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

#### Run the first stage discrete choice model ####

