function inpArray=checkcelloffunc(inpArray,isEmptyAllowed)
% CHECKCELLOFFUNC checks that input variable is either a function_handle 
% of cell of function_handle (char is converted to a cell), 
% in case validation fails an exception is thrown
%
% Input:
%   regular:
%       inpArray: anyType[]
%   optional:
%       isEmptyAllowed: logical[1,1] - if true, {} passes the check and
%           causes an exception otherwise, false by default
%
% Output:
%   inpArray: cell[1,] of char[1,]
%
% $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
% Faculty of Applied Mathematics and Cybernetics, System Analysis
% Department, 7-October-2012, <pgagarinov@gmail.com>$
%
import modgen.common.throwerror;
if nargin==1
    isEmptyAllowed=false;
end
% 
if ~(modgen.common.isrow(inpArray)||isEmptyAllowed&&isempty(inpArray))
    if ~isEmptyAllowed
        throwerror('wrongInput',...
            '%s is char is expected to be a row',inputname(1));
    else
        throwerror('wrongInput',...
            '%s is char is expected to be a row or empty cell',...
            inputname(1));
    end        
end
if isa(inpArray,'function_handle')
    inpArray={inpArray};
elseif ~iscell(inpArray)
    throwerror('wrongInput',...
        'input array should be either function_handle or cell');
else
    if ~all(cellfun('isclass',inpArray,'function_handle'))
        throwerror('wrongInput',...
            '%s is expected to be a cell array of function_handles',inputname(1));
    end
end