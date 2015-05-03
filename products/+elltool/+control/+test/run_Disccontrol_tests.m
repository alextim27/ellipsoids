function results = run_Disccontrol_tests(varargin)

[~,~,isReCache] = modgen.common.parseparext(varargin,...
    {'reCache';false;'islogical(x)'});

if ~exist('isReCache','var')
    isReCache = 0;
end


import elltool.reach.ReachFactory;
%
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
%
% crm = gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
% crmSys = gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
crm = elltool.control.test.conf.ConfRepoMgr();
crmSys = elltool.control.test.conf.sysdef.ConfRepoMgr();
%
confCMat = {
    'discrFirstTest',[1 1],[1 1];
    'discrSecondTest',[1 1],[1 1];
    'onedir',[1 1],[1 0 0 1 -4 7 -7 6; 1 0.627918422222137 0.627918422222137 1 -0.860407888889313...
          3.23248946666718 -1.9766526222229 2.86040788888931 ;1 1 1 1 1 1 1 1];
    'basic',[1 1],[-0.1 0 0 0 -3 6 -4 2; 0.51117172241211 1.11122131347656 0.555610656738281...
          0 -0.777557373046875 3.77755737304688 -1.77755737304688 1.44438934326172; 1 2 1 0 1 2 0 1];
    'advanced',[1,1],[-1 0 0 0 -5.3 6 -3 2; -2.92020392417908 0.960101962089539...
         -0.960101962089539 0.960101962089539 -3.09176548719406 10.3204588294029...
          -3.96010196208954 3.92020392417908;-3 1 -1 1 -3 10.5 -4 4];
    'osc8',[1 1],[-16 14 0 16 4 -30 0 -30;0.414507150650024 1.44772982597351 0.965559244155884...
          1.51661133766174 1.10332226753235 -0.0676634311676025 0.965559244155884...
        -0.0676634311676025;1 1 1 1 1 1 1 1];
    };
nConfs = size(confCMat, 1);
suiteList = {};
outPointVecList=[];
% 
for iConf = 1:nConfs
    confName = confCMat{iConf, 1};
    confTestsVec = confCMat{iConf, 2};
    inPointVecList  = confCMat{iConf, 3};
    if confTestsVec(1)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.control.test.mlunit.ReachDiscTC',...
            ReachFactory(confName, crm, crmSys, true, false,true),...
            inPointVecList , outPointVecList,isReCache,...
            'marker',[confName,'_IsBackTrueIsEvolveFalse_disc']);
    end 
    if confTestsVec(2)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.control.test.mlunit.ReachDiscTC',...
            ReachFactory(confName, crm, crmSys, true, true,true),...
            inPointVecList , outPointVecList,isReCache,...
            'marker',[confName,'_IsBackTrueIsEvolveTrue_disc']);
    end 

end

testLists = cellfun(@(x)x.tests,suiteList,'UniformOutput',false);
testList=horzcat(testLists{:});
suite = mlunitext.test_suite(testList);
suiteFilteredObj = suite.getCopyFiltered('discrFirstTest'); 
results = runner.run(suiteFilteredObj);
