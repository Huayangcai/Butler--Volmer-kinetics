%% three_core_theory_figures.m
% Three core figures for the coupled Golden-overpotential / dual-channel theory
%
% Figure 1: Reference-point innovation
%           Golden overpotential -> invariant competition state
%
% Figure 2: Kinetic generalization
%           Symmetric golden estimator -> asymmetric-BV corrected estimator
%
% Figure 3: Model diagnostic + experimental test
%           BV admissibility window + Table 3 HER data
%
% The script directly generates and exports three publication-style figures.
% MATLAB R2020a+ is recommended for exportgraphics.

clear; close all; clc;

%% ------------------------------------------------------------------------
% Common definitions
% -------------------------------------------------------------------------
phi = (1 + sqrt(5))/2;
lnphi = log(phi);

fontName = 'Arial';
fontSize = 13;
lineWidth = 2.2;

fprintf('Golden ratio phi = %.8f\n', phi);
fprintf('1/phi = %.8f\n', 1/phi);
fprintf('ln(phi) = %.8f\n\n', lnphi);

%% ========================================================================
% FIGURE 1
% REFERENCE-POINT INNOVATION
%
% Dual-channel normalized variables:
%       beta = S/N = tanh(xi)
%       m    = M/N = sech(xi)
%
% Hence:
%       beta^2 + m^2 = 1
%
% Golden competition state:
%       |xi| = ln(phi)
%
% Therefore:
%       beta_phi = +/- 1/sqrt(5)
%       m_phi    = 2/sqrt(5)
%
% This figure shows that the Golden point is an invariant point of the
% normalized competition geometry rather than merely the current condition
% j = j0 of symmetric BV.
% ========================================================================

xi = linspace(-4, 4, 1200);
beta = tanh(xi);
m = 1 ./ cosh(xi);

beta_g = 1/sqrt(5);
m_g = 2/sqrt(5);

f1 = figure('Color','w','Position',[80 80 900 720]);
ax1 = axes(f1);
hold(ax1,'on');

% Universal normalized master curve
plot(ax1, beta, m, 'k-', 'LineWidth', 2.8);

% Reference axes
plot(ax1, [-1.02 1.02], [0 0], 'k-', 'LineWidth', 0.8);
plot(ax1, [0 0], [0 1.03], 'k-', 'LineWidth', 0.8);

% Equilibrium state
plot(ax1, 0, 1, 's', 'MarkerSize', 10, ...
    'MarkerFaceColor', [0.25 0.25 0.25], 'MarkerEdgeColor', 'k');

% Golden competition states
plot(ax1,  beta_g, m_g, 'o', 'MarkerSize', 12, ...
    'MarkerFaceColor', [0.85 0.33 0.10], 'MarkerEdgeColor', 'k');
plot(ax1, -beta_g, m_g, 'o', 'MarkerSize', 12, ...
    'MarkerFaceColor', [0.85 0.33 0.10], 'MarkerEdgeColor', 'k');

% Guide lines
plot(ax1, [ beta_g beta_g], [0 m_g], '--', 'Color',[0.45 0.45 0.45], 'LineWidth',1.2);
plot(ax1, [-beta_g -beta_g], [0 m_g], '--', 'Color',[0.45 0.45 0.45], 'LineWidth',1.2);
plot(ax1, [-beta_g beta_g], [m_g m_g], '--', 'Color',[0.45 0.45 0.45], 'LineWidth',1.2);

% Direction arrows along the semicircle
iL = find(xi > -1.25, 1);
iR = find(xi >  1.05, 1);
quiver(ax1, beta(iL), m(iL), ...
    beta(iL+15)-beta(iL), m(iL+15)-m(iL), 0, ...
    'k', 'LineWidth',1.3, 'MaxHeadSize',2);
quiver(ax1, beta(iR), m(iR), ...
    beta(iR+15)-beta(iR), m(iR+15)-m(iR), 0, ...
    'k', 'LineWidth',1.3, 'MaxHeadSize',2);

