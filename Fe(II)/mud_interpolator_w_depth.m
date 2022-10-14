%% 

% Built to interpolate mud values

clear
close all

%% read content in

load('US9_EXT_OR')
load('processed_fe2_data_corr')
load('OC2107A_ETOP01')

%% clean Fe data

data.O2uM=data.O2umolkg1.*((1000+data.Potentialdensitykgm3)./1000);
df2=data(:,{'Cruise','Station','Casttype', 'Longitude', 'Latitude','Depthm','Bottomdepthm','Samplenumber','FeIInM','FeIIstdnM','O2uM','dFenM'});
df2 = df2((df2.Cruise==2107) & (df2.Bottomdepthm <= 200) & (df2.Casttype ~= 'BBG'),:);

% load('integrated_fe2_data')
% df2=data2;

stns=unique(df2.Station);

FeIImax=[];
Botdepth=[];
BotFeII=[];
BotO2=[];
clear df3

for i=1:length(stns)
    FeIImax(i)=max(df2.FeIInM(df2.Station==stns(i)));
%     FeIImax(i)=max(df2.FeIInMSampling(df2.Station==stns(i)));

    Botdepth(i)=max(df2.Depthm(df2.Station==stns(i)));
    BotFeII(i)=df2.FeIInM(df2.Station==stns(i) & df2.Depthm==Botdepth(i));
    BotFeIIstd(i)=df2.FeIIstdnM(df2.Station==stns(i) & df2.Depthm==Botdepth(i));    
    BotO2(i)=df2.O2uM(df2.Station==stns(i) & df2.Depthm==Botdepth(i));  
    df3(i,:)=df2((df2.Station==stns(i) & df2.Depthm==Botdepth(i)),:);
end

df3.FeIImax=FeIImax';
df3.Botdepth=Botdepth';
df3.BotFeII=BotFeII';
df3.BotO2=BotO2';

df3.FeIInM=[];
df3.O2uM=[];
df3.dFenM=[];
df3.Casttype=[];
df3.Depthm=[];

%% trying with dFe

data.O2uM=data.O2umolkg1.*((1000+data.Potentialdensitykgm3)./1000);
df2=data(:,{'Cruise','Station','Casttype', 'Longitude', 'Latitude','Depthm','Bottomdepthm','Samplenumber','FeIInM','FeIIstdnM','O2uM','dFenM'});
df2 = df2((df2.Cruise==2107) & (df2.Bottomdepthm < 500) & (df2.Casttype ~= 'BBG'),:);

df4=df2(isnan(df2.dFenM)==0,:); % table with onle dFe
stns=unique(df4.Station);

BotdFe=[];
Botdepth=[];
BotO2=[];
clear df5

for i=1:length(stns)
    Botdepth(i)=max(df4.Depthm(df4.Station==stns(i)));
    BotdFe(i)=df4.dFenM(df4.Station==stns(i) & df4.Depthm==Botdepth(i));
    BotO2(i)=df4.O2uM(df4.Station==stns(i) & df4.Depthm==Botdepth(i));  
    df5(i,:)=df4((df4.Station==stns(i) & df4.Depthm==Botdepth(i)),:);
end

df5(i+1,:)=df2(df2.Samplenumber==1172,:);
df5(i+2,:)=df2(df2.Samplenumber==1190,:);


df5.Botdepth=[Botdepth 135 93]';
df5.BotdFe=[BotdFe 24.9 12.4]';
df5.BotO2=[BotO2 68.3 75.7]';

df5.FeIInM=[];
df5.FeIIstdnM=[];
df5.O2uM=[];
df5.dFenM=[];
df5.Casttype=[];
df5.Depthm=[];


%% calculate shelf width

clear shallow deep Shelfwidth
for i=1:length(df3.Latitude)
    ind=find(round(df3.Latitude(i),4,'significant')==round(coast_y,4,'significant'));
    bottom=mean(coastal_relief_3sec(ind,:),1,'omitnan');% extract just one slice
    shallow(i) = find(bottom > -30, 1, 'first');
    deep(i)  = find(bottom < -200, 1, 'first');
    Shelfwidth(i)=haversine([df3.Latitude(i),coast_x(shallow(i))],[df3.Latitude(i),coast_x(deep(i))]);
end
df3.Shelfwidth=Shelfwidth';

clear shallow deep Shelfwidth
for i=1:length(df5.Latitude)
    ind=find(round(df5.Latitude(i),4,'significant')==round(coast_y,4,'significant'));
    bottom=mean(coastal_relief_3sec(ind,:),1,'omitnan');% extract just one slice
    shallow(i) = find(bottom > -30, 1, 'first');
    deep(i)  = find(bottom < -500, 1, 'first');
    Shelfwidth(i)=haversine([df5.Latitude(i),coast_x(shallow(i))],[df5.Latitude(i),coast_x(deep(i))]);
end
df5.Shelfwidth=Shelfwidth';


%% clean mud data

sf = sf(sf.Mud >= 0,:);
sf = sf(sf.WaterDepth < 500,:);
sf = sf(sf.Longitude < -123.5,:);
sf = sf(sf.Latitude < 47,:);
sf = sf(sf.Latitude > 42,:);



%% Interpolate the depth

sf2 = sf(sf.WaterDepth >= 0,:);

