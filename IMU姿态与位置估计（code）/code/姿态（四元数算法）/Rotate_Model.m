% 立方体顶点
vertices = [
    -1, -1, -1;
     1, -1, -1;
     1,  1, -1;
    -1,  1, -1;
    -1, -1,  1;
     1, -1,  1;
     1,  1,  1;
    -1,  1,  1
];

% 定义立方体的面
faces = [
    1, 2, 3, 4;
    5, 6, 7, 8;
    1, 2, 6, 5;
    2, 3, 7, 6;
    3, 4, 8, 7;
    4, 1, 5, 8
];

% 创建一个新的图形窗口
figure;
hold on;

% 绘制坐标轴
plot3([-3, 3], [0, 0], [0, 0], 'r', 'LineWidth', 2); % X轴
plot3([0, 0], [-3, 3], [0, 0], 'g', 'LineWidth', 2); % Y轴
plot3([0, 0], [0, 0], [-3, 3], 'b', 'LineWidth', 2); % Z轴

% 设置坐标轴范围
xlim([-3, 3]);
ylim([-3, 3]);
zlim([-3, 3]);
axis equal;
grid on;
view(3)
cube = patch('Vertices', vertices, 'Faces', faces, 'FaceColor', 'cyan', 'FaceAlpha', 0.5);

% 创建一个变换对象
h = hgtransform;
% 使用 `patch` 创建立方体对象，并将其父对象设置为 `h_transform`
set(cube,"Parent",h)

% 设置时间步长和模拟时长
for i=2:length(time)-1
    dt=time(i+1)-time(i);
    Ri = R(:,:,i);
    Ri4=eye(4);
    Ri4(1:3,1:3)=Ri;
    % 将旋转矩阵应用到变换对象
    h.Matrix= Ri4;
    % 更新图形
    drawnow;
    % 暂停，显示动画效果
    pause(dt);
end
