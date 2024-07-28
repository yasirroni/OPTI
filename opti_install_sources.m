% Add required paths
addpath([pwd '/Solvers'])
addpath([pwd '/Solvers/Source'])
addpath([pwd '/Utilities'])
addpath([pwd '/Utilities/opti'])
addpath([pwd '/Utilities/Install'])


% Get list of all files in Solvers/Source directory
files = dir('Solvers/Source');

% Iterate through files
for i = 1:length(files)
    filename = files(i).name;
    
    % Check if file matches the pattern 'opti_*_Install.m'
    if regexp(filename, '^opti_.*_Install\.m$')
        fprintf('Running %s...\n', filename);
        
        % Remove .m extension
        scriptname = filename(1:end-2);
        
        % Run the script
        try
            eval(scriptname);
            fprintf('%s completed successfully.\n\n', filename);
        catch err
            fprintf('Error running %s: %s\n\n', filename, err.message);
        end
    end
end

fprintf('All installation scripts have been processed.\n');
