function BIPVT_Storage
% BIPVT_Storage  Compute battery and grid profiles from P_pv and P_load
%
% Expects in base workspace:
%   P_pv_vec         [kW]  vector of PV output (8761×1)
%   P_load_vec       [kW]  vector of building electrical demand
%   batteryCapacity  [kWh] (optional; default=100)
%   batteryEff       (scalar 0–1 round‐trip efficiency; default=0.90)
%
% Produces in base workspace:
%   SoC_vec          [%]   hourly state of charge
%   P_batt_ch_vec    [kW]  battery charging power
%   P_batt_dis_vec   [kW]  battery discharging power
%   P_grid_vec       [kW]  net grid import (+) / export (–)

    %% 1) Pull inputs
    try
        P_pv    = evalin('base','P_pv_vec');
    catch
        error('P_pv_vec not found in workspace. Run BIPVT_Electrical first.');
    end
    try
        P_load  = evalin('base','P_load_vec');
    catch
        error('P_load_vec not found. Log building electrical load as P_load_vec.');
    end

    % Ensure same length
    N = numel(P_pv);
    if numel(P_load) ~= N
        error('P_pv_vec and P_load_vec must be the same length (%d vs %d)',N,numel(P_load));
    end

    % Battery parameters
    if evalin('base','exist(''batteryCapacity'',''var'')')
        Cbat = evalin('base','batteryCapacity');
    else
        Cbat = 100;    % default kWh
    end
    if evalin('base','exist(''batteryEff'',''var'')')
        eff = evalin('base','batteryEff');
    else
        eff = 0.90;     % default round-trip
    end

    %% 2) Pre-allocate
    SoC       = zeros(N,1);
    P_batt_ch = zeros(N,1);
    P_batt_dis= zeros(N,1);
    P_grid    = zeros(N,1);

    % Initialize SoC at 50%
    SoC(1) = 0.5 * Cbat;

    %% 3) Hourly energy balance loop
    for t = 1:N
        % Net surplus (+) or deficit (–) of PV vs load
        delta = P_pv(t) - P_load(t);  % [kW]

        if delta > 0
            % Charge: limited by available battery capacity
            charge = min(delta * eff, Cbat - SoC(t));
            P_batt_ch(t) = charge;
            SoC(t)       = SoC(t) + charge;
            P_grid(t)    = 0;  % no import
        else
            % Discharge: limited by stored energy
            needed = -delta / eff;
            discharge = min(needed, SoC(t));
            P_batt_dis(t) = discharge;
            SoC(t)        = SoC(t) - discharge;
            P_grid(t)     = needed - discharge;  % if >0, import from grid
        end

        % Carry SoC forward
        if t < N
            SoC(t+1) = SoC(t);
        end
    end

    % Convert SoC to % of capacity
    SoC_pct = 100 * SoC / Cbat;

    %% 4) Push outputs back
    assignin('base','SoC_vec',      SoC_pct);
    assignin('base','P_batt_ch_vec',P_batt_ch);
    assignin('base','P_batt_dis_vec',P_batt_dis);
    assignin('base','P_grid_vec',   P_grid);

    disp('🔋 BIPVT_Storage: SoC_vec, P_batt_ch_vec, P_batt_dis_vec, and P_grid_vec ready.');
end