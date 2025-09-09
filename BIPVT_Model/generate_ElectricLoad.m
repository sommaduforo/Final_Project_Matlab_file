% generate_ElectricLoad.m (corrected)
% ================================
% Converts a daily or full-year CSV electric profile into a full-year
% Simulink-ready .mat file (8760 h). Supports both 24-h and ≥8760-h inputs.

% --- 1. Configuration ---
filename  = 'BeckleyPoint_Electric_Load.csv';
sim_hours = 8760;  % hours in a non-leap year

% --- 2. Read CSV ---
electricData = readtable(filename);
rawLoadW     = electricData.Electric_Load_Watts;    % [W]
nRows         = height(electricData);

% --- 3. Expand or trim to full-year ---
if nRows == 24
    % Daily profile: repeat to full year
    nDays    = sim_hours/24;
    fullLoad = repmat(rawLoadW, nDays, 1);           % 8760×1 [W]
    disp('↻ Expanded 24-h load profile to 8760 h.');
elseif nRows >= sim_hours
    % Full-year data: trim to exactly sim_hours
    fullLoad = rawLoadW(1:sim_hours);
    disp('✔︎ Loaded full-year (≥8760 rows) and trimmed to 8760 h.');
else
    error('Electric load CSV has only %d rows; expected 24 or ≥8760.', nRows);
end

% --- 4. Build time vectors ---
time_hr  = (0:sim_hours-1)';   % 8760×1, hours since start
time_sec = time_hr * 3600;     % seconds

% --- 5. Create Simulink timeseries and vectors ---
P_load_ts  = timeseries(fullLoad, time_sec, 'Name', 'P_load');
P_load_vec = fullLoad / 1000;  % [kW]

% --- 6. Save for Simulink and post-processing ---
save('BeckleyElectricLoad.mat', 'P_load_ts', 'P_load_vec', 'time_hr', 'time_sec');

disp('✅ BeckleyElectricLoad.mat saved with P_load_ts (8760h), P_load_vec, time_hr & time_sec.');