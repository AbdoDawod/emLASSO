#' Plot a Network Graph from a Precision Matrix
#'
#' @description
#' Generates a customizable network plot from a precision matrix using the \code{qgraph} package.
#' The input matrix is scaled to a correlation matrix, symmetrized to handle floating-point
#' inaccuracies, and thresholded before plotting.
#'
#' @param omega A numeric, square matrix representing the precision matrix.
#' @param groups A list or vector indicating group membership of nodes. Default is \code{NULL}.
#' @param group_colors A character vector of colors corresponding to the groups. Default is \code{NULL}.
#' @param threshold A numeric value between 0 and 1. Edges with absolute weights strictly below
#'   this threshold are set to 0. Default is 0.15.
#' @param legend Logical. Should a legend be included in the plot? Default is \code{TRUE}.
#' @param node_names A character vector of node names. Default is \code{NULL}.
#' @param fade Logical. Should edge colors fade based on edge weight? Default is \code{TRUE}.
#'
#' @return A \code{qgraph} object representing the network plot, returned invisibly.
#'
#' @export
#' @importFrom stats cov2cor
#' @importFrom qgraph qgraph
plot_network <- function(omega,
                         groups = NULL,
                         group_colors = NULL,
                         threshold = 0.15,
                         legend = TRUE,
                         node_names = NULL,
                         fade = TRUE) {

  # 1. Input Validation
  if (!is.matrix(omega) || !is.numeric(omega) || nrow(omega) != ncol(omega)) {
    stop("`omega` must be a numeric, square matrix.")
  }
  if (!is.numeric(threshold) || threshold < 0 || threshold > 1) {
    stop("`threshold` must be a single numeric value between 0 and 1.")
  }

  # 2. Matrix Transformations
  # Scale the precision matrix (handles diagonal)
  omega <- stats::cov2cor(omega)

  # Ensure symmetry (corrects minor floating-point inaccuracies)
  omega <- (omega + t(omega)) / 2

  # Threshold small edges
  omega[abs(omega) < threshold] <- 0

  # 3. Base arguments for qgraph
  args <- list(
    input = omega,
    layout = "spring",
    graph = "cor",
    groups = groups,
    nodeNames = node_names,
    color = group_colors,
    vsize = 7,
    label.cex = 1,
    edge.label.cex = 0.9,
    posCol = "#2166AC",
    negCol = "#B2182B",
    edge.width = 2,
    minimum = 0.01,
    fade = fade,
    curve = 1,
    curveAll = TRUE,
    borders = TRUE,
    mar = c(1.5, 1.5, 1.5, 1.5)
  )

  # 4. Handle Legend
  if (legend) {
    args$legend <- TRUE
    args$legend.cex <- 0.25
    args$legend.mode <- "style1"
  } else {
    args$legend <- FALSE
  }

  # 5. Plot and Return
  # Using invisible() prevents the massive qgraph list from printing to the console
  # if the user doesn't assign the output to a variable.
  invisible(do.call(qgraph::qgraph, args))
}
