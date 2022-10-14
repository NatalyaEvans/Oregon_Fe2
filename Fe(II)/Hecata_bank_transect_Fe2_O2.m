%% for plotting transects of I-

% Adapted from previous code by Talia Evans 20220725 to plot a distribution
% of iodide on the Hecata bank. This code was initially written for O2
% measurements collected every 1 m, so it might require some tweaking to
% work for discrete samples.


%% load
clear

load('OC2107A1mbinned')
load('OC2107A_ETOP01')

%% Fe(II)

load('processed_fe2_data_corr')
cmap = cmocean('rain'); % set the colormap
cmax=5; % set the max value in the colorbar

%% Hecata Bank transect

% Extract the relevant stations from the data file

data=data(data.Station==31 | data.Station==32 | data.Station==33,:); % subset data
data(data.Casttype=='BBG',:)=[];
data(data.Samplenumber==1288 | data.Samplenumber==1289,:)=[];
botdepth=1000;
yrange=[0:1:botdepth];
gridded=ones(length(yrange),length(unique(data.Station))).*NaN; % make the structure to fill in

stns=[31 32 33];

%% clean up station 33

data(data.Station==31 & data.Cast==3,:)=[];
data(data.Station==31 & data.Depthm==10,:)=[];

%% 

for i=1:3 % first loop fills in with the deeper stations
    inds2=data.Station==31; % pick a station
    gridded(yrange(1:end)+1,i)=interp1(data.Depthm(inds2),data.FeIInM(inds2),yrange,'linear','extrap'); % fill in the contour with an interpolation
end

for i=2:3 % first loop fills in with the deeper stations
    inds2=data.Station==32; % pick a station
    depthmax=220;
    gridded(1:depthmax,i)=interp1(data.Depthm(inds2),data.FeIInM(inds2),[1:depthmax],'nearest','extrap'); % fill in the contour with an interpolation
end

inds2=data.Station==33; % pick a station
depthmax=120;
gridded(1:depthmax,i)=interp1(data.Depthm(inds2),data.FeIInM(inds2),[1:depthmax],'nearest','extrap'); % fill in the contour with an interpolation


for i=1:length(stns) % fix the data
	inds2=data.Station==stns(i); % pick a station
    xrange(i)=mean(data.Longitude(inds2));
end


ind=[data.Station==31 | data.Station==32 | data.Station==33];
max_lat=max(data.Latitude(ind));
min_lat=min(data.Latitude(ind));

ind=coast_y<max_lat & coast_y>min_lat;
ind2=coast_x<xrange(end) & coast_x>xrange(1);

bathy=mean(-coastal_relief_3sec(ind,ind2));
bathy=[bathy;ones(size(bathy)).*botdepth];


gridded=[gridded(:,1), gridded(:,1),gridded(:,2), gridded(:,2:3)]; % add in an invisible cast to stop stn 32 from smearing into stn 31
xrange=[xrange(1), -124.8, xrange(2),-124.4, xrange(3)];
gridded(gridded<0)=0;

figure(1)
contourf(xrange,yrange,gridded,[0:0.1:cmax],'LineColor','none')
hold on
plot(data.Longitude,data.Depthm,'ko','MarkerFaceColor','k','MarkerSize',2.5)

xrange2=xrange;
ind_save=ind2;

%% work up pdens contours

xrange=[];

data_binned=OC2107A1mbinned(OC2107A1mbinned.Station==31 | OC2107A1mbinned.Station==32 | OC2107A1mbinned.Station==33,:); % subset data_binned
yrange=[0:1:botdepth];
gridded=ones(length(yrange),length(unique(data_binned.Station))).*NaN; % make the structure to fill in

stns=[33 32 31]; % fill in the stations
for i=1:2 % first loop fills in with the deeper stations
    inds2=data_binned.Station==31; % pick a station
    gridded(floor(data_binned.Depthm(inds2)),i)=data_binned.Potentialdensitykgm3(inds2)'; % fill in the contour
end
for i=2:3 % first loop fills in with the deeper stations
    inds2=data_binned.Station==32; % pick a station
    gridded(floor(data_binned.Depthm(inds2)),i)=data_binned.Potentialdensitykgm3(inds2)'; % fill in the contour
