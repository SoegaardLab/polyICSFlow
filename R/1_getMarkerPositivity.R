#' Create dataframe of marker positivity
#'
#' Create a dataframe describing whether each cell is included by the gates where each row is a cell and each column is a marker.
#'
#' @param x An object of class \code{GatingHierarchy} or \code{GatingSet} with an applied \code{gatingTemplate}.
#' @param gate_names The names of the cytokine gates. If  \code{NULL} (default), all leaf nodes will be used.
#'
#' @returns A data.frame where each row is a cell and each column is a gated marker which can be used as input for
#' the \code{\link{assignMarkerCombinations}} function.
#'
#' @seealso \code{\link[flowWorkspace]{GatingSet}}, \code{\link[openCyto]{gatingTemplate}},
#' \code{\link[openCyto]{gt_gating}}, \code{\link{assignMarkerCombinations}},
#' \code{\link{calcPolyfunctionality}}
#'
#' @references This code is strongly based on the \code{\link[FlowSOM]{GetFlowJoLabels}} function.
#' @importFrom openCyto gatingTemplate gt_gating
#' @importFrom CytoExploreR cyto_gate_draw
#' @examples
#' # Define path to data
#' path_data <- system.file("extdata", package = "polyICSFlow")
#'
#' # Read fcs files as flowSet
#' fs <- flowCore::read.flowSet(path = path_data,
#'                              pattern = ".fcs",
#'                              truncate_max_range = FALSE,
#'                              transformation = FALSE)
#'
#' # Create GatingSet
#' gs <- flowWorkspace::GatingSet(fs)
#'
#' # Apply GatingTemplate
#' gt <- openCyto::gatingTemplate(file.path(path_data, "gatingTemp_cytokines.csv"))
#' openCyto::gt_gating(x = gt, y = gs)
#'
#' # Get marker positivity per cell
#' df_markerPos <- getMarkerPositivity(x = gs,
#'                                     gate_names = c("IFN+","TNFa+","IL2+","CD107a+"))
#' @export
getMarkerPositivity <- function(x, gate_names = NULL){

  if(is.null(gate_names)){
    gate_names <- vapply(stringr::str_split(flowWorkspace::gs_get_leaf_nodes(x[[1]]),"/"),tail,1)
    message("No gate names provided, defaulting to leaf nodes:")
    for(gate in gate_names){
      message(gate)
    }
  }

  files <- gsub("_[0-9]*$", "", flowWorkspace::sampleNames(x))
  result <- list()
  for(file in files){
    gatingMatrix <- matrix(NA,
                           nrow = dim(flowWorkspace::gh_pop_get_data(x[[grep(file,flowWorkspace::pData(x)$name)]]))[[1]],
                           ncol = length(gate_names),
                           dimnames = list(NULL,
                                           gate_names))

    for(gate in gate_names){
      gatingMatrix[, gate] <- flowWorkspace::gh_pop_get_indices(x[[file]], gate)
    }

    result[[file]] <- gatingMatrix

  }

  # get boolean matrix
  combined_matrix <- do.call(rbind,result)
  final_matrix <- data.frame(combined_matrix)
  names(final_matrix) <- sub("\\+.*$", "", colnames(combined_matrix)) #remove any suffices

  return(final_matrix)

}

