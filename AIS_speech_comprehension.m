function [x] = AIS_speech_conprehension(ss,day,part,conversation)

filename = strcat('NY',ss,'_',day,'_Part',part,'_conversation',conversation);
filepath = '/Volumes/hasson/ariel/247/data/NY625/conversations/';
load(strcat(filepath,filename,'/misc/',filename,'_aligned.mat'));

destination = strcat('/Users/jeanluo/Desktop/LanguagePredictability-master/AIS_',filename);
mkdir(destination);

[speechref, compref] = AIS_data_org(ss,day,part,conversation);
AISvals = strings([126,4]);
AISvals(1,1) = "Electrode"; AISvals(1,2) = "Comp AIS Median"; 
AISvals(1,3) = "Speech AIS Median"; AISvals(1,4) = "Speech Minus Comp AIS";
AISvals(1,5) = "p-value";

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

% inspect outliers: aligned(1,str2double(compref(outliers, 2:3)))

% remove outliers from comp
compoutliers = isoutlier(compAIS);
compAIS = compAIS(~compoutliers);

% NOTE: every time you want to calculate AIS with another set of data
% you have to call those three functions again

%histograms of AIS
figure;
subplot(2,2,1);
hist(speechAIS); title("Speech AIS");
[counts,centers] = hist(speechAIS);
xlabel('AIS values');
speechmedian = median(speechAIS);
speechlabel = sprintf('Median: %3.3f', speechmedian);
text(centers(1),max(counts),speechlabel)

subplot(2,2,2);
hist(compAIS); title("Comprehension AIS");
[counts,centers] = hist(compAIS);
xlabel('AIS values');
compmedian = median(compAIS);
complabel = sprintf('Median: %3.3f', compmedian);
text(centers(1),max(counts),complabel)

%histograms of lengths

subplot(2,2,3);
speech_lengths = speechref(:, 4);
hist(str2double(speech_lengths)); title("Speech lengths");
xlabel('Length of Segment in Samples');

subplot(2,2,4);
comp_lengths = compref(:, 4);
hist(str2double(comp_lengths)); title("Comprehension lengths");
xlabel('Length of Segment in Samples');


saveas(gcf,strcat(destination,'/AIS_graph_electrode',num2str(j),'.png'));
close

AISvals(j+1,1) = j;
AISvals(j+1,2) = num2str(compmedian); AISvals(j+1,3) = num2str(speechmedian);
AISvals(j+1,4) = num2str(speechmedian - compmedian);
[h,p] = ttest2(compAIS,speechAIS);
AISvals(j+1,5) = num2str(p);
end

compcol = str2double(AISvals(2:125,2));
speechcol = str2double(AISvals(2:125,3));
[h,p] = ttest(compcol,speechcol);
AISvals(126,1) = strcat('p-value =', num2str(p), '; ', 'h=', num2str(h));
AISvals(126,2:5) = "--";
cell2csv(strcat(destination,'/AISsummary.csv'),AISvals);
end