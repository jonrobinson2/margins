#' @title Perspective plots for models
#' @description Draw one or more perspectives plots reflecting predictions or marginal effects from a model. Currently methods exist for \dQuote{lm} and \dQuote{glm} models.
#' @param object A model object.
#' @param x A character string specifying the names of variables to use as the \samp{x} dimension in the plot. See \code{\link[graphics]{persp}} for details.
#' @param y A character string specifying the names of variables to use as the \samp{y} dimension in the plot. See \code{\link[graphics]{persp}} for details.
#' @param z A character string specifying whether to draw \dQuote{prediction} (fitted values from the model, calculated using \code{\link[stats]{predict}}) or \dQuote{effect} (marginal effect of \code{which[1]}, using \code{\link{margins}}).
#' @param type A character string specifying whether to calculate predictions on the response scale (default) or link (only relevant for non-linear models).
#' @param nx An integer specifying the number of points across \code{x} at which to calculate the predicted value or marginal effect.
#' @param ny An integer specifying the number of points across \code{y} at which to calculate the predicted value or marginal effect.
#' @param theta An integer vector specifying the value of \code{theta} in \code{\link[graphics]{persp}}. If length greater than 1, multiple subplots are drawn with different rotations.
#' @param phi An integer vector specifying the value of \code{phi} in \code{\link[graphics]{persp}}. If length greater than 1, multiple subplots are drawn with different rotations.
#' @param shade An integer vector specifying the value of \code{shade} in \code{\link[graphics]{persp}}. 
#' @param xlab A character string specifying the value of \code{xlab} in \code{\link[graphics]{persp}}. 
#' @param ylab A character string specifying the value of \code{ylab} in \code{\link[graphics]{persp}}. 
#' @param zlab A character string specifying the value of \code{zlab} in \code{\link[graphics]{persp}}. 
#' @param ticktype A character string specifying one of: \dQuote{detailed} (the default) or \dQuote{simple}. See \code{\link[graphics]{persp}}.
#' @param \dots Additional arguments passed to \code{\link[graphics]{persp}}. 
#' @examples
#' require('datasets')
#' # prediction from several angles
#' m <- lm(mpg ~ wt*drat, data = mtcars)
#' persp(m, theta = c(45, 135, 225, 315))
#' 
#' # marginal effect of 'drat' across drat and wt
#' m <- lm(mpg ~ wt*drat*I(drat^2), data = mtcars)
#' persp(m, x = "drat", y = "wt"), z = "effect", nx = 10, ny = 10, ticktype = "detailed")
#' 
#' # a non-linear model
#' m <- glm(am ~ wt*drat, data = mtcars, family = binomial)
#' persp(m, theta = c(30, 60)) # prediction
#' 
#' # effects on linear predictor and outcome
#' persp(m, x = "drat", y = "wt", z = "effect", type = "link")
#' persp(m, x = "drat", y = "wt", z = "effect", type = "response")
#' 
#' @seealso \code{\link{plot.margins}}
#' @importFrom graphics persp
#' @importFrom grDevices n2mfrow
#' @export
persp.lm <- 
function(object, 
         x = attributes(terms(m))[["term.labels"]][1],
         y = attributes(terms(m))[["term.labels"]][2], 
         z = c("prediction", "effect"), 
         type = c("response", "link"), 
         nx = 25L,
         ny = nx,
         theta = 45, 
         phi = 10, 
         shade = 0.75, 
         xlab = which[1], 
         ylab = which[2], 
         zlab = if (match.arg(z) == "prediction") match.arg(z) else paste0(match.arg(z), " of ", which[1]),
         ticktype = c("detailed", "simple"),
         ...) {
    
    dat <- object[["model"]]
    dat[] <- lapply(dat, as.numeric) # this probably isn't a good idea
    
    which <- c(x, y)
    xvar <- x
    xvals <- seq(min(dat[[xvar]], na.rm = TRUE), 
                 max(dat[[xvar]], na.rm = TRUE), 
                 length.out = nx)
    yvar <- y
    yvals <- seq(min(dat[[yvar]], na.rm = TRUE), 
                 max(dat[[yvar]], na.rm = TRUE), 
                 length.out = ny)
    
    z <- match.arg(z)
    type <- match.arg(type)
    if (z == "prediction") {
        datmeans <- cbind.data.frame(lapply(colMeans(dat[, !names(dat) %in% which, drop = FALSE]), rep, length(xvals) * length(yvals)))
        outcome <- outer(xvals, yvals, FUN = function(a, b) {
            datmeans[, xvar] <- a
            datmeans[, yvar] <- b
            predict(object, datmeans, type = type)
        })
    } else if (z == "effect") {
        dat2 <- expand.grid(xvals, yvals)
        names(dat2) <- which
        cmeans <- colMeans(dat[, !names(dat) %in% which, drop = FALSE])
        for (i in seq_along(cmeans)) {
            dat2[[names(cmeans)[i]]] <- cmeans[i]
        }
        vals <- get_slopes(data = dat2, model = object, type = type)[, xvar]
        outcome <- matrix(NA_real_, nrow = nx, ncol = ny)
        outcome[as.matrix(expand.grid(1:nx, 1:ny))] <- vals
    }
    
    ticktype <- match.arg(ticktype)
    perspfun <- function(itheta, iphi, ...) {
        persp(xvals, yvals, outcome, theta = itheta, phi = iphi, 
              shade = 0.75, xlab = xlab, ylab = ylab, zlab = zlab, ticktype = ticktype, ...)
    }
    if ((length(theta) == 1) & (length(phi) == 1)) {
        perspfun(itheta = theta, iphi = phi, ...)
    } else {
        p <- par(mai = rep(0.2, 4))
        views <- expand.grid(theta = theta, phi = phi)
        dims <- n2mfrow(nrow(views))
        layout(matrix(1:prod(dims), nrow = dims[1], byrow = TRUE))
        mapply(perspfun, views[["theta"]], views[["phi"]])
        par(p)
    }
}

#' @export
persp.glm <- persp.lm