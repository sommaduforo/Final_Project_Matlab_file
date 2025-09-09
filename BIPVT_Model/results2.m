% === Monthly Energy Aggregation & Nice Plots ===

% Assumptions: 
%   - P_load_vec (8760×1) in kW
%   - P_pv_vec   (8760×1) in kW
%   - Q_heat_vec (8760×1) in kW (your full‐year thermal demand series)
%   - Q_th_vec   (8760×1) in kW (your full‐year thermal output)
%   - monthVec   (8760×1) in {1,…,12} indicating calendar month for each hour

%% 0) Load monthVec from your climate file (you may need to save this in Generate_PlymouthClimateMat.m)
c = load('PlymouthClimate.mat','Month');  
if isfield(c,'Month')
    monthVec = c.Month;
else
    error('Please regenerate PlymouthClimate.mat to include a "Month" vector (1–12 for each hour).');
end

%% 1) Sanity‐check lengths
N = 8760;
assert(all([numel(P_load_vec), numel(P_pv_vec), numel(Q_heat_vec), numel(Q_th_vec), numel(monthVec)]==N), ...
       'All inputs must be 8760×1');

%% 2) Aggregate by month via accumarray
monthly_elec_demand = accumarray(monthVec, P_load_vec, [12,1], @sum);  % kWh
monthly_PV_gen      = accumarray(monthVec, P_pv_vec,   [12,1], @sum);  % kWh
monthly_heat_demand = accumarray(monthVec, Q_heat_vec, [12,1], @sum);  % kWh
monthly_th_output   = accumarray(monthVec, Q_th_vec,   [12,1], @sum);  % kWh

month_names = {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};

%% 3) Sanity check PV seasonality
if monthly_PV_gen(1) > monthly_PV_gen(7)
    warning('January PV (%.0f kWh) > July PV (%.0f kWh)! Check your P\_pv\_vec ordering.', ...
            monthly_PV_gen(1), monthly_PV_gen(7));
end

%% 4) Plot #1: Electrical Demand vs PV Generation
f1 = figure('Name','Monthly Electrical','Color','w');
bar(1:12, [monthly_elec_demand, monthly_PV_gen], 0.8, 'grouped');
colormap(f1, [0.2 0.2 0.8; 0.1 0.7 0.1]);
legend('Demand','PV Gen','Location','northwest','FontWeight','bold');
xlabel('Month','FontSize',12,'FontWeight','bold');
ylabel('Energy (kWh)','FontSize',12,'FontWeight','bold');
title('Monthly Electrical: Demand vs PV Generation','FontSize',14,'FontWeight','bold');
set(gca,'XTick',1:12,'XTickLabel',month_names,'FontSize',11,'LineWidth',1.2);
grid on;

% add numeric labels
xt = bsxfun(@plus, (1:12)', [-0.15, +0.15]);
for m=1:12
    text(xt(m,1), monthly_elec_demand(m)+0.02*max(monthly_elec_demand), ...
         sprintf('%.0f',monthly_elec_demand(m)), ...
         'HorizontalAlignment','center','FontSize',8,'FontWeight','bold');
    text(xt(m,2), monthly_PV_gen(m)+0.02*max(monthly_elec_demand), ...
         sprintf('%.0f',monthly_PV_gen(m)), ...
         'HorizontalAlignment','center','FontSize',8,'FontWeight','bold');
end

%% 5) Plot #2: Thermal Demand vs Solar Thermal Output
f2 = figure('Name','Monthly Thermal','Color','w');
bar(1:12, [monthly_heat_demand, monthly_th_output], 0.8, 'grouped');
colormap(f2, [0.5 0.5 0.5; 0.8 0.2 0.2]);
legend('Heating Demand','Solar Thermal','Location','northwest','FontWeight','bold');
xlabel('Month','FontSize',12,'FontWeight','bold');
ylabel('Energy (kWh)','FontSize',12,'FontWeight','bold');
title('Monthly Thermal: Demand vs Solar Output','FontSize',14,'FontWeight','bold');
set(gca,'XTick',1:12,'XTickLabel',month_names,'FontSize',11,'LineWidth',1.2);
grid on;

% add numeric labels
xt = bsxfun(@plus, (1:12)', [-0.15, +0.15]);
for m=1:12
    text(xt(m,1), monthly_heat_demand(m)+0.02*max(monthly_heat_demand), ...
         sprintf('%.0f',monthly_heat_demand(m)), ...
         'HorizontalAlignment','center','FontSize',8,'FontWeight','bold');
    text(xt(m,2), monthly_th_output(m)+0.02*max(monthly_heat_demand), ...
         sprintf('%.0f',monthly_th_output(m)), ...
         'HorizontalAlignment','center','FontSize',8,'FontWeight','bold');
end