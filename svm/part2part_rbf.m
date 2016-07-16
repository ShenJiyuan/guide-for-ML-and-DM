%%ClassifyUsingLibsvm
%by Jiyuan@sjtu
%% a little clean work
tic;
close all;
clear;
clc;
format compact;
%% 
%read train data_label file
fid=fopen('train.txt','r'); 
[f,count]=fscanf(fid,'%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f',[41,6065]);
fclose(fid);
f=f';
data_tr=f(:,[3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39 41]);
label_tr=f(:,1);
num_tr=6065;
%%read test data_label file
fid=fopen('test.txt','r'); 
[f1,count1]=fscanf(fid,'%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f %f:%f',[41,1514]);
fclose(fid);
f1=f1';
data_te=f1(:,[3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39 41]);
label_te=f1(:,1);
num_te=1514;
%extract data and label with a same label to a new matrix (train)
train0=data_tr(1:1:537,:);       label0=label_tr(1:1:537,:);
train1=data_tr(538:1:1531,:);    label1=label_tr(538:1:1531,:);
train2=data_tr(1532:1:1563,:);   label2=label_tr(1532:1:1563,:);
train3=data_tr(1564:1:1654,:);   label3=label_tr(1564:1:1654,:);
train4=data_tr(1655:1:2343,:);   label4=label_tr(1655:1:2343,:);
train5=data_tr(2344:1:2381,:);   label5=label_tr(2344:1:2381,:);
train6=data_tr(2382:1:2455,:);   label6=label_tr(2382:1:2455,:);
train7=data_tr(2456:1:3039,:);   label7=label_tr(2456:1:3039,:);
train8=data_tr(3040:1:4584,:);   label8=label_tr(3040:1:4584,:);
train9=data_tr(4585:1:4684,:);   label9=label_tr(4585:1:4684,:);
train10=data_tr(4685:1:6022,:);  label10=label_tr(4685:1:6022,:);
train11=data_tr(6023:1:end,:);   label11=label_tr(6023:1:end,:);
%extract data and label with a same label to a new matrix (test)
%test0=data_te(1:1:134,:);       labelt0=label_te(1:1:134,:);
%test1=data_te(135:1:381,:);     labelt1=label_te(135:1:381,:);
%test2=data_te(382:1:389,:);     labelt2=label_te(382:1:389,:);
%test3=data_te(390:1:412,:);     labelt3=label_te(390:1:412,:); 
%test4=data_te(413:1:584,:);     labelt4=label_te(413:1:584,:);
%test5=data_te(585:1:593,:);     labelt5=label_te(585:1:593,:);
%test6=data_te(594:1:612,:);     labelt6=label_te(594:1:612,:);
%test7=data_te(613:1:755,:);     labelt7=label_te(613:1:755,:);
%test8=data_te(756:1:1142,:);    labelt8=label_te(756:1:1142,:); 
%test9=data_te(1143:1:1167,:);   labelt9=label_te(1143:1:1167,:);
%test10=data_te(1168:1:1503,:);  labelt10=label_te(1168:1:1503,:);
%test11=data_te(1504:1:end,:);   labelt11=label_te(1504:1:end,:);


