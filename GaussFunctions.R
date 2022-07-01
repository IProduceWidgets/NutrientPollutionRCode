##### Load Packages #####

##### Indicator #####

GAUSSFUNCTIONS_ON <- T

##### recreating Roger's functions from Gauss in R #####

aggshare <- function(v,asc,gi,n,nl){
  v = v + c(0,asc)
  nest = colSums(gi[,2:n]*exp(v[,2:n]/nl)) # could need the my_exp function ?
  p0 = matrix(0, nrow(v),n)
  p0[,1] = exp(v[,1])/(exp(v[,1])+nest^nl)
  p0[,2:n] = exp(v[,2:n]/nl)*(nest^(nl-1))/(exp(v[,1])+nest^nl)
  p0 = gi*p0
  p0 = colSums(CO*p0)/(sum(colSums(CO*p0))) # CO is defined globally in dclGaussAttempt. !!!
  return(p0[2:n])
}


berry <- function(v,asc,n,ash,lnash,gi,nl){
  asc_0 = asc
  agg_s0 = aggshare(v,asc_0,gi,n,nl)
  tol = colSums((agg_s0-ash)^2)
  k = 1
  while (tol >= EPS_B){ # EPS_B set globally in dclGaussAttempt. !!!
    asc_1 = asc_0 + lnash - ln(agg_s0)  #could need my_ln from gauss ?
    asc_1 = .5*asc_0 + .5*asc_1
    agg_s1 = aggshare(v, asc_1, gi, n, nl)
    tol = colSums((agg_s1-ash)^2)
    if ((k %% 1) == 0){
      print(k~tol)
    }
    asc_0 = asc_1
    agg_s0 = agg_s1
    k = k+1
  }
  print(sprintf('Number of iterations: %1.0f', k))
  return(asc_0)
}