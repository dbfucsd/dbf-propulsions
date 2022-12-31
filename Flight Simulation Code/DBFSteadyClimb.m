function [v] = DBFSteadyClimb(mass,k,Cl,Cd0,ClimbAngle,MotorAngle,WingSurfaceArea)
%Inputs:
%mass(kg),k,Cl,Cd0,ClimbAngle(deg),MotorAngle(deg);WingSurfaceArea(m^3)
%Outputs: velocity(m/s)
%All calculations based off "Simulation Math" pdf

%Calculate drag coefficient
Cd = Cd0 + k*Cl^2;

%Re-label formulas to make formulas easier
M = mass;
L = Cl;
D = Cd;
S = WingSurfaceArea;

%Convert from degrees to radians
T = ClimbAngle*0.0174533;
A = MotorAngle*0.0174533;

%Assign constants
g = 9.79247; % For Tucson, Az (m/s^2)
R = 1.225; %Air density (kg/m^3)

%Pre-calculations to make formula nicer
Q = cos(T);
W = sin(T);
E = tan(T+A);

%Calculate velocity
v = sqrt(2*M*g/(R*S*(L*Q+L*W*E+D*Q*E-D*W)));