% Labels
text(ax1, 0.03, 1.005, 'Equilibrium: $\xi=0$', ...
    'Interpreter','latex','FontSize',fontSize,'VerticalAlignment','bottom');

text(ax1, beta_g+0.035, m_g+0.025, ...
    {'Anodic Golden state', '$\xi=+\ln\phi$', ...
     '$(\beta,m)=(1/\sqrt{5},\,2/\sqrt{5})$'}, ...
    'Interpreter','latex','FontSize',fontSize-1, ...
    'HorizontalAlignment','left','VerticalAlignment','bottom');

text(ax1, -beta_g-0.035, m_g+0.025, ...
    {'Cathodic Golden state', '$\xi=-\ln\phi$', ...
     '$(\beta,m)=(-1/\sqrt{5},\,2/\sqrt{5})$'}, ...
    'Interpreter','latex','FontSize',fontSize-1, ...
    'HorizontalAlignment','right','VerticalAlignment','bottom');

text(ax1, 0, 0.13, ...
    {'Universal competition-state criterion:', ...
     '$|\xi|=\ln\phi$', ...
     '$\beta^2+m^2=1$'}, ...
    'Interpreter','latex','FontSize',fontSize+1, ...
    'HorizontalAlignment','center','VerticalAlignment','middle');

xlabel(ax1, 'Signed dominance, $\beta=S/\mathcal{N}=\tanh\xi$', ...
    'Interpreter','latex','FontSize',fontSize+1);
ylabel(ax1, 'Normalized coexistence, $m=M/\mathcal{N}=\mathrm{sech}\xi$', ...
    'Interpreter','latex','FontSize',fontSize+1);
% title(ax1, {'Figure 1. Reference-point innovation', ...
%     'Golden overpotential as an invariant dual-channel competition state'}, ...
%     'FontName',fontName,'FontSize',fontSize+2,'FontWeight','bold');

axis(ax1,'equal');
xlim(ax1,[-1.05 1.05]);
ylim(ax1,[0 1.08]);
set(ax1,'FontName',fontName,'FontSize',fontSize,'LineWidth',1.1, ...
    'Box','off','TickDir','out');
grid(ax1,'off');

% Export
try
    exportgraphics(f1,'Fig1_ReferencePointInnovation.pdf','ContentType','vector');
    exportgraphics(f1,'Fig1_ReferencePointInnovation.png','Resolution',600);
catch
    print(f1,'Fig1_ReferencePointInnovation','-dpdf','-painters');
    print(f1,'Fig1_ReferencePointInnovation','-dpng','-r600');
end

%% ========================================================================
% FIGURE 2
% KINETIC GENERALIZATION
%
% Complementary BV convention:
%       alpha_a = 1-a
%       alpha_c = a
%
% Golden branch:
%       F*eta_phi/(2RT) = s*ln(phi)
%       s = +1 anodic
%       s = -1 cathodic
%
% Golden-current amplitude:
%       |j_phi|/j0 = phi^[s(1-2a)]
%
% Corrected estimator:
%       j0_corr = |j_phi| * phi^[s(2a-1)]
%
% Therefore:
%       j0_corr/j0 = 1
%
% This figure directly visualizes the failure of j_phi=j0 away from a=0.5
% and the exact collapse obtained after the correction.
% ========================================================================

a = linspace(0,1,800);

sA = +1;   % anodic Golden branch
sC = -1;   % cathodic Golden branch

jphi_over_j0_A = phi .^ (sA .* (1 - 2*a));
jphi_over_j0_C = phi .^ (sC .* (1 - 2*a));

corr_A = phi .^ (sA .* (2*a - 1));
corr_C = phi .^ (sC .* (2*a - 1));

j0corr_over_j0_A = jphi_over_j0_A .* corr_A;
j0corr_over_j0_C = jphi_over_j0_C .* corr_C;

f2 = figure('Color','w','Position',[120 100 980 690]);
ax2 = axes(f2);
hold(ax2,'on');

