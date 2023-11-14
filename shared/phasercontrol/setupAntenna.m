function [rx,bf,phaserModel,tx,bf_TDD] = setupAntenna(fc)
    % Setup the Pluto, Phaser, and Phaser Model.

    % Copyright 2023 The MathWorks, Inc.
    
    % Setup the pluto
    [rx,tx] = setupPluto();

    % Setup the phaser
    bf = setupPhaser(rx,fc);
    bf.RxPowerDown(:) = 0;
    bf.RxGain(:) = 127;
    bf.EnablePLL = true;

    % Setup the tdd engine
    bf_TDD = setupTddEngine();
    
    % Create the model of the phaser    
    nElements = 4;
    nSubarrays = 2;
    subModel = phased.ULA('NumElements',nElements,'ElementSpacing',bf.ElementSpacing);
    phaserModel = phased.ReplicatedSubarray("Subarray",subModel,"GridSize",[1,nSubarrays]);
end