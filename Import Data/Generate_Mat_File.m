%---------------------------------------------------------------%
%   UCSD DBF Propulsions Subteam 
%   Propeller & Motor Data Import Script
%   
%   Data sheets MUST be converted to an .XLSX file from the .txt
%   file generated off of the APC website
%   https://www.apcprop.com/technical-information/performance-data/
%   Using Excel, open the .txt file, use Delimited, check Spaces, 
%   and do not import column (skip first column). Then save
%   as a .xlsx file in the same directory that this script is in
%   
%   Errors may occur when importing new Propeller data sheets. This occurs 
%   because the APC datasheets //suck// sometimes import '-Nan' values 
%   into the cells. Simply replace the Nan values with zeros. They 
%   usually occur at high RPM values and are <10 of them, so it can be 
%   considered negligible.
%
%   Electric Motor Data only requires Kv, No-Load Current,
%   and Motor Resistance (Kv,I0,Rm respectively). Information is usually
%   found on the purchase website. Scorpion Motors are pretty good :)
%   https://www.scorpionsystem.com/catalog/aeroplane/motors_1/
%
%   First Created by 
%   Ryan Dunn 
%   Propulsions Lead 2019-2021
%   
%   Last Editted by
%   Kevin Vo
%   Propulsions Lead 2022
%   1/6/2023

%% Variable Legend
% -------------- Input Variables --------------

% MotorFile = An input variable containing the imported Motor excel sheet, 
% which contains: NAME, Kv, Rm, and I_0 of various motors.

% PropFiles = An input variable containing all the imported Propeller Data
% sheets. Each propeller data sheet contains V, J, Pe, Ct, PWR, Torque, 
% and Thrust of each propeller type.

% -------------- Output Variables in DataImport.mat --------------

% Motornames = contains the names of motors
% Kv = ratio of the motor's unloaded rpm to the peak voltage on the wires
% connected  to the coils [RPM/Volt] This rating is helpful to determine
% how fast a motor will rotate when a given voltage is applied to it.
% I0 = No-Load Current @ 10 Volts: The no-load current is the current 
% required just to turn the motor shaft with nothing connected. [Amps]
% Rm = Motor Resistance [Ohms]

% Propnames = name of propeller ([propeller diameter x pitch])
% diameter = propeller diameter [in]
% pitch = propeller pitch [in]
% maxRPM = maximum RPM of propeller
% V = model speed [mph]
% J = advance ratio (J=V/nD)
% Pe = propeller efficiency
% Ct = thrust coefficient (Ct=T/(rho * n**2 * D**4))
% Cp = power coefficient (Cp=P/(rho * n**3 * D**5))
% PWR = power [Hp]
% Qprop = propeller torque [In-lbf]
% T = thrust [lbf]

%% Initialize
clear all; close all; format longg; clc;
%% Input Sheets
MotorFile = 'Motor_data.xlsx';

