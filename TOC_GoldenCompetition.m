%% TOC_GoldenCompetition.m
% Table-of-contents graphic | Complementary Butler-Volmer kinetics
% Reproduces the two-panel visual concept from the supplied draft.
% MATLAB R2016b or later; no toolboxes or external files are required.
%
% Scientific meaning:
%   beta^2 + m^2 = 1, beta_phi = +/-1/sqrt(5), m_phi = 2/sqrt(5)
%   J_phi,+ = j0*phi^(1-2a), J_phi,- = j0*phi^(2a-1)
%   j0,pair = sqrt(J_phi,+ * J_phi,-)
%   a_pair = 1/2 - log(J_phi,+/J_phi,-)/(4*log(phi))
%   phi^(-2) <= J_phi,+/J_phi,- <= phi^2 is NECESSARY, not sufficient.

clear; close all; clc;

%% 1. Parameters and numerical self-checks
phi = (1 + sqrt(5))/2;
betaG = 1/sqrt(5);
mG = 2/sqrt(5);

aDemo = 0.70;  % Affects ONLY the illustrative branch-line thickness
assert(aDemo >= 0 && aDemo <= 1, 'aDemo must lie in [0, 1].');

Jplus = phi^(1-2*aDemo);      % Normalized by j0
Jminus = phi^(2*aDemo-1);     % Normalized by j0
aRecovered = 0.5 - log(Jplus/Jminus)/(4*log(phi));
tol = 1e-12;
assert(abs(tanh(log(phi))-betaG) < tol, 'Golden beta check failed.');
assert(abs(1/cosh(log(phi))-mG) < tol, 'Golden m check failed.');
assert(abs(sqrt(Jplus*Jminus)-1) < tol, 'Product check failed.');
assert(abs(aRecovered-aDemo) < tol, 'Ratio check failed.');
for a = [0, 0.5, 1]   % Verify both bounds and the symmetric case
    jp = phi^(1-2*a); jm = phi^(2*a-1);
    assert(jp/jm >= phi^(-2)-tol && jp/jm <= phi^2+tol);
    assert(abs(sqrt(jp*jm)-1) < tol);
end

%% 2. Canvas and restrained editorial palette
W = 1200; H = 600;                     % 2:1 TOC aspect ratio
ink    = [0.105, 0.245, 0.290];
muted  = [0.440, 0.585, 0.620];
teal   = [0.125, 0.620, 0.560];
coral  = [0.890, 0.435, 0.392];
gold   = [0.875, 0.632, 0.205];
paleT  = [0.919, 0.966, 0.953];
paleG  = [1.000, 0.958, 0.858];
lineC  = [0.854, 0.903, 0.900];
white  = [1, 1, 1];

fig = figure('Color',white, 'Units','pixels', ...
    'Position',[100 100 1440 720], 'PaperUnits','inches', ...
    'PaperPosition',[0 0 12 6], 'PaperSize',[12 6], ...
    'PaperPositionMode','manual', 'Renderer','painters');
ax = axes('Parent',fig,'Units','normalized', ...
    'Position',[0 0 1 1], 'XLim',[0 W], 'YLim',[0 H], ...
    'Visible','off','XColor',white,'YColor',white);
hold(ax,'on'); axis(ax,'manual');
daspect(ax,[1 1 1]);

% Top gold strip / understated bottom hairline
rectangle('Parent',ax,'Position',[0 593 W 7], ...
    'FaceColor',gold,'EdgeColor','none');
plot(ax,[22 1178],[17 17],'Color',[0.94 0.96 0.95], ...
    'LineWidth',1.0);

%% 3. Headers and center divider
circle(ax,58,539,8.5,gold,gold,0.5);
text(ax,80,539,'INVARIANT GEOMETRY','Color',ink, ...
    'FontName','Arial','FontWeight','bold','FontSize',17, ...
    'VerticalAlignment','middle');

circle(ax,692,539,8.5,coral,coral,0.5);
text(ax,714,539,'ASYMMETRIC CURRENTS','Color',ink, ...
    'FontName','Arial','FontWeight','bold','FontSize',17, ...
    'VerticalAlignment','middle');

plot(ax,[634 634],[82 522],'Color',lineC,'LineWidth',1.3);
% A small golden transition arrow across the divider
plot(ax,[599 645],[351 351],'Color',gold,'LineWidth',3);
patch(ax,[642 659 642],[360 351 342],gold,'EdgeColor','none');

%% 4. Left panel: a fixed normalized competition semicircle
xc = 321; yb = 163; R = 223;
angle = linspace(0,pi,400);

% Very faint nested arcs are decorative (not different BV curves).
for scale = [0.51 0.66 0.81]
    xx = xc + R*scale*cos(angle);
    yy = yb + R*scale*sin(angle);
    plot(ax,xx,yy,'Color',[0.972 0.950 0.900],'LineWidth',1.2);
