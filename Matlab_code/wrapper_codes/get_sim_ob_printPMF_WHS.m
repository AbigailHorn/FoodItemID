%%%%% Remember to update the src node --> currently equal to 285

%% Code to calculate Model Comparison statistics for multiple networks and outbreak datasets

%% Universal

net_index = [2];%[1:2];% 9];% 5:9];%[1 2 3 5 6]; %[1:9];

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
all_net_names{3} = 'sausageTC';
%all_net_names{4} = 'sausageFRO';
%all_net_names{5} = 'oilseeds';
all_net_names{4} = 'cheese';
all_net_names{5} = 'milkProducts';
all_net_names{6} = 'poultry';
% all_net_names{9} = 'vegDry';
%all_net_names{7} = 'milk';
%all_net_names{8} = 'fruit';
% %all_net_names{12} = 'fish';

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
    % As_samp_ob = randsample(As_nonzero_ID, num_ill, true, As(As_nonzero_ID)); % If creating a full random sample over all num_ill weighted by population
    As_samp_ob = randsample(uniq_samp_As, num_ill, true, As_at_uniq); % If creating a random sample from an unweighted sample from the num_uniq
    simulated_ob_4S(s,:) = As_samp_ob + (stage_ends_4S(3));
    simulated_ob_FULL(s,:) = As_samp_ob + (stage_ends_FULL(3));

ob_data_sim{1,1} = src; %240;
ob_data_sim{1,2} = simulated_ob_FULL;
%ob_data_sim{1,3} = 'eggs';
    

%%%%%%%%%
%% Simulated outbreak 2
%%%%%%%%%

% Choose the number of samples
num_samples = 1;

% Generate a set of sources to do outbreak from
s_possible = find(sum(food_net_A(1:402,:),2)>0);  % only start from possible sources
src_list = randsample(s_possible,num_samples,true);

% % For each source i.e. sample, do the following
As_simulated_ob = zeros(num_samples, num_ill);
simulated_ob_FULL_2 = zeros(num_samples, num_ill);
simulated_ob_4S_2 = zeros(num_samples, num_ill);

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
    % As_samp_ob = randsample(As_nonzero_ID, num_ill, true, As(As_nonzero_ID)); % If creating a full random sample over all num_ill weighted by population
    As_samp_ob = randsample(uniq_samp_As, num_ill, true, As_at_uniq); % If creating a random sample from an unweighted sample from the num_uniq
    simulated_ob_4S_2(s,:) = As_samp_ob + (stage_ends_4S(3));
    simulated_ob_FULL_2(s,:) = As_samp_ob + (stage_ends_FULL(3));




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

%%
% sampled_ob_4S_eggs = sampled_ob_4S;
% simulated_ob_4S_eggs = simulated_ob_4S;
% simulated_ob_4S_2_eggs = simulated_ob_4S_2;
% 
% sampled_ob_4S_veg = sampled_ob_4S;
% simulated_ob_4S_veg = simulated_ob_4S;
% simulated_ob_4S_2_veg = simulated_ob_4S_2;
% 
sampled_ob_4S = sampled_ob_4S_eggs;
simulated_ob_4S = simulated_ob_4S_eggs;
simulated_ob_4S_2 = simulated_ob_4S_2_eggs;
% 
% sampled_ob_4S = sampled_ob_4S_veg;
% simulated_ob_4S = simulated_ob_4S_veg;
% simulated_ob_4S_2 = simulated_ob_4S_2_veg;

%% Compute PMFs

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
%[pmf_simulated, ~] = traceback_fastinv_switch_feasible(1:stage_ends(1), prior_add, normalize_by_population, 1, food_net, 1, stage_ends, prior_pmf, contam_reports, 0, 0, 0, 0, 0,pop,A);
[pmf_simulated] = source_traceback_orig_log_feasible_tests(1:feas_sources, food_net_A, stage_ends, prior_pmf, contam_reports,pop);

% % Traceback with actual outbreak
contam_reports = simulated_ob_4S_2; %contam_rets_actual_at_ill;
%[pmf_actual, ~] = time_traceback_April2017_fastinv(1, food_net, 1, stage_ends, prior_pmf, contam_reports, 0, 0, 0, 0, 0,pop,A);
%[pmf_const, ~] = traceback_fastinv_switch_feasible(1:stage_ends(1), prior_add, normalize_by_population, 1, food_net, 1, stage_ends, prior_pmf, contam_reports, 0, 0, 0, 0, 0,pop,A);
[pmf_true] = source_traceback_orig_log_feasible_tests(1:feas_sources, food_net_A, stage_ends, prior_pmf, contam_reports,pop);



%% Plot subplots

