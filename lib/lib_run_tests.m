function results=lib_run_tests(varargin)
resList{1}=modgen.test.run_tests(varargin{:});
resList{2}=mlunitext.test.run_tests(varargin{:});
%
results=[resList{:}];
[errorCount,failCount]=mlunitext.countfailsinresults(results);
sprintf('(failures: %d, errors %d)',failCount,errorCount);