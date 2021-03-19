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

%% SIGNAL DETECTION + METRICS FOR EACH OUTBREAK

INTxOB = [];

for ob_i = 1:(num_food_nets*num_ob)
    
    ob_i
    
    current_ob_data = ob_data{ob_i,1};
    current_ob_src_net = ob_data{ob_i,3};
    current_ob_src_node = ob_data{ob_i,2};

    %%% Get net_MC_means: ILL INTERVAL x NUM_NETS (averaged across num_samples for each network)
    [SimSig_ob, raw_ob] = plot_compute_signal_OB_SIM_METRICS(all_food_nets, 0, stage_ends, current_ob_data, ill_over_time_interval, MC_method, num_samples, 0);
    %[SimSig_dpr, raw_dpr] = plot_compute_signal_OB_SIM_METRICS(all_food_nets, 0, stage_ends, current_ob_data, ill_over_time_interval, MC_method, num_samples, 1);

    %%% Put all net
    
    %curr_method = SimSig_ob;

    net_MC_means = SimSig_ob;
    
    %%% Get metrics for this outbreak and put into a matrix of ILL INTERVAL x NUM_OB

    [~, idx] = sort(net_MC_means,2,'descend');
    Sig_star(:,ob_i) = net_MC_means(:,current_ob_src_net);
    
    for ill = 1:ill_it
        
        rank_original(ill,ob_i) = find(idx(ill,:) == current_ob_src_net);
        
        if rank_original(ill,ob_i) == 1
            ACC_1(ill,ob_i) = 1;
        else
            ACC_1(ill,ob_i) = 0;
        end
        
        if rank_original(ill,ob_i) < 3
            ACC_2(ill,ob_i) = 1;
        else
            ACC_2(ill,ob_i) = 0;
        end
        
        Sig_hat(ill,ob_i) = net_MC_means(ill,idx(ill,1));
        
        Sig_star_hat(ill,ob_i) = Sig_star(ill,ob_i)/(Sig_hat(ill,ob_i));
        
    end
            

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



% applyToGivenRow = @(func, matrix) @(row) func(matrix(row, :))
% applyToRows = @(func, matrix) arrayfun(applyToGivenRow(func, matrix), 1:size(matrix,1))'
% 
% % Example
% myMx = net_MC_means;
% myFunc = @sortrows
% 
% applyToRows(myFunc , myMx)
