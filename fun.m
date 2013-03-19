function f= fun (x,a,b,nu)

% f=(1+x).^(-1./x)-a;
f= (1+exp(-b*x+a)).^(-1/nu);

