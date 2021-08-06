% prior_pmf can = 0 or = a vector

function [pmf] = source_traceback_log_Aug2019(flows, stage_ends, prior_pmf, contam_reports)

food_net = flows;
% Get A matrix
num_stages = length(stage_ends); % for convenience

 I_t = eye(stage_ends(num_stages-1));
 Q = food_net(1:stage_ends(end-1), 1:stage_ends(end-1));
 A = (I_t - Q)\food_net(1:stage_ends(end-1), stage_ends(end-1)+1:stage_ends(end));

 % identify feasible sources as those which reach a fraction >= P of all contaminated nodes
feasible_sources = 1:stage_ends(1); % initialize to list of all feasible sources

estimator = 1;
pmf = zeros([1, length(feasible_sources)]); % pmf will eventually be row vect of a prob for each potential source
%flows = sparse(flows); % for runtime

switch estimator
    case 1 % exact -- volume only (Markov Chain matrix method)
        vol_pmf = exact_volume_component(feasible_sources, contam_reports, A, stage_ends);
        pmf = vol_pmf; % elementwise multiply
        for s = feasible_sources

            if prior_pmf~=0
                if prior_pmf(s)~=0
                    pmf(s) = pmf(s) + log(prior_pmf(s));
                    pmf(s) = -1/pmf(s);
                elseif prior_pmf(s)==0
                    pmf(s) = 0;
                end
            end
        end
        
end

 %pmf = pmf / sum(pmf); % normalize
 %pmf = pmf.*prior_pmf;
 pmf = pmf / sum(pmf);

end % end function


% Given a list of feasible sources, the volume-flow adjacency matrix, and stage_ends, 
% computes and returns the 'exact volume component' of pmf, as defined by the Markov Chain matrix method
function vol_pmf = exact_volume_component(feasible_sources, contam_reports, A, stage_ends)
    vol_pmf = zeros([1, length(feasible_sources)]);

    num_stages = length(stage_ends); % for convenience
%     I_t = eye(stage_ends(num_stages-1));
%     Q = flows(1:stage_ends(end-1), 1:stage_ends(end-1));
%     A = inv(I_t - Q)*flows(1:stage_ends(end-1), stage_ends(end-1)+1:stage_ends(end));
    
    for s = feasible_sources
        diff_traj_likelihood = 0; % multiply all path probabilities together onto this variable       
        for node_ID = contam_reports(1, :)
%nodeid = node_ID
%nodeid_minus_stageends3 = node_ID - stage_ends(3)

           path_likelihood = A(s, node_ID-stage_ends(end-1));

%            %%%%%%%% Normalize by population %%%%%%%%  
%            region_ID = node_ID - stage_ends(num_stages-1);
%            path_likelihood = path_likelihood./(pop(region_ID));
%            %%%%%%%%
            
            if path_likelihood==0% likelihood that the current observation started at s, summed over all possible paths
               path_likelihood = .000001;
            end
%             if path_likelihood~=0
            diff_traj_likelihood = diff_traj_likelihood + log(path_likelihood);
%             end
            % probability of source s generating the whole collection of reports
        end % end for
        vol_pmf(s) = diff_traj_likelihood;
    end 
end

% % node_set = array of node IDs that we are querying for the overall set of ancestors of. Assumed to all be in same stage.
% % flows = the adjacency matrix
% % prents = an array containing all the IDs of parents of node_set
% function prents = parents(node_set, flows)
%     prents = [];
%     for j = 1:length(node_set)
%         prents = union(prents, find(flows(:, node_set(j)))); % find each node that leads into nodes in j
%         [r, c] = size(prents);
%         if r > c % make sure it comes out as a row vector
%             prents = prents.';
%         end % end if
%     end % end for
% end % end ancestors
% EDIT I'M TESTING