% Uncorrected Golden-current ratios
plot(ax2, a, jphi_over_j0_A, '-', 'LineWidth',lineWidth);
plot(ax2, a, jphi_over_j0_C, '--', 'LineWidth',lineWidth);

% Exact corrected result; anodic/cathodic curves are identical (=1)
plot(ax2, a, j0corr_over_j0_A, 'k-', 'LineWidth',3.0);

% Symmetric-BV point
plot(ax2, 0.5, 1, 'ko', 'MarkerFaceColor','w', 'MarkerSize',10, 'LineWidth',1.6);
xline(ax2,0.5,'k:','LineWidth',1.3);
yline(ax2,1,'k:','LineWidth',1.3);

% Boundary labels
text(ax2,0.02,phi+0.01,'$\phi$', ...
    'Interpreter','latex','FontSize',fontSize+1,'VerticalAlignment','bottom');
text(ax2,0.02,1/phi-0.01,'$1/\phi$', ...
    'Interpreter','latex','FontSize',fontSize+1,'VerticalAlignment','top');

% Equation box
% text(ax2,0.5,1.47, ...
%     {'Uncorrected Golden current:', ...
%      '$|j_\phi|/j_0=\phi^{\,s(1-2a)}$', ...
%      '', ...
%      'Corrected estimator:', ...
%      '$j_{0,\mathrm{corr}}=|j_\phi|\,\phi^{\,s(2a-1)}$', ...
%      '$\Rightarrow\;j_{0,\mathrm{corr}}/j_0=1$'}, ...
%     'Interpreter','latex','FontSize',fontSize, ...
%     'HorizontalAlignment','center','VerticalAlignment','middle');

text(ax2,0.5,0.90,'Symmetric BV: $a=0.5$', ...
    'Interpreter','latex','FontSize',fontSize+1, ...
    'HorizontalAlignment','center','VerticalAlignment','top');

xlabel(ax2,'Transfer coefficient, $a$', ...
    'Interpreter','latex','FontSize',fontSize+1);
ylabel(ax2,'Normalized current / exchange-current estimate', ...
    'FontName',fontName,'FontSize',fontSize+1);

% title(ax2, {'Figure 2. Kinetic generalization', ...
%     'Transfer-coefficient-corrected Golden estimator'}, ...
%     'FontName',fontName,'FontSize',fontSize+2,'FontWeight','bold');

legend(ax2, ...
    {'$|j_\phi|/j_0$  (anodic, $s=+1$)', ...
     '$|j_\phi|/j_0$  (cathodic, $s=-1$)', ...
     '$j_{0,\mathrm{corr}}/j_0$  (both branches)'}, ...
    'Interpreter','latex','Location','north','NumColumns',3, ...
    'Box','off','FontSize',fontSize+1);

xlim(ax2,[0 1]);
ylim(ax2,[0.55 1.70]);
set(ax2,'FontName',fontName,'FontSize',fontSize,'LineWidth',1.1, ...
    'Box','off','TickDir','out');
grid(ax2,'on');
ax2.GridAlpha = 0.12;

% Export
try
    exportgraphics(f2,'Fig2_KineticGeneralization.pdf','ContentType','vector');
    exportgraphics(f2,'Fig2_KineticGeneralization.png','Resolution',600);
catch
    print(f2,'Fig2_KineticGeneralization','-dpdf','-painters');
    print(f2,'Fig2_KineticGeneralization','-dpng','-r600');
end

%% ========================================================================
% FIGURE 3
% BV ADMISSIBILITY WINDOW + TABLE 3 HER DATA
%
% The original paper reports Table 3 values for HER measured on the
% cathodic (negative-overpotential) Golden branch. In the present notation:
%
%       C_req = j0_ref / |j_phi|
%
% where j0_ref is the Tafel-extrapolated exchange current density and
% |j_phi| is the current magnitude at the Golden overpotential.
%
% For complementary asymmetric BV kinetics:
%
%       C_req = phi^[s(2*a_req - 1)]
%
% and therefore
%
%       a_req = 1/2 * [1 + s*ln(C_req)/ln(phi)]
%
% For HER Table 3:
%
%       s = -1  (cathodic branch)
%
% The physical complementary-BV range 0 <= a_req <= 1 implies
%
%       1/phi <= C_req <= phi.
%
% Panel (a): theoretical admissibility map with the Table 3 points that
%            remain inside the physical complementary-BV window.
%
% Panel (b): all Table 3 correction factors on a logarithmic axis, making
%            the in-window / out-of-window classification explicit.
% ========================================================================

