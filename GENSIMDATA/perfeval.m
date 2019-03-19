function [] = perfeval(simDataDir,searchParamsFile,varargin)
% Performance evaluation of PSO based PTA analysis
% PERFEVAL(S,P)
% S is the name of the directory containing the input files and P is the
% name of the file containing some of the simulation parameters.
% There are separate files containing the noise realizations and
% noise+signal realizations. There is one input noise+signal file for every
% point in simulation parameter space (signal snr,source sky loc, source
% frequency, noise rlz). Thus, there are #snr X #loc X...X#noise rlz
% signa+noise input files and #noise rlz noise only input files. The two
% types of files are distinguished by the stored variable 'genHypothesis'
% (set to 'H1 data for noise + signal and 'H0 data' for noise only).

% For each input file, run PSO M times and record results. M is user
% specified. For each input file, record an output file with:
%
%  * Path to input file.
%  * 'H0' or 'H1' tag from input file.
%  * PSO parameters used.
%  * For each of the M pso runs: fitness found, number of function evaluations,
%   wall clock time, estimated signal parameters.
%
% Output files should be stored in a subfolder in the folder containing the
% input files. The subfolder should carry a unique tag identifying the run
% that produced it.
%  
% PERFEVAL(S,P,V)
% Overrides default simulations settings with those specified in struct V.
% The fields of V are:
%  'nRuns' : Number of independent PSO runs per file.
%  'psoParams': PSO parameter structure.
% Set any of the fields to '[]' in order to invoke the default values.

% %clear all;
% % clc;
% 
% global Np alphaP deltaP kp N timingResiduals sd yr stdTrueCoord
% 
% % function generating the simulated timing residuals for each pulsar
% [alpha,delta,omega,phi0,phiI,pname]=PTAsimulator;

%%
%% Set the ranges of the search parameters
% The PSO search space is the same for all input files.
load(searchParamsFile,'xmaxmin');
disp(xmaxmin);
% Search Space dimensionality
nDim = length(xmaxmin(:,1));

%%
% Path to folder containing simulated data
% simDataDir = 'simData3';
% dir(simDataDir);
%%
% Path to folder for storing outputs
outDataDir = [simDataDir,filesep,'results'];
mkdir(outDataDir);
%%
% Basic ascii log file for storing run information
% logFile = [simDataDir,filesep,'RunLog.txt'];
% fidLog = fopen(logFile,'w');

% List of input data files (we will only process .mat files)
inputFiles = dir([simDataDir,filesep,'*.mat']);
% Number of input Data files 
nInputFiles = length(inputFiles);
%% 
% Default simulation settings
% Number of independent PSO runs per file
nRuns = 1;
%%
% PSO configuration parameter structure
P = psoparamstruct(1,'default');
P.tuningVars.numPart = 40;
P.tuningVars.maxSteps = 2000;
P.tuningVars.inertiaDecayLaw = 'linear';
P.tuningVars.inertiaDecayParams = [0.9,0.4,2000,0.2];
P.topology.topoScheme = 'ring';
P.topology.topoParams = 3;
P.convergeScheme = 'maxSteps';
%Check if the defaults should be overriden
if nargin > 2
    if ~isempty(varargin{1})
        if ~isempty(varargin{1}.nRuns)
            nRuns = varargin{1}.nRuns;
        end
        if ~isempty(varargin{1}.psoParams)
            P = varargin{1}.psoParams;
        end
    end
end
disp('Number of independent PSO runs');
disp(nRuns);
disp('PSO parameters');
disp(P.tuningVars.numPart);
disp(P.tuningVars.maxSteps);
disp(P.tuningVars.inertiaDecayLaw); 
disp(P.tuningVars.inertiaDecayParams); 
disp(P.topology.topoScheme); 
disp(P.topology.topoParams); 
disp(P.convergeScheme); 
% PSO output parameter structure
outP = struct('outFileNames',{{'log',''}},'graphics','off','status','off');

   
%% Process each input file
parfor lpFile = 1:nInputFiles
    
    inFileName = inputFiles(lpFile).name;
    %Output files carry the same name as input file
    outFileName = [outDataDir,filesep,inFileName];
    
    %Log info
    %fprintf(fidLog,'Starting on File %s.\n--------\n',inFileName);
    disp(['Starting on File ',inFileName]);
     
    %Load contents of input file
    inFileContents = load([simDataDir,filesep,inFileName]);
    %Data to be analyzed
    data = inFileContents.timingResiduals;
    
    %Parameter structure for fitness function
    inParams = inFileContents.simParams;  
    % Add more info 
    yr = inFileContents.yr;
    timingResiduals = inFileContents.timingResiduals;
    inParams.s=timingResiduals;
    inParams.yr=yr;
    inParams.xmaxmin=xmaxmin;      
    
    % Target fitness function
    fHandle = @(x) LLR_PSO(x,inParams);
    
    %Start independent PSO runs
    bestLocationVec = zeros(nRuns,nDim);
    bestLocRealC = zeros(nRuns,nDim);
    bestFitValVec = zeros(nRuns,1);
    nFuncEvalsVec = zeros(nRuns,1);
    nIterVec = zeros(nRuns,1);
    wallClkTimeVec = zeros(nRuns,1);
    %Log info
%     fprintf(fidLog,'\t fitness found/number of function evaluations \n ----\n');
%     disp('fitness found/number of function evaluations');
    for lprun = 1:nRuns
        
        tic;
        psoResults=pso(fHandle,nDim,P,outP);
        wallClkTime = toc;
        wallClkTimeVec(lprun) = wallClkTime/60;%min
        
        bestLocationVec(lprun,:)=psoResults.bestLocation;
        bestLocRealC(lprun,:) = LLR_PSO(psoResults.bestLocation,inParams);
        bestFitValVec(lprun) = psoResults.bestSNR;
        nFuncEvalsVec(lprun) = psoResults.totalFuncEvals;
        nIterVec(lprun) = psoResults.totalSteps;
        
        %Log info
%         fprintf(fidLog,'\t %e/', bestFitValVec(lprun));
%         fprintf(fidLog,'%u', ...
%             nFuncEvalsVec(lprun));
    end
    
    [bestFitVal,bestFitIndx] = min(bestFitValVec);
%     fprintf(fidLog,'\n\t Best Run: %d \n',bestFitIndx);
    bestLocation = bestLocationVec(bestFitIndx,:);
    
    [~,realC]=LLR_PSO(bestLocation,inParams);
    % disp('Best Coordinates (before fminsearch)');
    % disp(realC');
    % disp(['best fitness found (before fminsearch)', num2str(bestFitVal)]);
    % % Do fminsearch (Nelder-Mead)
    % bestLocation = fminsearch(fHandle,bestLocation);
    % [bestFitVal,realC]=LLR_PSO(bestLocation,inParams);
    % disp(['best fitness found (after fminsearch)', num2str(bestFitVal)]);
    % disp('Best Coordinates (after fminsearch)');
%     fprintf(fidLog,'\t Best location:\n');
%     fprintf(fidLog,'%f,',realC);
%     fprintf(fidLog,'\n--------\n');    
    
    %Make output file
    %--------------------
    outStruct = struct(...
                     'inputFile',[simDataDir,filesep,inFileName],...
                     'genHypothesis',inFileContents.genHypothesis,...
                     'id',inFileContents.id,...
                     'psoParams',P,...
                     'nRuns',nRuns,...
                     'bestLocVals',bestLocationVec,...
                     'bestLocRealCVals',bestLocRealC,...
                     'fitnessVals',bestFitValVec,...
                     'numFitEvals',nFuncEvalsVec,...
                     'numIter',nIterVec,...
                     'time2complete',wallClkTimeVec,...
                     'bestRun',bestFitIndx,...
                     'bestLocation',bestLocation,...
                     'bestRealLoc',realC...
                     );
     parsavelocal(outFileName,outStruct);
    
end
%End of run log info
% fclose(fidLog);


               
                   
