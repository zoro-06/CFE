function get_CFE2(n,d)

N = n;
D = d;
max_len = max(length(N), length(D));

N = [zeros(1, max_len - length(N)) , N];
D = [zeros(1, max_len - length(D)) , D];

tol = 1e-10; 

pkg load symbolic
syms p  % The actual variable we want to see (p)
syms x  % A temporary dummy variable for calculation

N = N(end:-1:1);
D = D(end:-1:1);

% STORAGE FOR FINAL OUTPUT
quotients = {};

prev = 0;

if any(N)
    N = N(find(N, 1, 'first'):end);
else
    N = 0; 
end

if any(D)
    D = D(find(D, 1, 'first'):end);
else
    D = 0; 
end


while prev < 2*max_len
    q = deconv(N,D);
    q(2:end) = 0;

    P = conv(D, q);

    len_diff = length(P) - length(N);

    if len_diff > 0
        r = [zeros(1, len_diff), N] - P;
    elseif len_diff < 0
        r = N - [zeros(1, -len_diff), P];
    else
        r = N - P;
    end

    first_nonzero = find(r,1);

    if (r(first_nonzero)*D(1) < 0) 
        fprintf("0 quotient\n")
        prev = prev + 1;
        temp = N;
        N = D;
        D = temp;
        continue;
    end
   
    poly_temp = poly2sym(q, x);
    
    % Mathematically substitute x = 1/p
    
    real_sym = subs(poly_temp, x, 1/p);
    
    % Store and display the clean result
    quotients{end+1} = char(real_sym);
    disp(real_sym);
    
    fprintf("____________________________________________________________\n");

    if isempty(first_nonzero)
        break;
    end
    N = D;
    D = r(first_nonzero:end);

endwhile

% --- FINAL ARRAY PRINTING LOGIC ---
fprintf("\nPartial Quotients Array:\n[ ");
if length(quotients) > 0
    fprintf("%s", quotients{1});
    if length(quotients) > 1
        fprintf(" ; ");
        for k = 2:length(quotients)
            fprintf("%s", quotients{k});
            if k < length(quotients)
                fprintf(" , ");
            end
        end
    end
end
fprintf(" ]\n");

endfunction