fig = figure('Units', 'pixels' , 'Position', [100 100 500 375]);
hold on;
set(0,'DefaultAxesColor','none')

hTitle = title(' True, Sim, Rand pmfs, True Match Network (Vegetables)  ');
%hTitle = title(' True, Sim, Rand pmfs, Non Match Network (Eggs)  ');

ylim_max = .005;

subplot(1,3,1)
bar(pmf_true,'r')
ylim([0 ylim_max])
title('True-PMF')
hXlabel = xlabel('Source ID');
hYlabel = ylabel('probability');
set(gca, 'Box'  , 'on','YTick', [0:1e-3:5e-3]);

subplot(1,3,2)
bar(pmf_sampled,'g')
ylim([0 ylim_max])
title('Rand-PMF')
hXlabel = xlabel('Source ID');
hYlabel = ylabel('probability');
set(gca, 'Box'  , 'on','YTick', [0:1e-3:5e-3]);

subplot(1,3,3)
bar(pmf_simulated,'b')
ylim([0 ylim_max])
title('Sim-PMF')
hXlabel = xlabel('Source ID');
hYlabel = ylabel('probability');

set( gca, 'FontName'   , 'Helvetica' );
% set([hTitle, hXlabel, hYlabel],'FontName'   , 'AvantGarde');
% set([hXLabel, hYlabel]  , 'FontSize'   , 16 , 'FontWeight', 'italic' );
% set( hTitle  , 'FontSize'   , 18  , 'FontWeight' , 'bold' );
% %set(gca, 'Box'  , 'on','XTick', [25:25:150]);
set(gca, 'Box'  , 'on','YTick', [0:1e-3:5e-3]);
% set(gca,'color','none') 

%%%%%

%% Plot pmf code
%%%%%

%%%%% Get rank-ordered versions
nonzeros_samp = size(find(pmf_sampled),2);
nonzeros_sim = size(find(pmf_simulated),2);
nonzeros_true = size(find(pmf_true),2);
num_nonzeros = max(max(nonzeros_true,nonzeros_sim),nonzeros_samp);

pmf_unif = [(1/num_nonzeros)* ones(1,num_nonzeros) zeros(1,(feas_sources-num_nonzeros))];

pmf_sampled_sort = sort(pmf_sampled,'descend');
pmf_simulated_sort = sort(pmf_simulated,'descend');
pmf_true_sort = sort(pmf_true,'descend');

%%%%% Plot 
fig = figure('Units', 'pixels' , 'Position', [100 100 500 375]);
hold on;
set(0,'DefaultAxesColor','none')
bar_pmf_sampled = plot(pmf_sampled_sort); %plot(sort(pmf_sampled,'descend'));
bar_pmf_simulated = plot(pmf_simulated_sort); %plot(sort(pmf_simulated,'descend'));
bar_pmf_true = plot(pmf_true_sort); %plot(sort(pmf_const,'descend'));
bar_pmf_unif = plot(pmf_unif);
%bar_pmf_unif = plot(sort(prior_pmf,'descend'));%plot(pmf_unif);


xlim([0 num_nonzeros])
%ylim([0 .01]) %1e-2])

set(bar_pmf_unif,'LineWidth',3, 'Color', 'black');
set(bar_pmf_sampled,'LineWidth',3,'Color', 'g');
set(bar_pmf_simulated,'LineWidth',3,'Color', 'b');
set(bar_pmf_true,'LineWidth',3,'Color', 'r');
%set(h_idPP,'LineWidth',2,'Linestyle','-.','Color', '[0 .5 .5]','Marker','v','MarkerSize',8); %'r');

hTitle = title(' Ordered pmfs, True Match Network (Vegetables) ');
%hTitle = title(' Ordered pmfs, Non Match Network (Eggs) ');
%hTitle  = title (sprintf('(Full) PMF example with retailer simulation, %s Network, %4.0f ill cases      .',net_name, num_ill));
%hTitle  = title (sprintf('Variances, %s Network, %s, %0.0f ill     .',net_name, ret_name, num_ill));

hXLabel = xlabel('Source ID');
hYLabel_left = ylabel('probability');
hLegend = legend([bar_pmf_unif, bar_pmf_sampled, bar_pmf_simulated, bar_pmf_true], 'Uniform', 'Rand-PMF', 'Sim-PMF','True-PMF', [100 100 400 375]);
%hLegend = legend([bar_pmf_unif, bar_pmf_simulated, bar_pmf_actual], 'pmf uniform', 'pmf vegetable net','pmf cheese net', [100 100 400 375]);
%hLegend = legend([bar_pmf_unif, bar_pmf_simulated], 'pmf uniform', 'pmf vegetable net', [100 100 400 375]);


