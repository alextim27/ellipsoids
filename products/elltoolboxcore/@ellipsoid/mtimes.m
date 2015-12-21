function outEllArr=mtimes(multMat,inpEllArr)
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
[isFstScal,outEllArr]=mtimesInternal(multMat,inpEllArr);
arrayfun(@(x) fSingleMtimes(x),outEllArr);
    function fSingleMtimes(ellObj)
        if isFstScal
            shMat=multMat*multMat*singEll.getShapeMat();
        else
            shMat=multMat*(ellObj.getShapeMat())*multMat';
            shMat=0.5*(shMat + shMat');
        end
        ellObj.centerVec=multMat*ellObj.getCenterVec();
        ellObj.shapeMat=shMat;
    end
end