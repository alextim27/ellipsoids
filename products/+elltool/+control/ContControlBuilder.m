classdef ContControlBuilder
    properties (Access = private)
        intEllTube
        probDynamicsList
        goodDirSetList
    end
    methods        
        function self=ContControlBuilder(ReachContObj)
            import modgen.common.throwerror;
            ellTubeRel=ReachContObj.getEllTubeRel();
            self.intEllTube=ellTubeRel.getTuplesFilteredBy('approxType', ...
                gras.ellapx.enums.EApproxType.Internal);
            self.probDynamicsList=ReachContObj.getIntProbDynamicsList();
            self.goodDirSetList=ReachContObj.getGoodDirSetList();
            isBackward=ReachContObj.isbackward();
            if (~isBackward)
                throwerror('wrongInput',...
                    'System is in the forward time while should be backward system');                
            end
        end
        
        function ControlFuncObj=getControl(self,x0Vec)
            import modgen.common.throwerror;
            nTuples = self.intEllTube.getNTuples;
            TOL=10^(-5);
            %Tuple selection
            properIndTube=1;
            isX0inset=false;
            if (~all(size(x0Vec)==size(self.intEllTube.aMat{1}(:,1))))
                throwerror('wrongInput',...
                    'the dimension of x0 does not correspond the dimension of solvability domain');
            end
            for iTube=1:nTuples
                %check if x is in E(q,Q), x: <x-q,Q^(-1)(x-q)><=1
                %if (dot(x-qVec,inv(qMat)*(x-qVec))<=1)
                
                qVec=self.intEllTube.aMat{iTube}(:,1);  
                qMat=self.intEllTube.QArray{iTube}(:,:,1); 
                if (dot(x0Vec-qVec,qMat\(x0Vec-qVec))<=1+TOL)                    
                    isX0inset=true;                    
                    properIndTube=iTube;
                end
            end
            goodDirOrderedVec=mapGoodDirInd(self.goodDirSetList{1}{1},self.intEllTube);
            indTube=goodDirOrderedVec(properIndTube);
            properEllTube=self.intEllTube.getTuples(properIndTube); 
            qVec=properEllTube.aMat{:}(:,1);  
            qMat=properEllTube.QArray{:}(:,:,1);  
            if (isX0inset)  
                iWithoutX=findEllWithoutX(qVec, qMat, x0Vec);
            else
                iWithoutX=1;
            end
            properEllTube.scale(@(x)sqrt(iWithoutX),'QArray'); 
            % scale multiplies k^2 
 
            ControlFuncObj=elltool.control.Control(properEllTube,...
                self.probDynamicsList, self.goodDirSetList,indTube,iWithoutX);  
            function iWithoutX=findEllWithoutX(qVec, qMat, x0Vec)
                iWithoutX=1;
                if (dot(x0Vec-qVec,qMat\(x0Vec-qVec))<=1)
                    iWithoutX=dot(x0Vec-qVec,qMat\(x0Vec-qVec));                    
                end                
            end            
   
            function goodDirOrderedVec=mapGoodDirInd(goodDirSetObj,ellTube)
                CMP_TOL=1e-10;
                nTuples = ellTube.getNTuples;
                goodDirOrderedVec=zeros(1,nTuples);
                lsGoodDirMat = goodDirSetObj.getlsGoodDirMat();
                for iGoodDir = 1:size(lsGoodDirMat, 2)
                    lsGoodDirMat(:, iGoodDir) = ...
                        lsGoodDirMat(:, iGoodDir) / ...
                        norm(lsGoodDirMat(:, iGoodDir));
                end
                lsGoodDirCMat = ellTube.lsGoodDirVec();
                for iTuple = 1 : nTuples
                    %
                    % good directions' indexes mapping
                    %
                    curGoodDirVec = lsGoodDirCMat{iTuple};
                    curGoodDirVec = curGoodDirVec / norm(curGoodDirVec);
                    for iGoodDir = 1:size(lsGoodDirMat, 2)
                        isFound = norm(curGoodDirVec - ...
                            lsGoodDirMat(:, iGoodDir)) <= CMP_TOL;
                        if isFound
                            break;
                        end
                    end
                    mlunitext.assert_equals(true, isFound,...
                        'Vector mapping - good dir vector not found');
                    goodDirOrderedVec(iTuple)=iGoodDir;
                end
            end
        end
    end    
end