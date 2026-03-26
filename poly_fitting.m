% poly_fitting.m - Fixed version (centered/scaled + compatible plotting)

clear; clc; close all;

rng(42);  % reproducibility

% Data
x_train = linspace(0, 1, 50)';
y_true  = sin(2*pi*x_train);
y_train = y_true + 0.2*randn(size(x_train));

x_val   = linspace(0, 1, 100)';
y_val   = sin(2*pi*x_val) + 0.2*randn(size(x_val));

max_degree = 15;
train_errors = zeros(max_degree,1);
val_errors   = zeros(max_degree,1);

% ???????????????? First figure: data + some fits ????????????????
figure('Color','w');
hold on;

plot(x_train, y_train, 'bo', 'MarkerSize',6, 'DisplayName','Training data');
plot(x_val,   sin(2*pi*x_val), 'g-', 'LineWidth',2.2, 'DisplayName','True function');

xlabel('x'); ylabel('y');
title('Polynomial Fits – Various Degrees');
grid on;
legend('show','Location','best');

% We'll store centered/scaled polynomials
p_cell = cell(max_degree,1);

for d = 1:max_degree
    % === This is the important fix for conditioning ===
    [p, S, mu] = polyfit(x_train, y_train, d);   % mu = [mean(X) std(X)]
    
    p_cell{d} = p;  % save if needed later
    
    % Predict using centered & scaled version
    y_train_pred = polyval(p, x_train, S, mu);
    y_val_pred   = polyval(p, x_val,   S, mu);
    
    train_errors(d) = mean((y_train - y_train_pred).^2);
    val_errors(d)   = mean((y_val   - y_val_pred).^2);
    
    % Plot a few nice-looking ones
    if ismember(d, [1 3 7 10])
        plot(x_val, y_val_pred, '--', 'LineWidth',1.5, ...
             'DisplayName', sprintf('degree %d', d));
    end
end

hold off;
set(gca, 'FontSize',11);


% ???????????????? Second figure: error curves ????????????????
figure('Color','w');
hold on;

plot(1:max_degree, train_errors, 'b-o', 'LineWidth',1.4, ...
     'MarkerSize',7, 'DisplayName','Training MSE');
plot(1:max_degree, val_errors,   'r-s', 'LineWidth',1.4, ...
     'MarkerSize',7, 'DisplayName','Validation MSE');

xlabel('Polynomial Degree');
ylabel('Mean Squared Error');
title('Validation Curve – Best Polynomial Degree');
grid on;
legend('show','Location','best');

% Mark best degree (two ways – pick the one that works on your version)
[min_val, best_d] = min(val_errors);
fprintf('Best degree according to validation set: %d\n', best_d);
fprintf('Validation MSE: %.6f\n\n', min_val);

% Modern MATLAB (R2018b+): use xline
if exist('xline','file') == 2
    xline(best_d, '--k', 'LineWidth',1.3, ...
          sprintf('Best d = %d', best_d));
else
    % Older MATLAB fallback
    plot([best_d best_d], ylim, '--k', 'LineWidth',1.3);
    text(best_d + 0.4, max(ylim)*0.92, sprintf('Best d = %d', best_d), ...
         'Color','k', 'FontSize',11, 'BackgroundColor','w', 'EdgeColor','k');
end

hold off;
set(gca, 'FontSize',11);