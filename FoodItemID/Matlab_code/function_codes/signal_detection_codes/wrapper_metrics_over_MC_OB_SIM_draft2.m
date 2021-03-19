%% CALCULATE SIGNAL DETECTION METRICS OVER MULTIPLE OUTBREAK SIMULATIONS


%% PARAMETERS TO CHOOSE
num_ob = 15;
num_samples=1000;
dpr_flag = 0;


%% Input data

stage_ends = [100 200 300 400]; %[100 200 300 400];

% Food networks and prior pmfs
num_food_nets = 6;
all_food_nets = cell(num_food_nets,1);
all_food_nets{1} = trueNet;
all_food_nets{2} = rand2;
all_food_nets{3} = rand3;
all_food_nets{4} = rand4;
all_food_nets{5} = rand5;
all_food_nets{6} = rand6;
all_food_nets{7} = rand7;


prior_pmf = (1/num_feasible)*ones(1,num_feasible);

num_net_names = num_food_nets;
all_net_names = cell(num_food_nets,1);
all_net_names{1} = 'trueNet';
all_net_names{2} = 'rand2';
all_net_names{3} = 'rand3';
all_net_names{4} = 'rand4';
all_net_names{5} = 'rand5';
all_net_names{6} = 'rand6';
all_net_names{7} = 'rand7';



%% GENERATE OUTBREAKS
% 
ob_data = [];

% Choose number of illnesses and number of contaminated nodes
num_uniq = 35; %num_uniq_vec(uniq_it);
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

MC_method = 1;

for ob_i = 1:(num_food_nets*num_ob)
    
    ob_i
    
    current_ob_data = ob_data{ob_i,1};
    current_ob_src_net = ob_data{ob_i,3};
    current_ob_src_node = ob_data{ob_i,2};
    
    %%% Get net_MC_means: ILL INTERVAL x NUM_NETS (averaged across num_samples for each network)
    [method0_Sig, method0_raw] = plot_compute_signal_OB_SIM_METRICS(all_food_nets, 0, stage_ends, current_ob_data, ill_over_time_interval, MC_method, num_samples, 0);
    [method1_Sig, method1_raw] = plot_compute_signal_OB_SIM_METRICS(all_food_nets, 0, stage_ends, current_ob_data, ill_over_time_interval, MC_method, num_samples, 1);
    
    %%% Put all net
    
    % method0_Sig
    [ACC_1, ACC_2, rank_original, Sig_star, Sig_star_hat] = metrics_MC_brute(method0_Sig, ill_it, current_ob_src_net);
    ACC_1_method0_Sig(:,ob_i) = ACC_1;
    ACC_2_method0_Sig(:,ob_i) = ACC_2;
    rank_original_method0_Sig(:,ob_i) = rank_original;
    Sig_star_method0_Sig(:,ob_i) = Sig_star;
    Sig_star_hat_method0_Sig(:,ob_i) = Sig_star_hat;
    
    % method0_raw
    [ACC_1, ACC_2, rank_original, Sig_star, Sig_star_hat] = metrics_MC_brute(method0_raw, ill_it, current_ob_src_net);
    ACC_1_method0_raw(:,ob_i) = ACC_1;
    ACC_2_method0_raw(:,ob_i) = ACC_2;
    rank_original_method0_raw(:,ob_i) = rank_original;
    Sig_star_method0_raw(:,ob_i) = Sig_star;
    Sig_star_hat_method0_raw(:,ob_i) = Sig_star_hat;
    
    % method1_Sig
    [ACC_1, ACC_2, rank_original, Sig_star, Sig_star_hat] = metrics_MC_brute(method1_Sig, ill_it, current_ob_src_net);
    ACC_1_method1_Sig(:,ob_i) = ACC_1;
    ACC_2_method1_Sig(:,ob_i) = ACC_2;
    rank_original_method1_Sig(:,ob_i) = rank_original;
    Sig_star_method1_Sig(:,ob_i) = Sig_star;
    Sig_star_hat_method1_Sig(:,ob_i) = Sig_star_hat;
    
    % method1_raw
    [ACC_1, ACC_2, rank_original, Sig_star, Sig_star_hat] = metrics_MC_brute(method1_raw, ill_it, current_ob_src_net);
    ACC_1_method1_raw(:,ob_i) = ACC_1;
    ACC_2_method1_raw(:,ob_i) = ACC_2;
    rank_original_method1_raw(:,ob_i) = rank_original;
    Sig_star_method1_raw(:,ob_i) = Sig_star;
    Sig_star_hat_method1_raw(:,ob_i) = Sig_star_hat;
    
end %ob_i

%% MEAN AND 95%CI OVER ALL OUTBREAKS

