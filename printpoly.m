function printpoly(n)

pkg load symbolic
syms p
poly_sym = poly2sym(n, p);
disp(poly_sym)

end