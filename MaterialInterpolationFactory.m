classdef MaterialInterpolationFactory < handle
    
    methods (Access = public, Static)
               
        function obj = create(cParams)          
            switch cParams.typeOfMaterial
                case 'ISOTROPIC'
                    switch cParams.interpolation
                        case 'SIMPALL'
                            if ~isfield(cParams,'simpAllType')
                                cParams.simpAllType = 'EXPLICIT';
                            end                                    
                            switch cParams.simpAllType
                                case 'EXPLICIT'
                                    obj = SimpAllInterpolationExplicit(cParams);
                                case 'IMPLICIT'
                                    obj = SimpAllInterpolationImplicit(cParams);
                                otherwise
                                    error('Invalid SimpAll type');
                            end
                        case 'SIMP_Adaptative'
                            obj = SimpInterpolationAdaptative(cParams);
                        case 'SIMP_P3'
                            obj = SimpInterpolationP3(cParams);
                        otherwise
                            error('Invalid Material Interpolation method.');
                    end
                otherwise
                    error('Invalid type of material');
            end
            
        end
            
    end
    
end