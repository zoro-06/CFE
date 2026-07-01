function result = pr_check(num, den)
% PR_CHECK  Test whether F(p)=num/den is positive real.
% Returns:  result = 1 (PR), 0 (not PR).

  result = 1;  % assume PR until proven otherwise

  %% --- Stage 1: Hurwitz test via Routh array ---
  n  = length(den) - 1;       % degree of denominator
  if any(den <= 0)             % quick sign check
    fprintf('PR CHECK FAILED: denominator has non-positive coefficients.\n');
    result = 0;  return;
  end

  % Build Routh array
  r = zeros(n+1, ceil((n+1)/2));
  r(1,:) = den(1:2:end);
  if n >= 1
    r(2,1:floor(n/2)+1) = den(2:2:end);
  end
  for i = 3:n+1
    for j = 1:size(r,2)-1
      if r(i-1,1) == 0
        fprintf('PR CHECK FAILED: Routh row is zero (D(p) not Hurwitz).\n');
        result = 0; return;
      end
      r(i,j) = (r(i-1,1)*r(i-2,j+1) - r(i-2,1)*r(i-1,j+1)) / r(i-1,1);
    end
  end
  if any(r(:,1) <= 0)
    fprintf('PR CHECK FAILED: D(p) is not Hurwitz.\n');
    result = 0; return;
  end

  %% --- Stage 2: Re[F(jw)] >= 0 ---
  w   = logspace(-3, 6, 10000);
  jw  = 1i*w;
  Fjw = polyval(num, jw) ./ polyval(den, jw);
  if any(real(Fjw) < -1e-9)
    fprintf('PR CHECK FAILED: Re[F(jw)] < 0 for some w.\n');
    result = 0; return;
  end
  fprintf('PR CHECK PASSED: F(p) is positive real.\n');
end
