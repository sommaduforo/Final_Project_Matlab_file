function BIPVT_Electrical
    % Ensure PV/T parameters are in base workspace
    if ~evalin('base','exist(''pv_temp_coeff'',''var'')')
        fprintf('Loading PV/T parameters into base workspace…\n');
        evalin('base','run(''BIPVT_Params.m'')');
    end

    % Now safely grab them
    pv_efficiency   = evalin('base','pv_efficiency');
    totalPVArea     = evalin('base','totalPVArea');
    irradianceDerate= evalin('base','irradianceDerate');
    pv_temp_coeff   = evalin('base','pv_temp_coeff');

    % Grab your climate timeseries (assuming PreProcess also used evalin)
    ghi_ts   = evalin('base','GHI_ts');
    tamb_ts  = evalin('base','Tamb_ts');
    GHI      = ghi_ts.Data;        % [W/m²]
    T_amb    = tamb_ts.Data;       % [°C]
    t_sec    = ghi_ts.Time;        % [s]

    % --- Vectorized PV calculation (kW) ---
    deltaT    = T_amb - 25;
    tempFact  = 1 + pv_temp_coeff .* deltaT;
    P_dc_raw  = GHI .* pv_efficiency .* totalPVArea .* irradianceDerate;
    P_pv_W    = P_dc_raw .* tempFact;
    P_pv_W(P_pv_W<0) = 0;
    P_pv_vec  = P_pv_W/1000;       % → kW

    % (Optional) thermal vector here…

    % Push back to base
    assignin('base','P_pv_vec',P_pv_vec);
    assignin('base','time_sec',t_sec);
    assignin('base','PV_Power_ts',timeseries(P_pv_vec,t_sec,'Name','P_pv'));

    disp('✅ BIPVT_Electrical: full P_pv_vec ready in base workspace.');
end