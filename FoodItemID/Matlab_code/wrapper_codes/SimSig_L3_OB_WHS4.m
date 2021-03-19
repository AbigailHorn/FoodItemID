%%%%%COMPUTE SIM RLG -- need to use the non-A version

%function [MC_ratio_PUB, SimSig_ratio, MC_ratio_actual] = MC_compute_PracticalUB_RLG(MC_method, food_net, stage_ends, prior_pmf, contam_rets_actual, num_samples, ill_interval)
%function [MC_ratio_PUB, SimSig_new, MC_ratio_actual] = SimSig_L3_OB_WHS4(MC_method, food_net, stage_ends, prior_pmf, contam_rets_actual, num_samples, ill_interval)
function [thisSimSig, SimSig_R_norm, MC_ratio_actual] = SimSig_L3_OB_WHS4(net_i, MC_method, food_net, stage_ends, prior_pmf, contam_rets_actual, num_samples, ill_interval)


%num_stages = length(stage_ends); % for convenience
%n_last = stage_ends(end) - stage_ends(end-1);

%% Inputs
% % Characterize actual outbreak data
%num_ill_total = size(contam_rets_actual,2);   % Number ill in actual outbreak data
num_ill_intervals = size(ill_interval,2);


filename = '/Users/abigailhorn/Dropbox/GitHub/RFoodItemID/output/accuracy/Germany_CI_4Matlab.csv';
netNorms = readmatrix(filename); % net_i; num_ill; mean
netNorms = netNorms(:,2:8);
thisNetNorm = netNorms(find(netNorms(:,1)==net_i),:);
  

%% Initialize output
MC_ratio = zeros(num_ill_intervals, num_samples);

%% Get metrics over time

for ill = 1:num_ill_intervals %1:num_ill
    
    %ill
    % Get netNorms for net_i and num_ill    
    
    % param
    num_ill = ill_interval(ill);
    contam_rets_ill = contam_rets_actual(1,1:num_ill);
    unique_reps = unique(contam_rets_ill,'stable');
    num_uniq = size(unique_reps,2);
    
    % Get SimSig to normalize
    if num_ill > 300
        thisSimSig = thisNetNorm(length(thisNetNorm),3);
    elseif num_ill < 20
        thisSimSig = thisNetNorm(1,3);
    elseif num_ill == 75
        thisSimSig = thisNetNorm(find(thisNetNorm(:,2)==60),3);
    else
        thisSimSig = thisNetNorm(find(thisNetNorm(:,2)==num_ill),3);
    end
    
    %thisSimSig
    
    %[pmf_actual] = source_traceback_log_Oct2019_Germany(food_net, stage_ends, prior_pmf, contam_rets_ill);
    [pmf_actual] = source_traceback_log_Aug2019(food_net, stage_ends, prior_pmf, contam_rets_ill);

    %%% NOTE: food_net_A is the food_net input when normByOB is chosen
    
    %sampled_outbreaks = rand_simulated_outbreak_list(num_samples, num_uniq, num_ill, stage_ends);
    %simulated_outbreak_list = rand_sim_outbreaks(num_samples, num_uniq, num_ill, stage_ends, food_net);
    sampled_outbreak_list = rand_sampled_outbreaks(num_samples, num_uniq, num_ill, stage_ends);


    for it = 1:num_samples
        
        
        % Get model comparison statistics for sampled and simulated outbreak data

        %contam_reports_sim = cell2mat(simulated_outbreak_list(it,1));      
        contam_reports_samp = cell2mat(sampled_outbreak_list(it,1));      

        %[pmf_sim] = source_traceback_log_Aug2019(food_net, stage_ends, prior_pmf, contam_reports_sim);    
        [pmf_samp] = source_traceback_log_Aug2019(food_net, stage_ends, prior_pmf, contam_reports_samp);    

        %%% NOTE: food_net_A is the food_net input when normByOB is chosen
        
                
        %% Model Comparison Metrics for difference and ratios between distributions
        %MC_ratio_PUB(ill,it) = MC_ratio_compute(MC_method, pmf_sim, pmf_samp);
        MC_ratio_actual(ill,it) = MC_ratio_compute(MC_method, pmf_actual, pmf_samp);
        %SimSig_orig(ill,it) = MC_ratio_actual(ill,it)/MC_ratio_PUB(ill,it);%(MC_ratio_actual(ill,it)-MC_ratio_PUB(ill,it))/MC_ratio_PUB(ill,it); %/MC_ratio_actual(ill,it);
        %SimSig_new(ill,it) = MC_ratio_actual(ill,it)/max(MC_ratio_PUB(ill,it), MC_ratio_actual(ill,it));
        
        SimSig_R_norm(ill,it) = MC_ratio_actual(ill,it)/thisSimSig;
        
        %SimSig_ratio(ill,it) = (MC_ratio_actual(ill,it)-MC_ratio_PUB(ill,it))/MC_ratio_PUB(ill,it); %/MC_ratio_actual(ill,it);

  
    end    % end over num_samples
end    % end over ill_interval


if any(isnan(MC_ratio_actual(:)))
    %print_if_meanequalsNAN = 1
    MC_ratio = NaN * ones(num_ill_intervals, num_samples);
end

end % End function