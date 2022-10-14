%% 

% Built to interpolate mud values

close all

%% read content in

load('US9_EXT_OR')
load('processed_fe2_data_corr')
load('OC2107A_ETOP01')

%% clean Fe data

data.O2uM=data.O2umolkg1.*((1000+data.Potentialdensitykgm3)./1000);
df2=data(:,{'Cruise','Station','Casttype', 'Longitude', 'Latitude','Depthm','Bottomdepthm','Samplenumber','FeIInM','FeIIstdnM','O2uM','dFenM'});
df2 = df2((df2.Cruise=='OC2107A') & (df2.Bottomdepthm < 500) & (df2.Casttype ~= 'BBG'),:);
stns=unique(df2.Station);

FeIImax=[];
Botdepth=[];
BotFeII=[];
BotO2=[];
clear df3

for i=1:length(stns)
    FeIImax(i)=max(df2.FeIInM(df2.Station==stns(i)));
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

%% dFe this time
% 
% clear df4
% j=1;
% for i=1:length(stns)
%     if sum(isnan(df2.dFenM(df2.Station==stns(i))))==0
%         BotdFe(j)=df2.dFenM(df2.Station==stns(i)));
%         Botdepth(j)=df2.Depthm(df2.Station==stns(i) & df2.dFenM==BotdFe(j));
%         BotO2(j)=df2.O2uM(df2.Station==stns(i) & df2.dFenM==BotdFe(j));
%         df4(j,:)=df2(df2.Station==stns(i) & df2.dFenM==BotdFe(j),:);
%         j=j+1;
%     end
% end
% 
% df4.BotdFe=BotdFe';
% df4.Botdepth=Botdepth';
% df4.BotO2=BotO2';
% 
% df4.FeIInM=[];
% df4.O2uM=[];
% df4.dFenM=[];
% df4.Casttype=[];
% df4.Depthm=[];

        


%% calculate shelf width

clear shallow deep Shelfwidth
for i=1:length(df3.Latitude)
    ind=find(round(df3.Latitude(i),4,'significant')==round(coast_y,4,'significant'));
    bottom=mean(coastal_relief_3sec(ind,:),1,'omitnan');% extract just one slice
    shallow(i) = find(bottom > -30, 1, 'first');
    deep(i)  = find(bottom < -500, 1, 'first');
    Shelfwidth(i)=haversine([df3.Latitude(i),coast_x(shallow(i))],[df3.Latitude(i),coast_x(deep(i))]);
end
df3.Shelfwidth=Shelfwidth';


%% clean mud data

sf = sf(sf.Mud >= 0,:);
sf = sf(sf.WaterDepth < 500,:);
sf = sf(sf.Longitude < -123.5,:);
sf = sf(sf.Latitude < 47,:);
sf = sf(sf.Latitude > 42,:);

sf2 = sf(sf.WaterDepth >= 0,:);


%% test which interp type works the best

intertype={'linear','nearest','natural'};
% for i=1:length(intertype)
i=3;
    F = scatteredInterpolant(sf2.Longitude,sf2.Latitude,sf2.WaterDepth,sf2.Mud,intertype{i});
    sim_mud=F(sf2.Longitude,sf2.Latitude,sf2.WaterDepth);
    figure()
    plot(sf2.Mud,sim_mud,'ko')
    hold on
    [m(i),b(i),r(i),sm(i),sb(i)] = lsqfitma(sf2.Mud,sim_mud);
    plot([0:1:100],[0:1:100]*m(i)+b(i),'m--')
    xlabel('Percent mud')
    ylabel('Simulated percent mud')
    hold off 
% end

    display(intertype{i})
    sum(abs(sim_mud-sf2.Mud),'all')

figure()
scatter(sf2.Longitude,sf2.Latitude,[],sim_mud-sf2.Mud,'filled')
hold on
plot(df3.Longitude,df3.Latitude,'kd','MarkerFaceColor','k')
colorbar
caxis([-10 10])
xlabel('Longitude')
ylabel('Latitude')
hold off

%% interpolating

F = scatteredInterpolant(sf2.Longitude,sf2.Latitude,sf2.WaterDepth,sf2.Mud,'natural');
df3.Mud=F(df3.Longitude,df3.Latitude,df3.Bottomdepthm);

%%

figure()
errorbar(df3.Mud,df3.BotFeII,BotFeIIstd,'ko')
hold on
scatter(df3.Mud,df3.BotFeII,[],df3.BotO2,'filled')
box on
grid on
h=colorbar;
cmap=cmocean('-matter');
colormap(cmap);
set(get(h,'label'),'string',{'O_2/{\mu}M'},'FontSize',12);
caxis([20 75])
xlabel('Mud conten')
ylabel('Fe(II)/nM')
xtickformat('percentage')
hold off

% lme2 = fitlme(df3,'BotFeII ~ Mud*BotO2*Shelfwidth')
lme2 = fitlme(df3,'BotFeII ~ Mud*BotO2')





