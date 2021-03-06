%% CALCULATE SIGNAL DETECTION METRICS OVER MULTIPLE OUTBREAK SIMULATIONS


%% PARAMETERS TO CHOOSE
num_ob = 100;
num_samples=100;
dpr_flag = 0;
computing_NormSig = 0;

%% Input data

stage_ends = [100 200 300 400];

% Food networks and prior pmfs
% Food networks and prior pmfs
% Food networks FULL
num_food_nets = 6;
all_food_nets = cell(num_food_nets,1);
all_food_nets{1} = rand1;
all_food_nets{2} = rand2;
all_food_nets{3} = rand3;
all_food_nets{4} = rand4;
all_food_nets{5} = rand5;
all_food_nets{6} = rand6;


num_prior_pmfs = num_food_nets;
all_prior_pmfs = cell(num_food_nets,1);
all_prior_pmfs{1} = 0;
all_prior_pmfs{2} = 0;
all_prior_pmfs{3} = 0;
all_prior_pmfs{4} = 0;
all_prior_pmfs{5} = 0;
all_prior_pmfs{6} = 0;

num_net_names = num_food_nets;
all_net_names = cell(num_food_nets,1);
all_net_names{1} = 'rand1';
all_net_names{2} = 'rand2';
all_net_names{3} = 'rand3';
all_net_names{4} = 'rand4';
all_net_names{5} = 'rand5';
all_net_names{6} = 'rand6';



%% GENERATE OUTBREAKS
% 
ob_data = [];

% Choose number of illnesses and number of contaminated nodes
num_uniq = 30; %num_uniq_vec(uniq_it);
num_ill = 200;

% Generate outbreaks: num_ob of outbreaks for each network
%[ob_data] = rand_sim_outbreaks(num_samples, num_uniq, num_ill, stage_ends, trueNet);

for N = 1:num_food_nets
    
    %% If using WHS networks only, need to extract WHS supply channel and get A
    food_net = all_food_nets{N};
   
    ob_data_N = rand_sim_outbreaks(num_ob, num_uniq, num_ill, stage_ends, food_net);
    ob_data_N = [ob_data_N num2cell(repmat(N,num_ob,1))];    % to note the food network source
    ob_data = [ob_data; ob_data_N];     % to create a cell listing all outbreaks
end

% Choose which slice(s) in time to do source identification
ill_over_time_interval = [20:20:200]; %[2 5 10 20 30 40 50 100 150 200 250 300 350 400 450 500];
ill_it = size(ill_over_time_interval,2);

%% SIGNAL DETECTION + METRICS FOR EACH OUTBREAK

MC_method = 1;

ACC_1_method0_Sig=[];
ACC_2_method0_Sig=[];
rank_original_method0_Sig=[];
ACC_1_method0_raw=[];
ACC_2_method0_raw=[];
rank_original_method0_raw=[];
Sig_star_method0_Sig=[];
Sig_star_hat_method0_Sig=[];
Sig_star_method0_raw=[];
Sig_star_hat_method0_raw=[];

for ob_i = 1:(N*num_ob)
    
    ob_i
    
    current_ob_data = ob_data{ob_i,1};
    current_ob_src_net = ob_data{ob_i,3};
    current_ob_src_node = ob_data{ob_i,2};
    
    %%% Get net_MC_means: ILL INTERVAL x NUM_NETS (averaged across num_samples for each network)
    % Specify whether getting SimSig or NormSig
    if computing_NormSig==1
        [method0_Sig, method0_raw] = plot_compute_signal_OB_SIM_METRICS_RLG_norm(all_food_nets, 0, stage_ends, current_ob_data, ill_over_time_interval, MC_method, num_samples, 0);
    else
        [method0_Sig, method0_raw] = plot_compute_signal_OB_SIM_METRICS_RLG_SimSig(all_food_nets, 0, stage_ends, current_ob_data, ill_over_time_interval, MC_method, num_samples, 0);
    end
    
        
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
        
    
end %ob_i

%% PRINT TO CSV

foldername = '/Users/abigailhorn/Dropbox/MATLAB/Elena2017/utility/Model_Comparison/0_Dec2020/Results2021July/ACC_tests_RLG';
filename = sprintf('%s/ACC_SimSig.csv',foldername);
writematrix(ACC_1_method0_Sig, filename);
dlmwrite(filename, ACC_2_method0_Sig, '-append','roffset',1,'delimiter', ',');
dlmwrite(filename, rank_original_method0_Sig, '-append','roffset',1,'delimiter', ',');
dlmwrite(filename, Sig_star_method0_Sig, '-append','roffset',1,'delimiter', ',');
dlmwrite(filename, Sig_star_hat_method0_Sig, '-append','roffset',1,'delimiter', ',');

