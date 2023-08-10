classdef tFillBetweenAreaCurve < matlab.unittest.TestCase

    properties
        TestFigure
    end

    properties(TestParameter)
        testSyntaxesData = createTestSyntaxesData;
        testErrorData = createTestErrorData;
        testInterpolateData = createTestInterpolateData;
        testFigureOrderData = createTestFigureOrderData;
        testEmptyData = createTestEmptyData;
    end

    methods(TestClassSetup)
        function createFigure(testCase)
            testCase.TestFigure = figure;
            testCase.addTeardown(@() delete(testCase.TestFigure));
        end
    end


    methods(Test)
        function testSyntaxes(testCase, testSyntaxesData)  
           args = testSyntaxesData.Args;
           h = hTestFillAreaBetweenCurve(args{:});
           h.callUpdate();

           expectedXData = testSyntaxesData.XData;
           expectedY1Data = testSyntaxesData.Y1Data;
           expectedY2Data = testSyntaxesData.Y2Data;
           expectedFaceColorData = testSyntaxesData.FaceColor;

           testCase.verifyEqual(h.XData, expectedXData);
           testCase.verifyEqual(h.Y1Data, expectedY1Data);
           testCase.verifyEqual(h.Y2Data, expectedY2Data);
           testCase.verifyEqual(h.FaceColor, expectedFaceColorData);
        end

        function testEmptyDataDoesntBreakChart(testCase, testEmptyData)
            args = testEmptyData.Args;
            h = hTestFillAreaBetweenCurve(args{:});
            h.callUpdate();          
            h.XData = [];
            h.Y1Data = [];
            h.Y2Data = [];
            h.callUpdate();   
        end

        function testFigureOrder(testCase, testFigureOrderData)
            args = testFigureOrderData.Args;
            h = hTestFillAreaBetweenCurve(args{:});

            figObjects = h.getTestAxes().Children;
            testCase.verifyEqual(numel(figObjects), 4);
            testCase.verifyEqual(class(figObjects(1)), 'matlab.graphics.chart.primitive.Line');
            testCase.verifyEqual(class(figObjects(2)), 'matlab.graphics.chart.primitive.Line');
            testCase.verifyEqual(class(figObjects(3)), 'matlab.graphics.primitive.Patch');
            testCase.verifyEqual(class(figObjects(4)), 'matlab.graphics.primitive.Patch');
        end

        function testErrors(testCase, testErrorData)
            args = testErrorData.Args;
            errorIdentifier = testErrorData.id;
            errorMsg = testErrorData.errorMsg;
            % 
            % h = hTestFillAreaBetweenCurve(args{:});
            testCase.verifyError(@()hTestFillAreaBetweenCurve(args{:}), errorIdentifier, errorMsg);
        end

    end
end

function testSyntaxesData = createTestSyntaxesData
    XData = linspace(0, 4 * pi, 100);
    Y1Data = sin(XData);
    Y2Data = cos(XData);
    faceColor = [0.4 0.2 0.3];

    args1 = {XData Y1Data Y2Data};
    args2 = {XData Y1Data Y2Data faceColor};
    

    testSyntaxesData = struct( ...
        'SetXY1Y2DataSyntax', struct('Args', {args1}, 'XData', {XData}, ...
        'Y1Data', Y1Data, 'Y2Data', Y2Data, 'FaceColor', 'g') , ...
        'SetXY1Y2ColorDataSyntax', struct('Args', {args2}, 'XData', {XData}, ...
        'Y1Data', Y1Data, 'Y2Data', Y2Data, 'FaceColor', faceColor));
    
end

function testInterpolateData = createTestInterpolateData
    XData = linspace(0, 4 * pi, 100);
    Y1Data = sin(XData);
    Y2Data = cos(XData);

    [xi, yi] = polyxpoly(XData, Y1Data, XData, Y2Data);
    inter_XData = [XData, xi.'];
    inter_Y1Data = [Y1Data, yi.'];
    inter_Y2Data = [Y2Data, yi.'];

    [inter_XData, idx] = sort(inter_XData);
    inter_Y1Data = inter_Y1Data(idx);
    inter_Y2Data = inter_Y2Data(idx);

    args = {XData Y1Data Y2Data "Interpolate" true};
    testInterpolateData = struct( ...
        'SetInterpolateTrue', struct('Args', {args}, 'XData', inter_XData, ...
        'Y1Data', inter_Y1Data, 'Y2Data', inter_Y2Data));

end

function testErrorData = createTestErrorData
        XData = 1:10;
        Case1_Y1Data = 1:11;
        Case1_Y2Data = 1:10;
        Case1_args = {XData Case1_Y1Data Case1_Y2Data};

        Case1_Y1Data = 1:10;
        Case2_Y2Data = 1:11;
        Case2_args = {XData Case1_Y1Data Case2_Y2Data};

        testErrorData = struct( ...
            'XNotEqualToY1', struct('Args', {Case1_args}, 'id', 'invalid1:InputsAreInvalid', 'errorMsg', 'Length of x is not equal to length of y1'), ...
            'XNotEqualToY2', struct('Args', {Case2_args}, 'id', 'invalid2:InputsAreInvalid', 'errorMsg', 'Length of x is not equal to length of y2'));
end

function testFigureOrderData = createTestFigureOrderData
    XData = linspace(0, 4 * pi, 100);
    Y1Data = sin(XData);
    Y2Data = cos(XData);

    args = {XData Y1Data Y2Data};
    testFigureOrderData = struct( ...
        'TestFigureOrder', struct('Args', {args}));

end

function testEmptyData = createTestEmptyData
    Empty_XData = [];
    Empty_Y1Data = [];
    Empty_Y2Data = [];

    emptyargs = {Empty_XData Empty_Y1Data Empty_Y2Data};
    testEmptyData = struct( ...
        'SetXY1Y2Empty', struct('Args', {emptyargs}, 'XData', {Empty_XData}, ...
        'Y1Data', {Empty_Y1Data}, 'Y2Data', {Empty_Y2Data}, 'FaceColor', 'g') ...
    );
end
