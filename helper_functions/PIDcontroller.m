classdef PIDcontroller < handle
    properties
        P {mustBeNumeric}=0
        I {mustBeNumeric}=0
        D {mustBeNumeric}=0
    end
   methods 
       function [obj,TF]=getTF(obj)
           TF=pid(obj.P,obj.I,obj.D);
       end
       
   end
end