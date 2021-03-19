

num_toplot = 4;

toplot = [MC1_mean_rank_original_method0_raw, MC1_mean_rank_original_method0_Sig, MC1_mean_rank_original_method1_raw, MC1_mean_rank_original_method1_Sig];

toplot_names = cell(num_toplot,1);
toplot_names{1} = 'MC1 normOB raw';
toplot_names{2} = 'MC1 normOB SimSig';
toplot_names{3} = 'MC1 dpr raw';
toplot_names{4} = 'MC1 dpr SimSig';
%toplot_names{5} = 'MC5 normOB raw';


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

hTitle = title( 'Method1 normOB, dpr, raw, SimSig');

hXLabel = xlabel('Number ill');
hYLabel_left = ylabel('Accuracy');

set( gca, 'FontName'   , 'Helvetica' );
set([hTitle, hXLabel, hYLabel_left],'FontName'   , 'AvantGarde');
set([legend, gca], 'FontName'   , 'AvantGarde' ,'FontSize'   , 14 );
set([hXLabel]  , 'FontSize'   , 14          );
set([hYLabel_left]  , 'FontSize'   , 14          );
set( hTitle  , 'FontSize'   , 18  , 'FontWeight' , 'bold' );
%set(gca, 'Box'  , 'on','XTick', [25:25:150]);
% %