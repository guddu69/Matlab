% least_cost_method of transportation problem

% BALANCED
% cost = [2 7 4; 3 3 1; 5 5 4; 1 6 2];
% A = [5 8 7 14];
% B = [7 9 18];

% UNBALANCED
cost = [11 20 7 8; 21 16 10 12; 8 12 18 9];
A = [50 40 70];  % rows
B = [30 25 35 40];  % columns

% checking Balanced / Unbalanced
if sum(A)==sum(B)

    fprintf('The problem is Balanced \n');

else
    fprintf('The problem is Unblanced \n');

    if sum(A)<sum(B)
        cost(end+1,:) = zeros(1,size(A,1)); % add row
        A(end+1) = sum(B)-sum(A);
    elseif sum(A)>sum(B)
        cost(:,end+1) = zeros(1,size(A,2)); % add column
        B(end+1) = sum(A)-sum(B);
    end

end

icost = cost; % save the cost copy
X = zeros(size(cost)); % initilize allocation
[m,n] = size(cost); % finding rows and columns
BFS = m+n-1; % total BFS

for i=1:size(cost,1) % row loop
    for j=1:size(cost,2) % column loop

        hh = min(cost(:));  % finding min cost value
        [row_ind,col_ind] = find(hh==cost);

        x11 = min(A(row_ind),B(col_ind));
        [val,ind] = max(x11);  % finding max allocation

        ii = row_ind(ind);  % identify row position
        jj = col_ind(ind);  % identify column position

        y11 = min(A(ii),B(jj));  % find the value
        X(ii,jj) = y11;  % assign the allocation

        A(ii) = A(ii) - y11;  % reduce row value
        B(jj) = B(jj) - y11;  % reduce column value

        cost(ii,jj) = inf;  % cell covered
    end
end

% print initial bfs
fprintf('Initial BFS = \n');
IB = array2table(X);
disp(IB);

% check degenerate or non-degenerate
totalBFS = length(nonzeros(X));
if totalBFS == BFS
    fprintf('initial BFS is Non-degenerate \n');
else
    fprintf('initial BFS is Degenerate \n');
end

% compute initial transportation cost
initialcost = sum(sum(icost.*X));
fprintf('Initial BFS cost: %d \n',initialcost);
