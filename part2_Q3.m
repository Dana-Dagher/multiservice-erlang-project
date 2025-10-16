%% ================================================================
%  PART 2 – Q3 : Voice + Video Calls (CTMC approach)
%  Construct transition matrix Q, solve steady-state equations,
%  compute blocking for both classes, and find λv_max so that
%  Bv, Bs ≤ 1%. Plot Bv and Bs vs λv.
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

% Build feasible state space A = { (ns,nv) | cs*ns + cv*nv <= C }
states=[];
for ns=0:floor(C/cs)
    for nv=0:C
        if cs*ns+cv*nv<=C
            states=[states;ns,nv];
        end
    end
end
N=size(states,1);


% Function: Build Q matrix and blocking masks
function [Q, blockV, blockS]=buildQ(lambda_v, states,C,cv,cs,mu_v,mu_s)
    lambda_s=0.2*lambda_v;
    N=size(states,1);
    Q=sparse(N,N);
    blockV=false(N,1);
    blockS=false(N,1);
    ns_arr=states(:,1);
    nv_arr=states(:,2);

    for k=1:N
        ns=ns_arr(k);
        nv=nv_arr(k);
        used=cs*ns+cv*nv;

        % Voice arrival
        if used+cv<=C
            j=find(ns_arr==ns & nv_arr==nv+1,1);
            Q(k,j)=Q(k,j)+lambda_v;
        else
            blockV(k)=true;
        end

        % Video arrival
        if used+cs<=C
            j=find(ns_arr==ns+1 & nv_arr==nv, 1);
            Q(k,j)=Q(k,j)+lambda_s;
        else
            blockS(k)=true;
        end

        % Voice departure
        if nv>0
            j=find(ns_arr==ns & nv_arr==nv-1, 1);
            Q(k,j)=Q(k,j)+nv*mu_v;
        end

        % Video departure
        if ns>0
            j=find(ns_arr==ns-1 & nv_arr==nv, 1);
            Q(k,j)=Q(k,j)+ns*mu_s;
        end

        % Diagonal element
        Q(k,k)=-sum(Q(k,:));
    end
end


% Function: Compute steady-state distribution from Q
function pi=steady_from_Q(Q)
    N=size(Q,1);
    A=full(Q');
    A(end,:)=1;              
    b=zeros(N,1); 
    b(end)=1;
    pi=A\b;
    pi(pi<0)=0;
    pi=pi/sum(pi);
end

% Test one λv value (for sanity check)
lambda_v_test=0.16;
[Qtest, blockV_test, blockS_test]=buildQ(lambda_v_test,states,C,cv,cs,mu_v,mu_s);
pi_test=steady_from_Q(Qtest);
Bv_test=sum(pi_test(blockV_test));
Bs_test=sum(pi_test(blockS_test));
fprintf('Test λv = %.4f  →  Bv = %.4f,  Bs = %.4f\n',lambda_v_test,Bv_test,Bs_test);

% Bisection to find λv_max (both blockings ≤ 1%)
lo=0.001; hi=0.5; 
tol=1e-5;
for iter=1:60
    mid=(lo+hi)/2;
    [Qmid,bV,bS]=buildQ(mid,states,C,cv,cs,mu_v,mu_s);
    pi_mid=steady_from_Q(Qmid);
    Bv_mid=sum(pi_mid(bV));
    Bs_mid=sum(pi_mid(bS));
    if (Bv_mid<=target) && (Bs_mid<=target)
        lo=mid;  % feasible
    else
        hi =mid;  % too high
    end
    if hi-lo < tol, break; end
end

lambda_v_max=lo;
[Qf,bVf,bSf]=buildQ(lambda_v_max,states,C,cv,cs,mu_v,mu_s);
pif=steady_from_Q(Qf);
Bv_f=sum(pif(bVf));
Bs_f=sum(pif(bSf));

Ev=lambda_v_max/mu_v;           % Erlangs voice
Es=(0.2*lambda_v_max)/mu_s;     % Erlangs video

fprintf('λv_max = %.6f calls/s\n', lambda_v_max);
fprintf('λs_max = %.6f calls/s\n', 0.2*lambda_v_max);
fprintf('Ev = %.3f Erlangs, Es = %.3f Erlangs\n', Ev, Es);
fprintf('Bv = %.5f, Bs = %.5f\n', Bv_f, Bs_f);

% Plot Bv and Bs vs λv (using CTMC)
lambda_values = linspace(0.05, 0.25, 15);
Bv_vals = zeros(size(lambda_values));
Bs_vals = zeros(size(lambda_values));

for i = 1:length(lambda_values)
    [Qtmp, bVtmp, bStmp] = buildQ(lambda_values(i), states, C, cv, cs, mu_v, mu_s);
    pi_tmp = steady_from_Q(Qtmp);
    Bv_vals(i) = sum(pi_tmp(bVtmp));
    Bs_vals(i) = sum(pi_tmp(bStmp));
end

figure;
plot(lambda_values, Bv_vals*100, 'b', 'LineWidth', 1.5, 'DisplayName', 'Voice B_v');
hold on;
plot(lambda_values, Bs_vals*100, 'r', 'LineWidth', 1.5, 'DisplayName', 'Video B_s');
yline(1, 'k:', '1% target');
xlabel('\lambda_v (calls/s)');
ylabel('Blocking probability (%)');
legend('Location', 'northwest');
title('Blocking probability vs \lambda_v (CTMC simulation)');
grid on;
