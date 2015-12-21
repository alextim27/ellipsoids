function [isFstScal,outEllVec]=mtimesInternal(multMat,inpEllVec)
%
% MTIMES - overloaded operator '*'.
%
%   Multiplication of the ellipsoid by a matrix or a scalar.
%   If inpEllVec(iEll) = E(q, Q) is an ellipsoid, and
%   multMat = A - matrix of suitable dimensions,
%   then A E(q, Q) = E(Aq, AQA').
%
% Input:
%   regular:
%       multMat: double[mRows, nDims]/[1, 1] - scalar or
%           matrix in R^{mRows x nDim}
%       inpEllVec: ellipsoid [1, nCols] - array of ellipsoids.
%
% Output:
%   outEllVec: ellipsoid [1, nCols] - resulting ellipsoids.
%
% Example:
%   ellObj = ellipsoid([-2; -1], [4 -1; -1 1]);
%   tempMat = [0 1; -1 0];
%   outEllObj = tempMat*ellObj
%
%   outEllObj =
%
%   Center:
%       -1
%        2
%
%   Shape:
%        1     1
%        1     4
%
%   Nondegenerate ellipsoid in R^2.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California
% 2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $
% $Date: Dec-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
import modgen.common.checkvar
checkIsMeVirtual(inpEllVec);
checkvar(multMat,@(x)isa(x,'double'),...
    'errorTag','wrongInput','errorMessage',...
    'first input argument must be matrix or sacalar.');
checkvar(inpEllVec,'~any(isempty(x(:)))',...
    'errorTag','wrongInput','errorMessage',...
    'array of ellipsoids contains empty ellipsoid');
isFstScal=isscalar(multMat);
nDims=size(multMat,2);
nDimsVec=dimension(inpEllVec);
modgen.common.checkmultvar...
    ('all(x2(:)==x2(1))&&(x1||(~x1)&&(x2(1)==x3))',3,isFstScal,...
    nDimsVec,nDims,'errorTag','wrongSizes','errorMessage',...
    'dimensions not match.');
outEllVec=inpEllVec.getCopy();
end