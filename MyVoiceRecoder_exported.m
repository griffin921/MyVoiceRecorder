classdef MyVoiceRecoder_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure               matlab.ui.Figure
        RECButton              matlab.ui.control.Button
        PlayButton             matlab.ui.control.Button
        UIAxes                 matlab.ui.control.UIAxes
        PleasePushRECLabel     matlab.ui.control.Label
        SecLabel               matlab.ui.control.Label
        RECTimeEditFieldLabel  matlab.ui.control.Label
        RECTimeEditField       matlab.ui.control.NumericEditField
        Lamp                   matlab.ui.control.Lamp
    end


    properties (Access = public)
        %Create properties
        
        Fs = 44100;
        nBits = 16; 
        nChannels = 1;
        ID = -1; % default audio input device 
        recorder;
        voice_data;
        record_time = 5;
        Player;
    end
   

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            
            %Init
            app.PleasePushRECLabel.Text = "Please push REC.";
            app.UIFigure.Name ='My Voice Recorder';

            
        end

        % Button pushed function: RECButton
        function RECButtonValueChanged(app, event)
 
         
            if(strcmp(app.PleasePushRECLabel.Text,"Playing..."))
                return
            end
            
            %Start Recording
            app.PleasePushRECLabel.Text = "Recording..."; 
            app.Lamp.Color = [1,0,0];
            app.recorder = audiorecorder(app.Fs,app.nBits,app.nChannels,app.ID);
            recordblocking(app.recorder, app.record_time );
            
            %Finnish Recording
            app.PleasePushRECLabel.Text = "Please push Button."; 
            app.Lamp.Color = [0.94,0.94,0.94];
            
            %Plot wave data
            t = [0:1/app.Fs:app.record_time-(1/app.Fs)];
            app.voice_data = getaudiodata(app.recorder);
            plot(app.UIAxes,t, app.voice_data);
            
        end

        % Button pushed function: PlayButton
        function PlayButtonValueChange(app, event)
           
            if(strcmp(app.PleasePushRECLabel.Text,"Recording...") || strcmp(app.PleasePushRECLabel.Text,"Please push REC"))
                return
            end
           
            %Play recorded data.
            app.PleasePushRECLabel.Text = "Playing..."; 
            app.Lamp.Color = [0,1,0];
            app.Player = audioplayer(app.voice_data,app.Fs);
            playblocking(app.Player);
            app.PleasePushRECLabel.Text = "Please push Button."; 
            app.Lamp.Color = [0.94,0.94,0.94];

        end

        % Value changed function: RECTimeEditField
        function RecordTimeValueChanged(app, event)
            app.record_time = app.RECTimeEditField.Value;
            app.UIAxes.XLim = [0,app.record_time];
            app.UIAxes.XTick = [0,0.2,0.4,0.6,0.8,1] .* app.record_time;
            app.UIAxes.XTickLabel = [0,0.2,0.4,0.6,0.8,1] .* app.record_time;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 490 193];
            app.UIFigure.Name = 'UI Figure';

            % Create RECButton
            app.RECButton = uibutton(app.UIFigure, 'push');
            app.RECButton.ButtonPushedFcn = createCallbackFcn(app, @RECButtonValueChanged, true);
            app.RECButton.Icon = 'REC.png';
            app.RECButton.Position = [19 63 175 26];
            app.RECButton.Text = 'REC';

            % Create PlayButton
            app.PlayButton = uibutton(app.UIFigure, 'push');
            app.PlayButton.ButtonPushedFcn = createCallbackFcn(app, @PlayButtonValueChange, true);
            app.PlayButton.Icon = 'Play.png';
            app.PlayButton.Position = [19 27 175 23];
            app.PlayButton.Text = 'Play';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'voice wave')
            xlabel(app.UIAxes, 'time[s]')
            ylabel(app.UIAxes, 'Amp.')
            app.UIAxes.PlotBoxAspectRatio = [2.68354430379747 1 1];
            app.UIAxes.FontName = 'Meiryo UI';
            app.UIAxes.XLim = [0 5];
            app.UIAxes.YLim = [-1 1];
            app.UIAxes.XTick = [0 1 2 3 4 5];
            app.UIAxes.XTickLabel = {'0'; '1'; '0'; '1'; '4'; '5'};
            app.UIAxes.TitleFontWeight = 'bold';
            app.UIAxes.Position = [209 27 261 152];

            % Create PleasePushRECLabel
            app.PleasePushRECLabel = uilabel(app.UIFigure);
            app.PleasePushRECLabel.HorizontalAlignment = 'center';
            app.PleasePushRECLabel.VerticalAlignment = 'bottom';
            app.PleasePushRECLabel.FontName = 'Meiryo UI';
            app.PleasePushRECLabel.FontSize = 14;
            app.PleasePushRECLabel.Position = [42 147 152 22];
            app.PleasePushRECLabel.Text = 'Please Push REC';

            % Create SecLabel
            app.SecLabel = uilabel(app.UIFigure);
            app.SecLabel.FontName = 'Meiryo UI';
            app.SecLabel.FontSize = 14;
            app.SecLabel.Position = [136 105 36 22];
            app.SecLabel.Text = 'Sec.';

            % Create RECTimeEditFieldLabel
            app.RECTimeEditFieldLabel = uilabel(app.UIFigure);
            app.RECTimeEditFieldLabel.HorizontalAlignment = 'right';
            app.RECTimeEditFieldLabel.FontName = 'Meiryo UI';
            app.RECTimeEditFieldLabel.FontSize = 14;
            app.RECTimeEditFieldLabel.Position = [24 105 72 22];
            app.RECTimeEditFieldLabel.Text = 'REC Time';

            % Create RECTimeEditField
            app.RECTimeEditField = uieditfield(app.UIFigure, 'numeric');
            app.RECTimeEditField.Limits = [0 60];
            app.RECTimeEditField.ValueChangedFcn = createCallbackFcn(app, @RecordTimeValueChanged, true);
            app.RECTimeEditField.FontName = 'Meiryo UI';
            app.RECTimeEditField.FontSize = 14;
            app.RECTimeEditField.Position = [104 105 30 22];
            app.RECTimeEditField.Value = 5;

            % Create Lamp
            app.Lamp = uilamp(app.UIFigure);
            app.Lamp.Position = [22 145 21 21];
            app.Lamp.Color = [0.9412 0.9412 0.9412];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = MyVoiceRecoder_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end