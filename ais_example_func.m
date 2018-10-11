%% Example on how to use the ActiveInformationStorage (AIS) in JIDT

%% Generate data. Just a simple AR process for now
N   = 5000  % Number of samples
a   = 0.5   % Self-coupling
eps = 1     % Noise variance
X = zeros([N, 1]);
for i=2:N
  X(i) = a*X(i-1) + sqrt(eps)*randn();
end
true_ais = -0.5*log(1-a*a);

%% Load library and instantiate calculator
javaaddpath('infodynamics.jar');
aisCalc = infodynamics.measures.continuous.gaussian.ActiveInfoStorageCalculatorGaussian();

% You can compare this with the nonparametric estimator
% aisCalc = infodynamics.measures.continuous.kraskov.ActiveInfoStorageCalculatorKraskov();

%% Calculate AIS
k   = 1;  % Number of points in the past to use for the prediction
tau = 1;  % How far in the past those points are (NOTE: in this example k=tau=1 is optimal)
aisCalc.initialise(k, tau);
aisCalc.setObservations(X);
ais = aisCalc.computeAverageLocalOfObservations();

% NOTE: every time you want to calculate AIS with another set of data
% you have to call those three functions again

disp('Calculation finished.');
disp(['Obtained: ', num2str(ais)]);
disp(['True AIS: ', num2str(true_ais)]);

