% Example script for plotting processed ADCP Data

close all

%%

load('processed_fe2_data_corr')
load('OC2107A1mbinned')
load('OC2107A_ETOP01')
colors=viridis(100);
botdepth=1300;
yrange=[0:1:botdepth];
stns=[33 32 31]; % fill in the stations

% setting up topo contour
ind=[data.Station==31 | data.Station==32 | data.Station==33];
max_lat=max(data.Latitude(ind));
min_lat=min(data.Latitude(ind));

ind=coast_y<max_lat & coast_y>min_lat;
ind2=coast_x<-124.2 & coast_x>-125.1;
bathy=mean(-coastal_relief_3sec(ind,ind2));
bathy=[bathy;ones(size(bathy)).*botdepth];


%% Load data
load('contour_uv.mat');
load('contour_xy.mat');

% tit_str='OC2102A WH 3000 kHz';
tit_str={'OC2107A OS 75 kHz narrowband','Newport Hydrographic Line'};
tit_str2={'OC2107A OS 75 kHz narrowband','Hecata Bank'};


ylim_max=700;

% Separate u/v
u = uv(:,1:2:end);
v = uv(:,2:2:end);

% Get depth
dep = zc;

% Get location and time
lon  = xyt(1,:);
lat  = xyt(2,:);
time = xyt(3,:);
time = time + datenum('31-Dec-2020'); % time is in 'days of 2021'
time2 = datetime(time,'ConvertFrom','datenum');

lon=lon-360; % change to degrees W

load('transMap');
transMap=transMap.transMap;

% Contour levels
levels = linspace(-0.2,0.2,21);

% Correct (i.e. fill in the gaps)
u(u<levels(1)) = levels(1);
u(u>levels(end)) = levels(end);
v(v<levels(1)) = levels(1);
v(v>levels(end)) = levels(end);

% XTicks
t_start = min(time);
t_stop  = max(time);

% % Fontsize
% fontsize = 12;
% close all


%% DEPTH VS TIME
% Dep/Time mesh

t1=datenum(datetime('2021-08-04 11:00:00','InputFormat','yyyy-MM-dd hh:mm:ss'));
t2=datenum(datetime('2021-08-06','InputFormat','yyyy-MM-dd'));
inds=time>t1 & time<t2;

% figure(3)
% scatter(lon(inds),lat(inds),[],time(inds),'filled')
% xlabel('Longitude')
% ylabel('Latitude')
% colorbar

% cut values outside of timeframr
lon2=lon(inds);
u2=u(:,inds);
v2=v(:,inds);

% % cut values that swerved too deep
% inds=lat(inds)<43.92 & lon2<-124.9;
% lon2(inds)=[];
% u2(:,inds)=[];
% v2(:,inds)=[];

[dep_grid,long_grid] = meshgrid(dep,lon2);
dep_grid = dep_grid';
long_grid = long_grid';


%%

% U Vel
fig = figure(1);
% sb(1) = subplot(2,1,1);
set(gca,'Color',rgb('DimGray'));
contourf(long_grid,dep_grid,u2,levels,'linestyle','none');
hold on
set(gca,'YDir','Reverse');
cb(1) = colorbar('location','eastoutside');
ylabel(cb(1),'Zonal Velocity/m s^{-1}','FontSize',12);
xlim([min(lon2), max(lon2)]);
% set(gca,'XTickLabel',[]);
ylim([min(dep) 800])
ylabel('Depth/m');
colormap(transMap)
% title(tit_str2);
hold on


x=data.Longitude(data.Station==31);
y=data.Depthm(data.Station==31);
z=round(data.Potentialdensitykgm3(data.Station==31),3,'significant');
plot(x,y,'ko-','MarkerFaceColor','k')
% scatter(x,y,[],data.FeIInM(data.Station==31),'filled');
% text(x(2:2:length(x))-0.11,y(2:2:length(x)),num2cell(z(2:2:length(x))))

x=data.Longitude(data.Station==32);
y=data.Depthm(data.Station==32);
z=round(data.Potentialdensitykgm3(data.Station==32),3,'significant');
plot(x,y,'ko-','MarkerFaceColor','k')
% scatter(x,y,[],data.FeIInM(data.Station==32),'filled');
% text(x(1:10:length(x))-0.07,y(1:10:length(x))+30,num2cell(z(1:10:length(x))))

x=data.Longitude(data.Station==33);
y=data.Depthm(data.Station==33);
z=round(data.Potentialdensitykgm3(data.Station==33),3,'significant');
plot(x,y,'ko-','MarkerFaceColor','k')

a=area(coast_x(ind2),bathy','FaceColor','none','EdgeColor','none');
a(2).FaceColor=[160/255 160/255 160/255];

set(gca,'Color',rgb('LightGray'))
xlabel(['Longitude/' char(176) 'E'])

hold off
saveas(gca,'Hecata_ADCP_u.svg');


%%

% V Vel
fig = figure(2);
% sb(1) = subplot(2,1,1);
set(gca,'Color',rgb('DimGray'));
contourf(long_grid,dep_grid,v2,levels,'linestyle','none');
hold on
set(gca,'YDir','Reverse');
cb(1) = colorbar('location','eastoutside');
ylabel(cb(1),'Meridional Velocity/m s^{-1}','FontSize',12);
xlim([min(lon2), max(lon2)]);
% set(gca,'XTickLabel',[]);
ylim([min(dep) 800])
% set(gca,'YTickLabels',[]);
ylabel('Depth/m');
colormap(transMap)
% title(tit_str2);
hold on


x=data.Longitude(data.Station==31);
y=data.Depthm(data.Station==31);
z=round(data.Potentialdensitykgm3(data.Station==31),3,'significant');
plot(x,y,'ko-','MarkerFaceColor','k')
% scatter(x,y,[],data.FeIInM(data.Station==31),'filled');
% text(x(2:2:length(x))-0.11,y(2:2:length(x)),num2cell(z(2:2:length(x))))

x=data.Longitude(data.Station==32);
y=data.Depthm(data.Station==32);
z=round(data.Potentialdensitykgm3(data.Station==32),3,'significant');
plot(x,y,'ko-','MarkerFaceColor','k')
% scatter(x,y,[],data.FeIInM(data.Station==32),'filled');
% text(x(1:10:length(x))-0.07,y(1:10:length(x))+30,num2cell(z(1:10:length(x))))

x=data.Longitude(data.Station==33);
y=data.Depthm(data.Station==33);
z=round(data.Potentialdensitykgm3(data.Station==33),3,'significant');
plot(x,y,'ko-','MarkerFaceColor','k')

a=area(coast_x(ind2),bathy','FaceColor','none','EdgeColor','none');
a(2).FaceColor=[160/255 160/255 160/255];

set(gca,'Color',rgb('LightGray'))
xlabel(['Longitude/' char(176) 'E'])

hold off
saveas(gca,'Hecata_ADCP_v.svg')