% method0_Sig
MC1_mean_ACC_1_method0_Sig = mean(ACC_1_method0_Sig,2);
MC1_mean_ACC_2_method0_Sig = mean(ACC_2_method0_Sig,2);
MC1_mean_rank_original_method0_Sig = mean(rank_original_method0_Sig,2);
MC1_mean_Sig_star_method0_Sig = mean(Sig_star_method0_Sig,2);
MC1_mean_Sig_star_hat_method0_Sig(:,ob_i) = mean(Sig_star_hat_method0_Sig,2);

% method0_raw
MC1_mean_ACC_1_method0_raw = mean(ACC_1_method0_raw,2);
MC1_mean_ACC_2_method0_raw = mean(ACC_2_method0_raw,2);
MC1_mean_rank_original_method0_raw = mean(rank_original_method0_raw,2);
MC1_mean_Sig_star_method0_raw = mean(Sig_star_method0_raw,2);
MC1_mean_Sig_star_hat_method0_raw(:,ob_i) = mean(Sig_star_hat_method0_raw,2);

% method1_Sig
MC1_mean_ACC_1_method1_Sig = mean(ACC_1_method1_Sig,2);
MC1_mean_ACC_2_method1_Sig = mean(ACC_2_method1_Sig,2);
MC1_mean_rank_original_method1_Sig = mean(rank_original_method1_Sig,2);
MC1_mean_Sig_star_method1_Sig = mean(Sig_star_method1_Sig,2);
MC1_mean_Sig_star_hat_method1_Sig(:,ob_i) = mean(Sig_star_hat_method1_Sig,2);

% method1_raw
MC1_mean_ACC_1_method1_raw = mean(ACC_1_method1_raw,2);
MC1_mean_ACC_2_method1_raw = mean(ACC_2_method1_raw,2);
MC1_mean_rank_original_method1_raw = mean(rank_original_method1_raw,2);
MC1_mean_Sig_star_method1_raw = mean(Sig_star_method1_raw,2);
MC1_mean_Sig_star_hat_method1_raw(:,ob_i) = mean(Sig_star_hat_method1_raw,2);



hold on;
plot(ill_over_time_interval, MC1_mean_ACC_1_method0_Sig, 'b', 'marker','*')
hold on;
plot(ill_over_time_interval, MC1_mean_ACC_1_method1_Sig, 'g','marker','*')
plot(ill_over_time_interval, MC1_mean_ACC_1_method0_raw, 'b','marker','o')
plot(ill_over_time_interval, MC1_mean_ACC_1_method1_raw, 'g','marker','o')

hold on;
plot(ill_over_time_interval, MC1_mean_rank_original_method0_Sig, 'b', 'marker','*')
hold on;
plot(ill_over_time_interval, MC1_mean_rank_original_method1_Sig, 'g','marker','*')
plot(ill_over_time_interval, MC1_mean_rank_original_method0_raw, 'b','marker','o')
plot(ill_over_time_interval, MC1_mean_rank_original_method1_raw, 'g','marker','o')


% % % 
% % % 
% % % %% 95% CI MC_ratio
% % % y = ACC_1_method0_Sig.'; %randn(50,100);                                  % Create Dependent Variable ?Experiments? Data
% % % N = size(y,1);                                      % Number of ?Experiments? In Data Set
% % % yMean = mean(y);                                    % Mean Of All Experiments At Each Value Of ?x?
% % % ySEM = std(y)/sqrt(N);                              % Compute ?Standard Error Of The Mean? Of All Experiments At Each Value Of ?x?
% % % CI95 = tinv([0.025 0.975], N-1);                    % Calculate 95% Probability Intervals Of t-Distribution
% % % yCI95 = bsxfun(@times, ySEM, CI95(:));              % Calculate 95% Confidence Intervals Of All Experiments At Each Value Of ?x?
% % % % put result into matrix
% % % MC1_CI95_ACC_1_method0_Sig = yCI95(2,:);
% % % 
% % % MC_mean = MC1_mean_ACC_1_method0_Sig;
% % % MC_CI95 = MC1_CI95_ACC_1_method0_Sig;
% % % x=ill_over_time_interval;
% % %     plot_colored_fill(x,MC_mean,MC_mean-MC_CI95,MC_mean);
% % %     plot_colored_fill(x,MC_mean,MC_mean+MC_CI95,MC_mean);
% % % 
% % % 
% % % y = MC_ratio_actual.'; %randn(50,100);                                  % Create Dependent Variable ?Experiments? Data
% % % N = size(y,1);                                      % Number of ?Experiments? In Data Set
% % % yMean = mean(y);                                    % Mean Of All Experiments At Each Value Of ?x?
% % % ySEM = std(y)/sqrt(N);                              % Compute ?Standard Error Of The Mean? Of All Experiments At Each Value Of ?x?
% % % CI95 = tinv([0.025 0.975], N-1);                    % Calculate 95% Probability Intervals Of t-Distribution
% % % yCI95 = bsxfun(@times, ySEM, CI95(:));              % Calculate 95% Confidence Intervals Of All Experiments At Each Value Of ?x?
% % % % put result into matrix
% % % net_MC_CI95_actual(:,net_i) = yCI95(2,:);



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
