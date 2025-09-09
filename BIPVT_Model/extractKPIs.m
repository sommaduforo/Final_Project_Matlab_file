%% === Chapter 4 KPI Extraction Script ===
% Assumes these vectors exist in workspace (all length 8760 unless noted):
%   P_pv_vec   [kW]    – PV output
%   Q_th_vec   [kW]    – Thermal output
%   P_load_vec [kW]    – Electrical demand
%   Q_heat_vec [kW]    – Thermal demand (either 8760 or 24 long)
%   SoC_vec    [%]     – Battery state of charge
%   P_batt_ch_vec [kW] – Battery charge power
%   P_batt_dis_vec[kW] – Battery discharge power
%   P_grid_vec [kW]    – Net grid import(+)/export(–)
%   rawGHI     [W/m²]  – Hourly irradiance on panel (optional)
%   totalPVArea[m²]    – PV area (optional)
%   Month      [1–12]  – Month index for each hour

%% 1) Annual sums (kWh)
annual_elec_demand    = sum(P_load_vec);      % kWh
annual_PV_generation  = sum(P_pv_vec);        % kWh
if numel(Q_heat_vec)==24
    annual_heat_demand   = sum(Q_heat_vec)*365; 
else
    annual_heat_demand   = sum(Q_heat_vec);
end
annual_thermal_output = sum(Q_th_vec);        % kWh

% Grid imports/exports
annual_grid_import = sum(max(P_load_vec - P_pv_vec,0));    % kWh
annual_grid_export = sum(max(P_pv_vec - P_load_vec,0));    % kWh

%% 2) Solar fractions
solar_frac_elec    = annual_PV_generation  / annual_elec_demand  * 100;
solar_frac_thermal = annual_thermal_output / annual_heat_demand * 100;

%% 3) Average efficiencies (if climate data & area exist)
if exist('rawGHI','var') && exist('totalPVArea','var')
    % rawGHI in W/m2, hourly → Wh/m2
    incident_kWh = sum(rawGHI)/1000 * totalPVArea;  
    eff_pv_percent      = annual_PV_generation  / incident_kWh * 100;
    eff_thermal_percent = annual_thermal_output / incident_kWh * 100;
    eff_combined        = (annual_PV_generation + annual_thermal_output) / incident_kWh * 100;
else
    eff_pv_percent = NaN; eff_thermal_percent = NaN; eff_combined = NaN;
end

%% 4) Peak outputs
peak_PV_kW     = max(P_pv_vec);
peak_thermal_kW= max(Q_th_vec);

%% 5) Battery metrics
battery_initial_SOC = SoC_vec(1);
battery_final_SOC   = SoC_vec(end);
battery_throughput  = sum(P_batt_ch_vec) + sum(P_batt_dis_vec);  % kWh total moved

%% 6) Pump operating hours (if you have pump_on_vec)
if exist('pump_on_vec','var')
    pump_hours = sum(pump_on_vec);           % hours pump was on
else
    pump_hours = NaN;
end

%% 7) Print everything in a neat summary
fprintf('\n=== Annual Performance Metrics ===\n');
fprintf('Annual Electrical Demand:    %.1f MWh\n', annual_elec_demand/1000);
fprintf('Annual PV Generation:       %.1f MWh\n', annual_PV_generation/1000);
fprintf('Annual Heat Demand:         %.1f MWh\n', annual_heat_demand/1000);
fprintf('Annual Thermal Output:      %.1f MWh\n', annual_thermal_output/1000);
fprintf('Grid Import:                %.1f MWh\n', annual_grid_import/1000);
fprintf('Grid Export:                %.1f MWh\n', annual_grid_export/1000);
fprintf('Electrical Solar Fraction:  %.2f%%\n', solar_frac_elec);
fprintf('Thermal Solar Fraction:     %.2f%%\n', solar_frac_thermal);
if ~isnan(eff_pv_percent)
    fprintf('Avg. PV Efficiency:         %.2f%%\n', eff_pv_percent);
    fprintf('Avg. Thermal Efficiency:    %.2f%%\n', eff_thermal_percent);
    fprintf('Combined Capture Eff.:      %.2f%%\n', eff_combined);
end
fprintf('Peak PV Power:              %.1f kW\n', peak_PV_kW);
fprintf('Peak Thermal Power:         %.1f kW\n', peak_thermal_kW);
fprintf('Battery SOC:                %.0f%% → %.0f%%\n', battery_initial_SOC, battery_final_SOC);
fprintf('Battery Throughput:         %.1f kWh\n', battery_throughput);
if ~isnan(pump_hours)
    fprintf('Pump Operating Hours:       %d hours\n', pump_hours);
end

%% 8) Monthly yields table (MWh)
monthlyPV  = zeros(12,1);
monthlyTh  = zeros(12,1);
for m = 1:12
    idx = (Month==m);
    monthlyPV(m) = sum(P_pv_vec(idx))/1000;
    monthlyTh(m) = sum(Q_th_vec(idx))/1000;
end

month_names = {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
fprintf('\n=== Monthly Yields (MWh) ===\n');
fprintf(' Month | PV Gen | Thermal\n');
for m=1:12
    fprintf('  %-3s |  %5.2f  |  %5.2f\n', month_names{m}, monthlyPV(m), monthlyTh(m));
end

% And print June vs December explicitly
fprintf('\nJune PV yield:    %.2f MWh\n', monthlyPV(6));
fprintf('Dec  PV yield:    %.2f MWh\n', monthlyPV(12));
fprintf('June heat output: %.2f MWh\n', monthlyTh(6));
fprintf('Dec  heat output: %.2f MWh\n\n', monthlyTh(12));