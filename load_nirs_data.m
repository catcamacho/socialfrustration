function raw = load_nirs_data( task , rootdir , trackingform )
% Load NIRS data
% data = load_nirs_data( task [ , rootdir, trackingform , eventfilefolder ] );

if iscell(task)
    raw = {};
    for i = 1:length(task)
        raw = [raw load_nirs_data( task{i} , trackingform )];
    end
    return
end

% Get list of subjects and corresponding scan numbers
[subj,scan] = scanlist_from_runsheet( trackingform , task );
nScan = length(scan);
N_orig = nScan;

% Find the V1 folders containing NIRx data based on subject/scan numbers
folders = cell(nScan,1);
for i = 1:nScan
    folders{i} = fullfile(rootdir,subj{i},'*',['*' scan{i}],'/');
end

% Check if folders exist, expand wildcards to actual paths
notfound = false(nScan,1); %folders_notfound = {};
for i = 1:nScan
    dir = rdir(folders{i});
    if ~isempty(dir)
        %folders{i} = dir.folder;
        ff = dir.name;
        [folders{i}, ~, ~] = fileparts(ff);
    else
        notfound(i)=1; %folders_notfound{end+1,1} = [subj{i} '-' scan{i}];
    end
end
%folders(notfound)=[]; 
nScan = length(folders);
N_found = nScan;

%% Load data (do probe stuff only on first file)
raw = nirs.core.Data(nScan);
raw(1) = nirs.io.loadNIRx( folders{1} , true );
for i = 2:nScan
    try
        raw(i) = nirs.io.loadNIRx( folders{i} , false );
        raw(i).probe = raw(1).probe;
    catch err
        warning('%s (%s)',err.message,folders{i});
    end
end
for i=nScan:-1:1
    if isempty(raw(i).data)
        raw(i) = [];
    end
end
N_loaded = length(raw);

%% Remove stimless
job = nirs.modules.RemoveStimless( );
raw = job.run( raw );

N_hasstims = length(raw);
nScan = length(raw);

%% Fix demographics
for i=1:length(raw)
    if(isempty(raw(i).demographics('Name')))
        n=raw(i).demographics('subject');
        n=unique(nirs.createDemographicsTable(raw).Name(ismember(nirs.createDemographicsTable(raw).subject,n)));
        raw(i).demographics('Name')=n{end};
    end
end

%% Fix subject names 1 => '001'
for i = nScan:-1:1
    if isempty(raw(i).data)
        raw(i) = [];
    end
    tmp_name = raw(i).demographics('Name');
    raw(i).demographics('Name') = sprintf('%03i',str2double(tmp_name));
end

fprintf('%i scans listed, %i files found, %i files loaded, %i had stim marks\n',N_orig,N_found,N_loaded,N_hasstims);

end
