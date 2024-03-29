% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/hit.R
\name{hit}
\alias{hit}
\title{Calculate Herd Immunity Threshold}
\usage{
hit(R0)
}
\arguments{
\item{R0}{a positive double, the basic reproduction number}
}
\description{
Calculates Basic Herd Immunity Threshold Based on 
the Basic Reproduction Number
}
\examples{
# Calculate the Herd Immunity Threshold for R0 Between 1 and 9
o <- vapply(seq(1,9, .1), hit, FUN.VALUE = numeric(1))

plot(seq(1,9, .1), o, main = "HIT", type = "l",
    ylab = "Prop with Immunity", xlab = expression(R[0]))

}
