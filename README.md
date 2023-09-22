# LCDTEST8
A debugging tool for examining TI-84 Plus LCD driver behavior

## Why?
There's been questions about how fast the various display driver ICs of the TI-84 Plus can write to VRAM, and whether they indicate their busy status while doing so. This tool tests both and returns a bitmapped result in Ans:
- bit 2: Whether the test was performed at 15 MHz. Should be 0 for the TI-83 Plus; 1 for the TI-83 Plus Silver Edition, TI-84 Plus, and TI-84 Plus Silver Edition.
- bit 1: Whether the calculator instantly wrote to VRAM. The Kinpo driver should always set this bit, and the Novatek driver should always set this when the test is not performed at 15 MHz. Novatek behavior at 15 MHz is the main subject of LCDTEST8. This bit is always cleared on Toshiba drivers. 
- bit 0: Whether the calculator sets a busy bit while writing to VRAM. Kinpo drivers are too fast for this to be checked on any hardware, and are never busy. Novatek drivers are likely this fast as well. This bit is always set on Toshiba drivers.

## How?
Transfer LCDTEST8.8xp from Releases to your calculator (the TI-83 Plus, TI-83 Plus Silver Edition, TI-84 Plus, and TI-84 Plus Silver Edition are supported). From the home screen, run `Asm(prgmLCDTEST8):Ans` and the result will be displayed. The display may flicker, but the display contents are not altered. Calling `Asm(prgmLCDTEST8)` is possible from within TI-BASIC programs, and the result is stored inside Ans. The contents of the graph screen are destroyed (graphs will be re-plotted if the graph screen is reopened, and drawings erased), and the screen does not restore properly if G-T mode is enabled. 