end

% Flat beta-axis and endpoint ticks
plot(ax,[88 556],[yb yb],'Color',lineC,'LineWidth',1.8);
plot(ax,[xc-R xc-R],[yb-7 yb+7],'Color',muted,'LineWidth',1.3);
plot(ax,[xc+R xc+R],[yb-7 yb+7],'Color',muted,'LineWidth',1.3);
text(ax,561,yb-2,'$\beta$','Interpreter','latex', ...
    'FontSize',18,'Color',muted,'VerticalAlignment','middle');

% The SAME upper unit semicircle, with three colored stretches
segments = {linspace(-1,-betaG,150), ...
            linspace(-betaG,betaG,230), ...
            linspace(betaG,1,150)};
segmentColors = {teal, gold, coral};
for k = 1:3
    b = segments{k};
    xx = xc + R*b; yy = yb + R*sqrt(max(0,1-b.^2));
    plot(ax,xx,yy,'Color', ...
        0.73*white+0.27*segmentColors{k},'LineWidth',12);
    plot(ax,xx,yy,'Color',segmentColors{k},'LineWidth',5.6);
end

% Golden points: beta = +/- 1/sqrt(5), m = 2/sqrt(5)
yg = yb + R*mG;
xg = [xc-R*betaG, xc+R*betaG];
plot(ax,xg,[yg yg],':','Color',[0.88 0.72 0.39], ...
    'LineWidth',1.7);
for k = 1:2
    plot(ax,[xg(k) xg(k)],[yb yg],':', ...
        'Color',[0.88 0.74 0.49],'LineWidth',1.6);
    circle(ax,xg(k),yg,18,white,gold,3.1);
    plot(ax,xg(k),yg,'d','MarkerSize',7, ...
        'MarkerFaceColor',gold,'MarkerEdgeColor',gold);
end
text(ax,xg(1),yg-42,'-','FontName','Arial','FontSize',24, ...
    'FontWeight','bold','HorizontalAlignment','center','Color',ink);
text(ax,xg(2),yg-42,'+','FontName','Arial','FontSize',22, ...
    'FontWeight','bold','HorizontalAlignment','center','Color',ink);

text(ax,xc,469,'$\phi$','Interpreter','latex', ...
    'HorizontalAlignment','center','Color',gold,'FontSize',50);
text(ax,xc,420,'golden competition','FontName','Arial', ...
    'HorizontalAlignment','center','Color',muted,'FontSize',16);
text(ax,xc,248,'$\beta^2+m^2=1$','Interpreter','latex', ...
    'HorizontalAlignment','center','Color',[0.63 0.69 0.66], ...
    'FontSize',25);

% Invariant-coordinate summary bar
rectangle('Parent',ax,'Position',[76 46 495 72], ...
    'Curvature',[0.08 0.42], ...
    'FaceColor',paleT,'EdgeColor',[0.88 0.93 0.91], ...
    'LineWidth',1.0);
plot(ax,[328 328],[63 101],'Color',[0.78 0.87 0.84], ...
    'LineWidth',1.3);
text(ax,130,82,'$\beta_{\phi}=\pm 1/\sqrt{5}$', ...
    'Interpreter','latex','Color',ink,'FontSize',21, ...
    'VerticalAlignment','middle');
text(ax,380,82,'$m_{\phi}=2/\sqrt{5}$', ...
    'Interpreter','latex','Color',ink,'FontSize',21, ...
    'VerticalAlignment','middle');

%% 5. Right panel: asymmetric branch-current amplitudes
yC = 352; yUp = 427; yDown = 268;
xC = 717; xJoin = 838;

% Two cubic Bezier curves split at the central phi symbol.
bezierBranch(ax,[xC yC],[771 yC],[779 yUp],[xJoin yUp], ...
    coral, 4.0+2.6*Jplus);
bezierBranch(ax,[xC yC],[771 yC],[779 yDown],[xJoin yDown], ...
    teal, 4.0+2.6*Jminus);

% The line weights encode the chosen demonstration asymmetry.
arrowBranch(ax,xJoin,1162,yUp,coral,4.0+2.6*Jplus);
arrowBranch(ax,xJoin,1115,yDown,teal,4.0+2.6*Jminus);

% Golden reference splitting point (on top of curves)
circle(ax,xC,yC,30,paleG,paleG,0.5);
circle(ax,xC,yC,23,[0.977 0.868 0.574],gold,1.5);
text(ax,xC,yC+1,'$\phi$','Interpreter','latex', ...
    'Color',[0.50 0.39 0.09],'HorizontalAlignment','center', ...
    'VerticalAlignment','middle','FontSize',25);

