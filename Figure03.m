%% make_golden_BV_validation_figure.m
% Experimental tests of the golden-point relations using the
% Kucernak & Zalitis Pt/C HER/HOR data stored in "Experimental Data.xlsx".
%
% The script produces a 2-by-2 publication-style figure:
%   (a) 298 K local HER/HOR curve reconstructed from the two golden points;
%   (b) two-point j0,pair versus a full-window local BV fit over +/-50 mV;
%   (c) two-point alpha_pair versus full-window alpha_BVfit across 278--333 K;
%   (d) H2-pressure stress test of the physical and formal C_req windows.
%
% No Optimization Toolbox is required: the local BV fit uses fminsearch.
% The raw current values in the supplied workbook are numerically in mA/cm^2
% although the worksheet header states A/cm^2; therefore currentScale=1e-3
% converts the numeric values to A/cm^2 for all calculations.

clear; clc; close all;

%% 1. User settings
filename = 'Experimental Data.xlsx';
sheetName = 'Figure 7';
excelRange = 'A10:AL581';
fontName = 'Arial';

% If the workbook is not in the current folder, choose it interactively.
if ~isfile(filename)
    [f, p] = uigetfile({'*.xlsx;*.xls','Excel files (*.xlsx, *.xls)'}, ...
        'Select Experimental Data.xlsx');
    if isequal(f,0)
        error('No Excel file was selected.');
    end
    filename = fullfile(p,f);
end

% Physical constants and analysis windows.
R = 8.31446261815324;       % J mol^-1 K^-1
F = 96485.33212;            % C mol^-1
phi = (1 + sqrt(5))/2;
currentScale = 1e-3;        % workbook numeric values -> A cm^-2
fitWindow = 0.050;          % V, local complementary-BV fit window
microWindow = 0.005;        % V, micropolarization slope window
eqSearchWindow = 0.015;     % V, search window for the zero-current crossing

% Illustrative physically informed interval requested by Reviewer 2.
alphaPhysical = [0.3, 0.7];
Cphysical = [phi^(2*alphaPhysical(1)-1), phi^(2*alphaPhysical(2)-1)];
Cformal = [1/phi, phi];

%% 2. Read the Figure 7 worksheet directly
raw = readmatrix(filename, 'Sheet', sheetName, 'Range', excelRange);
if size(raw,2) < 38
    error(['The imported worksheet has only %d numeric columns, but this ', ...
        'script expects at least 38 columns (A:AL) from Figure 7.'], size(raw,2));
end

% Column pairs inside A:AL after readmatrix. Each pair is [E, j].
pH2 = [0.126, 0.107, 0.087, 0.068, 0.048, 0.029];
pressureCols = [1 2; 4 5; 7 8; 10 11; 13 14; 16 17];

Tlist = [278, 288, 298, 303, 313, 323, 333];
temperatureCols = [19 20; 22 23; 25 26; 28 29; 31 32; 34 35; 37 38];

%% 3. Analyze all temperature-series curves
nT = numel(Tlist);
EeqT = nan(nT,1);
etaPhiT = nan(nT,1);
JminusT = nan(nT,1);
JplusT = nan(nT,1);
j0PairT = nan(nT,1);
alphaPairT = nan(nT,1);
j0FitT = nan(nT,1);
alphaFitT = nan(nT,1);
R2PairT = nan(nT,1);

