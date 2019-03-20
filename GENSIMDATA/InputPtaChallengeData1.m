%% Input pta challenge data
addpath ptachallengedata
addpath ptachallengedata/data

Path = 'ptachallengedata/*.par';
File = dir(Path);

numberP = length(File);
%% Allocate spaces
alphaP0 = zeros(numberP,1);
deltaP0 = zeros(numberP,1);
kp0 = zeros(numberP,3);
sd0 = zeros(numberP,1);

%% Get values
for i=1:numberP
Name = File(i).name;
%PAR = struct;
PAR = importdata(Name);
name = strtok(Name,'.');
RESIDUAL = importdata( [name, '.dat']);

%for special case 'J1022+1011.par'(angles are given in ELONG and ELAT)
if strcmp('ELONG',PAR.textdata(2,1))
    alpha = 155.74167; % 0 ~ 360
    delta = 10.03134;  % -90 ~ 90
    ALPHA = (alpha-180)*pi/180;
    DELTA = delta*pi/180;
    
    alphaP0(i) = ALPHA;
    deltaP0(i) = DELTA;

    timingResiduals0(i,:) = RESIDUAL(:,2);
    err = RESIDUAL(:,3);
    avrErr = mean(err);
    sd0(i) = avrErr;
    continue
end

%reading data for usual case(angles are given in REJ and DECJ)
ra=PAR.textdata(2,2);
dec=PAR.textdata(3,2);

A=regexp(ra,':','split');
RA=A{1,1};
B=regexp(dec,':','split');
DEC=B{1,1};

ALPHA=((str2num(RA{1,3})/60+str2num(RA{1,2}))/60+str2num(RA{1,1})-12)*15*pi/180;
DELTA=(str2num(DEC{1,3})/60+str2num(DEC{1,2}))/60+str2num(DEC{1,1})*pi/180;

%directions of pulsars 
alphaP0(i)=ALPHA; % -pi ~ pi
deltaP0(i)=DELTA; % -pi/2 ~ pi/2

%timing residual
timingResiduals0(i,:)=RESIDUAL(:,2);

%standard deviation
err = RESIDUAL(:,3);
avrErr = mean(err);
sd0(i) = avrErr;
end

%unit vectors of pulsars
kp0(:,1)=cos(alphaP0).*cos(deltaP0);
kp0(:,2)=sin(alphaP0).*cos(deltaP0);
kp0(:,3)=sin(deltaP0);

%yr is time samples 
yr0=RESIDUAL(:,1); % in days
yr0=yr0/365.25;    % in years

%% Save useful values
save('TESTDATA2/savedValues.mat','timingResiduals0','yr0','numberP','alphaP0','deltaP0','kp0','sd0');

