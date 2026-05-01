palette_backbone <- c("#DC050C","#FB8072","#1965B0","#7BAFDE","#882E72","#B17BA6","#FF7F00","#FDB462","#E7298A","#E78AC3","#33A02C",
                      "#B2DF8A","#55A1B1","#8DD3C7","#A6761D","#E6AB02","#7570B3","#BEAED4","#666666","#999999","#aa8282","#d4b7b7",
                      "#8600bf","#ba5ce3","#808000","#aeae5c","#1e90ff","#00bfff","#56ff0d","#ffff00")

#### Find unique marker combinations from character vector of marker names ####
#' @importFrom utils combn tail
#' @importFrom grDevices colorRampPalette
.findUniqueMarkerCombinations <- function(marker_names, full_names = TRUE){

  if(full_names){

    # Generate combinations
    unique_combinations <- unlist(
      lapply(seq_along(marker_names), function(n) {
        utils::combn(marker_names, n, function(pos_markers) {
          paste0(marker_names, ifelse(marker_names %in% pos_markers, "+", "-"), collapse = "")
        })
      })
    )

    # Add the all-negative combination
    unique_combinations <- c(
      paste0(marker_names, "-", collapse = ""),
      unique_combinations
    )

  }else{

    unique_combinations <- unlist(
      lapply(seq_along(marker_names), function(n) {
        apply(utils::combn(marker_names, n), 2, paste0, collapse = "+")
        })) %>%
      paste0("+")

    # Add the all-negative combination
    unique_combinations <- c("No markers", unique_combinations)

  }

  return(unique_combinations)
}

#### Get character string of marker names from marker combinations ####
.getMarkerNames <- function(data_markerComb){

  markers <- strsplit(sub("\\+$", "", utils::tail(levels(data_markerComb$MarkerComb),1)), "\\+")[[1]]

  return(markers)
}

#### Get atleast_n columns ####
.getAtLeast_n <- function(data_markerComb){

  markers <- .getMarkerNames(data_markerComb)
  n_markers <- length(markers)

  at_least_vec <- if (n_markers > 1) seq_len(n_markers - 1) else integer(0)

  msg <- paste0(
    "Adding logical columns for at least ",
    paste(at_least_vec, collapse = ", "),
    " and ",
    n_markers,
    " markers and Polyfunctional, at least ",
    paste(markers, collapse = ", "),
    "..."
  )
  message(msg)

  # loop through combination sizes (2 to n_markers)
  for (k in seq_len(n_markers)) {
    combs <- utils::combn(markers, k, simplify = FALSE)
    for (cmb in combs) {
      new_col <- paste0("atleast_",k,"_", paste0(cmb, "+", collapse = ""), "")
      # rowSums across the selected markers == length(cmb) means all are TRUE
      data_markerComb[[new_col]] <- rowSums(data_markerComb[cmb]) == length(cmb)
    }
  }

  return(data_markerComb)
}

#### Get Polyfunct_atleast_marker columns ####
.getPolyfunctionalAtLeast_marker <- function(data_markerComb){

  markers <- .getMarkerNames(data_markerComb)

  # loop through markers
  for(marker in markers){
    new_col <- paste0("Polyfunctional_atleast_",marker,"+")
    data_markerComb[[new_col]] <- (data_markerComb$Functionality == "Polyfunctional" & data_markerComb[[marker]])
  }

  return(data_markerComb)
}

#### Get named character vector / palette for plotting ####
.getNamedPaletteMarkerComb <- function(marker_names, full_names = TRUE){

  levels_comb <- .findUniqueMarkerCombinations(marker_names, full_names = full_names)
  n_colors <- length(levels_comb)-1
  palette_comb <- palette_backbone[seq_len(n_colors)]

  # expand with colorRampPalette
  if(any(is.na(palette_comb))){
    palette_comb <- palette_comb[!is.na(palette_comb)]
    palette_comb <- grDevices::colorRampPalette(palette_comb)(n_colors)
  }

  palette_comb <- c("grey60",palette_comb) # add grey for all negative
  names(palette_comb) <- levels_comb # add names

  return(palette_comb)

}

#### Get strings of groupings for warning message ####
.getStringMessages <- function(df, md_cols, pop_col = NULL){

  if(is.null(pop_col)){
    string_messages <- df %>%
      dplyr::group_by()
  }else{
    string_messages <- df %>%
    dplyr::group_by(!!!rlang::syms(md_cols))%>%
    dplyr::mutate(!!rlang::sym(pop_col) := paste(unique(!!rlang::sym(pop_col)),collapse = ","),
                  n_unique_pop = length(unique(!!rlang::sym(pop_col))))%>%
    unique()%>%
    dplyr::ungroup()%>%
    dplyr::mutate(row = dplyr::row_number()) %>%
    tidyr::pivot_longer(-c(.data$row,.data$n_unique_pop),
                        names_to = "col",
                        values_to = "val") %>%
    dplyr::mutate(pair = paste(.data$col, "==",.data$val)) %>%
    dplyr::group_by(.data$row,.data$n_unique_pop) %>%
    dplyr::summarise(row_string = paste(.data$pair, collapse = ", "))%>%
    dplyr::pull(.data$row_string)
  }

  return(string_messages)

}

#### Subset data for plotting ####
.subsetDataCellTypes <- function(df, cell_subset_params = NULL){

  # Ensure expected list structure
  if (is.null(cell_subset_params)) {
    cell_subset_params <- list(cellTypes = NULL, cellTypes_plot = NULL)
  }

  # Extract components
  cell_labels <- cell_subset_params[["cellTypes"]]
  plot_subsets <- cell_subset_params[["cellTypes_plot"]]

  # If no subsetting requested, return original df
  if (is.null(cell_labels) || is.null(plot_subsets)) {
    return(list(
      dataframe = df,
      plot_caption = ""
    ))
  }

  # Construct caption text
  n_plot_subsets <- length(plot_subsets)

  subsets_title_string <- if (n_plot_subsets == 1) {
    paste0("cell type ", plot_subsets)
  } else {
    idx <- if (n_plot_subsets > 1) seq_len(n_plot_subsets - 1) else integer(0)

    paste0(
      "cell types ",
      paste(plot_subsets[idx], collapse = ", "),
      " and ",
      plot_subsets[n_plot_subsets]
    )
  }

  # Filter and annotate data
  df_subset <- df %>%
    dplyr::mutate(cell_label = cell_labels) %>%
    dplyr::filter(.data$cell_label %in% plot_subsets) %>%
    dplyr::select(-"cell_label")

  # Compose output
  return(list(
    dataframe = df_subset,
    plot_caption = paste0("Plotted subset of data: ", subsets_title_string)
  ))

}

#### Highlight positive markers in combinations ####
.markerCombtoMarkdown <- function(comb) {
  comb %>%
    # black for +
    stringr::str_replace_all("([A-Za-z0-9]+)\\+", "<span style='color:black'>\\1+</span>") %>%
    # grey for -
    stringr::str_replace_all("([A-Za-z0-9]+)\\-", "<span style='color:grey70'>\\1-</span>")
}
