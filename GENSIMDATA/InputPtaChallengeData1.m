%% Input pta challenge data
addpath ptachallengedata
addpath ptachallengedata/data

Path='ptachallengedata/*.par';
File=dir(Path);

numberP=length(File);
%% Allocate spaces
alphaP0=zeros(numberP,1);
deltaP0=zeros(numberP,1);
kp0=zeros(numberP,3);

%% Get values
for i=1:numberP
Name=File(i).name;
%PAR=struct;
PAR=importdata(Name);
name=strtok(Name,'.');
RESIDUAL=importdata( [name, '.dat']);
if strcmp('ELONG',PAR.textdata(2,1))
    long = PAR.textdata(2,2);
    
    continue
end
ra=PAR.textdata(2,2);
dec=PAR.textdata(3,2);
A=regexp(ra,:,'split');
RA=A{1,1};
B=regexp(dec,:,'split');
DEC=B{1,1};
ALPHA=((str2num(RA{1,3})/60+str2num(RA{1,2}))/60+str2num(RA{1,1})-12)*15*pi/180;
DELTA=(str2num(DEC{1,3})/60+str2num(DEC{1,2}))/60+str2num(DEC{1,1})*pi/180;

alphaP0(i)=ALPHA;
deltaP0(i)=DELTA;

kp0(:,1)=cos(alphaP0).*cos(deltaP0);
kp0(:,2)=sin(alphaP0).*cos(deltaP0);
kp0(:,3)=sin(deltaP0);

timingResiduals0(i,:)=RESIDUAL(:,2);
end

YR0=importdata('J2317+1439.dat');
yr0=YR0(:,1);
yr0=yr0/365.25;
save('TESTDATA2/savedValues.mat','timingResiduals0','yr0','numberP','alphaP0','deltaP0','kp0');

