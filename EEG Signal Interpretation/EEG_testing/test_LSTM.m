[XTrain,YTrain] = japaneseVowelsTrainData;
figure
plot(XTrain{1}')
xlabel("Time Step")
title("Training Observation 1")
legend("Feature " + string(1:12),'Location','northeastoutside')

numObservations = numel(XTrain);
for i=1:numObservations
    sequence = XTrain{i};
    sequenceLengths(i) = size(sequence,2);
end

[sequenceLengths,idx] = sort(sequenceLengths);
XTrain = XTrain(idx);
YTrain = YTrain(idx);

figure
bar(sequenceLengths)
ylim([0 30])
xlabel("Sequence")
ylabel("Length")
title("Sorted Data")

miniBatchSize = 27;

inputSize = 12;
numHiddenUnits = 100;
numClasses = 9;

layers = [ ...
    sequenceInputLayer(inputSize)
    bilstmLayer(numHiddenUnits,'OutputMode','last')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer]

maxEpochs = 100;
miniBatchSize = 27;

options = trainingOptions('adam', ...
    'ExecutionEnvironment','cpu', ...
    'GradientThreshold',1, ...
    'MaxEpochs',maxEpochs, ...
    'MiniBatchSize',miniBatchSize, ...
    'SequenceLength','longest', ...
    'Shuffle','never', ...
    'Verbose',0, ...
    'Plots','training-progress');

net = trainNetwork(XTrain,YTrain,layers,options);

% [XTest,YTest] = japaneseVowelsTestData;
% XTest(1:3)
% 
% numObservationsTest = numel(XTest);
% for i=1:numObservationsTest
%     sequence = XTest{i};
%     sequenceLengthsTest(i) = size(sequence,2);
% end
% [sequenceLengthsTest,idx] = sort(sequenceLengthsTest);
% XTest = XTest(idx);
% YTest = YTest(idx);
% 
% miniBatchSize = 27;
% YPred = classify(net,XTest, ...
%     'MiniBatchSize',miniBatchSize, ...
%     'SequenceLength','longest');
% 
% acc = sum(YPred == YTest)./numel(YTest)