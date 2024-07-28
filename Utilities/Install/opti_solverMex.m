function opti_solverMex(name,src,inc,libs,opts)
% OPTI_SOLVERMEX Compiles a MEX Interface to an OPTI Solver
%
% This function detects the OS and calls the appropriate platform-specific function.

% Detect OS
if ispc
    opti_solverMex_win(name,src,inc,libs,opts);
elseif ismac
    opti_solverMex_mac(name,src,inc,libs,opts);
else
    error('Unsupported operating system. This function only supports Windows and macOS.');
end

end