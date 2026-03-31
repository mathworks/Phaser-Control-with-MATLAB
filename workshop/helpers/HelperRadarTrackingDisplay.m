classdef HelperRadarTrackingDisplay < matlab.System
    properties (Nontunable)
        XLimits = [0 40];
        YLimits = [-10 10];
        ZLimits = [-0.25 0.25];
        FieldOfView = [120 0];
        MaxRange = 25;
        MotionModel = 'constvel';
        PlotReferenceImage = true;
        CameraReferenceLines = [63 74.3452 119.9792;80 26.2292 23.5208]*4;
        RadarReferenceLines = [0 16.5 16.5;0 0 -3.5];
        ReferenceLineLength = [16.5 3.5];
    end

    properties (Access = protected)
        Axes
        RawDetectionPlotter
        ClusteredDetectionPlotter
        TrackPlotter
        ReferenceImagePlotter
        truthPlotter
    end

    methods
        function obj = HelperRadarTrackingDisplay(varargin)
            setProperties(obj, nargin, varargin{:});
        end
    end

    methods (Access = protected)
        function setupImpl(obj,~,~,~)

            % Create two axes if reference image is plotter
            if obj.PlotReferenceImage
                f = figure('Visible','on','Units','normalized','Position', [0.1476    0.1989    0.8    0.5408]);
                ax = axes(f,'Units','normalized','Position',[0.05 0.1 0.4 0.8]);
                ax2 = axes(f,'Units','normalized','Position',[0.5 0.1 0.5 0.625]);
                obj.ReferenceImagePlotter = imagesc(ax2,zeros(size(refImage),'like',refImage));
                ax2.DataAspectRatio = [1 1 1];
                ax2.XAxis.Visible = 'off';
                ax2.YAxis.Visible = 'off';
                hold(ax2,'on');

                % Plot reference line
                plot(ax2,obj.CameraReferenceLines(1,:), obj.CameraReferenceLines(2,:),'LineWidth',2,'Color',[0 0 0],'LineStyle','-.');
                for i = 1:(size(obj.CameraReferenceLines,2)-1)
                    x1 = obj.CameraReferenceLines(1,i);
                    x2 = obj.CameraReferenceLines(1,i+1);
                    y1 = obj.CameraReferenceLines(2,i);
                    y2 = obj.CameraReferenceLines(2,i+1);
                    x0 = (x1 + x2)/2;
                    y0 = (y1 + y2)/2;
                    theta = atan2d((y2 - y1),(x2 - x1));
                    d = 20;
                    xc = x0 - d*sind(theta);
                    yc = y0 + d*cosd(theta);
                    text(ax2,xc,yc,sprintf('%0.2g m',obj.ReferenceLineLength(i)),'FontSize',20);
                end
            else % Otherwise, Only 1 axes for radar data
                f = figure('Visible','on','Units','normalized','Position',[0.1 0.1 0.8 0.8]);
                ax = axes(f);
            end

            % Create theater plot
            tp = theaterPlot('Parent',ax,"XLimits",obj.XLimits,'YLimits',obj.YLimits,'ZLimits',obj.ZLimits);

            % Color order
            clrs = lines(7);

            % Create detection plotter
            dp = detectionPlotter(tp,'DisplayName','Detections','MarkerFaceColor',clrs(3,:),'MarkerEdgeColor',clrs(3,:));
            
            % Create Truth Plotter
            dcp = detectionPlotter(tp,'DisplayName','Truths','MarkerFaceColor',clrs(2,:),'MarkerEdgeColor',clrs(2,:));

            % Create track plotter
            trkP = trackPlotter(tp,'DisplayName','Tracks','MarkerFaceColor',clrs(1,:),'MarkerEdgeColor',clrs(1,:),'ColorizeHistory','off','ConnectHistory','off','HistoryDepth',30,'FontSize',20);

            % Plot radar coverage
            cp = coveragePlotter(tp,'DisplayName','','Color',[0 0 0],'Alpha',[0.1 0.1]);
            fov = obj.FieldOfView;
            maxR = obj.MaxRange;
            scanLimits = [-1 1;-1 1].*([fov(1)/2;fov(2)/2]);
            cvg = struct('Index',1,'LookAngle',0,'FieldOfView',[120;0],'ScanLimits',scanLimits,'Range',maxR,'Position',[0 0 0],'Orientation',eye(3));
            cp.plotCoverage(cvg);

            % Move legend to appropriate position when reference image is
            % plotter
            if obj.PlotReferenceImage
                l = legend(ax);
                l.Position = [0.5658 0.7563 0.1058 0.1545];
            end

            % Top view
            view(ax,-90,90);

            % Plot reference line if image is available
            if obj.PlotReferenceImage
                hold(ax,'on');
                plot(ax,obj.RadarReferenceLines(1,:),obj.RadarReferenceLines(2,:),'LineWidth',2,'Color',[0 0 0],'LineStyle','-.');
            end

            obj.RawDetectionPlotter = dp;
            obj.truthPlotter = dcp;
            obj.TrackPlotter = trkP;
        end

        function stepImpl(obj,detections,tracks,truthPos)
            % Plot raw detections
            if ~isempty(detections)
                pos = zeros(3,numel(detections));
                vel = zeros(3,numel(detections));
                posCov = zeros(3,3,numel(detections));
                for i = 1:numel(detections)
                    [pos(:,i),vel(:,i),posCov(:,:,i)] = matlabshared.tracking.internal.fusion.parseDetectionForInitFcn(detections{i},'radar','double');
                end
                obj.RawDetectionPlotter.plotDetection(pos',vel');
                setEdgeAlpha(obj.RawDetectionPlotter);
            end

            % Plot tracks
            if ~isempty(tracks)
                [pos, posCov] = getTrackPositions(tracks,obj.MotionModel);
                vel = getTrackVelocities(tracks,obj.MotionModel);
                if size(pos,2) == 2
                    pos = [pos zeros(numel(tracks),1)];
                    vel = [vel zeros(numel(tracks),1)];
                    posCov3 = zeros(3,3,numel(tracks));
                    for i = 1:numel(tracks)
                        posCov3(:,:,i) = blkdiag(posCov(:,:,i),1);
                    end
                    posCov = posCov3;
                end
    
                labels = "T" + string([tracks.TrackID]);
                obj.TrackPlotter.plotTrack(pos,vel,posCov,labels);
                setEdgeAlpha(obj.TrackPlotter);
            end

            if ~isempty(truthPos)
                % Plot Truth Locations
                pos = vertcat(truthPos(:).Position);
                vel = vertcat(truthPos(:).Velocity);
                obj.truthPlotter.plotDetection(pos,vel)
            end

            if obj.PlotReferenceImage
                % Plot reference image
                obj.ReferenceImagePlotter.CData = refImage;
            end
        end
    end
end

function setEdgeAlpha(trkPlotter)
w = warning('off');
s = struct(trkPlotter);
warning(w);
for i = 1:numel(s.CovariancesPatches)
    set(s.CovariancesPatches(i),'EdgeAlpha',1);
    set(s.CovariancesPatches(i),'FaceAlpha',0);
end
end