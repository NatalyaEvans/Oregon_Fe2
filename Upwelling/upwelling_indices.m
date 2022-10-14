%%

% This script plots the daily upwelling index for Oregon. Data was acquired
% at https://mjacox.com/upwelling-indices/

%% load in data and convert to data

clear
load('CUTI')

CUTI.date=datetime(CUTI.year,CUTI.month,CUTI.day);

% sum_start=find(CUTI.date==datetime(2021,06,01));
sum_start=find(CUTI.date==datetime(2021,07,01));
% sum_end=find(CUTI.date==datetime(2021,08,31));
sum_end=find(CUTI.date==datetime(2021,08,12));
OC2107A_start=find(CUTI.date==datetime(2021,07,21));
OC2107A_end=find(CUTI.date==datetime(2021,08,09));
Hecata_start=find(CUTI.date==datetime(2021,08,05));
Hecata_end=find(CUTI.date==datetime(2021,08,06));

%%

figure(1)
plot(CUTI.date(sum_start:sum_end),CUTI.d44N(sum_start:sum_end),'k-');
hold on


a=area([CUTI.date(OC2107A_start),CUTI.date(OC2107A_end)],[2.4,2.4],'facecolor',[200, 200, 200]/255, ...
    'facealpha',.5,'edgecolor','none', 'basevalue',2.1,'ShowBaseLine','off');

plot([CUTI.date(Hecata_start),CUTI.date(Hecata_start),CUTI.date(Hecata_end),CUTI.date(Hecata_end)],[2.1,-0.25,-0.25,2.1],'k--');

ylabel('Coastal Upwelling Transport Index')
ylim([-0.5 2.5])
box on
grid on
hold off
