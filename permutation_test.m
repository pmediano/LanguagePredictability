 load AIS_dataset.mat
ps=[]
for elec=5:100 
    shuff_labels= AISvals(randperm(size(AISvals,1)),3);
    AISvals(:,3)= shuff_labels;
index_speech=find(strcmp("Speech",AISvals(:,3)) & str2double(AISvals(:,4)) > 100);
ais_speech_nan=AISvals(index_speech,elec);
ais_speech_elcd = ais_speech_nan(~isnan(str2double(ais_speech_nan)));
index_comp=find(strcmp("Comprehension",AISvals(:,3))& str2double(AISvals(:,4)) > 100);
ais_comp_nan=AISvals(index_comp,elec);
ais_comp_elcd = ais_comp_nan(~isnan(str2double(ais_comp_nan)));
[h,p,ci,stats]=ttest2(str2double(ais_speech_elcd),str2double(ais_comp_elcd));
ps=[ps h];

figure;
subplot(1,2,1);
hist(str2double(ais_speech_elcd)); title(strcat("Speech AIS for Elec ", num2str(elec)));
[counts,centers] = hist(str2double(ais_speech_elcd));
xlabel('AIS values');
speechlabel = sprintf('P-value: %3.3f', p);
text(centers(1),max(counts),speechlabel)

subplot(1,2,2);
hist(str2double(ais_comp_elcd)); title(strcat("Comprehension AIS for Elec ", num2str(elec)));
[counts,centers] = hist(str2double(ais_comp_elcd));
xlabel('AIS values');

destination = '/mnt/bucket/labs/hasson/ariel/trash_temp/LanguagePredictability/elecgraphs/shuffled';
mkdir(destination)
saveas(gcf,strcat(destination,"/Elec",num2str(elec),'.png'));
close

end
