% cd('/mnt/bucket/labs/hasson/ariel/247/data/NY625/conversations/');
cd ('Z:/ariel/247/data/NY625/conversations/');
list = dir('NY625*conversation*');

for f = 1:1:length(list)
    filename = list(f).name;
% filepath = '/mnt/bucket/labs/hasson/ariel/247/data/NY625/conversations/';
filepath = 'Z:/ariel/247/data/NY625/conversations/';
load(strcat(filepath,filename,'/misc/',filename,'_aligned.mat')); %raw files

destination = 'C:/Users/jeanl/Desktop/LanguagePredictability';
cd(destination);
ref = AIS_data_org_forelectrode(filename);
AISvals = strings([length(ref),130]);
AISvals(1,1) = "Segment"; AISvals(1,2) = "Conversation"; 
AISvals(1,3) = "Speaker"; AISvals(1,4) = "Length";


%% Load library and instantiate calculator
javaaddpath('infodynamics.jar');
aisCalc = infodynamics.measures.continuous.gaussian.ActiveInfoStorageCalculatorGaussian();

% You can compare this with the nonparametric estimator
% aisCalc = infodynamics.measures.continuous.kraskov.ActiveInfoStorageCalculatorKraskov();

%% Calculate AIS
k   = 1;  % Number of points in the past to use for the prediction
tau = 1;  % How far in the past those points are (NOTE: in this example k=tau=1 is optimal)

for j = 1:length(ref)   %iterates over all segments in conversation
    AISvals(j+1,1) = num2str(j);
    AISvals(j+1,2) = filename;
 
if ref(j,1) == "Speech"
    AISvals(j+1,3) = "Speech";
else 
    AISvals(j+1,3) = "Comprehension";
end

    AISvals(j+1,4) = ref(j,4);

for i = 1:126   %iterates over electrodes
    AISvals(1,i+4) = strcat('Electrode ',num2str(i), ' AIS');
    try
aisCalc.initialise(k, tau);
aisCalc.setObservations(aligned(i, str2double(ref(j,2)):str2double(ref(j,3))));
AISvals(j+1,i+4) = aisCalc.computeAverageLocalOfObservations();
 catch
    fprintf('NonPositiveDefiniteMatrix %s, skipped.\n', i);
  end
end

save(strcat(destination,'/AISsummary.mat'),'AISvals','-append');
end
end
