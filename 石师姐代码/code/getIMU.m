% Date         Author        Notes
% 2023.10.25   Yutong Shi    

addpath('quaternion_library');      % �����Ԫ����
close all;                          
clear;                              
clc;   
                               
%% ����������Ԥ��������
[num,txt,raw] = xlsread('C:\Users\12206\Desktop\3_imu_data.xlsx');

Accelerometer = num(:,1:3);
Gyroscope = num(:,4:6);
Magnetometer = num(:,10:12);

% ʱ���Ԥ����
timeStamp = txt(2:end,1);
timechar = char(timeStamp);
for i = 1: length(timeStamp)
    split_timecell(i,:) = strsplit(timechar(i,:), ':');    
end
% ��ȡ Cell �����ά��
rows = size(split_timecell, 1);
cols = size(split_timecell, 2);
doubleArray = zeros(size(split_timecell));              % ��ʼ��һ���� split_timecell ��С��ͬ�� double ����
for i = 1:numel(split_timecell)
    doubleArray(i) = str2double(split_timecell{i});     % ��ÿ���ַ���ת��Ϊ double �洢�� doubleArray ��
end
doubleArray = reshape(doubleArray, [rows, cols]);       % �� doubleArray ת��Ϊ�ʵ���ά��

time_a = doubleArray(:,3);
time_b = doubleArray(:,4);
time = time_a + time_b./1000;

time = time - time(1,:);
for i = 1:length(time)-1
    if time(i+1) - time(i) < 0
        time(i+1:end,:) = time(i+1:end,:) + 60;
    end
end

% IMUת����ȫ������ϵ
% for i = 1:length(time1)
%     Gyroscope(i,:) = ([1 0 0; 0 0 1; 0 -1 0]' *  Gyroscope(i,:)')';           %ע�⽫����ת������һ����ϵ��Ҫ������ϵ��ת�����ת��
%     Accelerometer(i,:) = ([1 0 0; 0 0 1; 0 -1 0]' *  Accelerometer(i,:)')';
% end

figure('Name', 'Sensor Data');
axis(1) = subplot(2,1,1);                   %��ʾһ������һ�е�ͼ�е�һ��λ��
hold on;
plot(time, Gyroscope(:,1));
plot(time, Gyroscope(:,2));
plot(time, Gyroscope(:,3));
legend('X', 'Y', 'Z');
xlabel('Time (s)');
ylabel('Angular rate (deg/s)');             %ע��ԭʼ�����������ǽǶ�ֵ
title('Gyroscope');
hold off;
axis(1) = subplot(2,1,2);                   %��ʾһ������һ�е�ͼ�е�һ��λ��
hold on;
plot(time, Accelerometer(:,1));
plot(time, Accelerometer(:,2));
plot(time, Accelerometer(:,3));
legend('X', 'Y', 'Z');
xlabel('Time (s)');
ylabel('Acceleration (g)');             %ע��ԭʼ�����������ǽǶ�ֵ
title('Accelerometer');
hold off;
linkaxes(axis, 'x');                        %��һ��ͼ�е�����ͼ��������ͬ��

%% ��������
% SamplePeriod = 0.04;
quaternion = zeros(length(time), 4);
quaternion(1,:) = [1 0 0 0];
q = quaternion;                             %Ϊ�˷������������ȫ����q����
Gyroscope = Gyroscope * (pi/180);           %���������ݽǶ�ת����

% ����Ԫ���㷨
for i = 1:length(time)-1
    qDot = 0.5 * quaternProd(q(i,:), [0 Gyroscope(i+1,1) Gyroscope(i+1,2) Gyroscope(i+1,3)]);
    q(i+1,:) = q(i,:) + qDot * (time(i+1)-time(i));
    q(i+1,:) = q(i+1,:) / norm(q(i+1,:));             % ��Ԫ����һ�� 
end

R = quatern2rotMat((q));
euler = quatern2euler(quaternConj(q)) * (180/pi);
% ��Щ�Ƕȳ���+-180
for i = 2:length(time)
    if euler(i,1)-euler(i-1,1) > 180
        euler(i,1) = euler(i,1) - 360;
    end
    if euler(i,2)-euler(i-1,2) > 180
        euler(i,2) = euler(i,2) - 360;
    end
    if euler(i,3)-euler(i-1,3) > 180
        euler(i,3) = euler(i,3) - 360;
    end
end

figure('Name', 'Euler Angles');
set(gcf,'unit','centimeters','position',[10,10,8,6])
hold on;
plot(time, euler(:,1),'color',[0.85,0.33,0.1],'LineWidth',1.5);
plot(time, euler(:,2),'color',[0,0.45,0.74],'LineWidth',1.5);
plot(time, euler(:,3),'color',[0.93,0.69,0.13],'LineWidth',1.5);
title('Euler angles');
set(gca,'FontSize',10,'linewidth',1,'FontName','Times New Roman');    %����������
xlabel('Time (s)','FontSize',10,'FontName','Times New Roman');
ylabel('Angle (deg)','FontSize',10,'FontName','Times New Roman');
lgd=legend('\phi', '\theta', '\psi');
% lgd.NumColumns = 3;
hold off;

% %% ���ٶȼƽ��� Ư�ƺܴ�
% velocity(1,:) = zeros(1,3);
% position(1,:) = zeros(1,3);
% for i = 1:length(time)-1
%     y(i,:) = (R(:,:,i)'*Accelerometer(i,:)' - Accelerometer(1,:)')';
%     velocity(i+1,:) = velocity(i,:) + (time(i+1)-time(i)) * (R(:,:,i)'*Accelerometer(i,:)' - Accelerometer(1,:)')';
%     position(i+1,:) = position(i,:) + (time(i+1)-time(i)) * velocity(i+1,:);
% end
% 
% figure('Name', 'Position');
% set(gcf,'unit','centimeters','position',[10,10,8,6])
% hold on;
% plot(time, position(:,1),'color',[0.85,0.33,0.1],'LineWidth',1.5);
% plot(time, position(:,2),'color',[0,0.45,0.74],'LineWidth',1.5);
% plot(time, position(:,3),'color',[0.93,0.69,0.13],'LineWidth',1.5);
% set(gca,'FontSize',10,'linewidth',1,'FontName','Times New Roman');    %����������
% xlabel('time (s)','FontSize',10,'FontName','Times New Roman');
% ylabel('position (cm)','FontSize',10,'FontName','Times New Roman');
% lgd=legend('x', 'y', 'z');
% hold off;



