%% integrate Fe(II) ox

% This script is designed to integrate how much Fe(II) was oxidized during
% sample acquisition for each measured sample


%% load data

clear
close all

global kprime % rate to give the DE solver

load('processed_fe2_data_corr')
data.pH2=data.pH; % make a duplicate to track adjustments

% fix station 34 pH values

pHcorr=[7.48011448694825;7.49445958120077;7.50666209896558;7.51685279076087;7.54084583219300;7.53717053513251;7.53428271508323;7.56334905681446;7.57561858552861;7.59222139707371;7.59867565351813];
depthcorr=[104;102;100;98;90;80;79;70;65;55;35]; % depths for those correct pH values

for i=1:length(depthcorr)
    data.pH2(data.Station==34 & data.Depthm==depthcorr(i))=pHcorr(i);
end

% data.pH2(data.Station==34 & data.Depthm==106)=NaN; % this point is a significant pH outlier
% data.pH2(data.Station==34 & data.Depthm==90)=NaN; % this point is an outlier
% % data.pH2(data.Station==34.5 & data.Depthm==104)=NaN; % Fe(II) and dFe are too close
data.pH2(data.Station==32 & data.Depthm==190)=7.6; % ave of the previous two values, things were messy

% add missing values
for i=1:length(data.pH2)
    if isnan(data.pH2(i))==1
        data.pH2(i)=0.0030*data.O2umolkg1(i)+7.4366;
    end
end


% cut points that we aren't integrating
% ind = data.Cruise~=2107 | isnan(data.pH2) | data.FeIInM<0.5 | data.TemperatureITSC==0 | isnat(data.Samplingtime) | isnat(data.Measurementtime);
ind = data.Cruise~=2107 | isnan(data.pH2) | data.FeIInM<0.25 | data.TemperatureITSC==0 | isnat(data.Samplingtime) | isnat(data.Measurementtime);

data2=data;
data2(ind,:)=[];

data2.O2uM=data2.O2umolkg1.*((1000+data2.Potentialdensitykgm3)/1000);

%% find delta t

data2.Samplingtime2=datestr(data2.Samplingtime,'HH:MM:SS');
data2 = movevars(data2,"Samplingtime2",'After',"Samplingtime");

% fix points that are weird
% data2.Measurementtime(data2.Samplenumber==1323)=data2.Measurementtime(data2.Samplenumber==1324); % fixes an outlier, might be off by a few mins
% data2.Measurementtime(data2.Samplenumber==1306)=data2.Measurementtime(data2.Samplenumber==1308); % fixes an outlier, might be off by a few mins
% data2(data2.Samplenumber==1306,:)=[]; % point difficult to fix right now. I think that the pH electrode is kinda messed up

dt=(datenum(datestr(data2.Measurementtime,'HH:MM:SS'))-datenum(datestr(data2.Samplingtime,'HH:MM:SS')));
dt2=datestr(dt,'HH:MM:SS');

for i=1:length(dt2)
    dt3(i,:) = seconds(duration(dt2(i,:), 'InputFormat', 'hh:mm:ss', 'Format', 'hh:mm:ss'));
end

data2.dt=dt3; % time elapsed in seconds

%% setting up kinetics
% logk in log(Hz)
data2.logk = 35.627 - 6.7109*(data2.pH2) + 0.5342*(data2.pH2).^2 - (5362.6./(data2.TemperatureITSC+273.15)) - 0.04406*data2.Salinitypractical.^0.5 - 0.002847*data2.Salinitypractical; % González-Santana et al 2021, in seconds

% O2 no longer being corrected
O2sat=gsw_O2sol(gsw_SA_from_SP(data2.Salinitypractical,gsw_p_from_z(-data2.Depthm,data2.Latitude),data2.Longitude,data2.Latitude),...
    gsw_CT_from_t(gsw_SA_from_SP(data2.Salinitypractical,gsw_p_from_z(-data2.Depthm,data2.Latitude),data2.Longitude,data2.Latitude),data2.TemperatureITSC,gsw_p_from_z(-data2.Depthm,data2.Latitude)),...
    gsw_p_from_z(-data2.Depthm,data2.Latitude),data2.Longitude,data2.Latitude);

%%

% data2.tau=(log(2)./(10.^logk))/60; % half life in mins
data2.tau=(log(2)./((data2.O2umolkg1./O2sat).*10.^data2.logk))/(60*60); % half life in hrs

