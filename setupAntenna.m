function [rx,bf,phaserModel] = setupAntenna(fc_hb100)
    % Setup the Pluto, Phaser, and Phaser Model.

    % Copyright 2023 The MathWorks, Inc.
    
    % Setup the pluto
    plutoURI = 'ip:pluto.local';
    rx = setupPluto(plutoURI);

    % Setup the phaser
    phaserURI = 'ip:phaser.local';
    bf = setupPhaser(rx,phaserURI,fc_hb100);
    bf.RxPowerDown(:) = 0;
    bf.RxGain(:) = 127; %?
    
    % Create the model of the phaser    
    nElements = 4;
    nSubarrays = 2;
    subModel = phased.ULA('NumElements',nElements,'ElementSpacing',bf.ElementSpacing);
    phaserModel = phased.ReplicatedSubarray("Subarray",subModel,"GridSize",[1,nSubarrays]);
end