for k = 1:nT
    T = Tlist(k);
    [E, j] = extractSeries(raw, temperatureCols(k,1), temperatureCols(k,2), currentScale);
    Eeq = estimateEquilibriumPotential(E, j, eqSearchWindow);
    eta = E - Eeq;
    etaPhi = 2*R*T*log(phi)/F;

    jPlusSigned = interpNoExtrap(eta, j, +etaPhi);
    jMinusSigned = interpNoExtrap(eta, j, -etaPhi);
    Jplus = abs(jPlusSigned);
    Jminus = abs(jMinusSigned);

    if ~isfinite(Jplus) || ~isfinite(Jminus) || Jplus <= 0 || Jminus <= 0
        error('Temperature series at %g K does not cover both golden points.', T);
    end

    % Bidirectional golden-point estimators.
    j0Pair = sqrt(Jplus*Jminus);
    alphaPair = 0.5 - log(Jplus/Jminus)/(4*log(phi));

    % Independent local complementary-BV fit to all points in +/-50 mV.
    [j0Fit, alphaFit] = fitComplementaryBV(eta, j, T, R, F, fitWindow, microWindow);

    % Goodness of the zero-additional-parameter curve reconstructed from the
    % two measured golden-point currents.
    localMask = abs(eta) <= fitWindow;
    jPairPred = bvCurrent(eta(localMask), j0Pair, alphaPair, T, R, F);
    yLocal = j(localMask);
    ssTot = sum((yLocal - mean(yLocal)).^2);
    if ssTot > 0
        R2Pair = 1 - sum((yLocal - jPairPred).^2)/ssTot;
    else
        R2Pair = NaN;
    end

    EeqT(k) = Eeq;
    etaPhiT(k) = etaPhi;
    JminusT(k) = Jminus;
    JplusT(k) = Jplus;
    j0PairT(k) = j0Pair;
    alphaPairT(k) = alphaPair;
    j0FitT(k) = j0Fit;
    alphaFitT(k) = alphaFit;
    R2PairT(k) = R2Pair;
end

% Cross-validation statistics used in panels (b) and (c).
MARDj0 = mean(abs((j0PairT - j0FitT)./j0FitT))*100;
maxRDj0 = max(abs((j0PairT - j0FitT)./j0FitT))*100;
MADalpha = mean(abs(alphaPairT - alphaFitT));
maxDalpha = max(abs(alphaPairT - alphaFitT));

%% 4. Analyze the H2-pressure series at 298 K
Tpressure = 298;
etaPhiPressure = 2*R*Tpressure*log(phi)/F;
nP = numel(pH2);
EeqP = nan(nP,1);
JplusP = nan(nP,1);
JminusP = nan(nP,1);
j0MicroP = nan(nP,1);
CreqPlus = nan(nP,1);
alphaReqPlus = nan(nP,1);
alphaPairP = nan(nP,1);

for k = 1:nP
    [E, j] = extractSeries(raw, pressureCols(k,1), pressureCols(k,2), currentScale);
    Eeq = estimateEquilibriumPotential(E, j, eqSearchWindow);
    eta = E - Eeq;

    jPlusSigned = interpNoExtrap(eta, j, +etaPhiPressure);
    jMinusSigned = interpNoExtrap(eta, j, -etaPhiPressure);
    Jplus = abs(jPlusSigned);
    Jminus = abs(jMinusSigned);

    % Local micropolarization benchmark. In ideal BV kinetics,
    % (RT/F)*(dj/deta)|eta=0 = j0 independent of alpha.
    j0Micro = microPolarizationJ0(eta, j, Tpressure, R, F, microWindow);

    if isfinite(Jplus) && Jplus > 0
        Creq = j0Micro/Jplus;
        alphaReq = 0.5*(1 + log(Creq)/log(phi));   % positive branch, s=+1
    else
        Creq = NaN;
        alphaReq = NaN;
    end

    if isfinite(Jplus) && isfinite(Jminus) && Jplus > 0 && Jminus > 0
        alphaPair = 0.5 - log(Jplus/Jminus)/(4*log(phi));
    else
        alphaPair = NaN;  % no extrapolation when the negative golden point is absent
    end

    EeqP(k) = Eeq;
    JplusP(k) = Jplus;
    JminusP(k) = Jminus;
    j0MicroP(k) = j0Micro;
    CreqPlus(k) = Creq;
    alphaReqPlus(k) = alphaReq;
    alphaPairP(k) = alphaPair;
end

