at_builder <- 
function(data,
         terms,
         at = NULL, 
         atmeans = FALSE, 
         ...){
    if(!is.null(at) && length(at) > 0) {
        if(any(!names(at) %in% names(data)))
            stop("Unrecognized variable name in 'at'")
        e <- expand.grid(at)
        e <- split(e, unique(e))
        data_out <- lapply(e, function(z) {
            # build new data
            dat <- data
            dat <- `[<-`(dat, , names(z), value = z)
            # build new model.matrix
            out <- as.data.frame(model.matrix(object = terms, data = dat)) # this will fail with factors
            out <- `[<-`(out, , names(z), value = z)
            if(atmeans) {
                for(i in names(out)[!names(out) %in% names(at)]){
                    out[,i] <- mean(out[,i])
                    dat[,i] <- mean(dat[,i]) # haven't check this
                }
            }
            list(data = dat, mm = data_out)
        })
    } else {
        out <- model.matrix(object = terms, data = data)
        if(atmeans) {
            dat <- list(as.data.frame(t(colMeans(data))))
            out <- list(as.data.frame(t(colMeans(out))))
        } else {
            dat <- data
            out <- list(as.data.frame(out))
        }
        return(list(data = dat, mm = out))
    }
}