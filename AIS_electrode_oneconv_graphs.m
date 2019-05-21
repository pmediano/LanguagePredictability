function x = AIS_electrode_oneconv_graphs(ss,day,part,conversation)

filename = strcat('NY',ss,'_',day,'_Part',part,'_conversation',conversation);

% change filepaths for load and destination definition
filepath = '/mnt/bucket/labs/hasson/ariel/trash_temp/Data/conversations/';
load(strcat(filepath,filename,'/misc/',filename,'_aligned.mat')); %raw files
destination = '/mnt/bucket/labs/hasson/ariel/trash_temp/LanguagePredictability';
cd(destination);


ref = AIS_data_org_mac(ss,day,part,conversation);

index_speech=find(strcmp("Speech",ref(:,1)));
ais_speech= ref(index_speech,:);
index_comp=find(strcmp("Comprehension",ref(:,1)));
ais_comp= ref(index_comp,:);
AISvals = strings(40,5);
AISvals(1,1) = "k-value";
AISvals(1,2) = "AIS- El25 Speech"; AISvals(1,3) = "AIS- El25 Comp";
AISvals(1,4) = "AIS- El32 Speech"; AISvals(1,5) = "AIS- El32 Comp"

%% Load library and instantiate calculator
javaaddpath('infodynamics.jar');
aisCalc = infodynamics.measures.continuous.gaussian.ActiveInfoStorageCalculatorGaussian();

% You can compare this with the nonparametric estimator
% aisCalc = infodynamics.measures.continuous.kraskov.ActiveInfoStorageCalculatorKraskov();

%% Calculate AIS

for k = 1:40 % Number of points in the past to use for the prediction
tau = 3  % How far in the past those points are (NOTE: in this example k=tau=1 is optimal)

AISvals(k+1,1) = k;
temp_el25_speech = zeros(length(ais_speech),1);
temp_el25_comp = zeros(length(ais_comp),1);
temp_el32_speech = zeros(length(ais_speech),1);
temp_el32_comp = zeros(length(ais_comp),1);


for j = 1:length(ais_speech)   %iterates over all segments in conversation
i = 25;
     try
aisCalc.initialise(k, tau);
aisCalc.setObservations(aligned(i, str2double(ais_speech(j,2)):str2double(ais_speech(j,3))));
temp_el25_speech(j,1)= aisCalc.computeAverageLocalOfObservations();
 catch
   warning('NonPositiveDefiniteMatrix %s, skipped.\n');
     end

i = 32;
     try
aisCalc.initialise(k, tau);
aisCalc.setObservations(aligned(i, str2double(ais_speech(j,2)):str2double(ais_speech(j,3))));
temp_el32_speech(j,1) = aisCalc.computeAverageLocalOfObservations();
 catch
   warning('NonPositiveDefiniteMatrix %s, skipped.\n');
     end

end
AISvals(k+1,2) = mean(temp_el25_speech);
AISvals(k+1,4) = mean(temp_el32_speech);

for j = 1:length(ais_comp)   %iterates over all segments in conversation
i = 25;
     try
aisCalc.initialise(k, tau);
aisCalc.setObservations(aligned(i, str2double(ais_comp(j,2)):str2double(ais_comp(j,3))));
temp_el25_comp(j,1)= aisCalc.computeAverageLocalOfObservations();
 catch
   warning('NonPositiveDefiniteMatrix %s, skipped.\n');
     end

i = 32;
     try
aisCalc.initialise(k, tau);
aisCalc.setObservations(aligned(i, str2double(ais_comp(j,2)):str2double(ais_comp(j,3))));
temp_el32_comp(j,1) = aisCalc.computeAverageLocalOfObservations();
 catch
   warning('NonPositiveDefiniteMatrix %s, skipped.\n');
     end
end

AISvals(k+1,3) = mean(temp_el25_comp);
AISvals(k+1,5) = mean(temp_el32_comp);

end
save(strcat(destination,'/AISsummary_varyingK_tau3',filename,'.mat'),'AISvals');



scatter(str2double(AISvals(2:end,1)),str2double(AISvals(2:end,4))) % 4 and 5 are electrode 32, 2 and 3 are 25
hold on
scatter(str2double(AISvals(2:end,1)),str2double(AISvals(2:end,5)))
legend("Production","Comprehension",'Location','southwest');
lsline
title("NY625 418 Part7 c5 k= 1:40, tau = 3")
xlabel("k-value")
ylabel("AIS value")
saveas(gcf,strcat(destination,'/',filename','_c1_k1-40_tau3_electrode32.png'));
close

scatter(str2double(AISvals(2:end,1)),str2double(AISvals(2:end,2))) % 4 and 5 are electrode 32, 2 and 3 are 25
hold on
scatter(str2double(AISvals(2:end,1)),str2double(AISvals(2:end,3)))
legend("Production","Comprehension",'Location','southwest');
lsline
title("NY625 418 Part7 c5 k= 1:40, tau = 3")
xlabel("k-value")
ylabel("AIS value")
saveas(gcf,strcat(destination,'/',filename','_c1_k1-40_tau3_electrode25.png'));
close
end
