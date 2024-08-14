function [projectDir, configfilePath,freesurferDir, githubDir] = dcm2bids_setup(username)

% User specific locations
switch(username)

    case {'Abdalla'}
        user='/Users/azm9155/';
        projectDir = [user,'Desktop/Ambl'];
        githubDir = '~/Documents/MATLAB/Visual_studies/GitHub';
        freesurferDir = '/Applications/freesurfer/7.4.1';
        fslDir = '/usr/local/fsl';
        configfilePath = [user,'Documents/GitHub/nyuad_mr_pipeline/config_20230918.json'];

    case {'omnia_NY'}
        user='/Users/omh7815/';
        projectDir = [user,'Documents/Retinotopy_Stereo_Rotation'];
        githubDir = '~/Documents/GitHub';
        freesurferDir = '/Applications/freesurfer/7.4.1';
        fslDir = '/usr/local/fsl';
        configfilePath = [user,'Documents/GitHub/nyuad_mr_pipeline/config_20230918.json'];

    case {'omnia_home'}
        user='/Users/omniahassanin/';
        projectDir = '/Volumes/server/Projects/Retinotopy_Stereo';
        githubDir = '~/Documents/GitHub';
        freesurferDir = '/Applications/freesurfer/7.4.1';
        fslDir = '/usr/local/fsl';
        configfilePath = [user,'Documents/GitHub/nyuad_mr_pipeline/config_20230918.json'];

    case {'rokers'}
        user='/Users/rokers/';
        projectDir = '~/Documents/MRI/rokerslab_retinotopy_2024_002';
        githubDir = '~/Documents/GitHub';
        freesurferDir = '/Applications/freesurfer/7.4.1';
        fslDir = '/usr/local/fsl';
        configfilePath = [githubDir filesep 'mriprep' filesep 'config_20230918.json'];

    case {'server'}
        user='/Users/omniahassanin/';
        projectDir = [user,'Volumes/server/Projects/Retinotopy_Stereo'];
        githubDir = '~/Documents/GitHub';
        freesurferDir = '/Applications/freesurfer/7.4.1';
        fslDir = '/usr/local/fsl';
        configfilePath = [user,'Documents/GitHub/nyuad_mr_pipeline/config_20230918.json'];

end

%conda base environment setting
setenv('PATH', [user,'anaconda3/bin/:' getenv('PATH')]);
%
% % Freesurfer settings
% PATH = getenv('PATH'); setenv('PATH', [PATH ':' freesurferDir '/bin']); % add freesurfer/bin to path
% setenv('FREESURFER_HOME', freesurferDir);
% addpath(genpath(fullfile(freesurferDir, 'matlab')));
% setenv('SUBJECTS_DIR', [projectDir 'derivatives/freesurfer']);
%
% % FSL settings
PATH = getenv('PATH'); setenv('PATH', [PATH ':' fslDir '/bin']); % add freesurfer/bin to path
setenv('FSLDIR', fslDir);
setenv('FSLOUTPUTTYPE','NIFTI_GZ'); %added to tell where to save the fsl outputs

% setenv( 'FSLDIR', '/Users/omh7815/fsl' );
% setenv('FSLOUTPUTTYPE', 'NIFTI_GZ');
% fsldir = getenv('FSLDIR');
% fsldirmpath = sprintf('%s/etc/matlab',fsldir);
% path(path, fsldirmpath);
% clear fsldir fsldirmpath;

