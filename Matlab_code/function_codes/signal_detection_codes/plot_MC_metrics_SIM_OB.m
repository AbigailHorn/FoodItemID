

x = ill_over_time_interval;

num_toplot = 5;

toplot = [MC1_mean_rank_original_method0_raw, MC2_mean_rank_original_method0_raw, MC3_mean_rank_original_method0_raw, MC4_mean_rank_original_method0_raw,MC5_mean_rank_original_method0_raw];

toplot_names = cell(num_toplot,1);
toplot_names{1} = 'MC1 normOB raw';
toplot_names{2} = 'MC2 normOB raw';
toplot_names{3} = 'MC3 normOB raw';
toplot_names{4} = 'MC4 normOB raw';
toplot_names{5} = 'MC5 normOB raw';

toplot_names = cell(num_toplot,1);
toplot_names{1} = 'MC1 KLDiv';
toplot_names{2} = 'MC2 HDist';
toplot_names{3} = 'MC3 MSE';
toplot_names{4} = 'MC4 Entropy';
toplot_names{5} = 'MC5 Variance';


Figure = figure('Units', 'pixels' , 'Position', [100 100 1000 1000]);
hold on;

%xlim([0 405])
%ylim([.25 1]);

N = num_toplot;
C = linspecer(N);
x = ill_over_time_interval;  

for toplot_i = 1:N
    MC_mean = toplot(:,toplot_i).';
    plot(x, MC_mean,'LineWidth',2, 'Color', C(toplot_i,:));% 'Color','w')
    text(x(end), MC_mean(end), sprintf(toplot_names{toplot_i}));

end %over net_i

Legend=cell(N,1);
for iter=1:N
    Legend{iter}=toplot_names{iter}; %strcat('Your_Data number', num2str(iter));
end
legend(Legend(1:N,1));

hTitle = title( 'Method comparison normOB raw');

hXLabel = xlabel('Number ill');
hYLabel_left = ylabel('Rank');

set( gca, 'FontName'   , 'Helvetica' );
set([hTitle, hXLabel, hYLabel_left],'FontName'   , 'AvantGarde');
set([legend, gca], 'FontName'   , 'AvantGarde' ,'FontSize'   , 14 );
set([hXLabel]  , 'FontSize'   , 14          );
set([hYLabel_left]  , 'FontSize'   , 14          );
set( hTitle  , 'FontSize'   , 18  , 'FontWeight' , 'bold' );
%set(gca, 'Box'  , 'on','XTick', [25:25:150]);
% %