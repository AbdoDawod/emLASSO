emLASSO: Robust GLASSO for Elliptically Symmetric Distributions


emLASSO provides advanced graphical modeling techniques for multivariate non-Gaussian data. By leveraging an EM-type algorithm adapted from the standard GLASSO, this package estimates sparse concentration matrices where the sparsity pattern encodes conditional uncorrelations among variables.

Designed for robustness, emLASSO extends covariance selection beyond the standard Gaussian case, with a strong focus on elliptically symmetric distributions (such as generalized hyperbolic and power exponential distributions).


✨ Key Features

    Non-Gaussian Graphical Modeling: Extend your graphical network analysis to data that deviates from strict normality.

    Elliptical Symmetry Support: Accurately handle distributions where the best prediction is linear, ensuring that zero partial correlations still strictly imply zero conditional correlations.

    EM-Adapted GLASSO: Utilizes a highly efficient Expectation-Maximization framework to accommodate non-Gaussian likelihoods while maintaining edge interpretability.

    Robust Structure Recovery: Proven via simulation and real-data application to effectively recover underlying graphical network structures despite significant normality deviations.

📦 Installation

You can install the development version of emLASSO directly from GitHub using the devtools or remotes package:
```R
# Install devtools if you haven't already
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

# Install emLASSO from GitHub
devtools::install_github("AbdoDawod/emLASSO")
```
🚀 Quick Start / Usage

```R
library(emLASSO)

# Load your multivariate non-Gaussian dataset
data("bodydat")

# Fit the graphical model using the EM-GLASSO approach
# Example: specifying a penalty parameter (lambda) and distribution family

Omega <- SGH_lasso(as.matrix(subset(bodydat, subset = Gender == 1, select = -Gender)),
          lambda = 0.15,
          distribution = "MSGH")

# View the estimated sparse concentration matrix
print(Omega)

# Plot the resulting conditional correlation graph
colnames(Omega) = rownames(Omega) <- names(bodydat)[-25]

group_colors <- c("#48C7E8", "#E3C434","#9DE848","#E34734")
groups <- list(
  General = c(AGE = "Age", HGT = "Height", WGT = "Weight"),
  JointGirths = c(ANG = "AnkleGirth", CAG = "CalfGirth", KNG = "KneeGirth", WRG = "
WristGirth"),
  SkeletalBreadths = c( BAD = "BiacromialD", BID = "BiiliacD", BTD = "BitrocD", CDP
                        = "ChestDepth", CDM = "ChestDiam", ELD = "ElbowD", WRD = "WristD", KND = "KneeD"
                        , AND = "AnkleD"),
  SoftTissueGirths = c( SHG = "ShoulderGirth", CHG = "ChestGirth", WAG = "WaistGirth
", NAG = "NavelGirth", HPG = "HipGirth", THG = "ThighGirth", BCG = "BicepGirth",
                        FOG = "ForearmGirth"))

plot_network( Omega, threshold = 0.15, groups = rep(names(groups), times = sapply(groups, length)), 
              node_names = unlist(groups, use.names = FALSE), 
              group_colors  = rep(group_colors, lengths(groups)))
```
📖 Theoretical Background

In standard Gaussian graphical models, the sparsity of the precision (concentration) matrix dictates conditional independence. However, real-world data often exhibits heavy tails or skewness. emLASSO addresses this by framing the problem within broader families of elliptically symmetric distributions.

Because the best prediction in these families remains linear, zero partial correlations continue to imply zero conditional correlations. The package solves the penalized maximum-likelihood problem using an EM algorithm that iteratively updates the weights and the scatter matrix, thereby allowing the standard GLASSO algorithm to be nested within the M-step.


📝 Citation

If you use emLASSO in your research, please cite the accompanying paper:
Code snippet
```R
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
  publisher = {Springer},
}
```


🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page.


📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
