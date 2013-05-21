classdef ReachDiscrete < elltool.reach.AReach
    % Discrete reach set library of the Ellipsoidal Toolbox.
    %
    % $Authors: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
    %           Kirill Mayantsev  <kirill.mayantsev@gmail.com> $
    %               $Date: March-2013 $
    %           Igor Kitsenko <kitsenko@gmail.com> $
    %               $Date: May-2013 $
    % $Copyright: Moscow State University,
    %             Faculty of Computational Mathematics
    %             and Computer Science,
    %             System Analysis Department 2013 $
    %
    properties (Constant, GetAccess = ?elltool.reach.AReach)
        DISPLAY_PARAMETER_STRINGS = {'discrete-time', 'k0 = ', 'k1 = '}
        LINSYS_CLASS_STRING = 'elltool.linsys.LinSysDiscrete'
    end
    %
    properties (Access = private)
        isMinMax
    end
    %
    methods (Static, Access = protected)
        function [atStrCMat btStrCMat gtStrCMat...
                ptStrCMat ptStrCVec...
                qtStrCMat qtStrCVec] = prepareSysParam(linSys, ~)
            [atStrCMat btStrCMat gtStrCMat...
                ptStrCMat ptStrCVec...
                qtStrCMat qtStrCVec] = ...
                prepareSysParam@elltool.reach.AReach(linSys);
            %
            atStrCMat = unifySym(atStrCMat);
            btStrCMat = unifySym(btStrCMat);
            gtStrCMat = unifySym(gtStrCMat);
            ptStrCMat = unifySym(ptStrCMat);
            ptStrCVec = unifySym(ptStrCVec);
            qtStrCMat = unifySym(qtStrCMat);
            qtStrCVec = unifySym(qtStrCVec);
            %
            function outStrCMat = unifySym(inStrCMat)
               fChangeSymToT = @(str) strrep(str, 'k', 't');
               outStrCMat = cellfun(fChangeSymToT, inStrCMat, ...
                   'UniformOutput', false);
            end
        end
        %
        function linSys = getProbDynamics(atStrCMat, btStrCMat,...
                ptStrCMat, ptStrCVec, gtStrCMat, qtStrCMat, qtStrCVec,...
                x0Mat, x0Vec, timeVec, ~, isDisturb)
            isBack = timeVec(1) > timeVec(2);
            if isDisturb
                linSys = getSysWithDisturb(atStrCMat, btStrCMat,...
                    ptStrCMat, ptStrCVec, gtStrCMat, qtStrCMat,...
                    qtStrCVec, x0Mat, x0Vec, timeVec);
            else
                linSys = getSysWithoutDisturb(atStrCMat, btStrCMat,...
                    ptStrCMat, ptStrCVec, x0Mat, x0Vec,...
                    timeVec);
            end
            %
            function linSys = getSysWithDisturb(atStrCMat, btStrCMat,...
                    ptStrCMat, ptStrCVec, gtStrCMat, qtStrCMat, qtStrCVec,...
                    x0Mat, x0Vec, timeVec)
                import gras.ellapx.lreachuncert.probdef.LReachContProblemDef;
                import gras.ellapx.lreachuncert.probdyn.*;
                pDefObj = LReachContProblemDef(atStrCMat, btStrCMat,...
                    ptStrCMat, ptStrCVec, gtStrCMat, qtStrCMat, ...
                    qtStrCVec, x0Mat, x0Vec, timeVec);
                if isBack
                    linSys = LReachDiscrBackwardDynamics(pDefObj);
                else
                    linSys = LReachDiscrForwardDynamics(pDefObj);
                end
            end
            %
            function linSys = getSysWithoutDisturb(atStrCMat, btStrCMat,...
                    ptStrCMat, ptStrCVec, x0Mat, x0Vec, timeVec)
                import gras.ellapx.lreachplain.probdef.LReachContProblemDef;
                import gras.ellapx.lreachplain.probdyn.*;
                pDefObj = LReachContProblemDef(atStrCMat, btStrCMat,...
                    ptStrCMat, ptStrCVec, x0Mat, x0Vec, timeVec);
                if isBack
                    linSys = LReachDiscrBackwardDynamics(pDefObj);
                else
                    linSys = LReachDiscrForwardDynamics(pDefObj);
                end
            end
        end
        %
        function newEllTubeRel = transformEllTube(ellTubeRel)
            newEllTubeRel = ellTubeRel;
        end
    end
    %
    methods (Static, Access = private)
        function [qArrayList ltGoodDirArray] = ...
                calculateApproxShape(probDynObj, l0Mat, ...
                relTol, approxType, isDisturb, isMinMax)
            import elltool.conf.Properties;
            import gras.ellapx.enums.EApproxType;
            %
            isBack = isa(probDynObj, ...
                'gras.ellapx.lreachplain.probdyn.LReachDiscrBackwardDynamics');
            %
            xDim = probDynObj.getDimensionality();
            timeVec = probDynObj.getTimeVec();
            nTubes = size(l0Mat, 2);
            qArrayList = repmat({repmat(zeros(xDim), ...
                [1, 1, length(timeVec)])}, 1, nTubes);
            ltGoodDirArray = zeros(xDim, nTubes, length(timeVec));
            lMat = zeros(xDim, length(timeVec));
            %
            if approxType == EApproxType.Internal
                fMinkmp = @(aEll, bEll, cEll, lVec) ...
                    minkmp_ia(aEll, bEll, cEll, lVec);
                fMinksum = @(aEllArray, lVec) minksum_ia(aEllArray, lVec);
                fMinkdiff = @(aEll, bEll, lVec) ...
                    minkdiff_ia(aEll, bEll, lVec);
            else
                fMinkmp = @(aEll, bEll, cEll, lVec) ...
                    minkmp_ea(aEll, bEll, cEll, lVec);
                fMinksum = @(aEllArray, lVec) minksum_ea(aEllArray, lVec);
                fMinkdiff = @(aEll, bEll, lVec) ...
                    minkdiff_ea(aEll, bEll, lVec);
            end
            %
            for iTube = 1:nTubes
                qMat = probDynObj.getX0Mat;
                qMat = ell_regularize(qMat, relTol);
                qMat = 0.5 * (qMat + qMat');
                qArrayList{iTube}(:, :, 1) = qMat;
                lVec = l0Mat(:, iTube);
                lMat(:, 1) = lVec;
                for iTime = 1:(length(timeVec) - 1)
                    aMat = probDynObj.getAtDynamics(). ...
                        evaluate(timeVec(iTime + isBack));
                    aInvMat = probDynObj.getAtInvDynamics(). ...
                        evaluate(timeVec(iTime + isBack));
                    bpbMat = probDynObj.getBPBTransDynamics(). ...
                        evaluate(timeVec(iTime + isBack));
                    bpbMat = 0.5 * (bpbMat + bpbMat');
                    if isDisturb
                        gqgMat = probDynObj.getCQCTransDynamics(). ...
                            evaluate(timeVec(iTime + isBack));
                        gqgMat = 0.5 * (gqgMat + gqgMat');
                        gqgMat = ell_regularize(gqgMat, relTol);
                    end
                    qMat = aMat * qMat * aMat';
                    qMat = ell_regularize(qMat, relTol / 1000);
                    bpbMat = ell_regularize(bpbMat, relTol);
                    lVec = aInvMat' * lVec;
                    if isDisturb
                        if isMinMax
                            eEll = fMinkmp(ellipsoid(0.5 * (qMat + qMat')),...
                                ellipsoid(0.5 * (gqgMat + gqgMat')),...
                                ellipsoid(0.5 * (bpbMat + bpbMat')), lVec);
                        else
                            eEll = fMinksum([ellipsoid(0.5 * (qMat + qMat'))...
                                ellipsoid(0.5 * (bpbMat + bpbMat'))], lVec);
                            eEll = fMinkdiff(eEll, ...
                                ellipsoid(0.5 * (gqgMat + gqgMat')), lVec);
                        end
                    else
                        eEll = fMinksum([ellipsoid(0.5 * (qMat + qMat')) ...
                            ellipsoid(0.5 * (bpbMat + bpbMat'))], lVec);
                    end
                    %
                    if ~isempty(eEll)
                        qMat = double(eEll);
                    else
                        qMat = zeros(xDim, xDim);
                    end
                    qMat = ell_regularize(qMat, relTol);
                    qMat = 0.5 * (qMat + qMat');
                    qArrayList{iTube}(:, :, iTime + 1) = qMat;
                    lMat(:, iTime + 1) = lVec;
                end
                ltGoodDirArray(:, iTube, :) = lMat;
            end
        end
    end
    %
    methods (Access = protected)
        function ellTubeRel = makeEllTubeRel(self, probDynObj, l0Mat,...
                timeLimsVec, isDisturb, calcPrecision, approxTypeVec)
            import gras.ellapx.enums.EApproxType;
            import gras.ellapx.lreachplain.GoodDirsDiscrete;
            goodDirSetObj = GoodDirsDiscrete(...
                probDynObj, timeLimsVec(1), l0Mat, calcPrecision);
            %
            approxSchemaDescr = char.empty(1,0);
            approxSchemaName = char.empty(1,0);
            sTime = timeLimsVec(1);
            timeVec = probDynObj.getTimeVec();
            %
            aMat = probDynObj.getxtDynamics().evaluate(timeVec);
            ltGoodDirArray = ...
                goodDirSetObj.getGoodDirCurveSpline().evaluate(timeVec);
            %
            isIntApprox = any(approxTypeVec == EApproxType.Internal);
            isExtApprox = any(approxTypeVec == EApproxType.External);
            %
            fCalcApproxShape = @(approxType) ...
                elltool.reach.ReachDiscrete.calculateApproxShape(...
                probDynObj, l0Mat, self.relTol, approxType, ...
                isDisturb, ...
                self.isMinMax);
            %
            if isExtApprox
                approxType = EApproxType.External;
                [qArrayList ltGoodDirArray] = fCalcApproxShape(approxType);
                extEllTubeRel = create();
                if ~isIntApprox
                    ellTubeRel = extEllTubeRel;
                end
            end
            if isIntApprox
                approxType = EApproxType.Internal;
                [qArrayList ltGoodDirArray] = fCalcApproxShape(approxType);
                intEllTubeRel = create();
                if isExtApprox
                    intEllTubeRel.unionWith(extEllTubeRel);
                end
                ellTubeRel = intEllTubeRel;
            end
            %
            function rel = create()
                rel = gras.ellapx.smartdb.rels.EllTube.fromQArrays(...
                    qArrayList, aMat, timeVec, ltGoodDirArray, ...
                    sTime, approxType, approxSchemaName, ...
                    approxSchemaDescr, self.relTol / 10);
            end
        end
    end
    %
    methods        
        function self = ReachDiscrete(linSys, x0Ell, l0Mat,...
                timeVec, varargin)
            %
            % ReachDiscrete - computes reach set approximation of the discrete linear
            %                 system for the given time interval.
            %
            %
            % Input:
            %     linSys: elltool.linsys.LinSys object - given linear system
            %     x0Ell: ellipsoid[1, 1] - ellipsoidal set of initial conditions
            %     l0Mat: double[nRows, nColumns] - initial good directions
            %           matrix.
            %     timeVec: double[1, 2] - time interval
            %     properties:
            %       isRegEnabled: logical[1, 1] - if it is 'true' constructor
            %           is allowed to use regularization.
            %       isJustCheck: logical[1, 1] - if it is 'true' constructor
            %           just check if square matrices are degenerate, if it is
            %           'false' all degenerate matrices will be regularized.
            %       regTol: double[1, 1] - regularization precision.
            %       minmax: logical[1, 1] - field, which:
            %           = 1 compute minmax reach set,
            %           = 0 (default) compute maxmin reach set.
            %
            % Output:
            %   regular:
            %     self - reach set object.
            % Example:
            %   adMat = [0 1; -1 -0.5];
            %   bdMat = [0; 1];
            %   udBoundsEllObj  = ellipsoid(1);
            %   dtsys = elltool.linsys.LinSysDiscrete(adMat, bdMat, udBoundsEllObj);
            %   x0EllObj = ell_unitball(2);
            %   timeVec = [0 10];
            %   dirsMat = [1 0; 0 1]';
            %   dRsObj = elltool.reach.ReachDiscrete(dtsys, x0EllObj, dirsMat, timeVec);
            %
            %
            % $Authors: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
            %           Kirill Mayantsev <kirill.mayantsev@gmail.com> $
            % $Date: Jan-2013 $
            %           Igor Kitsenko <kitsenko@gmail.com> $
            % $Date: May-2013 $
            % $Copyright: Moscow State University,
            %             Faculty of Computational
            %             Mathematics and Computer Science,
            %             System Analysis Department 2013 $
            %
            import elltool.conf.Properties;
            import gras.ellapx.enums.EApproxType;
            %
            if (nargin == 0) || isempty(linSys)
                return;
            end
            %            
            k0 = round(timeVec(1));
            k1 = round(timeVec(2));
            timeVec = [k0 k1];
            %
            self.parse(linSys, x0Ell, l0Mat, timeVec, varargin);
            %
            [reg, ~, self.isMinMax] =...
                modgen.common.parseparext(varargin, {'isMinMax'; false});
            if ~isempty(reg)
                throwerror('wrongInput', 'wrong input arguments format.');
            end
            %
            % create gras LinSys object
            %
            [x0Vec x0Mat] = double(x0Ell);
            [atStrCMat btStrCMat gtStrCMat ptStrCMat ptStrCVec...
                qtStrCMat qtStrCVec] = self.prepareSysParam(linSys);
            isDisturbance = self.isDisturbance(gtStrCMat, qtStrCMat);
            %
            % normalize good directions
            %
            sysDim = size(atStrCMat, 1);
            l0Mat = self.getNormMat(l0Mat, sysDim);
            %
            % create approximation tube
            %
            probDynObj = self.getProbDynamics(atStrCMat, btStrCMat, ...
                ptStrCMat, ptStrCVec, gtStrCMat, qtStrCMat, qtStrCVec, ...
                x0Mat, x0Vec, timeVec, self.relTol, isDisturbance);
            approxTypeVec = [EApproxType.External EApproxType.Internal];
            self.ellTubeRel = self.makeEllTubeRel(probDynObj, l0Mat, ...
                timeVec, isDisturbance, self.relTol, approxTypeVec);
        end
    end
end