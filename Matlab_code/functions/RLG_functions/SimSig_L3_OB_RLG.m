
function [MC_ratio_PUB, SimSig_ratio, MC_ratio_actual] = SimSig_L3_OB_RLG(MC_method, food_net, stage_ends, prior_pmf, contam_rets_actual, num_samples, ill_interval)

%num_stages = length(stage_ends); % for convenience
%n_last = stage_ends(end) - stage_ends(end-1);

%% Inputs
% % Characterize actual outbreak data
%num_ill_total = size(contam_rets_actual,2);   % Number ill in actual outbreak data
num_ill_intervals = size(ill_interval,2);

%% Initialize output
MC_ratio = zeros(num_ill_intervals, num_samples);

%% Get metrics over time

for ill = 1:num_ill_intervals %1:num_ill
    
    num_ill = ill_interval(ill);
    contam_rets_ill = contam_rets_actual(1,1:num_ill);
    unique_reps = unique(contam_rets_ill,'stable');
    num_uniq = size(unique_reps,2);
    
    %[pmf_actual] = source_traceback_log_Oct2019_Germany(food_net, stage_ends, prior_pmf, contam_rets_ill);
    [pmf_actual] = source_traceback_log_Aug2019(food_net, stage_ends, prior_pmf, contam_rets_ill);

    %%% NOTE: food_net_A is the food_net input when normByOB is chosen
    
    %sampled_outbreaks = rand_simulated_outbreak_list(num_samples, num_uniq, num_ill, stage_ends);
    simulated_outbreak_list = rand_sim_outbreaks(num_samples, num_uniq, num_ill, stage_ends, food_net);
    sampled_outbreak_list = rand_sampled_outbreaks(num_samples, num_uniq, num_ill, stage_ends);


    for it = 1:num_samples
        
        % Get model comparison statistics for sampled and simulated outbreak data

        contam_reports_sim = cell2mat(simulated_outbreak_list(it,1));      
        contam_reports_samp = cell2mat(sampled_outbreak_list(it,1));      

        [pmf_sim] = source_traceback_log_Aug2019(food_net, stage_ends, prior_pmf, contam_reports_sim);    
        [pmf_samp] = source_traceback_log_Aug2019(food_net, stage_ends, prior_pmf, contam_reports_samp);    

        %%% NOTE: food_net_A is the food_net input when normByOB is chosen
        
                
        %% Model Comparison Metrics for difference and ratios between distributions
        MC_ratio_PUB(ill,it) = MC_ratio_compute(MC_method, pmf_sim, pmf_samp);
        MC_ratio_actual(ill,it) = MC_ratio_compute(MC_method, pmf_actual, pmf_samp);
        
        % Updated to the following 8.4.21
        SimSig_ratio(ill,it) = MC_ratio_actual(ill,it)/MC_ratio_PUB(ill,it);%(MC_ratio_actual(ill,it)-MC_ratio_PUB(ill,it))/MC_ratio_PUB(ill,it); %/MC_ratio_actual(ill,it);
        %SimSig_ratio(ill,it) = MC_ratio_actual(ill,it)/max(MC_ratio_PUB(ill,it),MC_ratio_actual(ill,it));

  
    end    % end over num_samples
end    % end over ill_interval


if any(isnan(MC_ratio_actual(:)))
    %print_if_meanequalsNAN = 1
    MC_ratio = NaN * ones(num_ill_intervals, num_samples);
end

end % End function