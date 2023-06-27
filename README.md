# MATLAB Phaser Board Data Collection

This repo contains the MATLAB`&reg;` files used during a presentation given at the 2023 International Microwave Symposium (IMS). These files demonstrate how to use MATLAB to control the Analog Devices`&copy;` (ADI) Phaser Board and compares collected data to simulated data in various data collection scenarios. MATLAB Phased Array System Toolbox`&trade;` (PST) is utilized to simulate the data received by the ADI Phaser Board.

These files demonstrate a simple calibration routine to ensure expected functionality of the Phaser board. Once calibrated, the following phased array techniques are demonstrated:
- Antenna tapering to reduce pattern sidelobes
- Impact of antenna element spacing in the form of grating lobes
- Null steering for interference cancellation
- Monopulse for angle estimation

These files also allow users to collect data from a MATLAB PST example that was based on the work presented at the IMS 2023 workshop.

## Setup

[The MATLAB Phaser setup guide](https://wiki.analog.com/phaser_matlab) explains the required setup steps in detail. Follow the instructions on this page to setup MATLAB and the Phaser.

For these scripts to run successfully, MATLAB must be configured properly and the Phaser must be connected. A single tone X-Band frequency source such as the HB100 should be placed at the Phaser broadside angle.

### MathWorks Products (https://www.mathworks.com)

[The MATLAB Phaser setup guide](https://wiki.analog.com/phaser_matlab) lists the MATLAB products required in order to successfully run the files in this repo.

### 3rd Party Products:

[The MATLAB Phaser setup guide](https://wiki.analog.com/phaser_matlab) lists the 3rd party products required in order to successfully run the files in this repo.

## Getting Started 

Once the required setup steps have been completed and the Phaser board is hooked up, open the main script, called "workshopDataCollection.m".

Run this script completely or section by section. Each specific data collection function referenced in "workshopDataCollection.m" contains a detailed description and key setup information.

## License

The license is available in the License.txt file in this GitHub repository.

## Community Support
[MATLAB Central](https://www.mathworks.com/matlabcentral)

Copyright 2023 The MathWorks, Inc.

