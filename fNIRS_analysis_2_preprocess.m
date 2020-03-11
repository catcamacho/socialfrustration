function analysis_2_preprocess
% This function loads the raw data from step 1 and performs preprocessing

% Load raw data
load('data_1_raw.mat');

%% Drop subjects with errors in acquisition
raw(21) = []; %drop 1019
raw(20) = []; %drop 1018
raw(5) = []; %drop 1003 second scan
raw(4) = []; %drop 1003 first scan

%% Create job to do preprocessing: Convert to OD,
%  resample to 5 Hz, convert to oxy-hemoglobin
job = nirs.modules.TrimBaseline();
    job.preBaseline = 5;
    job.postBaseline = 5;
job = nirs.modules.OpticalDensity(job);
job = nirs.modules.TDDR(job);
job = nirs.modules.Resample(job);
    job.Fs = 5;
%job = advanced.nirs.modules.DCTFilter(job);
%    job.cutoff = 64;
job = nirs.modules.BeerLambertLaw(job);
job = nirs.modules.KeepTypes(job);
    job.types = {'hbo'};
% Run the preprocessing job
hb = job.run(raw);

%% visualize the channels and manually remove those dominated by high 
% frequency noise (confirm with experimenter notes)

%for i = 1:length(hb)
%figure('Name',hb(i).demographics('Name'))
%plot(hb(i).data(200:300,:))
%end

hb(53).data(:,1) = NaN; % 1058
hb(53).data(:,10) = NaN; % 1058
hb(52).data(:,1) = NaN; % 1056
hb(52).data(:,10) = NaN; % 1056
hb(49).data(:,1) = NaN; % 1053
hb(49).data(:,7) = NaN; % 1053
hb(49).data(:,8) = NaN; % 1053
hb(49).data(:,10) = NaN; % 1053
hb(46).data(:,1) = NaN; % 1050
hb(46).data(:,2) = NaN; % 1050
hb(45).data(:,2) = NaN; % 1049
hb(45).data(:,8) = NaN; % 1049
hb(45).data(:,9) = NaN; % 1049
hb(43).data(:,1) = NaN; % 1047
hb(43).data(:,10) = NaN; % 1047
hb(42).data(:,1) = NaN; % 1046
hb(42).data(:,10) = NaN; % 1046
hb(41).data(:,1) = NaN; % 1045
hb(38).data(:,1) = NaN; % 1040
hb(38).data(:,10) = NaN; % 1040
hb(37).data(:,1) = NaN; % 1039
hb(37).data(:,10) = NaN; % 1039
hb(36).data(:,1) = NaN; % 1038
hb(36).data(:,10) = NaN; % 1038
hb(35).data(:,1) = NaN; % 1037
hb(34).data(:,1) = NaN; % 1036
hb(34).data(:,10) = NaN; % 1036
hb(33).data(:,1) = NaN; % 1035
hb(33).data(:,10) = NaN; % 1035
hb(31).data(:,1) = NaN; % 1033
hb(31).data(:,10) = NaN; % 1033
hb(30).data(:,1) = NaN; % 1032
hb(30).data(:,7) = NaN; % 1032
hb(30).data(:,8) = NaN; % 1032
hb(30).data(:,10) = NaN; % 1032
hb(28).data(:,1) = NaN; % 1030
hb(28).data(:,10) = NaN; % 1030
hb(27).data(:,1) = NaN; % 1029
hb(27).data(:,10) = NaN; % 1029
hb(26).data(:,1) = NaN; % 1028
hb(25).data(:,1) = NaN; % 1027
hb(24).data(:,10) = NaN; % 1026
hb(22).data(:,1) = NaN; % 1024
hb(22).data(:,10) = NaN; % 1024
hb(21).data(:,1) = NaN; % 1023
hb(21).data(:,10) = NaN; % 1023
hb(19).data(:,1) = NaN; % 1021
hb(19).data(:,2) = NaN; % 1021
hb(19).data(:,10) = NaN; % 1021
hb(18).data(:,1) = NaN; % 1020
hb(18).data(:,2) = NaN; % 1020
hb(18).data(:,3) = NaN; % 1020
hb(18).data(:,4) = NaN; % 1020
hb(17).data(:,4) = NaN; % 1017
hb(16).data(:,4) = NaN; % 1016
hb(16).data(:,10) = NaN; % 1016
hb(15).data(:,4) = NaN; % 1015
hb(14).data(:,1) = NaN; % 1014
hb(14).data(:,4) = NaN; % 1014
hb(14).data(:,10) = NaN; % 1014
hb(13).data(:,1) = NaN; % 1013
hb(13).data(:,10) = NaN; % 1013
hb(12).data(:,4) = NaN; % 1012
hb(11).data(:,1) = NaN; % 1011
hb(11).data(:,4) = NaN; % 1011
hb(11).data(:,10) = NaN; % 1011
hb(10).data(:,4) = NaN; % 1010
hb(9).data(:,4) = NaN; % 1009
hb(9).data(:,10) = NaN; % 1009
hb(8).data(:,1) = NaN; % 1008
hb(8).data(:,4) = NaN; % 1008
hb(8).data(:,10) = NaN; % 1008
hb(7).data(:,1) = NaN; % 1007
hb(7).data(:,10) = NaN; % 1007
hb(4).data(:,10) = NaN; % 1004
hb(3).data(:,1) = NaN; % 1002
hb(3).data(:,10) = NaN; % 1002

% Save the results
save('data_2_preprocessed.mat','hb','job')

end