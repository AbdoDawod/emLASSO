#' Generate a Symmetric Positive Definite Precision Matrix
#'
#' This function creates a precision matrix (inverse covariance matrix) with a
#' specified sparsity pattern. It ensures the matrix is symmetric and positive
#' definite using row dominance and eigenvalue checks.
#'
#' @param n Integer. The dimension of the precision matrix (number of nodes).
#' @param zero_pattern A logical matrix of dimension \code{n x n}. \code{TRUE}
#'   indicates that the corresponding off-diagonal element should be set to zero
#'   (representing conditional independence).
#'
#' @return A symmetric, positive definite \code{n x n} numeric matrix.
#' @export
#'
#' @examples
#' n <- 5
#' pattern <- matrix(FALSE, n, n)
#' pattern[1, 2] <- pattern[2, 1] <- TRUE
#' prec_mtx <- generate_precision_matrix(n, pattern)
generate_precision_matrix <- function(n, zero_pattern) {
  # Step 1: Initialize the precision matrix
  precision_matrix <- matrix(0, n, n)

  # Step 2: Set specified off-diagonal elements to zero
  for (i in 1:(n - 1)) {
    for (j in (i + 1):n) {
      if (zero_pattern[i, j]==1 & i!=j) {
        # Randomly fill in the non-zero off-diagonal elements
        val <- runif(1, 0.1, 1)
        precision_matrix[i, j] <- precision_matrix[j, i] <- val
      }
    }
  }

  # Step 3: Ensure positive definiteness via diagonal dominance
  for (i in 1:n) {
    precision_matrix[i, i] <- sum(abs(precision_matrix[i, ])) + runif(1, 0.5, 1)
  }

  # Final Check: Ensure all eigenvalues are positive
  epsilon <- 1e-5
  while (min(eigen(precision_matrix)$values) <= 0) {
    precision_matrix <- precision_matrix + epsilon * diag(n)
  }

  return(precision_matrix)
}

#' Compute False Positive Rate (FPR)
#'
#' Calculates the False Positive Rate for an estimated precision matrix
#' compared to the ground truth structure.
#'
#' @param true_precision The ground truth precision matrix.
#' @param estimated_precision The estimated precision matrix.
#'
#' @return A numeric value representing the FPR. Returns \code{0} if there
#'   are no true negatives to evaluate.
#' @export
#'
#' @examples
#' true_mtx <- diag(1, 3)
#' est_mtx <- matrix(c(1, 0.5, 0, 0.5, 1, 0, 0, 0, 1), 3, 3)
#' compute_fpr(true_mtx, est_mtx)
compute_fpr <- function(true_precision, estimated_precision) {
  # Extract binary structures (excluding diagonal if necessary,
  # but here assuming full matrix comparison)
  true_binary <- (true_precision != 0)
  estimated_binary <- (estimated_precision != 0)

  # FP: Estimated as non-zero, but actually zero
  FP <- sum((estimated_binary == 1) & (true_binary == 0))
  # TN: Estimated as zero, and actually zero
  TN <- sum((estimated_binary == 0) & (true_binary == 0))

  # Prevent division by zero
  if ((FP + TN) == 0) return(0)

  FPR <- FP / (FP + TN)
  return(FPR)
}
