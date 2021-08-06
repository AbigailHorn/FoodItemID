function [ACC_1, ACC_2, rank_original, Sig_star, Sig_star_hat] = metrics_MC_brute(net_MC_means, ill_it, current_ob_src_net)

[~, idx] = sort(net_MC_means,2,'descend');
    Sig_star = net_MC_means(:,current_ob_src_net);
    
    for ill = 1:ill_it
        
        rank_original(ill) = find(idx(ill,:) == current_ob_src_net);
        
        if rank_original(ill) == 1
            ACC_1(ill) = 1;
        else
            ACC_1(ill) = 0;
        end
        
        if rank_original(ill) < 3
            ACC_2(ill) = 1;
        else
            ACC_2(ill) = 0;
        end
        
        Sig_hat(ill) = net_MC_means(ill,idx(ill,1));
        
        Sig_star_hat(ill) = Sig_star(ill)/(Sig_hat(ill));
        
    end % over ill
    
end % end function