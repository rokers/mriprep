% must launch matlab from terminal!

clear all; close all;  clc

Dounzip=0;
Dodcm2bids=0;
DoFixsBref=0;
DoCorrectJson=1;
DoValidateBids=0;
[project_dir, configfilePath]=dcm2bids_setup('Abdalla')

ses_num = '01'; 
if length(ses_num) < 2; ses_num = strcat('0',ses_num); end

sourcedatadir_all = fullfile(project_dir,'sourcedata')
% sourcedatadir = fullfile(project_dir,'sourcedata',SubjectName)
d = dir(sprintf('%s/Subject*',sourcedatadir_all));
bids_dir = fullfile(project_dir,'rawdata')

%%
for i=16:16 %length(d)

SubjectName = d(i).name
subject_num=extractAfter(SubjectName,"_");
sourcedatadir = fullfile(project_dir,'sourcedata',SubjectName)

%% unzip files that are still compressed
if Dounzip == 1
    disp('Unzipping any compressed dicoms. Please wait . . .')
    zippedFiles = dir(fullfile(sourcedatadir, sprintf('ses_%s',ses_num), '**/*.zip'));
    D = arrayfun(@(x) unzip(fullfile(zippedFiles(x).folder, zippedFiles(x).name), ...
        fullfile(zippedFiles(x).folder)), 1 : numel(zippedFiles), 'UniformOutput', false);
end 
%%%%%%%% TODO: unzip only if unzipped files found

%% DCM2BIDS

sessionsource = fullfile(sourcedatadir, sprintf('ses_%s',ses_num))

if Dodcm2bids == 1
 cmd = sprintf("dcm2bids -d %s -o %s -p %s -s %s -c %s --clobber", ...
       sessionsource, bids_dir, subject_num, ses_num, configfilePath);
 [status, cmdout] = system(cmd, '-echo');

%%
end 

bids_func_dir = fullfile(bids_dir, ['sub-', subject_num], sprintf('ses-%s',ses_num), 'func')

filetypes = {'.json', '.nii.gz'};
if DoFixsBref == 1
    for fi=1:numel(filetypes)
        filetype = filetypes{fi};
        ap_sbref_list = dir(fullfile(bids_func_dir, sprintf('*dir-AP_*sbref*%s', filetype)));
        pa_sbref_list = dir(fullfile(bids_func_dir, sprintf('*dir-PA_*sbref*%s', filetype)));
    
        % for rare cases which multiple sbref (unneccesary)
        ap_sbref = ap_sbref_list(1);
        pa_sbref = pa_sbref_list(1);
    
        % big fix it: this includes some of the sbref
        task_runs = dir(fullfile(bids_func_dir, sprintf('*task*%s', filetype)));
    
        for ii=1:numel(task_runs)
            try
                if contains(task_runs(ii).name, 'dir-AP', IgnoreCase=true)
                    copyfile(fullfile(ap_sbref.folder, ap_sbref.name), ...
                        fullfile(task_runs(ii).folder, strrep(task_runs(ii).name, '_bold', '_sbref')))
                elseif contains(task_runs(ii).name, 'dir-PA', IgnoreCase=true)
                    copyfile(fullfile(pa_sbref.folder, pa_sbref.name), ...
                        fullfile(task_runs(ii).folder, strrep(task_runs(ii).name, '_bold', '_sbref')))
                end
            catch
               sprintf('Skipping %s', task_runs(ii).name)
               sprintf('Either already converted of sbref not found.')
            end
        end
    
        % delete redundant files
        for dd=1:numel(ap_sbref_list)
            delete(fullfile(ap_sbref_list(dd).folder, ap_sbref_list(dd).name))
            delete(fullfile(pa_sbref_list(dd).folder, pa_sbref_list(dd).name))
        end
    
    end
end 

%% Fix the intended for field in the JSON for fmaps
% this is needed because we created several new sbref files (above)
% and to account for a bug in dcm2bids that ignores everything past the
% first task run (both field maps should apply to all bold runs, optionally
% to sbrefs as well)

bids_fmap_dir = fullfile(bids_dir, ['sub-', subject_num], sprintf('ses-%s',ses_num),   'fmap')
func_content = dir(fullfile(bids_func_dir, '*.nii.gz'));

if DoCorrectJson == 1
    if isfolder(bids_fmap_dir)
    
        % list fmap jsons
        fmap_jsons = dir(fullfile(bids_fmap_dir, '*epi.json'));
     
        valFill = {};
    
        for ii=1:numel(func_content)
            intendedItem = [fullfile(sprintf('ses-%s',ses_num), 'func', func_content(ii).name)];
            % intendedItem = ['bids::', fullfile(['sub-', subject_num], sprintf('ses-%s',ses_num), 'func', func_content(ii).name)]
            valFill = [{intendedItem}; valFill];
        end
    
        for fi = 1:numel(fmap_jsons) % for each json file
            % read values from original json
            fname = fullfile(fmap_jsons(fi).folder, fmap_jsons(fi).name); 
            fid = fopen(fname); 
            raw = fread(fid,inf); 
            str = char(raw'); 
            fclose(fid); 
            disp('~~~~')
            % decode and modify
            val = jsondecode(str);
            valModified = val; valModified.IntendedFor = valFill;
    
            str = jsonencode(valModified);
    
            % Make the json output file more human readable
            str = strrep(str, ',"', sprintf(',\n"'));
            str = strrep(str, '[{', sprintf('[\n{\n'));
            str = strrep(str, '}]', sprintf('\n}\n]'));
    
            fid = fopen(fname,'w');
            fwrite(fid,str);
            fclose(fid);
        end 
    end
end 

%% Validating BIDS
% TODO: does not work. activate python package in startup or here
% needed to remove  "sub-0149_ses-01_20231019-111209.log" and "tmp_dcm2bids" for bids validation to be succesful. Fix bidsignore
if DoValidateBids == 1
    cmd = sprintf("bids-validator %s", bids_dir);
    [status, cmdout] = system(cmd, '-echo');
    
    % pyrun("from bids_validator import BIDSValidator")
    % pyrun("BIDSValidator().is_bids('bids_dir')")
end 
end
