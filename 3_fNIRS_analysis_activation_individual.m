function analysis_3_activation_individual
% This function loads the raw data from step 2 and performs first-level
% activation analysis

% Load preprocessed data
load('data_2_preprocessed.mat');
conditions = hb(1).stimulus.keys;

% Create activation job
job = nirs.modules.GLM();
    canon = nirs.design.basis.Canonical; % Create a canonical HRF basis function
    canon.incDeriv = true; % Enable temporal and dispersion derivatives
    canon.peakTime = 6; % Use 6-second time-to-peak (SPM default)
    job.basis('default') = canon; % Set our canonical as the default basis in the set     

% Remove all but the canonical response (:01), rename to remove the ':01'
job = nirs.modules.RenameStims(job);
    job.listOfChanges = [strcat(conditions,':01')' conditions'];
    
job = nirs.modules.KeepStims(job);
    job.listOfStims = conditions;
    
% Run the activation job
SubjStats = job.run(hb);

% Save the results
save('data_3_activation_individual.mat','SubjStats','job')

%% Make ROIs
job = nirs.modules.ApplyROI();
 job.listOfROIs(1,:) = array2table({[2 2],[1 2],'left_lPFC'});
 job.listOfROIs(2,:) = array2table({[7 7],[3 4],'right_lPFC'});
 job.listOfROIs(3,:) = array2table({[3 4],[2 2],'left_mPFC'});
 job.listOfROIs(4,:) = array2table({[5 6],[3 3],'right_mPFC'});
 SubjROIStats = job.run(SubjStats);
 
save('data_3_activation_individualROI.mat','SubjROIStats')

end