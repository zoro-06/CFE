function get_CFE1(n,d)

pi = 3.141592653589793;
N = n;
D = d;

tol = 1e-10; 

max_len = max(size(n)(2),size(d)(2));

pkg load symbolic
syms p

% STORAGE FOR FINAL OUTPUT
quotients = {}; 

prev = 0;

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
        
        % Store 0 in the list if necessary, or just skip
        % swap and continue, no quotient generated here
        prev = prev + 1;
        temp = N;
        N = D;
        D = temp;
        continue;
    end

    % prev = 0;
    poly_sym = poly2sym(q, p);
    
    % Store the symbolic quotient for final array printing
    quotients{end+1} = char(poly_sym);

    disp(poly_sym)
    fprintf("_____________________________________________________________________\n");

        
    if isempty(first_nonzero)
        break;
    end
    N = D;
    D = r(first_nonzero:end);

endwhile

% --- FINAL ARRAY PRINTING LOGIC ---
fprintf("\nPartial Quotients Array:\n[ ");
if length(quotients) > 0
    % Print first element
    fprintf("%s", quotients{1});
    
    % If there are more elements, print semicolon then iterate with commas
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