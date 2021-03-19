%%%%% Remember to update the src node --> currently equal to 285

%% Code to calculate Model Comparison statistics for multiple networks and outbreak datasets

%% Universal

net_index = [1];%[1:2];% 9];% 5:9];%[1 2 3 5 6]; %[1:9];

feas_sources = 402;

% % Steps: Generate random outbreaks, run source identification, evaluate variances, and plot histogram

%% Parameters
stage_ends = stage_ends_4S; %stage_ends_FULL;
num_stages = size(stage_ends,2);
n1 = stage_ends(1);

%% Change these parameters for different networks and outbreaks
%contam_rets_actual = contam_rets_L15_full; %contam_rets_full_EHEC; 

%% Find the number of unique in the real data (or set this if doing simulation)
%num_uniq = size(unique(contam_rets_actual));  % Number of unique values
%num_ill = size(contam_rets_actual,2);   % Choose the number of observations to do the analysis at
%contam_rets_actual_at_ill = contam_rets_FULL(1,1:num_ill);
%unique_reps_actual = unique(contam_rets_actual_at_ill,'stable');  % Reduce to considering only the unique samples


%%%%%%
%% OR
%%%%%%%%%%%%%%%
num_ill = 1000; %77; %500; %1000;
num_uniq = 50; %46; %100; %331;
%%%%%%%%%%%%%%%

%num_ill = 10;
%num_uniq = 10;

%contam_rets_actual = contam_rets_L15_3S; %contam_rets_full_EHEC(1,1:1500); %contam_rets_L15_full(1,1:end); % %contam_rets_full_EHEC(1,1:30); %contam_rets_L15_full(1,1:32);   %  %contam_rets_full_EHEC(1,1:30); %contam_rets_full_EHEC(1,1:30); %contam_rets_L15_full(1,1:32); %contam_rets_4S_EHEC(1,1:77); %contam_rets_L15_full; %contam_rets_4S_EHEC(1,1:254); %contam_rets_FIP_full; %contam_rets_L15_full; %contam_rets_L15_full; %contam_rets_L15_full; %contam_rets_full_EHEC;
% % Choose the number of illnesses at which to do the traceback (depends on length of contam_rets_actual)


% net_name = 'Veg'; %'Eggs';
% food_net_FULL = veg_full_s; %sausage_tc_full; %veg_full_s; %milk_products; %sausage_fro_full; %eggs_full; %sausage_fro_full; %eggs_full; %veg_full_s; %sausage_tc_full; %veg_full_s;
% food_net = food_net_FULL;
% A_FULL = A_veg; %A_sausage_tc; %A_veg; %A_sausage_fro;
% A = A_FULL; %A_sausage_fro;
% prior_pmf = vec_veg_n; %vec_sausage_tc_n; %vec_veg_n; %ones(1,452)

% Food networks FULL
num_food_nets = 12;
all_food_nets = cell(num_food_nets,1);
all_food_nets{1} = veg_full_s;
all_food_nets{2} = eggs_full;
all_food_nets{3} = sausage_tc_full;
all_food_nets{4} = sausage_fro_full;
all_food_nets{5} = oilseeds;
all_food_nets{6} = cheese;
all_food_nets{7} = milk_products;
all_food_nets{8} = poultry;
all_food_nets{9} = veg_dry;
all_food_nets{10} = milk;
all_food_nets{11} = fruit;
all_food_nets{12} = fish;


num_prior_pmfs = num_food_nets;
all_prior_pmfs = cell(num_food_nets,1);
all_prior_pmfs{1} = vec_veg_n;
all_prior_pmfs{2} = vec_eggs_n;
all_prior_pmfs{3} = vec_sausage_tc_n;
all_prior_pmfs{4} = vec_sausage_fro_n;
all_prior_pmfs{5} = vec_oilseeds_n;
all_prior_pmfs{6} = vec_cheese_n;
all_prior_pmfs{7} = vec_cheese_n;
all_prior_pmfs{8} = vec_poultry_n;
all_prior_pmfs{9} = vec_veg_dry_n;
all_prior_pmfs{10} = vec_milk_n;
all_prior_pmfs{11} = vec_fruit_n;
all_prior_pmfs{12} = vec_fish_n;

