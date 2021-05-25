clc
clear all
close all
%% �����ļ�
%tspdata=importdata('att48.tsp.txt')
%tspdata=importdata('bayg29.tsp.txt')
%tspdata=importdata('eil76.tsp.txt')
tspdata=importdata('eil101.tsp.txt');
% tspdata=importdata('pa561.tsp.txt');
%tspdata=importdata('tsp225.tsp.txt');
%% ��ȡͼ�������λ�ã���ͼ�������λ�ý���XOY����ϵ
datanew = tspdata(:, 2:3); % ��ȡѵ�����еĺ������꣬���ݺ��������ȡ���ĵ�
maxv = max(datanew); % ��ȡ����������ֵ��������������ֵ
minv = min(datanew);
maxvalue = maxv(1)*maxv(1)+maxv(2)*maxv(2);
wcenter = (maxv - minv)/2 + minv; % ��ʼȨֵ������,�����к�������
%% �����趨
alpha = 0.05; % ��ѧϰ�ʶԽ����Ӱ�죬Խ��ѵ���ٶ�Խ�죬��׼ȷ��Խ�� [0.001��0.1]
beta = 0.1; % ѧϰ�� [0.001��0.5]
gain = 10; % ����������ģ�10��15��20
percent = 0.5; % �ھӵ�ռ��
saleman = 4; %����������
nsize = size(tspdata); % size��������������
ncity = nsize(1); % ���и�������nsize�ĵ�1��
m = ncity;
k_bias = 0.75;
winit = [rands(m, 2)+wcenter+wcenter.*[0,k_bias],rands(m, 2)+wcenter+wcenter.*[0,-k_bias]...
    ,rands(m, 2)+wcenter+wcenter.*[k_bias,0],rands(m, 2)+wcenter+wcenter.*[-k_bias,0]];
w = winit;
wold = w;  %�����ж�Ȩֵ�Ƿ����һ������Ա��˳�ѭ��
times = 0; %��������
inhibit = zeros(m,1); % ���н��ĵִ�״̬, m������и���
min_x = 0;
min_y = 0;
%% mindstѰ��ͼ�����������ľ��룬Ϊ��ʹ�����ڸ����߶ȵ������ж��ýϸߵ�Ч��
[mindst] = findmin_distance(datanew);

while times<150
%% �ƶ���      
        
    plot(datanew(:,1), datanew(:,2), 'ko', 'MarkerFaceColor', 'r');
    title('solution based on som algorithm');
    hold on;
    plot(w(:,1), w(:,2), '.-');
    plot(w(:,3), w(:,4), '.-');
    plot(w(:,5), w(:,6), '.-');
    plot(w(:,7), w(:,8), '.-');
