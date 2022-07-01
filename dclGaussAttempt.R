##### This follows NewMain.R #####
require(haven) # reads .dta
require(dplyr) # Blessed are the plumbers
require(readxl)  # reads .xlsx
#require(BLPestimatoR) # Berry (BLP) contraction mapping package

## sourcing functions from other scripts ##
setwd(ProjectDirectory)

if(!exists("GAUSSFUNCTIONS_on")){ # Check if script is loaded.
  source("GaussFunctions.R")
}

setwd(ProjectDirectory)
##### This attempts to emulate dcl.g #####

NIND <- 25230 # zip codes
NALT <- 553 # num of alternatives, excludes no trip.
ASNUM0 <- 6 # num of variables in alt specific indexes
ASNUM <- 1 # num of alt specific indexes (travel cost only)
MAX_DIS <- 1000000 # maximum distance to be included in choice set, (not restrictive at 1 million)
TC_NORM <- 100 #travel cost normalization
PRTHESS <- 0 # some hessian command parameter !!!!! ## CHANGE LATER ##
NITER <- 5000 # max iterations for maximization
EPS <- 0.00001 # tolerance for conversion
METHOD <- 2 # some hessian command parameter !!!!! ## CHANGE LATER ##

#### Load Data ####

filepath <- 'C:/Users/Avery/Desktop/Research_Folder/Nutrient_Pollution/GDriveData/'

DCdf <- read_dta(paste(filepath,
                       'gexport.dta',
                       sep='')) 

#^ has trip costs and counts from origins to destinations
#^ also contains 'individual' characteristics (from county census)

FRESH <- read.csv(paste(filepath,
                        'gexport1.txt',
                        sep=''), header = F, sep='\t')

DEMOS <- DCdf %>%
  transmute(
    Inc50kto67k = as.integer(income > 50000 & income <= 67000),
    Inc67kto90k = as.integer(income > 67000 & income <= 90000),
    IncOver90k  = as.integer(income > 90000),
    white,
    age = age/100,                # I'm not really sure why I do these divisions...
    density = density/10000
  )



CO <- DCdf$co # number of Choice Occasions

CHOI <- DCdf %>%
  select(4,(8+NALT):(2*NALT+7)) %>%
  mutate(NoTrips = co - select(., 2:554) %>% rowSums) %>% # all hail the pipe gods.
  select(NoTrips, everything(), -co)

DAS <- DCdf %>%
  select(8:(NALT+7)) %>%
  mutate(A = 0) %>%
  select(A, everything())
DAS <- DAS/TC_NORM

GI <- (1 - FRESH) %>%     # This creates a mask to later drop the freshwater sites.
  slice(rep(1, NIND)) %>%
  mutate(A = 1) %>%
  select(A, everything())

NALT <- NALT+1

DATA <- DEMOS

#########################################################
#  VARIABLES USED LATER
#########################################################

CHOI = CHOI*GI  # makes all the entries for freshwater sites 0.
NTRIPS = CHOI %>%
  transmute(Trips = select(., 2:554) %>% rowSums)
CO = CHOI %>% 
  transmute(ChoiceOccasions = rowSums(.,))

#########################################################
#  FINAL PARAMETER SETTINGS
#########################################################

B_BEGIN <- c(0,0,0,0,0,0,-1,.2, rep.int(-12, NALT-1))

BFIX = 1 # set to 1 if at least 1 parameter is fixed at start.

BFIXID = c(rep.int(1, length(B_BEGIN)))

#########################################################
# CALIBRATION OF ASCs
#########################################################

EPS_B <- 0.00000000000001 # for berry contraction mapping
v0 <- matrix(0, NIND, NALT)
beta0 <- B_BEGIN[1:ASNUM0]
beta1 <- B_BEGIN[(ASNUM0+1):(ASNUM0+ASNUM)]
theta1 <- exp(B_BEGIN[ASNUM0+ASNUM+1])/(1+exp(B_BEGIN[ASNUM0+ASNUM+1]))
# theta1 <- 1
k <- 1 
while (k <= ASNUM){
  v0 = v0 + beta1[k]*DAS[,((k-1)*NALT+1):(k*NALT)]
  k = k + 1
}

v0[,2:ncol(v0)] <- v0[,2:ncol(v0)] - rowSums(beta0*DATA)
ASC_B0 <- GI[1,2:NALT]*-8      # where does this -8 come from? Just a starting value?
ASHARE0 <- colSums(CHOI)/sum(colSums(CHOI))
ASHARE0 <- ASHARE0[2:length(ASHARE0)]
LNASHARE0 = log(ASHARE0)
ASC_F0 = berry(v0,ASC_B0,NALT,ASHER0,LNASHER0,GI,theta1)  
### and here is where I start needing to make my own functions. 
### (see 'proc' in gauss code) ## see GaussFunctions.R

#### Need to track down issues in berry(...) and aggshare(...) functions.