num_net_names = num_food_nets;
all_net_names = cell(num_food_nets,1);
all_net_names{1} = 'vegetables';
all_net_names{2} = 'eggs';
all_net_names{3} = 'sausageTC';
all_net_names{4} = 'sausageFRO';
all_net_names{5} = 'oilseeds';
all_net_names{6} = 'cheese';
all_net_names{7} = 'milkProducts';
all_net_names{8} = 'poultry';
all_net_names{9} = 'vegDry';
all_net_names{10} = 'milk';
all_net_names{11} = 'fruit';
all_net_names{12} = 'fish';

net_i = net_index; %num_food_nets
net_name = all_net_names{net_i};

food_net_full = all_food_nets{net_i};
food_net_WHS = food_net_full(1:402, 11709:12110);
n1=402;
food_net_4S = [zeros(n1) food_net_WHS zeros(n1) zeros(n1); zeros(n1) zeros(n1) food_net_WHS zeros(n1); zeros(n1) zeros(n1) zeros(n1) food_net_WHS; zeros(n1) zeros(n1) zeros(n1) diag(ones(n1,1))];
food_net = food_net_4S;
% % Create A
num_stages = length(stage_ends); % for convenience
I_t = eye(stage_ends(num_stages-1));
Q = food_net(1:stage_ends(end-1), 1:stage_ends(end-1));
A = (I_t - Q)\food_net(1:stage_ends(end-1), stage_ends(end-1)+1:stage_ends(end));
food_net_A = A;

prior_pmf = all_prior_pmfs{net_i};
    
%%%%%%

% % Global parameters
%init_vols;
dist_vec;
pop;



%sampled_ob_4S_GOOD_SAVE_1000_EHEC = sampled_ob_4S;
%sampled_ob_FULL_GOOD_SAVE_1000_EHEC = sampled_ob_FULL;

%%%%%%%%%
%% Simulated outbreak
%%%%%%%%%

% Choose the number of samples
num_samples = 1;

% Generate a set of sources to do outbreak from
s_possible = find(sum(food_net_A(1:402,:),2)>0);  % only start from possible sources
src_list = randsample(s_possible,num_samples,true);

% % For each source i.e. sample, do the following
As_simulated_ob = zeros(num_samples, num_ill);
simulated_ob_FULL = zeros(num_samples, num_ill);
simulated_ob_4S = zeros(num_samples, num_ill);

%for s = 1:length(src_list)
    src = src_list(1);
    As = A(src,:); % Find prob of s-->retailers
    As_nonzero_ID = find(As);  % Find the connected retailers to s
    As_nonzero_num = size(As_nonzero_ID,2); % How many retailers connected to s
    
    if As_nonzero_num > num_uniq    % If there are enough connected retailers connected to s to replicate the number of unique values in the actual ob data
        uniq_samp_As = randsample(As_nonzero_ID, num_uniq, false);  % Randomly sample a set of num_uniq connected retailers
        num_uniq_As = num_uniq;  % We can sample the same number of unique as in actual ob data at this num_ill
    else
        uniq_samp_As = As_nonzero_ID;   % If there are not enough connected retailers to replicate the number of unique values in the acutal ob data
        num_uniq_As = As_nonzero_num;   % Just set the unique sample to all connected retailers
    end
    
    As_at_uniq = As(uniq_samp_As);
    As_samp_ob = randsample(uniq_samp_As, num_ill, true, As_at_uniq);
    simulated_ob_4S(s,:) = As_samp_ob + (stage_ends_4S(3));
    simulated_ob_FULL(s,:) = As_samp_ob + (stage_ends_FULL(3));

ob_data_sim{1,1} = src; %240;
ob_data_sim{1,2} = simulated_ob_FULL;
ob_data_sim{1,3} = 'eggs';
    
%end

%% Samples: Get a distribution of samples with the same number of unique nodes as the original set of observations
%%%%%%%%%

% Choose the number of samples
num_samples = 1;

% Create population-weighted samples
sampled_ob = zeros(num_samples,num_ill);
sampled_ob_4S = [];
sampled_ob_FULL = [];

for i = 1:num_samples
    unique_sample = randsample(1:402,num_uniq,false);
    pop_at_unique = pop(unique_sample);
    sample_402 = [unique_sample randsample(unique_sample, num_ill-num_uniq, true, pop_at_unique)];
    sampled_ob_4S(i,:) = sample_402+(stage_ends_4S(3));
    %sampled_ob_FULL(i,:) = sample_402+(stage_ends(num_stages-1));
   
