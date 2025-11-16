function get_cfe()
  % This tool calculates CFE quotients for N(s)/D(s).
  % It asks for N, D, and the division type (FD or RD).
  % It automatically inverts if the function is improper
  % and formats the output with the correct leading quotient.
  % It then asks if the user wants to run the other form.
  % It requires the Octave Symbolic package.

  try
    pkg load symbolic
  catch
    error("the 'symbolic' package is required. please install it using command : pkg install -forge symbolic");
  end_try_catch

  s = sym('s');

  printf("========================================\n");
  printf("Symbolic CFE Calculator (FD/RD)\n");
  printf("========================================\n");

  printf("\n--- Enter Numerator N(s) ---\n");
  N_base = get_poly_from_user("Numerator", s);

  printf("\n--- Enter Denominator D(s) ---\n");
  D_base = get_poly_from_user("Denominator", s);

  printf("\nYour base function is: F(s) = N(s) / D(s)\n");
  printf("  N(s) = %s\n", char(N_base));
  printf("  D(s) = %s\n", char(D_base));
  printf("----------------------------------------\n");

  printf("\nSelect Division Type to run first:\n");
  printf("  1. Forward Division (at s=infinity)\n");
  printf("  2. Reverse Division (at s=0)\n");
  div_choice = input("Enter choice (1 or 2): ");

  printf("========================================\n");

  other_choice = 0;
  other_name = "";

  if div_choice == 1
      do_fd(N_base, D_base, s);
      other_choice = 2;
      other_name = "Reverse Division";
  elseif div_choice == 2
      do_rd(N_base, D_base, s);
      other_choice = 1;
      other_name = "Forward Division";
  else
      error("Invalid selection.");
  endif

  printf("========================================\n");
  prompt_str = sprintf("Do you also want to run %s? (y/n): ", other_name);
  run_other = input(prompt_str, "s");

  if lower(strtrim(run_other)) == "y"
      if other_choice == 1
          do_fd(N_base, D_base, s);
      elseif other_choice == 2
          do_rd(N_base, D_base, s);
      endif
  endif

  printf("========================================\n");
  printf("All calculations complete.\n");
  printf("========================================\n");

end


% -----------------------------------------------------------------
% FD LOGIC
% -----------------------------------------------------------------

function do_fd(N_base, D_base, s)
    printf("\n--- Running Forward Division ---\n");

    if degree(N_base, s) >= degree(D_base, s)
        printf("  Function is proper at s=inf. Expanding N/D.\n");
        [element_values] = run_cfe_forward_general(N_base, D_base, s);
        has_leading_quotient = true;
    else
        printf("  Function is improper at s=inf. Expanding D/N.\n");
        [element_values] = run_cfe_forward_general(D_base, N_base, s);
        has_leading_quotient = false;
    endif

    print_quotients(element_values, has_leading_quotient);
end


% -----------------------------------------------------------------
% RD LOGIC — UPDATED FULLY
% -----------------------------------------------------------------

function do_rd(N_base, D_base, s)
    printf("\n--- Running Reverse Division ---\n");

    % RD always starts with D/N
    printf("  RD initial step: start with D/N automatically.\n");

    [element_values, has_leading] = run_cfe_reverse_general(D_base, N_base, s, true);

    print_quotients(element_values, has_leading);
end



% -----------------------------------------------------------------
% PRINT
% -----------------------------------------------------------------

function print_quotients(element_values, has_leading)
    printf("\n--- Final Quotients ---\n");

    if isempty(element_values)
        printf("Q = [ ]\n");
        return;
    endif

    printf("Q = [ ");
    if has_leading
        printf("%s; ", char(element_values{1}));
        for i = 2:length(element_values)
            printf("%s", char(element_values{i}));
            if i < length(element_values)
                printf(", ");
            endif
        endfor
    else
        printf("; ");
        for i = 1:length(element_values)
            printf("%s", char(element_values{i}));
            if i < length(element_values)
                printf(", ");
            endif
        endfor
    endif
    printf(" ]\n");
end


% -----------------------------------------------------------------
% USER INPUT
% -----------------------------------------------------------------

function [p_sym] = get_poly_from_user(poly_name, s)
  p_sym = sym(0);
  prompt_deg = sprintf("Enter highest degree for %s: ", poly_name);
  highestDegreeStr = input(prompt_deg, "s");
  highestDegree = str2double(highestDegreeStr);

  if isnan(highestDegree) || highestDegree < 0
    error("Invalid degree. Must be a positive number.");
  endif

  printf("Enter coefficients for %s: \n", poly_name);
  for i = highestDegree:-1:0
    promptStr = sprintf("  Enter coefficient for s^%d: ", i);
    validInput = false;
    while ~validInput
      coeffStr = input(promptStr, "s");
      if isempty(strtrim(coeffStr))
        printf("  -> invalid input, please enter a number\n");
        continue;
      endif
      try
        coeffSym = sym(coeffStr);
        vars = symvar(coeffSym);
        if ~isempty(vars)
          error('Input should be a constant not variable');
        endif
        validInput = true;
      catch
        printf("  -> Invalid input, please enter a number \n");
      end_try_catch
    endwhile
    p_sym = p_sym + coeffSym*s^i;
  endfor
  p_sym = simplify(p_sym);
end


