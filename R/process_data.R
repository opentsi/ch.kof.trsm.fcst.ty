#' Fetch Time Series from the KOF Time Series Database API
#'
#' Sends a GET request to the public endpoint of the KOF Time Series
#' Database API and returns the parsed JSON response.
#'
#' @importFrom httr2 request req_url_path_append req_url_query req_perform resp_body_json
#' @param ts_keys Character vector of time series keys.
#' @param valid_on Date of the vintage to read. Defaults to today, i.e. the
#'   most recent released vintage.
#' @return A list with one element per time series, each holding
#'   \code{ts_key}, \code{vintage_date}, \code{time}, \code{value} and
#'   \code{frequency}.
fetch_ts <- function(ts_keys, valid_on = Sys.Date()) {
  request("https://tsdb-api.kof.ethz.ch/v2") |>   # base url
    req_url_path_append("ts") |>                  # endpoint
    req_url_query(                                # query params
      keys = paste(ts_keys, collapse = ","),
      valid_on = as.character(valid_on),
      access_type = "public"
    ) |>
    req_perform() |>                              # send GET request
    resp_body_json()                              # parse response
}


#' Process KOF TRSM FCST TY Data
#'
#' Fetches all time series of the ch.kof.trsm.fcst.ty dataset from the KOF
#' Time Series Database and writes each to its key.csv
#'
#' @importFrom opentimeseries list_series
#' @return Invisibly returns a character vector of output file paths.
#' @export
process_data <- function() {
  # set keys (aka all keys in index.md)
  # can use opentimeseries function for this
  keys <- list_series("opentsi/ch.kof.trsm.fcst.ty")
  # index.md lists keys without the dataset prefix, the API needs full keys
  tsl <- fetch_ts(paste0("ch.kof.trsm.fcst.ty.", keys))

  out_paths <- lapply(tsl, function(ts_obj) {
    # remove prefix so it matches with current data
    k <- sub("^ch\\.kof\\.trsm\\.fcst\\.ty\\.", "", ts_obj$ts_key)
    print(k)

    output_path <- file.path("data-raw", "csv", paste0(k, ".csv"))

    ts_dates <- as.Date(unlist(ts_obj$time))
    # missing observations arrive as JSON null
    values <- vapply(
      ts_obj$value,
      function(v) if (is.null(v)) NA_real_ else as.numeric(v),
      numeric(1)
    )

    ts_df <- data.frame(time = ts_dates, value = values)
    write.csv(ts_df, file = output_path, row.names = FALSE, quote = FALSE)
    message(sprintf("Written: %s", output_path))
    output_path
  })

  invisible(unlist(out_paths))
}
