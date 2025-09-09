% 0) load monthVec
c = load('PlymouthClimate.mat','Month');
monthVec = c.Month;

% 1) sanity check lengths (optional)
assert(numel(Q_th_vec)==8760 && numel(monthVec)==8760, 'Need 8760-long vectors');

% 2) aggregate solar-thermal
monthly_th_output = accumarray(monthVec, Q_th_vec, [12,1], @sum);

% 3) plot only solar-thermal
month_names = {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
f = figure('Name','Monthly Solar Thermal Output','Color','w');
bar(1:12, monthly_th_output, 0.6);
xlabel('Month','FontSize',12,'FontWeight','bold');
ylabel('Solar Thermal Output (kWh)','FontSize',12,'FontWeight','bold');
set(gca, 'XTick', 1:12, 'XTickLabel', month_names, ...
         'FontSize',11, 'LineWidth',1.2);
title('Monthly Solar Thermal Output','FontSize',14,'FontWeight','bold');
grid on;
for m = 1:12
    text(m, monthly_th_output(m) + 0.02*max(monthly_th_output), ...
         sprintf('%.0f', monthly_th_output(m)), ...
         'HorizontalAlignment','center', ...
         'FontSize',9, 'FontWeight','bold');
end