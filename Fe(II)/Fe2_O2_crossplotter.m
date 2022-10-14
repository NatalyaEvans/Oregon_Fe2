%%
% This file is designed to extract the bottom Fe(II) and O2 data for
% plotting. It uses both the bottle data and the Fe(II) data

% Written 2021 09 08
% Updated 2022 02 23 with winter data
% Updated 2022 06 03 with Lohand and Bruland data
% Updated 2022 09 16 to remove Lohan and Bruland but add a colorbar for
% distance from seafloor


%%

% data.Bottomdepthm-data.Depthm
    
load('processed_fe2_data_corr')
isBBG=data.Casttype~={'BBG'}; % 1 is not BBG
data.O2uM=data.O2umolkg1.*((1000+data.Potentialdensitykgm3)./1000);
data.O2uM(isBBG==0)=data.O2umolkg1(isBBG==0).*((1000+26.5)./1000);

figure(1)
errorbar(data.O2uM(data.Cruise=={'OC2107A'} & isBBG),data.FeIInM(data.Cruise=={'OC2107A'} & isBBG),data.FeIIstdnM(data.Cruise=={'OC2107A'} & isBBG),'ko');
hold on
p1=scatter(data.O2uM(data.Cruise=={'OC2107A'} & isBBG),data.FeIInM(data.Cruise=={'OC2107A'} & isBBG),[],data.Bottomdepthm(data.Cruise=={'OC2107A'} & isBBG)-data.Depthm(data.Cruise=={'OC2107A'} & isBBG),'filled','MarkerEdgeColor','k');

errorbar(data.O2uM(data.Cruise=={'OC2107A'} & isBBG==0),data.FeIInM(data.Cruise=={'OC2107A'} & isBBG==0),data.FeIIstdnM(data.Cruise=={'OC2107A'} & isBBG==0),'kd');
p2=scatter(data.O2uM(data.Cruise=={'OC2107A'} & isBBG==0),data.FeIInM(data.Cruise=={'OC2107A'} & isBBG==0),[],data.Depthm(data.Cruise=={'OC2107A'} & isBBG==0)/100,'d','filled','MarkerEdgeColor','k');

legend([p1,p2],{'Water column','Benthic boundary layer'},'Location','Northeast')
h=colorbar;
cmap=cmocean('-tempo');
colormap(cmap);
set(get(h,'label'),'string',{'Distance from seafloor/m'},'FontSize',12);
caxis([0 50])

xlabel('O_2/{\mu}M')
ylabel('Fe(II)/nM')
xlim([0 150])
ylim([0 60])
grid on
box on
hold off
saveas(gcf,'Fe2_O2.tif')

