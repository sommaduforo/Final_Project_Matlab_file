%% BIPVT Thermal Output Model (Air-based) - Fixed
% Assumes BIPVT_Params.m and BIPVT_PreProcess.m have been run, providing:
%   GHI [W/m²], T_amb [°C], totalPVArea [m²], irradianceDerate, 
%   flow_rate_air [kg/s], cp_air [J/kg·K]

% 1) Compute raw thermal power [W]
absorbed_frac   = 0.50;  % 50% of incident solar to heat
Q_thermal_raw  = GHI .* absorbed_frac .* totalPVArea .* irradianceDerate;
Q_thermal_raw(Q_thermal_raw < 0) = 0;  % no negatives

% 2) Compute outlet air temperature [°C]
deltaT_air = Q_thermal_raw ./ (flow_rate_air * cp_air);  % ΔT = Q/(ṁ·cp)
T_air_out  = T_amb + deltaT_air;
T_air_out  = min(max(T_air_out, T_amb), 60);  % clamp between ambient and 60°C

% 3) Build time vector and export timeseries
time_sec      = (0:length(T_air_out)-1)';  % seconds, hourly steps
T_air_out_ts  = timeseries(T_air_out,    time_sec, 'Name','T_air_out');
Q_thermal_ts  = timeseries(Q_thermal_raw, time_sec, 'Name','Q_thermal_raw');
assignin('base','T_air_out_ts', T_air_out_ts);
assignin('base','Q_thermal_ts', Q_thermal_ts);

% 4) Convert thermal power to kW numeric vector and export
Q_th_vec = Q_thermal_raw / 1000;          % [kW]
assignin('base','Q_th_vec', Q_th_vec);

% 5) Also expose a kW timeseries under the expected name
Q_th_ts = timeseries(Q_th_vec, time_sec, 'Name','Q_th');
assignin('base','Q_th_ts', Q_th_ts);

disp('✅ Air-based thermal model generated; Q_th_vec and Q_th_ts assigned.');