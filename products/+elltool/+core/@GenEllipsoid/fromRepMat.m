function ellArr=fromRepMat(varargin)
% FROMREPMAT - returns array of equal GenEllipsoids the same
%		size as stated in sizeVec argument
% 
% ellArr=fromRepMat(sizeVec) - creates an array of size 
%	sizeVec of empty GenEllipsoids.
% 
% ellArr=fromRepMat(dMat,sizeVec) - creates an array of size 
%	sizeVec of GenEllipsoids with diagonal matrix qMat.
% 
% ellArr=fromRepMat(cVec,dMat,sizeVec) - creates an
%	array of size sizeVec of GenEllipsoids with diagonal 
%	matrix qMat and center cVec.
%
% ellArr=fromRepMat(cVec,dMat,wMat,sizeVec) - creates an
%	array of size sizeVec of GenEllipsoids with diagonal 
%	matrix dMat, square matrix wMat and center cVec.
%
% Input:
%	Case1:
%		regular: 
%			sizeVec: double[1,n] - vector of size, have 
%				integer values.
% 
%	Case2:
%		regular:
%			dMat: double[nDim, nDim] / dVec: double[nDim,1] - 
%				shape matrix of GenEllipsoids. 
%			sizeVec: double[1,n] - vector of size, have 
%				integer values.
% 
%	Case3:
%		regular:
%			cVec: double[nDim,1] - center vector of 
%				GenEllipsoids
%			dMat: double[nDim, nDim] / dVec: double[nDim,1] - 
%				shape matrix of GenEllipsoids. 
%			sizeVec: double[1,n] - vector of size, have 
%				integer values.
%
%	Case4:
%		regular:
%			cVec: double[nDim,1] - center vector of 
%				GenEllipsoids
%			dMat: double[nDim, nDim] / dVec: double[nDim,1] - 
%				shape matrix of GenEllipsoids. 
%			wMat: double[nDim, nDim] - square matrix of GenEllipsoids. 
%			sizeVec: double[1,n] - vector of size, have 
%				integer values.
%
% Output:
%	ellArr: ellipsoid[] - created GenEllipsoidal array
%
% Example:
%	ellObj = GenEllipsoid.fromRepMat([3;4],[1 2])
%
%	ellObj = 
%
%
%	Structure(1, 1)
%		|    
%		|-- centerVec : [0 0]
%		|               -----
%		|------- QMat : |3|0|
%		|        		|0|4|
%		|               -----
%		|               -----
%		|---- QInfMat : |0|0|
%		|        		|0|0|
%		|               -----
%		O
%
%	Structure(2, 1)
%		|    
%		|-- centerVec : [0 0]
%		|               -----
%		|------- QMat : |3|0|
%		|        		|0|4|
%		|               -----
%		|               -----
%		|---- QInfMat : |0|0|
%		|        		|0|0|
%		|               -----
%		O
%
% $Author: Alexandr Timchenko <timchenko.alexandr@gmail.com> $   
% $Date: Dec-2015$
% $Copyright: Moscow State University,
%			Faculty of Computational Mathematics and Computer Science,
%			System Analysis Department 2015 $
%
import modgen.common.checkvar;
import elltool.core.GenEllipsoid;
%
if nargin>4
    indVec=[1:4,5:nargin];
    sizeVec=varargin{4};
else
    sizeVec=varargin{nargin};
    indVec=1:nargin-1;
end
%
if ~isa(sizeVec,'double')
    modgen.common.throwerror('wrongInput','Size array is not double');
end
sizeVec=gras.la.trytreatasreal(sizeVec);
checkvar(sizeVec,@(x)size(x,2)>1,'errorTag','wrongInput',...
    'errorMessage','size vector must have at least two elements')
checkvar(sizeVec,@(x)all(mod(x(:),1)==0)&&all(x(:)>0)...
    &&(size(x,1)==1),'errorTag','wrongInput', ...
    'errorMessage','size vector must contain positive integer values.');
%
nEllipsoids=prod(sizeVec);
ellArr(nEllipsoids)=GenEllipsoid();
% 
ell=GenEllipsoid(varargin{indVec});
arrayfun(@(x)makeEllipsoid(x),1:nEllipsoids);
ellArr=reshape(ellArr,sizeVec);
%
function makeEllipsoid(index)
    ellArr(index)=getCopy(ell);
end
end