fclose('all');

filename = sprintf('%s/ACC_raw.csv',foldername);
writematrix(ACC_1_method0_raw, filename);
dlmwrite(filename, ACC_2_method0_raw, '-append','roffset',1,'delimiter', ',');
dlmwrite(filename, rank_original_method0_raw, '-append','roffset',1,'delimiter', ',');
dlmwrite(filename, Sig_star_method0_raw, '-append','roffset',1,'delimiter', ',');
dlmwrite(filename, Sig_star_hat_method0_raw, '-append','roffset',1,'delimiter', ',');


fclose('all');

%% MEAN AND 95%CI OVER ALL OUTBREAKS

MC1_mean_Sig_star_hat_method0_Sig=[];
MC1_mean_Sig_star_hat_method0_raw=[];

% method0_Sig
net1_WHS4_MC1_mean_ACC_1_method0_Sig = mean(ACC_1_method0_Sig,2);
net1_WHS4_MC1_mean_ACC_2_method0_Sig = mean(ACC_2_method0_Sig,2);
net1_WHS4_MC1_mean_rank_original_method0_Sig = mean(rank_original_method0_Sig,2);
MC1_mean_Sig_star_method0_Sig = mean(Sig_star_method0_Sig,2);
MC1_mean_Sig_star_hat_method0_Sig(:,ob_i) = mean(Sig_star_hat_method0_Sig,2);

% method0_raw
net1_WHS4_MC1_mean_ACC_1_method0_raw = mean(ACC_1_method0_raw,2);
net1_WHS4_MC1_mean_ACC_2_method0_raw = mean(ACC_2_method0_raw,2);
net1_WHS4_MC1_mean_rank_original_method0_raw = mean(rank_original_method0_raw,2);
MC1_mean_Sig_star_method0_raw = mean(Sig_star_method0_raw,2);
MC1_mean_Sig_star_hat_method0_raw(:,ob_i) = mean(Sig_star_hat_method0_raw,2);

hold on;
plot(ill_over_time_interval, net1_WHS4_MC1_mean_ACC_1_method0_Sig, 'b', 'marker','*')
plot(ill_over_time_interval, net1_WHS4_MC1_mean_ACC_2_method0_Sig, 'b','marker','o')

hold on;
plot(ill_over_time_interval, net1_WHS4_MC1_mean_rank_original_method0_Sig, 'b', 'marker','*')
plot(ill_over_time_interval, net1_WHS4_MC1_mean_rank_original_method0_raw, 'b','marker','o')


%% 95% CI MC_ratio
% % y = ACC_1_method0_Sig.'; %randn(50,100);                                  % Create Dependent Variable ?Experiments? Data
% % N = size(y,1);                                      % Number of ?Experiments? In Data Set
% % yMean = mean(y);                                    % Mean Of All Experiments At Each Value Of ?x?
% % ySEM = std(y)/sqrt(N);                              % Compute ?Standard Error Of The Mean? Of All Experiments At Each Value Of ?x?
% % CI95 = tinv([0.025 0.975], N-1);                    % Calculate 95% Probability Intervals Of t-Distribution
% % yCI95 = bsxfun(@times, ySEM, CI95(:));              % Calculate 95% Confidence Intervals Of All Experiments At Each Value Of ?x?
% % % put result into matrix
% % MC1_CI95_ACC_1_method0_Sig = yCI95(2,:);
% % 
% % MC_mean = net1_WHS4_MC1_mean_ACC_1_method0_Sig;
% % MC_CI95 = MC1_CI95_ACC_1_method0_Sig;
% % x=ill_over_time_interval;
% %     plot_colored_fill(x,MC_mean,MC_mean-MC_CI95,MC_mean);
% %     plot_colored_fill(x,MC_mean,MC_mean+MC_CI95,MC_mean);
% % 
% % 
% % y = MC_ratio_actual.'; %randn(50,100);                                  % Create Dependent Variable ?Experiments? Data
% % N = size(y,1);                                      % Number of ?Experiments? In Data Set
% % yMean = mean(y);                                    % Mean Of All Experiments At Each Value Of ?x?
% % ySEM = std(y)/sqrt(N);                              % Compute ?Standard Error Of The Mean? Of All Experiments At Each Value Of ?x?
% % CI95 = tinv([0.025 0.975], N-1);                    % Calculate 95% Probability Intervals Of t-Distribution
% % yCI95 = bsxfun(@times, ySEM, CI95(:));              % Calculate 95% Confidence Intervals Of All Experiments At Each Value Of ?x?
% % % put result into matrix
% % net_MC_CI95_actual(:,net_i) = yCI95(2,:);
% % 


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