Creq = logspace(log10(0.35),log10(2.85),1000);

a_req_A = 0.5 .* (1 + log(Creq)./lnphi);  % s = +1, anodic
a_req_C = 0.5 .* (1 - log(Creq)./lnphi);  % s = -1, cathodic

Cmin = 1/phi;
Cmax = phi;

% -------------------------------------------------------------------------
% Table 3 data from Heinschke and Schneider, J. Mater. Chem. A (2026)
% Units of current density: mA cm^-2
%
% Metal   j0(Tafel, eta->0)   |j_phi| at Golden overpotential
% -------------------------------------------------------------------------
metal = {'Pd','Pt','Rh','Ir','Co','Re','Ru','Ni','Ag'};
j0_ref_exp = [1.259, 0.794, 1.906, 1.698, 0.200, 0.009, 0.027, 0.021, 0.008];
jphi_exp   = [1.170, 0.525, 1.250, 1.244, 0.682, 0.325, 1.357, 0.992, 0.742];

% Required correction in the notation of the present theory
Creq_exp = j0_ref_exp ./ jphi_exp;

% HER uses the cathodic Golden branch, s = -1
s_exp = -1;
a_req_exp = 0.5 .* (1 + s_exp .* log(Creq_exp)./lnphi);

% BV admissibility classification
is_admissible = (Creq_exp >= Cmin) & (Creq_exp <= Cmax) & ...
                (a_req_exp >= 0) & (a_req_exp <= 1);

fprintf('\nTable 3 HER diagnostic:\n');
fprintf('Metal     C_req       a_req(cathodic)    BV-admissible\n');
for k = 1:numel(metal)
    fprintf('%-4s    %8.5f       %8.4f          %d\n', ...
        metal{k}, Creq_exp(k), a_req_exp(k), is_admissible(k));
end
fprintf('\n');

% Publication colors
colWin  = [0.90 0.95 0.90];
colOut  = [0.96 0.92 0.92];
colA    = [0.00 0.45 0.74];
colC    = [0.85 0.33 0.10];
colIn   = [0.20 0.55 0.25];
colFail = [0.65 0.15 0.15];

f3 = figure('Color','w','Position',[120 100 980 690]);
tl = tiledlayout(f3,1,2,'TileSpacing','compact','Padding','compact');

%% ------------------------------------------------------------------------
% FIGURE 3(a): theoretical admissibility map + admissible Table 3 points
% -------------------------------------------------------------------------
ax3a = nexttile(tl,1);
hold(ax3a,'on');

% Background regions
hWin = patch(ax3a, [Cmin Cmax Cmax Cmin], [0 0 1 1], ...
    colWin, 'EdgeColor','none','FaceAlpha',0.90);

patch(ax3a, [0.35 Cmin Cmin 0.35], [-0.65 -0.65 1.65 1.65], ...
    colOut, 'EdgeColor','none','FaceAlpha',0.45);
patch(ax3a, [Cmax 2.85 2.85 Cmax], [-0.65 -0.65 1.65 1.65], ...
    colOut, 'EdgeColor','none','FaceAlpha',0.45);

% Required transfer-coefficient curves
hA = plot(ax3a,Creq,a_req_A,'-','Color',colA,'LineWidth',lineWidth);
hC = plot(ax3a,Creq,a_req_C,'--','Color',colC,'LineWidth',lineWidth);

% Physical boundaries
yline(ax3a,0,'k-','LineWidth',1.1);
yline(ax3a,1,'k-','LineWidth',1.1);
xline(ax3a,Cmin,'k--','LineWidth',1.3);
xline(ax3a,1,'k:','LineWidth',1.2);
xline(ax3a,Cmax,'k--','LineWidth',1.3);

