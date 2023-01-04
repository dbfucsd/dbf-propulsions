function [v]=DBFSteadyFlight(mass,Cl,k,Cd0,MotorAngle,WingSurfaceArea)
%Inputs: mass(kg),Cl,k,Cd0,MotorAngle(deg),WingSurfaceArea(m^3)
%Outputs: velocity(m/s)
%All calculations based off "Simulation Math" pdf

%Calculate the drag coefficient
Cd = Cd0 + k*Cl^2;

%Re-label variables to make formulas easier
M = mass;
L = Cl;
D = Cd;
S = WingSurfaceArea;

%Convert from degrees to radians
a = MotorAngle*0.0174533;

%Assign constants 
g = 9.79247; % For Tucson, Az (m/s^2)
R = 1.225; %Density of air (kg/m^3)

%Calculate velocity
v = sqrt(2*M*g/(R*S*(L+D*tan(a))));
