function analysis_1_prepare
% Load NIRS and demographic data for EmoGrow Fetch task
task = 'SocialCake';
rootdir = '/Users/catcamacho/Box/LCBD/ChEC/social_cake_data_analysis/NIRS_data';
trackingform = [rootdir '/CHEC tracking form 2018.xlsx'];
output_file = fullfile(pwd,'data_1_raw.mat');

%% Load nirs files based on runsheet
raw = load_nirs_data( task , rootdir , trackingform );

%% Rename conditions and remove unneeded files/conditions
% Rest            1
% Preparation	  2
% Position        3
% FinalPosition   4
% Delay     	  5
% Response        6
% Monkey Task	 14

stim_mapping = {'channel_1', 'MoodRating'; ...
                'channel_2', 'TrialEvent'; ...
                'channel_3', 'TrialEvent';...
                'channel_4', 'TrialEvent';...
                'channel_5', 'IBI'; ...
                'channel_12', 'End'};

job = nirs.modules.RenameStims();
    job.listOfChanges = stim_mapping;

    raw = job.run( raw );

%% Probe registration to 10-20 reference points
job = nirs.modules.RegisterProbe();
    job.optode_reference_distance(end+1,:) = cell2table({'S1','FC5',0});
    job.optode_reference_distance(end+1,:) = cell2table({'S2','F5',0});
    job.optode_reference_distance(end+1,:) = cell2table({'S3','AF3',0});
    job.optode_reference_distance(end+1,:) = cell2table({'S4','Fp1',0});
    job.optode_reference_distance(end+1,:) = cell2table({'S5','Fp2',0});
    job.optode_reference_distance(end+1,:) = cell2table({'S6','AF4',0});
    job.optode_reference_distance(end+1,:) = cell2table({'S7','F6',0});
    job.optode_reference_distance(end+1,:) = cell2table({'S8','FC6',0});
    job.optode_reference_distance(end+1,:) = cell2table({'D1','F7',0});
    job.optode_reference_distance(end+1,:) = cell2table({'D2','AF7',0});
    job.optode_reference_distance(end+1,:) = cell2table({'D3','AF8',0});
    job.optode_reference_distance(end+1,:) = cell2table({'D4','F8',0});
    job.source_detector_distance = 3;
    job.units = 'cm';
raw = job.run( raw );

%% Save output
save(output_file,'raw','-v7.3');

%% Modify timings
conditions = {'nonsoc_rew','soc_fru','nonsoc_fru','soc_rew',...
              'nonsoc_fru','soc_rew','nonsoc_rew','soc_fru',...
              'nonsoc_fru','soc_fru','nonsoc_rew','soc_rew',...
              'nonsoc_rew','soc_fru','nonsoc_fru','soc_rew'};
conditions_rev = transpose(flip(conditions));
choice_cond = {'non-social','social','non-social','social',...
               'non-social','social','non-social','social',...
               'non-social','social','non-social','social',...
               'non-social','social','non-social','social'};
feedback_cond = {'reward','frustration','frustration','reward',...
                 'frustration','reward','reward','frustration',...
                 'frustration','frustration','reward','reward',...
                 'reward','frustration','frustration','reward'};

for i = 1:length(raw)
    
    end_of_task = raw(i).stimulus('End');
    IBIs = raw(i).stimulus('IBI');
    ratings = raw(i).stimulus('MoodRating');
    trial_events = raw(i).stimulus('TrialEvent');

    if length(IBIs.onset) > 16
        fprintf('There are too many blocks for %s. Skipping.\n',raw(i).demographics('Name'));
        continue;
    elseif length(IBIs.onset) < 16 && isempty(end_of_task)
        fprintf('There are not enough blocks for %s and no clear end. Skipping.\n',raw(i).demographics('Name'));
        
        continue;
    end
  
    % Fix durations for the IBIs and mood rating periods.
    IBIs.dur = ones(size(IBIs.onset)) * 9;
    ratings.dur = ones(size(ratings.onset)) * 4;
    stims = Dictionary();
    %stims('Rest') = IBIs;
    %stims('MoodRating') = ratings;
    
    % Determine onset for each block and duration
    temp_onsets = ratings.onset * 0;
    temp_dur = ratings.onset * 0;
    for n = 1:length(temp_onsets)
        trial_event_onsets = trial_events.onset;
        if n==1
            temp_dur(n) = ratings.onset(n) - trial_event_onsets(1);
            temp_onsets(n) = trial_event_onsets(1);
        else
            block_events = trial_event_onsets((trial_event_onsets < ratings.onset(n)) & (trial_event_onsets > ratings.onset(n-1)));
            temp_dur(n) = ratings.onset(n) - block_events(1);
            temp_onsets(n) = block_events(1);
        end
    end
    
    block_info = table(temp_onsets,temp_dur,'VariableNames',{'block_onsets','block_duration'});
    block_info = sortrows(block_info,'block_onsets','descend');
    block_info = [block_info table(conditions_rev(1:length(temp_onsets)),'VariableNames',{'Condition'})];
    block_info = sortrows(block_info,'block_onsets','ascend');
    cond = unique(conditions);
    
    for c = 1:length(cond)
        cond_block = block_info(strcmp(block_info.Condition,cond(c)),:);
        s = nirs.design.StimulusEvents(cond(c));
        s.onset = cond_block.block_onsets;
        s.dur = cond_block.block_duration;
        s.amp = ones(size(s.onset));
        stims(cond(c)) = s;
    end
    
    raw(i).stimulus = stims;
end 
%% Save output

save(output_file,'raw','-v7.3');

end