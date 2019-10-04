## Seven-Segment Display Controller ##

This repository implements a scanning controller for a multiplexed seven-segment display, with various configurable utility modules and a top-level module designed for Digilent's Nexys A7-100T board with 16 input switches and 8 seven-segment digits. A scanning controller is necessary for [this board's unique seven-segment display configuration](https://reference.digilentinc.com/reference/programmable-logic/nexys-a7/reference-manual#seven-segment_display), with all identical segments on every digit tied to the same pin, and a separate enable pin for each digit. This means that, in order to display different data on each digit, the digits must be iteratively enabled with separate segment-enable masks.


### Quick Start ###

1. Clone this repository
2. `cd` to the repository root folder
3. Add appropriate constraints file at `source/constraints/constraints.xdc`
	- On Mac/Linux, just run `make setup`
	- On Windows, `cp source/constraints/templates/digilent/Nexys-A7-100T-Master.xdc source/constraints/constraints.xdc`
4. Open `seven-segment-controller.xpr` in Vivado
5. Build and deploy project to board


### Usage ###

- Input switches represent value to be encoded on the seven-segment displays
- The A7-100T includes a decimal point in each digit, which can be controller as follows:
	- The current selected digit is displayed on the lowest 4 LEDs
	- The left push-button increases the digit index by 1, while the right decreases the index by 1 (where the digit on the right is the lowest-indexed digit)
	- The center push-button enables or disables the decimal point on the selected digit
	- The CPU reset button resets the selected digit and enabled decimal points

#### Usage in other projects ####

This repository is designed to be used as a [git submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules), from where the components (described below) can be used, either indivdually or together.


#### Notes ####

The Vivado project is configured to look for the constraints file at `source/constraints/constraints.xdc`, which is not included in this repository to allow for other boards to be targeted without affecting the source. All of Digilent's boards have their default constraints files in `source/constraints/templates/digilent` (merged from [Digilent's constraints templates repository](https://github.com/Digilent/digilent-xdc)), and can be copied or linked to the expected location from there.

You may notice that the `Makefile`s make a hard link between the template constraints file and the expected location, and that there is a `post-checkout` git hook installed to remove and recreate this link on every checkout; this is to facilitate developing this project on Mac/Linux system and using a Windows VM with shared directories to actually build and deploy the project. Windows does not fully support Unix-style symlinks, so a hard link must be used instead; however, git does not recognize hard links and will overwrite them when performing `checkout` operations. Thus, the git hook will re-create the hard link after every checkout to ensure the link is always correct.


### Components ###

This repository consists of a few major modules.

- `SevenSegmentController_top`: the top-level controller, instantiating and driving the scanning seven-segment controller, with behavior described above
- `SevenSegmentController`: the scanning seven-segment controller, with a configurable number of digits and digit refresh rate
- `SevenSegmentEncoder`: an encoder mapping input bitstrings to seven-segment enable masks
- `ClockDivider`: a clock divider with configurable number of clock divisions by 2
- `Debouncer`: a counter-based signal debouncer with configurable counter width

Each module has documentation at the top of the file describing its usage in more detail.
