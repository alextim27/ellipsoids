  T  = 5;
  w  = 2;
  A  = [0 1; -w 0];
  B  = eye(2);
  C  = eye(2);
  U  = ellipsoid([9 0; 0 2]);
  V  = ellipsoid([1 0; 0 2]);
  s  = elltool.linsys.LinSysContinuous(A, B, U, C, V);
  
  X0 = ellipsoid([10; 0], [25 0; 0 25]);
  L0 = [1 -1; 1 1; 0 1]';
%  L0 = [1 1]';
  rs = elltool.reach.ReachContinuous(s, X0, L0, [T 0], 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);
