#' EM Algorithm for Precision Matrix Estimation under Elliptical Distributions
#'
#' Estimates the precision matrix using an Expectation-Maximization (EM) algorithm
#' for data following Multivariate t or other Elliptical distributions
#' (MPE, MSGH, MNIG). It incorporates the Graphical Lasso in the M-step.
#'
#' @param X Numeric matrix. The data matrix of dimension \code{n x d}.
#' @param lambda Numeric scalar. The regularization parameter for the Graphical Lasso. Default is \code{0.01}.
#' @param Kappa Numeric scalar. Parameter for the MPE distribution. Default is \code{1}.
#' @param tol Numeric scalar. Tolerance for convergence of the Frobenius norm of the precision matrix. Default is \code{1e-2}.
#' @param max_iter Integer. Maximum number of EM iterations. Default is \code{1000}.
#' @param nu Numeric scalar. Degrees of freedom for the Student-t distribution. Default is \code{3}.
#' @param psi Numeric scalar. Parameter for the generalized hyperbolic/inverse Gaussian distributions. Must be positive. Default is \code{1}.
#' @param chi Numeric scalar. Parameter for the generalized hyperbolic/inverse Gaussian distributions. Default is \code{1}.
#' @param gh_lambda Numeric scalar. Parameter for the MSGH distribution. Default is \code{1}.
#' @param distribution Character string. The target distribution: \code{'t'}, \code{'MPE'}, \code{'MSGH'}, or \code{'MNIG'}. Default is \code{'MSGH'}.
#' @param appr Logical. Whether to use the approximate formulation in \code{glasso}. Default is \code{FALSE}.
#'
#' @return A numeric matrix representing the estimated precision matrix.
#' @export
#' @importFrom corpcor make.positive.definite
#' @importFrom glasso glasso
#' @importFrom stats cov
SGH_lasso <- function(X, lambda = 0.01, Kappa = 1, tol = 1e-2, max_iter = 1e3, nu = 3, psi = 1, chi = 1, gh_lambda = 1, distribution = 'MSGH', appr = FALSE) {
  n <- nrow(X)
  d <- ncol(X)
  mu <- colMeans(X)
  S <- stats::cov(X)
  S <- corpcor::make.positive.definite(S)
  Theta <- solve(S + diag(1e-2, d))

  for (t in 1:max_iter) {
    # E-step
    Z <- sweep(X, 2, mu)
    qx <- rowSums((Z %*% Theta) * Z)
    u <- sqrt(psi * (chi + qx))

    # Weights
    EW <- if (distribution == 't') {
      (nu + d) / (nu + qx)
    } else if (distribution == 'MPE') {
      Kappa * qx^(Kappa - 1)
    } else if (distribution == 'MSGH') {
      sqrt(psi / (chi + qx)) * (besselK(u, gh_lambda - 1 - d/2) / besselK(u, gh_lambda - d/2))
    } else if (distribution == 'MNIG') {
      E_tau_given_X(psi = psi, chi = chi, d = d, qx = qx)
    }

    # M-step
    mu_new <- colSums(EW * X) / sum(EW)
    Z <- sweep(X, 2, mu_new)
    S <- crossprod(sqrt(EW) * Z) / n
    if (any(!is.finite(S))) {
      warning("S contains Non-finite values. Attempting to recover...")
      S[is.na(S)] <- 0
      diag(S)[diag(S) <= 0] <- 1e-4
    }
    Theta_new <- glasso::glasso(S, rho = lambda, approx = appr)$wi

    # Check convergence
    if (norm(Theta_new - Theta, "F") < tol) break

    mu <- mu_new
    Theta <- Theta_new
  }
  return(Theta)
}

