% === BIPVT_PreProcess.m ===
% Load climate data and convert to timeseries for Simulink

% 1) Load the raw vectors
clim     = load('PlymouthClimate.mat','GHI','T_amb','time_hr');
rawGHI   = clim.GHI;     % [W/m²]
rawTamb  = clim.T_amb;   % [°C]
t_hours  = clim.time_hr; % [h]

% 2) Build timeseries
time_s    = t_hours * 3600;              % convert hours → seconds
GHI_ts    = timeseries(rawGHI,   time_s);  % timeseries named GHI_ts
Tamb_ts   = timeseries(rawTamb,  time_s);  % timeseries named Tamb_ts

% 3) Push into base workspace under the names your Electrical script expects
assignin('base','GHI_ts',  GHI_ts);
assignin('base','Tamb_ts', Tamb_ts);

% (Optional) also push raw vectors if needed downstream
assignin('base','rawGHI',  rawGHI);
assignin('base','rawTamb', rawTamb);
assignin('base','time_hr', t_hours);