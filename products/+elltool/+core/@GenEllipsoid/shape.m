function ellArr = shape(ellArr, modMat)
%
% SHAPE - modifies the shape matrix of the GenEllipsoid without
%	changing its center. 
%
%	modEllArr = SHAPE(ellArr, modMat) Modifies the shape matrices of
%		the GenEllipsoids in the ellipsoidal array ellArr. The centers
%		remain untouched - that is the difference of the function SHAPE and
%		linear transformation modMat*ellArr. modMat is expected to be a
%		scalar or a square matrix of suitable dimension.
%
% Input:
%	regular:
%		ellArr: GenEllipsoid [nDims1,nDims2,...,nDimsN] - array
%			of GenEllipsoids.
%		modMat: double[nDim, nDim]/[1,1] - square matrix or scalar
%
% Output:
%	ellArr: GenEllipsoid [nDims1,nDims2,...,nDimsN] - array of modified
%		GenEllipsoids.
%
% Example:
%	ellObj = GenEllipsoid([-2; -1], [4 -1; -1 1]);
%	tempMat = [0 1; -1 0];
%	outEllObj = shape(ellObj, tempMat)
%	outEllObj = 
%
%		|    
%		|-- centerVec : [-2 -1]
%		|               -----
%		|------- QMat : |1|1|
%		|               |1|4|
%       |               -----
%		|               -----
%		|---- QInfMat : |0|0|
%		|               |0|0|
%		|               -----
%
% $Author: Alexandr Timchenko <timchenko.alexandr@gmail.com> $   
% $Date: Dec-2015$
% $Copyright: Moscow State University,
%			Faculty of Computational Mathematics and Computer Science,
%			System Analysis Department 2015 $
%
import elltool.core.GenEllipsoid;
GenEllipsoid.checkIsMe(ellArr);
modgen.common.checkvar(modMat,@(x)isa(x,'double'),...
    'errorMessage','second input argument must be double');   
isModScal=isscalar(modMat);
if isModScal
   modMatSq=modMat*modMat;
else
    [nRows,nDim]=size(modMat);
    dimArr=dimension(ellArr);
    modgen.common.checkmultvar('(x1==x2)&&all(x3(:)==x2)',...
        3,nRows,nDim,dimArr,'errorMessage',...
        'input matrix not square or dimensions do not match');
end
arrayfun(@(x)fSingleShape(x),ellArr);
    function fSingleShape(ellObj)
        if isModScal
            eigvMat=modMatSq*ellObj.eigvMat;
        else
            eigvMat=modMat*ellObj.eigvMat;
        end
        ellObj.eigvMat=eigvMat;
    end
end
