%% Workflow multiple signal detection with stylized networks
% * Input parameters and data
% * Simulate outbreaks
% * Signal detection + decision algorithm
% * All results saved in cell
% * Metric results
%     * Marcel?s algorithm
%     * Is true network in 1st position at each #ill ([0,1])
%     * In first 3 positions
%     * Rank of true network over all

num_ob = 1;
num_samples = 100;
num_nets = 12;
num_ill_interval = size(nested_ob_data{ob,1}{method_i,1}{net_i,1},1);

MEANxOBxILL = [];
METRICSxSAMPLE = [];

for ill_it = num_ill_interval
    
    
    for ob_i = 1:num_ob
        
        for samp_i = 1:num_samples
            
            for net_i = 1:num_nets
                SAMPLExNET(:,net_i) = nested_ob_data{ob,1}{method_i,1}{net_i,1}(ill_it,samp_i);
            end %net_i
            
            METRICSxSAMPLE_i = mean(SAMPLExNET,2);
            
            METRICSxSAMPLE = [METRICSxSAMPLE; METRICSxSAMPLE_i];
            
        end %num_samples
        
    end %ob_i
    
    MEANxOB = mean(METRICSxSAMPLE,1);
    MEANxOBxILL = [MEANxOBxILL; MEANxOB];
    
end %ill_it

