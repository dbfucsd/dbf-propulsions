%---------------------------------------------------------------%
%   UCSD DBF Propulsion Subteam Master Optimization Script
%   
%   
%   First Created by 
%   Ryan Dunn 
%   Propulsions Lead 2019-2021
%   
%   Last Editted by
%   Kevin Vo
%   12/30/22.
%   
%---------------------------------------------------------------%
%% Initialize
clear all; close all; format longg; clc;
%% Input Parameters

outfile = 'Results.xlsx';

numProps = 1;   % Number of Propellers
Voltage = 22.2; % Voltage of Battery *NOTE* Voltage does change throughout
                % the flight, but the labeled volate is a fair average.

% MISSION REQUIREMENTS
% Based on values acquired from Aero Team: 
% Drag & Cruising speed
% Assuming steady level flight: Thrust = Drag
% [Thrust/numProps CruiseAirspeed]
% [lbsf MPH]
Mreq{1} = [0.413/numProps 53.18];
Mreq{2} = [0.336/numProps 47.7];
Mreq{3} = [0.336/numProps 47.7];

% Import Propeller & Motor Datasheets (Make sure to overwrite old
% DataImport.mat after rerunning 
load('DataImport.mat')

%% Propeller Analysis & Mission Performance Criteria

fprintf('beginning propeller analysis\n');
% Mission-Propeller loop for calculating
max_eff=ones(3,1);
for MISSION=1:3
    for FILE=1:length(Propnames)
        Vmission{FILE} = zeros(1,3);
        for n=maxRPM(FILE):-1:1 % Find the minimum RPM where mission criteria is met
            req1 = T{FILE}{n} > Mreq{MISSION}(1);
            req2 = V{FILE}{n} > Mreq{MISSION}(2);
            if nnz(req1) && nnz(req2) % There exists a V where it provides enough thrust
                for x=30:-1:1
                    if req1(x) && req2(x)
                        Vmission{FILE}(MISSION) = V{FILE}{n}(x);
                        RPMmission{FILE}(MISSION) = n*1000;
                        Pemission{FILE}(MISSION) = Pe{FILE}{n}(x);
                        Qpropmission{FILE}(MISSION) = Qprop{FILE}{n}(x);
                    end
                end
            elseif (Vmission{FILE}(MISSION)) == 0 % If criteria not met, return zeros
                Vmission{FILE}(MISSION) = 0;
                RPMmission{FILE}(MISSION) = 0;
                Pemission{FILE}(MISSION) = 0;
                Qpropmission{FILE}(MISSION) = 0;
            end
        end
        if Pemission{FILE}(MISSION) > Pemission{max_eff(MISSION)}(MISSION)
            max_eff(MISSION)=FILE;
        end
    end
end

% Print Best Propeller
for M=1:3
    bestprops{M,1} = Propnames{max_eff(M)};
end
bestprops
fprintf('completed propeller analysis successfully\n');

%% Motor Analysis

% Data initialization
fprintf('beginning motor analysis\n')

% Motor Analysis loop
for Motor = 1:length(Motornames)
    Kt(Motor) = 1355/Kv(Motor);
    RPMmax(Motor) = Kv(Motor) * (Voltage - Rm(Motor)*I0(Motor));
    Imax(Motor) = (Voltage) / Rm(Motor);

    eta_motor{Motor} = @(RPM,A) (Kt(Motor)*(A-I0(Motor))*0.007061552*RPM*2*pi/60) / (Voltage*A);
end
fprintf('completed motor analysis successfully\n')
%% Mission Combination Analysis
fprintf('beginning mission combination analysis\n')
for MISSION = 1:3    
    for Prop = 1:length(Propnames)
        if RPMmission{Prop}(MISSION) == 0 % Makes sure Prop meets mission criteria
            for Motor=1:length(Motornames)
                outsheet{MISSION}{Prop+1,Motor+1} = 0; % Returns zero if fail
            end
            continue
        end
        RPMcrit = RPMmission{Prop}(MISSION);
        Qcrit = Qpropmission{FILE}(MISSION)*0.112985; % in-lbf to Nm conversion
        
        for Motor = 1:length(Motornames)
            eta_Prop{MISSION}(Prop,Motor) = Pemission{Prop}(MISSION);
            Aindex = Qcrit/(Kt(Motor)*0.007061552) + I0(Motor);
            RPMmax = Kv(Motor)*(Voltage-Rm(Motor)*I0(Motor));
            if RPMcrit < RPMmax
                eta_Motor{MISSION}(Prop,Motor) = eta_motor{Motor}(RPMcrit,Aindex);
                amp_draw{MISSION}(Prop,Motor) = Aindex;
            else
                eta_Motor{MISSION}(Prop,Motor) = 0;
                amp_draw{MISSION}(Prop,Motor) = 0;
            end
            eta_net{MISSION}(Prop,Motor) = eta_Prop{MISSION}(Prop,Motor)*eta_Motor{MISSION}(Prop,Motor);

            outsheet{MISSION}{Prop+1,Motor+1} = eta_net{MISSION}(Prop,Motor);
            outsheet{MISSION}{Prop+length(Propnames)+3,Motor+1} = amp_draw{MISSION}(Prop,Motor);
        end
    end

    % Generating outsheet
    for Prop = 1:length(Propnames)
        outsheet{MISSION}{Prop+1,1} = Propnames{Prop};
        outsheet{MISSION}{Prop+length(Propnames)+3,1} = Propnames{Prop};
    end
    for Motor=1:length(Motornames)
        outsheet{MISSION}{1,Motor+1} = Motornames{Motor};
        outsheet{MISSION}{length(Propnames)+3,Motor+1} = Motornames{Motor};
    end
     
%      xlswrite(outfile,outsheet{MISSION},MISSION)
end

for MISSION=1:3
    maxeff(MISSION) = max(max(eta_net{MISSION}));
    [bestprop, bestmotor] = find(eta_net{MISSION} == maxeff(MISSION));
    best_combo{1,MISSION} = sprintf('Mission %0.f Optimized',MISSION);
    best_combo{2,MISSION} = sprintf('%0.f: %s',bestprop,Propnames{bestprop});
    best_combo{3,MISSION} = sprintf('%0.f: %s',bestmotor,Motornames{bestmotor});
    best_combo{4,MISSION} = sprintf('%.4f eta_net',eta_net{MISSION}(bestprop,bestmotor));
    best_combo{5,MISSION} = sprintf('%.4f Amps',amp_draw{MISSION}(bestprop,bestmotor));
    best_combo{6,MISSION} = sprintf('%.0f RPM',RPMmission{bestprop}(MISSION));
    best_combo{7,MISSION} = sprintf('%.4f eta_P',eta_Prop{MISSION}(bestprop,bestmotor));
    best_combo{8,MISSION} = sprintf('%.4f eta_M',eta_Motor{MISSION}(bestprop,bestmotor));
end
fprintf('completed mission analysis successfully\n')
best_combo