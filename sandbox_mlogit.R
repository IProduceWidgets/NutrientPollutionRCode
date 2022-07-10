library(mlogit)

data(Car)
 Car$choice <- substr(Car$choice, 7,7)
 mlogit.Car <- mlogit.data(Car,
                           choice = 'choice',
                           shape = 'wide',
                           varying = 5:70,
                           sep="")
 model <- mlogit(choice ~ type + fuel + price | college, 
                 data = mlogit.Car)
 summary(model)
 