%% 5. Print and save numerical summaries for the revision record
TempSummary = table(Tlist(:), 1e3*EeqT, 1e3*etaPhiT, 1e3*JminusT, 1e3*JplusT, ...
    1e3*j0PairT, alphaPairT, 1e3*j0FitT, alphaFitT, R2PairT, ...
    'VariableNames', {'T_K','Eeq_mV','etaPhi_mV','JphiMinus_mAcm2','JphiPlus_mAcm2', ...
    'j0Pair_mAcm2','alphaPair','j0BVfit_mAcm2','alphaBVfit','R2_pair_prediction'});

PressureSummary = table(pH2(:), 1e3*EeqP, 1e3*JplusP, 1e3*JminusP, 1e3*j0MicroP, ...
    CreqPlus, alphaReqPlus, alphaPairP, ...
    CreqPlus >= Cformal(1) & CreqPlus <= Cformal(2), ...
    CreqPlus >= Cphysical(1) & CreqPlus <= Cphysical(2), ...
    'VariableNames', {'pH2_bar','Eeq_mV','JphiPlus_mAcm2','JphiMinus_mAcm2', ...
    'j0Micro_mAcm2','CreqPlus','alphaReqPlus','alphaPair','InsideFormalWindow','InsidePhysicalBand'});

fprintf('\n=== Temperature-series two-point/full-window consistency ===\n');
disp(TempSummary);
fprintf('Mean |j0_pair-j0_BVfit|/j0_BVfit = %.2f %%\n', MARDj0);
fprintf('Maximum relative difference          = %.2f %%\n', maxRDj0);
fprintf('Mean |alpha_pair-alpha_BVfit|        = %.4f\n', MADalpha);
fprintf('Maximum |alpha_pair-alpha_BVfit|     = %.4f\n', maxDalpha);

fprintf('\n=== H2-pressure stress test at 298 K ===\n');
disp(PressureSummary);
fprintf('Formal C_req interval      : %.4f to %.4f\n', Cformal(1), Cformal(2));
fprintf('Illustrative alpha 0.3-0.7: %.4f to %.4f\n', Cphysical(1), Cphysical(2));

writetable(TempSummary, 'Golden_BV_temperature_summary.csv');
writetable(PressureSummary, 'Golden_BV_pressure_summary.csv');

%% 6. Prepare representative 298 K data for panel (a)
idx298 = find(Tlist == 298, 1, 'first');
[E298, j298] = extractSeries(raw, temperatureCols(idx298,1), temperatureCols(idx298,2), currentScale);
Eeq298 = EeqT(idx298);
eta298 = E298 - Eeq298;
etaPhi298 = etaPhiT(idx298);

plotMask = abs(eta298) <= fitWindow;
etaLocal = eta298(plotMask);
jLocal = j298(plotMask);
etaGrid = linspace(-fitWindow, fitWindow, 600).';

jPairCurve = bvCurrent(etaGrid, j0PairT(idx298), alphaPairT(idx298), Tlist(idx298), R, F);
jFitCurve = bvCurrent(etaGrid, j0FitT(idx298), alphaFitT(idx298), Tlist(idx298), R, F);
jGoldenPlus = interpNoExtrap(eta298, j298, +etaPhi298);
jGoldenMinus = interpNoExtrap(eta298, j298, -etaPhi298);

%% 7. Create the 2-by-2 figure
fig = figure('Color','w','Units','centimeters','Position',[2 2 18.5 14.5]);
tl = tiledlayout(fig, 2, 2, 'TileSpacing','compact', 'Padding','compact');

% A restrained, color-blind-friendly palette.
cExp = [0.35 0.35 0.35];
cPair = [0.00 0.45 0.74];
cFit = [0.85 0.33 0.10];
cAlert = [0.72 0.12 0.12];
cFormal = [0.92 0.92 0.92];
cPhysical = [0.82 0.91 0.84];

