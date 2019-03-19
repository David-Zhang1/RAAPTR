%% Cover old values in 'inputDATA.mat'
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

save('TESTDATA2/inputData.mat')

