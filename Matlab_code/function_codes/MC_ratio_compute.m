%% Compute Model Comparison Metrics for distance and ratios between distributions

function [MC_ratio] = MC_ratio_compute(MC_method,pmf_actual, pmf_rand)

pmf_actual_sort = sort(pmf_actual,'descend');
pmf_rand_sort = sort(pmf_rand,'descend');

%1 KLD
if MC_method == 1
    MC_ratio = KLDiv_2(pmf_actual_sort, pmf_rand_sort);

%2 Hellinger Distance
elseif MC_method == 2
    MC_ratio = sum((sqrt(pmf_actual_sort) - sqrt(pmf_rand_sort)).^2);

%3 MSE
elseif MC_method == 3
    MC_ratio = mean((pmf_actual_sort - pmf_rand_sort).^2);

%4 Entropy
elseif MC_method == 4
    
    entp_actual_pre = info_entropy(pmf_actual_sort,'bit');
    if entp_actual_pre == 0
        entp_actual_pre = .0000001;
    end
    entp_actual = 1/entp_actual_pre;
    
    entp_rand_pre = info_entropy(pmf_rand_sort,'bit');
    if entp_rand_pre == 0
        entp_rand_pre = .0000001;
    end
    
    entp_rand = 1/entp_rand_pre;
    
    MC_ratio = (entp_actual - entp_rand) / entp_rand;

%5 Variance
elseif MC_method == 5
    var_actual = var(pmf_actual_sort);
    var_samp = var(pmf_rand_sort);
    MC_ratio = (var_actual - var_samp)/ var_samp;
end



function dist=KLDiv_2(P,Q)
%  dist = KLDiv(P,Q) Kullback-Leibler divergence of two discrete probability
%  distributions
%  P and Q  are automatically normalised to have the sum of one on rows
% have the length of one at each 
% P =  n x nbins
% Q =  1 x nbins or n x nbins(one to one)
% dist = n x 1



if size(P,2)~=size(Q,2)
    error('the number of columns in P and Q should be the same');
end

if sum(~isfinite(P(:))) + sum(~isfinite(Q(:)))
   error('the inputs contain non-finite values!') 
end

% normalizing the P and Q
if size(Q,1)==1
    Q = Q ./sum(Q);
    P = P ./repmat(sum(P,2),[1 size(P,2)]);
    temp =  P.*log(P./repmat(Q,[size(P,1) 1]));
    temp(isnan(temp))=0;% resolving the case when P(i)==0
    dist = sum(temp,2);
    
    
elseif size(Q,1)==size(P,1)
    
    Q = Q ./repmat(sum(Q,2),[1 size(Q,2)]);
    P = P ./repmat(sum(P,2),[1 size(P,2)]);
    temp =  P.*log(P./Q);
    temp(isnan(temp))=0; % resolving the case when P(i)==0
    dist = sum(temp,2);
end