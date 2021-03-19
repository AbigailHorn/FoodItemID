%% CALCULATE SIGNAL DETECTION METRICS OVER MULTIPLE OUTBREAK SIMULATIONS


%% PARAMETERS TO CHOOSE
num_ob = 2;
num_samples=2;
dpr_flag = 0;


%% Input data

stage_ends = [100 200 300 400];

% Food networks and prior pmfs
num_food_nets = 5;
all_food_nets = cell(num_food_nets,1);
all_food_nets{1} = trueNet;
all_food_nets{2} = rand2;
all_food_nets{3} = rand3;
all_food_nets{4} = rand4;
all_food_nets{5} = rand5;

prior_pmf = (1/num_feasible)*ones(1,num_feasible);

num_net_names = num_food_nets;
all_net_names = cell(num_food_nets,1);
all_net_names{1} = 'trueNet';
all_net_names{2} = 'rand2';
all_net_names{3} = 'rand3';
all_net_names{4} = 'rand4';
all_net_names{5} = 'rand5';


%% GENERATE OUTBREAKS

ob_data = [];

% Choose number of illnesses and number of contaminated nodes
num_uniq = 25; %num_uniq_vec(uniq_it);
num_ill = 500;

% Generate outbreaks: num_ob of outbreaks for each network
%[ob_data] = rand_sim_outbreaks(num_samples, num_uniq, num_ill, stage_ends, trueNet);

for N = 1:num_food_nets
    ob_data_N = rand_sim_outbreaks(num_ob, num_uniq, num_ill, stage_ends, all_food_nets{N});
    ob_data_N = [ob_data_N num2cell(repmat(N,num_ob,1))];    % to note the food network source 
    ob_data = [ob_data; ob_data_N];     % to create a cell listing all outbreaks
end

% Choose which slice(s) in time to do source identification
ill_over_time_interval = [2 5 10 20 30 40 50 100 150 200 250 300 350 400 450 500];
ill_it = size(ill_over_time_interval,2);

num_ob_total = num_food_nets*num_ob;

%% SIGNAL DETECTION + METRICS FOR EACH OUTBREAK

INTxOB = [];

INTxOB_test = zeros(ill_it,num_ob_total);

for ob_i = 1:num_ob_total
    
    ob_i
    
    current_ob_data = ob_data{ob_i,1};
    current_ob_src_net = ob_data{ob_i,3};
    current_ob_src_node = ob_data{ob_i,2};

    %%% Get net_MC_means: ILL INTERVAL x NUM_NETS (averaged across num_samples for each network)
    [net_MC_means_0, net_raw_means_0] = plot_compute_signal_OB_SIM_METRICS(all_food_nets, 0, stage_ends, current_ob_data, ill_over_time_interval, MC_method, num_samples, 0);
%    [net_MC_means_1, net_raw_means_1] = plot_compute_signal_OB_SIM_METRICS(all_food_nets, 0, stage_ends, current_ob_data, ill_over_time_interval, MC_method, num_samples, 1);

    %%% Get metrics for this outbreak and put into a matrix of ILL INTERVAL x NUM_OB
        
    [~, I_max] = max(net_MC_means, [], 2);
    
    for ill = 1:ill_it
        if I_max(ill) == current_ob_src_net
            INTxOB(ill,ob_i) = 1;
        else
            INTxOB(ill,ob_i) = 0;
        end
    end
    
    INTxOB_test(ill,ob_i) = max_MC_SimTest(net_MC_means, ill_it, current_ob_src_net, ob_i);
    
    
end %ob_i

%% MEAN AND 95%CI OVER ALL OUTBREAKS

%mean_ACC = mean(MEANxOB,2);
mean_ACC = mean(INTxOB,2);
mean_ACC_test = mean(INTxOB_test,2);


% %% 95% CI MC_ratio
% y = MEANxOB; %MC_ratio.';                                  % Create Dependent Variable ?Experiments? Data
% N = size(y,1);                                      % Number of ?Experiments? In Data Set
% yMean = mean(y);                                    % Mean Of All Experiments At Each Value Of ?x?
% ySEM = std(y)/sqrt(N);                              % Compute ?Standard Error Of The Mean? Of All Experiments At Each Value Of ?x?
% CI95 = tinv([0.025 0.975], N-1);                    % Calculate 95% Probability Intervals Of t-Distribution
% yCI95 = bsxfun(@times, ySEM, CI95(:));              % Calculate 95% Confidence Intervals Of All Experiments At Each Value Of ?x?
% 
% % put result into matrix
% net_MC_CI95(:,net_i) = yCI95(2,:);

%% PLOT


