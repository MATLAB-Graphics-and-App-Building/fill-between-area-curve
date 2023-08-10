classdef fillBetweenAreaCurve < matlab.graphics.chartcontainer.ChartContainer & ...
        matlab.graphics.chartcontainer.mixin.Legend

    % fillBetweenAreaCurve Shades the area between 2 curves
    %     fillBetweenAreaCurve(x, y1, y2) shades the area between 2 lines
    %     formed by (x,y1) and (x,y2)
    % 
    %     fillBetweenAreaCurve(x, y1, y2, c) shades the area between 2
    %     lines formed by (x,y1) and (x,y2) with color c
    %     
    %     fillBetweenAreaCurve(__, Name, Value) specifies additional
    %     options for the fillBetweenAreaCurve using one or more name-value
    %     pair arguments. Specify the options after all other input
    %     arguments

    properties
        
        % Data Properties of fillBetweenAreaCurve
        XData (1,:) double = [];
        Y1Data (1,:) double = [];
        Y2Data (1,:) double = [];
        

        % Properties for Fill Shape
        FaceAlpha (1,1) double {mustBeInRange(FaceAlpha, 0, 1)} = 0.2;

        % Properties for shading rest of the graph 
        ShadeInverse matlab.lang.OnOffSwitchState = 'on';


        % Properties for Line 1 
        Line1LineWidth (1,1) double {mustBePositive(Line1LineWidth)} = 1;
        Line1LineStyle (1,1) string {mustBeMember(Line1LineStyle, {'-', '--', ':', '-.'})} = '-';
        Label1 (1,1) string = "Curve 1";
       

        % Properties for Line 2
        Line2LineWidth (1,1) double {mustBePositive(Line2LineWidth)} = 1;
        Line2LineStyle (1,1) string {mustBeMember(Line2LineStyle, {'-', '--', ':', '-.'})}  = '-';
        Label2 (1,1) string = "Curve 2";
        
        % Propeties of the chart
        XLabel (1,1) string = "";
        YLabel (1,1) string = "";
        Title (1,1) string = "";

        % Triangulate polygon manually instead of asking patch to do it
        OptimizePerformance matlab.lang.OnOffSwitchState = 'on';

    end

  properties (Dependent)
      FaceColor;
      InverseFaceColor;
      Condition;
      Line1Color;
      Line2Color;

  end


   properties(Access = private,Transient,NonCopyable)
        Line1Object matlab.graphics.chart.primitive.Line 
        Line2Object matlab.graphics.chart.primitive.Line 
        PatchObject matlab.graphics.primitive.Patch
        InversePatchObject matlab.graphics.primitive.Patch
        Validator ValidationFunctions = ValidationFunctions;
   end

   properties(Access = private)
        FaceColorSetMode string = 'auto';
        InverseFaceColorSetMode string = 'auto';
        ConditionSetMode string = 'auto';
        Line1ColorSetMode string = 'auto';
        Line2ColorSetMode string = 'auto';

        FaceColor_I {validatecolor} = [0, 0, 1];
        InverseFaceColor_I {validatecolor} = [1, 0, 0];
        Condition_I = @(x, y1, y2) y1 >= y2;
        Line1Color_I {validatecolor} = [0, 0, 1];
        Line2Color_I {validatecolor} = [1, 0, 0];

        ContainsMappingToolbox matlab.lang.OnOffSwitchState = 'on';
   end

   methods
       function obj = fillBetweenAreaCurve(varargin)
           % Intialize list of arguments
           args = varargin;
           leadingArgs = cell(0);

            if ~isempty(args) && numel(args) >= 3  && isnumeric(args{1}) ...
                && isnumeric(args{2}) && isnumeric(args{3})
                   
                if numel(args) >= 3 && mod(numel(args), 2) == 1
                   % fillBetweenAreaCurve(x, y1, y2)
                   x = args{1};
                   y1 = args{2};
                   y2 = args{3};
                   leadingArgs = [leadingArgs {'XData', x, 'Y1Data', y1 , 'Y2Data', y2 }];
                   args = args(4:end);
               
                else
                   % fillBetweenAreaCurve(x, y1, y2, color)
                   x = args{1};
                   y1 = args{2};
                   y2 = args{3};
                   color = args{4};
                   leadingArgs = [leadingArgs {'XData', x, 'Y1Data', y1 , 'Y2Data', y2, 'FaceColor', color}];
                   args = args(5:end);
                end
            else
                warning('Invalid Input Arguments')
            end
            
            % Combine positional arguments with name/value pairs
            args = [leadingArgs args];

            % Call superclass constructor method
            obj@matlab.graphics.chartcontainer.ChartContainer(args{:});

       end
   end 

   methods(Access=protected)
       function setup(obj)
            ax = getAxes(obj);
            hold(ax,'all')
            obj.PatchObject = fill(ax, NaN, NaN, 'k');
            obj.PatchObject.EdgeColor = 'none';
            obj.PatchObject.Annotation.LegendInformation.IconDisplayStyle = 'off';

            obj.InversePatchObject = fill(ax, NaN, NaN, 'k');
            obj.InversePatchObject.Annotation.LegendInformation.IconDisplayStyle = 'off';
            obj.InversePatchObject.EdgeColor = 'none';

            obj.Line1Object = plot(ax, NaN, NaN);
            obj.Line2Object = plot(ax, NaN, NaN);

            % Setup colors of the plot to be the first 2 colors of the
            % colororder
            order = ax.ColorOrder;
            
            if obj.Line1ColorSetMode == "auto"
                obj.Line1Color = order(1, :);
            end

            if obj.Line2ColorSetMode == "auto"
                obj.Line2Color = order(2, :);
            end

            hold(ax,'off')



            if ~any(strcmp('Mapping Toolbox', {ver().Name})) 
                obj.ContainsMappingToolbox = 'off';
                warning("Mapping Toolbox is not installed. " + ...
                    "This may lead to degraded performance of the FillBetweenAreaCurve. " + ...
                    "Install Mapping Toolbox for better performance")
            end

       end

       function update(obj)
            ax = getAxes(obj);
            [obj.XData, obj.Y1Data, obj.Y2Data] = obj.Validator.performAllValidations( ...
                obj.XData, obj.Y1Data, obj.Y2Data);

            % Set Properties of Line 1
            obj.Line1Object.XData = obj.XData;
            obj.Line1Object.YData = obj.Y1Data;
            obj.Line1Object.Color = obj.Line1Color;
            obj.Line1Object.LineWidth = obj.Line1LineWidth;
            obj.Line1Object.DisplayName = obj.Label1;
            obj.Line1Object.LineStyle = obj.Line1LineStyle;
            
            % Set Properties of Line 2
            obj.Line2Object.XData = obj.XData;
            obj.Line2Object.YData = obj.Y2Data;
            obj.Line2Object.Color = obj.Line2Color;
            obj.Line2Object.LineWidth = obj.Line2LineWidth;
            obj.Line2Object.DisplayName = obj.Label2;
            obj.Line2Object.LineStyle = obj.Line2LineStyle;
            
            % If FaceColor/ InverseFaceColor has not be setup by user, use
            % the corresponding line color
            if obj.FaceColorSetMode == "auto"
                obj.FaceColor_I = obj.Line1Color;
            end

            if obj.FaceColorSetMode == "auto"
                obj.InverseFaceColor_I = obj.Line2Color;
            end 

            % Set legend, title and axis labels of the graph
            lgd = getLegend(obj);
   
            title(ax, obj.Title);
            xlabel(ax, obj.XLabel);
            ylabel(ax, obj.YLabel);
            
            % To ensure accuracy of shading, we need to insert 
            % intersection points into the existing data. 
            if obj.ContainsMappingToolbox
                [xi, yi] = polyxpoly(obj.XData, obj.Y1Data, obj.XData, obj.Y2Data);
                XData_final = [obj.XData, xi.'];
                Y1Data_final = [obj.Y1Data, yi.'];
                Y2Data_final = [obj.Y2Data, yi.'];             
            else
                XData_final = obj.XData;
                Y1Data_final = obj.Y1Data;
                Y2Data_final = obj.Y2Data;
            end

            [XData_final, idx] = sort(XData_final);
            Y1Data_final = Y1Data_final(idx);
            Y2Data_final = Y2Data_final(idx);


            % If the user provides a condition, we need to select all
            % the values for which the condition evaluates to true.
            % isInRange is a logical array where tells us which values
            % to select for shading finally
            isInRange = evaluateCondition(XData_final, Y1Data_final, Y2Data_final, obj.Condition);

            % We then build a patch object to shade the curve using x, y1 and y2 values obtained above
            buildPatchObjectForShadedAreaUsingLogicalArray(obj.PatchObject, isInRange, XData_final, Y1Data_final, Y2Data_final, ...
                obj.FaceAlpha, obj.FaceColor, obj.OptimizePerformance);
            

            % If a user wants to shade the rest of the graph with a separate color, 
            % then we generate invert the isInRange logical array to pick all the 
            % values that do not satisfy condition. In this case, the
            % isNotInRange logical array tells us which values to pick. 
            % We then further build a PatchObject using the new x , y1
            % and y2 values
            if obj.ShadeInverse
                isNotInRange = generateInverseLogicalArray(isInRange);
                buildPatchObjectForShadedAreaUsingLogicalArray(obj.InversePatchObject, isNotInRange, XData_final, Y1Data_final, Y2Data_final, ...
                    obj.FaceAlpha, obj.InverseFaceColor, obj.OptimizePerformance);
                
                % If the user specifies a condition in there chart we need
                % to turnsavefig on displaying area in the legends
                if obj.ConditionSetMode == "manual" 
                    obj.PatchObject.Annotation.LegendInformation.IconDisplayStyle = 'on';
                    obj.PatchObject.DisplayName = "Satisfies Condition";
                    if obj.ShadeInverse
                        obj.InversePatchObject.DisplayName = "Doesn't Satisfy Condition";
                        obj.InversePatchObject.Annotation.LegendInformation.IconDisplayStyle = 'on';
                    end
                end
            else
                % If a user turns off ShadeInverse, color the inverse face
                % as white and don't display it in the legend
                obj.InversePatchObject.FaceColor = 'w';
                obj.InversePatchObject.Annotation.LegendInformation.IconDisplayStyle = 'off';

            end
       end 

       
   end

   methods(Access = {?tFillBetweenAreaCurve})
       function ax = getTestAxes(obj)
           ax = getAxes(obj);
       end
   end

   methods
       function set.FaceColor(obj, FaceColor)
            obj.FaceColorSetMode = 'manual';
            obj.FaceColor_I = validatecolor(FaceColor);
       end

       function faceColor = get.FaceColor(obj)
            faceColor = obj.FaceColor_I;
       end

       function set.InverseFaceColor(obj, InverseFaceColor)
            obj.InverseFaceColorSetMode = 'manual';
            obj.InverseFaceColor_I = validatecolor(InverseFaceColor);
       end

       function inverseFaceColor = get.InverseFaceColor(obj)
             inverseFaceColor = obj.InverseFaceColor_I;
       end

       function set.Condition(obj, condition)
            obj.ConditionSetMode = 'manual';
            obj.Condition_I = condition;
       end

       function condition = get.Condition(obj)
            condition = obj.Condition_I;
       end

       function set.Line1Color(obj, LineColor)
            obj.Line1ColorSetMode = 'manual';
            obj.Line1Color_I = validatecolor(LineColor);
       end

       function line1Color = get.Line1Color(obj)
            line1Color = obj.Line1Color_I;
       end

       function set.Line2Color(obj, LineColor)
            obj.Line2ColorSetMode = 'manual';
            obj.Line2Color_I = validatecolor(LineColor);
       end    

       function line2Color = get.Line2Color(obj)
            line2Color = obj.Line2Color_I;
       end

       function set.Line1LineWidth(obj, LineWidth)
           obj.Line1LineWidth = LineWidth;
       end

       function set.Line2LineWidth(obj, LineWidth)
           obj.Line2LineWidth = LineWidth;
       end

   end
end



function buildPatchObjectForShadedAreaUsingLogicalArray(patchObject, includeVals, XData, Y1Data, Y2Data, alpha, faceColor, optimizePerformance)
    % Extract the X, Y1 and Y2 Data based on logical array -
    % includeVals
    filtered_XData = XData(includeVals);
    filtered_Y1Data = Y1Data(includeVals);
    filtered_Y2Data = Y2Data(includeVals);


    patchObject.FaceAlpha = alpha;
    patchObject.FaceColor = faceColor;
    
     % Define the vertices polygon which will define our shaded area
    poly_XData = [filtered_XData fliplr(filtered_XData)];
    poly_YData = [filtered_Y1Data  fliplr(filtered_Y2Data)];

    % Define Vertices and Faces for polygon that defines the shaded
    % area
    patchObject.Vertices = [poly_XData(:) poly_YData(:)];
    patchObject.Faces = returnFaceList(includeVals, numel(poly_XData), optimizePerformance);
    
end


function isInRange = evaluateCondition(XData, Y1Data, Y2Data, Condition)
    % Use condition to filter out x, y1 and y2 values which do not
    % satisfy the Condition function.
    try
        isInRange = Condition(XData, Y1Data, Y2Data);
    catch ME
       warning(ME.message + ". Invalid Function Supplied. Shading all regions")
    end

    filtered_XData = XData(isInRange);
    filtered_Y1Data = Y1Data(isInRange);
    filtered_Y2Data = Y2Data(isInRange);           

end



% While shading there can be discontinuous regions in our shaded area. 
% These discontiuous regions each consitute a seperate Face in our
% PatchObject

% Given the number of vertices and boolean array describing
% which x-values are included in the shaded area the function 
% returns a 2-d array where each row specifies how vertices will be
% connected
function faceList = returnFaceList(true_vals, nVertices, optimizePerformance)

    contLengthList = [];
    currentLength = 0;

    % Find continuous regions in the shaded areas 
    for i = 1 : numel(true_vals)
        if true_vals(i)
            currentLength = currentLength + 1;

        elseif currentLength > 0
            contLengthList = [contLengthList; currentLength];
            currentLength = 0;
        end
    end

    if currentLength > 0
        contLengthList = [contLengthList; currentLength];
    end

    faceList = [];
    startVertex = 1;
    endVertex = nVertices;
    maxCurrentLength = 2 *  max(contLengthList) + 1;

    % Create a single face with continuous regions 
    for i = 1: numel(contLengthList)
        contLength = contLengthList(i);

        % If OptimizePerformance is turned off, For each face we just
        % calculate which vertices are part of a face and pass it to patch
        % Internally, Patch will triangulate the polygon and calculate
        % vertices of the triangle
        if ~optimizePerformance
            currFaceList = [startVertex: startVertex + contLength - 1, endVertex - contLength + 1: endVertex, startVertex];
            currFaceList = [currFaceList, NaN(1, maxCurrentLength - numel(currFaceList))];
            faceList = [faceList; currFaceList];
        
         % If OptimizePerformance is turned on, For each face we calculate
         % vertices of triangles that will form the polygon. Each face will
         % have 3 vertices, Each vertices will be part of 2 face. 
        else 
    
            topLineSegmentIdxs = startVertex: startVertex + contLength - 1;
            bottomLineSegmentIdxs = endVertex: -1: endVertex - contLength + 1;

            topLineSegmentPtr = 1; bottomLineSegmentPtr = 1;

            while topLineSegmentPtr < numel(topLineSegmentIdxs) && bottomLineSegmentPtr < numel(bottomLineSegmentIdxs)
                faceList = [faceList; topLineSegmentIdxs(topLineSegmentPtr), topLineSegmentIdxs(topLineSegmentPtr + 1), bottomLineSegmentIdxs(bottomLineSegmentPtr)];
                faceList = [faceList; bottomLineSegmentIdxs(bottomLineSegmentPtr), bottomLineSegmentIdxs(bottomLineSegmentPtr + 1), topLineSegmentIdxs(topLineSegmentPtr + 1)];
                topLineSegmentPtr = topLineSegmentPtr + 1;
                bottomLineSegmentPtr = bottomLineSegmentPtr + 1;
            end
        end

        startVertex = startVertex + contLength;
        endVertex = endVertex - contLength;
    end

end

function isNotInRange = generateInverseLogicalArray(isInRange)
      isNotInRange = ~isInRange;
      for i = 1:numel(isInRange)
          if i < numel(isInRange) && isInRange(i) && ~isInRange(i + 1)
              isNotInRange(i) = true;
          elseif i > 1 && isInRange(i) && ~isInRange(i - 1)
              isNotInRange(i) = true;
          end
      end
end