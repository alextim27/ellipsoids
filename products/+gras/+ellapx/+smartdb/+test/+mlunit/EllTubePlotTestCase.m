classdef EllTubePlotTestCase < mlunitext.test_case
    
    methods
        function self = EllTubePlotTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function tear_down(~)
            close all;
        end
        function testPlotIntAndExtProperties(self)
            
            rel = self.createTubeWithProj(2,1);
            
            
            
            plObj = rel.plotInt('color',[0 1 0]);
            self.checkParams(plObj, 1, false, 0.4, [0 1 0],1);
            
            
            plObj = rel.plotExt('b');
            self.checkParams(plObj, 1, false, 0.4, [0 0 1],1);
            
            
            rel = self.createTubeWithProj(2,2);
            
            plObj = rel.plotInt('linewidth', 4, ...
                'fill', true, 'shade', 0.8);
            self.checkParams(plObj, 4, true, 0.8, [.5 .5 .5],2);
            plObj = rel.plotExt('linewidth', 3, ...
                'fill', 0);
            self.checkParams(plObj, 3, false, 0, [.5 .5 .5],2);
            rel = self.createTubeWithProj(3,3);
            
            plObj = rel.plotInt('fill', true, 'shade', 0.1, ...
                'color', [0, 1, 1]);
            self.checkParams(plObj, [], true, 0.1, [0 1 1],3);
            plObj = rel.plotExt('shade', 0.3, ...
                'g');
            self.checkParams(plObj, [],true, 0.3, [0 1 0],3);
            
            
            
            
        end
        function testPlotInt(self)
            import gras.ellapx.enums.EApproxType;
            approxType = gras.ellapx.enums.EApproxType.Internal;
            fRight = @(a,b,c) a+b>=c;
            fPlot = @(x) x.plotInt;
            testPlot(self,approxType,fPlot,fRight);
            
            
        end
        function testPlotExt(self)
            import gras.ellapx.enums.EApproxType;
            fRight = @(a,b,c) a-b<=c;
            approxType = gras.ellapx.enums.EApproxType.External;
            fPlot = @(x) x.plotExt;
            testPlot(self,approxType,fPlot,fRight);
            
        end
        function testPlot(self,approxType,fPlot,fRight)
            rel = self.createTubeWithProj(2,1);
            plObj = fPlot(rel);
            
            rel2 = rel.getTuplesFilteredBy(...
                'approxType', approxType);
            self.checkPoints(rel2,plObj,1,fRight);
            
            rel = self.createTubeWithProj(2,2);
            plObj = fPlot(rel);
            rel2 = rel.getTuplesFilteredBy(...
                'approxType', approxType);
            self.checkPoints(rel2,plObj,2,fRight);
            
            rel = self.createTubeWithProj(3,3);
            plObj = fPlot(rel);
            rel2 = rel.getTuplesFilteredBy(...
                'approxType', approxType);
            self.checkPoints(rel2,plObj,3,fRight);
        end
    end
    methods (Static)
        function relStatProj  = createTubeWithProj(dim,ind)
            projSpaceList = {eye(dim)};
            projType = gras.ellapx.enums.EProjType.Static;
            rel = gras.ellapx.smartdb...
                .test.mlunit.EllTubePlotTestCase.createTube(ind);
            relStatProj = ...
                rel.project(projType,projSpaceList,@fGetProjMat);
        end
        function rel = createTube(ind)
            fTransMat2d = @(t)[cos(5*(t-2)) sin(5*(t-2));...
                -sin(5*(t-2)) cos(5*(t-2))];
            fTrans2Mat2d = @(t)[cos(7*(t-4)) sin(7*(t-4));...
                -sin(7*(t-4)) cos(7*(t-4))];
            fTrans2Mat3d = @(t)[cos(5*(t-2)) sin(5*(t-2)) 0;...
                -sin(5*(t-2)) cos(5*(t-2)) 0; 0 0 1];
            approxInt = gras.ellapx.enums.EApproxType.Internal;
            approxExt = gras.ellapx.enums.EApproxType.External;
            calcPrecision = 10^(-3);
            switch ind
                case 1
                    fQ1Int = @(t) fTransMat2d(t)'*diag([1 0.5])*...
                        fTransMat2d(t);
                    fQ2Int = @(t) fTrans2Mat2d(t)'*diag([1 0.5])...
                        *fTrans2Mat2d(t);
                    fQ1Ext = @(t) fTransMat2d(t)'*diag([1 4])*fTransMat2d(t);
                    fQ2Ext = @(t) fTrans2Mat2d(t)'*diag([1 4])...
                        *fTrans2Mat2d(t);
                    QArrList = {cat(3,fQ1Int(1),fQ1Int(2),fQ1Int(3),...
                        fQ1Int(4),fQ1Int(5));...
                        cat(3,fQ2Int(1),fQ2Int(2),fQ2Int(3),fQ2Int(4),...
                        fQ2Int(5));...
                        cat(3,fQ1Ext(1),fQ1Ext(2),fQ1Ext(3),...
                        fQ1Ext(4),fQ1Ext(5));...
                        cat(3,fQ2Ext(1),fQ2Ext(2),fQ2Ext(3),fQ2Ext(4),...
                        fQ2Ext(5))};
                    aMat = repmat([1 0]',[1,5]);
                    timeVec = 1:5;
                    ltGDir = {cat(3,fTransMat2d(1)'*[1;0],...
                        fTransMat2d(2)'*[1;0],...
                        fTransMat2d(3)'*[1;0], fTransMat2d(4)'*[1;0], ...
                        fTransMat2d(5)'*[1;0]);...
                        cat(3,fTrans2Mat2d(1)'*[1;0],...
                        fTrans2Mat2d(2)'*[1;0],...
                        fTrans2Mat2d(3)'*[1;0], fTrans2Mat2d(4)'*[1;0] ,...
                        fTrans2Mat2d(5)'*[1;0])};
                    sTime =[2; 4];
                case 2
                    QArrList = {diag([1 0.5 ]);...
                        fTransMat2d(1)'*diag([1 0.5])*fTransMat2d(1);...
                        diag([1 4 ]);...
                        fTransMat2d(1)'*diag([1 4])*fTransMat2d(1)};
                    aMat = [1;0];
                    timeVec = 1;
                    ltGDir = {[1;0];fTransMat2d(1)'*[1;0]};
                    sTime = [1 1];
                case 3
                    QArrList = {diag([1 0.2 0.5 ]);...
                        fTrans2Mat3d(1)'*diag([1 0.2 0.5])...
                        *fTrans2Mat3d(1);...
                        diag([1 2 4 ]);...
                        fTrans2Mat3d(1)'*diag([1 2 4])...
                        *fTrans2Mat3d(1)};
                    aMat = [1;0;0];
                    timeVec = 1;
                    ltGDir = {[1;0;0];fTrans2Mat3d(1)'*[1;0;0]};
                    sTime = [1 1];
            end
            rel = gras.ellapx.smartdb.rels...
                .EllTube.fromQArrays(QArrList(1),aMat...
                ,timeVec,ltGDir{1},sTime(1),approxInt,...
                char.empty(1,0),char.empty(1,0),...
                calcPrecision);
            rel.unionWith(...
                gras.ellapx.smartdb.rels...
                .EllTube.fromQArrays(QArrList(2),aMat...
                ,timeVec,ltGDir{2},sTime(2),approxInt,...
                char.empty(1,0),char.empty(1,0),...
                calcPrecision));
            rel.unionWith(...
                gras.ellapx.smartdb.rels...
                .EllTube.fromQArrays(QArrList(3),aMat...
                ,timeVec,ltGDir{1},sTime(1),approxExt,...
                char.empty(1,0),char.empty(1,0),...
                calcPrecision));
            rel.unionWith(...
                gras.ellapx.smartdb.rels...
                .EllTube.fromQArrays(QArrList(4),aMat...
                ,timeVec,ltGDir{2},sTime(2),approxExt,...
                char.empty(1,0),char.empty(1,0),...
                calcPrecision));
        end
        function checkParams(plObj, linewidth, fill, shade, colorVec,...
                curCase)
            SHPlot =  plObj.getPlotStructure().figToAxesToHMap.toStruct();
            plEllObjVec = get(SHPlot.figure_g1.ax, 'Children');
            plEllObjVec = plEllObjVec(~strcmp(get(plEllObjVec,...
                'Type'),'light'));
            plEllObjVec = plEllObjVec(~strcmp(get(plEllObjVec,...
                'Marker'), '*'));
            isEq = true;
            switch curCase
                case 1
                    colorPlMat = get(plEllObjVec, 'FaceVertexCData');
                    if numel(colorPlMat) > 0
                        colorPlVec = colorPlMat(1, :);
                        if numel(colorVec) > 0
                            isEq = isEq & all(colorVec == colorPlVec);
                        end
                    end
                    isFill = false;
                case 2
                    linewidthPl = get(plEllObjVec, 'linewidth');
                    colorPlVec = get(plEllObjVec, 'EdgeColor');
                    if numel(linewidth) > 0
                        isEq = isEq & eq(linewidth, linewidthPl);
                    end
                    if numel(colorVec) > 0
                        isEq = isEq & min(eq(colorVec, colorPlVec));
                    end
                    shadePl = get(plEllObjVec, 'FaceAlpha');
                    if numel(shade) > 0
                        isEq = isEq & eq(shade, shadePl);
                    end
                    if get(plEllObjVec, 'FaceAlpha') > 0
                        isFill = true;
                    else
                        isFill = false;
                    end
                case 3
                    shadePl = get(plEllObjVec, 'FaceAlpha');
                    if numel(shade) > 0
                        isEq = isEq & eq(shade, shadePl);
                    end
                    colorPlMat = get(plEllObjVec, 'FaceVertexCData');
                    if numel(colorPlMat) > 0
                        colorPlVec = colorPlMat(1, :);
                        if numel(colorVec) > 0
                            isEq = isEq & all(colorVec == colorPlVec);
                        end
                    end
                    if get(plEllObjVec, 'FaceAlpha') > 0
                        isFill = true;
                    else
                        isFill = false;
                    end
            end
            mlunitext.assert_equals(isEq, true);
            mlunitext.assert_equals(isFill, fill);
        end
        
        function checkPoints(rel,plObj,curCase,fRight)
            ABS_TOL = 10^(-5);
            SHPlot =  plObj.getPlotStructure().figToAxesToHMap.toStruct();
            xTitl = get(get(SHPlot.figure_g1.ax,'xLabel'),'String');
            yTitl =  get(get(SHPlot.figure_g1.ax,'yLabel'),'String');
            zTitl =  get(get(SHPlot.figure_g1.ax,'zLabel'),'String');
            plEllObjVec = get(SHPlot.figure_g1.ax, 'Children');
            plEllObjVec = plEllObjVec(~strcmp(get(plEllObjVec,...
                'Type'),'light'));
            plEllObjVec = plEllObjVec(~strcmp(get(plEllObjVec,...
                'Marker'), '*'));
            isEq = true;
            [xDataVec,yDataVec,zDataVec] = getData(plEllObjVec);
            timeVec = rel.timeVec{1};
            qArrList = rel.QArray;
            aMat = rel.aMat;
            curInd = 1;
            switch curCase
                case 1
                    
                    isEq = strcmp(xTitl,'t')&&strcmp(yTitl,...
                        '[lsGoodDirVec=1,sTime=1]')...
                        &&strcmp(zTitl,'[lsGoodDirVec=2,sTime=1]');
                    
                    [xDataVec,xInd] = sort(xDataVec);
                    prev = 1;
                    yDataVec = yDataVec(xInd);
                    zDataVec = zDataVec(xInd);
                    for iTime = 1:size(timeVec,2)
                        numberPoints = numel(find(xDataVec == xDataVec(prev)));
                        for iDir = 1:numberPoints
                            for iTube = 1:numel(qArrList)
                                yP = yDataVec(curInd);
                                zP = zDataVec(curInd);
                                qMat = qArrList{iTube}(:,:,iTime);
                                cVec = aMat{iTube}(:,iTime);
                                yP = yP-cVec(1);
                                zP = zP-cVec(2);
                                if ~fRight([yP zP]/qMat*[yP zP]'-1,...
                                        ABS_TOL,0)
                                    isEq = false;
                                end
                            end
                            curInd = curInd+1;
                        end
                        prev = prev + numberPoints;
                    end
                case 2
                    isEq = strcmp(xTitl,...
                        '[lsGoodDirVec=1,sTime=1]')...
                        &&strcmp(yTitl,'[lsGoodDirVec=2,sTime=1]');
                    for iDir = 1:size(xDataVec,2)
                        for iTube = 1:numel(qArrList)
                            xP = xDataVec(curInd);
                            yP = yDataVec(curInd);
                            qMat = qArrList{iTube}(:,:,1);
                            cVec = aMat{iTube}(:,1);
                            xP = xP-cVec(1);
                            yP = yP-cVec(2);
                            if ~fRight([xP yP]/qMat*[xP yP]'-1,ABS_TOL,0)
                                isEq = false;
                            end
                        end
                        curInd = curInd+1;
                    end
                    
                case 3
                    isEq =strcmp(xTitl,...
                        '[lsGoodDirVec=1,sTime=1]')...
                        &&strcmp(yTitl,'[lsGoodDirVec=2,sTime=1]')...
                        &&strcmp(zTitl,'[lsGoodDirVec=3,sTime=1]');
                    for iDir = 1:size(xDataVec,2)
                        for iTube = 1:numel(qArrList)
                            xP = xDataVec(curInd);
                            yP = yDataVec(curInd);
                            zP = zDataVec(curInd);
                            qMat = qArrList{iTube}(:,:,1);
                            cVec = aMat{iTube}(:,1);
                            xP = xP-cVec(1);
                            yP = yP-cVec(2);
                            zP = zP-cVec(3);
                            
                            if ~fRight([xP yP zP]/qMat*[xP yP zP]'-1,...
                                    ABS_TOL,0)
                                isEq = false;
                            end
                        end
                        curInd = curInd+1;
                    end
            end
            mlunitext.assert_equals(isEq, true);
        end
        
        
        
    end
    
end

function [projOrthMatArray, projOrthMatTransArray] =...
    fGetProjMat(projMat, timeVec, varargin)
nTimePoints = length(timeVec);
projOrthMatArray = repmat(projMat, [1, 1, nTimePoints]);
projOrthMatTransArray = repmat(projMat.',...
    [1,1,nTimePoints]);
end



function [outXDataVec, outYDataVec, outZDataVec] = getData(hObj)
outXDataMat = get(hObj, 'XData');
outYDataMat = get(hObj, 'YData');
outZDataMat = get(hObj, 'ZData');
outXDataVec = outXDataMat(:)';
outYDataVec = outYDataMat(:)';
outZDataVec = outZDataMat(:)';

end