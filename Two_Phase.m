C = [-7.5 3 0 0 0 -1 -1 0];
COEFF = [3 -1 -1 -1 0 1 0 3; 1 -1 1 0 -1 0 1 2];
B = [3; 2];
BV = [6 7];

% PHASE-1
fprintf('--PHASE 1 START-- \n');

C_1 = [0 0 0 0 0 -1 -1 0];
COEFF_1 = COEFF;
BV_1 = BV;

% CALCULATING ZjCj
ZjCj = C_1(BV) * COEFF_1 - C_1;

A = [ZjCj; COEFF_1];
Sim_Tab = array2table(A);
Sim_Tab.Properties.VariableNames(1 : size(A, 2)) = {'x_1', 'x_2', 'x_3', 's_1', 's_2', 'a_1', 'a_2', 'Sol'}
% columns of A
LAST = size(A, 2);

RUN = true;
while RUN
    if any(ZjCj < 0)
        fprintf('Current BFS is NOT OPTIMAL\n');
        fprintf('----NEXT ITERNATION----\n');

        disp('Old BV: ');
        disp(BV_1);

        % FINDING ENTERING VARIABLE
        X = ZjCj(1 : size(ZjCj, 2) - 1);
        [min_V, min_Ind] = min(X);

        fprintf('Entering column= %d\n',min_Ind);

        Sol_Col = A(:, LAST);
        Curr_Col = A(:, min_Ind);

        if all(A(:, min_Ind) <= 0)
            error('LPP is Unbounded');
        else
            for i = 1 : size(A, 1)
                if Curr_Col(i) >  0
                    ratio(i) = Sol_Col(i) ./ Curr_Col(i);
                else
                    ratio(i) = Inf;
                end
            end

            % FINDING MIN RATIO
            [min_R_V, min_R_Row] = min(ratio);
            fprintf('Leaving row is= %d\n',min_R_Row);

            BV_1(min_R_Row - 1) = min_Ind;
            disp('New BV: ');
            disp(BV_1);

            % UPADTING THE TABLE
            PVT_V = A(min_R_Row, min_Ind);
            A(min_R_Row, :) = A(min_R_Row, :) ./ PVT_V;

            for i = 1:size(A, 1)
                if i ~= min_R_Row
                    A(i, :) = A(i, :) - A(min_R_Row, :) .* A(i, min_Ind);
                end;
            end
            ZjCj = ZjCj - A(min_R_Row, :) .* X(1, min_Ind);

            % Printing Table
            A(1, :) = ZjCj;
            TAB = A;
            Simp_Tab = array2table(TAB);
            Simp_Tab.Properties.VariableNames(1 : LAST) = {'x_1', 'x_2', 'x_3', 's_1', 's_2', 'a_1', 'a_2', 'Sol'}

            BFS = zeros(1, size(A, 2));
            BFS(BV_1(1)) = TAB(2, LAST);
            BFS(BV_1(2)) = TAB(3, LAST);
            BFS(LAST) = sum(BFS .* C);

            fprintf('--CURRENT BFS--\n')
            BFS_Tab = array2table(BFS);
            BFS_Tab.Properties.VariableNames(1 : LAST) = {'x_1', 'x_2', 'x_3', 's_1', 's_2', 'a_1', 'a_2', 'Sol'}
        end
    else
        RUN = false;
        fprintf('CURRENT BFS IS OPTIMAL\n');
        fprintf('PHASE 1 END\n');

    end
end

fprintf('-PHASE 2 START- \n');

% REMOVING ARTIFICAL VARIABLE
A(:, BV) = [];
C(:, BV) = [];

fprintf('--FINAL BFS--\n')
BFS(:, BV) = [];
BFS_Tab = array2table(BFS);
BFS_Tab.Properties.VariableNames(1 : size(BFS, 2)) = {'x_1', 'x_2', 'x_3', 's_1', 's_2', 'Sol'}
