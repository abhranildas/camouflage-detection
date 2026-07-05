function nll = hyperexp_nll(x,lambda)
    % log likelihood of a set of numbers under 
    % the hyperexponential distribution
    % (sum of two exponential variables).
    % lambda(2) > lambda(1) > 0
    n=numel(x);
    nll=-n*log(lambda(1)*lambda(2)/(lambda(2)-lambda(1)))-...
        sum(log(exp(-lambda(1)*x)-exp(-lambda(2)*x)));