% Critical points
plot(ax3a,[Cmin 1 Cmax],[0 0.5 1],'ko', ...
    'MarkerFaceColor','w','MarkerSize',6);
plot(ax3a,[Cmin 1 Cmax],[1 0.5 0],'ks', ...
    'MarkerFaceColor','w','MarkerSize',6);

% Table 3 HER points that are physically admissible
idxIn = find(is_admissible);
hExp = scatter(ax3a,Creq_exp(idxIn),a_req_exp(idxIn),72, ...
    'o','MarkerFaceColor',colIn,'MarkerEdgeColor','k','LineWidth',0.9);

for n = 1:numel(idxIn)
    k = idxIn(n);
    % Small hand-tuned offsets avoid overlap for Pt/Rh
    dx = 1.025;
    dy = 0.035;
    if strcmp(metal{k},'Rh')
        dy = -0.035;
    elseif strcmp(metal{k},'Pt')
        dy = 0.050;
    elseif strcmp(metal{k},'Ir')
        dy = 0.045;
    elseif strcmp(metal{k},'Pd')
        dx = 1.035;
        dy = 0.045;
    end
    text(ax3a,Creq_exp(k)*dx,a_req_exp(k)+dy,metal{k}, ...
        'FontName',fontName,'FontSize',fontSize-1, ...
        'HorizontalAlignment','left','VerticalAlignment','middle');
end

% Region annotation
text(ax3a,1,1.36, ...
    {'Complementary-BV admissible window', ...
     '$1/\phi\leq C_{\mathrm{req}}\leq\phi$', ...
     '$0\leq a_{\mathrm{req}}\leq1$'}, ...
    'Interpreter','latex','FontSize',fontSize, ...
    'HorizontalAlignment','center','VerticalAlignment','middle');

% Panel label
text(ax3a,0.36,1.52,'(a)', ...
    'FontName',fontName,'FontSize',fontSize+2,'FontWeight','bold');

xlabel(ax3a,'Required correction factor, $C_{\mathrm{req}}=j_{0,\mathrm{ref}}/|j_\phi|$', ...
    'Interpreter','latex','FontSize',fontSize+1);
ylabel(ax3a,'Required transfer coefficient, $a_{\mathrm{req}}$', ...
    'Interpreter','latex','FontSize',fontSize+1);

legend(ax3a,[hWin hA hC hExp], ...
    {'BV-admissible region', ...
     '$a_{\mathrm{req}}$ (anodic, $s=+1$)', ...
     '$a_{\mathrm{req}}$ (cathodic, $s=-1$)', ...
     'HER data (admissible)'}, ...
    'Interpreter','latex','Location','southoutside', ...
    'NumColumns',2,'Box','off','FontSize',fontSize-1);

set(ax3a,'XScale','log');
xlim(ax3a,[0.35 2.85]);
ylim(ax3a,[-0.60 1.60]);
xticks(ax3a,[0.4 0.5 Cmin 0.8 1 Cmax 2 2.5]);
xticklabels(ax3a,{'0.4','0.5','1/\phi','0.8','1','\phi','2','2.5'});
set(ax3a,'FontName',fontName,'FontSize',fontSize,'LineWidth',1.1, ...
    'Box','off','TickDir','out');
grid(ax3a,'on');
ax3a.GridAlpha = 0.10;

%% ------------------------------------------------------------------------
% FIGURE 3(b): all Table 3 HER correction factors
% -------------------------------------------------------------------------
ax3b = nexttile(tl,2);
hold(ax3b,'on');

yExp = 1:numel(metal);

% Full x-range needed to show every Table 3 material
xMinData = 0.008;
xMaxData = 2.10;

% Shade the admissible correction window
patch(ax3b,[Cmin Cmax Cmax Cmin], ...
    [0.3 0.3 numel(metal)+0.7 numel(metal)+0.7], ...
    colWin,'EdgeColor','none','FaceAlpha',0.90);

