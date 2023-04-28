% nov = number of variables
nov = 3;
% c = cost
c = [-1 3 -2 0 0 0 0];
info = [3 -1 2; -2 4 0; -4 3 8];
b = [7; 12; 10];

% s = surplus matrix
s = eye(size(info,1));
A = [info s b];

% BV = basic variables
BV = nov+1:size(A,2)-1 ;

zjcj = c(BV)*A-c;
zcj = [zjcj;A];

simptable = array2table(zcj);
simptable.Properties.VariableNames(1:size(zcj,2)) = {'x1','x2','x3','s1','s2','s3','sol'}

run=true;
while run
    if any(zjcj<0)
        fprintf('------Not optimal------ \n');
        fprintf('------Next iteration--- \n');

        disp('Old BV: ');
        disp(BV);

        zc = zjcj(1:end-1);
        [enter_col,pvt_col] = min(zc);
        % enter_col = value, pvt_col= index
        fprintf('Entering column: %d \n', pvt_col);

        sol = A(:,end);
        column = A(:,pvt_col);

        if all(column<=0)
            fprintf('Unbounded solution \n');
        else
            % minimum ratio calculation only for positive values in column
            for i = 1:size(column,1)
                if column(i)>0
                    ratio(i) = sol(i)./column(i);
                else
                    ratio(i) = inf;
                    % inf so that min ratio should not be this by mistake
                end
            end
            [min_ratio, pvt_row] = min(ratio);
            fprintf('Leaving variable: %d \n',BV(pvt_row));
        end
        % ----next iteration---
        % changing BVs
        BV(pvt_row) = pvt_col;
        disp('New BV: ');
        disp(BV);

        pvt_key = A(pvt_row,pvt_col);

        % dividing row of min ratio
        A(pvt_row,:) = A(pvt_row,:)./pvt_key;
        % dividing all rows except of min ratio to make BVs identity matrix
        for i=1:size(A,1)
            if i~=pvt_row
                A(i,:) = A(i,:)-A(i,pvt_col).*A(pvt_row,:);
            end
            % dividing zjcj also
            zjcj = zjcj-zjcj(pvt_col).*A(pvt_row,:);
        end
        % --iterations--
        zcj = [zjcj;A];
        simptable = array2table(zcj);
        simptable.Properties.VariableNames(1:size(zcj,2)) = {'x1','x2','x3','s1','s2','s3','sol'}

        % --- Values ---- (current fisiable solution)
        BFS = zeros(1,size(A,2));
        BFS(BV) = A(:,end);
        BFS(end) = sum(BFS.*c);
        current_bfs = array2table(BFS);
        current_bfs.Properties.VariableNames(1:size(current_bfs,2)) = {'x1','x2','x3','s1','s2','s3','sol'}

    else
        run=false;
        fprintf('----------Current BFS is Optimal---------- \n');
    end
end
