function [frs, Frs] = computeGRD(rstest, b, rmin)
% computeGRD: This function computes the probability of an r_s-sized source
% based on the GRD with b given.

    if nargin < 3
        rmin = min(rstest); 
    end
    ind = round(rstest, 5) < round(rmin, 5); 
    
    alpha = (2*b);   
    lf = log(alpha) + alpha*log(rmin) - (alpha+1)*log(rstest); 
    frs = exp(lf); 
    frs(ind) = 0; 
    Frs = 1 - ((rstest./rmin).^(-alpha)); 
    frs = frs(:); 
    Frs = Frs(:); 
end