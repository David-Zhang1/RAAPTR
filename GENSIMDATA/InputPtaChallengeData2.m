%% Cover old values in 'noise1.mat'and make it a new file: 'inputData.mat'
clear
load ('TESTDATA2/savedValues.mat')
load ('TESTDATA2/noise1.mat')
timingResiduals=timingResiduals0;
clear  timingResiduals0
yr=yr0;
clear  yr0
simParams.Np=numberP;
clear  numberP 
simParams.N=length(yr);
%simParams.sd=????
simParams.alphaP=alphaP0;
clear  alphaP0
simParams.deltaP=deltaP0;
clear  deltaP0
simParams.kp=kp0;
clear kp0
simParams.sd=sd0;
clear sd0

save('TESTDATA2/inputData.mat')

