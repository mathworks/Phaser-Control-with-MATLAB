# MATLAB Phaser Board Data Collection

This repo contains the MATLAB&reg; files used during a presentation given at the 2023 International Microwave Symposium (IMS). These files demonstrate how to use MATLAB to control the Analog Devices&copy; (ADI) Phaser Board and compares collected data to simulated data in various data collection scenarios. MATLAB Phased Array System Toolbox&trade; (PST) is utilized to simulate the data received by the ADI Phaser Board.

These files demonstrate a simple calibration routine to ensure expected functionality of the Phaser board. Once calibrated, the following phased array techniques are demonstrated:
- Antenna tapering to reduce pattern sidelobes
- Impact of antenna element spacing in the form of grating lobes
- Null steering for interference cancellation
- Monopulse for angle estimation

These files also allow users to collect data from a MATLAB PST example that was based on the work presented at the IMS 2023 workshop.

## Setup

[The MATLAB Phaser setup guide](https://wiki.analog.com/phaser_matlab) explains the required setup steps in detail. Follow the instructions on this page to setup MATLAB and the Phaser. Follow these instructions up to the portion titled "Running the labs".

For the scripts in this repository to run successfully, MATLAB must be configured properly and the Phaser must be connected. A single tone X-Band frequency source such as the HB100 should be placed at the Phaser broadside angle.

### MathWorks Products (https://www.mathworks.com)

[The MATLAB Phaser setup guide](https://wiki.analog.com/phaser_matlab) lists the MATLAB products required in order to successfully run the files in this repo.

### 3rd Party Products:

[The MATLAB Phaser setup guide](https://wiki.analog.com/phaser_matlab) lists the 3rd party products required in order to successfully run the files in this repo.

### Hardware Connections

The following hardware connections are required:

- USB-C Power cable to insert into the antenna board
- USB - Micro-USB cable to connect from computer to the ADI Pluto
- USB - ethernet cable to connect from computer to rasberry pi

[View from front](frontsideconnections.jpg)

[View from back](backsideconnections.jpg)

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

## Getting Started 

Once the required setup steps have been completed and the Phaser board is hooked up, open the main script, called "workshopDataCollection.m".

Run this script completely or section by section. Each specific data collection function referenced in "workshopDataCollection.m" contains a detailed description and key setup information.

## Error Conditions

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

## License

The license is available in the license.txt file in this GitHub repository.

## Community Support
[MATLAB Central](https://www.mathworks.com/matlabcentral)

Copyright 2023 The MathWorks, Inc.

