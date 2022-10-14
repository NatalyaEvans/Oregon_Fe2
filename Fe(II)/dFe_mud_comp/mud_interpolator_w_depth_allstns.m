%% 

% Built to interpolate mud values

clear
close all

%% read content in

load('US9_EXT_OR')
load('OC2107A_ETOP01')
load('dFe_Bottom_09_26')

FeDatabottom(FeDatabottom.Bottomdepthm > 200,:)=[];


%% clean mud data

sf = sf(sf.Mud >= 0,:);
sf = sf(sf.WaterDepth < 500,:);
sf = sf(sf.Longitude < -123.5,:);
sf = sf(sf.Latitude < 47,:);
sf = sf(sf.Latitude > 42,:);

%% Interpolate the depth

sf2 = sf(sf.WaterDepth >= 0,:);

%% Fix the depth

F = scatteredInterpolant(sf2.Longitude,sf2.Latitude,sf2.WaterDepth,'natural');
sf.sim_depth=F(sf.Longitude,sf.Latitude);


%% interpolating mud for Fe(II)

F = scatteredInterpolant(sf.Longitude,sf.Latitude,sf.WaterDepth,sf.Mud,'natural');
FeDatabottom.Mud=F(FeDatabottom.LongitudeW,FeDatabottom.LatitudeN,FeDatabottom.Bottomdepthm);
sim_mud=F(sf.Longitude,sf.Latitude,sf.WaterDepth);
xunc=mean(abs(sim_mud-sf.Mud),'all').*ones(size(FeDatabottom.Mud));

%% plotting up Fe(II) results

clear df

FeDatabottom.O2=FeDatabottom.Oxygenumolkg1.*((1026.5)./1000); % better fit with the O2 at the measured depth
% FeDatabottom.O2=FeDatabottom.BotO2.*((1026.5)./1000);

% df.mud=log(FeDatabottom.Mud);
df.dFenM=FeDatabottom.dFenM;
df.logdFenM=log10(FeDatabottom.dFenM);
% df.O2=log(FeDatabottom.O2);

df.mud=FeDatabottom.Mud;
% df.dFenM=FeDatabottom.dFenM;
df.O2=FeDatabottom.O2;

df=struct2table(df);
df(df.mud<0,:)=[];

figure()
scatter(df.mud,df.dFenM,[],df.O2,'filled','MarkerEdgeColor','k')
box on
grid on
h=colorbar;
cmap=cmocean('-matter');
colormap(cmap);
set(gca, 'YScale', 'log')
set(get(h,'label'),'string',{'O_2/{\mu}M'},'FontSize',12);
caxis([20 100])
xlabel('Mud content')
ylabel('log(dFe/nM)')
xtickformat('percentage')
% ylim([0 60])
hold off


display('dFe comp')
% lme2 = fitlme(FeDatabottom,'dFenM ~ Mud*O2*Shelfwidth')
lme2 = fitlme(df,'logdFenM ~ mud*O2')
lme2.Rsquared



