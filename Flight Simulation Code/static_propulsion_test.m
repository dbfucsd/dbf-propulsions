%% Initialize
clear all; close all; format longg; clc;

%% Reading in Mission Inputs
mission_1 = xlsread('mission1statPropTest-Lucy.csv')
t_1 = mission_1(:,1)
Thrust_1 = mission_1(:,10)
Voltage_1 = mission_1(:,11)
Current_1 = mission_1(:,12)
Power_1 = mission_1(:,15)

mission_2 = xlsread('Mission2_Adeeb.csv')
t_2 = mission_2(:,1)
Thrust_2 = mission_2(:,10)
Voltage_2 = mission_2(:,11)
Current_2 = mission_2(:,12)
Power_2 = mission_2(:,15)

mission_3 = xlsread('mission3dev.csv')
t_3 = mission_3(:,1)
Thrust_3 = mission_3(:,10)
Voltage_3 = mission_3(:,11)
Current_3 = mission_3(:,12)
Power_3 = mission_3(:,15)

%% Plotting Voltage vs Time Data With Linear Fit
figure(1)
plot(t_1,Voltage_1)
hold on
plot(t_2,Voltage_2)
plot(t_3,Voltage_3)
% 
% figure(2)

% Mission 1
P_1 = polyfit(t_1,Voltage_1,1)
m1_slope = P_1(1)
m1_intercept = P_1(2)
m1_yfit = m1_slope*t_1 + m1_intercept
plot(t_1,m1_yfit,'r-.')

% Mission 2
P_2 = polyfit(t_2,Voltage_2,1)
m2_slope = P_2(1)
m2_intercept = P_2(2)
m2_yfit = m2_slope*t_2 + m2_intercept
plot(t_2,m2_yfit,'r-.')

% Mission 3
P_3 = polyfit(t_3,Voltage_3,1)
m3_slope = P_3(1)
m3_intercept = P_3(2)
m3_yfit = m3_slope*t_3 + m3_intercept
plot(t_3,m3_yfit,'r-.')

title('Voltage (V) vs Time (s) For All Three Missions')
xlim([0 300])
xlabel('Time (s)')
ylabel('')
legend('Mission 2','Mission 1','Mission 3')
