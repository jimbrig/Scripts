# create_archived_file.R

create_archived_file <- function(file, last_modified, with_time) {

  # create main suffix depending on type
  suffix_main <- ifelse(last_modified,
                        as.character(file.info(file)$mtime),
                        as.character(Sys.time()))

  if (with_time) {

    # create clean date-time suffix
    suffix <- gsub(pattern = " ", replacement = "_", x = suffix_main)
    suffix <- gsub(pattern = ":", replacement = "-", x = suffix)

    # add "at" between date and time
    suffix <- paste0(substr(suffix, 1, 10), "_at_", substr(suffix, 12, 19))

  } else {

    # create date suffix
    suffix <- substr(suffix_main, 1, 10)

  }

  # create info to paste depending on type
  type_info <- ifelse(last_modified,
                      "_MODIFIED_on_",
                      "_ARCHIVED_on_")

  # get file extension (could be any of "RDS", "Rds", "rds", etc.)
  ext <- paste0(".", tools::file_ext(file))

  # replace extension with suffix
  archived_file <- gsub(pattern = paste0(ext, "$"),
                        replacement = paste0(type_info,
                                             suffix,
                                             ext),
                        x = file)

  return(archived_file)

}
