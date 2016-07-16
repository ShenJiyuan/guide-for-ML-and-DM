[f1,f2,f3,class] = textread('train_all.txt' , '%f%f%f%f',96);

%特征值归一化;
[input,minI,maxI] = premnmx( [f1 , f2 , f3  ]')  ;
input=input(1:2,:);

%构造输出矩阵
output = f3';

%创建神经网络
net = newff( input,output ,30, { 'logsig' 'purelin' } , 'traingdx' ) ; 

%设置训练参数
net.trainparam.show = 50 ;
net.trainparam.epochs = 3000 ;
net.trainparam.goal = 0.01 ;
net.trainParam.lr = 0.01 ;

%开始训练
net = train( net, input , output ) ;
%读取测试数据
[t1, t2, t3, c] = textread('train_all.txt' , '%f%f%f%f',96);

%测试数据归一化
% testInput = tramnmx ( [t1,t2,t3]' , minI, maxI ) ;
% testInput = testInput(1:2,:);
% arrx = -1.5:0.05:1.5;
% arry = -1:0.01:1;
count=1;
for xx=-1.5:0.02:1.5
    for yy=-1:0.02:1
        iinput(1,count)=xx;
        iinput(2,count)=yy;
        count=count+1;
    end
end
[row,column]=size(iinput);
%仿真
Y = sim( net , iinput ) ;
Y =round( Y);
for i=1:column
    switch Y(i)
        case 0
%             plot(testInput(1,i),testInput(2,i),'ro');
              scatter(iinput(1,i),iinput(2,i),'w','filled');
            hold on;
        case 1
%             plot(testInput(1,i),testInput(2,i),'go');
              scatter(iinput(1,i),iinput(2,i),'k','filled');
            hold on;
    end
end

%  plot(t1,t2);
% plot(testInput,Y,'o');
% scatter(t1,t2,'filled');