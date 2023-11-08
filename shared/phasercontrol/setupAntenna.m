function [rx,bf,phaserModel,tx,plutoURI,phaserURI] = setupAntenna(fc)
    % Setup the Pluto, Phaser, and Phaser Model.

    % Copyright 2023 The MathWorks, Inc.
    
    % Setup the pluto
    plutoURI = 'ip:pluto.local';
    [rx,tx] = setupPluto(plutoURI);

    % Setup the phaser
    phaserURI = 'ip:phaser.local';
    bf = setupPhaser(rx,phaserURI,fc);
    bf.RxPowerDown(:) = 0;
    bf.RxGain(:) = 127; %?
    bf.EnablePLL = true;
    
    % Create the model of the phaser    
    nElements = 4;
    nSubarrays = 2;
    subModel = phased.ULA('NumElements',nElements,'ElementSpacing',bf.ElementSpacing);
    phaserModel = phased.ReplicatedSubarray("Subarray",subModel,"GridSize",[1,nSubarrays]);
end