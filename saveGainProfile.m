function saveGainProfile(fc_hb100)
% Setup:
%
% Place the HB100 in front of the Phaser - 0 degree azimuth.
%
% Notes:
% 
% The goal is to measure the gain profile of each channel versus the gain
% control code. Place the Hb100 at boresight of the array. This function will
% save the normalized gain profile for each channel.

% Copyright 2023 The MathWorks, Inc.

% Setup antenna
[rx,bf,~] = setupAntenna(fc_hb100);

% Measure the amplitude of each channel for each of the gain codes between
% 0 and 127. 
bf.RxPhase(:) = 0;
bf.RxPowerDown(:) = 1;
bf.LatchRxSettings();
nCapture = 10;
gaincode = 0:127;
subArray1_pks = zeros(numel(gaincode),4);
subArray2_pks = zeros(numel(gaincode),4);
for nCh = 1:4

    % Turn off all channels except 1 in each subarray
    bf.RxPowerDown(:) = 1;
    bf.RxPowerDown(nCh) = 0;
    bf.RxPowerDown(nCh+4) = 0;
    for currentgaincode = gaincode

        % Set the gain code for each subarray element being tested
        aux1 = zeros(1,nCapture);
        aux2 = zeros(1,nCapture);
        bf.RxGain(nCh) = currentgaincode;
        bf.RxGain(nCh+4) = currentgaincode;
        bf.LatchRxSettings();
        rx();
        for ncapture = 1 : nCapture

            % Capture data and measure amplitude of each signal
            receivedSig = rx();
            subArray1_fft = fft(receivedSig(:,2));
            subArray2_fft = fft(receivedSig(:,1));
            aux1(ncapture) = max(abs(subArray1_fft));
            aux2(ncapture) = max(abs(subArray2_fft));
        end
        subArray1_pks(currentgaincode+1,nCh) = mean(aux1);
        subArray2_pks(currentgaincode+1,nCh) = mean(aux2);         
    end
end

% Get the variable to save
subArray1_NormalizedGainProfile = mag2db(subArray1_pks./max(subArray1_pks));
subArray2_NormalizedGainProfile = mag2db(subArray2_pks./max(subArray2_pks));

% Plot normalized gain codes
f = figure; tiledlayout(f,1,2);
ax = nexttile();
plotGainCodes(ax,1,gaincode,subArray1_NormalizedGainProfile);
ax = nexttile();
plotGainCodes(ax,2,gaincode,subArray2_NormalizedGainProfile);

gainProfile_filename = 'GainProfile.mat';
save(gainProfile_filename,"subArray1_NormalizedGainProfile","subArray2_NormalizedGainProfile","gaincode");
    
function plotGainCodes(ax,array,codes,profile)
    [~,numElements] = size(profile);
    hold(ax,"on"); title(ax,['Subbarray ',num2str(array),' Gain Profile']);
    ylabel(ax,'Normalized Gain (dB)'); xlabel(ax,'Element Code Setting');
    for iEl = 1:numElements
        plot(codes,profile(:,iEl),'DisplayName',['Element ',num2str(iEl)]);
    end
    legend(ax,'Location','southeast');
end

end