%     for i=1:saleman
%         plot(w(:,1+(2*(salemannum-1))), w(:,2+(2*(salemannum-1))), '.-');
%     end
    pause(0.0001); % ��ͣ0.0001���ִ����һ��ָ��
    hold off;
    inhibit = zeros(m,1); % �������н��ĵ���״̬, m������и���
    %���������еı��
    yrand = randperm(ncity);
    for choice_num = 1:ncity
        newidx = yrand(choice_num);
        a = datanew(newidx, :); % ��ȡ���е�����
        % ������(1..m) �� ���������ľ���
        for salemannum=1:saleman
            for j=1:m
                if inhibit(j) == 1
                    T(salemannum,j) = maxvalue;%���������Ѿ����ҵ�����㣬�Ͳ��ټ�����
                else
                    T(salemannum,j) = (a(1)-w(j,1+(2*(salemannum-1))))^2 + (a(2)-w(j,2+(2*(salemannum-1))))^2;
                end
            end
        end
        % [Tmin���������ʤ�ڵ㵽��ǰ���еĶ̾��룬 min_x��ʾ�����Ǹ����������min_y��ʾ�Ǹ����е��±�]
        Tmin = min(min(T));
        [min_x,min_y]=find(Tmin == T);

        inhibit(min_y) = 1;
        % ��ÿ�λ�ʤ�Ľڵ㱣������
        y(min_y) = newidx;
        f = zeros(1,m);
        %ֻ�����뵱ǰ��������ĵ����ڵ�����
         for j=1:m
            % ��ʾ�ڻ��Ͻڵ� j �� J �ľ���
            d=min(abs(j-min_y), m-abs(j-min_y));
            [size_dx, size_dy]= size(d);
            if size_dx>=2
                d = d(1,1);
            end
            if d<percent*m
                f(j) = exp(-d*d/(gain*gain));
                w(j,1+(2*(min_x-1)))=w(j,1+(2*(min_x-1)))+beta*f(j)*(a(1)-w(j,1+(2*(min_x-1))));
                w(j,2+(2*(min_x-1)))=w(j,2+(2*(min_x-1)))+beta*f(j)*(a(2)-w(j,2+(2*(min_x-1))));
            end
        end
        
        % ���澺��ʤ���Ľ���������С��0.01*mindst
        distJ = sqrt((a(1)-w(min_y,1+(2*(salemannum-1)))).^2 + (a(2)-w(min_y,2+(2*(salemannum-1)))).^2);
        if distJ < 0.01*mindst
            w(min_y,1+(2*(salemannum-1)))=a(1);
            w(min_y,2+(2*(salemannum-1)))=a(2);
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
z = zeros(1,ncity);
l =zeros(1,saleman);
for salemannum=1:saleman
    for i=1:m
        for j = 1:ncity
            if(abs(norm(w(i,1+2*(salemannum-1):2*(salemannum))-datanew(j,:)))<2 && z(1,j)~=1)
                new_w(k,1+2*(salemannum-1):2*(salemannum)) =w(i,1+2*(salemannum-1):2*(salemannum));
                % ��ÿ�λ�ʤ�Ľڵ㱣������
                y(k) = j;
                k = k +1;
                l(1,salemannum) = l(1,salemannum)+1;
                z(j)=1;
                break;
            end
        end
    end
end
l(2) = l(1)+l(2);
l(3) = l(3)+l(2);
l(4) = l(4)+l(3);
%% ����·�� ���Լ�
plot(new_w(1:l(1,1),1), new_w(1:l(1,1),2), 'ko', 'MarkerFaceColor', 'b');
hold on;
plot(new_w(l(1,1)+1:l(2),3), new_w(l(1,1)+1:l(2),4), 'ko', 'MarkerFaceColor', 'r');
hold on;
plot(new_w(l(1,2)+1:l(3),5), new_w(l(1,2)+1:l(3),6), 'ko', 'MarkerFaceColor', 'g');
hold on;
plot(new_w(l(1,3)+1:l(4),7), new_w(l(1,3)+1:l(4),8), 'ko', 'MarkerFaceColor', 'y');
hold on;
title('TSP route by som ');
hold on;
plot(new_w(1:l(1,1),1), new_w(1:l(1,1),2), 'b.-');
plot([new_w(1,1) new_w(l(1,1),1) ],[new_w(1,2) new_w(l(1,1),2)], 'b.-');
hold on;
plot(new_w(l(1,1)+1:l(2),3), new_w(l(1,1)+1:l(2),4), 'r.-');
plot([new_w(l(1,1)+1,3) new_w(l(2),3)],[new_w(l(1,1)+1,4) new_w(l(2),4)], 'r.-');
hold on;
plot(new_w(l(1,2)+1:l(3),5), new_w(l(1,2)+1:l(3),6), 'g.-');
plot([new_w(l(1,2)+1,5) new_w(l(3),5)],[new_w(l(1,2)+1,6) new_w(l(3),6)], 'g.-');
hold on;
plot(new_w(l(1,3)+1:l(4),7), new_w(l(1,3)+1:l(4),8), 'y.-');
plot([new_w(l(1,3)+1,7) new_w(l(4),7)],[new_w(l(1,3)+1,8) new_w(l(4),8)], 'y.-');
hold on;
pause(0.0001); % ��ͣ0.0001���ִ����һ��ָ��
hold off;
% plot(new_w(:,3), new_w(:,4), 'b.-');
% hold on;
% plot(new_w(:,5), new_w(:,6), 'b.-');
% plot(new_w(:,7), new_w(:,8), 'b.-');
pause(0.0001); % ��ͣ0.0001���ִ����һ��ָ��
hold off;
% �����������
times
% ����·��
solution = y;
