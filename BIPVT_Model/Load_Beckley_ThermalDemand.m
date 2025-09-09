function Load_Beckley_ThermalDemand
%=== Load_Beckley_ThermalDemand.m (with corrected seasonal scaling) ===
% Reads 24-h HVAC thermal load, applies monthly factors (winter high, summer zero),
% and builds an 8760-h kW vector and timeseries.

    % 1) Read the 24-h profile (Watts)
    tbl   = readtable('BeckleyPoint_HVAC_Thermal_Load.csv');
    daily = tbl.Thermal_Load_Watts;    % [W]
    assert(numel(daily)==24, 'CSV must have exactly 24 rows');

    % 2) Simulation length
    sim_hours = evalin('base','sim_hours');
    assert(sim_hours==8760, 'sim_hours must be 8760 for a 1-yr sim');

    % 3) Define corrected monthly multipliers & days
    %    High in cold months (Dec, Jan, Feb), zero in summer (Jun-Aug)
    monthlyFactor = [1.0, 0.9, 0.7, 0.4, 0.1, 0.0, 0.0, 0.0, 0.1, 0.4, 0.8, 1.0];
    daysPerMonth  = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    assert(numel(monthlyFactor)==12 && numel(daysPerMonth)==12, ...
        'monthlyFactor/daysPerMonth must each have 12 elements');

    % 4) Build full-year vector
    Q_heat_vec = zeros(sim_hours,1);
    idx = 1;
    for m = 1:12
        % scale daily shape by this month’s factor (convert to kW)
        scaledDaily = (daily/1000) * monthlyFactor(m);
        % repeat for each day in month
        nDays = daysPerMonth(m);
        block = repmat(scaledDaily, nDays, 1);
        Q_heat_vec(idx:idx+numel(block)-1) = block;
        idx = idx + numel(block);
    end
    assert(idx-1==sim_hours, 'Final index mismatch: built %d hours', idx-1);

    % 5) Create timeseries
    t_sec = (0:sim_hours-1)' * 3600;   % seconds
    Q_heat_ts = timeseries(Q_heat_vec, t_sec, 'Name','ThermalDemand');

    % 6) Assign to base workspace
    assignin('base','Q_heat_vec', Q_heat_vec);
    assignin('base','Q_heat_ts',  Q_heat_ts);

    fprintf('✅ Seasonal thermal demand vector created (8760h, kW) with winter-high scaling.\n');
end