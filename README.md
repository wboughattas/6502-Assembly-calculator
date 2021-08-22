# 6502-Assembly-calculator
A program written in assembly language instruction 6502 to find the sum of 4-digit numbers for Commodore 64 home computer.

## Instructions:
- accept the values to be used as input from the keyboard and write the calculated result to the screen
- input as many 4-digit numbers as possible
- handle errors: 
-- restrict input when 4 digits are exceeded
-- input is exclusive to numbers and operators
-- out-of-range branching was handled using a [workaround](https://atariage.com/forums/topic/265756-need-some-help-with-labels-and-branching/)
-- Write a report that clearly describes how the program works and design decisions are supported with adequate reasoning

## Required tools
- [VICE Commodore 64 Emulator](https://vice-emu.sourceforge.io/)
- [CC65 6502 toolchain](https://www.cc65.org/)

## Using the Assembler and Running the Code
CC65 comes with several applications, including cl65 which we will use. CC65 is used entirely from the command line. The following command will assemble a file called ```prj.asm``` and produce a file called ```prj.prg```.
```
cl65 -t c64 -C c64-asm.cfg prj.asm -o prj.prg
```
If you are using windows, you may need to include the location of where you downloaded and extracted cc65 when running the command. For example, the following command assumes the package was extracted to your working directory.
```
.\cc65-win32-snapshot\bin\cl65 -t c64 -C c64-asm.cfg prj.asm -o prj.prg
```
From the VICE package, use the x64sc application to run the Commodore 64 Emulator which can then load the output file such as ```prj.prg``` from the assembler. To open assembled file, use the File menu and then select Smart attach disk/tape/cartridge and then open your file or drag and drop the file into the window.

## Authors
* **Wasim Boughattas** - [wboughattas](https://github.com/wboughattas)

## Demo
![](https://github.com/wboughattas/6502-Assembly-calculator/blob/main/Demo.gif)

