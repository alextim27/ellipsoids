import elltool.conf.Properties;

C =0.25;
 aMat = [0 1; 0 0]; B = [0; 1]; 
 SUBounds = ellipsoid(1);
 sys = elltool.linsys.LinSysContinuous(aMat, B, SUBounds);

 x0EllObj = Properties.getAbsTol()*ell_unitball(2);

 firstDirsMat = [-1 -1; 1 0; 0 1; 2 1; 3 1; 1 3; 1 2; -1 1; -2 1; -3 1; -1 3; -1 2]';

 timeVec = [0 6];
 rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, firstDirsMat, timeVec, 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);
 eaEllMat = rsObj.cut(timeVec(end)).get_ea();

    eaEllMat  = inv(eaEllMat');
    approxSize   = size(eaEllMat, 2);
    N   = Properties.getNPlot2dPoints()/2;
    phi = linspace(0, 2*pi, N);
    secondDirsMat   = [cos(phi); sin(phi)];
    yy  = [];
    for i = 1:N
      l    = secondDirsMat(:, i);
      mval = 0;
      for j = 1:approxSize
        Q = parameters(eaEllMat(1, j));
        v = l' * Q * l;
        if v > mval
          mval = v;
        end
      end
      x = l/realsqrt(mval);
      yy = [yy x];
    end
    yy = [timeVec(end)*ones(1, N); yy];


 [xx, tt] = rsObj.get_goodcurves();
 LL       = rsObj.get_directions();
 xx = xx{1};
 xi = [timeVec(end); C*xx(:, end)];






%  clear MM;
% 
%  for i = 1:199
% 	 cla;
%    x0 = C*xx(:, i);
%    X0 = x0 + Properties.getAbsTol()*ell_unitball(2);
%    t0 = tt(i);
%    L0 = [];
%    for j = 1:M
% 	   L = LL{j};
% 	   L0 = [L0 L(:, i)];
%    end
% 
%    rs = elltool.reach.ReachContinuous(s, X0, L0, [t0 T(end)], 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);
%    rs.plotByEa(); hold on;
%    ell_plot(yy, 'r', 'LineWidth', 2);
%    ell_plot(xi, 'ko');
%    ell_plot([t0; x0], 'k*');
%    ell_plot([tt(i:end); C*xx(:, i:end)], 'k');
% 
%    title(sprintf('Reach tube at time T = %d', t0));
%   axis([0 T -40 40 -6 6]);
% 
%    hold off;
% 
%    MM(i) = getframe(h);
%  end
% 
%  movie2avi(MM, 'internal_point.avi', 'QUALITY', 100);
   
