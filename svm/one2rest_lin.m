%%ClassifyUsingLibsvm
%by Jiyuan@sjtu
%% a little clean work
tic;
close all;
clear;
clc;
format compact;
%% 
num_label=12; %maximum label number
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

%preparations
%function [acctest,pred]]=svm_ovr_class(data_tr,label_tr,data_te,label_te);
%train one-versus-rest linear
model=cell(num_label,1);
for k=1:num_label
    model{k}=svmtrain(double(label_tr==k-1),data_tr,'-c 2048 -g 0.2 -t 0 -b 1');
end
%get probability estimates of test instances using each model
prob=zeros(num_te,num_label);
for k=1:num_label
    [~,~,p]=svmpredict(double(label_te==k-1),data_te,model{k},'-b 1');
    prob(:,k)=p(:,model{k}.Label==1); %probability of class==k
end
%predict test instances with the highest probability
prob=prob';
[~,pred]=max(prob); %pred is the label prediction of each test
pred=pred';
pred=pred-1;
acctest=sum(pred==label_te) ./ numel(label_te); 
C=confusionmat(label_te,pred);
%%
toc;