end
for i=1:length(stns) % fix the data_binned
    inds2=data_binned.Station==stns(i); % pick a station
    gridded(floor(data_binned.Depthm(inds2)),i)=data_binned.Potentialdensitykgm3(inds2)'; % fill in the contour
    xrange(i)=mean(data_binned.Longitude(inds2));
end

gridded(99:200,1)=data_binned.Potentialdensitykgm3(data_binned.Station==33 & data_binned.Depthm==99); % fill in a depth issue
gridded(190:220,2)=data_binned.Potentialdensitykgm3(data_binned.Station==32 & data_binned.Depthm==189); % fill in a depth issue


[C,h1]=contour(xrange,yrange,gridded,[0,26.5,26.6,26.8],'k--','LineWidth',0.25);


%% return to plotting


a=area(coast_x(ind_save),bathy','FaceColor','none','EdgeColor','none');
a(2).FaceColor=[160/255 160/255 160/255];
% text([-124.689909052631,-124.319720102041],[250,200],{'40 nM','47 nM'});
text([-124.68-0.05,-124.31-0.085],[250,180],{'40 nM','47 nM'});
% clabel(C,h1,[26.5,26.6,26.8],'LabelSpacing',200)

axis ij
ylim([0 botdepth])
h=colorbar;
colormap(cmap)
caxis([0,cmax])

set(get(h,'label'),'string','Fe(II)/nM','FontSize',12);
ylabel('Depth/m')
xlabel(['Longitude/' char(176)' 'E'])
% title('Hecata Bank')
hold off
saveas(gcf,'Hecata_Fe2.svg')

%% O2

xrange=[];
load('OC2107A1mbinned')
cmap = cmocean('-ice');
cmax=200;

%% Hecata Bank transect

data=OC2107A1mbinned(OC2107A1mbinned.Station==31 | OC2107A1mbinned.Station==32 | OC2107A1mbinned.Station==33,:); % subset data
data.O2uM=data.Oxygenumolkg1.*((1000+data.Potentialdensitykgm3)./1000);

botdepth=1000;
yrange=[0:1:botdepth];
gridded=ones(length(yrange),length(unique(data.Station))).*NaN; % make the structure to fill in

stns=[33 32 31];

for i=1:2 % first loop fills in with the deeper stations
    inds2=data.Station==31; % pick a station
    gridded(floor(data.Depthm(inds2)),i)=data.O2uM(inds2)'; % fill in the contour
end

for i=2:3 % first loop fills in with the deeper stations
    inds2=data.Station==32; % pick a station
    gridded(floor(data.Depthm(inds2)),i)=data.O2uM(inds2)'; % fill in the contour
end

for i=1:length(stns) % fix the data
    inds2=data.Station==stns(i); % pick a station
    gridded(floor(data.Depthm(inds2)),i)=data.O2uM(inds2)'; % fill in the contour
    xrange(i)=mean(data.Longitude(inds2));
end

gridded(99:200,1)=data.O2uM(data.Station==33 & data.Depthm==99); % fill in a depth issue
gridded(190:220,2)=data.O2uM(data.Station==32 & data.Depthm==189); % fill in a depth issue


ind=[data.Station==31 | data.Station==32 | data.Station==33];
max_lat=max(data.Latitude(ind));
min_lat=min(data.Latitude(ind));

ind=coast_y<max_lat & coast_y>min_lat;
ind2=coast_x<xrange(1) & coast_x>xrange(end);

bathy=mean(-coastal_relief_3sec(ind,ind2));
bathy=[bathy;ones(size(bathy)).*botdepth];


figure(2)
contourf(xrange,yrange,gridded,[min(data.O2uM):5:cmax],'LineColor','none')
hold on
plot(data.Longitude,data.Depthm,'ko','MarkerFaceColor','k','MarkerSize',1)
a=area(coast_x(ind2),bathy','FaceColor','none','EdgeColor','none');
a(2).FaceColor=[160/255 160/255 160/255];
axis ij
ylim([0 botdepth])
h=colorbar;
colormap(cmap)
caxis([min(data.O2uM),cmax])

set(get(h,'label'),'string','O_2/{\mu}M','FontSize',12);
ylabel('Depth/m')
% set(gca,'YTickLabels',[]);
xlabel(['Longitude/' char(176)' 'E'])
% title('Hecata Bank')
hold off
saveas(gcf,'Hecata_O2.svg')

