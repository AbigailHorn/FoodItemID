%% Create Simulated Ob Data
%%%%%%%%%
% % Simulated outbreak data: Get a distribution of samples with the same number of unique nodes as the original set of observations
%%%%%%%%%

function [ob_data] = rand_sim_outbreaks(num_samples, num_uniq, num_ill, stage_ends, food_net)

% For convenience
num_stages = length(stage_ends);
n1 = stage_ends(1);

% Create stochastic A matrix from flows matrix
I_t = eye(stage_ends(num_stages-1));
Q = food_net(1:stage_ends(end-1), 1:stage_ends(end-1));
A = (I_t - Q)\food_net(1:stage_ends(end-1), stage_ends(end-1)+1:stage_ends(end));

food_net_A = A;

% Source to do outbreak from
s_possible = find(sum(food_net_A(1:n1,:),2)>0);  % only start from possible sources
src_list = randsample(s_possible,num_samples,true);

for it = 1:num_samples
    src = src_list(it);
    
    As = food_net_A(src,:); % V from src to absorbing nodes
    As_nonzero_ID = find(As);  % Find the connected retailers to s
    As_nonzero_num = size(As_nonzero_ID,2); % How many retailers connected to s
    
    [As_sort, idx] = sortrows(As.',-1);      % Sorted by top connected notes to src
    As_ranked = [idx, As_sort];
    
    uniq_samp_sim = [];
    As_sim_ob = [];
    As_at_uniq = [];
        
    if As_nonzero_num > num_uniq    % If there are enough connected retailers connected to s to replicate the number of unique values in the actual ob data
        uniq_samp_sim = randsample(As_nonzero_ID, num_uniq, false);  % Randomly sample a set of num_uniq connected retailers
        num_uniq_As = num_uniq;  % We can sample the same number of unique as in actual ob data at this num_ill
    else
        uniq_samp_sim = As_nonzero_ID;   % If there are not enough connected retailers to replicate the number of unique values in the acutal ob data
        num_uniq_As = As_nonzero_num;   % Just set the unique sample to all connected retailers
    end
    
    As_at_uniq = As(uniq_samp_sim);
    
    %if As_nonzero_num == 1
    if size(uniq_samp_sim,2) == 1
        As_sim_ob = repmat(uniq_samp_sim, num_ill);
    else
        As_sim_ob = randsample(uniq_samp_sim, num_ill, true, As_at_uniq);
    end

    %%%%% Putting it in the right format for identification
    sim_ob = [];
    sim_ob = As_sim_ob + (stage_ends(num_stages-1));
    
    %%% For Ess (Tim paper) Calculations
%          ob_data{it,1} = src;
%          ob_data{it,2} = sim_ob;
    
    %%% For MC Calculations
    ob_data{it,1} = sim_ob;
    ob_data{it,2} = src;
    
end %end for



end %function

