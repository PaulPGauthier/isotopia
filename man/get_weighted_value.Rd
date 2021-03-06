% Generated by roxygen2 (4.0.0): do not edit by hand
\name{get_weighted_value}
\alias{get_weighted_value}
\title{Retrieve isotope object's weighted values}
\usage{
get_weighted_value(iso)
}
\value{
In the case of a single isotope object (Isoval), returns a numeric
vector of the object's values weighted by the object's weights. In the case of an isotope system (Isosys),
returns the data frame underlying the object with all its isotope value
objects replaced with their weighted values.
}
\description{
This function returns an isotope object's weighted values.
}
\seealso{
\code{\link{as.data.frame}}, \code{\link[base]{as.data.frame}} (base method)

Other data type attributes: \code{\link{get_label}},
  \code{\link{get_name}}, \code{\link{get_units}};
  \code{\link{get_value}}; \code{\link{get_weight}};
  \code{\link{set_attrib}}; \code{\link{switch_notation}};
  \code{\link{weight}}
}

