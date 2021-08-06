%%%%%WRAPPER SimSig WHS4

%% Input data

stage_ends = stage_ends_4S; %[100 1100 2100 2200]; %[100 200 300 400];

% Food networks and prior pmfs
% Food networks FULL
num_food_nets = 6;
all_food_nets = cell(num_food_nets,1);
all_food_nets{1} = veg_full_s;
all_food_nets{2} = eggs_full;
all_food_nets{3} = sausage_tc_full;
%all_food_nets{4} = sausage_fro_full;
%all_food_nets{5} = oilseeds;
all_food_nets{4} = cheese;
all_food_nets{5} = milk_products;
all_food_nets{6} = poultry;
% all_food_nets{9} = veg_dry;
%all_food_nets{7} = milk;
%all_food_nets{8} = fruit;
% %all_food_nets{12} = fish;


%prior_pmf = (1/num_feasible)*ones(1,num_feasible);
num_prior_pmfs = num_food_nets;
all_prior_pmfs = cell(num_food_nets,1);
all_prior_pmfs{1} = vec_veg_n;
all_prior_pmfs{2} = vec_eggs_n;
all_prior_pmfs{3} = vec_sausage_tc_n;
%all_prior_pmfs{4} = vec_sausage_fro_n;
%all_prior_pmfs{5} = vec_oilseeds_n;
all_prior_pmfs{4} = vec_cheese_n;
all_prior_pmfs{5} = vec_cheese_n;
all_prior_pmfs{6} = vec_poultry_n;
% all_prior_pmfs{9} = vec_veg_dry_n;
%all_prior_pmfs{7} = vec_milk_n;
%all_prior_pmfs{8} = vec_fruit_n;
% %all_prior_pmfs{12} = vec_fish_n;

num_net_names = num_food_nets;
all_net_names = cell(num_food_nets,1);
all_net_names{1} = 'vegetables';
all_net_names{2} = 'eggs';
all_net_names{3} = 'meatProducts'; %'sausageTC';
%all_net_names{4} = 'sausageFRO';
%all_net_names{5} = 'oilseeds';
all_net_names{4} = 'cheese';
all_net_names{5} = 'milkProducts';
all_net_names{6} = 'poultry';
% all_net_names{9} = 'vegDry';
%all_net_names{7} = 'milk';
%all_net_names{8} = 'fruit';
% %all_net_names{12} = 'fish';

% Outbreak data
num_ob_datasets = 14;
all_ob_data = cell(num_ob_datasets,1);
all_ob_data{1} = simulated_ob_4S(1,:);
all_ob_data{2} = contam_rets_4S_EHEC(1,:); %simulated_ob_FULL;
all_ob_data{3} = contam_rets_EHEC_RKI_4S(1,:);
all_ob_data{4} = contam_rets_L15_4S(1,:);
all_ob_data{5} = contam_rets_FIP_4S(1,:);
% all_ob_data{6} = simulated_ob_4S_eggs(1,:);
% all_ob_data{7} = simulated_ob_4S_milkproducts(1,:);
% all_ob_data{8} = simulated_ob_4S_milk(1,:);
% all_ob_data{9} = simulated_ob_4S_sausageTC(1,:);
% all_ob_data{10} = simulated_ob_4S_poultry(1,:);
% all_ob_data{11} = simulated_ob_4S_cheese(1,:);
% all_ob_data{12} = simulated_ob_4S_vegDry(1,:);
% all_ob_data{13} = simulated_ob_4S_sausageFRO(1,:);
% all_ob_data{14} = simulated_ob_4S_fruit(1,:);


