% generate_ElectricLoad.m
% Converts hourly CSV electric profile to Simulink-ready .mat file

% Load the electric load data from CSV
electricData = readtable('BeckleyPoint_Electric_Load.csv');

% Extract hours and convert to seconds
time_hr = electricData.Hour;
time_sec = time_hr * 3600;  % Simulink uses seconds for time

% Create time series object
P_demand = timeseries(electricData.Electric_Load_Watts, time_sec);

% Save the timeseries to .mat for use in Simulink
save('BeckleyElectricLoad.mat', 'P_demand');

% Optional: Confirm
disp('✅ Electric load timeseries saved as BeckleyElectricLoad.mat');