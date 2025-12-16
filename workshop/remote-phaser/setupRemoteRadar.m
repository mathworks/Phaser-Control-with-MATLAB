function radar = setupRemoteRadar(id,prf,nPulses,fs,rampbandwidth,ns)
% Create a remote phaser in the 'radar' configuration with the specified
% parameters.

% Create the remote phaser.
radar = phaser.RemotePhaser(id);

% Set the configuration to 'radar'
set(radar,'configuration','radar');

% Set the specified parameters
set(radar, 'prf', prf);
set(radar, 'number_chirps', nPulses);
set(radar, 'sample_rate', fs);
set(radar, 'ramp_bandwidth', rampbandwidth);
set(radar, 'samples_per_pulse', ns); 

end