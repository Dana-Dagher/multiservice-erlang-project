%% ================================================================
%  PART 1 – Q1 : Voice Calls Only (Erlang-B Formula)
%  Compute the blocking probability using the Erlang-B formula
%  for λv ∈ [0.01, 0.5] calls/s, and find λv_max for 1% blocking.
% ================================================================

c=40;            
mu=1/180;      
Pr=0.01;       

lambda=0.01:0.005:0.25;
Bp=zeros(size(lambda));

for i=1:length(lambda)
    s=0;
    for j=0:c
        s=s+(lambda(i)/mu)^j/factorial(j);
    end
    Bp(i)=((lambda(i)/mu)^c)/(factorial(c)*s);
end

figure;
plot(lambda, Bp);
hold on;
yline(Pr,'r','1% target');
xlabel('\lambda_v (calls/s)');
ylabel('Blocking Probability B');
title('Erlang-B Blocking – Voice Only');
grid on;

[~, idx]=min(abs(Bp - Pr));
lambda_v=lambda(idx);
E_v=lambda_v/mu;
fprintf('λv = %.4f calls/s (%.2f Erlangs) for 1%% blocking\n', lambda_v, E_v);
