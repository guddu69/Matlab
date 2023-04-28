C = [-2 0 -1 0 0 0];
COEFF = [-1 -1 1 1 0 -5;
    -1 2 -4 0 1 -8];
V = {'x_1', 'x_2', 'x_3', 's_1', 's_2', 'Sol'};
% FINDING BASIC VARIABLES
S = eye(2);
BV = [];
for i = 1 : size(S, 2)
    for j = 1 : size(COEFF, 2)
        if COEFF(:, j) == S(:, i)
            BV = [BV j];
        end
    end
end

% CALCULATE Zj - Cj
ZjCj = C(BV) * COEFF - C;
LAST = size(COEFF, 2);

% PRINT TABLE
TAB = [ZjCj ; COEFF];
Simp_Tab = array2table(TAB);
Simp_Tab.Properties.VariableNames(1 : LAST) = V

fprintf('BASIC VARIABLES:');
disp(BV);

RUN = true;
while RUN
    if any(COEFF(:, LAST) < 0)
        fprintf('--NOT FEASIBLE-- \n');

        %   FINDING LEAVING VARIABLE
        [MIN_R_V, MIN_R_IND] = min(COEFF(:, LAST));
        fprintf('LEAVING ROW: %d\n', MIN_R_IND);

        %   FINDING ENTERING VARIABLE
        PVT_ROW = COEFF(MIN_R_IND, 1 : LAST - 1);
        ZJ = ZjCj(1 : LAST - 1);

        for i = 1 : LAST - 1
            if PVT_ROW(i) < 0
                ratio(i) = abs(ZJ(i) ./ PVT_ROW(i));
            else
                ratio(i) = Inf;
            end
        end
        [MIN_C_V, MIN_C_IND] = min(ratio);
        fprintf('ENTERING COLUMN: %d\n', MIN_C_IND);

        %   UPDATING BASIC VARIABLE
        BV(MIN_R_IND) = MIN_C_IND;
        fprintf('NEW BASIC VARIABLES: ');
        disp(BV);

        %   UPDATING TABLE
        PVT_V = COEFF(MIN_R_IND, MIN_C_IND);

        COEFF(MIN_R_IND, :) = COEFF(MIN_R_IND, :) / PVT_V;
        for i = 1 : size(COEFF, 1)
            if i ~= MIN_R_IND
                COEFF(i, :) = COEFF(i, :) - COEFF(i, MIN_C_IND) * COEFF(MIN_R_IND, :);
            end
        end
        ZjCj = C(BV) * COEFF - C;
        TAB = [ZjCj ; COEFF]
        Simp_Tab = array2table(TAB);
        Simp_Tab.Properties.VariableNames(1 : LAST) = V

    else
        RUN = false;
        fprintf('--FEASIBLE & OPTIMAL--\n');

        BFS = zeros(1, size(TAB, 2) - 1);
        BFS(BV) = TAB(2 : size(TAB, 1), LAST);
        Sol = TAB(1, LAST);
        BFS = [BFS Sol];

        BFS_Tab = array2table(BFS);
        BFS_Tab.Properties.VariableNames(1 : LAST) = V
    end
end