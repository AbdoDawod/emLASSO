#' Human Body Dimensions Dataset
#'
#' A dataset containing anthropometric measurements collected from adult
#' individuals. The data include 25 variables consisting of body dimensions,
#' body weight, height, age, and sex. The anthropometric measurements comprise
#' various breadths, depths, circumferences, and limb girths that are commonly
#' used in studies of human body composition, ergonomics, and multivariate
#' statistical analysis.
#'
#' The dataset was originally published as a teaching resource for multivariate
#' statistics and has been widely used for demonstrating techniques such as
#' principal component analysis, discriminant analysis, clustering, and
#' classification.
#'
#' @format A data frame with 507 observations and 25 variables:
#' \describe{
#'   \item{biacromial}{Biacromial diameter (cm).}
#'   \item{pelvic}{Biiliac (pelvic) diameter (cm).}
#'   \item{bitrochanteric}{Bitrochanteric diameter (cm).}
#'   \item{chest_depth}{Chest depth (cm).}
#'   \item{chest_diameter}{Chest diameter (cm).}
#'   \item{elbow_diameter}{Elbow diameter (cm).}
#'   \item{wrist_diameter}{Wrist diameter (cm).}
#'   \item{knee_diameter}{Knee diameter (cm).}
#'   \item{ankle_diameter}{Ankle diameter (cm).}
#'   \item{shoulder_girth}{Shoulder girth (cm).}
#'   \item{chest_girth}{Chest girth (cm).}
#'   \item{waist_girth}{Waist girth (cm).}
#'   \item{navel_girth}{Navel girth (cm).}
#'   \item{hip_girth}{Hip girth (cm).}
#'   \item{thigh_girth}{Thigh girth (cm).}
#'   \item{biceps_girth}{Biceps girth (cm).}
#'   \item{forearm_girth}{Forearm girth (cm).}
#'   \item{knee_girth}{Knee girth (cm).}
#'   \item{calf_girth}{Calf girth (cm).}
#'   \item{ankle_girth}{Ankle girth (cm).}
#'   \item{wrist_girth}{Wrist girth (cm).}
#'   \item{age}{Age (years).}
#'   \item{weight}{Body weight (kg).}
#'   \item{height}{Height (cm).}
#'   \item{sex}{Biological sex (1 = male, 0 = female).}
#' }
#'
#' @details
#' The data were compiled for educational purposes and consist of standard
#' anthropometric measurements obtained from adults. All body dimensions are
#' recorded in centimeters except body weight, which is measured in kilograms,
#' and age, which is measured in years. The final variable indicates the
#' participant's sex (1 = male, 0 = female).
#'
#' @source
#' Heinz, G. (2003). *Exploring Relationships in Body Dimensions*. Journal of
#' Statistics Education, 11(2).
#' https://doi.org/10.1080/10691898.2003.11910711
#'
"bodydat"



#' PTSD Symptom Network Dataset
#'
#' A dataset containing post-traumatic stress disorder (PTSD) symptom responses
#' collected from trauma-exposed individuals. The data consist of ordinal
#' responses to PTSD symptom items and are commonly used for estimating and
#' evaluating Gaussian graphical models, Bayesian network models, and
#' psychometric network structures.
#'
#' The dataset is included in the BGGM package as an example for Bayesian
#' Gaussian Graphical Models and has been widely used to illustrate network
#' estimation, uncertainty quantification, and posterior inference for
#' psychological data.
#'
#' @format A data frame with 344 observations and 20 variables:
#' \describe{
#'   \item{V1--V20}{Ordinal PTSD symptom items measured on a Likert-type scale.}
#' }
#'
#' @details
#' Each variable represents the severity or frequency of a PTSD symptom as
#' assessed using a standardized PTSD questionnaire. Responses are ordinal,
#' making the dataset suitable for methods based on rank likelihoods, copula
#' models, or latent Gaussian graphical models. The dataset is frequently used
#' as a benchmark for Bayesian network estimation and psychometric analyses.
#'
#' @source
#' Williams, D. R. (2021). *Bayesian Estimation for Gaussian Graphical Models:
#' Structure Learning, Predictability, and Network Comparisons*. Journal of
#' Statistical Software, 105(9), 1--33.
#'
#' Originally distributed with the BGGM R package.
#'
"ptsd"
