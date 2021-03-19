%% Create Sampled Data
%%%%%%%%%
% % Sampled outbreak data: Get a distribution of samples with the same number of unique nodes as the original set of observations
%%%%%%%%%

function [sampled_outbreaks] = rand_sampled_outbreaks(num_samples, num_uniq, num_ill, stage_ends)

num_stages = length(stage_ends); % for convenience
n_last = stage_ends(end) - stage_ends(end-1);

% Creating population-weighted samples from BOOTSTRAPPED DISTRICTS
sampled_outbreaks = cell(num_samples, 1);

for iter = 1:num_samples
    
    unique_sample = randsample(1:n_last,num_uniq,false);
    As_sampled_ob = randsample(unique_sample, num_ill, true);  % Weighted random sample with replacement
    sampled_ob = As_sampled_ob + (stage_ends(num_stages-1));
    
    sampled_outbreaks(iter,1) = {sampled_ob};
    
end %for

end %function

