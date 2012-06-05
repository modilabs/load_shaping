% Mitchell Lee 
% 4/12/2012
% Shared Solar 
% Create Idealized Solar data
%---------------------
% All nomenclature for solar geometric data notation and equations are 
% as consistent as possible with Renewable and Efficicient Electric 
% Power Systems by Gilbert M. Masters

clc
format short 
format compact
%rawData = importdatafile('week_of_data.csv');

%% Location and PV cell arrangment 
L = 13.368056*pi/180; %latitude degrees
Long = 5.273333*pi/180; %longitude(West Positve)
time_meradian = 0; %local time meradian
sigma = L; %collector angle tilt
phi_c = 0;

%% Convert Time to Usable form
dates = datevec(rawData(:,1));
[rows,cols] = size(dates);
monthStarts = [1,2,3,4,5,6,7,8,9,10,11,12
               1,32,60,91,121,152,182,213,244,274,305,335]';
dayNumbers = zeros(rows,1);
for ix = 1:rows
    for ixx = 1:12
        if monthStarts(ixx) == dates(ix,2)
            dayNumbers(ix) = monthStarts(ixx,2)+dates(ix,3);
        end
    end
end
%% Calculate Solar time
standardTimes = dates(:,4)+dates(:,5)*60+dates(:,6)*60*60;%hours
B = 360*(dayNumbers-81)/364*pi/180;
E = 9.87*sin(2*B)-7.53*cos(B)-1.5*sin(B);
solarTimes = standardTimes +4*(time_meradian-Long)*180/pi/60+E/60;% hours
% confirm accuracy of solar time over larger dataset 

%% Geometric Properties
delta = asin(-sind(23.45).*cosd(360.*(dayNumbers+10)./365));
H = 15*pi/180*(12-solarTimes);
beta = asin(cos(L)*cos(delta).*cos(H)+sin(L)*sin(delta));
m = 1./sin(beta);
A = 1160+75.*sin(pi/180*360/365.*(dayNumbers-275)); % "Apparent" Extraterrestrial Flux 
phi_s = asin(cos(delta).*sin(H)./cos(beta)); 
theta = acos(cos(beta).*cos(phi_s-phi_c).*sin(sigma)+sin(beta).*cos(sigma));
H_SR = acos(-tan(L)*tan(delta));

%% Insolation
% Until reliabled data is available assume that:
% -Direct beam insolation is 1000 W/m^2 during all dailight hours
% -There is no ground reflected or diffuse radition
% -That the insolation at the beginning of the hour is representative of 
%  the entire hour.

I_B = zeros(rows,1);
for ix = 1:rows
    if abs(H(ix)) <= abs(H_SR(ix))
        I_B(ix) = 1000;
    end
end
I_BC = I_B.*cos(theta); %Hourly Radiation on Collector per m^2





peakHours = 3:6; %number of peak hours per day equivalent of insolation available  
peakPower = 1000; %W/m^2 is maximum insolation
totalSolarResource = round(rows/24)*peakHours*1000;% The amount of Energy Available 
% during the time period (dependent upon the number of peak hours of sunlight
% available per day) this is in Wh/m^2
scaleResource = totalSolarResource./sum(I_BC);

% I need to incorporate k



I_scaled = zeros(length(peakHours),length(I_BC));

for jx = 1:length(peakHours)
    I_scaled(jx,:) = I_BC.*scaleResource(jx);
end


%% Demand
totalDemand = sum(rawData(:,2)); % Watt hours per week

% Determine the PV area such that for this week, the exact amount of
% electricity to meet demand is generated
PV_area = totalDemand./totalSolarResource; % m^2


%% System Simulation
% Plot System Ablity to meet demand vs Battery storage capacity

solGen = zeros(length(peakHours),length(I_BC));
for jx = 1:length(peakHours)
    solGen(jx,:) = I_scaled(jx,:)*PV_area(jx);
