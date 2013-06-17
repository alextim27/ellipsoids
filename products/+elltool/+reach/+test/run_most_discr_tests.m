function results = run_most_discr_tests(varargin)
% RUN_MOST_DISCR_TESTS runs most of the tests based on specified patters
% for markers, test cases, tests names
%
% Input:
%   optional:
%       markerRegExp: char[1,] - regexp for marker AND/OR configuration
%           names, default is '.*' which means 'all cofigs'
%       testCaseRegExp: char[1,] - regexp for test case names, same default
%       testRegExp: char[1,] - regexp for test names, same default
%
% Output:
%   results: mlunitext.text_test_run[1,1] - test result
%
% Example:
%
%   elltool.reach.test.run_most_discr_tests('demo3firstTest',...
%       'elltool.reach.test.mlunit.ContinuousReachTestCase','testCut')
%
%   elltool.reach.test.run_most_discr_tests('.*',...
%       'elltool.reach.test.mlunit.ContinuousReachTestCase','testCut')
%
%   elltool.reach.test.run_most_discr_tests('_IsBackTrueIsEvolveFalse',...
%       '.*','testCut')
%
% $Authors: Peter Gagarinov <pgagarinov@gmail.com>
% $Date: March-2013 $
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics
%             and Computer Science,
%             System Analysis Department 2012-2013$
%
import elltool.reach.ReachFactory;
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
%
crm = gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
crmSys = gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
%
confCMat = {
    'discrFirstTest',  [1 0 1 1 0];
    'discrSecondTest',  [1 1 1 0 0];
    'demo3fourthTest', [0 0 0 0 1];
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
            'elltool.reach.test.mlunit.DiscreteReachTestCase', ...
            ReachFactory(confName, crm, crmSys, false, false, true), ...
            'marker', [confName,'_IsBackFalseIsEvolveFalse']);
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.DiscreteReachTestCase', ...
            ReachFactory(confName, crm, crmSys, true, false, true), ...
            'marker', [confName,'_IsBackTrueIsEvolveFalse']);
    end
    if confTestsVec(2)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachTestCase', ...
            ReachFactory(confName, crm, crmSys, false, false, true), ...
            'marker', [confName,'_IsBackFalseIsEvolveFalse']);
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachTestCase', ...
            ReachFactory(confName, crm, crmSys, true, false, true), ...
            'marker', [confName,'_IsBackTrueIsEvolveFalse']);
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachTestCase', ...
            ReachFactory(confName, crm, crmSys, false, true, true), ...
            'marker', [confName,'_IsBackFalseIsEvolveTrue']);
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachTestCase', ...
            ReachFactory(confName, crm, crmSys, true, true, true), ...
            'marker', [confName,'_IsBackTrueIsEvolveTrue']);
    end
    if confTestsVec(3)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.DiscreteReachProjTestCase', ...
            confName, crm, crmSys, 'marker', confName);
    end
    if confTestsVec(4)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachRefineTestCase',...
            ReachFactory(confName, crm, crmSys, false, false,true),...
            'marker',confName);
    end
    if confTestsVec(5)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.DiscreteReachRegTestCase',...
            confName, crm, crmSys);
    end
end
suiteList{end + 1} = loader.load_tests_from_test_case(...
    'elltool.reach.test.mlunit.DiscreteReachFirstTestCase',...
    crm, crmSys);
%
testLists = cellfun(@(x)x.tests,suiteList,'UniformOutput',false);
testList=horzcat(testLists{:});
suite = mlunitext.test_suite(testList);
suite=suite.getCopyFiltered(varargin{:});
results = runner.run(suite);
