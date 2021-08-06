%% Code to calculate Model Comparison statistics for multiple networks and outbreak datasets

%% Input data

%% Specify global parameters
stage_ends = [100 200 300 400]; %stage_ends_RN; % = [1000 11000 21000 22000];  %[100 200 300 400]; %[25 50 75 100];% = [500 1000 1500 2000]; %[10 20 30 40]; 
n1 = stage_ends(1);
n_last = stage_ends(end) - stage_ends(end-1);
prior_pmf = (1/n1)*ones(1,n1);

%%%%%%%%%
% % Specify number of contaminated nodes
%%%%%%%%%
num_uniq = 50; %30; 
num_ill = 500; %500;

% % Number of illnesses to traceback at:
cases_of_illness = 500; % 500; %[10 20]; %[50 100]; %num_ill; %[50 100 150];

%%%%%%%%%
% % Specify network
%%%%%%%%%
food_net = trueNet;
%food_net = networks{1,1};

%% Testing appropriateness of network
%food_net_orig = flows3;
%size(find(food_net_orig~=0))
randT = 1;
%find(food_net(randT,:))
food_net(randT,find(food_net(randT,:))) % to find the outgoing links for stage randT and make sure they add to 1

% Count links in the network - randomized should be similar to original
size(find(food_net~=0))

% Make sure rows add to 1
%sum_test = sum(food_net,2);

%% Create stochastic A matrix from flows matrix
num_stages = length(stage_ends); % for convenience
 I_t = eye(stage_ends(num_stages-1));
 Q = food_net(1:stage_ends(end-1), 1:stage_ends(end-1));
 A = (I_t - Q)\food_net(1:stage_ends(end-1), stage_ends(end-1)+1:stage_ends(end));

food_net_A = A;

% % Testing stochasticness of A matrix 
A_outgoing_sum = sum(food_net_A(1:n1,:),2);
[A_outgoing_sort, idx] = sortrows(A_outgoing_sum,-1);              

