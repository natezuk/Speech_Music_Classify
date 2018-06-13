% Label stimulus by type
% I've labeled the stimuli by type based on ordering after loading with
% loadstimclassdata, which should always be the same because it's
% alphabetically (NZ, 4/12/2018)
% Environmental = 1; Mechanical = 2; Music = 3; Non-speech vocal = 4;
% Non-vocal human = 5; Speech = 6; Animal = 7;
typelbl = [2;... % dial-tone
    4;... % background speech
    3;... % drum solo
    6;... % girl speaking
    4;... % grunting and groaning
    6;... % baby talk
    3;... % piano
    1;... % poaring liquid
    3;... % saxophone jazz solo
    2;... % school bell
    4;... % scream
    6;... % angry shouting
    1;... % boiling water
    5;... % walking on hard surface
    4;... % whistling
    3;... % latin music
    6;... % spanish
    6;... % italian
    6;... % german
    4;... % crowd laughing
    2;... % heartbeat
    1;... % stream
    3;... % cartoon sound effects
    2;... % cell phone vibrating
    3;... % cello
    1;... % chimes in the wind
    5;... % chopping food
    7;... % cicadas
    2;... % clock ticking
    4]; % crowd cheering