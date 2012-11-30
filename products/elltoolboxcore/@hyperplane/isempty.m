function isPositiveArr = isempty(myHypArr)
%
% ISEMPTY - checks if hyperplanes in H are empty.
%
% Input:
%   regular:
%       myHypArr: hyperplane [nDims1, nDims2, ...] - array
%           of hyperplanes.
%
% Output:
%   isPositiveArr: logical[nDims1, nDims2, ...],
%       isPositiveArr(iDim1, iDim2, ...) = true - if ellipsoid
%       myHypArr(iDim1, iDim2, ...) is empty, false - otherwise.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: Aushkap Nikolay <n.aushkap@gmail.com> $  $Date: 30-11-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $

modgen.common.checkvar(myHypArr, 'isa(x,''hyperplane'')',...
    'errorTag', 'wrongInput',...
    'errorMessage', 'ISEMPTY: input argument must be hyperplanes.');

isPositiveArr = ~dimension(myHypArr);
