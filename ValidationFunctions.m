classdef ValidationFunctions

    methods 
        function [x, y1, y2] = performAllValidations(obj, x, y1, y2)
            obj.validateDuplicateXValues(x);
            obj.validateInputs(x, y1, y2);
            [x, y1, y2] = obj.validateAndCleanMissingData(x, y1, y2);
        end
        
        % Validate and Clean Missing Data in the inputs
        function [x, y1, y2] = validateAndCleanMissingData(obj, x, y1, y2)
            missing_x = find(isnan(x));
            missing_y = find(isnan(y1));
            missing_z = find(isnan(y2));
            missing_idx = union(union(missing_x, missing_y), missing_z);
            x(missing_idx) = [];
            y1(missing_idx) = [];
            y2(missing_idx) = [];
        end
        
        function validateDuplicateXValues(obj, x)
           if numel(x) ~= numel(unique(x))
                error("X values cannot be duplicated. X array should entirely consist of unique x-values")
           end
        end
        
        % Validate Inputs
        function validateInputs(obj, x, y1, y2)
            % If length of x is not equal to both y1 and y2, then we cannot create
            % the graph
            if numel(x) ~= numel(y1)
                error("invalid1:InputsAreInvalid", "Length of x is not equal to length of y1")
            end
            
            if numel(x) ~= numel(y2)
                error("invalid2:InputsAreInvalid", "Length of x is not equal to length of y2")
            end
        end
    end


end