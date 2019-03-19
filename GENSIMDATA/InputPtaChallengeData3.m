%% Converting
% A script convert searchParams file from .mat to hdf5
clear
delete('TESTDATA2/inputData.hdf5')
mpavinfile2hdf5('TESTDATA2/inputData.mat')

name = 'searchParams_simDataSKA_X.mat';
inFileList = dir(name);
%mkdir('searchParams_HDF5');
for lpc = 1:length(inFileList)
    inFileName = strtok(name,'.');
    outFileName = ['TESTDATA2',filesep,inFileName,'.hdf5'];
    inFileInfo = load(name);
    fldName = 'xmaxmin';
    %Create HDF5 file
    fid = H5F.create(outFileName);
    H5F.close(fid);
    nDim = length(size((inFileInfo.(fldName))'));
    baseSz = ones(1, nDim);
    h5create(outFileName,['/',fldName],...
        max([size((inFileInfo.(fldName))'); baseSz]));
    h5write(outFileName,['/',fldName],(inFileInfo.(fldName))');
end


