classdef SimpAllInterpolationImplicit < MaterialInterpolation
    
    methods  (Access = public)
        
        function obj = SimpAllInterpolationImplicit(cParams)
            obj.init(cParams);
            obj.computeNstre();
            switch obj.ndim
                case 2
                    obj = SimpAllInterpolationImplicit2D(cParams);
                case 3
                    obj = SimpAllInterpolationImplicit3D(cParams);
                otherwise
                    error('Invalid problem dimension.');
            end
        end

    end
       
    methods (Access = protected)
        
        function [mS,dmS] = computeMuSymbolicFunctionAndDerivative(obj)
            dmu0     = obj.computeDmu0();
            dmu1     = obj.computeDmu1();
            s.f0     = obj.matProp.mu0;
            s.f1     = obj.matProp.mu1;
            s.df0    = dmu0;
            s.df1    = dmu1;
            [mS,dmS] = obj.computeParameterInterpolationAndDerivative(s);
        end
        
        function [kS,dkS] = computeKappaSymbolicFunctionAndDerivative(obj)
            dk0      = obj.computeDKappa0();
            dk1      = obj.computeDKappa1();
            s.f0     = obj.matProp.kappa0;
            s.f1     = obj.matProp.kappa1;
            s.df0    = dk0;
            s.df1    = dk1;
            [kS,dkS] = obj.computeParameterInterpolationAndDeirvative(s);
        end
        
        function [f,df] = computeParameterInterpolationAndDerivative(obj,s)
            c     = obj.computeCoefficients(s);
            rho   = sym('rho','positive');
            fSym  = obj.rationalFunction(c,rho);
            dfSym = obj.rationalFunctionDerivative(c,rho);
            f     = simplify(fSym);
            df    = simplify(dfSym);
        end
        
        function c = computeCoefficients(obj,s)
            f1    = s.f1;
            f0    = s.f0;
            df1   = s.df1;
            df0   = s.df0;
            c1    = sym('c1','real');
            c2    = sym('c2','real');
            c3    = sym('c3','real');
            c4    = sym('c4','real');
            coef  = [c1 c2 c3 c4];
            r1    = obj.matProp.rho1;
            r0    = obj.matProp.rho0;
            eq(1) = obj.rationalFunction(coef,r1) - f1;
            eq(2) = obj.rationalFunction(coef,r0) - f0;
            eq(3) = obj.rationalFunctionDerivative(coef,r1) - df1;
            eq(4) = obj.rationalFunctionDerivative(coef,r0) - df0;
            c     = solve(eq,[c1,c2,c3,c4]);
            c     = struct2cell(c);
            c     = [c{:}];
        end
        
    end
    
    methods (Access = protected, Static)
        
        function r = rationalFunction(coef,rho)
            c1  = coef(1);
            c2  = coef(2);
            c3  = coef(3);
            c4  = coef(4);
            num = (c1*rho^2 + c2*rho + 1);
            den = (c4 + rho*c3);
            r   = num/den;
        end
        
        function dr = rationalFunctionDerivative(coef,rho)
            c1  = coef(1);
            c2  = coef(2);
            c3  = coef(3);
            c4  = coef(4);
            n1  = c2 + 2*rho*c1;
            d1  = c4 + rho*c3;
            dr1 = n1/d1;
            n2  = -c3*(c1*rho^2 + c2*rho + 1);
            d2  = (c4 + rho*c3)^2;
            dr2 = n2/d2;
            dr  = dr1 + dr2;
        end
        
    end
    
    methods (Access = protected, Abstract)
        computeDmu0(obj)
        computeDmu1(obj)
        computeDKappa0(obj)
        computeDKappa1(obj)
    end
    
end