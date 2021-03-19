%%%%%PLOT COMPUTE SIGNAL SIM RLG -- just need to update the one line

function [net_MC_means, net_MC_CI95] = plot_compute_signal_PUB_RLG_SimSigRawJan2020(all_food_nets, all_net_names, init_vals, stage_ends, all_ob_data, all_ob_names, ill_over_time_interval, MC_method, num_samples, dpr_flag, save_plot)

num_food_nets = size(all_food_nets,1);
num_ob = size(all_ob_data,1);
num_feasible = stage_ends(1);

% can set MC method to run through all 4 or just one
if MC_method == 0
    method_index = 1:5;
else
    method_index = MC_method;
end
num_methods = size(method_index,2);

num_time_points = size(ill_over_time_interval,2);

ob_index = 1:num_ob;

% Setting up nested data structures
nested_net_data = cell(num_food_nets,1);
nested_method_data = cell(num_methods, 1);
nested_ob_data = cell(num_ob, 1);

for ob_i = ob_index
    ob_name = all_ob_names{ob_i};
    contam_rets_actual = all_ob_data{ob_i};  % Get the outbreak data
    
    net_index = 1:num_food_nets;
    
    
    for method_i = method_index
        
        %[UB,LB] = UB_LB_compute(method_i, stage_ends);
        
        net_MC_means = zeros(num_time_points,num_food_nets);
        net_MC_CI95 = zeros(num_time_points,num_food_nets);
        
        for net_i = net_index %num_food_nets
            net_i
            net_name = all_net_names{net_i};
            food_net = all_food_nets{net_i};
            %food_net_A = all_food_nets_A{net_i};
            
            if init_vals~=0
                prior_pmf = init_vals(net_i);
            else
                prior_pmf = 0;
            end

            %% Calculate Model Comparison Statistics
            
            %%%%% Choose which method: random sampling or dpr
            if dpr_flag == 0
                %%% Using Outbreak Random Sampling
                %[MC_ratio] = KLD_AOC_MSE_RLG_Aug2019(method_i, food_net, stage_ends, prior_pmf, contam_rets_actual, num_samples, ill_over_time_interval);
                %[MC_ratio] = MC_compute_randOb_Oct2019(method_i, food_net, stage_ends, prior_pmf, contam_rets_actual, num_samples, ill_over_time_interval);
                %[MC_ratio] = MC_compute_SIMob_RLG(method_i, food_net, stage_ends, prior_pmf, contam_rets_actual, num_samples, ill_over_time_interval);
                [~, SimSig_ratio, MC_ratio_actual] = MC_compute_PracticalUB_RLG(method_i, food_net, stage_ends, prior_pmf, contam_rets_actual, num_samples, ill_over_time_interval);

                
            else
                %%% Using Degree Preserving Randomization
                %[MC_ratio] = MC_compute_DPR_Aug2019(method_i, food_net, stage_ends, prior_pmf, contam_rets_actual, num_samples, ill_over_time_interval);
                %[MC_ratio] = MC_compute_DPR_Oct2019(method_i, food_net, stage_ends, prior_pmf, contam_rets_actual, num_samples, ill_over_time_interval);
                %[MC_ratio] = MC_compute_DPR_Oct2019_Germany(method_i, food_net, stage_ends, prior_pmf, contam_rets_actual, num_samples, ill_over_time_interval);
                %[MC_ratio] = MC_compute_DPR_Dec2019_Germany(method_i, food_net, food_net_A, stage_ends, prior_pmf, contam_rets_actual, num_samples, ill_over_time_interval);
                [~, SimSig_ratio, MC_ratio_actual] = MC_compute_DPR_PractialUB_RLG(method_i, food_net, stage_ends, prior_pmf, contam_rets_actual, num_samples, ill_over_time_interval);

            end
            
          
            
            %% Filenaming MC_ratio for output
            
            nested_net_data{net_i,1} = MC_ratio_actual;
            
            % eval(sprintf(  'DataOut_OB%s_method%0.0f_norm%s = MC_ratio',ob_name,method_i,normalize));
            
            
            %% Mean MC_ratio
            %mean_MC_ratio_PUB = mean(MC_ratio_PUB,2);
            mean_MC_ratio_actual = mean(MC_ratio_actual,2);
            mean_MC_ratio_SimSig = mean(SimSig_ratio,2);

            
            % put the results for this network in to the matrix of net_MC_means
            %net_MC_means_PUB(:,net_i) = mean_MC_ratio_PUB;
            %net_MC_means_actual(:,net_i) = mean_MC_ratio_actual;

            
            
            %% 95% CI MC_ratio
            y = MC_ratio_SimSig.'; %randn(50,100);                                  % Create Dependent Variable ?Experiments? Data
            N = size(y,1);                                      % Number of ?Experiments? In Data Set
            yMean = mean(y);                                    % Mean Of All Experiments At Each Value Of ?x?
            ySEM = std(y)/sqrt(N);                              % Compute ?Standard Error Of The Mean? Of All Experiments At Each Value Of ?x?
            CI95 = tinv([0.025 0.975], N-1);                    % Calculate 95% Probability Intervals Of t-Distribution
            yCI95 = bsxfun(@times, ySEM, CI95(:));              % Calculate 95% Confidence Intervals Of All Experiments At Each Value Of ?x?
            % put result into matrix
            net_MC_CI95_SimSig(:,net_i) = yCI95(2,:);

            y = MC_ratio_actual.'; %randn(50,100);                                  % Create Dependent Variable ?Experiments? Data
            N = size(y,1);                                      % Number of ?Experiments? In Data Set
            yMean = mean(y);                                    % Mean Of All Experiments At Each Value Of ?x?
            ySEM = std(y)/sqrt(N);                              % Compute ?Standard Error Of The Mean? Of All Experiments At Each Value Of ?x?
            CI95 = tinv([0.025 0.975], N-1);                    % Calculate 95% Probability Intervals Of t-Distribution
            yCI95 = bsxfun(@times, ySEM, CI95(:));              % Calculate 95% Confidence Intervals Of All Experiments At Each Value Of ?x?
            % put result into matrix
            net_MC_CI95_actual(:,net_i) = yCI95(2,:);
            

        end %over net_i
        
        %nested_method_data{method_i,1} = nested_net_data;
        
        %plot_MC_means(ob_name, all_net_names, method_i, num_samples, net_MC_means, ill_over_time_interval, dpr_flag, save_plot);
        %plot_MC_CI95(ob_name, all_net_names, method_i, num_samples, net_MC_means, net_MC_CI95, ill_over_time_interval, dpr_flag, save_plot);
        %plot_MC_CI95_UB_LB(UB,LB,ob_name, all_net_names, method_i, num_samples, net_MC_means, net_MC_CI95, ill_over_time_interval, dpr_flag, save_plot);
        %plot_MC_SIMob_compare(ob_name, all_net_names, method_i, num_samples, net_MC_means, net_MC_CI95, ill_over_time_interval, dpr_flag, save_plot)
        plot_MC_CI95_PUB_actual(ob_name, all_net_names, method_i, num_samples, net_MC_means_SimSig, net_MC_CI95_SimSig, net_MC_means_actual, net_MC_CI95_actual, ill_over_time_interval, dpr_flag, save_plot)

        
        
%         filename = 'Elena2017/utility/Model_Comparison/0_2019S/figures'; % doesn't end with /
%         eval(sprintf(  'print -djpeg100 %s/OB_%s/method%0.0f',filename,ob_name,method_i));
            
    end %over method_i
    
    nested_ob_data{ob_i,1} = nested_method_data;
    
end %over plotId

end %over ob_i
