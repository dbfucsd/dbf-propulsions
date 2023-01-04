function [v,TurnRate,TurnRadius] = DBFBankTurn(mass,Cl,n,WingSurfaceArea)
%Inputs: mass(kg),Cl,n,WingSurfaceArea(m^3)
%Outputs: velocity(m/s),TurnRate(rad/s),TurnRadius(m)
%All calculations based off "Simulation Math" pdf

%Re-label formulas to make formulas easier
M = mass;
L = Cl;
Theta = acos(1/n);
S = WingSurfaceArea;

%Assign constants
g = 9.79247; % For Tucson, Az (m/s^2)
R = 1.225; %Air density (kg/m^3)

%Calculate velocity
v = sqrt(2*M*g/(R*S*L*cos(Theta)));

%Calculate TurnRadius
TurnRadius = 2*M/(R*S*L*sin(Theta));

%Calculate TurnRate
TurnRate = g*tan(Theta);

[v,TurnRate,TurnRadius]