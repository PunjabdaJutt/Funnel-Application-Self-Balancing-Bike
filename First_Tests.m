clear all
close all

a = arduino;

% carrier = addon(a, 'Arduino/MKRMotorCarrier')
carrier = motorCarrier(a);

% Fly Wheel
dc_f = dcmotor(carrier,'M3');
en_f = rotaryEncoder(carrier,1);
%resetCount(en_f);


% Rear Wheel
dc_rw = dcmotor(carrier,'M2');
en_rw = rotaryEncoder(carrier,2);
%resetCount(en_rw);


% Steering Wheel
se_sw = servo(carrier,'servo3');
writePosition(se_sw, 0.5)
%current_pos = readPosition(se_sw) * 180


Flywheel_Rot = (readCount(en_f)/12) * 100 / 360 % 1 is a full rotation
start(dc_f)
dc_f.Speed = 1; % min 0.2
for i =1:200
    pause(1/10)
    rpm_f(i) = readSpeed(en_f) / 100;
end
stop(dc_f)
Flywheel_Rot = (readCount(en_f)/12) * 100 / 360
figure(1)
plot(rpm_f)

Rearwheel_Rot = (readCount(en_rw)/12) / 100 % 100:1 Gear ratio and 1 is a full rotation
start(dc_rw)
dc_rw.Speed = 0.3; % min 0.3
for i =1:30
    pause(1/10)
    rpm_rw(i) = readSpeed(en_rw) / 100;
end
stop(dc_rw)
Rearwheel_Rot = (readCount(en_rw)/12) / 100
figure(2)
plot(rpm_rw)



