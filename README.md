# Automatic-Threshold-Sparse-Bayesian-algorithm
An improved algorithm for Threshold Sparse Bayesian algorithm can automatically adjust the best Threshold value.(YUAN YAO spotted it.)
Shen(Zhang et al., 2018) comes up with a threshold sparse Bayesian training method to increase the robustness of the model. 
The disturbances candidates, which correspond to smaller weights, will be removed through a manually set threshold,
and then the model will re-estimate the weights iteratively until convergence. 
We developed an Automatic Threshold Sparse Bayesian algorithm to automatically screen out best approximation from candidates.
We applied this algorithm to the modeling of terrestrial ecosystem, and found the best GPP model through this algorithm.
