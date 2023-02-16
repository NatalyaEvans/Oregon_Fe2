%%

clear
close all
load('processed_fe2_data_corr')
load('integrated_fe2_data')

colors=viridis(100);

%% start plotting
%% stn 20
ind=[data.Station==20 & data.Cast~=2];
ind2=[data2.Station==20 & data2.Cast~=2];

% Get data
x=data.FeIInM(ind);
x2=data.dFenM(ind);
x3=data2.FeIInMSampling(ind2);
err3=data2.FeIInMSampling_err(ind2);
y3=data2.Depthm(ind2);
y=data.Depthm(ind);
y2=data.Depthm(ind);
err=data.FeIIstdnM(ind);
y(isnan(x))=[];
err(isnan(x))=[];
x(isnan(x))=[];

y2(isnan(x2))=[];
x2(isnan(x2))=[];

y3(isnan(x3))=[];
err3(isnan(x3))=[];
x3(isnan(x3))=[];

figure(1)
p1=errorbar(x,y,[],[],err,err,'ko-','MarkerFaceColor','k');
hold on
p3=errorbar(x3,y3,[],[],err3,err3,'r^','MarkerFaceColor','r');
p2=plot(x2,y2,'bd-','MarkerFaceColor','b');
ylim([0 100])

% h=colorbar;
% colormap(colors)
% set(get(h,'label'),'string','Time/min since sample collected');
% xlabel('Fe/nM')
ylabel('Height above seafloor/cm')
legend([p1,p3,p2],{'Fe(II)','Fe(II)_{t=0}','dFe'})
xlim([0 60])
grid on
set(gca,'XTickLabel',[])
hold off

figure(2)
% Get data
x=data.O2umolkg1(ind);
y=data.Depthm(ind);
plot(x,y,'mo-','MarkerFaceColor','m');
% xlabel('O_2/{\mu}mol kg^{-1}')
ylim([0 100])
xlim([30 85])
grid on
% colorbar
set(gca,'XTickLabel',[],'YTickLabel',[])
hold off

figure(3)
title('Station 20')

%% start plotting
%% stn 33
ind=[data.Station==33 & data.Casttype=='BBG'];
ind2=[data2.Station==33 & data2.Casttype=='BBG'];

% Get data
x=data.FeIInM(ind);
x2=data.dFenM(ind);
x3=data2.FeIInMSampling(ind2);
err3=data2.FeIInMSampling_err(ind2);
y3=data2.Depthm(ind2);
y=data.Depthm(ind);
y2=data.Depthm(ind);
err=data.FeIIstdnM(ind);
y(isnan(x))=[];
err(isnan(x))=[];
x(isnan(x))=[];

y2(isnan(x2))=[];
x2(isnan(x2))=[];

y3(isnan(x3))=[];
err3(isnan(x3))=[];
x3(isnan(x3))=[];

figure(4)
p1=errorbar(x,y,[],[],err,err,'ko-','MarkerFaceColor','k');
hold on
p3=errorbar(x3,y3,[],[],err3,err3,'r^','MarkerFaceColor','r');
p2=plot(x2,y2,'bd-','MarkerFaceColor','b');
ylim([0 100])
xlim([0 60])

% h=colorbar;
% colormap(colors)
% set(get(h,'label'),'string','Time/min since sample collected');
xlabel('Fe/nM')
ylabel('Height above seafloor/cm')
% legend([p1,p3,p2],{'Fe(II)','Sampled Fe(II)','dFe'})
grid on
hold off

figure(5)
% Get data
x=data.O2umolkg1(ind);
y=data.Depthm(ind);
plot(x,y,'mo-','MarkerFaceColor','m');
xlabel('O_2/{\mu}mol kg^{-1}')
ylim([0 100])
xlim([30 85])
% colorbar
grid on
set(gca,'YTickLabel', [])
hold off

figure(6)
title('Station 33')



