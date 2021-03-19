function [Figure] = plot_MC_CI95_PUB_rawvsSimSig(ob_name, all_net_names, method_i, num_samples, net_MC_means_PUB, net_MC_CI95_PUB, net_MC_means_actual, net_MC_CI95_actual, ill_over_time_interval, dpr_flag, save_plot)


%% Create UB and LB lines

%UB_line = UB*ones(size(ill_over_time_interval,2),1);
%LB_line = LB*ones(size(ill_over_time_interval,2),1);

%%
num_nets = size(net_MC_means_actual,2);

if method_i == 1
    MC_method = 'KLD';
elseif method_i == 2
    MC_method = 'H-Dist';
elseif method_i == 3
    MC_method = 'MSE';
elseif method_i == 4
    MC_method = 'Entpy';
elseif method_i == 5
    MC_method = 'Var';
end

if dpr_flag == 0
    normalize = 'OB';
else
    normalize = 'NET';
end
    
Figure = figure('Units', 'pixels' , 'Position', [100 100 1000 1000]);
hold on;

%xlim([0 405])
%ylim([-1.5e-3 2e-3]);

N = num_nets;
C = linspecer(N);
x = ill_over_time_interval;  

for net_i = 1:num_nets
    MC_mean = net_MC_means_PUB(:,net_i).';
    MC_CI95 = net_MC_CI95_PUB(:,net_i).';
    plot(x, MC_mean,'LineWidth',1, 'Color', C(net_i,:));% 'Color','w')
end %over net_i

for net_i = 1:num_nets
    MC_mean = net_MC_means_PUB(:,net_i).';
    MC_CI95 = net_MC_CI95_PUB(:,net_i).';
    plot_colored_fill(x,MC_mean,MC_mean-MC_CI95,MC_mean, C(net_i,:));
    plot_colored_fill(x,MC_mean,MC_mean+MC_CI95,MC_mean, C(net_i,:));
    plot(x, MC_mean,'LineWidth',1, 'Color', 'w')

   %text(x(end), MC_mean(end), all_net_names{net_i});
   text(x(end), MC_mean(end), sprintf('SimSig-%s', all_net_names{net_i}));
    
   
    
end %over net_i


for net_i = 1:num_nets
    MC_mean = net_MC_means_actual(:,net_i).';
    MC_CI95 = net_MC_CI95_actual(:,net_i).';
    plot(x, MC_mean,'LineWidth',1, 'Color', C(net_i,:));% 'Color','w')
end %over net_i

for net_i = 1:num_nets
    MC_mean = net_MC_means_actual(:,net_i).';
    MC_CI95 = net_MC_CI95_actual(:,net_i).';
    plot_colored_fill(x,MC_mean,MC_mean-MC_CI95,MC_mean, C(net_i,:));
    plot_colored_fill(x,MC_mean,MC_mean+MC_CI95,MC_mean, C(net_i,:));
    plot(x, MC_mean,'LineWidth',1, 'Color', 'w')
    
    %text(x(end), MC_mean(end), all_net_names{net_i});
    text(x(end), MC_mean(end), sprintf('raw-%s', all_net_names{net_i}));

    
end %over net_i




Legend=cell(N,1);
for iter=1:N
    Legend{iter}=all_net_names{iter}; %strcat('Your_Data number', num2str(iter));
end
legend(Legend(1:N,1));


hTitle  = title (sprintf('Norm by: %s || Method: %s || OB: %s || iter: %0.0f', normalize, MC_method, ob_name,num_samples))

title (sprintf('Norm by: %s || Method: %s || OB: %s || iter: %0.0f', normalize, MC_method, ob_name,num_samples))
%title('Norm by: OB || Method: KLD || OB: SimulatedOB-Veg || iter:50')

hXLabel = xlabel('Number ill');
hYLabel_left = ylabel('Signal Strength');


set( gca, 'FontName'   , 'Helvetica' );
set([hTitle, hXLabel, hYLabel_left],'FontName'   , 'AvantGarde');
set([legend, gca], 'FontName'   , 'AvantGarde' ,'FontSize'   , 14 );
set([hXLabel]  , 'FontSize'   , 14          );
set([hYLabel_left]  , 'FontSize'   , 14          );
set( hTitle  , 'FontSize'   , 18  , 'FontWeight' , 'bold' );
%set(gca, 'Box'  , 'on','XTick', [25:25:150]);
% %

if save_plot == 1
    filename = '0_2019S/0_MC_over_ob_simulations/results_MC_metrics/WHS4_nets'; %'Elena2017/utility/Model_Comparison/0_2019S/figures'; % doesn't end with /
    eval(sprintf(  'print -djpeg100 %s/OB%s_method%0.0f_norm%s',filename,ob_name,method_i,normalize,));
end

%filename = 'Elena2017/utility/Model_Comparison/0_2019S/figures'; % doesn't end with /
%eval(sprintf(  'print -djpeg100 %s/OB_%s_method4_50samp_402',filename,ob_name));

end %function

 
% x = ill_over_time_interval;%1:100;                                          % Create Independent Variable
% y = MC_ratio.'; %randn(50,100);                                  % Create Dependent Variable ?Experiments? Data
% N = size(y,1);                                      % Number of ?Experiments? In Data Set
% yMean = mean(y);                                    % Mean Of All Experiments At Each Value Of ?x?
% ySEM = std(y)/sqrt(N);                              % Compute ?Standard Error Of The Mean? Of All Experiments At Each Value Of ?x?
% CI95 = tinv([0.025 0.975], N-1);                    % Calculate 95% Probability Intervals Of t-Distribution
% yCI95 = bsxfun(@times, ySEM, CI95(:));              % Calculate 95% Confidence Intervals Of All Experiments At Each Value Of ?x?
% figure
% hold on
% plot(x, yCI95+yMean)                                % Plot 95% Confidence Intervals Of All Experiments
% hold off
% grid
% plot_colored_fill(x,yMean,yCI95(1,:)+yMean,yMean)
% plot_colored_fill(x,yMean,yCI95(2,:)+yMean,yMean)
% plot(x, yMean,'LineWidth',1, 'Color','w') 