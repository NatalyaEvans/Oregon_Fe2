%% 
% stn 34
% Just for the kinetics, redone to make sure the kinetics make sense


%% load in your calib curves

clear

% Only calibrating up to 5 nM so the high values don't mess things up

x1=[0;0.416652200000000;0.858267038000000;1.32742021600000;1.82823403900000;2.36109371900000]*10^-9; % in M now
y1=[406.755000000000;1289.47500000000;2374.74500000000;3605.49000000000;4953.92500000000;6286.82500000000];
std1=[11.2101323100000;27.5995068900000;26.8165294200000;38.0884095100000;55.9740111400000;65.5795445100000];
%% load in measured values

calcFe(1).Fe_vals=[22718.2500000000;14203.4800000000;8045.53000000000;6502.28500000000;2506.39000000000;1212.65000000000];
calcFe(1).DTPA_vals=[5632.94000000000;5706.67500000000;3460.84000000000;3122.07000000000;1591.06000000000;1232.01000000000];
calcFe(1).Fe_stderr=[53.0580054200000;42.3335651700000;38.7384861100000;36.0614922700000;17.6399332500000;23.7742872600000];
calcFe(1).Fe_vals=calcFe(1).Fe_vals-calcFe(1).DTPA_vals;
calcFe(1).time=datetime({'15:13';'16:24';'17:20';'18:17';'19:21';'20:21'},'InputFormat','HH:mm');
calcFe(1).delta_time=calcFe(1).time-min(calcFe(1).time);
% calcFe(1).meas_unc=


%% calib
pin1=[-630.308484983678;72574.5554143474;6755.64808933574];
[fit(1).f,fit(1).p,fit(1).kvg,fit(1).iter,fit(1).corp,fit(1).covp,fit(1).covr,fit(1).stdresid,fit(1).Z,fit(1).r2]=nlleasqr(x1,y1,pin1,'modfunc');
fit(1).out=fit(1).p(1) + fit(1).p(2).*x1+fit(1).p(3).*x1.^2;

figure(1)
errorbar(x1,y1,std1,std1,'ko')
hold on
plot(x1,fit(1).out,'k--')
hold off

%% concs with calib 1

syms x

for i=1:length(calcFe(1).Fe_vals)
    eqn= fit(1).p(1) + fit(1).p(2).*x + fit(1).p(3).*x.^2==calcFe(1).Fe_vals(i);
    temp=double(vpasolve(eqn,x));
    calcFe(1).Fe_fitted(i)=max(temp);
end

for i=1:length(calcFe(1).DTPA_vals)  
    eqn= fit(1).p(1) + fit(1).p(2).*x + fit(1).p(3).*x.^2==calcFe(1).DTPA_vals(i);
    temp=double(vpasolve(eqn,x));
    calcFe(1).DTPA_fitted(i)=max(temp);
end


calcFe(1).Fe_fitted(calcFe(1).Fe_fitted<0)=0;

%% uncertainty
for i=1:length(calcFe(1).Fe_vals)
    fun_l= @(x) fit(1).p(1) + fit(1).p(2).*x + fit(1).p(3).*x.^2 - calcFe(1).Fe_stderr(i) - calcFe(1).Fe_vals(i);
    fun_u= @(x) fit(1).p(1) + fit(1).p(2).*x + fit(1).p(3).*x.^2 + calcFe(1).Fe_stderr(i) - calcFe(1).Fe_vals(i);
    temp=fzero(fun_u,0);
    err(i,1)=min(temp);
    temp=fzero(fun_l,0);
    err(i,2)=min(temp);    
end
calcFe(1).Fe_uplow=err(:,2)-err(:,1);


%%

figure(2) % normal
errorbar(seconds(calcFe(1).delta_time),calcFe(1).Fe_fitted,calcFe(1).Fe_uplow,'ko','MarkerFaceColor','k')
ylabel('Measured Fe(II)/M')
xlabel('Elapsed time/sec')
title('Fe(II) oxidation from station 34 BBG')

figure(3) % ln
x=calcFe(1).delta_time(1:end-2);
y=log(calcFe(1).Fe_fitted(1:end-2))'; % natural log, matlab is stupid

plot(seconds(x)/60,y,'ko','MarkerFaceColor','k')
hold on

% fit the data
[a,sa,cov,r] = linfit(seconds(x),y,ones(size(calcFe(1).Fe_fitted(1:end-2)))');
yfit=a(1)+seconds(x).*a(2);
plot(seconds(x)/60,yfit,'r--');

% converting this to log(k)
% fittedlogk=log10(-a(2))

%%

% Rate data
O2=20.5; % micromolar, should follow up with Pete
pH=7.69; % best measurement.
T=7.64; % from water column, d=106 m, in C
S=33.98; % from water column, d=106 m, in psu

logk = 35.627 - 6.7109*(pH) + 0.5342*(pH).^2 - (5362.6./(T+273.15)) - 0.04406*S.^0.5 - 0.002847*S; % González-Santana et al 2021
% O2sat = gsw_O2sol(gsw_SA_from_SP(S,gsw_p_from_z(-110,43.82042),-124.34051 ,43.82042),...
%     gsw_CT_from_t(gsw_SA_from_SP(S,gsw_p_from_z(-110,43.82042),-124.34051 ,43.82042),T,gsw_p_from_z(-110,43.82042 )),...
%     gsw_p_from_z(-110,43.82042 ),-124.34051 ,43.82042); % in uM
O2sat=[291.450173466270]; % value from the above calc

% pred_slope=-(O2/O2sat)*10^logk; % correcting for O2 saturation, this is -k in Hz
pred_slope=-10^logk; % not correcting for O2 saturation, this is -k in Hz

plot(seconds(x)/60,a(1)+pred_slope.*seconds(x))
legend('Measurement','Best fit line','Estimated rate','Location','Southwest')


ylabel('ln(Measured Fe(II)/M)')
xlabel('Elapsed time/min')
title('Fe(II) oxidation from station 34 BBG')
hold off


