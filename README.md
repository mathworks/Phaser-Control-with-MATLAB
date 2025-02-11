# Phaser (CN0566) control with MATLAB

This repository contains files that demonstrate how to use MATLAB&reg; to control the Analog Devices&reg; (ADI) ADALM PHASER kit ([CN0566](https://www.analog.com/en/design-center/reference-designs/circuits-from-the-lab/cn0566.html#rd-description)).

### Phaser as a Receiver

One set of demonstration files shows how to collect data using the Phaser as a receiver with the HB100 being used as a single tone transmitter. These demonstrations use the MATLAB Phased Array System Toolbox&trade; to generate beamforming weights and compare real received data to simulated received data.

The [receiverDataCollection](demos/receiver/receiverDataCollection.m) script can be run to demonstrate a number of different phased array methods and effects:
- Antenna calibration
- Antenna tapering to reduce pattern sidelobes
- Impact of antenna element spacing in the form of grating lobes
- Null steering for interference cancellation
- Monopulse for angle estimation

The files demonstrating using Phaser as a receiver form the basis for a presentation given at the 2023 International Microwave Symposium (IMS) titled "Phased Array System Modeling and Design using MATLAB and Analog Devices Hardware". These files are also used to collect data for a MATLAB documentation example called [Hardware Array Data Collection and Simulation](https://www.mathworks.com/help/phased/ug/hardware-array-data-collection-and-simulation.html).

### Phaser as a Radar

A second set of demonstration files shows how to collect data using the Phaser as an FMCW radar, transmitting and receiving data synchronously.

The [fmcwDemo](demos/radar/fmcwDemo.m) script shows you how to get up and running using the Phaser as a radar.

The [fmcwRunContinuous](demos/radar/fmcwRunContinuous.m) script shows you how to continuously run the FMCW radar and plot a Range-Doppler response.

The [fmcwBeamsteeringDemo](demos/radar/fmcwBeamsteeringDemo.m) script shows you how to do some simple receive beamforming when the Phaser is configured as a radar.

### Expected Demo Script Results

The expected output of all of each of the demo scripts can be found in [demos/ExpectedDemoOutputs.pdf](demos/ExpectedDemoOutputs.pdf). After running these scripts, check that your results are similar to ensure that your system is set up properly.

## Setup

[The MATLAB Phaser setup guide](https://wiki.analog.com/phaser_matlab) explains the required setup steps in detail. Follow the instructions on this page to setup MATLAB and the Phaser.

For the scripts in this repository to run successfully, MATLAB must be configured properly, and the Phaser must be connected. Make sure to read the comments in the script that you are running, as there may be additional setup steps required - these additional setup steps will be found in the comments.

## Shutdown

When shutting down the Phaser, try to avoid removing power until the board is shut down correctly. To power down correctly, press the small white button on the back of the phaser board (labeled RPI SHUTDOWN) – this will initiate the raspberry pi shutdown procedure.  Then wait about 5 seconds for the Pis lights to stop blinking.  And then you can remove power.

### MathWorks Products (https://www.mathworks.com)

[The MATLAB Phaser setup guide](https://wiki.analog.com/phaser_matlab) lists the MATLAB products required in order to successfully run the files in this repo.

### 3rd Party Products:

[The MATLAB Phaser setup guide](https://wiki.analog.com/phaser_matlab) lists the 3rd party products required in order to successfully run the files in this repo.

### Hardware Connections

The following hardware connections are required:

- USB-C Power cable to insert into the antenna board
- USB - Micro-USB cable to connect from computer to the ADI Pluto
- USB - ethernet cable to connect from computer to Raspberry Pi
- Vivaldi Antenna - SMA Out 1 or Out 2 (optional, if using transmit)

[View from front](frontsideconnections.jpg)

[View from back](backsideconnections.jpg)

[Transmitter connection](transmitterconnections.jpg)

To see connected iio devices, run the following command from the command line:

```
$ iio_info -s
```

The output should resemble the example output:

```
Library version: 0.24 (git tag: c4498c2)
Compiled with backends: xml ip usb serial
Unable to create Local IIO context : Function not implemented (40)
Available contexts:
        0: fe80::d20c:d840:92cb:4363%53 (one-bit-adc-dac,adf4159,adar1000_1,ad7291,adar1000_0) [ip:phaser.local]
        1: 192.168.2.1 (Analog Devices PlutoSDR Rev.C (Z7010-AD9361)), serial=1044734c9605001313000c00984b4f92d0 [ip:pluto.local]
        2: 0456:b673 (Analog Devices Inc. PlutoSDR (ADALM-PLUTO)), serial=1044734c9605001313000c00984b4f92d0 [usb:1.11.5]
```

If not all of these connections are being shown, try unplugging and plugging in all USB cables.

## Getting Started

This repository contains demonstration scripts for using MATLAB to control and collect data from the Phaser board. Demo scripts can be found under the [demos/](demos/) directory. Try running any of these demo scripts to get up and running.

- The scripts in [demos/radar/](demos/radar/) are run with the Phaser configured as a transmitter and receiver. The files under [demos/radar/helpers/](demos/radar/helpers/) are used in the main scripts to assist with control, data collection, or visualization.
- The scripts in [demos/receiver/](demos/receiver/) are run with the Phaser configured as a receiver only and the HB100 operating as a transmitter. The files under [demos/receiver/helpers/](demos/receiver/helpers/) are used in the main scripts to assist with control, data collection, or visualization.
- The files found in [shared/calibration/](shared/calibration/) are used to help calibrate the phase and amplitude of each element and digital channel in the Phaser and are relevant whether operating the radar or receiver scripts. Calibration must be performed to successfully beamform using the Phaser.
    - There is a function in this directory called [generateCalibrationWeights](shared/calibration/generateCalibrationWeights.m) that will generate and save the calibration weights for your Phaser board. This function is called as part of the demo scripts, but it can also be run independently to explore how we are calibrating the Phaser elements.
- The files found in [shared/phasercontrol/](shared/phasercontrol/) are used throughout the demo and calibration scripts and are used to help control and collect data from the Phaser.

## Troubleshooting

### Could not find file ad9361-wrapper.h

If you see the following error in MATLAB:

```
Error using loadlibrary
Could not find file ad9361-wrapper.h.
```

Run the following commands in MATLAB:

```
A=adi.utils.libad9361
A.download_libad9361
```

### Channel: voltage1 not found

If you see the following error in MATLAB:

```
Error using matlabshared.libiio.base/cstatus
Channel: voltage1 not found
```

It means that the Pluto SDR is only configured for single channel operation.

To fix this issue, SSH into the Pluto using the following command. You may have to change the Pluto IP address:

```
ssh root@192.168.2.1
```

When prompted for a password, type "analog".

Once successful, enter the following commands in series to reprogram the Pluto:

```
fw_setenv attr_name compatible
fw_setenv attr_val ad9361
fw_setenv compatible ad9361
fw_setenv mode 2r2t
reboot
```

This should resolve the error condition.

### Failed to create context for uri: ip:phaser.local
If you see the following error in MATLAB, it is possible that the Raspberry Pi has SD card has been corrupted:

```
Error using matlabshared.libiio.base/cstatusid
Failed to create context for uri: ip:phaser.local 
The address is not available. Make sure the device is connected and try again.

Error in matlabshared.libiio.base/getContext

Error in adi.internal.ADAR100x/setupImpl (line 1284)
            getContext(obj);
```

In order to resolve this issue, [burn a new image to the SD card](https://wiki.analog.com/resources/eval/user-guides/circuits-from-the-lab/cn0566/quickstart#sd_cardsoftware_setup). This should resolve the problem.

## License

The license is available in the [license.txt](license.txt) file in this GitHub repository.

## Community Support
[MATLAB Central](https://www.mathworks.com/matlabcentral)

Copyright 2023 The MathWorks, Inc.

