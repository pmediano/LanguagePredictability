function [x] = AIS_speech_conprehension(ss,day,part,conversation)

filename = strcat('NY',ss,'_',day,'_Part',part,'_conversation',conversation);
filepath = 'Z:/ariel/247/data/NY625/NY625_conversations/';
load(strcat(filepath,filename,'/misc/',filename,'_aligned.mat'));

destination = 'C:/Users/jeanl/Desktop/AIS/AIS Graphs'
mkdir(destination);

[speechref, compref] = AIS_data_org(ss,day,part,conversation);

%% Load library and instantiate calculator
javaaddpath('infodynamics.jar');
aisCalc = infodynamics.measures.continuous.gaussian.ActiveInfoStorageCalculatorGaussian();

% You can compare this with the nonparametric estimator
% aisCalc = infodynamics.measures.continuous.kraskov.ActiveInfoStorageCalculatorKraskov();

%% Calculate AIS
for j = 1:124

k   = 1;  % Number of points in the past to use for the prediction
tau = 1;  % How far in the past those points are (NOTE: in this example k=tau=1 is optimal)
for i = 1:length(speechref)
aisCalc.initialise(k, tau);
aisCalc.setObservations(aligned(j, str2double(speechref(i,2)):str2double(speechref(i,3))));
speechAIS(i) = aisCalc.computeAverageLocalOfObservations();
% disp(['Speech: ', num2str(ais)]);
end

for i = 1:length(compref)
    try
    aisCalc.initialise(k, tau);
aisCalc.setObservations(aligned(j, str2double(compref(i,2)):str2double(compref(i,3))));
compAIS(i) = aisCalc.computeAverageLocalOfObservations();
  catch
    fprintf('NonPositiveDefiniteMatrix %s, skipped.\n', i);
  end
end


% disp(['Comprehension: ', num2str(ais2)]);
% NOTE: every time you want to calculate AIS with another set of data
% you have to call those three functions again

%histograms of AIS
figure;
subplot(2,2,1);
hist(speechAIS); title("Speech AIS");
xlabel('AIS values');
speechmedian = median(speechAIS);
speechlabel = sprintf('Median : %3.3f', speechmedian);
text(0.5,40,speechlabel)
subplot(2,2,2);
hist(compAIS); title("Comprehension AIS");
xlabel('AIS values');
compmedian = median(compAIS);
complabel = sprintf('Median : %3.3f', compmedian);
text(0.5,40,complabel)

%histograms of lengths
comp_lengths = compref(:, 4);
subplot(2,2,3);
hist(str2double(comp_lengths)); title("Comprehension lengths");
xlabel('Length of Segment in Samples');

subplot(2,2,4);
speech_lengths = speechref(:, 4);
hist(str2double(speech_lengths)); title("Speech lengths");
xlabel('Length of Segment in Samples');

saveas(gcf,strcat(destination,'/AIS_graph_electrode',num2str(j),'.png'));
close
end
end