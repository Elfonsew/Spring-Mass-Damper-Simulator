%% Spring Mass Damper Simulator by Alfonso Custodio
% Allows for R2 button of a game controller connected via Bluetooth to be pressed
% to simulate displacing a mass. Change System and Simulation parameters to
% configure. Note: resolution of high k values is highly dependent on
% computer speed AND tScale!

%% Editable Parameters
clc; clear all; close all;

% Adjustable parameters:
% System Specific:
m = 1;              % Mass of system [kg]
k = 1;              % Spring Coefficient [N/m]
c = 1;              % Damping Coefficient [Ns/m]

% Simulation Specific:
R2_Distance = 0.01; % Fully pressed down R2 distance [m]
tWindow = 10;       % [s] Time window for figure
tSense = 0.1;       % [s] Time Window to sample R2 Input when released
tScale = 1;         % Ratio of simulation time to real time, e.g., 2 = sim time 2x speed

%% Background Initialization
% Initialize flags for events:
pressFlag = 0;       % Flag to see if R2 pressed
positionFlag = 0;    % Flag to begin harmonic response

% Test theoretical max sampling rate
for i = 1:20
    t0 = datetime('now');
    t = datetime('now');
    SampleTimes(i) = seconds(t - t0);
end
maxSamplingTime = max(SampleTimes);
pauseTime = min(maxSamplingTime * 1, 0.01);  % Set maximum pause time to ensure smooth simulation

fprintf("The largest approximate k/m ratio this can visualize without false aliases is: %d\n", (4 * pi / maxSamplingTime / tScale)^2);
fprintf("Current k/m ratio: %d\n", k / m);

% Calculate system variables:
c_c = 2 * sqrt(k * m); % Critical damping coefficient
zeta = c / c_c;        % Damping ratio
w_n = sqrt(k / m);     % Natural frequency [rad/s]
T_n = 2 * pi / w_n;    % Natural period [s]
x_init = 0;            % Declare x_init (R2)

fprintf("ζ = %d. System is ", zeta);
if zeta < 1
    fprintf("underdamped.\n")
elseif zeta == 1
    fprintf("critically damped.\n")
else
    fprintf("overdamped.\n")
end

% Initialize joystick
joy = vrjoystick(1);

% Initialize arrays for storing data
timeData = [];     % Array for time data
R2Data = [];       % Array for R2 data
PositionData = []; % Array for Position Data

%% UI Setup
% Create UI controls
left_start = 60;           % Starting position from the left
bottom_start = 800;        % Starting position from the bottom
vertical_spacing = 50;     % Space between each row of controls
label_width = 80;          % Width of the text labels
label_height = 30;         % Height of the text labels
input_width = 80;          % Width of the input text boxes
input_height = 30;         % Height of the input text boxes

% Create main figure
f = figure('Name', 'Spring Mass Damper Simulator', 'NumberTitle', 'off', 'WindowState', 'maximized');

% System inputs: Mass (m) controls
uicontrol(f, 'Style', 'text', 'String', 'Mass (m)', ...
    'Position', [left_start, bottom_start, label_width, label_height]);
massBox = uicontrol(f, 'Style', 'edit', 'String', num2str(m), ...
    'Position', [left_start + label_width + 10, bottom_start, input_width, input_height]);

% Spring Coefficient (k) controls
uicontrol(f, 'Style', 'text', 'String', 'Spring Coefficient (k)', ...
    'Position', [left_start, bottom_start - vertical_spacing, label_width, label_height]);
kBox = uicontrol(f, 'Style', 'edit', 'String', num2str(k), ...
    'Position', [left_start + label_width + 10, bottom_start - vertical_spacing, input_width, input_height]);

% Damping Coefficient (c) controls
uicontrol(f, 'Style', 'text', 'String', 'Damping Coefficient (c)', ...
    'Position', [left_start, bottom_start - 2 * vertical_spacing, label_width, label_height]);
cBox = uicontrol(f, 'Style', 'edit', 'String', num2str(c), ...
    'Position', [left_start + label_width + 10, bottom_start - 2 * vertical_spacing, input_width, input_height]);

% Simulation Inputs: R2 Distance
uicontrol(f, 'Style', 'text', 'String', 'R2 Distance', ...
    'Position', [left_start, bottom_start - 3 * vertical_spacing, label_width, label_height]);
R2Box = uicontrol(f, 'Style', 'edit', 'String', num2str(R2_Distance), ...
    'Position', [left_start + label_width + 10, bottom_start - 3 * vertical_spacing, input_width, input_height]);

% Time Window
uicontrol(f, 'Style', 'text', 'String', 'Time Window', ...
    'Position', [left_start, bottom_start - 4 * vertical_spacing, label_width, label_height]);
tWindowBox = uicontrol(f, 'Style', 'edit', 'String', num2str(tWindow), ...
    'Position', [left_start + label_width + 10, bottom_start - 4 * vertical_spacing, input_width, input_height]);

% Time Scale
uicontrol(f, 'Style', 'text', 'String', 'Time Scale', ...
    'Position', [left_start, bottom_start - 5 * vertical_spacing, label_width, label_height]);