#' Compute E[tau | X = x] for the MGIG Distribution
#'
#' @param psi Numeric scalar. Must be strictly positive.
#' @param chi Numeric scalar.
#' @param d Numeric scalar. The dimension parameter. Must be \code{>= 2}.
#' @param qx Numeric vector or scalar. Evaluated quadratic form values.
#' @return A numeric vector of expected values.
#' @export
E_tau_given_X <- function(psi, chi, d, qx) {
  if (!is.numeric(psi) || length(psi) != 1 || psi <= 0) stop("psi must be a positive numeric scalar.")
  if (!is.numeric(chi) || length(chi) != 1) stop("chi must be a numeric scalar.")
  if (!is.numeric(d) || length(d) != 1) stop("d must be a numeric scalar.")

  inner <- chi + qx
  if (any(inner <= 0)) stop("All values of chi + q(x) must be positive.")

  if (d > 2) {
    arg <- sqrt(psi * inner)
    numerator <- sqrt(psi / inner) * besselK(arg, (d + 3) / 2)
    denominator <- besselK(arg, (d + 1) / 2)
    result <- numerator / denominator
  } else if (d == 2) {
    sqrt_term <- sqrt(psi * inner)
    numerator <- 3 + 3 * sqrt_term + psi * inner
    denominator <- inner * (1 + sqrt_term)
    result <- numerator / denominator
  } else {
    stop("d must be >= 2 for this formulation.")
  }

  return(as.numeric(result))
}

#' Compute Interpolated ROC Curve Results
#'
#' @param result Numeric matrix. The estimated precision matrix.
#' @param true_result Numeric matrix. The ground truth precision matrix.
#' @param tol Numeric scalar. Tolerance threshold for identifying non-zero true edges. Default is \code{1e-3}.
#' @param fpr_seq Numeric vector. Sequence of FPR values at which to interpolate TPR.
#' @return A numeric vector of interpolated TPR values.
#' @export
#' @importFrom pROC roc coords
#' @importFrom stats approx
Roc_result <- function(result, true_result, tol = 1e-3, fpr_seq = seq(0, 1, length.out = 100)) {
  true <- get_offdiag(abs(true_result)) > tol
  scores <- get_offdiag(abs(result))

  roc_obj <- pROC::roc(response = true, predictor = scores, quiet = TRUE)
  coords_all <- pROC::coords(roc_obj, "all", ret = c("specificity", "sensitivity"), transpose = FALSE)

  fpr_raw <- 1 - coords_all[,"specificity"]
  tpr_raw <- coords_all[,"sensitivity"]

  ord <- order(fpr_raw, na.last = NA)
  fpr_ord <- fpr_raw[ord]
  tpr_ord <- tpr_raw[ord]

  tpr_interp <- stats::approx(
    x = fpr_ord,
    y = tpr_ord,
    xout = fpr_seq,
    ties = "ordered",
    yleft = 0, yright = 1
  )$y

  return(tpr_interp)
}

#' Extract Lower Triangular Off-Diagonal Elements
#'
#' @param mat A matrix.
#' @return A vector containing the lower triangular elements.
#' @export
get_offdiag <- function(mat) {
  mat[lower.tri(mat, diag = FALSE)]
}

#' Gamma-Lasso Precision Matrix Estimation
#'
#' Estimates a robust precision matrix using the Gamma-divergence framework.
#'
#' @param X Numeric matrix. The \code{n x p} data matrix.
#' @param lambda Numeric scalar. L1 penalty parameter for sparsity.
#' @param gamma Numeric scalar. Robustness parameter. If \code{0}, it is equivalent to the standard Graphical Lasso.
#' @param max_iter Integer. Maximum number of iterations. Default is \code{100}.
#' @param tol Numeric scalar. Tolerance for convergence. Default is \code{1e-3}.
#' @param appr Logical. Whether to use the approximate formulation in \code{glasso}. Default is \code{FALSE}.
#' @return A list containing the estimated precision matrix (\code{Theta}), the robust covariance matrix (\code{S_robust}), and the robust observation \code{weights}.
#' @export
#' @importFrom glasso glasso
#' @importFrom stats cov
gamma_glasso <- function(X, lambda, gamma, max_iter = 100, tol = 1e-3, appr = FALSE) {
  n <- nrow(X)
  p <- ncol(X)
  mu <- colMeans(X)
  S_curr <- stats::cov(X)

  Theta_curr <- glasso::glasso(S_curr, rho = lambda, approx = TRUE)$wi

  for (iter in 1:max_iter) {
    X_centered <- sweep(X, 2, mu, "-")
    mahal_dist <- rowSums((X_centered %*% Theta_curr) * X_centered)

    weights_unnorm <- exp(pmax(-0.5 * gamma * mahal_dist, -700))
    weights <- weights_unnorm / sum(weights_unnorm) * n

    if (any(is.na(weights)) || sum(weights) <= 1e-8) {
      warning("Weights collapsed to zero or invalid")
      weights <- rep(1, n)
    }

    mu_new <- colSums(weights * X) / sum(weights)
    X_centered_new <- sweep(X, 2, mu_new, "-")
    X_weighted <- sweep(X_centered_new, 1, sqrt(weights), "*")

    S_weighted <- t(X_weighted) %*% X_weighted / (sum(weights) - 1)

    if (any(!is.finite(S_weighted))) stop("Invalid covariance matrix")
    S_weighted <- S_weighted + diag(1e-6, p)

    Theta_new <- glasso::glasso(S_weighted, rho = lambda, approx = appr)$wi

    diff <- sqrt(sum((Theta_new - Theta_curr)^2))
    if (diff < tol) break

    Theta_curr <- Theta_new
    mu <- mu_new
  }

  return(list(Theta = Theta_curr, S_robust = S_weighted, weights = weights))
}

