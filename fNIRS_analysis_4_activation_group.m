function analysis_4_activation_group
% Loads subject-level activation data and runs a group-level analysis
% Currently just a basic MFX model with condition and subject ID

%% channel-wise analysis
% Load individual activation data
load('data_3_activation_individual.mat');

% Run mixed-effects ANOVA (to look at main effects & interactions)
job = nirs.modules.MixedEffects();
    job.formula = 'beta ~ -1 + cond + (1|Name)'; %-1 removes the intercept from the model
    job.robust = true;

GroupMFX = job.run(SubjStats);

% % Contrasts
GroupMFX = GroupMFX.ttest({'soc_fru-soc_rew','nonsoc_fru-nonsoc_rew',...
                            'soc_fru-nonsoc_fru','soc_rew-nonsoc_rew'});
GroupMFX.draw('tstat',[-4 4],'q<.05');
GroupMFX.printAll('tstat',[-4 4],'q<.05','./figures','png');

% Save results
save('data_4_activation_group.mat','GroupMFX');
 
%% ROI analysis
% Load individual activation data
load('data_3_activation_individualROI.mat');

% Run mixed-effects ANOVA (to look at main effects & interactions)
job = nirs.modules.MixedEffects();
    job.formula = 'beta ~ -1 + cond + (1|Name)'; %-1 removes the intercept from the model
    job.robust = true;

GroupMFXROI = job.run(SubjROIStats);

% % Contrasts
GroupMFXROI = GroupMFXROI.ttest({'soc_fru-soc_rew','nonsoc_fru-nonsoc_rew',...
                            'soc_fru-nonsoc_fru','soc_rew-nonsoc_rew'});
GroupMFXROI.draw('tstat',[-4 4],'q<.05');
GroupMFXROI.printAll('tstat',[-4 4],'q<.05','./ROIfigures','png');

% Save results
save('data_4_activation_groupROI.mat','GroupMFXROI');
    
end