set( gca, 'FontName'   , 'Helvetica' );
set([hTitle, hXLabel, hYLabel_left],'FontName'   , 'AvantGarde');
set([hLegend, gca], 'FontName'   , 'AvantGarde' ,'FontSize'   , 14 );
set([hXLabel]  , 'FontSize'   , 16          );
set([hYLabel_left]  , 'FontSize'   , 16          );
set( hTitle  , 'FontSize'   , 18  , 'FontWeight' , 'bold' );
set(gca, 'Box'  , 'on','YTick', [0: 0.5e-3 : 5e-3]);
set(gca,'color','none') 

%print -djpeg100 Elena2017/utility/Model_Comparison/Week_of_22May/test_fig

%filename = 'Elena2017/utility/Model_Comparison/Week_of_22May/figs'; % doesn't end with /
%ob_name = 'constructed'
%eval(sprintf(  'print -djpeg100 %s/OB_%s_EHEC_veg_1000ill',filename,ob_name));

%% Plot bar and rank-ordered bar

fig = figure('Units', 'pixels' , 'Position', [100 100 500 375]);
hold on;
set(0,'DefaultAxesColor','none')

hTitle = title(' True, Sim, Rand pmfs, True Match Network (Vegetables)  ');
%hTitle = title(' True-PMF, Non Match Network (Eggs)  ');

ylim_max = .0045;

subplot(2,1,1)
bar(pmf_true,'r')
ylim([0 ylim_max])
title('True-PMF True Match')
hXlabel = xlabel('Source ID');
hYlabel = ylabel('probability');
set(gca, 'Box'  , 'on','YTick', [0:1e-3:5e-3]);

subplot(2,1,2)
bar(pmf_true_sort,'r')
ylim([0 ylim_max])
title('Rank-ordered True-PMF True Match')
hXlabel = xlabel('Source ID');
hYlabel = ylabel('probability');
set(gca, 'Box'  , 'on','YTick', [0:1e-3:5e-3]);

set( gca, 'FontName'   , 'Helvetica' );
% set([hTitle, hXlabel, hYlabel],'FontName'   , 'AvantGarde');
% set([hXLabel, hYlabel]  , 'FontSize'   , 16 , 'FontWeight', 'italic' );
% set( hTitle  , 'FontSize'   , 18  , 'FontWeight' , 'bold' );
% %set(gca, 'Box'  , 'on','XTick', [25:25:150]);
set(gca, 'Box'  , 'on','YTick', [0:1e-3:5e-3]);



%% Compute True-Sig and Rand-Sig

MC_ratio_PUB = MC_ratio_compute(1, pmf_simulated, pmf_sampled)
MC_ratio_actual = MC_ratio_compute(1, pmf_true, pmf_sampled)
SimSig_orig = MC_ratio_actual/MC_ratio_PUB %(MC_ratio_actual(ill,it)-MC_ratio_PUB(ill,it))/MC_ratio_PUB(ill,it); %/MC_ratio_actual(ill,it);
SimSig_new = MC_ratio_actual/max(MC_ratio_PUB, MC_ratio_actual)

MC_ratio_compute(1, [.9 .4 .1], [.1 .9 .4])

KLDiv_2([.9 .1], [.1 .9])
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%
% %feas_sources = 402;
% 
% %num_feasible = 402;
% %feas_sources = 1:num_feasible;
% 
% % Contam rets 
% ob_data_sim{1,1} = src; %240;
% ob_data_sim{1,2} = simulated_ob_4S;
% 
% cases_of_illness = num_ill; %[25 77];
% 
% ob_data = ob_data_sim;
% stage_ends = stage_ends_4S;
% prior_pmf; % = ones(1,402);
% cases_of_illness = cases_of_illness;
% 
% prior_add = 1;
% normalize_by_population = 2;
% [tb_data_sim] = metrics_fastinv_switch_feasible(1:feas_sources, prior_add, normalize_by_population, ob_data, food_net, 0, stage_ends, prior_pmf(1:feas_sources), cases_of_illness, distances_full, pop, food_net_A);
% [tb_data_sim_log] = metrics_fastinv_log_feasible(1:feas_sources,  ob_data, food_net, 0, stage_ends, prior_pmf(1:feas_sources), cases_of_illness, distances_full, pop, food_net_A);
% 
% % % Average distance out of top 20 pmf values
% sum(tb_data_sim{1, 1}{1, 6}(3,1:cnt))/cnt
% sum(tb_data_sim_log{1, 1}{1, 6}(3,1:cnt))/cnt
% 
% eval(sprintf('simulated_ob_4S_%s = simulated_ob_4S', net_name));
