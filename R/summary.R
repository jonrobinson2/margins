#' @export
summary.margins <- 
function(object, digits = 4, level = 0.95, ...) {
    if (attributes(object)[["atmeans"]]) {
        if (is.null(attributes(object)[["at"]])) {
            cat("Marginal Effects at Means\n")
        } else {
            atvals <- paste(names(attributes(object)[["at"]]), "=", attributes(object)[["at"]][1,], collapse = ", ")
            cat("Marginal Effects at Means, with ", atvals, "\n")
        }
    } else {
        if (is.null(attributes(object)[["at"]])) {
            cat("Average Marginal Effects\n")
        } else {
            atvals <- paste(names(attributes(object)[["at"]]), "=", attributes(object)[["at"]][1,], collapse = ", ")
            cat("Average Marginal Effects, with ", atvals, "\n")
        }
    }
    if (!is.null(attributes(object)[["call"]])) {
        cat(deparse(attributes(object)[["call"]]), "\n\n")
    }
    fmt <- paste0("%0.", ifelse(digits > 7, 7, digits), "f")
    mes <- extract_marginal_effects(object)
    tab <- structure(list(Factor = names(mes), 
                          "dy/dx" = colMeans(mes),
                          "Std.Err." = sqrt(attributes(mes)[["Variances"]])
                          ),
                     class = "data.frame", row.names = names(mes))
    tab[["z value"]] <- tab[,"dy/dx"]/tab[,"Std.Err."]
    tab[["Pr(>|z|)"]] <- 2 * pnorm(abs(tab[,"z value"]), lower.tail = FALSE)
    tab <- cbind(tab, confint(object = object, level = level))
    for (i in 2:ncol(tab)) {
        tab[[i]] <- sprintf(fmt, tab[[i]])
    }
    tab
}

#' @export
summary.marginslist <- 
function(object, row.names = FALSE, ...) {
    out <- list()
    for (i in seq_len(length(object))) {
        out[[i]] <- print(summary(object[[i]]), row.names = row.names, ...)
        cat("\n")
    }
    invisible(out)
}