tScaleBox = uicontrol(f, 'Style', 'edit', 'String', num2str(tScale), ...
    'Position', [left_start + label_width + 10, bottom_start - 5 * vertical_spacing, input_width, input_height]);

% System output: Zeta display
uicontrol(f, 'Style', 'text', 'String', 'Damping Ratio (ζ)', ...
    'Position', [left_start, bottom_start - 6 * vertical_spacing - 20, label_width, label_height]);
zetaDisplay = uicontrol(f, 'Style', 'text', 'String', num2str(zeta), ...
    'Position', [left_start + label_width + 10, bottom_start - 6 * vertical_spacing - 20, input_width, input_height], ...
    'BackgroundColor', [1, 1, 1]); % White

% Position plot area
left_margin = 0.2;
bottom_margin = 0.1;
plot_width = 0.85 - bottom_margin;
plot_height = 1 - left_margin;

subplot('Position', [left_margin, bottom_margin, plot_width, plot_height]);
h = plot(nan, nan, 'b-');
xlabel('Relative Time (s)');
ylabel('Position [m]');
title('Spring Mass Damper Position vs. Time');
ylim([-R2_Distance, R2_Distance] * 1.1);
hold on;

%% Main Loop
t0 = datetime('now');

while true
    [axes, buttons, pov] = read(joy);

    % Update parameters from text boxes
    if m ~= str2double(get(massBox, 'String'))
        m = str2double(get(massBox, 'String'));
        pressFlag = 1;
        buttons(7) = 1;
    end
    if k ~= str2double(get(kBox, 'String'))
        k = str2double(get(kBox, 'String'));
        pressFlag = 1;
        buttons(7) = 1;
    end
    if c ~= str2double(get(cBox, 'String'))
        c = str2double(get(cBox, 'String'));
        pressFlag = 1;
        buttons(7) = 1;
    end
    R2_Distance = str2double(get(R2Box, 'String'));
    tWindow = str2double(get(tWindowBox, 'String'));
    tScale = str2double(get(tScaleBox, 'String'));

    % Set current time and elapsed time
    t_now = datetime('now');
    elapsedTime = seconds(t_now - t0) * tScale;
    t0 = t_now;
    
    R2State = -(axes(6) + 1) / 2.470588;

    % Check if R2 is pressed and released
    if abs(R2State) > 0
        positionFlag = 0;
        pressFlag = 1;
    end

    if pressFlag == 1 && R2State == 0
        pressFlag = 0;
        positionFlag = 1;
        
        c_c = 2 * sqrt(k * m);
        zeta = c / c_c;
        set(zetaDisplay, 'String', num2str(zeta));
        w_n = sqrt(k / m);
        T_n = 2 * pi / w_n;

        if zeta < 1
            phi = @(x0) atan2(zeta * x0, x0 * sqrt(1 - zeta^2));
            X = @(x0) sqrt(x0^2 * w_n^2) / (sqrt(1 - zeta^2) * w_n);
            x = @(t, x0) X(x0) * exp(-zeta * w_n * t) .* cos(sqrt(1 - zeta^2) * w_n * t - phi(x0));

        elseif zeta == 1
            x = @(t, x0) (x0 + (x0 * w_n) * t) * exp(-w_n * t);

        elseif zeta > 1 && zeta ~= Inf
            C1 = @(x0) (x0 * w_n * (zeta + sqrt(zeta^2 - 1))) / (2 * w_n * sqrt(zeta^2 - 1));
            C2 = @(x0) (-x0 * w_n * (zeta - sqrt(zeta^2 - 1))) / (2 * w_n * sqrt(zeta^2 - 1));
            x = @(t, x0) C1(x0) * exp((-zeta + sqrt(zeta^2 - 1)) * w_n * t) + C2(x0) * exp((-zeta - sqrt(zeta^2 - 1)) * w_n * t);
        
        else
            x = @(t, x0) x0;
        end
        funcStartTime = datetime('now');

        if (min(PositionData(ceil(end - tSense * 1 / elapsedTime):end)) < 0)
            x_init = min(PositionData(ceil(end - tSense * tScale / elapsedTime):end));
        elseif (min(PositionData(ceil(end - tSense * 1 / elapsedTime):end)) == 0)
            x_init = 0;
        else
            x_init = max(PositionData(ceil(end - tSense * 1 / elapsedTime):end));
        end
    end

    % Set position based on R2 state
    if positionFlag == 1
        funcTime = seconds(datetime('now') - funcStartTime) * tScale;
        PositionState = x(funcTime, x_init);
    else
        PositionState = R2State * R2_Distance;
    end

    % Append data for plotting
    timeData = [timeData - elapsedTime, 0];
    PositionData = [PositionData, PositionState];

    % Set x-axis limits and update plot
    xlim([-tWindow, 0]);
    ylim([-R2_Distance, R2_Distance] * 1.1);
    set(h, 'XData', timeData, 'YData', PositionData);
    drawnow;

    % Button functionality
    if buttons(7) == 1 % L2 to reset
        positionFlag = 0;
    end
    if buttons(11) == 1 % L3 to stop
        clear joy; % Clear joystick object
        break;
    end

    % Pause for smooth simulation
    % pause(pauseTime);
end