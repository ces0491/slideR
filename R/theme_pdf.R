#' pdf_theme
#'
#' Document template for fractalSlides pdf beamer presentation.
#' @inheritParams rmarkdown::beamer_presentation
#' @export
pdf_theme <- function(toc = FALSE,
                      incremental = FALSE,
                      fig_width = 9,
                      fig_height = 6,
                      fig_crop = TRUE,
                      fig_caption = TRUE,
                      keep_tex = FALSE,
                      pandoc_args = NULL,
                      highlight = "haddock",
                      latex_engine = "xelatex") {

  template_path <- system.file(
    "rmarkdown", "templates", "slideR_pdf", package = "slideR"
  )
  ## set locations of doc pre/suf fixes
  doc_prefix <- file.path(
    template_path, "resources", "pdf_theme_prefix.tex"
  )
  # doc_prefix <- add_logos_pdf(doc_prefix)

  doc_afterbody <- file.path(
    template_path, "resources", "pdf_theme_afterbody.tex"
  )
  doc_prebody <- file.path(
    template_path, "resources", "pdf_theme_beforebody.tex"
  )
  knitr::knit_hooks$set(mysize = function(before, options, envir) if (before) return(options$size))
  knitr::opts_chunk$set(collapse = TRUE, mysize = TRUE, size = "\\scriptsize")

  ## call the base html_document function
  rmarkdown::beamer_presentation(toc = toc,
                                 incremental = incremental,
                                 theme = "boxes",
                                 colortheme = "structure",
                                 latex_engine = latex_engine,
                                 df_print = "tibble",
                                 fig_crop = fig_crop,
                                 fig_width = fig_width,
                                 fig_height = fig_height,
                                 fig_caption = fig_caption,
                                 highlight = highlight,
                                 keep_tex = keep_tex,
                                 includes = rmarkdown::includes(in_header = doc_prefix,
                                                                before_body = doc_prebody,
                                                                after_body = doc_afterbody
                                                                ),
                                 pandoc_args = pandoc_args)
}

# readline_ <- function(...) {
#   input <- readline(paste(unlist(c(...)), collapse = ""))
#   gsub("^\"|^'|\"$|'$", "", input)
# }
#
# .Renviron <- function() {
#   if (file.exists(".Renviron")) {
#     ".Renviron"
#   } else if (!identical(Sys.getenv("HOME"), "")) {
#     file.path(Sys.getenv("HOME"), ".Renviron")
#   } else {
#     file.path(normalizePath("~"), ".Renviron")
#   }
# }