% Boundaries
xline(ax3b,Cmin,'k--','LineWidth',1.3);
xline(ax3b,1,'k:','LineWidth',1.2);
xline(ax3b,Cmax,'k--','LineWidth',1.3);

% Plot admissible and non-admissible materials separately
hIn = scatter(ax3b,Creq_exp(is_admissible),yExp(is_admissible),78, ...
    'o','MarkerFaceColor',colIn,'MarkerEdgeColor','k','LineWidth',0.9);

hOut = scatter(ax3b,Creq_exp(~is_admissible),yExp(~is_admissible),78, ...
    'd','MarkerFaceColor',colFail,'MarkerEdgeColor','k','LineWidth',0.9);

% Numerical C_req labels
for k = 1:numel(metal)
    xk = Creq_exp(k);
    if xk < 0.08
        xText = xk * 1.18;
        ha = 'left';
    elseif xk < Cmin
        xText = xk * 1.07;
        ha = 'left';
    else
        xText = xk / 1.06;
        ha = 'right';
    end

    text(ax3b,xText,yExp(k),sprintf('%.3g',xk), ...
        'FontName',fontName,'FontSize',fontSize-1, ...
        'HorizontalAlignment',ha,'VerticalAlignment','middle');
end

% Window annotation
text(ax3b,sqrt(Cmin*Cmax),0.62,'BV window', ...
    'FontName',fontName,'FontSize',fontSize, ...
    'HorizontalAlignment','center','VerticalAlignment','middle');

% Panel label
text(ax3b,0.0085,0.62,'(b)', ...
    'FontName',fontName,'FontSize',fontSize+2,'FontWeight','bold');

xlabel(ax3b,'Required correction factor, $C_{\mathrm{req}}=j_{0,\mathrm{Tafel}}/|j_\phi|$', ...
    'Interpreter','latex','FontSize',fontSize+1);
ylabel(ax3b,'HER catalyst', ...
    'FontName',fontName,'FontSize',fontSize+1);

yticks(ax3b,yExp);
yticklabels(ax3b,metal);
set(ax3b,'YDir','reverse');

legend(ax3b,[hIn hOut], ...
    {'Within complementary-BV window', ...
     'Outside complementary-BV window'}, ...
    'Location','southoutside','NumColumns',1, ...
    'Box','off','FontSize',fontSize-1);

set(ax3b,'XScale','log');
xlim(ax3b,[xMinData xMaxData]);
ylim(ax3b,[0.3 numel(metal)+0.7]);
xticks(ax3b,[0.01 0.02 0.05 0.1 0.2 0.5 Cmin 1 Cmax 2]);
xticklabels(ax3b,{'0.01','0.02','0.05','0.1','0.2','0.5', ...
    '1/\phi','1','\phi','2'});
set(ax3b,'FontName',fontName,'FontSize',fontSize,'LineWidth',1.1, ...
    'Box','off','TickDir','out');
grid(ax3b,'on');
ax3b.GridAlpha = 0.10;

% Export
try
    exportgraphics(f3,'Fig3_BVAdmissibility_Table3.pdf','ContentType','vector');
    exportgraphics(f3,'Fig3_BVAdmissibility_Table3.png','Resolution',600);
catch
    print(f3,'Fig3_BVAdmissibility_Table3','-dpdf','-painters');
    print(f3,'Fig3_BVAdmissibility_Table3','-dpng','-r600');
end

%% ------------------------------------------------------------------------
% Console summary
% -------------------------------------------------------------------------
fprintf('Three figures generated.\n');
fprintf('Figure 1 Golden states: beta = +/- %.6f, m = %.6f\n', beta_g, m_g);
fprintf('Figure 2 exact corrected result: j0_corr/j0 = 1 for all 0<=a<=1\n');
fprintf('Figure 3 BV-admissible correction window: %.6f <= C_req <= %.6f\n', Cmin, Cmax);
fprintf('Figure 3 Table 3 HER data: %d admissible, %d outside window.\n', ...
    sum(is_admissible), sum(~is_admissible));
