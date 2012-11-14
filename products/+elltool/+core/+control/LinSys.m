classdef LinSys<handle
    %
    properties (Access = private)
        AtMat
        BtMat
        controlBoundsEll
        GtMat
        disturbanceBoundsEll
        CtMat
        noiseBoundsEll
        isTimeInv
        isDiscr
        isConstantBoundsVec
    end
    methods
        %%
        function self = LinSys(AtInpMat, BtInpMat, UBoundsEll, GtInpMat,...
                distBoundsEll, CtInpMat, noiseBoundsEll, discrFlag)
            global ellOptions;
            %
            if ~isstruct(ellOptions)
                evalin('base', 'ellipsoids_init;');
            end
            %%
            if nargin == 0
                self.AtMat = [];
                self.BtMat = [];
                self.controlBoundsEll = [];
                self.GtMat = [];
                self.disturbanceBoundsEll = [];
                self.CtMat = [];
                self.noiseBoundsEll = [];
                self.isTimeInv = false;
                self.isDiscr = false;
                self.isConstantBoundsVec = false(1, 3);
                return;
            end
            %%
            isTimeInvar = true;
            [mRow, nCol] = size(AtInpMat);
            if mRow ~= nCol
                error('linsys:dimension:A',...
                    'LINSYS: A must be square matrix.');
            end
            if iscell(AtInpMat)
                isTimeInvar = false;
            elseif ~(isa(AtInpMat, 'double'))
                error('linsys:type:A',...
                    'LINSYS: matrix A must be of type ''cell'' or ''double''.');
            end
            self.AtMat = AtInpMat;
            %%
            [kRow, lCol] = size(BtInpMat);
            if kRow ~= nCol
                error('linsys:dimension:B',...
                    'LINSYS: dimensions of A and B do not match.');
            end
            if iscell(BtInpMat)
                isTimeInvar = false;
            elseif ~(isa(BtInpMat, 'double'))
                error('linsys:type:B',...
                    'LINSYS: matrix B must be of type ''cell'' or ''double''.');
            end 
            self.BtMat = BtInpMat;
            %%
            isCBU = true;
            if nargin > 2
                if isempty(UBoundsEll)
                    % leave as is
                elseif isa(UBoundsEll, 'ellipsoid')
                    UBoundsEll = UBoundsEll(1, 1);
                    [dRow, rCol] = dimension(UBoundsEll);
                    if dRow ~= lCol
                        error('linsys:dimension:U',...
                            'LINSYS: dimensions of control bounds U and matrix B do not match.');
                    end
                    if (dRow > rCol) && (ellOptions.verbose > 0)
                        fprintf('LINSYS: Warning! Control bounds U represented by degenerate ellipsoid.\n');
                    end
                elseif isa(UBoundsEll, 'double') || iscell(UBoundsEll)
                    [kRow, mRow] = size(UBoundsEll);
                    if mRow > 1
                        error('linsys:type:U',...
                            'LINSYS: control U must be an ellipsoid or a vector.')
                    elseif kRow ~= lCol
                        error('linsys:dimension:U',...
                            'LINSYS: dimensions of control vector U and matrix B do not match.');
                    end
                    if iscell(UBoundsEll)
                        isCBU = false;
                    end
                elseif isstruct(UBoundsEll) &&...
                        isfield(UBoundsEll, 'center') &&...
                        isfield(UBoundsEll, 'shape')
                    isCBU = false;
                    UBoundsEll = UBoundsEll(1, 1);
                    self.isEllHaveNeededDim(UBoundsEll, lCol);      
                else
                    error('linsys:type:U',...
                        'LINSYS: control U must be an ellipsoid or a vector.')
                end
            else
                UBoundsEll = [];
            end
            self.controlBoundsEll = UBoundsEll;
            %%
            if nargin > 3
                if isempty(GtInpMat)
                    % leave as is
                else
                    [kRow, lCol] = size(GtInpMat);
                    if kRow ~= nCol
                        error('linsys:dimension:G',...
                            'LINSYS: dimensions of A and G do not match.');
                    end
                    if iscell(GtInpMat)
                        isTimeInvar = false;
                    elseif ~(isa(GtInpMat, 'double'))
                        error('linsys:type:G',...
                            'LINSYS: matrix G must be of type ''cell'' or ''double''.');
                    end 
                end 
            else
                GtInpMat = [];
            end
            %%
            isCBV = true;
            if nargin > 4
                if isempty(GtInpMat) || isempty(distBoundsEll)
                    GtInpMat = [];
                    distBoundsEll = [];
                elseif isa(distBoundsEll, 'ellipsoid')
                    distBoundsEll = distBoundsEll(1, 1);
                    [dRow, rCol] = dimension(distBoundsEll);
                    if dRow ~= lCol
                        error('linsys:dimension:V',...
                            'LINSYS: dimensions of disturbance bounds V and matrix G do not match.');
                    end
                elseif isa(distBoundsEll, 'double') || iscell(distBoundsEll)
                    [kRow, mRow] = size(distBoundsEll);
                    if mRow > 1
                        error('linsys:type:V',...
                            'LINSYS: disturbance V must be an ellipsoid or a vector.')
                    elseif kRow ~= lCol
                        error('linsys:dimension:V',...
                            'LINSYS: dimensions of disturbance vector V and matrix G do not match.');
                    end
                    if iscell(distBoundsEll)
                        isCBV = false;
                    end
                elseif isstruct(distBoundsEll) &&...
                        isfield(distBoundsEll, 'center') &&...
                        isfield(distBoundsEll, 'shape')
                    isCBV = false;
                    distBoundsEll = distBoundsEll(1, 1);
                    self.isEllHaveNeededDim(distBoundsEll, lCol);
                else
                    error('linsys:type:V',...
                        'LINSYS: disturbance V must be an ellipsoid or a vector.')
                end
            else
                distBoundsEll = [];
            end
            self.GtMat = GtInpMat;
            self.disturbanceBoundsEll = distBoundsEll;
            %%
            if nargin > 5
                if isempty(CtInpMat)
                    CtInpMat = eye(nCol);
                else
                    [kRow, lCol] = size(CtInpMat);
                    if lCol ~= nCol
                        error('linsys:dimension:C',...
                            'LINSYS: dimensions of A and C do not match.');
                    end
                    if iscell(CtInpMat)
                        isTimeInvar = false;
                    elseif ~(isa(CtInpMat, 'double'))
                        error('linsys:type:C',...
                            'LINSYS: matrix C must be of type ''cell'' or ''double''.');
                    end 
                end 
            else
                CtInpMat = eye(nCol);
            end
            self.CtMat = CtInpMat;
            %%
            isCBW = true;
            if nargin > 6
                if isempty(noiseBoundsEll)
                    % leave as is
                elseif isa(noiseBoundsEll, 'ellipsoid')
                    noiseBoundsEll = noiseBoundsEll(1, 1);
                    [dRow, rCol] = dimension(noiseBoundsEll);
                    if dRow ~= kRow
                        error('linsys:dimension:W',...
                            'LINSYS: dimensions of noise bounds W and matrix C do not match.');
                    end
                elseif isa(noiseBoundsEll, 'double') || iscell(noiseBoundsEll)
                    [lCol, mRow] = size(noiseBoundsEll);
                    if mRow > 1
                        error('linsys:type:W',...
                            'LINSYS: noise W must be an ellipsoid or a vector.')
                    elseif kRow ~= lCol
                        error('linsys:dimension:W',...
                            'LINSYS: dimensions of noise vector W and matrix C do not match.');
                    end
                    if iscell(noiseBoundsEll)
                        isCBW = false;
                    end
                elseif isstruct(noiseBoundsEll) &&...
                        isfield(noiseBoundsEll, 'center') &&...
                        isfield(noiseBoundsEll, 'shape')
                    isCBW = false;
                    noiseBoundsEll = noiseBoundsEll(1, 1);
                    self.isEllHaveNeededDim(noiseBoundsEll, kRow);
                else
                    error('linsys:type:W',...
                        'LINSYS: noise W must be an ellipsoid or a vector.')
                end
            else
                noiseBoundsEll = [];
            end
            self.noiseBoundsEll = noiseBoundsEll;
            %%
            self.isTimeInv = isTimeInvar;
            self.isDiscr  = false;
            if (nargin > 7)  && ischar(discrFlag) && (discrFlag == 'd')
                self.isDiscr = true;
            end
            self.isConstantBoundsVec = [isCBU isCBV isCBW];
        end
        %
        %
        %
        function isEllHaveNeededDim(InpEll, NDim)
        % isEllHaveNeededDim - checks if given structure E represents an ellipsoid
        %                      of dimension N.
            global ellOptions;
            %%
            qVec = InpEll.center;
            QMat = InpEll.shape;
            [kRow, lCol] = size(qVec);
            [mRow, nCol] = size(QMat);
            %%
            if mRow ~= nCol
                error(sprintf('linsys:value:%s:shape', inputname(1)),...
                    'shape matrix must be symmetric, positive definite');
            elseif nCol ~= NDim
                error(sprintf('linsys:dimension:%s:shape', inputname(1)),...
                    'shape matrix must be of dimension %dx%d', NDim, NDim);
            elseif lCol > 1 || kRow ~= NDim
                error(sprintf('linsys:dimension:%s:center', inputname(1)),...
                    'center must be a vector of dimension %d', NDim);  
            end 
            %%
            if ~iscell(qVec) && ~iscell(QMat)
                error( sprintf('linsys:type:%s',inputname(1)), ...
                    'for constant ellipsoids use ellipsoid object' );
            end
            %%
            if ~iscell(qVec) && ~isa(qVec, 'double')
                error(sprintf('linsys:type:%s:center', inputname(1)),...
                    'center must be of type ''cell'' or ''double''');        
            end
            %%
            if iscell(QMat)
                if ellOptions.verbose > 0
                    fprintf('LINSYS: Warning! Cannot check if symbolic matrix is positive definite.\n');
                end
                isEqMat = strcmp(QMat, QMat.');
                if ~all(isEqMat(:))
                    error(sprintf('linsys:value:%s:shape', inputname(1)),...
                        'shape matrix must be symmetric, positive definite');
                end
            else
                if isa(QMat, 'double')
                    isnEqMat = (QMat ~= QMat.');
                    if any(isnEqMat(:)) || min(eig(QMat)) <= 0
                        error(sprintf('linsys:value:%s:shape', inputname(1)),...
                            'shape matrix must be symmetric, positive definite');
                    end                    
                else
                    error(sprintf('linsys:type:%s:shape', inputname(1)),...
                        'shape matrix must be of type ''cell'' or ''double''');    
                end        
            end
        end
        %
        %
        %
        function [stateDim, inpDim, outDim, distDim] = dimension(self)
            global ellOptions;
            %%
            if ~isstruct(ellOptions)
                evalin('base', 'ellipsoids_init;');
            end
            %%
            stateDim = size(self.AtMat, 1);
            inpDim = size(self.BtMat, 2);
            outDim = size(self.CtMat, 1);
            distDim = size(self.GtMat, 2);
            %%
            if nargout < 4
                clear(distDim);
                if nargout < 3
                    clear(outDim);
                    if nargout < 2
                        clear(inpDim);
                    end
                end
            end
            return;
        end
        %
        %
        %
        function display(self)
            fprintf('\n');
            disp([inputname(1) ' =']);
            %%
            if isempty(self)
                fprintf('Empty linear system object.\n\n');
                return;
            end
            %%
            if isdiscrete(self)
                s0 = '[k]';
                s1 = 'x[k+1]  =  ';
                s2 = '  y[k]  =  ';
                s3 = ' x[k]';
            else
                s0 = '(t)';
                s1 = 'dx/dt  =  ';
                s2 = ' y(t)  =  ';
                s3 = ' x(t)';
            end
            %%
            fprintf('\n');
            if iscell(self.AtMat)
                if isdiscrete(self)
                    fprintf('A[k]:\n');
                    s4 = 'A[k]';
                else
                    fprintf('A(t):\n');
                    s4 = 'A(t)';
                end
            else
                fprintf('A:\n');
                s4 = 'A';
            end
            disp(self.AtMat);
            if iscell(self.BtMat)
                if isdiscrete(self)
                    fprintf('\nB[k]:\n');
                    s5 = '  +  B[k]';
                else
                    fprintf('\nB(t):\n');
                    s5 = '  +  B(t)';
                end
            else
                fprintf('\nB:\n');
                s5 = '  +  B';
            end
            disp(self.BtMat);
            %%
            fprintf('\nControl bounds:\n');
            s6 = [' u' s0];
            if isempty(self.controlBoundsEll)
                fprintf('     Unbounded\n');
            elseif isa(self.controlBoundsEll, 'ellipsoid')
                [qVec, QMat] = parameters(self.controlBoundsEll);
                fprintf('   %d-dimensional constant ellipsoid with center\n',...
                    size(self.BtMat, 2));
                disp(qVec);
                fprintf('   and shape matrix\n');
                disp(QMat);
            elseif isstruct(self.controlBoundsEll)
                UEll = self.controlBoundsEll;
                fprintf('   %d-dimensional ellipsoid with center\n',...
                    size(self.BtMat, 2));
                disp(UEll.center);
                fprintf('   and shape matrix\n');
                disp(UEll.shape);
            elseif isa(self.controlBoundsEll, 'double')
                fprintf('   constant vector\n');
                disp(self.controlBoundsEll);
                s6 = ' u';
            else
                fprintf('   vector\n');
                disp(self.controlBoundsEll);
            end
            %%
            if ~(isempty(self.GtMat)) && ~(isempty(self.disturbanceBoundsEll))
                if iscell(self.GtMat)
                    if isdiscrete(self)
                        fprintf('\nG[k]:\n');
                        s7 = '  +  G[k]';
                    else
                        fprintf('\nG(t):\n');
                        s7 = '  +  G(t)';
                    end
                else
                    fprintf('\nG:\n');
                    s7 = '  +  G';
                end
                disp(self.GtMat);
                fprintf('\nDisturbance bounds:\n');
                s8 = [' v' s0];
                if isa(self.disturbanceBoundsEll, 'ellipsoid')
                    [qVec, QMat] = parameters(self.disturbanceBoundsEll);
                    fprintf('   %d-dimensional constant ellipsoid with center\n',...
                        size(self.GtMat, 2));
                    disp(qVec);
                    fprintf('   and shape matrix\n');
                    disp(QMat);
                elseif isstruct(self.disturbanceBoundsEll)
                    UEll = self.disturbanceBoundsEll;
                    fprintf('   %d-dimensional ellipsoid with center\n',...
                        size(self.GtMat, 2));
                    disp(UEll.center);
                    fprintf('   and shape matrix\n');
                    disp(UEll.shape);
                elseif isa(self.disturbanceBoundsEll, 'double')
                    fprintf('   constant vector\n');
                    disp(self.disturbanceBoundsEll);
                    s8 = ' v';
                else
                    fprintf('   vector\n');
                    disp(self.disturbanceBoundsEll);
                end
            else
                s7 = '';
                s8 = '';
            end
            %%
            if iscell(self.CtMat)
                if isdiscrete(self)
                    fprintf('\nC[k]:\n');
                    s9 = 'C[k]';
                else
                    fprintf('\nC(t):\n');
                    s9 = 'C(t)';
                end
            else
                fprintf('\nC:\n');
                s9 = 'C';
            end
            disp(self.CtMat);
            %%
            s10 = ['  +  w' s0];
            if ~(isempty(self.noiseBoundsEll))
                fprintf('\nNoise bounds:\n');
                if isa(self.noiseBoundsEll, 'ellipsoid')
                    [qVec, QMat] = parameters(self.noiseBoundsEll);
                    fprintf('   %d-dimensional constant ellipsoid with center\n',...
                        size(self.CtMat, 1));
                    disp(qVec);
                    fprintf('   and shape matrix\n');
                    disp(QMat);
                elseif isstruct(self.noiseBoundsEll)
                    UEll = self.noiseBoundsEll;
                    fprintf('   %d-dimensional ellipsoid with center\n',...
                        size(self.CtMat, 1));
                    disp(UEll.center);
                    fprintf('   and shape matrix\n');
                    disp(UEll.shape);
                elseif isa(self.noiseBoundsEll, 'double')
                    fprintf('   constant vector\n');
                    disp(self.noiseBoundsEll);
                    s10 = '  +  w';
                else
                    fprintf('   vector\n');
                    disp(self.noiseBoundsEll);
                end
            else
                s10 = '';
            end
            %%
            fprintf('%d-input, ', size(self.BtMat, 2));
            fprintf('%d-output ', size(self.CtMat, 1));
            if self.isDiscr
                fprintf('discrete-time linear ');
            else
                fprintf('continuous-time linear ');
            end
            if self.isTimeInv
                fprintf('time-invariant system ');
            else
                fprintf('system ');
            end
            fprintf('of dimension %d', size(self.AtMat, 1));
            if ~(isempty(self.GtMat))
                if size(self.GtMat, 2) == 1
                    fprintf('\nwith 1 disturbance input');
                elseif size(self.GtMat, 2) > 1
                    fprintf('\nwith %d disturbance input',...
                        size(self.GtMat, 2));
                end
            end
            fprintf(':\n%s%s%s%s%s%s%s\n%s%s%s%s\n\n',...
                s1, s4, s3, s5, s6, s7, s8, s2, s9, s3, s10);
            return; 
        end
        %
        %
        %
        function isDisturbance = hasdisturbance(self)
            global ellOptions;
            %%
            if ~isstruct(ellOptions)
                evalin('base', 'ellipsoids_init;');
            end
            %%
            if  ~isempty(self.disturbanceBoundsEll) && ~isempty(self.GtMat)
                isDisturbance(iRow, jCol) = true;
            end
        end
        %
        %
        %
        function isNoise = hasnoise(self)
            global ellOptions;
            %%
            if ~isstruct(ellOptions)
                evalin('base', 'ellipsoids_init;');
            end
            %%
            isNoise = false;
            %%
            if ~isempty(self.noiseBoundsEll) 
                isNoise = true;
            end
        end
        %
        %
        %
        function isDiscrete = isdiscrete(self)
            global ellOptions;
            %%
            if ~isstruct(ellOptions)
                evalin('base', 'ellipsoids_init;');
            end
            %%
            isDiscrete = self.isDiscr;
        end
        %
        %
        %
        function isEmpty = isempty(self)
            global ellOptions;
            %%
            if ~isstruct(ellOptions)
                evalin('base', 'ellipsoids_init;');
            end
            %%
            isEmpty = false;
            %%
            if isempty(self.AtMat) 
                isEmpty = true;
            end
        end
        %
        %
        %
        function isLti = islti(self)
            global ellOptions;
            %%
            if ~isstruct(ellOptions)
                evalin('base', 'ellipsoids_init;');
            end
            %%
            isLti = self.isTimeInv;
        end
    end
end