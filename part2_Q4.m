%% ================================================================
%  PART 2 – Q4 : Analytical (Multi-Erlang Product-Form)
%  Compute steady-state probabilities analytically using
%  the multi-Erlang formula, derive blocking rates for both
%  classes, and compare with Q3 (CTMC results).
% ================================================================

C=40;          
cv=1;        
cs=5;          
Tv=180;      
Ts=120;         
mu_v=1/Tv;      
mu_s=1/Ts;      
target=0.01;   
ratio=0.2;   

% Function: Compute blocking from product-form formula
function [Bv, Bs] = blockingProb(lambda_v, C, cv, cs, mu_v, mu_s, ratio)
    lambda_s = ratio * lambda_v;
    
    % Build all valid states (ns, nv)
    states=[];
    for ns=0:floor(C/cs)
        for nv=0:C
            if cs*ns+cv*nv<=C
                states=[states;ns,nv];
            end
        end
    end
    N=size(states,1);
    
    % Unnormalized steady-state probabilities (product-form)
    pi=zeros(N,1);
    for k=1:N
        ns=states(k,1);
        nv=states(k,2);
        pi(k)=((lambda_v/mu_v)^nv / factorial(nv)) * ((lambda_s/mu_s)^ns / factorial(ns));
    end
    
    % Normalize
    G=sum(pi);
    pi=pi/G;
    
    % Blocking probabilities
    % Voice blocked if adding 1 circuit exceeds capacity
    Bv=sum(pi(cs*states(:,1)+cv*states(:,2)>C-cv));
    % Video blocked if adding 5 circuits exceeds capacity
    Bs=sum(pi(cs*states(:,1)+cv*states(:,2)>C-cs));
end

% Bisection to find λv_max (both Bv,Bs ≤ 1%)
low=0; high=0.2; tol=1e-6;
for i=1:40
    mid=(low + high)/2;
    [Bv,Bs]=blockingProb(mid, C, cv, cs, mu_v, mu_s, ratio);
    if Bv<=target && Bs<=target
        low=mid; % feasible
    else
        high=mid;% too high
    end
    if (high-low) < tol, break; end
end

lambda_v_max=low;
[Bv_final, Bs_final]=blockingProb(lambda_v_max, C, cv, cs, mu_v, mu_s, ratio);

Ev=lambda_v_max / mu_v;% Erlangs voice
Es=(ratio * lambda_v_max)/mu_s; % Erlangs video

fprintf('\n=== PART 2 – Q4 : Analytical Multi-Erlang ===\n');
fprintf('λv_max = %.6f calls/s\n', lambda_v_max);
fprintf('λs_max = %.6f calls/s\n', ratio * lambda_v_max);
fprintf('Ev = %.3f Erlangs, Es = %.3f Erlangs\n', Ev, Es);
fprintf('Bv = %.5f, Bs = %.5f\n', Bv_final, Bs_final);

% Plot Bv and Bs vs λv
lambda_values=linspace(0.05, 0.25, 40);
Bv_vals=zeros(size(lambda_values));
Bs_vals=zeros(size(lambda_values));

for i=1:length(lambda_values)
    [Bv_vals(i), Bs_vals(i)]=blockingProb(lambda_values(i), C, cv, cs, mu_v, mu_s, ratio);
end

figure;
plot(lambda_values, Bv_vals*100, 'b', 'LineWidth', 1.5, 'DisplayName', 'Voice B_v');
hold on;
plot(lambda_values, Bs_vals*100, 'r', 'LineWidth', 1.5, 'DisplayName', 'Video B_s');
yline(1, 'k:', '1% target');
xlabel('\lambda_v (calls/s)');
ylabel('Blocking probability (%)');
legend('Location','northwest');
title('PART 2 – Q4 : Analytical Multi-Erlang Blocking');
grid on;
