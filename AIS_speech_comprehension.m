function [x] = AIS_speech_conprehension(ss,day,part,conversation)

filename = strcat('NY',ss,'_',day,'_Part',part,'_conversation',conversation);
filepath = 'Z:/ariel/247/data/NY625/NY625_conversations/';
load(strcat(filepath,filename,'/misc/',filename,'_aligned.mat'));

[speechref, compref] = AIS_data_org(ss,day,part,conversation);


%% Load library and instantiate calculator
javaaddpath('infodynamics.jar');
aisCalc = infodynamics.measures.continuous.gaussian.ActiveInfoStorageCalculatorGaussian();

% You can compare this with the nonparametric estimator
% aisCalc = infodynamics.measures.continuous.kraskov.ActiveInfoStorageCalculatorKraskov();

%% Calculate AIS
k   = 1;  % Number of points in the past to use for the prediction
tau = 1;  % How far in the past those points are (NOTE: in this example k=tau=1 is optimal)
for i = 1:length(speechref)
aisCalc.initialise(k, tau);
aisCalc.setObservations(aligned(32, str2double(speechref(i,2)):str2double(speechref(i,3))));
speechAIS(i) = aisCalc.computeAverageLocalOfObservations();
% disp(['Speech: ', num2str(ais)]);
end

for i = 1:length(compref)
    try
    aisCalc.initialise(k, tau);
aisCalc.setObservations(aligned(32, str2double(compref(i,2)):str2double(compref(i,3))));
compAIS(i) = aisCalc.computeAverageLocalOfObservations();
  catch
    fprintf('NonPositiveDefiniteMatrix %s, skipped.\n', i);
  end
end


% disp(['Comprehension: ', num2str(ais2)]);
% NOTE: every time you want to calculate AIS with another set of data
% you have to call those three functions again

%histograms
hist(speechAIS); title("Speech AIS");
figure;
hist(compAIS); title("Comprehension AIS");


end