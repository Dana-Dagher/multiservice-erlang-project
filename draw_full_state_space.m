% ================================================================
% draw_full_state_space.m
% Draw full CTMC state-space for two-class loss system:
% voice uses 1 circuit, video uses 5 circuits, total C = 40.
% States: (ns, nv) with 5*ns + nv <= 40. Colors blocking states red.
% Saves figure to 'ctmc_full_grid.png'.
% ================================================================

C = 40;
cv = 1; cs = 5;
mu_v = 1/180; mu_s = 1/120;
lambda_v_str = '\lambda_v';
lambda_s_str = '\lambda_s';

% Build state list
states = [];
for ns = 0:floor(C/cs)
    for nv = 0:C
        if cs*ns + cv*nv <= C
            states = [states; ns, nv];
        end
    end
end
N = size(states,1);

index = containers.Map();
for k=1:N
    key = sprintf('%d_%d', states(k,1), states(k,2));
    index(key) = k;
end

max_ns = max(states(:,1));

nv_max_per_ns = zeros(max_ns+1,1);
for ns = 0:max_ns
    nv_max_per_ns(ns+1) = floor((C - cs*ns)/cv);
end
X = zeros(N,1);
Y = zeros(N,1);
for k=1:N
    ns = states(k,1); nv = states(k,2);
    X(k) = nv + 1;              
    Y(k) = max_ns - ns + 1;     
end

% Determine blocking states 
is_block = false(N,1);
for k=1:N
    ns = states(k,1); nv = states(k,2);
    if cs*ns + cv*nv == C
        is_block(k) = true;
    end
end

% Plot
figure('Units','normalized','Position',[0.05 0.05 0.9 0.8],'Color','w');
hold on;
axis equal
scale = 1;  
X = X * scale;
Y = Y * scale;

scatter(X(~is_block), Y(~is_block), 220, [0.2 0.6 1], 'filled', 'MarkerEdgeColor', [0 0 0]);
scatter(X(is_block), Y(is_block), 260, [1 0.3 0.3], 'filled', 'MarkerEdgeColor', [0 0 0]);

% Annotate nodes with (ns,nv)
for k=1:N
    ns = states(k,1); nv = states(k,2);
    txt = sprintf('(%d,%d)', ns, nv);
    if is_block(k)
        text(X(k), Y(k), txt, 'HorizontalAlignment','center','VerticalAlignment','middle',...
            'FontSize',8,'FontWeight','bold','Color',[0.2 0.05 0.05]);
    else
        text(X(k), Y(k), txt, 'HorizontalAlignment','center','VerticalAlignment','middle',...
            'FontSize',7,'Color',[0 0 0]);
    end
end

arrowColor = [0 0 0];
for k=1:N
    ns = states(k,1); nv = states(k,2);
    used = cs*ns + cv*nv;
    x0 = X(k); y0 = Y(k);
    % voice arrival -> (ns, nv+1)
    if used + cv <= C
        keyj = sprintf('%d_%d', ns, nv+1);
        j = index(keyj);
        x1 = X(j); y1 = Y(j);
        % draw arrow with small offset to reduce overlap
        drawArrow([x0,y0],[x1,y1], arrowColor, 0.12);
        % optional label: lambda_v near midpoint
        xm = (x0+x1)/2; ym = (y0+y1)/2;
        text(xm, ym+0.08, '\lambda_v','FontSize',7,'HorizontalAlignment','center');
    end
    % voice departure -> (ns, nv-1)
    if nv > 0
        keyj = sprintf('%d_%d', ns, nv-1);
        j = index(keyj);
        x1 = X(j); y1 = Y(j);
        drawArrow([x0,y0],[x1,y1], arrowColor, 0.06);
        xm = (x0+x1)/2; ym = (y0+y1)/2;
        text(xm, ym-0.08, sprintf('%d\\mu_v', nv),'FontSize',7,'HorizontalAlignment','center');
    end
    % video arrival -> (ns+1, nv)
    if used + cs <= C
        keyj = sprintf('%d_%d', ns+1, nv);
        if isKey(index, keyj)
            j = index(keyj);
            x1 = X(j); y1 = Y(j);
            drawArrow([x0,y0],[x1,y1], arrowColor, 0.12);
            xm = (x0+x1)/2; ym = (y0+y1)/2;
            text(xm+0.08, ym, '\lambda_s','FontSize',7,'Rotation',0,'HorizontalAlignment','center');
        end
    end
    % video departure -> (ns-1, nv)
    if ns > 0
        keyj = sprintf('%d_%d', ns-1, nv);
        if isKey(index, keyj)
            j = index(keyj);
            x1 = X(j); y1 = Y(j);
            drawArrow([x0,y0],[x1,y1], arrowColor, 0.06);
            xm = (x0+x1)/2; ym = (y0+y1)/2;
            text(xm-0.08, ym, sprintf('%d\\mu_s', ns),'FontSize',7,'HorizontalAlignment','center');
        end
    end
end

xlim([0.5, max(X)+0.5]); ylim([0.5, max(Y)+0.5]);
xlabel('n_v (voice calls)');
ylabel('n_s (video calls) [inverted axis]');
title('Full CTMC state-space: states (n_s,n_v) with 5n_s + n_v <= 40','FontSize',12);
set(gca,'XTick',0:5:max(X),'YTick',1:max(Y),'YDir','normal');

% Legend
h1 = scatter(-10,-10,140,[0.2 0.6 1],'filled');
h2 = scatter(-10,-10,160,[1 0.4 0.4],'filled');
legend([h1,h2],{'Normal states','Blocking states'},'Location','northeastoutside');

xlim([-1, max(X)+1]);
ylim([-1, max(Y)+1]);

% Save PNG
set(gcf,'Position',[100,100,1500,900]);
print(gcf,'ctmc_full_grid.png','-dpng','-r600');
fprintf('Saved figure to ctmc_full_grid.png\n');

function drawArrow(p0,p1,color,shrink)
    v = p1 - p0;
    L = norm(v);
    if L==0, return; end
    p0s = p0 + (shrink)*v;
    p1s = p1 - (shrink)*v;
    quiver(p0s(1),p0s(2),p1s(1)-p0s(1),p1s(2)-p0s(2),0,'Color',color,'MaxHeadSize',0.5,'LineWidth',0.8);
end
