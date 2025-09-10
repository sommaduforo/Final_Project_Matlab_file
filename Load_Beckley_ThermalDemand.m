% Load_Beckley_ThermalDemand.m
% Prepares HVAC thermal demand profile for Beckley Point simulation

% 1) Load hourly thermal demand data from CSV
thermalData = readtable('BeckleyPoint_HVAC_Thermal_Load.csv');

% 2) Convert hour values to seconds
time_hr = thermalData.Hour;              % 0–23
time_sec = time_hr * 3600;               % seconds

% 3) Create the core timeseries in Watts
Q_demand = timeseries(thermalData.Thermal_Load_Watts, time_sec, 'Name','Q_demand');

% 4) Expose Q_demand for Simulink blocks that expect it
assignin('base','Q_demand', Q_demand);

% 5) Also create convenience variables for post‐processing
%    a) timeseries named Q_heat_ts
assignin('base','Q_heat_ts', Q_demand);

%    b) numeric kW vector Q_heat_vec
Q_heat_vec = Q_demand.Data / 1000;       % convert W → kW
assignin('base','Q_heat_vec', Q_heat_vec);

% 6) (Optional) save for reuse
save('BeckleyThermalLoad.mat','Q_demand','Q_heat_vec');

disp('✅ HVAC thermal demand assigned as Q_demand, Q_heat_ts & Q_heat_vec.');