% Explicit +/- channel signs
circle(ax,xJoin,yUp,20,white,coral,3.3);
text(ax,xJoin,yUp+2,'+','Color',coral,'FontWeight','bold', ...
    'FontName','Arial','FontSize',21, ...
    'HorizontalAlignment','center','VerticalAlignment','middle');
circle(ax,xJoin,yDown,20,white,teal,3.3);
text(ax,xJoin,yDown+2,'-','Color',teal,'FontWeight','bold', ...
    'FontName','Arial','FontSize',23, ...
    'HorizontalAlignment','center','VerticalAlignment','middle');

% Exact complementary-BV golden-current relations
text(ax,865,484,'$J_{\phi,+}=j_0\,\phi^{\,1-2a}$', ...
    'Interpreter','latex','Color',ink,'FontSize',23);
text(ax,865,312,'$J_{\phi,-}=j_0\,\phi^{\,2a-1}$', ...
    'Interpreter','latex','Color',ink,'FontSize',23);

%% 6. Paired estimates and necessary consistency bound
plot(ax,[684 1168],[209 209],'Color',lineC,'LineWidth',1.8);
text(ax,650,170, ...
    '$j_{0,\mathrm{pair}}=\sqrt{J_{\phi,+}J_{\phi,-}}$', ...
    'Interpreter','latex','Color',ink,'FontSize',21, ...
    'VerticalAlignment','middle');
text(ax,650*1.4,170, ...
    '$a_{\mathrm{pair}}=\frac{1}{2}-\frac{\ln(J_{\phi,+}/J_{\phi,-})}{4\ln\phi}$', ...
    'Interpreter','latex','Color',ink,'FontSize',21, ...
    'VerticalAlignment','middle');

rectangle('Parent',ax,'Position',[650 46 520 72], ...
    'Curvature',[0.055 0.40], ...
    'FaceColor',paleG,'EdgeColor',[0.95 0.81 0.53], ...
    'LineWidth',1.1);
text(ax,704*1.15,82, ...
    '$\phi^{-2}\leq J_{\phi,+}/J_{\phi,-}\leq\phi^{2}$', ...
    'Interpreter','latex','Color',ink,'FontSize',21, ...
    'VerticalAlignment','middle');
% text(ax,1150,65,'NECESSARY','FontName','Arial', ...
%     'Color',[0.57 0.44 0.20],'FontSize',11, ...
%     'FontWeight','bold','HorizontalAlignment','right', ...
%     'VerticalAlignment','middle');

%% 7. Export as PNG, vector PDF and SVG
outDir = fileparts(mfilename('fullpath'));
if isempty(outDir), outDir = pwd; end
outBase = fullfile(outDir,'TOC_GoldenCompetition');
drawnow;

% 12 x 6 inches; print preserves the full designed canvas.
print(fig,[outBase '.png'],'-dpng','-r600');
print(fig,[outBase '.pdf'],'-dpdf','-painters');
try
    print(fig,[outBase '.svg'],'-dsvg','-painters');
catch ME
    warning('SVG not exported on this MATLAB release: %s',ME.message);
end
fprintf('Generated: %s.png, .pdf and (when supported) .svg\n',outBase);
fprintf('Demo a=%.2f; J+/j0=%.6f; J-/j0=%.6f; recovered a=%.6f\n', ...
    aDemo,Jplus,Jminus,aRecovered);

%% Local helpers (built-in MATLAB only)
function circle(ax,cx,cy,r,face,edge,lw)
    rectangle('Parent',ax,'Position',[cx-r cy-r 2*r 2*r], ...
        'Curvature',[1 1], 'FaceColor',face, ...
        'EdgeColor',edge,'LineWidth',lw);
end

function bezierBranch(ax,p0,p1,p2,p3,col,lw)
    t = linspace(0,1,180);
    x = (1-t).^3*p0(1) + 3*(1-t).^2.*t*p1(1) + ...
        3*(1-t).*t.^2*p2(1) + t.^3*p3(1);
    y = (1-t).^3*p0(2) + 3*(1-t).^2.*t*p1(2) + ...
        3*(1-t).*t.^2*p2(2) + t.^3*p3(2);
    plot(ax,x,y,'Color',0.74*[1 1 1]+0.26*col, ...
        'LineWidth',lw+7);
    plot(ax,x,y,'Color',col,'LineWidth',lw);
end

function arrowBranch(ax,x1,x2,y,col,lw)
    plot(ax,[x1 x2-28],[y y], ...
        'Color',0.74*[1 1 1]+0.26*col,'LineWidth',lw+7);
    plot(ax,[x1 x2-27],[y y],'Color',col,'LineWidth',lw);
    patch(ax,[x2-35 x2 x2-35],[y+17 y y-17], ...
        col,'EdgeColor','none');
end
