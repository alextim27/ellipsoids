classdef MatrixSysODESolver
    properties(Access = protected)
        sizeEqList
        fSolveFunc
        nEquations
        indEqList
        indOutArgStartVec
    end
    methods
        function self=MatrixSysODESolver(sizeVecList,fSolveFunc,varargin)
            % MATRIXSYSODESOLVER - MatrixSysODESolver
            %   class constructor.
            % Input:
            %   regular:
            %       sizeVecList: double[1,nEquations] - variable that holds
            %           the dimension of each equation of the system
            %       fSolveFunc: function_handle[1,1] - ODE solver
            %   properties:
            %       indOutArgStartVec: double[1,nEquations] - number of 
            %           output for each of the functions that calculate
            %           the right side
            %       
            % Output:
            %   self: MatrixSysODESolver[1,1] - MatrixSysODESolver class
            %       object
            %   
            % $Author: Vadim Danilov <vadimdanilov93@gmail.com> $  
            % $Date: 24-oct-2013$
            % $Copyright: Moscow State University,
            %  Faculty of Computational Mathematics and Cybernetics,
            %  Science, System Analysis Department 2013 $
            import modgen.common.throwerror;
            import modgen.common.parseparext;
            if ~all(cellfun('length',sizeVecList)>=2);
                throwerror('wrongInput',['each element of size vector',...
                    'list should contain at least 2 elements']);
            end
            self.sizeEqList=sizeVecList;
            nEqs=length(sizeVecList);
            nElemVec=cellfun(@prod,sizeVecList);
            nElemCumVec=cumsum(nElemVec);
            self.indEqList=cellfun(@(x,y)x:y,...
                num2cell(ones(1,nEqs)+[0,nElemCumVec(1:end-1)]),...
                num2cell(nElemCumVec),'UniformOutput',false);
            %
            [~,~,self.indOutArgStartVec]=parseparext(varargin,...
                {'outArgStartIndVec';ones(1,nEqs);...
                'isnumeric(x)&&isrow(x)&&all(fix(x)==x)'},0);
            self.fSolveFunc=fSolveFunc;
            self.nEquations=nEqs;
        end
        function [timeVec,varargout]=solve(self,fDerivFuncList,...
                timeVec,varargin)
            % SOLVE - solver of the system of matrix equations
            % Input:
            %   regular:
            %       self: gras.ode.MatrixSysODESolver[1,1] -
            %           all the data nessecary to solve the system of
            %           matrix equations  is stored in this object;
            %       fDerivFuncList: cell[1,nEquations] of function handle -
            %           list of derivatives functions;
            %       timeVec: double[1,nPoints] - time range, same meaning 
            %           as in ode45;
            %       initalValue1Mat: double[size1Eqn] - inital value
            %           for the first equation
            %           ...
            %       initalValueNMat: double[sizeNEqn] - inital value
            %           for the N-th equation (N == nEquation)
            % Output:
            %   regular:
            %       timeVec: double[nPoints,1] - time grid, same meaning
            %           as in ode45
            %   optional:
            %       outArg1Array: double[sizeEqList{1}]
            %           ...
            %       outArgNArray: double[sizeEqList{nEquations*nFuncs}] -
            %           these variables contains nEquations*nFuncs arrays
            %           of dobule (nEquations for each function), each of
            %           which is a solution of the corresponding equation 
            %           for the corresponding function. (here N in the
            %           name outArgN equal nEquations*nFuncs)
            %       outArgExtra1: <anyType>
            %       outArgExtra2: <anyType>
            %           ...
            %       outArgExtraN: <anyType> - these variables contain the 
            %           data returned directly from the function solver
            % Example:
            %   % Example corresponds to four equations and two derivatives
            %   % functions
            %   
            %   solveObj=gras.ode.MatrixSysODESolver(...
            %       sizeVecList,@(varargin)fSolver(varargin{:},...
            %       odeset(odePropList{:})),varargin{:});
            %
            %   % here interpObj gras.ode.VecOde45RegInterp class object - 
            %   % a variable that is directly returned from ode45reg solver
            %
            %   [resInterpTimeVec,resSolveSimpleFunc1Array,...
            %       resSolveSimpleFunc2Array,resSolveSimpleFunc3Array,...
            %       resSolveSimpleFunc4Array,resSolveRegFunc5Array,...
            %       resSolveRegFunc6Array,resSolveRegFunc7Array,...
            %       resSolveRegFunc8Array,interpObj]=solveObj.solve(...
            %       fDerivFuncList,timeVec,initValList{:});
            %
            % $Author: Vadim Danilov <vadimdanilov93@gmail.com> $  
            % $Date: 24-oct-2013$
            % $Copyright: Moscow State University,
            %  Faculty of Computational Mathematics and Cybernetics,
            %  Science, System Analysis Department 2013 $
            import modgen.common.throwerror;
            %
            if ~all(cellfun(@auxchecksize,varargin,self.sizeEqList))
                throwerror('wrongInput',['initial values should be ',...
                    'consistent with list of size vectors ',...
                    'specified in constructor']);
            end
            fDerivFuncList=modgen.common.type.simple.checkcelloffunc(...
                fDerivFuncList);
            nFuncs=length(fDerivFuncList);
            fMatrixDerivFuncList=cell(1,nFuncs);
            indOutArgStartVec=self.indOutArgStartVec;
            for iFunc=1:nFuncs
                fMatrixDerivFuncList{iFunc}=@(t,y)reshapeInOut(self,t,y,...
                    fDerivFuncList{iFunc},indOutArgStartVec(iFunc));
            end
            varargin=cellfun(@(x)x(:),varargin,'UniformOutput',false);
            initValVec=vertcat(varargin{:});
            resList=cell(1,nFuncs);
            outExtraList=cell(1,nargout-nFuncs*length(self.sizeEqList)-1);
            [timeVec,resList{:},outExtraList{:}]=...
                self.fSolveFunc(fMatrixDerivFuncList{:},...
                timeVec,initValVec(:));
            timeVec=timeVec.';
            nTimePoints=length(timeVec);
            nEqs=self.nEquations;
            indEqList=self.indEqList;
            sizeEqList=self.sizeEqList;
            for iFunc=1:nFuncs
                indShift=(iFunc-1)*nEqs;
                for iEq=1:nEqs
                    varargout{indShift+iEq}=reshape(...
                        transpose(resList{iFunc}(:,indEqList{iEq})),...
                        [sizeEqList{iEq} nTimePoints]);
                end
            end
            varargout = [varargout outExtraList];
        end
    end
    methods (Access=private)
        function varargout=reshapeInOut(self,t,y,fDerivFunc,indStart)
            nEqs=self.nEquations;
            nOutArgs=indStart-1+nEqs;
            indOutArgVec=indStart:nOutArgs;
            outList=cell(1,nOutArgs);
            inList=cell(1,nEqs);
            sizeEqList=self.sizeEqList;
            indEqList=self.indEqList;
            for iEq=1:nEqs
                inList{iEq}=reshape(y(indEqList{iEq}),sizeEqList{iEq});
            end
            [outList{:}]=fDerivFunc(t,inList{:});
            outList(indOutArgVec)=cellfun(@(x)x(:),...
                outList(indOutArgVec),'UniformOutput',false);
            varargout(1:indStart-1)=outList(1:indStart-1);
            varargout{indStart}=vertcat(outList{indOutArgVec});
        end
    end
end