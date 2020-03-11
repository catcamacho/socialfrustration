function [subj,scan] = scanlist_from_runsheet( trackingform , taskname , filter )
% Extract list of subjects and scans from run sheet
% [subject,scan] = scanlist_from_runsheet( trackingform , taskname , filter )
% 
if nargin<3, filter = {}; end

tbl=readtable(trackingform);
tbl(isnan(tbl.SubjectID),:)=[];

Name = cell(height(table),1);
for i=1:height(tbl)
    Name{i,1} = sprintf('%03i',tbl.SubjectID(i));
end
tbl=[table(Name) tbl];
tbl.SubjectID=[];

if ~isempty(filter)
    fdata = tbl.(filter{1});
end

scan_list = tbl.(taskname);
scan_list = strrep(strrep(strrep(strrep(scan_list,'.',''),'scan',''),' ',''),',','/');

subj = {}; scan = {};
for i = 1:length(scan_list)
    
    if ~isempty(filter)
        if ~strcmpi(fdata{i},filter{2})
            continue;
        end
    end
        
    scans = strsplit(scan_list{i},'/');
    if all(cellfun(@isempty,scans))
        continue;
    end
    
    for j = 1:length(scans)
        subj(end+1,1) = Name(i);
        scan(end+1,1) = {sprintf('%03i',str2double(scans{j}))};
    end
    
end

end