ptest=zeros(1514,12);
%train each svm (12-1)*12/2 runs
for t=0:10
    for r=(t+1):11
        %x data get
        if t==0
            x=train0;lx=label0;xn=537;%testt=test0;labelt=labelt0;
        else if t==1
                x=train1;lx=label1;xn=994;%testt=test1;labelt=labelt1;
            else if t==2
                    x=train2;lx=label2;xn=32;%testt=test2;labelt=labelt2;
                else if t==3
                        x=train3;lx=label3;xn=91;%testt=test3;labelt=labelt3;
                    else if t==4
                            x=train4;lx=label4;xn=689;%testt=test4;labelt=labelt4;
                        else if t==5
                                x=train5;lx=label5;xn=38;%testt=test5;labelt=labelt5;
                            else if t==6
                                    x=train6;lx=label6;xn=74;%testt=test6;labelt=labelt6;
                                else if t==7
                                        x=train7;lx=label7;xn=584;%testt=test7;labelt=labelt7;
                                    else if t==8
                                            x=train8;lx=label8;xn=1545;%testt=test8;labelt=labelt8;
                                        else if t==9
                                                x=train9;lx=label9;xn=100;%testt=test9;labelt=labelt9;
                                            else if t==10
                                                    x=train10;lx=label10;xn=1338;%testt=test10;labelt=labelt10;
                                                else if t==11
                                                        x=train11;lx=label11;xn=43;%testt=test11;labelt=labelt11;
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        %y data get
        if r==0
            y=train0;ly=label0;yn=537;
        else if r==1
                y=train1;ly=label1;yn=994;
            else if r==2
                    y=train2;ly=label2;yn=32;
                else if r==3
                        y=train3;ly=label3;yn=91;
                    else if r==4
                            y=train4;ly=label4;yn=689;
                        else if r==5
                                y=train5;ly=label5;yn=38;
                            else if r==6
                                    y=train6;ly=label6;yn=74;
                                else if r==7
                                        y=train7;ly=label7;yn=584;
                                    else if r==8
                                            y=train8;ly=label8;yn=1545;
                                        else if r==9
                                                y=train9;ly=label9;yn=100;
                                            else if r==10
                                                    y=train10;ly=label10;yn=1338;
                                                else if r==11
                                                        y=train11;ly=label11;yn=43;
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        m=ceil(min(xn,yn)/2);ll=0;lr=0;k=0;s=0;
        %ptmp=cell((xn/m+1)*(yn/m+1),1514);
        for k1=1:m:xn
            for k2=1:m:yn
                ll=k1+m-1;lr=k2+m-1;
                if ll>xn
                    ll=xn;
                end
                if lr>yn
                    lr=yn;
                end
                data=[x(k1:1:ll,:);y(k2:1:lr,:)];label=[lx(k1:1:ll,:);ly(k2:1:lr,:)];
                model=svmtrain(label,data,'-c 2048 -g 0.2 -t 2 -b 1');
                [p,~,probtest]=svmpredict(label_te,data_te,model,'-b 1');
                p=p';
                if k==0
                    ptmp=p;k=1;
                end
                if k==1
                   k=0;
                   %ptmp=ptmp|p;
                   for d=1:ll-k1+1
                       if (ptmp(1,d)==lx(d,1) || p(1,d)==lx(d,1))
                           ptmp(1,d)=lx(d,1);
                       end
                   end
                   if s==0
                       pulti=ptmp;s=1;
                   else
                       %pulti=pulti&ptmp;
                       for d=1:ll-k1+1
                           if (pulti(1,d)==lx(d,1) && ptmp(1,d)==lx(d,1))
                               pulti(1,d)=lx(d,1);
                           end
                       end
                   end
                end
            end
        end
        %model=svmtrain(label,data,'-c 2048 -g 0.2 -t 0 -b 1');
        %[p,acctest,probtest]=svmpredict(label_te,data_te,model,'-b 1');
        %pt=p';
        %ptest=[ptest;pt];
        for i=1:1514
            ptest(i,pulti(1,i)+1)=ptest(i,pulti(1,i)+1)+1;
        end
    end
end

pfinal=zeros(1514,1);
for u=1:1514
    check=ptest(u,:);
    final=max(check);
    for v=1:12
        if (ptest(u,v)==final)
            pfinal(u,1)=v-1;
        end
    end
end

acctest=sum(pfinal==label_te) ./ numel(label_te);
C=confusionmat(label_te,pfinal);
%train one-versus-one linear
%model=svmtrain(label_tr,data_tr,'-c 2048 -g 0.2 -t 0 -b 1');
%predict for test set
%[ptest,acctest,probtest]=svmpredict(label_te,data_te,model,'-b 1');
%%
toc;