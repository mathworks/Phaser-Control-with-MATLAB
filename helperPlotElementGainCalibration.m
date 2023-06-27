function [array1gaincal,array2gaincal] = helperPlotElementGainCalibration(sub1meanamp,sub1gaincal,sub2meanamp,sub2gaincal)
    % Calculate and visualize the element-wise amplitude calibration for
    % both subarrays.

    % Copyright 2023 The MathWorks, Inc.

    sub1meanamp = mag2db(sub1meanamp);
    sub1gaincal = mag2db(sub1gaincal);
    sub2meanamp = mag2db(sub2meanamp);
    sub2gaincal = mag2db(sub2gaincal);
    
    % Setup figure
    figure; tiledlayout(1,2); a = nexttile();

    % Calculate and plot the gain calibration for subarray 1
    array1gaincal = helperElementSubarrayGainCalibration(a,'Subarray 1',sub1meanamp, sub1gaincal); a = nexttile();
    
    % Calculate and plot the gain calibration for subarray 2
    array2gaincal = helperElementSubarrayGainCalibration(a, 'Subarray 2', sub2meanamp, sub2gaincal);
end

function arraygaincal = helperElementSubarrayGainCalibration(ax,name,amplitudes,arraygaincal)
    % Calculate and visualize the element-wise amplitude calibration for
    % one subarray.

    hold(ax,"on");

    % Normalize amplitude for each element in the array
    dbNormAmplitudes = amplitudes - max(amplitudes);
    
    % Plot normalized amplitudes and gain adjustments
    b = bar(ax,[dbNormAmplitudes',arraygaincal'],'stacked');
    b(1).DisplayName = "Initial Normalized Amplitude";
    b(2).DisplayName = "Gain Adjustment";

    % Plot a line showing the final amplitude of all elements
    plot(ax,[0,5],[min(dbNormAmplitudes),min(dbNormAmplitudes)],"DisplayName","Final Element Amplitude","LineWidth",2,"Color","k")

    xlabel('Antenna Element')
    ylabel('dB');
    title([name ' - Gain Calibration'])
    legend('Location','southoutside')
end