function [wS,objs] = gen_screen(objs,wS,varargin)
% Generates or updates a screen with the desired text, buttons, etc. The function also
% outputs the input structure, including the screen pointer and
% information, as well as coordinate, color, size, and font information
% created on screen generation.
% Inputs:
%   - objs = a structure of buttons or textboxes that should be put on
%   screen. This is formatted as an "object tag" containing variables of
%   text, colors, or relative coordinates.  Coordinates in particular 
%   should be specified based on the section in which they should be centered
%   in the screen. The screen is split into a 3x3 grid by default.
%   For example, a button with text positioned in the bottom left of the
%   screen that plays a particular sound would look like this:
%       objs.btn_tag
%       objs.btn_tag.type = 'btn'
%       objs.btn_tag.active = 1
%       objs.btn_tag.txt = 'Your text here'
%       objs.btn_tag.rel = [1,3]
%       objs.btn_tag.resp = 'examplesound.wav'
%   - (optional) wS = window pointer for PsychToolbox. If provided, this screen 
%   is updated with the objects provided in 'objs'
% Outputs:
%   - wS = a structure containing the window pointer and background color
%   - objs = same as the input structure, with position and boundary
%   variables included
% Nate Zuk (2016)

bckColor = [0 0 0]; % background color
txtColor = [255 255 255 255]; % color of text
txtFont = 'Arial';
btnColor = [0 0 255 255]; % color of button
btnPd = 10; % number of pixels to pad button rectangle around text
txtSize = 30; % size of text
indSize = 50; % diameter of circular indicator
indColor = [100 255 100 255; 255 100 100 255]; % colors for the indicator, row 1 is OFF, row 2 is ON
crsSize = 50; % width of crosshair
crsWidth = 2; % width of the lines in the crosshair, in pixels
crsColor = [255 255 255 255]; % color for the crosshair
dsp = 1; % number of the screen
offscreen = 0; % window is offscreen
maxrel = [3 3]; % number of equal sections (width and height) by which to split the screen
if nargin<2, % if wS is not provided
	wS = [];
end

% Parse varargin
if ~isempty(varargin),
    for n=2:2:length(varargin),
        eval([varargin{n-1} '=varargin{n};']);
    end
end

%% Initially create the screen
% Create a screen
if ~isempty(wS),
    if offscreen, % if it's offscreen
        bckColor = wS.bckColor;
        [scPtr,scPos] = Screen('OpenOffscreenWindow',wS.ptr,wS.bckColor);
    else
        scPtr = wS.ptr;
        scPos = wS.pos;
        bckColor = wS.bckColor;
    end
else
    [scPtr,scPos] = Screen('OpenWindow',dsp,bckColor); % create screen
end
[scSize(1),scSize(2)] = Screen('WindowSize',scPtr); % save width, height of window

% Set parameters related to the screen
Screen('TextColor',scPtr,txtColor); % set text color
Screen('TextSize',scPtr,txtSize);
Screen('TextFont',scPtr,txtFont);

%% Go through each object and place it on screen
fobj = fieldnames(objs);

