% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/build_datalist.R
\name{build_datalist}
\alias{build_datalist}
\title{Build list of data.frames}
\usage{
build_datalist(data, at = NULL, atmeans = FALSE, ...)
}
\arguments{
\item{data}{A data.frame containing the original data.}

\item{at}{A list of one or more named vectors of values, which will be used to specify values of variables in \code{data}. See examples.}

\item{atmeans}{A logical indicating whether, \emph{after} replacing values in \code{at}, to return one-row data.frames containing variable means.}

\item{\dots}{Ignored.}
}
\value{
A list of data.frames.
}
\description{
Construct a list of data.frames based upon an input data.frame and a list of one or more \code{at} values
}
\examples{
# basic examples
require("datasets")
build_datalist(head(mtcars), at = list(cyl = c(4, 6)))

str(build_datalist(head(mtcars, at = list(cyl = c(4,6), wt = c(1,2,3)))))

}
\author{
Thomas J. Leeper
}
\seealso{
\code{\link{margins}}
}
\keyword{data}
\keyword{manip}

