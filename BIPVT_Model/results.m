% === Automatic Summer/Winter Day Selection ===
N = numel(P_pv_vec);
assert(N==8760 && numel(P_load_vec)==8760, 'Need 8760-long vectors');

% reshape into days
Ppv_mat   = reshape(P_pv_vec, 24, []);   
Pload_mat = reshape(P_load_vec,24, []);  

dailyPVsum = sum(Ppv_mat,1);  

[~, idxSummer] = max(dailyPVsum);
[~, idxWinter] = min(dailyPVsum);

% map DOY to actual dates
refDate     = datetime(2025,1,1);
dateSummer  = refDate + days(idxSummer-1);
dateWinter  = refDate + days(idxWinter-1);

% extract 24-h profiles
PpvSum   = Ppv_mat(:, idxSummer);
PloadSum = Pload_mat(:, idxSummer);
PgridSum = max(PloadSum - PpvSum, 0);

PpvWin   = Ppv_mat(:, idxWinter);
PloadWin = Pload_mat(:, idxWinter);
PgridWin = max(PloadWin - PpvWin, 0);

hr = 0:23;  % hours of day

%% === Figure 1: Sunniest Day ===
figure(1);
plot(hr, PloadSum, '-k',  'LineWidth',2); hold on;
plot(hr, PgridSum,'--r', 'LineWidth',2);
plot(hr, PpvSum,   '-g', 'LineWidth',2);
hold off;

xlabel('Hour of Day','FontSize',12);
ylabel('Power (kW)','FontSize',12);
title('Sunniest Day', 'FontSize',14,'FontWeight','bold');
legend({'Load','Grid','PV'}, 'Location','northwest','FontSize',10);
set(gca, 'FontSize',11, 'LineWidth',1.2, 'Box','on');
grid on; xlim([0 23]);

%% === Figure 2: Cloudiest Day ===
figure(2);
plot(hr, PloadWin, '-k',  'LineWidth',2); hold on;
plot(hr, PgridWin,'--r', 'LineWidth',2);
plot(hr, PpvWin,   '-g', 'LineWidth',2);
hold off;

xlabel('Hour of Day','FontSize',12);
ylabel('Power (kW)','FontSize',12);
title('Cloudiest Day', 'FontSize',14,'FontWeight','bold');
legend({'Load','Grid','PV'}, 'Location','northwest','FontSize',10);
set(gca, 'FontSize',11, 'LineWidth',1.2, 'Box','on');
grid on; xlim([0 23]);