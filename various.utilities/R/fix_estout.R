#' @title Convert STATA estout .csv to R data frames
#' 
#' @description Get point estimates and SEs/T-values as a numeric data frame
#'   without the extra characters or formatting issues inputted by estout.
#' 
#' @details Ever wanted to just access the numbers from estout without
#'   having to deal with all the extra fluff included to make the output 
#'   readable by Excel, Word, or LaTeX? \code{fix_estout} is for you!
#'   \code{fix_estout} takes in a filename path to a .csv created by STATA's
#'   estout, and returns two data frames (in a list): \code{reg.results} giving
#'   the point estimates and \code{reg.ses} giving whatever second line option
#'   was picked (i.e. standard errors or t-values). All fluff ("=","()", etc.)
#'   is removed. The regresands are the column names (with .1, .2, as R does by
#'   default, for multiple specifications - a future version may offer the
#'   option to put different model specifications in different list elements),
#'   the regressors are the row names. The actual data frame is therefore purely
#'   numeric. 
#'   
#' @param fn A full (character) filename path pointing to the desired .csv
#'   created by estout.
#'
#' @return A list will be returned containing two data frames:
#'   \code{reg.results} giving the point estimates of the regression output and
#'   \code{reg.ses} giving the second line of the outputs (i.e. SEs or T values)
#'   
#' @examples 
#' \dontrun{fix_estout("~/code/regression_output.csv")}
fix_estout <- 
  function(fn) {
  # Load regression results
  reg.results <- read.csv(fn)
  
  # Get rid of the "=" and "()" stuff eststo puts in and fix names
  reg.results[] <- lapply(reg.results,function(x) gsub(pattern="=|[()]",replacement="",x=x))
  names(reg.results) <- reg.results[1,]
  reg.results <- reg.results[2:(nrow(reg.results)-2),]
  
  # Separate out standard errors
  reg.ses <- reg.results[seq(2,nrow(reg.results),by=2),2:ncol(reg.results)]
  rns <- reg.results[seq(1,nrow(reg.results),by=2),1] #separated out so we can use it below for the og as well
  rownames(reg.ses) <- rns
  reg.ses[] <- lapply(reg.ses,as.numeric)
  
  # Fix reg results df as well
  reg.results <- reg.results[seq(1,nrow(reg.results),by=2),2:ncol(reg.results)]
  rownames(reg.results) <- rns
  reg.results[] <- lapply(reg.results,as.numeric)
  
  return(list("reg.results" = reg.results,"reg.ses" = reg.ses))
  
}