emLASSO: Robust GLASSO for Elliptically Symmetric Distributions


emLASSO provides advanced graphical modeling techniques for multivariate non-Gaussian data. By leveraging an EM-type algorithm adapted from the Gaussian Graphical LASSO (GLASSO), this package estimates sparse concentration matrices where the sparsity pattern encodes conditional uncorrelations among variables.

Designed for robustness, emLASSO extends covariance selection beyond the standard Gaussian case, with a strong focus on elliptically symmetric distributions (such as generalized hyperbolic and power exponential distributions).
✨ Key Features

    Non-Gaussian Graphical Modeling: Extend your graphical network analysis to data that deviates from strict normality.

    Elliptical Symmetry Support: Accurately handle distributions where the best prediction is linear, ensuring that zero partial correlations still strictly imply zero conditional correlations.

    EM-Adapted GLASSO: Utilizes a highly efficient Expectation-Maximization framework to accommodate non-Gaussian likelihoods while maintaining edge interpretability.

    Robust Structure Recovery: Proven via simulation and real-data application to effectively recover underlying graphical network structures despite significant normality deviations.

📦 Installation

You can install the development version of emLASSO directly from GitHub using the devtools or remotes package:
R

# Install devtools if you haven't already
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

# Install emLASSO from GitHub
devtools::install_github("AbdoDawod/emLASSO")

🚀 Quick Start / Usage

R

library(emLASSO)

# Load your multivariate non-Gaussian dataset
data("your_dataset")

# Fit the graphical model using the EM-GLASSO approach
# Example: specifying a penalty parameter (lambda) and distribution family
fit <- emlasso(
  x = your_dataset, 
  lambda = 0.25, 
  family = "generalized_hyperbolic" 
)

# View the estimated sparse concentration matrix
print(fit$concentration_matrix)

# Plot the resulting conditional independence graph
plot(fit)

📖 Theoretical Background

In standard Gaussian graphical models, the sparsity of the precision (concentration) matrix dictates conditional independence. However, real-world data often exhibits heavy tails or skewness. emLASSO addresses this by framing the problem within broader families of elliptically symmetric distributions.

Because the best prediction in these families remains linear, zero partial correlations continue to imply zero conditional correlations. The package solves the penalized maximum-likelihood problem using an EM algorithm that iteratively updates the weights and the scatter matrix, thereby allowing the standard GLASSO algorithm to be nested within the M-step.
📝 Citation

If you use emLASSO in your research, please cite the accompanying paper:
Code snippet

@article{Terdik2026,
  author    = {Gy{\"o}rgy Terdik and Abdaljbbar B. A. Dawod},
  title     = {Extending GLASSO to non-Gaussian settings: Sparse concentration estimation via EM algorithm},
  journal   = {Computational Statistics},
  year      = {2026},
  volume    = {41},
  number    = {5},
  pages     = {90},
  doi       = {10.1007/s00180-026-01764-0},
  url       = {https://doi.org/10.1007/s00180-026-01764-0},
  issn      = {1613-9658},
  abstract  = {This paper develops graphical modeling techniques for multivariate non-Gaussian data, in which the sparsity pattern of the concentration matrix encodes conditional uncorrelations among variables. This structure enables efficient covariance selection, yielding concentration graph models that extend beyond the Gaussian case. Within elliptically symmetric distributions and indeed in an even broader family, distributions for which the best prediction is linear, zero partial correlations imply zero conditional correlations. That preserves the interpretability of edges in the graphical model. Focusing on elliptically symmetric families such as the generalized hyperbolic and power exponential distributions, we propose a modified graphical LASSO (GLASSO) framework for estimating sparse concentration matrices. The method is implemented using an EM-type algorithm adapted from Gaussian GLASSO to accommodate non-Gaussian likelihoods. Simulation studies and real-data applications demonstrate the effectiveness and robustness of the proposed estimators in recovering underlying graphical structures despite deviations from normality.},
  publisher = {Springer},
}

🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page.
📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