% Add propeller datasheets to the generated .mat file by adding a string of
% the file name to the variable below. The whole list is organized by
% propeller diameter and pitch. NOTE: If the propeller diameter is in the
% double digits in a section that has a single digit diameter, it means
% that value is a decimal value. e.g. 41x41E is 4.1 inch diameter x 4.1
% pitch
PropFiles  = {
            
            '1225x375.xlsx'
            '125x10.xlsx'
            '125x11.xlsx'
            '125x115.xlsx'
            '125x12.xlsx'
            '125x125.xlsx'
            '125x13.xlsx'
            '125x6.xlsx'
            '125x9.xlsx'
            % --------------- 4 Inch ---------------
            '41x41E.xlsx'
            '42x2.xlsx'
            '42x4.xlsx'
            '4375x425.xlsx'
            '45x35.xlsx'
            '45x4.xlsx'
            '45x41E.xlsx'
            '46x3.xlsx'
            '475x4.xlsx'
            '475x45E.xlsx'
            '475x475E.xlsx'
            '475x55E.xlsx'
            '47x42E.xlsx'
            '4x33E.xlsx'
            '4x45E.xlsx'

            % --------------- 5 Inch ---------------
            '5x3.xlsx'
            '5x3E.xlsx'
            '5x43E.xlsx'
            '5x45E.xlsx'
            '5x46E.xlsx'
            '5x4E-3.xlsx'
            '5x5E.xlsx'
            '51x45E.xlsx'
            '51x50E.xlsx'
            '52x60E.xlsx'
            '525x475E.xlsx'
            '525x625E.xlsx'
            '55x2.xlsx'
            '55x25.xlsx'
            '55x45E.xlsx'
            '55x47E.xlsx'
            '55x65E.xlsx'
            '57x3.xlsx'

            % --------------- 6 Inch ---------------
            '6x2.xlsx'
            '6x3.xlsx'
            '6x4E.xlsx'
            '6x43E.xlsx'
            '6x45E.xlsx'
            '6x55E.xlsx'
            '6x5.xlsx'
            '6x6E.xlsx'
            '63x4.xlsx'
            '65x29.xlsx'
            '65x37.xlsx'
            '65x50.xlsx'
            '65x55.xlsx'
            '65x60.xlsx'
            '65x65.xlsx'
            '65x70.xlsx'

            % --------------- 7 Inch --------------- 
            '7x3.xlsx'
            '7x4E.xlsx' 
            '7x5.xlsx'
            '7x5E.xlsx'
            '7x6.xlsx'
            '7x6E.xlsx'
            '7x65D.xlsx'
            '7x7.xlsx'
            '7x7E.xlsx'
            '7x8.xlsx'
            '7x9.xlsx'
            '7x10.xlsx'
            '75x25.xlsx'
            '78x4.xlsx'
            '78x6.xlsx'
            '78x7.xlsx'

            % --------------- 8 Inch ---------------
            '8x4.xlsx'
            '8x4E.xlsx'
            '8x5.xlsx'
            '8x6E.xlsx'
            '8x7.xlsx'
            '8x8.xlsx'
            '8x8E.xlsx'
            '8x9.xlsx'
            '8x10.xlsx'
            '8x375.xlsx'
            '8x725.xlsx'
            '85x55.xlsx'
            '85x70.xlsx'
            '85x75.xlsx'
            '85x725.xlsx'
            '8625x375.xlsx'
            '875x50.xlsx'
            '88x85.xlsx'
            '88x89.xlsx'
            '88x90.xlsx'
            '88x95.xlsx'
            '88x875.xlsx'
            '88x925.xlsx'
            '88x975.xlsx'

            % --------------- 9 Inch ---------------
            '9x3.xlsx'
            '9x4.xlsx'
            '9x45E.xlsx'
            '9x6.xlsx'
            '9x6E.xlsx'
            '9x65.xlsx'
            '9x75.xlsx'
            '9x75E.xlsx'
            '9x85.xlsx'
            '9x10.xlsx'
            '925x50.xlsx'
            '925x525.xlsx'
            '925x55.xlsx'
            '925x575.xlsx'
            '925x60.xlsx'
            '93x3.xlsx'
            '95x45.xlsx'
            '95x6.xlsx'

            % --------------- 10 Inch ---------------           
            '10x3.xlsx'
            '10x4.xlsx'
            '10x5.xlsx'
            '10x5E.xlsx'
            '10x6.xlsx'
            '10x6E.xlsx'
            '10x6-4.xlsx'
            '10x7.xlsx'
            '10x7E.xlsx'
            '10x7-3.xlsx'
            '10x8.xlsx'
            '10x8E.xlsx'
            '10x9.xlsx'
            '10x10.xlsx'
            '10x10E.xlsx'

            % --------------- 11 Inch ---------------
            '11x3.xlsx'
            '11x4.xlsx'
            '11x45EP.xlsx'
            '11x5.xlsx'
            '11x55E.xlsx'
            '11x6.xlsx'
            '11x6-4.xlsx'
            '11x7.xlsx'
            '11x7E.xlsx'
            '11x8.xlsx'
            '11x8E.xlsx'
            '11x85E.xlsx'
            '11x9.xlsx'
            '11x9-4.xlsx'
            '11x10.xlsx'
            '11x10E.xlsx'
            '11x11.xlsx'
            '11x12.xlsx'
            '11x12E.xlsx'
            '11x13.xlsx'
            '11x14.xlsx'

            % --------------- 12 Inch ---------------
            '12x4.xlsx'
            '12x5.xlsx'
            '12x6.xlsx'
            '12x6E.xlsx'
            '12x7.xlsx'
            '12x8.xlsx'
            '12x8E.xlsx'
            '12x9.xlsx'
            '12x10.xlsx'
            '12x10E.xlsx'
            '12x11.xlsx'
            '12x12.xlsx'
            '12x12E.xlsx'
            '12x13.xlsx'
            '12x14.xlsx'

            % --------------- 13 Inch ---------------
            '13x4.xlsx'
            '13x4E.xlsx'
            '13x45EP.xlsx'
            '13x55E.xlsx'
            '13x6.xlsx'
            '13x65E.xlsx'
            '13x7.xlsx'
            '13x8.xlsx'
            '13x8E.xlsx'
            '13x9.xlsx'
            '13x10E.xlsx'
            '13x11.xlsx'
            '13x13-4.xlsx'

            % --------------- 14 Inch ---------------
            '14x6.xlsx'
            '14x6E.xlsx'
            '14x7.xlsx'
            '14x7E.xlsx'
            '14x85E.xlsx'
            '14x10E.xlsx'
            '14x11.xlsx'
            '14x12.xlsx'
            '14x12E.xlsx'
            '14x13.xlsx'
            '14x135.xlsx'
            '14x14.xlsx'
            '14x14E.xlsx'

            % --------------- 15 Inch ---------------
            '15x4E.xlsx'
            '15x6.xlsx'
            '15x6E.xlsx'
            '15x7.xlsx'
            '15x7E.xlsx'
            '15x8.xlsx'
            '15x8E.xlsx'
            '15x10.xlsx'
            '15x10E.xlsx'
            '15x11-4.xlsx'
            '15x11.xlsx'
            '15x12.xlsx'
            '15x13.xlsx'
            '15x13W.xlsx'
            '15x135.xlsx'
            '15x14.xlsx'

            % --------------- 16 Inch ---------------
            '16x4E.xlsx'
            '16x6.xlsx'
            '16x6E.xlsx'
            '16x7.xlsx'
            '16x8.xlsx'
            '16x8E.xlsx'
            '16x10.xlsx'
            '16x10E.xlsx'
            '16x11.xlsx'
            '16x12.xlsx'
            '16x12E.xlsx'
            '16x13.xlsx'
            '16x14.xlsx'
            '16x15.xlsx'
            '16x16.xlsx'

            % --------------- 17 Inch ---------------
            '17x6.xlsx'
            '17x6E.xlsx'
            '17x7E.xlsx'
            '17x8.xlsx'
            '17x8E.xlsx'
            '17x10.xlsx'
            '17x10E.xlsx'
            '17x12.xlsx'
            '17x1275.xlsx'
            '17x12E.xlsx'
            '17x13.xlsx'
            '17x18.xlsx'

            % --------------- 18 Inch ---------------
            '18x8.xlsx'
            '18x8E.xlsx'
            '18x10.xlsx'
            '18x11.xlsx'
            '18x12.xlsx'
            '18x12E.xlsx'
            '18x14.xlsx'
            '18x16.xlsx'
            '181x11.xlsx'
            '181x12.xlsx'
            '185x95.xlsx'

            % --------------- 19 Inch ---------------
            '19x8E.xlsx'
            '19x10E.xlsx'
            '19x11.xlsx'
            '19x12E.xlsx'
            '19x14.xlsx'
            '19x16.xlsx'

            % --------------- 20 Inch ---------------
            '20x8.xlsx'
            '20x8E.xlsx'
            '20x10.xlsx'
            '20x10E.xlsx'
            '20x11E.xlsx'
            '20x12.xlsx'
            '20x13E.xlsx'
            '20x14.xlsx'
            '20x15E.xlsx'
            '20x16.xlsx'
            '20x18.xlsx'
            '205x14E.xlsx'

            % --------------- 21 Inch ---------------
            '21x13E.xlsx'
            '21x135E.xlsx'

            % --------------- 22 Inch ---------------
            '22x8.xlsx'
            '22x10.xlsx'
            '22x10E.xlsx'
            '22x12E.xlsx'

            % --------------- 24 Inch ---------------
            '24x12E.xlsx'

            % --------------- 25 Inch ---------------
            '25x125E.xlsx'

            % --------------- 26 Inch ---------------
            '26x13E.xlsx'
            '26x15E.xlsx'

            % --------------- 27 Inch ---------------
            '27x13E.xlsx'
            };

