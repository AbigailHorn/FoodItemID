function [net_SimSig_means, net_raw_means] = plot_compute_signal_OB_SIM_METRICS_RLG_SimSig(all_food_nets, init_vals, stage_ends, current_ob_data, ill_over_time_interval, method_i, num_samples, dpr_flag)


num_food_nets = size(all_food_nets,1);

num_time_points = size(ill_over_time_interval,2);
    
    net_index = 1:num_food_nets;
                    
        net_SimSig_means = zeros(num_time_points,num_food_nets);
        net_raw_means = zeros(num_time_points,num_food_nets);
        
        for net_i = net_index %num_food_nets
            net_i
            
            food_net = all_food_nets{net_i};

            if init_vals~=0
                prior_pmf = init_vals{net_i};
            else
                prior_pmf = 0;
            end

            %% Calculate Model Comparison Statistics
            
            %%%%% Choose which method: random sampling or dpr
            if dpr_flag == 0
                 %%% NOTE: Use this when NOT normalizing by an already-computed SigStar
                 %[~, MC_SimSig, MC_raw] = SimSig_L3_OB_RLG(method_i, food_net, stage_ends, prior_pmf, current_ob_data, num_samples, ill_over_time_interval);
                
                 %%% NOTE: Use this WHEN normalizing by an already-computed SigStar
                 [~, MC_SimSig, MC_raw] = SimSig_L3_OB_RLG(method_i, food_net, stage_ends, prior_pmf, current_ob_data, num_samples, ill_over_time_interval);

                 
            else
                %%% Using Degree Preserving Randomization
                [~, MC_SimSig, MC_raw] = MC_compute_DPR_PractialUB_RLG(method_i, food_net, stage_ends, prior_pmf, current_ob_data, num_samples, ill_over_time_interval);

             %%%%%
             %%%%% NOTE: Use MC_compute_DPR_Oct2019 when going for brute
             %%%%% force least efficient but accurate way across full networks
             %%%%%
                
            end
                   
            
            %% Mean MC_ratio
            mean_MC_SimSig = mean(MC_SimSig,2);
            mean_MC_raw = mean(MC_raw,2);
            
            % put the results for this network in to the matrix of net_MC_means
            net_SimSig_means(:,net_i) = mean_MC_SimSig;
            net_raw_means(:,net_i) = mean_MC_raw;


        end %over net_i
                
           
    %end %over method_i
        

end %over function