% intertype={'linear','nearest','natural'};
% for i=1:length(intertype)
%     F = scatteredInterpolant(sf2.Longitude,sf2.Latitude,sf2.WaterDepth,intertype{i});
%     sim_depth=F(sf2.Longitude,sf2.Latitude);
%     figure()
%     plot(sf2.WaterDepth,sim_depth,'ko')
%     hold on
%     [m(i),b(i),r(i),sm(i),sb(i)] = lsqfitma(sf2.WaterDepth,sim_depth);
%     plot([0:1:100],[0:1:100]*m(i)+b(i),'m--')
%     xlabel('Depth/m')
%     ylabel('Simulated depth/m')
%     hold off 
%     
%     display(intertype{i})
%     sum(abs(sim_depth-sf2.WaterDepth),'all')
% end

% figure()
% scatter(sf2.Longitude,sf2.Latitude,[],sim_depth-sf2.WaterDepth,'filled')
% hold on
% plot(df3.Longitude,df3.Latitude,'kd','MarkerFaceColor','k')
% colorbar
% caxis([-10 10])
% xlabel('Longitude')
% ylabel('Latitude')
% hold off

%% Fix the depth

F = scatteredInterpolant(sf2.Longitude,sf2.Latitude,sf2.WaterDepth,'natural');
sf.sim_depth=F(sf.Longitude,sf.Latitude);

%% test which interp type works the best

% intertype={'linear','nearest','natural'};
% % for i=1:length(intertype)
% i=3;
%     F = scatteredInterpolant(sf.Longitude,sf.Latitude,sf.WaterDepth,sf.Mud,intertype{i});
%     sim_mud=F(sf.Longitude,sf.Latitude,sf.WaterDepth);
% %     figure()
% %     plot(sf.Mud,sim_mud,'ko')
% %     hold on
% %     [m(i),b(i),r(i),sm(i),sb(i)] = lsqfitma(sf.Mud,sim_mud);
% %     plot([0:1:100],[0:1:100]*m(i)+b(i),'m--')
% %     xlabel('Percent mud')
% %     ylabel('Simulated percent mud')
% %     hold off 
% %     
% %     
% %     display(intertype{i})
% %     sum(abs(sim_mud-sf.Mud),'all')
% % end
% % 
% % figure()
% % scatter(sf.Longitude,sf.Latitude,[],sim_mud-sf.Mud,'filled')
% % hold on
% % plot(df3.Longitude,df3.Latitude,'kd','MarkerFaceColor','k')
% % colorbar
% % caxis([-10 10])
% % xlabel('Longitude')
% % ylabel('Latitude')
% % hold off

%% interpolating mud for Fe(II)


F = scatteredInterpolant(sf.Longitude,sf.Latitude,sf.WaterDepth,sf.Mud,'natural');
df3.Mud=F(df3.Longitude,df3.Latitude,df3.Bottomdepthm);
sim_mud=F(sf.Longitude,sf.Latitude,sf.WaterDepth);
xunc=mean(abs(sim_mud-sf.Mud),'all').*ones(size(df3.Mud));

%% plotting up Fe(II) results

df3.logBotFeII=log(df3.BotFeII);
df3.BotFeIIstd=BotFeIIstd';
df3.xunc=xunc;
% df3(df3.logBotFeII<-10,:)=[];

figure()
errorbar(df3.Mud,df3.BotFeII,df3.BotFeIIstd,df3.BotFeIIstd,df3.xunc,df3.xunc,'ko')
hold on
scatter(df3.Mud,df3.BotFeII,[],df3.BotO2,'filled')
box on
grid on
h=colorbar;
cmap=cmocean('-matter');
colormap(cmap);
set(get(h,'label'),'string',{'O_2/{\mu}M'},'FontSize',12);
caxis([20 75])
xlabel('Mud content')
ylabel('Fe(II)/nM')
xtickformat('percentage')
% set(gca,'YTickLabels',[])
ylim([0 60])
hold off

saveas(gca,'Fe_mud.tif')


% display('Fe(II) comp')
% lme2 = fitlme(df3,'BotFeII ~ Mud*BotO2*Shelfwidth')
lme2 = fitlme(df3,'BotFeII ~ Mud*BotO2');


%% interpolating mud for dFe

df5.Mud=F(df5.Longitude,df5.Latitude,df5.Bottomdepthm);

df5.logBotdFe=log(df5.BotdFe);
df5.xunc=mean(abs(sim_mud-sf.Mud),'all').*ones(size(df5.Mud));
df5(df5.logBotdFe<-10,:)=[];

%% plotting up dFe results

figure()
scatter(df5.Mud,df5.BotdFe,[],df5.BotO2,'filled','MarkerEdgeColor','k')
box on
grid on
set(gca, 'YScale', 'log')
h=colorbar;
cmap=cmocean('-matter');
colormap(cmap);
set(get(h,'label'),'string',{'O_2/{\mu}M'},'FontSize',12);
caxis([20 75])
xlabel('Mud content')
ylabel('dFe/nM')
xtickformat('percentage')
ylim([0 60])
hold off

display('dFe comp')
% lme2 = fitlme(df5,'BotdFe ~ Mud*BotO2*Shelfwidth')
lme2 = fitlme(df5,'logBotdFe ~ Mud*BotO2')




% 