%%%%%%%%%
%% Identifying highest prior probability sources
%%%%%%%%%
%rank_of_src_in_prior = 1;
%ref_node = 240;     %240 for Munchen
%[prior_pmf_sort, idx] = sortrows(prior_pmf(1:n1).',-1);              
%prior_pmf_dist = distances_full(ref_node,idx);
%prior_pmf_vals = [idx, prior_pmf_sort, prior_pmf_dist.'];
%src = idx(rank_of_src_in_prior); % 60 is top probability node for eggs %177 is top for vegetables;

%%%%%%%%%
%% Constructed outbreak -- this is an outbreak that samples illnesses only from the N top highest probability nodes connected to a chosen source node
%%%%%%%%%

% Source to do outbreak from
s_possible = find(sum(food_net_A(1:n1,:),2)>0);  % only start from possible sources
src = randsample(s_possible,1,true);
%src = contam_farm;

As = food_net_A(src,:); % V from src to absorbing nodes
As_nonzero_ID = find(As);  % Find the connected retailers to s
As_nonzero_num = size(As_nonzero_ID,2); % How many retailers connected to s

[As_sort, idx] = sortrows(As.',-1);      % Sorted by top connected notes to src        
As_ranked = [idx, As_sort];

uniq_samp_const = [];
uniq_samp_const = idx(1:num_uniq); % + (stage_ends(num_stages-1))).';
As_at_uniq = As(uniq_samp_const);

As_const_ob = [];

%As_sim_ob = [randsample(uniq_samp_As.', num_ill - num_uniq_As, true, As_at_uniq.') uniq_samp_As.'];
%As_sim_ob = [(fliplr(uniq_samp_As)).' randsample(uniq_samp_As.', num_ill, true, As_at_uniq.')];

As_const_ob = [randsample(uniq_samp_const.', num_ill, true, As_at_uniq.')];  % Weighted random sample with replacement

%%%%% Putting it in the right format for identification
const_ob = [];
const_ob = As_const_ob + (stage_ends(num_stages-1));


%%%%%%%%
%% TB WITH CONSTRUCTED OUTBREAK
%%%%%%%%

num_feasible = n1;
feas_sources = 1:num_feasible;

% Contam rets 
ob_data_const{1,1} = src;
ob_data_const{1,2} = const_ob;

ob_data = ob_data_const;
food_net;
stage_ends;
prior_pmf;
cases_of_illness;
food_net_A;

[tb_data] = metrics_RLG_Aug2019_NoLocs(cases_of_illness, ob_data, food_net, stage_ends, prior_pmf);
[metrics_RLG] = mean_metrics_RLG_Aug2019(tb_data);

contam_reports = const_ob; %sampled_ob_FULL_GOOD_SAVE_1000_EHEC; %sampled_ob_FULL;
[pmf_const] = source_traceback_log_Aug2019(food_net, stage_ends, prior_pmf, contam_reports);
%plot_pmf_const = plot(pmf_const); %plot(sort(pmf_const,'descend'));

% pmf_const_sort = sort(pmf_const,'descend');
% line_pmf_const = plot(pmf_const_sort); %plot(sort(pmf_const,'descend'));
% 
% nonzeros_const = size(find(pmf_const),2);
% pmf_unif = (1/nonzeros_const)*ones(1,nonzeros_const);

% hold on;
% line_pmf_unif = plot(pmf_unif);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%
%% Simulated outbreak -- chooses num_uniq contaminated nodes at random from those that are connected to source node s, then samples from those according to their probabilities of being connected to s
%%%%%%%%%

% Source to do outbreak from
s_possible = find(sum(food_net_A(1:n1,:),2)>0);  % only start from possible sources
src = randsample(s_possible,1,true);
%src = contam_farm;

As = food_net_A(src,:); % V from src to absorbing nodes
As_nonzero_ID = find(As);  % Find the connected retailers to s
As_nonzero_num = size(As_nonzero_ID,2); % How many retailers connected to s

[As_sort, idx] = sortrows(As.',-1);      % Sorted by top connected notes to src        
As_ranked = [idx, As_sort];

uniq_samp_sim = [];
As_sim_ob = [];
%As_sim_ob = randsample(uniq_samp_As.', num_ill, true, As_at_uniq.');
    
if As_nonzero_num > num_uniq    % If there are enough connected retailers connected to s to replicate the number of unique values in the actual ob data
    uniq_samp_sim = randsample(As_nonzero_ID, num_uniq, false)  % Randomly sample a set of num_uniq connected retailers
    num_uniq_As = num_uniq;  % We can sample the same number of unique as in actual ob data at this num_ill
else
    uniq_samp_sim = As_nonzero_ID   % If there are not enough connected retailers to replicate the number of unique values in the acutal ob data
    num_uniq_As = As_nonzero_num;   % Just set the unique sample to all connected retailers
end

As_at_uniq = As(uniq_samp_sim);
As_sim_ob = randsample(uniq_samp_sim, num_ill, true, As_at_uniq);

%%%%% Putting it in the right format for identification
sim_ob = [];
sim_ob = As_sim_ob + (stage_ends(num_stages-1));


%%%%%%%%
%% TB WITH SIMULATED OUTBREAK
%%%%%%%%

num_feasible = n_last;
feas_sources = 1:num_feasible;

% Contam rets 
ob_data_sim{1,1} = src;
ob_data_sim{1,2} = sim_ob;

ob_data = ob_data_sim;
food_net;
stage_ends;
prior_pmf;
cases_of_illness;
food_net_A;

[tb_data_sim] = metrics_RLG_Aug2019_NoLocs(cases_of_illness, ob_data, food_net, stage_ends, prior_pmf);
[metrics_RLG_sim] = mean_metrics_RLG_Aug2019(tb_data_sim);

contam_reports = sim_ob; %sampled_ob_FULL_GOOD_SAVE_1000_EHEC; %sampled_ob_FULL;
[pmf_sim] = source_traceback_log_Aug2019(food_net, stage_ends, prior_pmf, contam_reports);
%plot_pmf_const = plot(pmf_const); %plot(sort(pmf_const,'descend'));

% pmf_sim_sort = sort(pmf_sim,'descend');
% hold on;
% line_pmf_sim = plot(pmf_sim_sort, 'r'); %plot(sort(pmf_const,'descend'));
% 
% nonzeros_sim = size(find(pmf_sim),2);
% pmf_unif = (1/nonzeros_sim)*ones(1,nonzeros_sim);
% %hold on;
% %line_pmf_unif = plot(pmf_unif);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%
%% Randomly sampled outbreak
% Get a distribution of samples with the same number of unique nodes as the original set of observations
%%%%%%%%%

sampled_ob = [];

unique_sample = randsample(1:n1,num_uniq,false);
As_samp_ob = randsample(unique_sample, num_ill, true);  % Weighted random sample with replacement
samp_ob = As_samp_ob + (stage_ends(num_stages-1));

%%%%%%%%
%% TB WITH RANDOMLY SAMPLED OUTBREAK
%%%%%%%%

num_feasible = n1;
feas_sources = 1:num_feasible;

% Contam rets 
ob_data_samp{1,1} = src;
ob_data_samp{1,2} = samp_ob;

ob_data = ob_data_samp;
food_net;
stage_ends;
prior_pmf;
cases_of_illness;
food_net_A;

[tb_data_sim] = metrics_RLG_Aug2019_NoLocs(cases_of_illness, ob_data, food_net, stage_ends, prior_pmf);
[metrics_RLG_sim] = mean_metrics_RLG_Aug2019(tb_data_sim);

contam_reports = samp_ob; %sampled_ob_FULL_GOOD_SAVE_1000_EHEC; %sampled_ob_FULL;
[pmf_samp] = source_traceback_log_Aug2019(food_net, stage_ends, prior_pmf, contam_reports);
%plot_pmf_const = plot(pmf_const);

% pmf_samp_sort = sort(pmf_samp,'descend');
% hold on;
% line_pmf_samp = plot(pmf_samp_sort, 'g'); %plot(sort(pmf_const,'descend'));

%nonzeros_samp = size(find(pmf_samp),2);
%pmf_unif = (1/nonzeros_samp)*ones(1,nonzeros_samp);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Plotting
%%%%%%%%%

contam_reports = const_ob; %sampled_ob_FULL_GOOD_SAVE_1000_EHEC; %sampled_ob_FULL;
[pmf_const] = source_traceback_log_Aug2019(food_net, stage_ends, prior_pmf, contam_reports);

contam_reports = sim_ob; %sampled_ob_FULL_GOOD_SAVE_1000_EHEC; %sampled_ob_FULL;
[pmf_sim] = source_traceback_log_Aug2019(food_net, stage_ends, prior_pmf, contam_reports);

contam_reports = samp_ob; %sampled_ob_FULL_GOOD_SAVE_1000_EHEC; %sampled_ob_FULL;
[pmf_samp] = source_traceback_log_Aug2019(food_net, stage_ends, prior_pmf, contam_reports);


nonzeros_const = size(find(pmf_const),2);
nonzeros_samp = size(find(pmf_samp),2);
nonzeros_sim = size(find(pmf_sim),2);
num_nonzeros = max(max(nonzeros_const,nonzeros_sim),nonzeros_samp);

pmf_unif = [(1/num_nonzeros)* ones(1,num_nonzeros) zeros(1,(num_feasible-num_nonzeros))];

pmf_const_sort = sort(pmf_const,'descend');
pmf_samp_sort = sort(pmf_samp,'descend');
pmf_sim_sort = sort(pmf_sim,'descend');

pmf_const_sort = pmf_const_sort(1:num_nonzeros);
pmf_samp_sort = pmf_samp_sort(1:num_nonzeros);
pmf_sim_sort = pmf_sim_sort(1:num_nonzeros);



%% Plot pmf code
%%%%%

fig = figure('Units', 'pixels' , 'Position', [100 100 500 375]);
hold on;
set(0,'DefaultAxesColor','none')
bar_pmf_samp = plot(pmf_samp_sort); %plot(sort(pmf_sampled,'descend'));
bar_pmf_const = plot(pmf_const_sort); %plot(sort(pmf_const,'descend'));
bar_pmf_sim = plot(pmf_sim_sort);
bar_pmf_unif = plot(pmf_unif);

xlim([1 num_nonzeros])
%ylim([0 .01]) %1e-2])

set(bar_pmf_sim,'LineWidth',3,'Color','g');
set(bar_pmf_samp,'LineWidth',3,'Color', 'b');
set(bar_pmf_const,'LineWidth',3,'Color', 'r');
set(bar_pmf_unif,'LineWidth',3,'Color','y');

%set(h_idPP,'LineWidth',2,'Linestyle','-.','Color', '[0 .5 .5]','Marker','v','MarkerSize',8); %'r');

hTitle  = title (sprintf('TB PMFs: Const; Sim; Samp OB, %4.0f ill cases', num_ill));

hXLabel = xlabel('Source ID');
hYLabel_left = ylabel('probability');
hLegend = legend([bar_pmf_const, bar_pmf_sim, bar_pmf_samp], 'pmf const', 'pmf sim','pmf samp', [100 100 400 375]);
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


%%%%%%%%%%%%
%%%%%%%%%%%%
%%%%%%%%%%%%
%%%%%%%%%%%%

sim_ob_RLG = sim_ob;
const_ob_RLG = const_ob;
samp_ob_RLG = samp_ob;
