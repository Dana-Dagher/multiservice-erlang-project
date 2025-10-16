%% ================================================================
%  PART 1 – Q2 : Voice Calls Only (CTMC approach)
%  Construct the transition matrix Q of the CTMC,
%  solve the steady-state probabilities numerically,
%  and compute the blocking rate.
% ================================================================

c=40;
mu=1/180;      
lambda=0.16;  
E=lambda / mu;   

Q=zeros(c+1);

for i=1:c+1
    if i>1
        Q(i,i-1)=(i-1)*mu; 
    end
    if i<=c
        Q(i,i+1)=lambda; 
    end
    Q(i,i)=-sum(Q(i,:));   
end

A=Q';
A(end,:)=1;         
b=zeros(c+1,1);
b(end)=1;
pi=A\b;          

B_matrix=pi(end);
B_erlang=0.01;

fprintf('Blocking from matrix Q = %.6f\n',B_matrix);
fprintf('Blocking from Erlang-B = %.6f\n',B_erlang);
fprintf('Difference = %.6e\n',abs(B_matrix-B_erlang));
