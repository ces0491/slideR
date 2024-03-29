#' HTML slideshow presentation
#'
#' Renders rmarkdown as an HTML slideshow.
#'
#' @param incremental Logical indicating whether to render bullet points incrementally. Defaults to FALSE. To reverse-order, precede item with `>`
#' @param fig_width Default figure width, in inches.
#' @param fig_height Default figure height, in inches.
#' @param fig_caption Logical indicating whether to render figure captions.
#' @param self_contained Logical indicating whether to package presentation as single html file.
#' @param highlight Highlight style, if "default" then "haddock" is used.
#' @param css Optional, additional css file(s) to include
#' @param includes Optional, additional content to include.
#' @param keep_md Logical indicating whether to keep .md version of file.
#' @param lib_dir If not self contained, name for directory containing presentation files. If NULL (default) then "_files" is added to document name.
#' @param pandoc_args Optional, additional args to pass on to pandoc.
#'
#' @export
html_theme <- function(incremental = FALSE,
                       fig_width = 7.50,
                       fig_height = 4.75,
                       fig_caption = FALSE,
                       self_contained = FALSE,
                       highlight = "default",
                       css = NULL,
                       includes = NULL,
                       keep_md = FALSE,
                       lib_dir = NULL,
                       pandoc_args = NULL) {

  katex = TRUE
  fig_retina = 2
  template = "default"
  smart = TRUE
  theme = "ribbon"
  ratio = "16x10"

  css <- add_logos_html(css)

  theme_url <-   system.file(
    "rmarkdown/templates/slideR_html/resources", package = "fractalSlides")

  ## put common pandoc options here
  args <- c()

  if (identical(template, "default")) {
    default_template <- system.file(
      "rmarkdown/templates/fvaslides_html/resources/default.html",
      package = "uslides"
    )
    args <- c(args, "--template",
              rmarkdown::pandoc_path_arg(default_template))

  } else if (!is.null(template)) {
    args <- c(args, "--template",
              rmarkdown::pandoc_path_arg(template))
  }

  if (incremental)
    args <- c(args, "--incremental")

  # slide level
  args <- c(args, "--slide-level", "2")

  # aspect ratio
  args <- c(args, paste0("--variable=ratio:", ratio))

  # KaTeX?
  args <- c(args, if (katex) paste0("--variable=katex:yes"))

  # content includes
  args <- c(args, rmarkdown::includes_to_pandoc_args(includes))

  # additional css
  for (css_file in css) {
    args <- c(args, "--css", rmarkdown::pandoc_path_arg(css_file))
  }

  pre_processor <- function(metadata, input_file, runtime, knit_meta, files_dir,
                            output_dir) {

    ## we don't work with runtime shiny
    if (identical(runtime, "shiny")) {
      stop("shower is not compatible with runtime 'shiny'",
           call. = FALSE)
    }

    ## use files_dir as lib_dir if not explicitly specified
    if (is.null(lib_dir)) lib_dir <- files_dir

    ## extra args
    args <- c()

    shower_path <- system.file("rmarkdown/templates/slideR_html/resources", package = "fractalSlides")
    if (!self_contained || identical(.Platform$OS.type, "windows")) {
      shower_path <- rmarkdown::relative_to(
        output_dir, rmarkdown::render_supporting_files(shower_path, lib_dir)
      )
    }
    args <- c(
      args,
      paste0("--variable=shower-url:",
             rmarkdown::pandoc_path_arg(shower_path))
    )

    ## theme
    args <- c(args, paste0("--variable=theme:", theme))
    if (!self_contained || identical(.Platform$OS.type, "windows")) {
      theme_url <- rmarkdown::relative_to(
        output_dir, rmarkdown::render_supporting_files(theme_url, lib_dir)
      )
    }
    args <- c(args, paste0("--variable=shower-theme-url:", theme_url))

    ## highlight
    args <- c(args,
              rmarkdown::pandoc_highlight_args(
                highlight, default = "haddock"))

    ## return additional args
    args
  }

  post_processor <- function(metadata, input_file, output_file, clean,
                             verbose) {

    ## Get lines from output file
    con <- file(output_file)
    lines <- readLines(con)
    close(con)

    ## Change <li class="fragment"> elements, add a "next" class.
    ## Shower needs this for incremental lists
    lines <- sub(
      "<li class=\"fragment\"",
      "<li class=\"fragment next\"",
      lines,
      fixed = TRUE
    )

    ## Everything should be H2 for shower
    lines <- sub(
      "^<h1>(.*)</h1>$",
      "<h2>\\1</h2>",
      lines,
      perl = TRUE
    )

    ## Title slides are H2, too, but have a special class
    lines <- sub(
      "(class=\"titleslide slide level1\">)<h1>(.*)</h1>",
      "\\1<h2 class=\"shout\">\\2</h2>",
      lines,
      perl = TRUE
    )

    ## No embedded sections, please
    lines <- sub("^<section><section", "<section", lines)
    lines <- sub("^</section></section>", "</section>", lines)

    ## Write it out
    con <- file(output_file)
    writeLines(lines, con)
    close(con)

    output_file
  }

  knitr::opts_chunk$set(collapse = TRUE)

  rmarkdown::output_format(
    knitr = rmarkdown::knitr_options_html(
      fig_width, fig_height, fig_retina, keep_md),
    pandoc = rmarkdown::pandoc_options(
      to = "revealjs",
      from = rmarkdown::rmarkdown_format(
        if (fig_caption) "" else "-implicit_figures"),
      args = args
    ),
    keep_md = keep_md,
    clean_supporting = self_contained,
    pre_processor = pre_processor,
    post_processor = post_processor,
    base_format = rmarkdown::html_document_base(
      smart = smart,
      lib_dir = lib_dir,
      self_contained = self_contained,
      mathjax = if (katex) "default" else NULL,
      pandoc_args = pandoc_args
    )
  )

}
