%%

% pH correction plotter script. This script generates the plot used to
% correct for missing pH values

%%

load('processed_fe2_data_corr')
data2=data(data.Cruise==2107 & data.O2umolkg1<=100 & isnan(data.pH)==0,:);

plot(data2.O2umolkg1,data2.pH,'ko','MarkerFaceColor','k')
hold on
[m,b,r,sm,sb] = lsqfitma(data2.O2umolkg1,data2.pH)
xsim=[min(data2.O2umolkg1):1:max(data2.O2umolkg1)];
plot(xsim,b+m*xsim,'r--')
xlim([0 100])
xlabel('O_2/{\mu}mol kg^{-1}')
ylabel('pH')
hold off







