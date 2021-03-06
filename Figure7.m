%% Script to replicate Fig. 7 in Maurer & Segall, 2018
clear

%% Parameters

% diffusivity
c = 0.01;

% seismicity parameters
Mwmax = 4.5;
Mwmin = 0.5;
b = 1;
dtau = 3e6;

%% Compute a(t)
tdays = [1, 4:4:150];
nsec = 24*3600;
ts = tdays*nsec;
at = 10 + 2*sqrt(c*ts);

%% Compute P(r_s) for each a(t)
Nx = 300; 
Nt = length(ts); 
[mx, Rx, fM1, fM2, fM3] = deal(zeros(Nx, Nt)); 
for loop = 1:Nt
    a = at(loop); 
    rhomin = mw2rs(Mwmin, dtau)./a; 
    rhomax = mw2rs(Mwmax, dtau)./a; 

    % compute P(r_s)
    [Prs, rx, ~, Pin, Pp] = Compute_Prs_num(b,rhomin,rhomax, Nx);     
    
    % re-normalize to correct size
    Rx(:,loop) = rx.*a; 
    P1 = Pin./a;
    yp = trapz(Rx(:,loop), Pin + Pp); 
    P2 = (Pin + Pp)./yp;
    P3 = Prs./a; 
    
    % convert PDF on r_s to Mw
    [mx(:,loop),fm2] = rspdf2mwpdf(Rx(:,loop), P2, dtau);
    [~,fm3] = rspdf2mwpdf(Rx(:,loop), P3, dtau);
    [~, fm1] = rspdf2mwpdf(Rx(:,loop), P1, dtau);
    fM1(:,loop) = fm1./fm1(1); 
    fM2(:,loop) = fm2./fm2(1);
    fM3(:,loop) = fm3./fm3(1); 
end

%% Plot results
MX = linspace(Mwmin, Mwmax); 
y = 10.^(-b*(MX - Mwmin)); 
cs = varycolor(length(tdays)); 
ymin = 1e-5; 

figure; 
for k = 1:size(fM1,2)
    semilogy(mx(:,k), fM1(:,k), 'color', cs(k,:))
    hold on
end
axis tight
colorbar;
ylim([ymin, 1])
xlim([Mwmin, Mwmax])
semilogy(MX, y, 'k--')
xlabel('M_W')
ylabel('Relative Frequency')
title('P_{in}')

figure; 
for k = 1:size(fM2,2)
    semilogy(mx(:,k), fM2(:,k), 'color', cs(k,:))
    hold on
end
axis tight
colorbar;
ylim([ymin, 1])
xlim([Mwmin, Mwmax])
semilogy(MX, y, 'k--')
xlabel('M_W')
ylabel('Relative Frequency')
title('P_{p}')

figure; 
for k = 1:size(fM3,2)
    semilogy(mx(:,k), fM3(:,k), 'color', cs(k,:))
    hold on
end
axis tight
colorbar;
ylim([ymin, 1])
xlim([Mwmin, Mwmax])
semilogy(MX, y, 'k--')
xlabel('M_W')
ylabel('Relative Frequency')
title('P(r_s)')

%% Create Time-integrated plots

% Discretize more finely in time to avoid numerical artifacts
ts = linspace(1, 150, 1000)*nsec;
at = 2*sqrt(c*ts);
Nx = 500; 
Nt = length(ts); 
[mx, Rx, fM1, fM2, fM3] = deal(zeros(Nx, Nt)); 
for loop = 1:Nt
    a = at(loop); 
    rhomin = mw2rs(Mwmin, dtau)./a; 
    rhomax = mw2rs(Mwmax, dtau)./a; 

    % compute P(r_s)
    [Prs, rx, ~, Pin, Pp] = Compute_Prs_num(b,rhomin,rhomax, Nx);     
%     [Prs, rx] = Compute_Prs(b,rhomin,rhomax, Nx);     
    
    % re-normalize to correct size
    Rx(:,loop) = rx.*a; 
    P1 = Pin./a;
    yp = trapz(Rx(:,loop), Pin + Pp); 
    P2 = (Pin + Pp)./yp;
    P3 = Prs./a; 
    
    % convert PDF on r_s to Mw
%     [mx(:,loop),fm] = rspdf2mwpdf(Rx(:,loop), P3, dtau);
    [mx(:,loop),fm2] = rspdf2mwpdf(Rx(:,loop), P2, dtau);
    [~,fm3] = rspdf2mwpdf(Rx(:,loop), P3, dtau);
    [~, fm1] = rspdf2mwpdf(Rx(:,loop), P1, dtau);
    fM1(:,loop) = fm1./fm1(1); 
    fM2(:,loop) = fm2./fm2(1);
    fM3(:,loop) = fm3./fm3(1); 
%     fM(:,loop) = fm./fm(1); 
end


[fM_tot1,MXT1] = compute_timeintegrated_prs(mx,fM1,ts); 
[fM_tot2,MXT2] = compute_timeintegrated_prs(mx,fM2,ts); 
[fM_tot3,MXT3] = compute_timeintegrated_prs(mx,fM3,ts); 
fMx_norm1 = fM_tot1./max(fM_tot1);
fMx_norm2 = fM_tot2./max(fM_tot2);
fMx_norm3 = fM_tot3./max(fM_tot3);

% plot the results
figure; 
semilogy(MXT1, fMx_norm1)
hold on
semilogy(MXT2, fMx_norm2)
semilogy(MXT3, fMx_norm3)
semilogy(MX, y, 'k--')
xlabel('M_W')
legend('Pin', 'Pp+Pin', 'Prs')
xlim([Mwmin, Mwmax])

