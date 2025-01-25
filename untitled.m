% 清理工作空间
clear; clc;

% 文件名
filename = 'mpu6050_with_temp_data.csv'; % 替换为你的实际文件名

% 读取 CSV 文件，从第 4 行开始读取
opts = detectImportOptions(filename, 'NumHeaderLines', 60); % 跳过前三行
data = readtable(filename, opts);

% 提取时间和温度数据
temperature = data{:, 7}; % 获取第 7 列的温度数据

% 如果温度数据是字符串，去掉单位
temperature = str2double(erase(temperature, '°C')); % 去除 '°C' 并转换为数字

% 检查是否转换成功，处理无效数据
if any(isnan(temperature))
    error('温度数据包含无效的值，无法转换为数值。');
end

num_samples = length(temperature); % 数据点数量
time = (0:num_samples-1) * 0.1; % 时间数组，单位为秒（100ms 间隔）

% 确保 time 和 temperature 是列向量
time = time(:);  % 转换为列向量
temperature = temperature(:);  % 转换为列向量

% 初始猜测值（可以通过数据的趋势估算）
T0_guess = temperature(1); % 初始温度
T_inf_guess = mean(temperature(end-10:end)); % 稳定温度的估算（最后几个数据的平均值）
lambda_guess = 0.1; % 衰减常数的初始猜测值

% 定义拟合模型：指数衰减函数
fit_model = fittype(@(T0, T_inf, lambda, t) T_inf + (T0 - T_inf) * exp(-lambda * t), ...
                    'independent', 't', 'dependent', 'y');

% 使用拟合函数拟合数据
[fit_result, gof] = fit(time, temperature, fit_model, 'StartPoint', [T0_guess, T_inf_guess, lambda_guess]);

% 获取拟合的参数
T0_fit = fit_result.T0;
T_inf_fit = fit_result.T_inf;
lambda_fit = fit_result.lambda;

% 使用拟合的参数计算拟合曲线的值
fitted_temperature = T_inf_fit + (T0_fit - T_inf_fit) * exp(-lambda_fit * time);

% 绘制拟合曲线和原始数据
figure;
plot(time, temperature, '-o', 'LineWidth', 1.5, 'MarkerSize', 6); % 原始数据
hold on;
plot(time, fitted_temperature, 'r-', 'LineWidth', 1.5); % 拟合曲线
grid on;
xlabel('时间 (秒)');
ylabel('温度 (°C)');
title('温度变化曲线与指数拟合');
legend('温度数据', '拟合曲线');

% 输出拟合结果
disp('--- 拟合结果 ---');
fprintf('初始温度 T0: %.2f °C\n', T0_fit);
fprintf('稳态温度 T_inf: %.2f °C\n', T_inf_fit);
fprintf('衰减常数 λ: %.4f\n', lambda_fit);

% 计算拟合优度
disp('--- 拟合优度 ---');
disp(gof);