clc
clear all
close all
tic
%% �����ļ�
% tspdata=importdata('att48.tsp.txt');
% tspdata=importdata('eil51.tsp.txt');
%tspdata=importdata('bayg29.tsp.txt');
% tspdata=importdata('eil76.tsp.txt');
tspdata=importdata('eil101.tsp.txt');
% tspdata=importdata('pa561.tsp.txt');
% tspdata=importdata('tsp225.tsp.txt');
%datanew = tspdata(:, 2:3); % ��ȡѵ�����еĺ��������������
%% ��ȡͼ�������λ�ã���ͼ�������λ�ý���XOY����ϵ
datanew = tspdata(:, 2:3); % ��ȡѵ�����еĺ������꣬���ݺ��������ȡ���ĵ�
maxv = max(datanew); % ��ȡ����������ֵ��������������ֵ
minv = min(datanew);
maxvalue = maxv(1)*maxv(1)+maxv(2)*maxv(2);
wcenter = (maxv - minv)/2 + minv; % ��ʼȨֵ������,�����к�������
%% �����趨
alpha = 0.05; % ��ѧϰ�ʶԽ����Ӱ�죬Խ��ѵ���ٶ�Խ�죬��׼ȷ��Խ�� [0.001��0.1]
beta = 0.2; % ѧϰ�� [0.001��0.5]
gain = 10; % ����������ģ�10��15��20
percent = 0.8; % �ھӵ�ռ��
saleman = 4; %����������
nsize = size(tspdata); % size��������������
ncity = nsize(1); % ���и�������nsize�ĵ�1��
m = ncity*2;
% m = ncity;
winit = [rands(m, 2)+wcenter];
w = winit;
wold = w;  %�����ж�Ȩֵ�Ƿ����һ������Ա��˳�ѭ��
times = 0; %��������
new_w = ones(ncity, 2);%���ɾ���ڵ���ֵ
%% mindstѰ��ͼ�����������ľ��룬Ϊ��ʹ�����ڸ����߶ȵ������ж��ýϸߵ�Ч��
[mindst] = findmin_distance(datanew);

%%
while 1>0
    plot(datanew(:,1), datanew(:,2), 'ko', 'MarkerFaceColor', 'r');
    title('TSP route by som');
    hold on;
    plot(w(:,1), w(:,2), 'b.-');
    plot([w(1,1) w(m,1)], [w(1,2) w(m,2)], 'b.-');
    pause(0.0001); % ��ͣ0.0001���ִ����һ��ָ��
    hold off;
    inhibit = zeros(m,1); % �������н��ĵ���״̬, m������и���
    %���������еı��
    
    yrand = randperm(ncity);
    for pattern = 1:ncity
        newidx = yrand(pattern);
        a = datanew(newidx, :); % ��ȡ���е�����
        % ������(1..m) �� ������a �ľ���
        for j=1:m
            if inhibit(j) == 1
                T(j) = maxvalue;%���������Ѿ����ҵ�����㣬�Ͳ��ټ�����
            else
                T(j) = (a(1)-w(j,1))^2 + (a(2)-w(j,2))^2;
            end
        end
        % [Tmin���������ʤ�ڵ㵽��ǰ���еĶ̾��룬 Jmin���������ʤ�ڵ���±�]
        [Tmin, Jmin] = min(T);
        inhibit(Jmin) = 1;
        
        f = zeros(1,m);
        for j=1:m
            % ��ʾ�ڻ��Ͻڵ� j �� J �ľ���
            d=min(abs(j-Jmin), m-abs(j-Jmin));
            % �������ڵ����г��н���Ȩֵ�޸�
            if d<percent*m
                f(j) = exp(-d*d/(gain*gain));
                w(j,1)=w(j,1)+beta*f(j)*(a(1)-w(j,1));
                w(j,2)=w(j,2)+beta*f(j)*(a(2)-w(j,2));
            end
        end
        
        % ���澺��ʤ���Ľ���������С��0.01*mindst
        distJ = sqrt((a(1)-w(Jmin,1))^2 + (a(2)-w(Jmin,2))^2);
        if distJ < 0.01*mindst
            w(Jmin,1)=a(1);
            w(Jmin,2)=a(2);
        end
    end
    % ѧϰ���ʸı�
    alpha = alpha*0.998;
    gain = (1-alpha)*gain;
    
    % �����˳���������Ȩֵ���ٸı�ʱ
     if w==wold
        break;
     end
    wold = w;
    times = times + 1;
end

%delete
k = 1;
z = zeros(ncity);
for i=1:m
    for j = 1:ncity
        if(abs(norm(w(i,:)-datanew(j,:)))<0.1 && z(j)~=1)
            new_w(k,:) = w(i,:);
            % ��ÿ�λ�ʤ�Ľڵ㱣������
            y(k) = j;
            k = k +1;
            z(j)=1;
            break;
        end
    end
end
plot(new_w(:,1), new_w(:,2), 'ko', 'MarkerFaceColor', 'r');
title('TSP route by som ');
hold on;
plot(new_w(:,1), new_w(:,2), 'b.-');
plot([new_w(1,1) new_w(ncity,1)], [new_w(1,2) new_w(ncity,2)], 'b.-');
pause(0.0001); % ��ͣ0.0001���ִ����һ��ָ��
hold off;

% �����������
times
% ����·��
solution = y;
solution
%�������о���
tourdistance = 0;
for i=1:ncity-1
    tourdistance = tourdistance + norm(new_w(i+1)-new_w(i));
end
tourdistance = tourdistance + norm(new_w(ncity)-new_w(1));
tourdistance
toc