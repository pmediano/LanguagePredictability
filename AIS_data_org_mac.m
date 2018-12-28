function [ref] = AIS_data_org_mac(ss,day,part,conversation)
filename = strcat('NY',ss,'_',day,'_Part',part,'_conversation',conversation);
filepath = 'Z:/ariel/247/data/NY625/conversations/';

load(strcat(filepath,filename,'/misc/',filename,'_aligned.mat'));
load(strcat(filepath,filename,'/labels/',filename,'_speaker_labels.mat'));
% binary_speaker = zeros(length(speaker_labels));

for i = 1:length(speaker_labels)
    if speaker_labels(i) == "Speaker1"
        binary_speaker(i) = 1;
    else
        binary_speaker(i) = 0;
    end
end
% 
% speaker1_indices = find(binary_speaker);
% speaker1_data = aligned(electrode, speaker1_indices);
% otherspeaker_indices = find(~binary_speaker);
% otherspeaker_data = aligned(electrode, otherspeaker_indices);

% create summary of data
sectionchange = [true; diff(binary_speaker(:)) ~= 0];   % TRUE if values change
changeindices= find([sectionchange', true]);          % Indices of changes
sectionlength = diff(changeindices);                   % Number of repetitions

ref = strings([length(sectionlength),4]);
 if binary_speaker(1) == 1
        ref(1,1) = "Speech";
    else ref(1,1) = "Comprehension";
 end
 
for i=1:length(sectionlength)
    if i~=1
       if ref(i-1,1) == "Speech"
           ref(i,1) = "Comprehension";
       else
           ref(i,1) = "Speech";
       end
    end
    ref(i,2)= changeindices(i);
    if i+1 < length(changeindices)
    ref(i,3) = changeindices(i+1) - 1;
    else ref(i,3) = length(binary_speaker);
    end
    ref(i,4) = sectionlength(i);
end

% speechref = ref(find(ref(:,1) == "Speech"),:);
% compref = ref(find(ref(:,1) == "Comprehension"),:);


end
