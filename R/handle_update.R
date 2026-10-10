#' Handle Data Update
#'
#' Orchestrates the update process: checks if update is needed,
#' processes data, writes output, and stores the new checksum.
#'
#' @importFrom opentimeseries is_update_needed update_checksum
#' @importFrom digest digest
#' @export
handle_update <- function() {

  checksum_input <- generate_checksum_input()

  if (!is_update_needed(checksum_input)) {
    message("No update needed, series up-to-date.")
    return(invisible(NULL))
  }

  # Edit R/process_data.R and enter a function
  # that returns the most recent version of a time series
  # from its original provider
  # Store checksum after successful update
  upd <- update_checksum(digest(checksum_input, algo = "sha256"))
  if(upd){
    process_data()
  } else {
    message("Checksum initialized. Data untouched.")
  }
  message("Update complete, checksum stored.")
}


#' User Written Function to Create Input for Checksum Comparison
#'
#' This function generates input for computation of checksums to identify
#' outdated content. Good inputs are either publication dates extracted from
#' official publisher sites or APIs or any single time series from a database,
#' because opentsi definition all time series of the same dataset must
#' have the same publication date.
generate_checksum_input <- function(){
  sample_key <- "ch.kof.trsm.fcst.ty.l.all.alpin.lg"
  ts <- fetch_ts(sample_key)
  return(ts)
}
