##### Load Packages #####
require(haven) # reads .dta
require(dplyr) # Blessed are the plumbers
require(readxl)  # reads .xlsx
require(Rchoice) # pkg for choice modeling w/ random parameters.

##### Indicator #####
DATAIMPORT_on <- T
##### 

DCdf <- read_dta(
  file.path('..','GDriveData','gexport.dta')
) 
#^ has trip costs and counts from origins to destinations
#^ also contains 'individual' characteristics (from county census)

NumSites <- 445 # 553 before dropping freshwater, 108 fresh

SiteChars <- read_xlsx(
  file.path('..','GDriveData','destinations_attributes_nov2021.xlsx')
)
#^ contains all the site chars that Nate sent us.