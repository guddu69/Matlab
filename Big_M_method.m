% Big-M method
% function should be of maximization

V = {'x1','x2','s2','s3','A1','A2','sol'};
M = 1000; % very large value
cost = [-2 -1 0 0 -M -M 0];

A = [3 1 0 0 1 0 3;
    4 3 -1 0 0 1 6;
    1 2 0 1 0 0 3];

s = eye(size(A,1));

% BV = [5 6 4]
% calculating basic variables using identity matrix
BV = [];
for j=1:size(s,2)
    for i=1:size(A,2)
        if A(:,i)==s(:,j)
            BV = [BV i];
        end
    end
end

zjcj = cost(BV)*A-cost;
zcj = [zjcj ; A];
% printing table
simptable = array2table(zcj);
simptable.Properties.VariableNames(1:size(zcj,2)) = V

run = true;
while run

    zc = zjcj(:,1:end-1); % end-1 because we dont want column of sol

    if any (zc<0)
        fprintf('----Not optimal----- \n');
        fprintf('----Next iteration-- \n');
        disp('Old BV: ');
        disp(BV);

        %     entering variable
        [enter_val, pvt_col] = min(zc);
        fprintf('Entering column= %d \n',pvt_col);

        %     leaving variable
        sol = A(:,end);
        column = A(:,pvt_col);

        if all (column<=0)
            fprintf('----Sol is unbounded---- \n');
        else
            %         finding min ratio
            for i=1:size(column,1)
                if column(i)>0
                    ratio(i) = sol(i)./column(i);
                else
                    ratio(i) = inf;
                end
            end

            [min_r, pvt_row] = min(ratio);
            fprintf('Leaving variable= %d \n',pvt_row);

            %         update BV
            BV(pvt_row) = pvt_col;
            disp('New BV: ');
            disp(BV);

            %             update table

            B = A(:,BV);
            A = inv(B)*A;
            zjcj = cost(BV)*A-cost;

            % -- iterations of tables--

            %         printing sol table
            zcj = [zjcj;A];
            table = array2table(zcj);
            table.Properties.VariableNames(1:size(zcj,2)) = V

            %             printing basic fiseable sol
            BFS = zeros(1,size(A,2));
            BFS(BV) = A(:,end);
            BFS(end) = sum(BFS.*cost);
            current_bfs = array2table(BFS);
            current_bfs.Properties.VariableNames(1:size(current_bfs,2)) = V
        end
    else
        run = false;
        fprintf('----The current BFS is optimal---- \n');
    end
end