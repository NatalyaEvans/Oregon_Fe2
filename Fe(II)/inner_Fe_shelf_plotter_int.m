%%

% This code is designed to plot Fe(II) and dFe for
% the "shallow" shelf sites. It also plots O2 as a useful parameter to
% report

%%
clear
close all

load('processed_fe2_data_corr');
load('integrated_fe2_data');
int_data=data2;
int_data(int_data.Casttype=='BBG',:)=[]; % remove BBGs
data2=data;
max_depth=140;
data2(data2.Bottomdepthm>max_depth,:)=[];
data2(data2.Station==34.5,:)=[];
data2(data2.Casttype=='BBG' | data2.Casttype=='TMC Fe only',:)=[];
data2(data2.Cruise~=2107,:)=[];
stns=unique(data2.Station);

figure(1)
for i=1:length(stns)
    lats(i)=mean(data2.Latitude(data2.Station==stns(i)));
end

[lats_sorted order]=sort(lats);
stns_sorted=stns(order);
for i=1:length(stns_sorted)
    x=data2.FeIInM(data2.Station==stns_sorted(i));
    y=data2.Depthm(data2.Station==stns_sorted(i));
    err=data2.FeIIstdnM(data2.Station==stns_sorted(i));
    [y,inds]=sort(y);
    x=x(inds);
    err=err(inds);
    
    
    subplot(1,length(stns),i)
    errorbar(x,y,[],[],err,err,'ko-','MarkerFaceColor','k')
    hold on
    
    x3=int_data.FeIInMSampling(int_data.Station==stns_sorted(i));
    y3=int_data.Depthm(int_data.Station==stns_sorted(i));
    err3=int_data.FeIInMSampling_err(int_data.Station==stns_sorted(i));
    [y3,inds]=sort(y3);
    x3=x3(inds);
    err3=err3(inds);   
    
    errorbar(x3,y3,[],[],err3,err3,'r^','MarkerFaceColor','r')
    
    if stns_sorted(i)==27
        x2=data.dFenM(data.Station==4);
        y2=data.Depthm(data.Station==4);
        [y2,inds]=sort(y2);
        x2=x2(inds);
        y2(isnan(x2))=[];
        x2(isnan(x2))=[];
        plot(x2,y2,'bd-','MarkerFaceColor','b')
    end
    
    if stns_sorted(i)==29
        x2=data.dFenM(data.Station==3);
        y2=data.Depthm(data.Station==3);
        [y2,inds]=sort(y2);
        x2=x2(inds);
        y2(isnan(x2))=[];
        x2(isnan(x2))=[];
        plot(x2,y2,'bd-','MarkerFaceColor','b')
    end
    
    if stns_sorted(i)~=[27,29]
        x2=data2.dFenM(data2.Station==stns_sorted(i));
        y=data2.Depthm(data2.Station==stns_sorted(i));
        [y,inds]=sort(y);
        x2=x2(inds);
        y2=y;
        y2(isnan(x2))=[];
        x2(isnan(x2))=[];
        plot(x2,y2,'bd-','MarkerFaceColor','b')
    end
    
%     y=depth;
%     x=1000*mean([Femodel7(i,:)',Femodel8(i,:)'],2);
%     err=1000*mean([stdFemodel7(i,:)',stdFemodel8(i,:)'],2);
%     ind=isnan(x);
%     x2=x;
%     y2=y;
%     err2=err;
%     y2(ind)=[];
%     x2(ind)=[];
%     err2(ind)=[];
%     plot(x2,y2,'r--','LineWidth',2)
    
     a=area([[0 100]',[0 100]'],[[mean(data2.Bottomdepthm(data2.Station==stns_sorted(i))),mean(data2.Bottomdepthm(data2.Station==stns_sorted(i)))]',[max_depth,max_depth]'],'FaceColor','none','EdgeColor','none');
%     a=area([[0 max(data2.FeIInM)]',[0 max(data2.FeIInM)]'],[[mean(data2.Bottomdepthm(data2.Station==stns_sorted(i))),mean(data2.Bottomdepthm(data2.Station==stns_sorted(i)))]',[max_depth,max_depth]'],'FaceColor','none','EdgeColor','none');
    a(2).FaceColor=[160/255 160/255 160/255];
%     title(round(lats_sorted(i),4,'significant'));
    title(stns_sorted(i))
    ylim([0 max_depth])
%     xlim([0 60])
    xlim([0 70])
    axis ij
    grid on
    
    % make figure modifications
%     if i==length(stns_sorted)
    if i==1
        legend('Fe(II)','Sampled Fe(II)','dFe')
    end
    
    box on
    hold off

end

% graphics figure
figure(2)
errorbar(x,y,[],[],err,err,'ko-','MarkerFaceColor','k')
xlabel('Fe/nM')
ylabel('Depth/m')


%% O2

load('OC_1m_all')

figure(3)
for i=1:length(stns_sorted)
    x=data2.O2umolkg1(data2.Station==stns_sorted(i));
    x2=OC2107A1m.Oxygenumolkg1(OC2107A1m.Station==stns_sorted(i));
    x2=x2.*((1000+OC2107A1m.Potentialdensitykgm3(OC2107A1m.Station==stns_sorted(i)))/1000); % now in uM
    y=data2.Depthm(data2.Station==stns_sorted(i));
    y2=OC2107A1m.Depthm(OC2107A1m.Station==stns_sorted(i));    
    [y,inds]=sort(y);
    x=x(inds);
    [y2,inds]=sort(y2);
    x2=x2(inds);
    subplot(1,length(stns),i)
%     p1=plot(x,y,'ko--','MarkerFaceColor','k');
    hold on
    p1=plot(x2,y2,'k-','LineWidth',2);
    
%     y=depth;
%     x=mean([O2model7(i,:)',O2model8(i,:)'],2);
%     err=mean([stdO2model7(i,:)',stdO2model8(i,:)'],2);
%     ind=isnan(x);
%     x2=x;
%     y2=y;
%     err2=err;
%     y2(ind)=[];
%     x2(ind)=[];
%     err2(ind)=[];
%     p2=plot(x2,y2,'r--','LineWidth',2);
%     
    a=area([[0 max(data2.O2umolkg1)]',[0 max(data2.O2umolkg1)]'],[[mean(data2.Bottomdepthm(data2.Station==stns_sorted(i))),mean(data2.Bottomdepthm(data2.Station==stns_sorted(i)))]',[max_depth,max_depth]'],'FaceColor','none','EdgeColor','none');
    a(2).FaceColor=[160/255 160/255 160/255];
%     title(stns_sorted(i))
    ylim([0 max_depth])
    xlim([0 200])
    axis ij
    grid on
    
%     % make figure modifications
%     if i==length(stns_sorted)
%         legend([p1, p2],{'Measured','ROMS'})
%     end
    
    box on
    hold off
end

% graphics figure
figure(4)
p1=plot(x,y,'mo','MarkerFaceColor','m');
xlabel('O_2/{\mu}M')
ylabel('Depth/m')




