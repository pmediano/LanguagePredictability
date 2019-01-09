function x = electrode_shuffle(electrode,k,tau)
javaaddpath('infodynamics.jar');
aisCalc = infodynamics.measures.continuous.gaussian.ActiveInfoStorageCalculatorGaussian();

% load('/mnt/bucket/labs/hasson/ariel/trash_temp/LanguagePredictability/AIS_dataset.mat','AISvals');
load('Z:/ariel/trash_temp/LanguagePredictability/AIS_dataset.mat','AISvals');
elec_data = str2double(AISvals(:,electrode+4));
elec_wo_nan = elec_data(isnan(elec_data) == 0);
shuffled = elec_wo_nan(randperm(length(elec_wo_nan)));
aisCalc.initialise(k, tau);
aisCalc.setObservations(shuffled);
x = num2str(aisCalc.computeAverageLocalOfObservations());
end

