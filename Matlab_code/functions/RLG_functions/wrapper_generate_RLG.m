
%% Generate network and essential parameters

% Set parameters
avg_deg = 3; 
node_counts = [100 100 100 100];   %[100 100 100 100]; % formerly n1
init_vol_dist = 'determ';
num_stages = length(node_counts);

network_params = cell(num_stages - 1, 4);
network_params(1, :) = {avg_deg, 'out', 'geo', 'geo'};
network_params(2, :) = {avg_deg, 'out', 'geo', 'geo'};
network_params(3, :) = {avg_deg, 'out', 'geo', 'geo'};

% network_params(1, :) = {avg_deg, 'out', 'identical', 'identical'};
% network_params(2, :) = {avg_deg, 'out', 'identical', 'identical'};
% network_params(3, :) = {avg_deg, 'out', 'identical', 'identical'};

n1 = node_counts(1);
show_plots = false;
display_network = false;

% Create network linkages
[trueNet, node_layers, init_vols, stage_ends] = random_layered_graph(node_counts, init_vol_dist, ...
    network_params, show_plots, display_network);

[rand2, node_layers, init_vols, stage_ends] = random_layered_graph(node_counts, init_vol_dist, ...
    network_params, show_plots, display_network);

[rand3, node_layers, init_vols, stage_ends] = random_layered_graph(node_counts, init_vol_dist, ...
    network_params, show_plots, display_network);

[rand4, node_layers, init_vols, stage_ends] = random_layered_graph(node_counts, init_vol_dist, ...
    network_params, show_plots, display_network);

[rand5, node_layers, init_vols, stage_ends] = random_layered_graph(node_counts, init_vol_dist, ...
    network_params, show_plots, display_network);

[rand6, node_layers, init_vols, stage_ends] = random_layered_graph(node_counts, init_vol_dist, ...
    network_params, show_plots, display_network);

[rand7, node_layers, init_vols, stage_ends] = random_layered_graph(node_counts, init_vol_dist, ...
    network_params, show_plots, display_network);

%trueNet = flows;
%rand2 = flows;
%rand3=flows;
%rand4=flows;
%rand5=flows;

% Assign network locations
show_loc_plots = false;
[dists, node_locs] = assign_locations(node_layers, flows, show_loc_plots);
%[~, dists, node_locs] = assign_distances_FR(node_layers, flows, false);

%% Simulate outbreak

% Set up parameters to simulate a deterministic outbreak
dispersion = 'max';
src_farm = -1; 
%num_stages = 4;
return_all_reports = true;
plot_or_not = false;
transport_dev_frac = .25; % setting this number between 0 and 1 changes stochasticity of outbreak (0 is deterministic)
storage_dev_frac = .25; % true is deterministic, false isn't

% Simulate outbreak
[contam_farm, contam_reports] = outbreak_Nov2017(dispersion, src_farm, dists, ...
    node_locs, flows, init_vols, num_stages, return_all_reports, ...
    plot_or_not, transport_dev_frac, storage_dev_frac);

% Sort reports by time
contam_reports = (sortrows(contam_reports.',2)).';

%% Run source identification

% Choose which slice in time to do source identification
cases_of_illness = 100;
contam_reps = contam_reports(:,[1:cases_of_illness]); %[1 2 5 10 14 16 22 44 63]);  %60:65); % [29 43 90 91]);

% Run source identification
[pmf] = source_traceback_orig(flows, stage_ends, init_vols, contam_reps, 1);
%[pmf_rand] = source_traceback_orig(flows, stage_ends, init_vols, contam_reps_rand, 1);

pmf(find(pmf~=0))
pmf(contam_farm)

%pmf_rand(find(pmf_rand~=0))
%pmf_rand(contam_farm)

csvwrite('Elena2017/utility/Nov2017/example_data/homogeneous.dat', flows_determ_6nodes_4deg);
csvwrite('Elena2017/utility/Nov2017/example_data/heterogeneous.dat', flows_geo_6nodes_4deg_best);


% Write to csv
csvwrite('Elena2017/utility/Nov2017/example_data/flows6.dat', flows);
csvwrite('Elena2017/utility/Nov2017/example_data/true_source6.dat', contam_farm);
csvwrite('Elena2017/utility/Nov2017/example_data/contam_reps6.dat', contam_reps);
pmf_list = [1:n1; pmf];
csvwrite('Elena2017/utility/Nov2017/example_data/pmf6.dat', pmf_list);


%% Generate multiple outbreaks, trace them back, and get metrics

% Choose number of iterations
outbreaks = 2;

% Generate outbreaks
ob_data = outbreak_iterations_RLG(n1, outbreaks, dists, node_locs, flows, init_vols, num_stages, transport_dev_frac, storage_dev_frac);

% Choose which slice(s) in time to do source identification
cases_of_illness = [50 100];

% Run source identification and get metrics
[tb_data] = metrics_RLG_Nov2017(node_locs, cases_of_illness, ob_data, flows, stage_ends, init_vols);
[metrics_RLG] = mean_metrics_RLG_Nov2017(tb_data);