% -------- Panel (a): representative 298 K reconstruction --------
ax1 = nexttile(tl,1); hold(ax1,'on'); box(ax1,'on');
hExp = plot(ax1, 1e3*etaLocal, 1e3*jLocal, 'o', ...
    'Color',cExp,'MarkerSize',3.2,'MarkerFaceColor',[0.82 0.82 0.82], ...
    'LineStyle','none','DisplayName','Experiment');
hPair = plot(ax1, 1e3*etaGrid, 1e3*jPairCurve, '-', ...
    'Color',cPair,'LineWidth',1.8,'DisplayName','Golden-pair prediction');
hFit = plot(ax1, 1e3*etaGrid, 1e3*jFitCurve, '--', ...
    'Color',cFit,'LineWidth',1.5,'DisplayName','Local BV fit');
xline(ax1, +1e3*etaPhi298, ':', 'Color',[0.55 0.55 0.55], 'HandleVisibility','off');
xline(ax1, -1e3*etaPhi298, ':', 'Color',[0.55 0.55 0.55], 'HandleVisibility','off');
hGold = plot(ax1, 1e3*[+etaPhi298, -etaPhi298], 1e3*[jGoldenPlus, jGoldenMinus], 'd', ...
    'LineStyle','none','MarkerSize',6,'MarkerEdgeColor',cAlert, ...
    'MarkerFaceColor',cAlert,'DisplayName','Golden points');
yline(ax1,0,'-','Color',[0.78 0.78 0.78],'HandleVisibility','off');
xline(ax1,0,'-','Color',[0.78 0.78 0.78],'HandleVisibility','off');
xlabel(ax1,'Overpotential, \it\eta\rm (mV)');
ylabel(ax1,'Specific current density, \itj\rm (mA cm^{-2})');
% title(ax1,'(a) 298 K: two-point reconstruction','FontWeight','bold');
text(ax1,-48,270,'(a)', ...
    'FontName',fontName,'FontSize',14,'FontWeight','bold');
legend(ax1,[hExp hPair hFit hGold],'Location','northwest','Box','off');
% infoText = sprintf('j_{0,pair} = %.1f mA cm^{-2}\n%s = %.3f\nR^2 = %.5f', ...
%     1e3*j0PairT(idx298), 'a_{pair}', alphaPairT(idx298), R2PairT(idx298));
% text(ax1,0.3,0.06,infoText,'Units','normalized','FontSize',8.5, ...
%     'VerticalAlignment','bottom','Interpreter','latex');
infoText = sprintf('$j_{0,pair} = %.0f\\ \\mathrm{mA\\ cm^{-2}}$\n$a_{pair} = %.2f$\n$R^2 = %.4f$', ...
    1e3*j0PairT(idx298), alphaPairT(idx298), R2PairT(idx298));
text(ax1,0.3,0.06,infoText,'Units','normalized','FontSize',8.5, ...
    'VerticalAlignment','bottom','Interpreter','latex');
styleAxes(ax1);

% -------- Panel (b): j0 consistency across temperature --------
ax2 = nexttile(tl,2); hold(ax2,'on'); box(ax2,'on');
xj = 1e3*j0FitT;
yj = 1e3*j0PairT;
lo = 0.95*min([xj; yj]);
hi = 1.05*max([xj; yj]);
plot(ax2,[lo hi],[lo hi],'--','Color',[0.35 0.35 0.35],'LineWidth',1.0,'DisplayName','1:1');
plot(ax2,xj,yj,'o','LineStyle','none','MarkerSize',6, ...
    'MarkerFaceColor',cPair,'MarkerEdgeColor','w','LineWidth',0.8, ...
    'DisplayName','Temperature series');
for k = 1:nT
    text(ax2,xj(k),yj(k),sprintf('  %d K',Tlist(k)), ...
        'FontSize',7.5,'VerticalAlignment','middle');
