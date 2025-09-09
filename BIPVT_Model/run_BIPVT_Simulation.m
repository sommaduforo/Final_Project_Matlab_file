% ================================
% Master Runner for BIPV/T Simulation - Beckley Point (Corrected)
% ================================
clc; close all; clear;

disp('🔁 Starting BIPV/T pre-simulation setup...');

%% 1. Load system parameters into base workspace
disp('⚙️  Loading BIPV system parameters...');
evalin('base','run(''BIPVT_Params.m'')');
sim_hours = evalin('base','sim_hours');   % expected 8760

%% 2. Generate and load climate data
disp('🌤️  Preparing climate data...');
evalin('base','run(''Generate_PlymouthClimateMat.m'')');

%% 3. Preprocess time & input signals
disp('🛠️  Running pre-processing...');
evalin('base','run(''BIPVT_PreProcess.m'')');

%% 4. Build full-year demand profiles

% 4a) Electric demand
disp('⚡ Generating and loading electric demand...');
run('generate_ElectricLoad.m');                     % creates BeckleyElectricLoad.mat
ldE = load('BeckleyElectricLoad.mat','P_load_ts','P_load_vec');
P_load_ts  = ldE.P_load_ts;                         % timeseries [W]
P_load_vec = ldE.P_load_vec;                        % [kW]
assignin('base','P_load_ts',  P_load_ts);
assignin('base','P_load_vec', P_load_vec);
% <-- new: alias for your Simulink block
assignin('base','P_demand',   P_load_ts);
disp('✔️  Building electric load (8760 h) assigned.');

% 4b) HVAC thermal demand
disp('🔥 Loading HVAC thermal demand...');
run('Load_Beckley_ThermalDemand.m');                % creates BeckleyThermalLoad.mat
ldT = load('BeckleyThermalLoad.mat','Q_heat_ts','Q_heat_vec');
Q_heat_ts  = ldT.Q_heat_ts;                         % timeseries [W]
Q_heat_vec = ldT.Q_heat_vec;                        % [kW]
assignin('base','Q_heat_ts',  Q_heat_ts);
assignin('base','Q_heat_vec', Q_heat_vec);
% <-- new: alias for your Simulink block
assignin('base','Q_demand',   Q_heat_ts);
disp('✔️  HVAC thermal load (8760 h) assigned.');

%% 5. Compute PV/T outputs
disp('☀️  Computing PV electrical and thermal outputs...');
BIPVT_Electrical;      % defines P_pv_vec, Q_th_vec
BIPVT_ModuleThermal;   % ensures Q_th_vec/Q_th_ts exist
disp('✔️  PV/T output vectors ready.');

%% 5.5 Align PV/T outputs to hourly resolution
disp('🔄  Aligning PV/T outputs to hourly resolution...');
P_pv_orig = evalin('base','P_pv_vec');
% … rest of down‐sampling as before …

%% 6. Configure storage
disp('🔋  Configuring electrical + thermal storage...');
BIPVT_Storage;
disp('✔️  Storage profiles ready.');

%% 7. Optional control logic
disp('🧠  Executing control logic...');
BIPVT_ControlLogic;
disp('✔️  Control logic executed.');

%% 8. Run the full Simulink model
disp('🚀  Launching system simulation...');
modelName = 'BIPVT_FullSystem';
% … rest unchanged …
simOut = sim(modelName,'ReturnWorkspaceOutputs','on');
disp('✅ Simulation complete.');