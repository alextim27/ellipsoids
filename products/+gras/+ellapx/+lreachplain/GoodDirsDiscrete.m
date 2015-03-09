classdef GoodDirsDiscrete < gras.ellapx.lreachplain.AGoodDirs
    properties (Access=private)
        absTol
    end
    methods
        function self = GoodDirsDiscrete(pDynObj, sTime, ...
                lsGoodDirMat, relTol, absTol)
            self = self@gras.ellapx.lreachplain.AGoodDirs(...
                pDynObj, sTime, lsGoodDirMat, relTol, absTol);
        end
    end
    methods (Access = protected)
        function [XstDynamics, RstDynamics, XstNormDynamics, ...
                RstInterpObj] = calcTransMatDynamics(self, matOpFactory, ...
                STimeData, AtDynamics, relTol, absTol)
            %
            import gras.mat.interp.MatrixInterpolantFactory;
            import gras.ellapx.uncertcalc.log.Log4jConfigurator;
            import gras.mat.CompositeMatrixOperations;
            import gras.gen.matdot;
            %
            logger=Log4jConfigurator.getLogger();
            %
            compOpFactory = CompositeMatrixOperations();
            %
            self.absTol = absTol;
            %
            t0 = STimeData.t0;
            t1 = STimeData.t1;
            %
            isBack = t0 > t1;
            if isBack
                timeVec = fliplr(t1:t0);
            else
                timeVec = t0:t1;
            end
            nTimePoints = length(timeVec);
            %
            %%Check, if AtDynamics is not degenerate
            %
            fAtMat = @(t) AtDynamics.evaluate(t);
            for iTime = 1 : nTimePoints
                if ~gras.la.ismatnotdeg(fAtMat(timeVec(iTime)), ...
                        self.absTol)
                    modgen.common.throwerror('wrongInput',...
                        cat(2, 'At matrix seems to be degenerate,', ...
                        ' det(At) should be != 0 for all t in [t0, t1]'));
                end
            end
            %
            aInvMatFcn = compOpFactory.inv(AtDynamics);
            fAtInvMat = @(t) aInvMatFcn.evaluate(t);
            sizeSysVec = size(fAtInvMat(0));
            %
            dataXtt0Arr = zeros([sizeSysVec nTimePoints]);
            dataRtt0Arr = zeros([sizeSysVec nTimePoints]);
            dataXtt0NormVec = zeros([1, nTimePoints]);
            %
            dataXtt0Arr(:, :, 1) = eye(sizeSysVec);
            dataXtt0NormVec(1) = realsqrt(matdot(...
                    dataXtt0Arr(:, :, 1), dataXtt0Arr(:, :, 1)));
            dataRtt0Arr(:, :, 1) = dataXtt0Arr(:, :, 1) ./ ...
                    dataXtt0NormVec(1);
            %
            for iTime = 2:nTimePoints
                dataXtt0Arr(:, :, iTime) = ...
                    dataXtt0Arr(:, :, iTime - 1) * ...
                    fAtInvMat(timeVec(iTime - 1 + isBack));
                dataXtt0NormVec(iTime) = realsqrt(matdot(...
                    dataXtt0Arr(:, :, iTime), dataXtt0Arr(:, :, iTime)));
                dataRtt0Arr(:, :, iTime) = dataXtt0Arr(:, :, iTime) ./ ...
                    dataXtt0NormVec(iTime);
            end
            %
            if isBack
                dataXtt0Arr=flipdim(dataXtt0Arr,3);
                dataRtt0Arr=flipdim(dataRtt0Arr,3);
                dataXtt0NormVec=fliplr(dataXtt0NormVec);
            end
            XstDynamics = MatrixInterpolantFactory.createInstance(...
                'column', dataXtt0Arr, timeVec);
            RstDynamics = MatrixInterpolantFactory.createInstance(...
                'column', dataRtt0Arr, timeVec);
            XstNormDynamics = MatrixInterpolantFactory.createInstance(...
                'scalar', dataXtt0NormVec, timeVec);
            RstInterpObj = XstDynamics;
            %
            tStart = tic;
            %
            logger.debug(...
                sprintf(['calculating transition matrix spline ' ...
                'at time %d, nodes = %d, time elapsed = %s sec.'], ...
                self.sTime, length(timeVec), ...
                num2str(toc(tStart))));
        end
    end
end