end
xlim(ax2,[lo hi]); ylim(ax2,[lo hi]);
axis(ax2,'square');
xlabel(ax2,'\itj\rm_{0,BVfit} (mA cm^{-2})');
ylabel(ax2,'\itj\rm_{0,pair} (mA cm^{-2})');
% title(ax2,'(b) Two-point vs full-window j_0','FontWeight','bold');
text(ax2,75,235,'(b)', ...
    'FontName',fontName,'FontSize',14,'FontWeight','bold');
% text(ax2,0.05,0.93,sprintf('Mean relative difference = %.2f%%',MARDj0), ...
%     'Units','normalized','FontSize',8.5,'VerticalAlignment','top');
styleAxes(ax2);

% -------- Panel (c): alpha consistency --------
ax3 = nexttile(tl,3); hold(ax3,'on'); box(ax3,'on');
xBand = [min(Tlist)-4, max(Tlist)+4];
hPhysC = shadeBand(ax3, xBand, alphaPhysical(1), alphaPhysical(2), cPhysical, 0.60);
hAP = plot(ax3,Tlist,alphaPairT,'o-','Color',cPair,'LineWidth',1.5, ...
    'MarkerSize',5.5,'MarkerFaceColor',cPair,'DisplayName','$a_\mathrm{pair}$');
hAF = plot(ax3,Tlist,alphaFitT,'s--','Color',cFit,'LineWidth',1.4, ...
    'MarkerSize',5.2,'MarkerFaceColor','w','DisplayName','$a_\mathrm{BVfit}$');
yline(ax3,0.5,':','Color',[0.35 0.35 0.35],'LineWidth',1.0,'HandleVisibility','off');
xlim(ax3,xBand); ylim(ax3,[0.25 0.75]);
xlabel(ax3,'Temperature (K)');
ylabel(ax3,'Effective transfer coefficient, $a$','Interpreter','latex');
% title(ax3,'(c) Two-point vs full-window a','FontWeight','bold');
text(ax3,275,0.73,'(c)', ...
    'FontName',fontName,'FontSize',14,'FontWeight','bold');
styleAxes(ax3);
lgdC=legend(ax3,[hPhysC hAP hAF],{'Illustrative $0.3 \leq a\rm \leq 0.7$','$a_\mathrm{pair}$','$a_\mathrm{BVfit}$'}, ...
    'Location','southeast','Box','on','Interpreter','latex');
% alphaDiffText = ['Mean |\Deltaa| = ' num2str(MADalpha,'%.4f')];
% text(ax3,0.04,0.08,alphaDiffText,'Units','normalized','FontSize',8.5);


% -------- Panel (d): H2-pressure stress test --------
ax4 = nexttile(tl,4); hold(ax4,'on'); box(ax4,'on');
xBandP = [min(pH2)*0.90, max(pH2)*1.06];
validC = CreqPlus(isfinite(CreqPlus));
yUpper = max(1.82, 1.06*max(validC));
hFormal = shadeBand(ax4, xBandP, Cformal(1), Cformal(2), cFormal, 0.85);
hPhysical = shadeBand(ax4, xBandP, Cphysical(1), Cphysical(2), cPhysical, 0.78);
hC = plot(ax4,pH2,CreqPlus,'o-','Color',cPair,'LineWidth',1.6, ...
    'MarkerSize',5.5,'MarkerFaceColor',cPair,'DisplayName','C_{req,+}');
yline(ax4,phi,'--','Color',[0.35 0.35 0.35],'LineWidth',1.0,'HandleVisibility','off');

failMask = CreqPlus > phi;
if any(failMask)
    plot(ax4,pH2(failMask),CreqPlus(failMask),'s','LineStyle','none', ...
        'MarkerSize',7,'MarkerFaceColor',cAlert,'MarkerEdgeColor',cAlert, ...
        'HandleVisibility','off');
    failIdx = find(failMask);
    for q = 1:numel(failIdx)
        k = failIdx(q);
        alphaLabel = ['$a_\mathrm{req}$=' num2str(alphaReqPlus(k),'%.2f')];
        text(ax4,pH2(k),CreqPlus(k)+0.055, alphaLabel, ...
            'FontSize',8.5,'HorizontalAlignment','center','Color',cAlert,'Interpreter','latex');
    end
