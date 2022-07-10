# Lets explore the BLPestimatoR package.
require(BLPestimatoR)

# Nevo 2001 cereal example

nevos_model <- as.formula("share ~  price + productdummy |
    0 + productdummy |
    price + sugar + mushy | 
    0 + IV1 + IV2 + IV3 + IV4 + IV5 + IV6 + IV7 + IV8 + IV9 + IV10 + 
    IV11 + IV12 + IV13 + IV14 + IV15 + IV16 + IV17 + IV18 + IV19 + IV20")

A <- productData_cereal
B <- demographicData_cereal


productData_cereal$startingGuessesDelta <- c(log(w_guesses_cereal)) 
# include orig. draws in the product data

cereal_data <- BLP_data(
  model = nevos_model,
  market_identifier = "cdid",
  par_delta = "startingGuessesDelta",
  product_identifier = "product_id",
  productData = productData_cereal,
  demographic_draws = demographicData_cereal,
  blp_inner_tol = 1e-6, blp_inner_maxit = 5000,
  integration_draws = originalDraws_cereal,
  integration_weights = rep(1 / 20, 20)
)