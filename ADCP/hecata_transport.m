%%


close all

global kprime % for the integration

%%

load('processed_fe2_data_corr')
load('OC2107A_ETOP01')

%%

max_lat=44.5;
min_lat=43.7;

ind=coast_y<max_lat & coast_y>min_lat;
ind2=coast_x<-124.2 & coast_x>-125.1;
bathy=-coastal_relief_3sec(ind,ind2);

%%

load('contour_uv.mat');
load('contour_xy.mat');

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

%% DEPTH VS TIME
% Dep/Time mesh

t1=datenum(datetime('2021-08-04 11:00:00','InputFormat','yyyy-MM-dd hh:mm:ss'));
t2=datenum(datetime('2021-08-06','InputFormat','yyyy-MM-dd'));
inds=time>t1 & time<t2;

% cut values outside of timeframr
lon2=lon(inds);
u2=u(:,inds);
v2=v(:,inds);

[dep_grid,long_grid] = meshgrid(dep,lon2);
dep_grid = dep_grid';
long_grid = long_grid';

%% find velocity and direction

long_ind=6;
dep_ind=10;
% theta=(180/pi())*atan2(v2(dep_ind,long_ind),u2(dep_ind,long_ind))
t=[0:1:4];
x=mean(data.Longitude(data.Station==31))-t*u2(dep_ind,long_ind);
y=mean(data.Latitude(data.Station==31))-t*v2(dep_ind,long_ind);

ang=20;
x2=mean(data.Longitude(data.Station==31))-t*u2(dep_ind,long_ind)*cos(ang*(pi()/180));
y2=mean(data.Latitude(data.Station==31))-t*v2(dep_ind,long_ind)*sin(ang*(pi()/180));

%%

contourf(coast_x(ind2), coast_y(ind), bathy, [0:20:1000],'LineColor','None')
hold on
plot(mean(data.Longitude(data.Station==31)),mean(data.Latitude(data.Station==31)),'md','MarkerSize',8,'MarkerFaceColor','m')
plot(x,y,'m--','LineWidth',2)
plot(x2,y2,'r-.','LineWidth',2)
plot(x2(3),y2(3),'ro','MarkerSize',6,'MarkerFaceColor','r')


cmap=cmocean('-ice');
colormap(cmap(1:200,:))
h=colorbar;
caxis([0 800])
ylim([min_lat max_lat])

set(get(h,'label'),'string','Seafloor depth/m','FontSize',12);
ylabel(['Latitude/' char(176)' 'N'])
xlabel(['Longitude/' char(176)' 'E'])
hold off

% saveas(gcf,'Hecata_transport_map.tif');

%%

d=haversine([y2(3) x2(3)], [mean(data.Latitude(data.Station==31)) mean(data.Longitude(data.Station==31))]); % in km
vel=sqrt(u2(dep_ind,long_ind)^2+v2(dep_ind,long_ind)^2); % m/s
% vel=sqrt(2)*0.2;
deltat=(d*1000)/(vel*60); % in min
% n_halflifes=deltat/150
% remaining=100*(0.5)^n_halflifes

pH=7.66;
T=6.45;
S=34.11;
logk = 35.627 - 6.7109*(pH) + 0.5342*(pH).^2 - (5362.6./(T+273.15)) - 0.04406*S.^0.5 - 0.002847*S; % González-Santana et al 2021, in seconds
kprime=(41.818/299.355)*10.^logk;
% kprime=log(2)/(12.*3600);

Fe2start=0.6*10^-9;
% Fe2start=0.81*10^-9;

[t0,Fe2]=ode45('Feox',[0:1:60*deltat]',(Fe2start)); % t0 in seconds, Fe(II) in M
FeIInMSampling=Fe2(end,:)'*10^9 % Fe(II) in nM again