end

xlim(ax4,xBandP);
set(ax4,'XDir','reverse');
ylim(ax4,[0.60 yUpper]);
xlabel(ax4,'Hydrogen partial pressure, $p_{H_2}$ (bar)','Interpreter','latex');
ylabel(ax4,'$C_{req,+} = j_{0,micro}/J_{\phi,+}$','Interpreter','latex');
% title(ax4,'(d) H_2-pressure stress test','FontWeight','bold');
text(ax4,0.132,1.75,'(d)', ...
    'FontName',fontName,'FontSize',14,'FontWeight','bold');

lgdD=legend(ax4,[hPhysical hFormal hC], ...
    {'Illustrative $a = 0.3-0.7$','Formal $0 \leq a \leq 1$','$C_\mathrm{req,+}$'}, ...
    'Location','southeast','Box','on','Interpreter','latex');
styleAxes(ax4);

% sgtitle(tl,'Experimental tests of golden-point consistency using Pt/C HER/HOR data', ...
%     'FontWeight','bold','FontSize',11.5);

%% 8. Export publication-quality files
drawnow;

fitLegendBox(lgdC,26);
fitLegendBox(lgdD,26);

drawnow;
outBase = 'Golden_BV_experimental_cross_validation_2x2';
exportgraphics(fig, [outBase '.pdf'], 'ContentType','vector');
exportgraphics(fig, [outBase '.png'], 'Resolution',600);
print(fig, [outBase '.svg'], '-dsvg');
fprintf('\nSaved figure: %s.pdf and %s.png\n', outBase, outBase);

%% ---------------- Local functions ----------------
function [E, j] = extractSeries(raw, eCol, jCol, currentScale)
% Extract one [potential,current] series, remove invalid rows, sort by E,
% and average duplicate potential entries so that interp1 is well posed.
    E = raw(:,eCol);
    j = currentScale*raw(:,jCol);
    mask = isfinite(E) & isfinite(j);
    E = E(mask);
    j = j(mask);
    if numel(E) < 5
        error('A requested data series contains fewer than five valid points.');
    end
    [E, order] = sort(E);
    j = j(order);
    [Eu, ~, ic] = unique(E, 'sorted');
    if numel(Eu) < numel(E)
        j = accumarray(ic, j, [], @mean);
        E = Eu;
    end
end

function Eeq = estimateEquilibriumPotential(E, j, searchWindow)
% Estimate E_eq from the zero-current crossing closest to 0 V. If no sign
% change is found in the search window, use a local linear intercept.
    mask = abs(E) <= searchWindow;
    e = E(mask);
    y = j(mask);
    if numel(e) < 4
        [~, idx] = sort(abs(E), 'ascend');
        idx = idx(1:min(10,numel(idx)));
        e = E(idx);
        y = j(idx);
    end
    [e, order] = sort(e);
    y = y(order);

    rootsFound = [];
    for k = 1:(numel(e)-1)
        if y(k) == 0
            rootsFound(end+1) = e(k); %#ok<AGROW>
        elseif y(k)*y(k+1) < 0
            root = e(k) - y(k)*(e(k+1)-e(k))/(y(k+1)-y(k));
            rootsFound(end+1) = root; %#ok<AGROW>
        end
    end

    if ~isempty(rootsFound)
        [~, idx] = min(abs(rootsFound));
        Eeq = rootsFound(idx);
    else
        [~, idx] = sort(abs(e), 'ascend');
        idx = idx(1:min(8,numel(idx)));
        p = polyfit(e(idx), y(idx), 1);
        if abs(p(1)) < eps
            error('Unable to estimate E_eq because the local current slope is nearly zero.');
        end
        Eeq = -p(2)/p(1);
    end
end

function value = interpNoExtrap(x, y, target)
% Linear interpolation with no extrapolation. A missing golden point is
% returned as NaN rather than being silently extrapolated.
    if target < min(x) || target > max(x)
        value = NaN;
    else
        value = interp1(x, y, target, 'linear');
    end
