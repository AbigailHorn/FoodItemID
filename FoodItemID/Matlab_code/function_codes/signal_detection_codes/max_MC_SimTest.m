
function [INTxOB] = max_MC_SimTest(means_mat, ill_it, current_ob_src_net, ob_i)

[~, I_max] = max(means_mat, [], 2);

for ill = 1:ill_it
    if I_max(ill) == current_ob_src_net
        INTxOB(ill,ob_i) = 1
    else
        INTxOB(ill,ob_i) = 0
    end
    
end

end