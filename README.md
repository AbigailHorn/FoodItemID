
# README: Code for paper

<br>
<br>

## [**See this as a website**](https://abigailhorn.github.io/FoodItemID/)

<br>

**Information-theoretic methods for food supply network identification in foodborne disease outbreaks**

Abigail L. Horn^1,2^, Marcel Fuhrmann^2^, Tim Schlaich^3^, Andreas Balster^3^, Elena Polozova^4^, Armin Weiser^2^, Annemarie Kaesboehrer^2^, Matthias Filter^2^, Hanno Friedrich^3^
  
  <br>
  
^1^ Department of Population and Public Health Sciences, University of Southern California, Los Angeles, CA, USA

^2^ Federal Institute for Risk Assessment (BfR), 10589 Berlin, Germany

^3^ Kuhne Logistics University, 20457 Hamburg, Germany

^4^ MIT

<br> 

<br>

# R code

`R` was used to compute t-test 95% confidence intervals and create Figures 4-9 in the paper.

<br>

## Germany Networks

<br>

1. [Baseline characteristic signal resonance, Germany networks](index_BaselineSig_simple_plot.html): results
  - Baseline signals from simulated outbreaks: $B^{sim}_{N_i,c,k}$
  - Baseline signals from random sampled outbreaks: $B^{rand}_{N_i,c,k}$
2. [Simulated Signal Relative to Random, Germany networks](index_AccPlots_raw.html), $\overline{\psi^{sim}_{N_i}}(c)$: plot and convergence
3. [Normalized Signal Resonance measure, Germany networks](index_convergence_singleOB.html), $\overline{\Psi^{norm}_{N_i}}(c)$: results for single outbreaks
4. [Normalized Signal Resonance measure, Germany networks](index_SimSigR_convergence.html), $\overline{\Psi^{norm}_{N_i}}(c)$: accuracy results on simulated outbreaks

<br>

## Stylized Networks (random layered graphs, RLG)

1. [Simulated Signal Relative to Random, RLG](index_RLG_raw.html), $\overline{\psi^{sim}_{N_i}}(c)$: plot and convergence
2. [Normalized Signal Resonance measure, RLG](index_SimSigR_convergence.html), $\overline{\Psi^{norm}_{N_i}}(c)$: accuracy results on simulated outbreaks

<br>

## Instructions for using R_code

Knit the code in each markdown file `index____.Rmd` to reproduce analysis in each file. If the repository is built from the project file `FoodItemID.Rproj`, the working directory should not need to be set.

<br>

# Matlab code

* `Matlab` was used for all signal computations in the paper. 
* The data files (variables) for each network and outbreak are included in the file `variables/workspace_variables_080521.mat` 
* Before running any codes, add the `functions` folder and all subfolders to the working directory.
* There are 3 categories of functions/scripts: (i) for Germany networks, (ii) for stylized networks (RLG), and (iii) global functions that are used for both.

<br>

## Germany networks

There are 3 main wrapper codes that can be used to re-run the analyses in the paper. The functions used in each wrapper code can be traced back to see the full trajectory of computations from simulating an outbreak, to applying the source localization algorithm, to applying the normalized signal resonance measure, to outputting the results.

*Wrapper codes*

* `wrapper_BaselineSig_WHS4.m` 
  - Recreates baseline characteristic signal resonance plots 
* `wrapper_NormSig_WHS4.m`
  - Computes Normalized Signal Resonance measure $\Psi^{norm}_{N_i,c,k}$ for a single outbreak. Results in an output matrix of $\Psi^{norm}_{N_i,c,k}$ results of dimensions $C$ illness intervals X $K$ iterations 
  - Specify outbreak to run in `single_ob`, choosing from the `all_ob_data` array
* `wrapper_acc_tests_WHS4.m`
  - Computes, simultaneously, Simulated Signal Relative to Random] $\overline{\psi^{sim}_{N_i}}(c)$ (see results in `method0_Sig`) and Normalized Signal Resonance measure $\overline{\Psi^{Norm}_{N_i}}(c)$ (see results in `method0_raw`)
  - Specify number of outbreaks $m$ to generate *for each network* in `num_ob` 
  - For outbreak $m$, specify number of iterations $k$ to compute for each $\Psi^{norm}_{N_i,c,k,m}$ in `num_samples`
  - Will compute accuracy metrics and then output files into a .csv file for processing within `R`
* `get_sim_ob_printPMF_WHS.m`:
  - generates a single outbreak
  - applies the source localization algorithm to get pmf
  - prints the pmf

<br>

## Stylized Networks (RLG)

To analyze the Normalized Signal Resonance measure on stylized networks (RLG), one must first generate a sample set of RLG, and second run the code on these networks.

- To generate a sample set of RLG, use the script `wrapper_generate_RLG.m`

- To generate a single outbreak and plot its pmf use the script `get_sim_ob_RLG.m`:

  - generates a single outbreak
  - applies the source localization algorithm to get pmf
  - prints the pmf

- To recreate simulation accuracy tests on RLG, wse the wrapper script `wrapper_acc_tests_RLG.m` and the following instructions:

  - Specify number of outbreaks $m$ to generate *for each network* in `num_ob` 

  - For outbreak $m$, specify number of iterations $k$ to compute for each $\Psi^{norm}_{N_i,c,k,m}$ in `num_samples`

  - If computing Simulated Signal Relative to Random ($\overline{\psi^{sim}_{N_i}}(c)$) for use in Normalized Signal Resonance measure, set `computing_NormSig=0`. If computing Normalized Signal Resonance measure ($\overline{\Psi^{Norm}_{N_i}}(c)$), set `computing_NormSig=1`.


- Note that to compute the Normalized Signal Resonance measure, you will need to:

  **1.** Compute Simulated Signal Relative to Random in `Matlab` using the code above with `computing_NormSig=0`.
  
  **2.** Read computed Simulated Signal Relative to Random into `R` and compute mean and 95% CI statistics for each network using the code within the `R markdown` file, `index_RLG_raw.Rmd`. Save this as a csv file as e.g. `RLG6_CI_4Matlab.csv`
  
  **3.** Read the file `RLG6_CI_4Matlab.csv` into `Matlab` and use in the function script `SimSig_L3_OB_RLG_norm.m` within lines 14-17. Use the exact same `num_ill_intervals` as used to compute the Simulated Signal Relative to Random.

<br>
<br>

# Network models in R

Please see [this GitLab repository](https://gitlab.com/DjMaFu/networkfeatures/-/tree/master) for R code for analyzing the network features of the German food supply networks, including transforming the networks into network files.


