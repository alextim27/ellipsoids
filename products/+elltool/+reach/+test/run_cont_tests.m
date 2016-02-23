function results = run_cont_tests(varargin)
% Example:
%
%   elltool.reach.test.run_cont_tests('filter',{'demo3firstTest',...
%       'elltool.reach.test.mlunit.ContinuousReachTestCase','testCut'})  
%
%   elltool.reach.test.run_cont_tests('filter',{'.*',...
%       'elltool.reach.test.mlunit.ContinuousReachTestCase','testCut'})
%
%   elltool.reach.test.run_cont_tests('filter',{'_IsBackTrueIsEvolveFalse',...
%       '.*','testCut'},'nParallelProcesses',8)
%
% $Authors: Peter Gagarinov <pgagarinov@gmail.com>
% $Date: March-2016 $
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics
%             and Computer Science,
%             System Analysis Department 2012-2016$
import elltool.reach.ReachFactory;
%
%
[restArgList,~,filterPropList]=modgen.common.parseparext(varargin,...
    {'filter';{}});
[~,suitePropList]=modgen.common.parseparams(restArgList,[],0);
%
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
%
crm=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
crmSys=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
%
confCMat = {
    'demo3firstTest',  [1 0 1 0 1 0 1 0 1 1 0 1 1 0];
    'demo3secondTest', [0 0 0 0 0 0 0 0 1 0 0 0 0 0];
    'demo3thirdTest',  [0 0 0 0 0 1 0 1 1 0 0 0 0 0];
    'demo3fourthTest', [0 0 0 1 1 1 0 0 1 0 0 0 0 1];
    'test2dbad',       [0 0 0 0 0 0 0 0 0 0 1 0 0 0]...
    };
%
nConfs = size(confCMat, 1);
suiteList = {};
%
for iConf = 1:nConfs
    confName = confCMat{iConf, 1};
    confTestsVec = confCMat{iConf, 2};
    if confTestsVec(1)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachTestCase',...
            ReachFactory(confName, crm, crmSys, false, false),...
            'marker',[confName,'_IsBackFalseIsEvolveFalse']);
    end
    if confTestsVec(2)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachTestCase',...
            ReachFactory(confName, crm, crmSys, true, false),...
            'marker',[confName,'_IsBackTrueIsEvolveFalse']);
    end
    if confTestsVec(3)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachTestCase',...
            ReachFactory(confName, crm, crmSys, false, true),...
            'marker',[confName,'_IsBackFalseIsEvolveTrue']);
    end
    if confTestsVec(4)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachTestCase',...
            ReachFactory(confName, crm, crmSys, true, true),...
            'marker',[confName,'_IsBackTrueIsEvolveTrue']);
    end
    if confTestsVec(5)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachProjTestCase',...
            confName, crm, crmSys,...
            'marker',confName);
    end
    if confTestsVec(7)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachRefineTestCase',...
            ReachFactory(confName, crm, crmSys, false, false),...
            'marker',confName);
    end 
    if confTestsVec(8)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachRegTestCase',...
            confName, crm, crmSys);
    end
    if confTestsVec(9)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousIsEqualTestCase',...
            ReachFactory(confName, crm, crmSys, false, false),...
			'marker', confName); 
    end
    if confTestsVec(10)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachFirstTestCase',...
            confName, crm, crmSys,'marker',confName);
    end
    if confTestsVec(11)
        MODE_LIST = {'fix'};%allowed modes: fix, rand        
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachProjAdvTestCase',...
            confName, crm, crmSys, MODE_LIST,...
            'marker',confName);    
    end
    if confTestsVec(12)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousSecReachTestCase',...
            ReachFactory(confName, crm, crmSys, false, false),...
            'marker',[confName,'_IsBackFalseIsEvolveFalse']);
    end
    if confTestsVec(13)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousSecReachTestCase',...
            ReachFactory(confName, crm, crmSys, false, true),...
            'marker',[confName,'_IsBackFalseIsEvolveTrue']);
    end
    if confTestsVec(14) 
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousSecReachTestCase',...
            ReachFactory(confName, crm, crmSys, true, true),...
            'marker',[confName,'_IsBackTrueIsEvolveTrue']); %#ok<*AGROW>
    end
    %
    suiteList{end + 1} = loader.load_tests_from_test_case(...
        'elltool.reach.test.mlunit.ContReachTestNTimeGridPoints',...
        ReachFactory(confName, crm, crmSys, true, true),...
        'marker',[confName,'_IsBackTrueIsEvolveTrue']);
end
suiteList{end + 1} = loader.load_tests_from_test_case(...
    'elltool.reach.test.mlunit.MPTIntegrationTestCase');
%%
testLists = cellfun(@(x)x.tests,suiteList,'UniformOutput',false);
testList=horzcat(testLists{:});
suite = mlunitext.test_suite(testList,suitePropList{:});
suite=suite.getCopyFiltered(filterPropList{:});
results = runner.run(suite);