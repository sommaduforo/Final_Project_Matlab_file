%% BIPVT_ControlLogic.m
% Implements basic dispatch logic using your precomputed vectors:
%  - P_pv_vec   [kW] PV generation
%  - P_load_vec [kW] building electrical load
%  - Q_th_vec   [kW] PV/T thermal output
%  - Q_heat_vec [kW] building thermal demand
%  - SoC_vec    [%]  battery state of charge
%  - P_grid_vec [kW] net grid import/export
%
% This script writes back any control signals you might need, for example:
%   - P_pv_curtailed_vec  : curtailed PV [kW]
%   - pump_on_vec         : binary heat‐pump status
%   - battery_charge_enabled_vec, battery_discharge_enabled_vec

%% 1) Pull required vectors from base
P_pv = evalin('base','P_pv_vec');      % [kW], N×1
P_load = evalin('base','P_load_vec');  % [kW], N×1
Q_th   = evalin('base','Q_th_vec');    % [kW], N×1

% Thermal demand may be only 24×1
if evalin('base','exist(''Q_heat_vec'',''var'')')
    Qd = evalin('base','Q_heat_vec');  % [kW], maybe 24×1
else
    Qd = zeros(1,1);  % fallback
    warning('Q_heat_vec missing: assuming zero thermal demand.');
end

%% 2) Expand Qd to full-year if needed
N = numel(P_pv);
if numel(Qd) ~= N
    if mod(N, numel(Qd)) == 0
        reps = N/numel(Qd);
        Q_heat = repmat(Qd, reps, 1);
    else
        warning('Cannot integer‐repeat Q_heat_vec (%d) to length %d; truncating/padding.', numel(Qd), N);
        % simple pad/truncate
        Q_temp = repmat(Qd, ceil(N/numel(Qd)), 1);
        Q_heat = Q_temp(1:N);
    end
else
    Q_heat = Qd;
end

%% 3) Pull storage & grid data
SoC    = evalin('base','SoC_vec');        % [%], N×1
P_ch   = evalin('base','P_batt_ch_vec');  % [kW]
P_dis  = evalin('base','P_batt_dis_vec'); % [kW]
P_grid = evalin('base','P_grid_vec');     % [kW]

%% 4) Preallocate control outputs
N = numel(P_pv);
P_pv_curtailed = zeros(N,1);
battery_charge_allowed    = false(N,1);
battery_discharge_allowed = false(N,1);
pump_on                   = false(N,1);

%% 5) Example dispatch loop
for t = 1:N
    surplus = P_pv(t) - P_load(t);

    % --- Electrical storage ---
    if surplus > 0
        if SoC(t) < 80
            battery_charge_allowed(t) = true;
        else
            P_pv_curtailed(t) = surplus;
        end
    else
        if SoC(t) > 20
            battery_discharge_allowed(t) = true;
        end
    end

    % --- Thermal pump ---
    if Q_th(t) >= 0.1 * Q_heat(t)
        pump_on(t) = true;
    end
end

%% 6) Assign control signals back
assignin('base','P_pv_curtailed_vec',          P_pv_curtailed);
assignin('base','battery_charge_allowed_vec',  battery_charge_allowed);
assignin('base','battery_discharge_allowed_vec',battery_discharge_allowed);
assignin('base','pump_on_vec',                 pump_on);

disp('🧠 Control logic executed (with Q_heat_vec expanded to full year).');