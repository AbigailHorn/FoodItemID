
# README: Code for paper

<br>
<br>

## [**See this as a website**](https://abigailhorn.github.io/FoodItemID/)

<br>

# Network-based signal resonance for food-source identification in foodborne disease outbreaks

Abigail L. Horn^1^, Marcel Fuhrmann^2^, Tim Schlaich^3^, Andreas Balster^3^, Elena Polozova^4^, Armin Weiser^2^, Annemarie Kaesboehrer^2^, Matthias Filter^2^, Hanno Friedrich^3^

^1^ Division of Biostatistics, Department of Preventive Medicine, University of Southern California, Los Angeles, CA, USA

^2^ Federal Institute for Risk Assessment (BfR), 10589 Berlin, Germany

^3^ Kuhne Logistics University, 20457 Hamburg, Germany

^4^ Facebook

<br> 

<br>

# Using this code

## R code

`R` was used to compute t-test 95% confidence intervals and create Figures 4-9 in the paper.

### Files 

1. [Baseline characteristic signal resonance](index_BaselineSig_simple_plot.html): results
  - Baseline signals from simulated outbreaks
  - Baseline signals from random sampled outbreaks
2. [Simulated Signal Relative to Random](index_AccPlots_raw.html): results
3. [Normalized Signal Resonance measure](index_SimSigR_convergence.html): accuracy results on simulated outbreaks
  4 metrics of accuracy:
  - Normalized Signal Resonance measure value for true source network
  - Normalized Signal Resonance measure value for highest ranked source network
  - Rank of true source network
  - Binary accuracy, whether true source network is in position 1 or 2
4. [Normalized Signal Resonance measure](index_convergence_singleOB.html): results for single outbreaks

<br>

### Instructions for using R_code

Knit the code in each markdown file `index____.Rmd` to reproduce analysis in each file. If the repository is built from the project file `FoodItemID.Rproj`, the working directory should not need to be set.

<br>

## Matlab code

`Matlab` was used for all signal computations in the paper. 
The data files for each network and outbreak are included in the `workspace.mat` file. 

Before running any codes, add the `function_code` folder and all subfolders to the working directory

There are 3 main wrapper codes that can be used to re-run the analyses in the paper:

* `wrapper_BaselineSig_WHS4.m` 
  - Recreates baseline characteristic signal resonance plots 
* `wrapper_NormSig_WHS4.m`
  - Computes Normalized Signal Resonance measure for a single outbreak. Results in an output matrix of results of dimensions C illness intervals x K iterations 
  - Specify outbreak to run in `single_ob`, choosing from the `all_ob_data` array
* `wrapper_acc_tests_WHS4.m`
  - Computes, simultaneously, Simulated Signal Relative to Random] (see results in `method0_Sig`) and Normalized Signal Resonance measure (see results in `method0_raw`)
  - Specify number of outbreaks m to generate *for each network* in `num_ob` 
  - For outbreak m, specify number of iterations k to compute in `num_samples`
  - Will compute accuracy metrics according and output files into a .csv file for processing within `R`
* The functions used in each wrapper code can be traced back to see the full trajectory of computations from simulating an outbreak, to applying the source localization algorithm, to applying the normalized signal resonance measure, to outputting the results.

<br>

The code to generate a single outbreak, apply source localization algorithm to get pmf, and print the pmf, is in:
* `get_sim_ob_printPMF_WHS.m`

<br>
<br>

## Network models in R

Please see [this GitLab repository](https://gitlab.com/DjMaFu/networkfeatures/-/tree/master) for R code for analyzing the network features of the German food supply networks, including transforming the networks into network files.


