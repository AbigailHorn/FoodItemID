
%write_baseline_csv(nested_ob_data, num_food_nets, all_net_names, num_samples, ill_over_time_interval, foldername, sim_flag, net_type)

function [] = write_baseline_csv(nested_ob_data, num_food_nets, all_net_names, num_samples, ill_over_time_interval, foldername, sim_flag, net_type)

nested_out = nested_ob_data{1, 1}{1, 1};
nested_out = cat(1,nested_out{:});

ill_it = length(ill_over_time_interval);

net_idx = [];
for k=1:num_food_nets
    net_idx_current = repmat({all_net_names{k}},1,ill_it);
    net_idx_current = string(cat(1,net_idx_current{:}));
    net_idx = [net_idx; net_idx_current];
end

num_ill = repmat(ill_over_time_interval,1,num_food_nets)';
%iter = ["net_name", "num_ill", compose("iter.%d", 1:num_samples)];

%nested_out_named = [net_idx, num_ill, nested_out];
%nested_out_named = [iter; nested_out_named];

nested_out_colnames = [net_idx, num_ill];

%foldername = '/Users/abigailhorn/Dropbox/MATLAB/Elena2017/utility/Model_Comparison/0_Dec2020/Results/BaselineSig_out';
%net_type = 'Germany_WHS';

if sim_flag==0
    sim_samp = "Samp";
else
    sim_samp = "Simul";
end

filename = sprintf('%s/BaselineSig_%s_%s.csv',foldername,net_type,sim_samp);

%writematrix(nested_out_named, filename);
writematrix(nested_out_colnames, filename);
%dlmwrite(filename, net_idx,'delimiter', ',');
dlmwrite(filename, nested_out, '-append','coffset',2,'delimiter', ',', 'precision', 8);

%dlmwrite(filename, nested_out, 'delimiter', ',', 'precision', 8);
%fclose('all');


end 

