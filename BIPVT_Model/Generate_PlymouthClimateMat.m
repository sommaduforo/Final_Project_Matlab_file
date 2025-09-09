% Generate_PlymouthClimateMat.m
% ==============================
% Read a NASA POWER TMYx CSV and trim to exactly one year (8760 h)
% Saves GHI, T_amb, time_hr, clim_time_hr, and Month into PlymouthClimate.mat

% --- 1. Configuration ---
filename   = 'Plymouth_TMYx.csv';  % NASA POWER CSV in this folder
startRow   = 12;                    % skip metadata lines
sim_hours  = 8760;                  % hours in a non-leap year

% --- 2. Import options ---
opts = detectImportOptions(filename, 'NumHeaderLines', startRow-1);
% Name all columns so we can select Month, GHI and T_amb
opts.VariableNames         = {'Year','Month','Day','Hour','GHI','T_amb','Wind'};
opts.SelectedVariableNames = {'Month','GHI','T_amb'};

% --- 3. Read the full table ---
dataFull = readtable(filename, opts);

% --- 4. Check length and trim to one year ---
if height(dataFull) < sim_hours
    error('Climate file has only %d rows but sim_hours = %d required.', ...
          height(dataFull), sim_hours);
end
data = dataFull(1:sim_hours, :);

% --- 5. Build time vectors ---
clim_time_hr = (0:sim_hours-1)';  % 8760×1, hours since start
time_hr      = clim_time_hr;      % alias so scripts expecting "time_hr" still work

% --- 6. Extract variables ---
Month = data.Month;   % 8760×1, values 1–12
GHI   = data.GHI;     % [W/m²], 8760×1
T_amb = data.T_amb;   % [°C],    8760×1

% --- 7. Save trimmed climate file ---
save('PlymouthClimate.mat', 'GHI', 'T_amb', 'time_hr', 'clim_time_hr', 'Month');

disp('✅ PlymouthClimate.mat created with GHI, T_amb, time_hr, clim_time_hr & Month.');