del_pH=0.1;
for i=1:length(data2.dt)
%     kprime=10.^logk(i);
    kprime=(data2.O2umolkg1(i)./O2sat(i)).*10.^data2.logk(i);
    [t0,Fe2]=ode45('Feox',[0:1:data2.dt(i)]',(data2.FeIInM(i)*10^-9)); % t0 in seconds, Fe(II) in M
    data2.FeIInMSampling(i)=Fe2(end,:)'*10^9; % Fe(II) in nM again    

    
    % Unc
    % pH, low then high
    logkl = 35.627 - 6.7109*(data2.pH2-del_pH) + 0.5342*(data2.pH2-del_pH).^2 - (5362.6./(data2.TemperatureITSC+273.15)) - 0.04406*data2.Salinitypractical.^0.5 - 0.002847*data2.Salinitypractical; % González-Santana et al 2021, in seconds
%     kprime=10.^logkl(i);
    kprime=(data2.O2umolkg1(i)./O2sat(i)).*10.^logkl(i);
    [t0,Fe2]=ode45('Feox',[0:1:data2.dt(i)]',(data2.FeIInM(i)*10^-9)); % t0 in seconds, Fe(II) in M
    temp(1)=Fe2(end,:)'*10^9; % Fe(II) in nM again for a low pH measurement
    
    logkh = 35.627 - 6.7109*(data2.pH2+del_pH) + 0.5342*(data2.pH2+del_pH).^2 - (5362.6./(data2.TemperatureITSC+273.15)) - 0.04406*data2.Salinitypractical.^0.5 - 0.002847*data2.Salinitypractical; % González-Santana et al 2021, in seconds
%     kprime=10.^logkh(i);
    kprime=(data2.O2umolkg1(i)./O2sat(i)).*10.^logkh(i);

    [t0,Fe2]=ode45('Feox',[0:1:data2.dt(i)]',(data2.FeIInM(i)*10^-9)); % t0 in seconds, Fe(II) in M
    temp(2)=Fe2(end,:)'*10^9; % Fe(II) in nM again for a high pH measurement
    
    Fe2_pHunc(i)=abs(temp(2)-temp(1));
    delkprime=abs(10^logkl(i)-10^logkh(i));
    
    % Fe(II) starting value, low then high
    % reseting k
    data2.logk = 35.627 - 6.7109*(data2.pH2) + 0.5342*(data2.pH2).^2 - (5362.6./(data2.TemperatureITSC+273.15)) - 0.04406*data2.Salinitypractical.^0.5 - 0.002847*data2.Salinitypractical; % González-Santana et al 2021, in seconds
%     kprime=10.^logk(i);
    kprime=(data2.O2umolkg1(i)./O2sat(i)).*10.^data2.logk(i);


    [t0,Fe2]=ode45('Feox',[0:1:data2.dt(i)]',((data2.FeIInM(i)-data2.FeIIstdnM(i))*10^-9)); % t0 in seconds, Fe(II) in M
    temp(1)=Fe2(end,:)'*10^9; % Fe(II) in nM again for the low value

    [t0,Fe2]=ode45('Feox',[0:1:data2.dt(i)]',(data2.FeIInM(i)+data2.FeIIstdnM(i))*10^-9); % t0 in seconds, Fe(II) in M
    temp(2)=Fe2(end,:)'*10^9; % Fe(II) in nM again for the low value
    
    Fe2_Feunc(i)=abs(temp(2)-temp(1));

    data2.FeIInMSampling_err(i)=sqrt(Fe2_Feunc(i)^2+Fe2_pHunc(i)^2);
%     data2.FeIInMSampling_err(i)=sqrt(data2.FeIIstdnM(i)^2+Fe2_pHunc(i)^2);

    data2.tau_err(i)=(delkprime*log(2)./(10.^(data2.logk(i)*2)))/(60*60); % half life in hrs


end

% hold off

%%

% data3=data2; % make a backup
% data2(data2.Casttype=='BBG',:)=[]; % cut the BBG data from this figure


figure(2)
errorbar(data2.FeIInM,data2.tau,data2.tau_err,data2.tau_err,data2.FeIIstdnM,data2.FeIIstdnM,'ko','MarkerFaceColor','k')
hold on
scatter(data2.FeIInM,data2.tau,[],data2.Depthm,'filled')
cmap=cmocean('turbid');
caxis([100 1000])
colormap(cmap)
h=colorbar;
set(get(h,'label'),'string',{'Depth/m'},'FontSize',12);
set(gca,'YScale','log')
xlabel('Fe(II)/nM')
ylabel('Fe(II) half-life/hour')
grid on
hold off
xlim([0 70])
saveas(gca,'Fe2_halflifes.tif')

% figure(3)
% histogram(data2.tau,10)
% hold on
% xline(80,'r--','LineWidth',3);
% xlabel('Fe(II) half-life/min')
% ylabel('Frequency')
% hold off

%%

save('integrated_fe2_data','data2')

%% check the data

% stns=unique(data2.Station);
% 
% for i=1:length(stns)
%     ind=data.Station==stns(i) & data.Casttype~='BBG';
%     figure()
%     
%     x=data.FeIInM(ind);
%     z=data.FeIIstdnM(ind);
%     [y,inds]=sort(data.Depthm(ind));
%     x=x(inds);
%     z=z(inds);
%     errorbar(x,y,[],[],z,z,'ko-','MarkerFaceColor','k')
%     hold on
%      
%     x2=data.dFenM(ind);
%     x2=x2(inds);
%     y2=y(isnan(x2)==0);
%     x2(isnan(x2)==1)=[];
%     plot(x2,y2,'bd-','MarkerFaceColor','b')
%     
%     if stns(i)==27
%         ind=data.Station==4;
%         x2=data.dFenM(ind);
%         x2=x2(inds);
%         y2=y(isnan(x2)==0);
%         x2(isnan(x2)==1)=[];
%         plot(x2,y2,'bd-','MarkerFaceColor','b')
%     end
%     
%     if stns(i)==29
%         ind=data.Station==3;
%         x2=data.dFenM(ind);
%         x2=x2(inds);
%         y2=y(isnan(x2)==0);
%         x2(isnan(x2)==1)=[];
%         plot(x2,y2,'bd-','MarkerFaceColor','b')
%     end
%     
%     ind=data2.Station==stns(i);    
%     x3=data2.FeIInMSampling(ind);
%     z3=data2.FeIInMSampling_err(ind);
%     [y3,inds]=sort(data2.Depthm(ind));
%     x3=x3(inds);
%     z3=z3(inds);
%     errorbar(x3,y3,[],[],z3,z3,'r^-')   
%     
%     axis ij
%     
%     title(stns(i))
%     xlabel('Fe/nM')
%     ylabel('Depth/m')
%     hold off
% end
% % 
% % 
% % 
% % 
