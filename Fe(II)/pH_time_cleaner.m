%% Clean up pH and times to integrate Fe(II) ox

% This script is designed to plot profiles of pH, sampling time, and measurement
% time to fix these values so we can integrate how much Fe(II) was oxidized 
% during sample acquisition for each measured sample with the Fe2integrator
% script

%% outlier points

% data2.FeIInMSampling-data2.FeIInM>2*data2.FeIInM
% 1260 % stn 32 ctd at 190, deepest % this sat for a long time but time
% seems likely. The pH definitely seems too high though, so fix that
% 1306 % stn 34 ctd at 106, deepest % I bet that the times for 1306 and
% 1323 got switched, based on these profiles. Sample 1306 definitely has
% way too high pH as well
% 1323 % stn 34 tmc at 98, deepest tmc
% 
% data2.FeIInMSampling-data2.FeIInM>data2.FeIInM)
% 1173 % stn 27 tmc at 105 % time seems fine, pH seems fine 
% 1174 % stn 27 tmc at 100 % time seems fine, pH seems fine
% 1249 % stn 31 tmc at 360 % time seems fine, pH seems fine?

% All time values corrected

%% load data

clear
close all
load('processed_fe2_data_corr')

% cut points that we aren't integrating
ind= data.Cruise~=2107 | isnan(data.pH) | data.TemperatureITSC==0 | isnat(data.Samplingtime)==1; % less things to cut for beter profiles
data2=data;
data2(ind,:)=[];

ind= data.Cruise~=2107 | isnan(data.pH) | data.FeIInM<0.5 | data.TemperatureITSC==0 | isnat(data.Samplingtime) | isnat(data.Measurementtime);
data3=data;
data3(ind,:)=[]; % only the data that's being integrated


data2.O2uM=data2.O2umolkg1.*((1000+data2.Potentialdensitykgm3)/1000);
data3.O2uM=data3.O2umolkg1.*((1000+data3.Potentialdensitykgm3)/1000);


%% find delta t

data3.Samplingtime2=datestr(data3.Samplingtime,'HH:MM:SS');
data3 = movevars(data3,"Samplingtime2",'After',"Samplingtime");

% fix points that are weird
% data3.Measurementtime(data3.Samplenumber==1323)=data3.Measurementtime(data3.Samplenumber==1324); % fixes an outlier, might be off by a few mins
% % data3.Measurementtime(data3.Samplenumber==1306)=data3.Measurementtime(data3.Samplenumber==1308); % fixes an outlier, might be off by a few mins
% data3(data3.Samplenumber==1306,:)=[]; % point difficult to fix right now. I think that the pH electrode is kinda messed up

dt=(datenum(datestr(data3.Measurementtime,'HH:MM:SS'))-datenum(datestr(data3.Samplingtime,'HH:MM:SS')));
dt2=datestr(dt,'HH:MM:SS');

for i=1:length(dt2)
    dt3(i,:) = seconds(duration(dt2(i,:), 'InputFormat', 'hh:mm:ss', 'Format', 'hh:mm:ss'));
end

data3.dt=dt3; % time elapsed in seconds


%% find delta t

data2.Samplingtime2=datestr(data2.Samplingtime,'HH:MM:SS');
data2 = movevars(data2,"Samplingtime2",'After',"Samplingtime");

% fix points that are weird
% data2.Measurementtime(data2.Samplenumber==1323)=data2.Measurementtime(data2.Samplenumber==1324); % fixes an outlier, might be off by a few mins
% % data2.Measurementtime(data2.Samplenumber==1306)=data2.Measurementtime(data2.Samplenumber==1308); % fixes an outlier, might be off by a few mins
% data2(data2.Samplenumber==1306,:)=[]; % point difficult to fix right now. I think that the pH electrode is kinda messed up

dt=(datenum(datestr(data2.Measurementtime,'HH:MM:SS'))-datenum(datestr(data2.Samplingtime,'HH:MM:SS')));
dt2=datestr(dt,'HH:MM:SS');

for i=1:length(dt2)
    dt3(i,:) = seconds(duration(dt2(i,:), 'InputFormat', 'hh:mm:ss', 'Format', 'hh:mm:ss'));
end

data2.dt=dt3; % time elapsed in seconds

