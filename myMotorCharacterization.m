%close all

%% 1. Create test data 

maxPWM = 1.00;                          % Maximum duty cycle
incrPWM = 0.05;                         % PWM increment
PWMcmdRaw = (-maxPWM:incrPWM:maxPWM);   % Column vector of duty cycles from -1 to 1

%% 2. Create and initialize device objects 

clear a dcm carrier enc              % Delete existing device objects

a = arduino;
carrier = motorCarrier(a);
dcm = dcmotor(carrier,'M2');         % Connect a DC motor at 'M1' port on the Arduino Nano Motor Carrier board

enc = rotaryEncoder(carrier,2);      % Connect the encoder of 'M1' at the encoder port 1 on the Arduino Nano Motor Carrier board

%% 3. Measure raw motor speed for each PWM command

speedRaw = zeros(size(PWMcmdRaw));              % Preallocate vector for speed measurements

dcm.Speed = 0;
gearRatio = 100;                                % As per the motor spec sheet, gear ratio equals 100:1

start(dcm)                                      % Turn on motor

for ii = 1:length(PWMcmdRaw)

    dcm.Speed = PWMcmdRaw(ii);
    pause(1)                                    % Wait for steady state

    speedRaw(ii) = readSpeed(enc)/gearRatio;    % read motor speed in rpm of the output shaft

end

stop(dcm)                                       % turn off motor
dcm.Speed = 0;

%% 4. Graph raw data

figure(1)
plot(PWMcmdRaw,speedRaw)      % raw speed measurements
title('100:1 Gearbox Motor Steady State Response')
xlabel('PWM Command')
ylabel('Measured Speed (rpm)')

%% 5. Post-process and save data

idx = (diff(speedRaw) > 0);             % find indices where vector is increasing
speedMono = speedRaw(idx);              % Keep only increasing values of speed
PWMcmdMono = PWMcmdRaw(idx);            % Keep only corresponding PWM values
PWMcmdMono(speedMono == 0) = 0;         % enforce zero power for zero speed
save motorResponse PWMcmdMono speedMono % save post-processed measurements

%% 6. Graph raw and post-processed data

plot(PWMcmdRaw,speedRaw)                            % raw speed measurements
hold on
plot(PWMcmdMono,speedMono)                          % non-monotonic measurements filtered out
title('100:1 Gearbox Motor Steady State Response')
xlabel('PWM Command')
ylabel('Measured Speed (rpm)')
legend('Raw Data','Monotonic Data','Location','northwest')

%% 7. Delete device objects

clear a dcm carrier enc