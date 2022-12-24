%%% Data Processing

clear all

%% Global variables
freq_old = 1000;
freq = 1000;
w_size= freq*0.35;

%% Load Recorded Data
f1 = freq*(0:(w_size/2))/w_size;
database_1 = {};
database_1t = {};
 X_aug = {};
label_1 = {};
n_1 = 1;
n_2 = 1;
id=1;
for i=1:3
    file = strcat('C:\Users\sergi\Desktop\TFM\EEG_testing\Data_recording\LR_0',int2str(i),'.mat')
    load(file)
    record = resample(data,freq,freq_old); %DOES THIS FUNCTION WORK REMOTELY OK ??
    record = record(:,[1 4 7]);
    %Filter and split
    [A,B,C,D] = butter(10,[3 78]/(freq*0.5));
    band_f = designfilt('bandpassiir','FilterOrder',20, ...
        'HalfPowerFrequency1',3,'HalfPowerFrequency2',78, ...
        'SampleRate',freq);
    sos = ss2sos(A,B,C,D);
    Hd =  dfilt.statespace(A,B,C,D);

    notch_f = designfilt('bandstopiir','FilterOrder',2, ...
                   'HalfPowerFrequency1',49,'HalfPowerFrequency2',51, ...
                   'DesignMethod','butter','SampleRate',freq);


    filtered = filter(Hd,record);
    filtered_2 = filtfilt(notch_f,filtered);
    filt = filtered_2;           


    for n=1:(floor(length(filt(:,1))/w_size)-1)
        piece=filt(((n-1)*w_size+1):((n)*w_size+1),:);
        %Transform
        Y=fft(piece);
        P2 = abs(Y/w_size);
        P1 = P2(1:w_size/2+1,:);
        P1(2:end-1,:) = 2*P1(2:end-1,:);
    %     filtered = filter(Hd,data);
    %     filtered_2 = filtfilt(notch_f,filtered);
    %     eeg{j}{i} = filtered_2;
        if video_label(n,freq,w_size,id)>(-1)
            database_1{n_1}=P1;
            database_1t{n_1}=piece;
            prov=database_1{n_1}';
            X_aug{n_1}= [database_1{n_1}';sum(database_1{n_1}'.^2);sum(database_1{n_1}'.^3);(prov(1,:).*prov(2,:)+prov(2,:).*prov(3,:)+prov(3,:).*prov(1,:))];
            %Label
            Y_aug{n_1}= video_label(n,freq,w_size,id);
            n_1 = n_1 + 1;
        end
    end
end
%% Previsualization
f1 = freq*(0:(w_size/2))/w_size;
winds = [20 90 175 15 100 185 30 80 165];
figure(1)
ax1 = subplot(3,3,1);
plot(f1,database_1{winds(1)}')
title(strcat('Window #',int2str(winds(1)),' | Rest'));
ax1 = subplot(3,3,2);
plot(f1,database_1{winds(2)}')
title(strcat('Window #',int2str(winds(2)),' | Rest'));
ax1 = subplot(3,3,3);
plot(f1,database_1{winds(3)}')
title(strcat('Window #',int2str(winds(3)),' | Rest'));

ax1 = subplot(3,3,4);
plot(f1,database_1{winds(4)}')
title(strcat('Window #',int2str(winds(4)),' | Left Hand'));
ax1 = subplot(3,3,5);
plot(f1,database_1{winds(5)}')
title(strcat('Window #',int2str(winds(5)),' | Left Hand'));
ax1 = subplot(3,3,6);
plot(f1,database_1{winds(6)}')
title(strcat('Window #',int2str(winds(6)),' | Left Hand'));

ax1 = subplot(3,3,7);
plot(f1,database_1{winds(7)}')
title(strcat('Window #',int2str(winds(7)),' | Right Hand'));
ax1 = subplot(3,3,8);
plot(f1,database_1{winds(8)}')
title(strcat('Window #',int2str(winds(8)),' | Right Hand'));
ax1 = subplot(3,3,9);
plot(f1,database_1{winds(9)}')
title(strcat('Window #',int2str(winds(9)),' | Right Hand'));

Y_aug{winds}

%% Feature classification
c3_f = [2 5 3 9 6 10];
cz_f = [2 4 9 10 8 18];
c4_f = [2 3 4 9 5 6];
X_feat=[];
num = 0;
s = size(database_1);
for n = 1:s(2)
   if n==1
       pie = database_1{n};
       rel = [max(pie(:,1)) max(pie(:,2)) max(pie(:,3))];
   end 
   num = num + 1;

   res = [database_1{n}(:,1)/rel(1) database_1{n}(:,2)/rel(2) database_1{n}(:,3)/rel(3)];
   X_feat(:,num) = [res(c3_f,1);res(cz_f,2);res(c4_f,3)];
      
end
Y_res = cell2mat(Y_aug);
[a1,b1]=hist(Y_res,unique(Y_res));
min1 = min(a1);

full = 0;
n1=0;
n2=0;
n3=0;
Y_1=[];
X_1=[];
i=0;
k=0;
while full == 0
    i=i+1;
    if Y_res(1,i)==0
        n1=n1+1;
        if n1<min1
            k=k+1;
            Y_1(1,k)=0;
            X_1(:,k)=X_feat(:,i);
        end
    elseif  Y_res(1,i)==3
        n2=n2+1;
        if n2<min1
            k=k+1;
            Y_1(1,k)=1;
            X_1(:,k)=X_feat(:,i);
        end
    elseif  Y_res(1,i)==4
        n3=n3+1;
        if n3<min1
            k=k+1;
            Y_1(1,k)=2;
            X_1(:,k)=X_feat(:,i);
        end
    end
    if (n1>=min1) && (n2>=min1) && (n3>=min1)
        full = 1;
    end
end
database_class_row = [X_1; Y_1]';
database_class_column = [X_1; Y_1];
[trainedClassifier, validationAccuracy] = SVM_features(database_class_row)
%% Load Trained LSTM
net = load('C:\users\sergi\Desktop\TFM\EEG_testing\LSTM_Aug1.mat')
%Validation
numObservationsTest = numel(X_aug);
for i=1:numObservationsTest
    sequence = X_aug{i};
    sequenceLengthsTest(i) = size(sequence,2);
end
[sequenceLengthsTest,idx] = sort(sequenceLengthsTest);
X_aug = X_aug(idx)';
Y_aug = Y_aug(idx)';

layers_1 = [ ...
    sequenceInputLayer(6)
    lstmLayer(50,'OutputMode','last')
    %bilstmLayer(numHiddenUnits,'OutputMode','last')
    %fullyConnectedLayer(numClasses*numHiddenUnits/5)
    %fullyConnectedLayer(numClasses*numHiddenUnits/25)
    fullyConnectedLayer(3)
    softmaxLayer
    classificationLayer];

options_2 = trainingOptions('adam', ...
    'GradientThreshold',0.95, ...
    'InitialLearnRate',0.035, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',25, ...
    'Verbose',0, ...
    'ExecutionEnvironment','gpu',...
    'Plots','training-progress');

miniBatchSize = 60;
%trainedNet = trainNetwork(X_aug,Y_aug,layers_1,options_2)

% %HOW TO REFER TO THE RIGHT "CLASSIFY" FUNCTION ??
% [YPred,scores] = classify(net,X_aug,'SequenceLength','longest');
% %[updatedNet,YPred] = classifyAndUpdateState(recNet,C)
% 
% acc = sum(YPred == Y_aug)./numel(Y_aug)
% 
% %% ReTrain network
% %[net,tr] = train(net,X,T,'useGPU','yes')