end

function j0Micro = microPolarizationJ0(eta, j, T, R, F, window)
% In complementary BV kinetics, the equilibrium slope obeys
% (dj/deta)_0 = j0*F/(RT), independent of alpha.
    mask = abs(eta) <= window;
    if nnz(mask) < 4
        [~, idx] = sort(abs(eta), 'ascend');
        idx = idx(1:min(8,numel(idx)));
        x = eta(idx);
        y = j(idx);
    else
        x = eta(mask);
        y = j(mask);
    end
    p = polyfit(x, y, 1);
    j0Micro = abs((R*T/F)*p(1));
end

function [j0Fit, alphaFit] = fitComplementaryBV(eta, j, T, R, F, fitWindow, microWindow)
% Fit j = j0*[exp((1-alpha)u)-exp(-alpha*u)] over a local potential window.
% Parameter transformations enforce j0>0 and 0<alpha<1. Base-MATLAB
% fminsearch is used, so no Optimization Toolbox is required.
    mask = abs(eta) <= fitWindow & isfinite(eta) & isfinite(j);
    x = eta(mask);
    y = j(mask);
    if numel(x) < 8
        error('Too few data points are available for the local BV fit.');
    end

    j0Init = microPolarizationJ0(eta, j, T, R, F, microWindow);
    j0Init = max(j0Init, 1e-12);
    theta0 = [log(j0Init), 0];  % alpha=0.5 after logistic transformation
    scale = max(max(abs(y)), 1e-12);

    objective = @(theta) bvObjective(theta, x, y, T, R, F, scale);
    opts = optimset('Display','off','MaxIter',20000,'MaxFunEvals',50000, ...
        'TolX',1e-10,'TolFun',1e-12);
    theta = fminsearch(objective, theta0, opts);
    [j0Fit, alphaFit] = unpackBVParameters(theta);
end

function value = bvObjective(theta, eta, j, T, R, F, scale)
    [j0, alpha] = unpackBVParameters(theta);
    prediction = bvCurrent(eta, j0, alpha, T, R, F);
    residual = (prediction - j)/scale;
    value = mean(residual.^2);
    if ~isfinite(value)
        value = 1e100;
    end
end

function [j0, alpha] = unpackBVParameters(theta)
% Clamp transformed variables only to prevent numerical overflow.
    t1 = max(min(theta(1), 50), -50);
    t2 = max(min(theta(2), 50), -50);
    j0 = exp(t1);
    alpha = 1/(1 + exp(-t2));
end

function j = bvCurrent(eta, j0, alpha, T, R, F)
    u = F*eta/(R*T);
    j = j0.*(exp((1-alpha).*u) - exp(-alpha.*u));
end

function h = shadeBand(ax, xRange, yLow, yHigh, faceColor, faceAlpha)
    h = patch(ax, [xRange(1) xRange(2) xRange(2) xRange(1)], ...
        [yLow yLow yHigh yHigh], faceColor, ...
        'EdgeColor','none','FaceAlpha',faceAlpha);
end

function styleAxes(ax)
    set(ax,'FontName','Arial','FontSize',8.5,'LineWidth',0.8, ...
        'TickDir','out','Layer','top');
    grid(ax,'on');
    ax.GridAlpha = 0.12;
    ax.MinorGridAlpha = 0.06;
end


function fitLegendBox(lgd, extraWidthPt)
    % Prevent legend text from overflowing its border

    % Compact legend symbol column (R2024b+)
    if isprop(lgd,'IconColumnWidth')
        lgd.IconColumnWidth = 18;
    end

    drawnow;

    % Enlarge box while keeping its right edge fixed
    lgd.Units = 'points';
    pos = lgd.Position;

    pos(1) = pos(1) - extraWidthPt;
    pos(3) = pos(3) + extraWidthPt;

    lgd.Position = pos;
end
