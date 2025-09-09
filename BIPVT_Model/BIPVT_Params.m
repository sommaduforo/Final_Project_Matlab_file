%% BIPV/T Retrofit Parameters for Beckley Point

% Building geometry
buildingHeight = 78;               % [m]
numFloors = 23;
panelsPerFloor = 5;
panelArea = 1.0;                   % [m²] per panel
numPanels = numFloors * panelsPerFloor;
totalPVArea = numPanels * panelArea;
zoneArea = 700;                    % [m²] assumed floor zone

% Orientation & mounting
orientation = 'south';            % Facade facing
tilt = 90;                        % Vertical integration
tilt_rad = deg2rad(tilt);         % Radians
azimuth = 180;                    % South-facing in azimuth degrees

% Optical and system derate factor
irradianceDerate = 0.85;

% PV electrical parameters
pv_efficiency = 0.16;             % 16% panel efficiency
pv_temp_coeff = -0.0045;          % [%/°C]

% Thermal subsystem (air-based for now)
cp_air = 1005;                    % J/kg·K
rho_air = 1.2;                    % kg/m³
flow_rate_air = 0.15;             % kg/s baseline assumption

% Time parameters
time_step = 1/60;                 % 1-min steps (hours)
sim_hours = 8760;                 % 1-year simulation