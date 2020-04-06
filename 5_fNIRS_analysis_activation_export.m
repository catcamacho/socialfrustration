function analysis_6_activation_export

%% Load data
load('data_3_activation_individualROI.mat','SubjROIStats');
load('data_4_activation_groupROI.mat','GroupMFXROI');

%% Extract ROI data
GroupMFXROI = GroupMFXROI.ttest({'soc_fru-soc_rew','nonsoc_fru-nonsoc_rew',...
                            'soc_fru-nonsoc_fru','soc_rew-nonsoc_rew'});
conds = unique(nirs.getStimNames(SubjROIStats));
tstats = struct;
rois = unique(SubjROIStats(1,1).variables.ROI);
for k = 1:length(rois)
    for i = 1:length(SubjROIStats)

            for j = 1:length(conds)

                idx = find( strcmp(SubjROIStats(i).variables.ROI, rois{k})& ...
                            strcmp(SubjROIStats(i).variables.cond , conds{j}) );

                 assert(length(idx)==1,'Mismatch found!');

                 %tstats.(rois{k})(i,j) = SubjROIStats(i).tstat(idx);
                 tstats.(rois{k})(i,j) = SubjROIStats(i).beta(idx);
            end
    end
    
end

%% Create table for export
export = nirs.createDemographicsTable(SubjROIStats);

for i=1:length(rois)
    export = [export array2table(tstats.(rois{i}), 'VariableNames',strcat(rois{i},'_beta_',conds))];
    
end

% Save to CSV
writetable(export,'data_6_ROI_export_beta.csv');
end