% -----------------------------------------------------------------
% Forward CFE
% -----------------------------------------------------------------

function [element_values] = run_cfe_forward_general(num_poly, den_poly, s)
  element_values = {};
  iteration = 1;
  printf("  Running iterations...\n");
  while den_poly ~= 0
    if num_poly == 0, break; endif
    deg_N = degree(num_poly, s);
    deg_D = degree(den_poly, s);

    if deg_N == deg_D
        [c_N, ~] = coeffs(num_poly, s);
        [c_D, ~] = coeffs(den_poly, s);
        q_value = c_N(1) / c_D(1);
        q_poly = q_value;

    elseif deg_N == deg_D + 1
        [c_N, ~] = coeffs(num_poly, s);
        [c_D, ~] = coeffs(den_poly, s);
        q_value = c_N(1) / c_D(1);
        q_poly = q_value * s;

    else
        printf("  Stopping: deg(N) < deg(D) or form invalid.\n");
        break;
    endif

    r_poly = simplify(num_poly - q_poly * den_poly);
    element_values{end+1} = q_poly;
    num_poly = den_poly;
    den_poly = r_poly;

    iteration++;
    if iteration > 20, break; endif
  endwhile
  printf("  ...Iterations complete.\n");
end


% -----------------------------------------------------------------
% Reverse CFE — FINAL UPDATED LOGIC
% -----------------------------------------------------------------

function [element_values, has_leading] = run_cfe_reverse_general(num_poly, den_poly, s, is_first_iteration)

    element_values = {};
    iteration = 1;
    has_leading = false;

    printf("  Running iterations...\n");

    while den_poly ~= 0

        if num_poly == 0, break; endif

        % Factor out powers of s (RD logic)
        [k_N, N_new] = factor_out_s(num_poly, s);
        [k_D, D_new] = factor_out_s(den_poly, s);

        low_N_coeff = subs(N_new, s, 0);
        low_D_coeff = subs(D_new, s, 0);

        % If denominator low-order coefficient is zero -> invalid.
        if low_D_coeff == 0
            if is_first_iteration
                printf("  First-iteration: denominator low-order coefficient is zero -> switching to N/D.\n");
                has_leading = true;
                [rest_values, ~] = run_cfe_reverse_general(den_poly, num_poly, s, false);
                element_values = rest_values;
                return;
            else
                printf("\n  Stopping: Division by zero.\n");
                break;
            endif
        endif

        % RD quotient detection: allowed forms are k_N == k_D (constant)
        % or k_D == k_N + 1 (1/s term). Otherwise invalid for RD.
        if k_N == k_D
            q_value = low_N_coeff / low_D_coeff;
            q_poly = q_value;

        elseif k_D == k_N + 1
            q_value = low_N_coeff / low_D_coeff;
            q_poly = q_value / s;

        else
            % invalid form at s=0
            if is_first_iteration
                printf("  First-iteration: invalid RD form -> switching to N/D.\n");
                has_leading = true;
                [rest_values, ~] = run_cfe_reverse_general(den_poly, num_poly, s, false);
                element_values = rest_values;
                return;
            else
                printf("  Stopping: invalid form at s=0.\n");
                break;
            endif
        endif

        % Compute remainder
        r_poly = simplify(num_poly - q_poly * den_poly);

        % ------------------------------------------------------------------
        % If first iteration and remainder has ANY negative numeric coefficient
        % then switch to N/D but preserve the quotient we just computed
        % ------------------------------------------------------------------
        try
            c_list = coeffs(r_poly);
            % convert to double where possible; filter out non-numeric gracefully
            numeric_flags = false(1,length(c_list));
            numeric_vals = zeros(1,length(c_list));
            for ii = 1:length(c_list)
                try
                    numeric_vals(ii) = double(c_list(ii));
                    numeric_flags(ii) = true;
                catch
                    numeric_flags(ii) = false;
                end_try_catch
            endfor
            % consider only numeric coefficients when checking negativity
            if any(numeric_flags)
                if any(numeric_vals(numeric_flags) < 0) && is_first_iteration
                    printf("  First-iteration: remainder has negative coefficient(s) -> switching to N/D (preserving current quotient).\n");
                    has_leading = true;
                    [rest_values, ~] = run_cfe_reverse_general(den_poly, num_poly, s, false);
                    % prepend current q_poly
                    element_values = [{q_poly}, rest_values];
                    return;
                endif
            end
        catch
            % if coeffs() or double() failed, conservatively do nothing
        end_try_catch
        % ------------------------------------------------------------------

        % Accept quotient
        element_values{end+1} = q_poly;

        % Advance
        num_poly = den_poly;
        den_poly = r_poly;

        iteration++;
        is_first_iteration = false;
        if iteration > 200
            printf("  Reached iteration limit; stopping.\n");
            break;
        endif

    endwhile

    printf("  ...Iterations complete.\n");
end


% -----------------------------------------------------------------
% Helper
% -----------------------------------------------------------------

function out = is_negative_polynomial(p)
    c = coeffs(p);
    out = all(double(c) < 0);
end

function [k, P_new] = factor_out_s(P, s)
    k = 0;
    P_new = P;
    if P == 0, return; endif
    while (subs(P_new, s, 0) == 0)
        P_new = simplify(P_new / s);
        k = k + 1;
        if P_new == 0, break; endif
    endwhile
end