end

%%%%% SAMPLE WITHOUT POPULATION NORMALIZATION %%%%%
% sampled_ob = zeros(num_samples,num_ill);
% sampled_ob_4S = [];
% sampled_ob_FULL = [];
% i = 1;
%     unique_sample = randsample(1:402,num_uniq,false);
%     %pop_at_unique = pop(unique_sample);
%     sample_402 = [unique_sample randsample(unique_sample, num_ill-num_uniq, true)];
%     sampled_ob_4S(i,:) = sample_402+(stage_ends_4S(3));
%     sampled_ob_FULL(i,:) = sample_402+(stage_ends(num_stages-1));
%     
% 



%%%%%
feas_sources = 402;
prior_add = 1;
normalize_by_population = 2;

% % Traceback with sampled outbreak
contam_reports = sampled_ob_4S; %sampled_ob_FULL_GOOD_SAVE_1000_EHEC; %sampled_ob_FULL;
%[pmf_sampled, ~] = time_traceback_April2017_fastinv(1, food_net, 1, stage_ends_FULL, prior_pmf, contam_reports, 0, 0, 0, 0, 0,pop,A);
%[pmf_sampled, ~] = traceback_fastinv_switch_feasible(1:stage_ends(1), prior_add, normalize_by_population, 1, food_net, 1, stage_ends, prior_pmf, contam_reports, 0, 0, 0, 0, 0,pop,A);
[pmf_sampled] = source_traceback_orig_log_feasible_tests(1:feas_sources, food_net_A, stage_ends, prior_pmf, contam_reports,pop);


% % Traceback with simulated outbreak
contam_reports = simulated_ob_4S;
%[pmf_simulated, ~] = time_traceback_April2017_fastinv(1, food_net, 1, stage_ends, prior_pmf, contam_reports, 0, 0, 0, 0, 0,pop,A);
[pmf_simulated, ~] = traceback_fastinv_switch_feasible(1:stage_ends(1), prior_add, normalize_by_population, 1, food_net, 1, stage_ends, prior_pmf, contam_reports, 0, 0, 0, 0, 0,pop,A);
[pmf_simulated] = source_traceback_orig_log_feasible_tests(1:feas_sources, food_net_A, stage_ends, prior_pmf, contam_reports,pop);

% % Traceback with actual outbreak
contam_reports = As_const_ob_4S; %contam_rets_actual_at_ill;
%[pmf_actual, ~] = time_traceback_April2017_fastinv(1, food_net, 1, stage_ends, prior_pmf, contam_reports, 0, 0, 0, 0, 0,pop,A);
%[pmf_const, ~] = traceback_fastinv_switch_feasible(1:stage_ends(1), prior_add, normalize_by_population, 1, food_net, 1, stage_ends, prior_pmf, contam_reports, 0, 0, 0, 0, 0,pop,A);
[pmf_const] = source_traceback_orig_log_feasible_tests(1:feas_sources, food_net_A, stage_ends, prior_pmf, contam_reports,pop);


nonzeros_const = size(find(pmf_const),2);
nonzeros_sim = size(find(pmf_simulated),2);
nonzeros_samp = size(find(pmf_sampled),2);
nonzeros_prior = size(find(prior_pmf),2);
num_nonzeros = max(max(nonzeros_const,nonzeros_sim),nonzeros_samp);

pmf_unif = [(1/num_nonzeros)* ones(1,num_nonzeros) zeros(1,(feas_sources-num_nonzeros))];

pmf_const_sort = sort(pmf_const,'descend');
pmf_simulated_sort = sort(pmf_simulated,'descend');
pmf_sampled_sort = sort(pmf_sampled,'descend');
pmf_prior_sort = sort(prior_pmf,'descend');

%num_nonzeros = max(nonzeros_sim,nonzeros_samp);

pmf_sampled_sort = pmf_sampled_sort(1:num_nonzeros);
pmf_simulated_sort = pmf_simulated_sort(1:num_nonzeros);
pmf_simulated_sort = pmf_simulated_sort(1:num_nonzeros);
pmf_const_sort = pmf_const_sort(1:num_nonzeros);




% hold on;
% plot(sort(pmf_sampled,'descend'))
% plot(sort(pmf_simulated,'descend'))        
% plot(sort(pmf_actual,'descend'))        
% ylim([0 .02])
%%%%%

%% Plot pmf code
%%%%%