#' ADMM Solver for the Gslope Problem
#'
#' Solves the weighted graphical model problem with a sorted L1 penalty.
#'
#' @param S Numeric matrix. The sample covariance matrix.
#' @param lambda_seq Numeric vector. Sequence of decreasing penalty values.
#' @param rho Numeric scalar. ADMM step size parameter. Default is \code{1.0}.
#' @param max_iter Integer. Maximum number of ADMM iterations. Default is \code{100}.
#' @param tol Numeric scalar. Tolerance for convergence. Default is \code{1e-4}.
#' @return A numeric matrix representing the estimated precision matrix.
#' @export
#' @importFrom SLOPE sortedL1Prox
gslope_admm <- function(S, lambda_seq, rho = 1.0, max_iter = 100, tol = 1e-4) {
  p <- nrow(S)
  Theta <- solve(S + diag(rho, p))
  Z <- Theta
  U <- matrix(0, p, p)

  for (k in 1:max_iter) {
    M <- Z - U - (1/rho) * S
    eig <- eigen(M, symmetric = TRUE)
    D <- eig$values
    V <- eig$vectors

    D_tilde <- (D + sqrt(D^2 + 4/rho)) / 2
    Theta_new <- V %*% diag(D_tilde) %*% t(V)

    A <- Theta_new + U
    z_vec <- A[lower.tri(A)]

    z_prox <- SLOPE::sortedL1Prox(z_vec, lambda_seq / rho)

    Z_new <- matrix(0, p, p)
    Z_new[lower.tri(Z_new)] <- z_prox
    Z_new <- Z_new + t(Z_new)
    diag(Z_new) <- diag(A)

    U <- U + Theta_new - Z_new

    if (norm(Theta_new - Theta, type = "F") < tol) {
      Theta <- Theta_new
      break
    }
    Theta <- Theta_new
  }
  return(Theta)
}

#' Robust TSLOPE Estimator
#'
#' Fits the Graphical SLOPE model using a Student-t EM framework for robust estimation.
#'
#' @param X Numeric matrix. The \code{n x p} data matrix.
#' @param nu Numeric scalar. Degrees of freedom for the Student-t distribution. Default is \code{3}.
#' @param max_iter_em Integer. Maximum number of EM iterations. Default is \code{20}.
#' @param tol_em Numeric scalar. Tolerance for EM convergence. Default is \code{1e-3}.
#' @return A list containing the estimated precision matrix (\code{Theta}) and the observation \code{Weights}.
#' @export
#' @importFrom stats cov qt
tslope <- function(X, nu = 3, max_iter_em = 20, tol_em = 1e-3) {
  n <- nrow(X)
  p <- ncol(X)

  q <- 0.05
  m <- p * (p - 1) / 2
  lambda_seq <- sort(q * stats::qt(1 - (q * (1:m) / (2 * m)), df = n - 2), decreasing = TRUE)

  mu_hat <- colMeans(X)
  X_centered <- scale(X, center = TRUE, scale = FALSE)

  S_sample <- stats::cov(X)
  Theta <- solve(S_sample + diag(0.01, p))

  for (iter in 1:max_iter_em) {
    delta <- rowSums((X_centered %*% Theta) * X_centered)
    weights <- (nu + p) / (nu + delta)

    X_weighted <- sweep(X_centered, 1, sqrt(weights), "*")
    S_weighted <- crossprod(X_weighted) / n

    Theta_new <- gslope_admm(S_weighted, lambda_seq)

    diff <- norm(Theta_new - Theta, type = "F") / norm(Theta, type = "F")
    if (diff < tol_em) break

    Theta <- Theta_new
  }

  return(list(Theta = Theta, Weights = weights))
}
