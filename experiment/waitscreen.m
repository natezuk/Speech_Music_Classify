function [wS,objs] = waitscreen(wS,objs)
% When using PsychToolbox, update the screen and wait for the user to press
% any key
[wS,objs] = gen_screen(objs,wS);
Screen('Flip',wS.ptr);
KbPressWait();