% Generate PlymouthClimate.mat from NASA POWER TMYx CSV
% Ensure the CSV file is in the same folder as this script
% or update the file path accordingly

filename = 'Plymouth_TMYx.csv';  % Your CSV file
startRow = 12;  % Skip 11 metadata lines

% Read the data starting from row 12
opts = detectImportOptions(filename, 'NumHeaderLines', startRow - 1);
opts.VariableNames = {'Year','Month','Day','Hour','GHI','T_amb','Wind'};
opts.SelectedVariableNames = {'GHI','T_amb'};

% Read table
data = readtable(filename, opts);

% Generate continuous hourly time vector
time_hr = (0:height(data)-1)';  % each row = 1 hour

% Extract variables
GHI = data.GHI;        % [W/m²]
T_amb = data.T_amb;    % [°C]

% Save to .mat file
save('PlymouthClimate.mat', 'GHI', 'T_amb', 'time_hr');

disp('✅ PlymouthClimate.mat has been successfully created.');