function opti_solverMex_mac(name,src,inc,libs,opts)
% macOS-specific implementation

if nargin > 4
    if ~isfield(opts,'verb') || isempty(opts.verb), opts.verb = false; end
    if ~isfield(opts,'debug') || isempty(opts.debug), opts.debug = false; end
    if ~isfield(opts,'pp'), opts.pp = []; end
    if ~isfield(opts,'quiet') || isempty(opts.quiet), opts.quiet = false; end
else
    opts.verb = false;
    opts.debug = false;
    opts.pp = [];
    opts.quiet = false;
end

% Remove existing mex file from memory
clear(name);

if ~opts.quiet
    fprintf('\n------------------------------------------------\n');
    fprintf('%s MEX FILE INSTALL\n\n',upper(name));
end

% Build Source File String
if iscell(src)
    src_str = strjoin(src, ' ');
else
    src_str = src;
end
% Add OPTI Utils
src_str = sprintf('%s opti/opti_mex_utils.cpp', src_str);

% Build Include String
if iscell(inc)
    inc_str = strjoin(cellfun(@(x) ['-I' x], inc, 'UniformOutput', false), ' ');
elseif ~isempty(inc)
    inc_str = ['-I' inc];
else
    inc_str = '';
end
inc_str = [inc_str ' -Iopti -IInclude'];

% Set up Homebrew paths
brew_prefix = '/opt/homebrew';
cbc_path = [brew_prefix '/Cellar/cbc/2.10.11'];
openblas_path = [brew_prefix '/Cellar/openblas/0.3.27'];

% Add system include and library paths
inc_str = [inc_str, ...
    ' -I' brew_prefix '/include', ...
    ' -I' cbc_path '/include', ...
    ' -I' openblas_path '/include'];

lib_str = ['-L' brew_prefix '/lib', ...
           ' -L' cbc_path '/lib', ...
           ' -L' openblas_path '/lib'];

% Add libraries
if iscell(libs)
    lib_str = [lib_str ' ' strjoin(cellfun(@(x) ['-l' x], libs, 'UniformOutput', false), ' ')];
elseif ~isempty(libs)
    lib_str = [lib_str ' -l' libs];
end
lib_str = [lib_str ' -llibut'];

% Post Messages (output name + preprocessors)
post = [' -output ' name];
if ~isempty(opts.pp)
    if iscell(opts.pp)
        post = [post ' ' strjoin(cellfun(@(x) ['-D' x], opts.pp, 'UniformOutput', false), ' ')];
    else
        post = [post ' -D' opts.pp];
    end
end

% Other Options
if opts.verb
    verb = ' -v ';
else
    verb = ' ';
end

if opts.debug
    debug = ' -g ';
    post = [post ' -DDEBUG']; % some mex files use this to provide extra info
else
    debug = ' ';
end

% Extra preprocessor defines
oct_ver = version();
post = [post ' -DOCT_VER=' oct_ver ' -DOPTI_VER=' sprintf('%.2f', optiver())];

% CD to Source Directory
cdir = pwd();
cd('Solvers/Source');

% Compile & Move
try
    evalstr = ['mkoctfile --mex' verb debug ' ' inc_str ' ' src_str ' ' lib_str post];
    
    if ~opts.quiet
        fprintf('MEX Call:\n%s\n\n', evalstr);
    end
    
    [status, output] = system(evalstr);
    if status ~= 0
        error('Compilation failed:\n%s', output);
    end
    
    movefile([name '.mex'], '../', 'f');
    
    if ~opts.quiet
        fprintf('Done!\n');
    end
catch ME
    cd(cdir);
    error('opti:mex', 'Error Compiling %s!\n%s', upper(name), ME.message);
end
cd(cdir);
if ~opts.quiet
    fprintf('------------------------------------------------\n');
end

end

function ver = optiver()
% Return OPTI version (placeholder function, replace with actual version retrieval)
ver = 2.28; % Replace with actual version
end
