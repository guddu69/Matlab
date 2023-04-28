
V = {'x1','x2','x3','s1','s2','A1','A2','sol'};
Optimal_V = {'x1','x2','x3','s1','s2','sol'};

OrigC = [-7.5 3 0 0 0 -1 -1 0];
info = [3 -1 -1 -1 0 1 0 3; 1 -1 1 0 -1 0 1 2];
BV = [6 7];

% Phase 1
fprintf('--Phase 1 start-- \n');

cost = [0 0 0 0 0 -1 -1 0]; % cost of 1st phase
% because objective function is z = -A -A
A = info;
startBV = find(cost<0); % define artificial variable

zjcj = cost(BV)*A-cost;
zcj = [zjcj; A];
initialtable = array2table(zcj);
initialtable.Properties.VariableNames(1:size(A,2)) = V

run = true;
while run
    zc = zjcj(1,1:end-1);
    if any(zc<0)
%         entering variable
        [enter_val, pvt_col] = min(zc);
        fprintf('Entering column= %d \n',pvt_col);

%         leaving variable
        sol = A(:,end);
        column = A(:,pvt_col);
        
        if column<=0
            fprintf('Unbounded solution \n');
        else
            for i=1:size(A,1)
                if column(i>0)
                    ratio(i) = sol(i)./column(i);
                else
                    ratio(i) = inf;
                end
            end
            [min_r, pvt_row] = min(ratio);
            fprintf('Leaving variable: %d \n',pvt_row);
        end

%         updae bfs
        BV(pvt_row) = pvt_col;
        pvt_key = A(pvt_row,pvt_col);

%         update table
%         B = A(:,BV);
%         A = inv(B)*A;
%         zjcj = cost(BV)*A-cost;

        A(pvt_row,:) = A(pvt_row,:)./pvt_key;
        % dividing all rows except of min ratio to make BVs identity matrix
        for i=1:size(A,1)
            if i~=pvt_row
                A(i,:) = A(i,:)-A(i,pvt_col).*A(pvt_row,:);
            end
            % dividing zjcj also
            zjcj = zjcj-zjcj(pvt_col).*A(pvt_row,:);
        end

        
%         printing table
        zcj = [zjcj; A];
        table = array2table(zcj);
        table.Properties.VariableNames(1:size(zcj,2)) = V

%         BFS(BV) = A(:,end);




        

        
    else
        run = false;
        fprintf('Optimal solution reached \n');
        fprintf('Phase end \n');
        BFS = BV;
    end
end