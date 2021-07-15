#' add pdf logos
#'
#' Set logos as environment variables for slideR design
#'
#' @param doc_prefix Path to pdf_theme_prefix. Default (NULL) will look up where package is located for default document.
#'
#' @export
#'
add_logos_pdf <- function(doc_prefix = NULL) {

  logo <- "figures/egLogo"
  satrday_logo <- "figures/satRdayJoburgLogo"

  if (is.null(doc_prefix)) {
    template_path <- system.file(
      "rmarkdown", "templates", "slideR_pdf", package = "slideR"
    )
    ## set locations of css and doc pre/suf fixes
    doc_prefix <- file.path(
      template_path, "resources", "pdf_theme_prefix.tex"
    )
  }
  con <- file(doc_prefix)
  x <- readLines(con, warn = FALSE)
  close(con)

  ## BOTTOM LEFT LOGO
  bl <- Sys.getenv("FVASLIDES_BOTTOMLEFT")
  ## if not set then ask and set
  if (identical(bl, "")) {
    if (interactive()) {
      ## if env var not set, then ask user and set it for future sessions
      bl <- readline_("What is the full path for BOTTOMLEFT image?")
      if (nchar(bl) > 0L) {
        cat(
          paste0("FVASLIDES_BOTTOMLEFT=", bl),
          file = .Renviron(),
          append = TRUE, fill = TRUE
        )
      }
    } else {
      ## if not interactive then guess the path
      bl <- ""
    }
  }

  ## BOTTOM RIGHT LOGO
  br <- Sys.getenv("FVASLIDES_BOTTOMRIGHT")
  if (identical(br, "")) {
    if (interactive()) {
      br <- readline_("What is the full path for BOTTOMRIGHT image?")
      if (nchar(br) > 0L) {
        cat(
          paste0("FVASLIDES_BOTTOMRIGHT=", br),
          file = .Renviron(),
          append = TRUE, fill = TRUE
        )
      }
    } else {
      ## if not interactive then guess the path
      br <- fva_logo
    }
  }
  if (file.exists(bl) || file.exists(br)) {
    x <- gsub("BOTTOMLEFT", bl, x)
    x <- gsub("BOTTOMRIGHT", br, x)
  } else {
    x <- grep("BOTTOMLEFT", x, invert = TRUE, value = TRUE)
    x <- grep("BOTTOMRIGHT", x, invert = TRUE, value = TRUE)
  }

  ## BOTTOM TITLE BANNER
  bn <- Sys.getenv("FVASLIDES_BANNER")
  if (identical(bn, "")) {
    if (interactive()) {
      bn <- readline_("What is the full path for BANNER image?")
      if (nchar(bn) > 0L) {
        cat(
          paste0("FVASLIDES_BANNER=", bn),
          file = .Renviron(),
          append = TRUE, fill = TRUE
        )
      }
    } else {
      ## if not interactive then guess the path
      bn <- fva_logo
    }
  }
  if (file.exists(bn)) {
    x <- gsub("BANNER", bn, x)
  } else {
    x <- grep("BANNER", x, invert = TRUE, value = TRUE)
  }

  ## BACKGROUND WATERMARK
  bg <- Sys.getenv("FVASLIDES_BACKGROUND")
  if (identical(bg, "")) {
    if (interactive()) {
      ## if env var not set, then ask user and set it for future sessions
      bg <- readline_("What is the full path for BACKGROUND image?")
      if (nchar(bg) > 0L) {
        cat(
          paste0("FVASLIDES_BACKGROUND=", bg),
          file = .Renviron(),
          append = TRUE, fill = TRUE
        )
      }
    } else {
      ## if not interactive then guess
      bg <- satrday_logo
    }
  }
  if (file.exists(bg)) {
    x <- gsub("BACKGROUND", bg, x)
  } else {
    x <- grep("BACKGROUND", x, invert = TRUE, value = TRUE)
  }

  ## save as temp file
  tmp <- tempfile(fileext = ".tex")
  writeLines(x, tmp)
  invisible(tmp)
}
