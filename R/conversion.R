#' @include classes.R
NULL

# FIXME: convert to to_ratio, to_delta, etc.

#' Convert to isotope ratio
#' 
#' \code{to_ratio} converts another isotopic data type to a ratio.
#'
#' @param iso isotopic data object (\code{\link{ratio}}, \code{\link{abundance}}, \code{\link{delta}}, etc.)
#' @return isotope \code{\link{ratio}} object if iso can be converted to a \code{\link{ratio}}, an error otherwise
#' @rdname to_ratio
#' @family data type conversions
#' @export
#' @genericMethods
setGeneric("to_ratio", function(iso) standardGeneric("to_ratio"))
setMethod("to_ratio", "ANY", function(iso) stop("can't do that"))
setMethod("to_ratio", "Ratio", function(iso) iso)
setMethod("to_ratio", "data.frame", function(iso) {
    stop("not implemented yet")
    # implement that it basically takes all parts of the df. that are Isoval and tries to make an isosys
    # out of that portion of the data frame --> apply the to_ratio on that part of the df and cbind the thing
    # back together - only allow one type of system (they must all be the same)
})
setMethod("to_ratio", "Ratios", function(iso) {
    stop("not implemented")
    # now can do proper conversion
    # --> validation whether everything is in order for conversion will happen at this point!
    # i.e. checks that all have same major isotope, have corrent ratio defined, etc., etc.
})