for o = 1:length(fobj),
    eval(['obj = objs.' fobj{o} ';']);
    if isfield(obj,'type'),
        % Text object (type, txt, rel)
        if strcmp(obj.type,'txt'),
            if ~isfield(obj,'pos'),
                % Identify the position and bounds for the text
                [obj.bnd,obj.pos] = Screen('TextBounds',scPtr,obj.txt,...
                    (obj.rel(1)-0.5)*scSize(1)/maxrel(1)+scPos(1),... % x cor
                    (obj.rel(2)-0.5)*scSize(2)/maxrel(2)+scPos(2)); % y corr
                % Adjust pos so that it's centered on the desired point on
                % screen
                obj.pos(1:2) = obj.pos(1:2)-obj.bnd(3:4)/2;
                obj.pos(3:4) = obj.pos(3:4)-obj.bnd(3:4)/2;
                % Save the new info into the objs structure
                eval(['objs.' fobj{o} '.bnd = obj.bnd;']);
                eval(['objs.' fobj{o} '.pos = obj.pos;']);
            end
            % Draw text
            if obj.active,
                Screen('DrawText',scPtr,obj.txt,obj.pos(1),obj.pos(2));
            end
        % Descriptive text object (type, txt), always centered on screen
        elseif strcmp(obj.type,'dsc'),
            % Draw text with 1.5 spacing
            if obj.active,
                [~,~,obj.bnd] = DrawFormattedText(scPtr,obj.txt,'center','center',[],[],[],[],1.5);
                eval(['objs.' fobj{o} '.bnd = obj.bnd;']);
            end
        % Button object (type, txt, rel, resp)
        elseif strcmp(obj.type,'btn'),
            if ~isfield(obj,'pos'),
                % Identify the position and bounds for the text
                [txtbnd,txtpos] = Screen('TextBounds',scPtr,obj.txt,...
                    (obj.rel(1)-0.5)*scSize(1)/maxrel(1)+scPos(1),... % x corr
                    (obj.rel(2)-0.5)*scSize(2)/maxrel(2)+scPos(2)); % y corr
                % Adjust txtpos so the text is centered on the desired point
                txtpos(1:2) = txtpos(1:2)-txtbnd(3:4)/2;
                txtpos(3:4) = txtpos(3:4)-txtbnd(3:4)/2;
                % Adjust the bounds and the position for the button
                obj.pos(1:2) = txtpos(1:2)-btnPd;
                obj.pos(3:4) = txtpos(3:4)+btnPd;
                obj.bnd(1) = 0; obj.bnd(2) = 0;
                obj.bnd(3) = obj.pos(3)-obj.pos(1); obj.bnd(4) = obj.pos(4)-obj.pos(2);
                % Save the new info into the objs structure
                eval(['objs.' fobj{o} '.bnd = obj.bnd;']);
                eval(['objs.' fobj{o} '.pos = obj.pos;']);
            end
            if obj.active,
                % Create the rectangle for the button
                Screen('FillRect',scPtr,btnColor,obj.pos);
                % Place the text
                Screen('DrawText',scPtr,obj.txt,obj.pos(1)+btnPd,obj.pos(2)+btnPd);
            end
        % Indicator object (type, rel)
        elseif strcmp(obj.type,'ind'),
            if ~isfield(obj,'pos'),
                % Identify the center point on screen
                cent = [(obj.rel(1)-0.5)*scSize(1)/maxrel(1)+scPos(1), (obj.rel(2)-0.5)*scSize(2)/maxrel(2)+scPos(2)];
                % Determine the pos of the indicator
                obj.pos(1:2) = cent-indSize/2;
                obj.pos(3:4) = cent+indSize/2;
                % Save the new info into the objs structure           
                eval(['objs.' fobj{o} '.color = indColor;']);
                eval(['objs.' fobj{o} '.pos = obj.pos;']);
            end
            % Create a state variable for the indicator, if not already
            % specified
            if ~isfield(obj,'st'),
                obj.st = 1;
                eval(['objs.' fobj{o} '.st = obj.st;']);
            end
            % Create the indicator
            if obj.active,
                Screen('FillOval',scPtr,indColor(obj.st,:),obj.pos);
            end
        % Crosshair object (type)
        elseif strcmp(obj.type,'crs'),
            if ~isfield(obj,'pos'),
                rel = [2, 2]; % plase the crosshair in the center
                % Identify the center point on screen
                cent = [(rel(1)-0.5)*scSize(1)/maxrel(1)+scPos(1), (rel(2)-0.5)*scSize(2)/maxrel(2)+scPos(2)];
                % Determine the pos of the indicator
                obj.pos(1:2) = cent-crsSize/2;
                obj.pos(3:4) = cent+crsSize/2;
                % Save the new info into the objs structure
                eval(['objs.' fobj{o} '.pos = obj.pos;']);
            end
            % Create the indicator
            cent = [sum(obj.pos([1 3]))/2, sum(obj.pos([2 4]))/2]; % identify the center position of the crosshair
            coords = [obj.pos(1), cent(2); ... % left point of first line
                      obj.pos(3), cent(2); ... % right point of first line
                      cent(1), obj.pos(2); ... % lower point of first line
                      cent(1), obj.pos(4);]; % upper point of first line
            if obj.active,
                Screen('DrawLines',scPtr,coords(1:2,:)',crsWidth,crsColor); % horizontal line
                Screen('DrawLines',scPtr,coords(3:4,:)',crsWidth,crsColor); % vertical line
            end
        else
            warning(['Unknown object type ' obj.type ' for obj ' fobj{o} ', skipping...']);
        end
    else
        warning(['No type found for object ' fobj{o} ', skipping...']);
    end
end

%% Save window attributes
wS.ptr = scPtr;
wS.pos = scPos;
wS.bckColor = bckColor;