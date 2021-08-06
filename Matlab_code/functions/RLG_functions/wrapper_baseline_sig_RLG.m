%%%%%WRAPPER SIM RLG

%% Input data
% % Global parameters

stage_ends = [100 200 300 400];

% Food networks and prior pmfs
num_food_nets = 7;
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
all_net_names{1} = 'Geom1';
all_net_names{2} = 'Geom2';
all_net_names{3} = 'Geom3';
all_net_names{4} = 'Geom4';
all_net_names{5} = 'Geom5';
all_net_names{6} = 'Geom6';
all_net_names{7} = 'Geom7';

% Outbreak data
num_ob_datasets = 3;
all_ob_data = cell(num_ob_datasets,1);
all_ob_data{1} = sim_ob(1,:);
all_ob_data{2} = const_ob(1,:); %simulated_ob_FULL;
all_ob_data{3} = samp_ob(1,:);

num_ob_names = num_ob_datasets;
all_ob_names = cell(num_ob_datasets);
all_ob_names{1} = 'sim';
all_ob_names{2} = 'const';
all_ob_names{3} = 'samp';

%%

num_samples = 2000; % Choose the number of samples
both_norm = 0; % Run both ob and network randomization normalization procedures? 
dpr_flag = 0; % 0 computes ob randomization; 1 computes network randomization 
MC_method = 1;  % 0 computes all methods
prior_pmf = 0;  % 0 means no prior pmf, use uniform distribution
%ill_over_time_interval = [20:20:80 100:50:500]; %[10:10:200 300 400 500]; %[5:5:50];% %1:1:200; %
ill_over_time_interval = [1:9 10:10:40 60 80 100:50:500]; %[10:10:200 300 400 500]; %[5:5:50];% %1:1:200; %
single_ob = 1; % 0 iterates over all outbreaks; 
save_plot = 0;
sim_flag=1;

if single_ob == 0
    current_ob_data = all_ob_data;
    current_ob_names = all_ob_names;
else    % If I want to single out one outbreak
    ob_index = single_ob;
    ob = all_ob_data{ob_index};
    ob_name = all_ob_names{ob_index};
    current_ob_data = {ob};
    current_ob_names = {ob_name};
end

norm_method = dpr_flag;
[nested_ob_data] = BaselineSig_L2_RLG(all_food_nets, all_net_names, prior_pmf, stage_ends, current_ob_data, current_ob_names, ill_over_time_interval, MC_method, num_samples, save_plot, sim_flag);


%% Output to csv to share with Marcel
foldername = '/Users/abigailhorn/Dropbox/MATLAB/Elena2017/utility/Model_Comparison/0_Dec2020/Results/BaselineSig_out';
net_type = 'RLG';
write_baseline_csv(nested_ob_data, num_food_nets, all_net_names, num_samples, ill_over_time_interval, foldername, sim_flag, net_type)


%nested_ob_data_methodEntpy_obSim = nested_ob_data{1,1}{4,1};
%nested_ob_data_methodKLD_obSim_INTERMEDIATE = nested_ob_data{1,1}{1,1};
%nested_ob_data_methodEntpy_obRand = nested_ob_data{1,1}{4,1};



%mkdir Figs_100nodes_deg4_determ 0_2019S/figures

%% Run the code to get plots output
%plot_compute_signal(all_food_nets, all_net_names, prior_pmf, stage_ends, current_ob_data, current_ob_names, ill_over_time_interval, MC_method, num_samples, dpr_flag, save_plot); 
 