num_ob_names = num_ob_datasets;
all_ob_names = cell(num_ob_datasets);
all_ob_names{1} = 'sim';
all_ob_names{2} = 'EHEC';
all_ob_names{3} = 'EHECRKI';
all_ob_names{4} = 'Listeria';
all_ob_names{5} = 'Fipronil';
% all_ob_names{6} = 'simEggs';
% all_ob_names{7} = 'simMilkProd';
% all_ob_names{8} = 'simMilk';
% all_ob_names{9} = 'simSausageTC';
% all_ob_names{10} = 'simPoultry';
% all_ob_names{11} = 'simCheese';
% all_ob_names{12} = 'simVegDry';
% all_ob_names{13} = 'simSausageFRO';
% all_ob_names{14} = 'simFruit';



%%

num_samples = 25; % Choose the number of samples
both_norm = 0; % Run both ob and network randomization normalization procedures? 
dpr_flag = 0; % 0 computes ob randomization; 1 computes network randomization 
MC_method = 1;  % 0 computes all methods
prior_pmf = 0;  % 0 means no prior pmf, use uniform distribution
%ill_over_time_interval = [100:100:500]; % 300:100:500];% 750 1000 1250 1500]; %[10:10:200 300:100:1000]; %[5:5:50];% %1:1:200; %
%ill_over_time_interval = [1 10 20 50 100 200:200:1000];% 2000];% 750 1000 1250 1500]; %[10:10:200 300:100:1000]; %[5:5:50];% %1:1:200; %
%ill_over_time_interval = [1 10:10:60 75 77]; %[10:10:200 300:100:500 750 1000 1250 1500]; %[10:10:200 300:100:1000]; %[5:5:50];% %1:1:200; %
%ill_over_time_interval = [2 5:5:30 32]; %[10:10:200 300:100:500 750 1000 1250 1500]; %[10:10:200 300:100:1000]; %[5:5:50];% %1:1:200; %

%ill_over_time_interval = [20:20:100 150:50:300];  % Sim
ill_over_time_interval = [20:20:100 150:50:300 400:200:3600 3700 3785];  % EHEC
%ill_over_time_interval = [1 10 20:20:60 75];  % Listeria
ill_interval = ill_over_time_interval;

single_ob = 3; % 0 iterates over all outbreaks; 
save_plot = 0;

ob_index = single_ob;
ob = all_ob_data{ob_index};
ob_name = all_ob_names{ob_index}; %A_outgoing_sort
current_ob_data = {ob};
current_ob_names = {ob_name};

if both_norm == 1
    for norm_method = 1:2
        norm_method_i = norm_method-1;
        [nested_net_data, net_MC_means_NormSig, net_MC_CI95_NormSig] = plot_compute_signal_rawvsSimSig_WHS(all_food_nets, all_net_names, prior_pmf, stage_ends, current_ob_data, current_ob_names, ill_over_time_interval, MC_method, num_samples, norm_method, save_plot);
    end
else
    norm_method = dpr_flag;
    [nested_net_data, net_MC_means_RawSig, net_MC_CI95_RawSig] = plot_compute_signal_rawvsSimSig_WHS(all_food_nets, all_net_names, prior_pmf, stage_ends, current_ob_data, current_ob_names, ill_over_time_interval, MC_method, num_samples, norm_method, save_plot);
end


all_net_data_EHEC3600 = nested_net_data;

foldername = '/Users/abigailhorn/Dropbox/MATLAB/Elena2017/utility/Model_Comparison/0_Dec2020/Results/ACC_tests';
filename = sprintf('%s/convergence_singleOB_EHEC_3600ill.csv',foldername);
writematrix(all_net_data_EHEC3600, filename);


%nested_ob_data_methodEntpy_obSim = nested_ob_data{1,1}{4,1};
%nested_ob_data_methodKLD_obSim_INTERMEDIATE = nested_ob_data{1,1}{1,1};
%nested_ob_data_methodEntpy_obRand = nested_ob_data{1,1}{4,1};



%mkdir Figs_100nodes_deg4_determ 0_2019S/figures

%% Run the code to get plots output
%plot_compute_signal(all_food_nets, all_net_names, prior_pmf, stage_ends, current_ob_data, current_ob_names, ill_over_time_interval, MC_method, num_samples, dpr_flag, save_plot); 
 
