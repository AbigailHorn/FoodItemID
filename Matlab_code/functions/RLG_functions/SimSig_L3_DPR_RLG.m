function [MC_ratio_PUB, SimSig_ratio, MC_ratio_actual] = SimSig_L3_DPR_RLG(MC_method, food_net, stage_ends, prior_pmf, contam_rets_actual, num_samples, ill_interval)

%num_stages = length(stage_ends); % for convenience
%n_last = stage_ends(end) - stage_ends(end-1);

%% Inputs
% % Characterize actual outbreak data
%num_ill_total = size(contam_rets_actual,2);   % Number ill in actual outbreak data
num_ill_intervals = size(ill_interval,2);

%% Initialize output
MC_ratio = zeros(num_ill_intervals, num_samples);

%% Create Randomized Networks
%Generate a random network that has same structure as "true network"
[rand_networks] = DPR_networks(food_net, stage_ends, num_samples);

if prior_pmf~=0
    [rand_prior_pmfs] = DPR_prior_pmf(num_samples, food_net, stage_ends);
end

for it = 1:num_samples
    
    % Assign randomized network and prior_pmf (if prior is defined) to iteration
    food_net_dpr = cell2mat(rand_networks(it,1));
    if prior_pmf~=0
        dpr_prior_pmf = cell2mat(rand_prior_pmfs(it,1));
    else
        dpr_prior_pmf = 0;
    end
    
    for ill = 1:num_ill_intervals %1:num_ill
        
        num_ill = ill_interval(ill);
        contam_rets_ill = contam_rets_actual(1,1:num_ill);
        unique_reps = unique(contam_rets_ill,'stable');
        num_uniq = size(unique_reps,2);
        
        simulated_outbreak = rand_sim_outbreaks(1, num_uniq, num_ill, stage_ends, food_net);
        contam_reports_sim = cell2mat(simulated_outbreak(1,1));

        
      
        
        [pmf_actual] = source_traceback_log_Aug2019(food_net, stage_ends, prior_pmf, contam_rets_ill);
        % pmf_dpr = pmf_samp (actual)
        [pmf_dpr] = source_traceback_log_Aug2019(food_net_dpr, stage_ends, dpr_prior_pmf, contam_rets_ill);

        [pmf_sim] = source_traceback_log_Aug2019(food_net, stage_ends, prior_pmf, contam_reports_sim);
        % pmf_dpr_sim = pmf_samp (dpr)
        [pmf_dpr_sim] = source_traceback_log_Aug2019(food_net_dpr, stage_ends, dpr_prior_pmf, contam_reports_sim);
        
        %% Model Comparison Metrics for difference and ratios between distribution
        MC_ratio_PUB(ill,it) = MC_ratio_compute(MC_method, pmf_sim, pmf_dpr_sim);
        MC_ratio_actual(ill,it) = MC_ratio_compute(MC_method, pmf_actual, pmf_dpr);
        SimSig_ratio(ill,it) = MC_ratio_actual(ill,it)/MC_ratio_PUB(ill,it); %/MC_ratio_actual(ill,it);
        %SimSig_ratio(ill,it) = (MC_ratio_actual(ill,it)-MC_ratio_PUB(ill,it))/MC_ratio_PUB(ill,it); %/MC_ratio_actual(ill,it);


    end    % end over ill_interval

end    % end over num_samples


if any(isnan(MC_ratio(:)))
    %print_if_meanequalsNAN = 1
    MC_ratio = NaN * ones(num_ill_intervals, num_samples);
end

end % End function