%% Initialize & Import

% Import Propellers Loop
for FILE=1:length(PropFiles)
    % Open File
    insheet = readcell(PropFiles{FILE},'Sheet',1);
    Propnames{FILE} = insheet{1,1};
    diameter(FILE)  = str2num(Propnames{FILE}(1:(find(Propnames{FILE}=='x')-1)));
    pitch{FILE}     = Propnames{FILE}(((find(Propnames{FILE}=='x')+1):end));
    maxRPM(FILE)    = (size(insheet,1)-10)/37;
    % Import chunks of data based on RPM
    for i=1:maxRPM(FILE)
       % Direct Import
       V{FILE}{i}       = cell2mat(insheet((-19+37*i):(10+37*i),1));
       J{FILE}{i}       = cell2mat(insheet((-19+37*i):(10+37*i),2));
       Pe{FILE}{i}      = cell2mat(insheet((-19+37*i):(10+37*i),3));
       Ct{FILE}{i}      = cell2mat(insheet((-19+37*i):(10+37*i),4));
       Cp{FILE}{i}      = cell2mat(insheet((-19+37*i):(10+37*i),5));
       PWR{FILE}{i}     = cell2mat(insheet((-19+37*i):(10+37*i),6));
       Qprop{FILE}{i}   = cell2mat(insheet((-19+37*i):(10+37*i),7));
       T{FILE}{i}       = cell2mat(insheet((-19+37*i):(10+37*i),8));
    end
    fprintf('imported propeller #%d successfully\n',FILE)
end
fprintf('imported propellers successfully\n',length(PropFiles));

% Read Motor File
insheet = readcell(MotorFile,'Sheet',1);
for i=1:(size(insheet,1)-1)
    Motornames{i} = insheet{i+1,1};    
    Kv(i) = insheet{i+1,2};
    Rm(i) = insheet{i+1,3};
    I0(i) = insheet{i+1,4};
end
fprintf('imported motors successfully\n');

%clear FILE temp i PropFiles MotorFile insheet
clear FILE temp i MotorFile insheet

save('DataImport.mat')
fprintf('done\n')