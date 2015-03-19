classdef Impedance
    %IMPEDANCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        vcFilePath = './impedance chronic.xlsx';
        csDates;
        mrImp; %impedance values
        mrAng; %phase angle
    end
    
    methods
        function obj = Impedance(animalID)
        
        [~, ~, csImp] = xlsread(obj.vcFilePath, animalID);
        obj.csDates = csImp(1, 1:3:end);
        obj.mrImp = cell2mat(csImp(2:end, 2:3:end));
        obj.mrAng = cell2mat(csImp(2:end, 3:3:end));  
        
        end %constructor
    end
    
end

