function logprintf(logLevel, varargin)
% LOGPRINTF passes a printf-formatted message to a log4j logger
%
% Input:
%   regular:
%     logLevel: char[1,] - log level for log4j. Possible values:
%       trace, debug, info, warn, error, fatal
%   optional:
%     printf arguments (see sprintf documentation)
%
% $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
% Faculty of Applied Mathematics and Cybernetics, System Analysis
% Department, 7-October-2012, <pgagarinov@gmail.com>$

persistent log4jLogger
%
logLevel = lower(logLevel);
switch logLevel
    case {'trace', 'debug', 'info', 'warn', 'error', 'fatal'}
    otherwise
        error([upper(mfilename),':wrongInput'], ...
            'Unsupported value of logLevel: %s', logLevel);
end
%
if isempty(log4jLogger)
    log4jLogger=modgen.logging.log4j.Log4jConfigurator.getLogger();
end
%
msg = sprintf(varargin{:});
% Trim the last newline char, since the logger will add one anyway
if msg(end) == sprintf('\n')
    msg = msg(1:end-1);
end
fh = eval(['@log4jLogger.', logLevel]);
fh(msg); % single-step feval doesn't work here
end

