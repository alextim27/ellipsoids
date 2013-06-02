classdef EllTube < gras.ellapx.smartdb.rels.AEllTube & ...
        gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel
    %
    methods (Access=protected)
        function changeDataPostHook(self)
            self.checkDataConsistency();
        end
    end
    %
    methods
        function self=EllTube(varargin)
            self=self@gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel(...
                varargin{:});
        end
    end
end