fig = figure('Units', 'pixels' , 'Position', [100 100 500 375]);
hold on;
set(0,'DefaultAxesColor','none')
bar_pmf_sampled = plot(pmf_sampled_sort); %plot(sort(pmf_sampled,'descend'));
bar_pmf_simulated = plot(pmf_simulated_sort); %plot(sort(pmf_simulated,'descend'));
bar_pmf_const = plot(pmf_const_sort); %plot(sort(pmf_const,'descend'));
bar_pmf_unif = plot(pmf_unif);
%bar_pmf_unif = plot(sort(prior_pmf,'descend'));%plot(pmf_unif);


xlim([0 num_nonzeros])
%ylim([0 .01]) %1e-2])

set(bar_pmf_unif,'LineWidth',3);
set(bar_pmf_sampled,'LineWidth',3,'Color', 'b');
set(bar_pmf_simulated,'LineWidth',3,'Color', 'g');
set(bar_pmf_const,'LineWidth',3) ;%,'Color', 'y');
%set(h_idPP,'LineWidth',2,'Linestyle','-.','Color', '[0 .5 .5]','Marker','v','MarkerSize',8); %'r');

hTitle  = title (sprintf('(Full) PMF example with retailer simulation, %s Network, %4.0f ill cases      .',net_name, num_ill));
%hTitle  = title (sprintf('Variances, %s Network, %s, %0.0f ill     .',net_name, ret_name, num_ill));

hXLabel = xlabel('Source ID');
hYLabel_left = ylabel('probability');
hLegend = legend([bar_pmf_unif, bar_pmf_sampled, bar_pmf_simulated, bar_pmf_const], 'pmf uniform', 'pmf sampled', 'pmf simulated','pmf constructed ob', [100 100 400 375]);
%hLegend = legend([bar_pmf_unif, bar_pmf_simulated, bar_pmf_actual], 'pmf uniform', 'pmf vegetable net','pmf cheese net', [100 100 400 375]);
%hLegend = legend([bar_pmf_unif, bar_pmf_simulated], 'pmf uniform', 'pmf vegetable net', [100 100 400 375]);



set( gca, 'FontName'   , 'Helvetica' );
set([hTitle, hXLabel, hYLabel_left],'FontName'   , 'AvantGarde');
set([hLegend, gca], 'FontName'   , 'AvantGarde' ,'FontSize'   , 14 );
set([hXLabel]  , 'FontSize'   , 16          );
set([hYLabel_left]  , 'FontSize'   , 16          );
set( hTitle  , 'FontSize'   , 18  , 'FontWeight' , 'bold' );
%set(gca, 'Box'  , 'on','XTick', [25:25:150]);
set(gca,'color','none') 

%print -djpeg100 Elena2017/utility/Model_Comparison/Week_of_22May/test_fig

%filename = 'Elena2017/utility/Model_Comparison/Week_of_22May/figs'; % doesn't end with /
%ob_name = 'constructed'
%eval(sprintf(  'print -djpeg100 %s/OB_%s_EHEC_veg_1000ill',filename,ob_name));



%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%
%feas_sources = 402;

%num_feasible = 402;
%feas_sources = 1:num_feasible;

% Contam rets 
ob_data_sim{1,1} = src; %240;
ob_data_sim{1,2} = simulated_ob_4S;

cases_of_illness = num_ill; %[25 77];

ob_data = ob_data_sim;
stage_ends = stage_ends_4S;
prior_pmf; % = ones(1,402);
cases_of_illness = cases_of_illness;

prior_add = 1;
normalize_by_population = 2;
[tb_data_sim] = metrics_fastinv_switch_feasible(1:feas_sources, prior_add, normalize_by_population, ob_data, food_net, 0, stage_ends, prior_pmf(1:feas_sources), cases_of_illness, distances_full, pop, food_net_A);
[tb_data_sim_log] = metrics_fastinv_log_feasible(1:feas_sources,  ob_data, food_net, 0, stage_ends, prior_pmf(1:feas_sources), cases_of_illness, distances_full, pop, food_net_A);

% % Average distance out of top 20 pmf values
sum(tb_data_sim{1, 1}{1, 6}(3,1:cnt))/cnt
sum(tb_data_sim_log{1, 1}{1, 6}(3,1:cnt))/cnt

eval(sprintf('simulated_ob_4S_%s = simulated_ob_4S', net_name));