end
subplot(2,1,2)
plot(rawData(:,1),solGen')
datetick('x','dd/mm')
xlabel('Hour of Week')
ylabel('Electricity Generation (W)')
title('Electricity Generation by PV Module')
subplot(2,1,1)
plot(rawData(:,1),I_scaled')
datetick('x','dd/mm')
xlabel('Hour of Week')
ylabel('Insolation (W/m^2)') %\
title('Insolation Profile')
% demand = rawData(:,2);
% batteryFlow = solGen -demand;
% batteryCharge1 = zeros(rows,1);
% 
% % Assume Initial Charge state is zero
% % Demand is magically met even when battery capacity is below zero
% for ix = 2:rows
%     batteryCharge1(ix) = batteryCharge1(ix-1)+batteryFlow(ix-1);
% end
% 
% % Now assume battery initial charge states is 50% of this range
% demandMet = 0;
% n = 1000;
% MaxCapacity = linspace((max(batteryCharge1)-min(batteryCharge1))/2,3000,n);%(max(batteryCharge1)-min(batteryCharge1)),n);
% WhShort = zeros(n,1); % Amount of energy that could not be met for each 
% % battery capacity simulation
% 
% LOLP = zeros(n,1);% Loss of Load Probability = number of battery capacity 
% % measurements with zero capacity divided by the total number of 
% % measurements taken. Each element is
% % for one simulation with a fixed maximum battery capacity)    
%                 
% for ixx = 1:n;
%     batteryCharge = zeros(rows,1);
%     batteryCharge(1) = (max(batteryCharge1)-min(batteryCharge1))/2;
%     for ix = 2:rows
%         batteryCharge(ix) = batteryCharge(ix-1)+batteryFlow(ix-1);
%         if batteryCharge(ix) > MaxCapacity(ixx)
%             batteryCharge(ix) = MaxCapacity(ixx);
%         elseif batteryCharge(ix) < 0
%             batteryCharge(ix) = 0;
%             WhShort(ixx,1) = WhShort(ixx,1)- batteryFlow(ix-1); 
%         end
%     end
%     LOLP(ixx) = sum(batteryCharge == 0)/length(batteryCharge);
%     if ixx ==1
%         figure
%         plot(rawData(:,1),solGen,'g',rawData(:,1),demand,'b',rawData(:,1),batteryCharge,'m')
%         datetick('x')
%         axis auto
%         ylabel('Energy (Wh)')
%         legend('PV Generation (W)','Energy Demand (W)','Battery Stored Energy (Wh)')
%     end
% end
% 
% chopOff = min(find(LOLP == 0));
% LOLP = LOLP(1:chopOff);
% MaxCapacity = MaxCapacity(1:chopOff);
% WhShort = WhShort(1:chopOff);
% % 
% % % figure
% % % subplot(2,1,1)
% % % plot(MaxCapacity,LOLP)
% % % axis tight
% % % xlabel('Battery Storage Capacity (Wh)')
% % % ylabel('Loss of Load Probablity')
% % % title('LOLP vs Maximum Battery Capacity')
% % % 
% % % subplot(2,1,2)
% % plot(MaxCapacity,WhShort)
% % axis tight
% % xlabel('Battery Storage Capacity (Wh)')
% % ylabel('Energy Shortfall (Wh)')
% % title('Missed Demand vs Maximum Battery Capacity')
% % 
% % % figure
% % plot(rawData(:,1),solGen,'g',rawData(:,1),demand,'b',rawData(:,1),batteryCharge,'m')
% % datetick('x')
% % legend('PV Generation (W)','Energy Demand (W)','Battery Stored Energy (Wh)')
% % title('Last Iteration: All Demand Just Met')
% % 
% 
% 
% 
% % NOTE: Once the model includes battery efficency losses it will be necessary 
% % to differentiate between demand that is meet directly via PV energy
% % without going to the battery first
%                 