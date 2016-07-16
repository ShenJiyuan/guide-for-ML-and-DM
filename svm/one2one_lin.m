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

%train one-versus-one linear
model=svmtrain(label_tr,data_tr,'-c 2048 -g 0.2 -t 0 -b 1');
%predict for test set
[ptest,acctest,probtest]=svmpredict(label_te,data_te,model,'-b 1');
%%
toc;