%% plot pH profiles
% 
% stns=unique(data3.Station);
% 
% for i=1:length(stns)
%     ind=data3.Station==stns(i);
%     figure()
%     x=data3.pH(ind);
%     [y,ind]=sort(data3.Depthm(ind));
%     x=x(ind);
%     plot(x,y,'ko-','MarkerFaceColor','k')
%     hold on
%     
%     ind=data2.Station==stns(i);    
%     x=data2.pH(ind);
%     [y,ind]=sort(data2.Depthm(ind));
%     x=x(ind);
%     plot(x,y,'ko-')   
%     
%     axis ij
%     
%     title(stns(i))
%     xlabel('pH')
%     ylabel('Depth/m')
%     hold off
% end

%% plot sampling time profiles

% stns=unique(data3.Station);
% 
% for i=1:length(stns)
%     figure()
%     sub=data3(data3.Station==stns(i),:);
%     casts=unique(sub.Cast);
%     for j=1:length(casts)
%         ind=sub.Cast==casts(j);
%         [y,sortind]=sort(sub.Depthm(ind));
%         temp=sub.Samplingtime2(ind,:);
%         for k=1:length(y)
%             x(k,:)=duration(temp(k,:));
%         end
%         x=x(sortind,:);
%         plot(x,y,'ko-','MarkerFaceColor','k')
%         hold on
%         
%         temp=sub.Measurementtime(ind,:);
%         for k=1:length(y)
%             dummy=char(temp(k));
%             z(k,:)=duration(dummy(end-7:end));
%         end
%         z=z(sortind,:);
%         plot(z,y,'rd--','MarkerFaceColor','r')
%     end
%     
%     sub=data2(data2.Station==stns(i),:);
%     casts=unique(sub.Cast);
%     for j=1:length(casts)
%         ind=sub.Cast==casts(j);
%         [y,sortind]=sort(sub.Depthm(ind));
%         temp=sub.Samplingtime2(ind,:);
%         for k=1:length(y)
%             x2(k,:)=duration(temp(k,:));
%         end
%         x2=x2(sortind,:);
%         plot(x2,y,'ko-')
% 
%         temp=sub.Measurementtime(ind,:);
%         for k=1:length(y)
%             dummy=char(temp(k));
%             z2(k,:)=duration(dummy(end-7:end));
%         end
%         z2=z2(sortind,:);
%         plot(z2,y,'rd--')
%     end        
%     axis ij
%     
%     title(stns(i))
%     xlabel('Time')
%     ylabel('Depth/m')
%     hold off
% end
% 
% 

% %% fix station 34 deep pH values
% 
% ind=data.Station==34;
% x=data.pH(ind);
% [y,inds]=sort(data.Depthm(ind),'descend');
% x=x(inds);
% plot(x,y,'ko-')
% hold on
% 
% x2=x(2:end-2);
% y2=y(2:end-2);
% 
% x3=smooth(y2,x2,10,'loess'); % these are good values, drop the deepest one
% plot(x3,y2,'bd-')
% 
% % % forcing to a linear regression
% % x2=x(2:end-2);
% % y2=y(2:end-2);
% % x2(9)=[];
% % y2(9)=[];
% % plot(x2,y2,'ko-','MarkerFaceColor','k')
% % 
% % [m,b] = lsqfitma(y2,x2);
% % plot(m*y2+b,y2,'r--')
% % 
% % y3=y(1:end-4);
% % x3=m*y3+b;
% % plot(x3,y3,'bd-','MarkerFaceColor','b')
% 
% axis ij
% xlabel('pH')
% ylabel('Depth/m')
% hold off
% 


%% fix station 32 deep pH values

ind=data.Station==32;
x=data.pH(ind);
[y,inds]=sort(data.Depthm(ind),'descend');
x=x(inds);
plot(x,y,'ko-')
hold on

x2=x(1:end-2);
y2=y(1:end-2);

x3=smooth(y2,x2,5,'sgolay'); % these are good values, drop the deepest one
plot(x3,y2,'bd-')

% % forcing to a linear regression
% x2=x(2:end-2);
% y2=y(2:end-2);
% x2(9)=[];
% y2(9)=[];
% plot(x2,y2,'ko-','MarkerFaceColor','k')
% 
% [m,b] = lsqfitma(y2,x2);
% plot(m*y2+b,y2,'r--')
% 
% y3=y(1:end-4);
% x3=m*y3+b;
% plot(x3,y3,'bd-','MarkerFaceColor','b')

axis ij
xlabel('pH')
ylabel('Depth/m')
hold off
