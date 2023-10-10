# partyquest
A demo cutscene system for the [PICO-8 fantasy console](https://www.lexaloffle.com/pico-8.php), including handcrafted sprite and animation systems. Last updated in 2020, uploaded in 2022 for archival purposes.

Implements several features such as: 
* synchronized and translatable multi-sprite animations
* dialogue system

File explanation:
* party_new.p8 - a PICO-8 cartridge implementing loading dialogue scripts from an external "databank" cart
* d_bank_1.p8 - a cartridge acting as a data store for dialogue scripts, including a test script
* party_orig_say.p8 - same as party_new.p8 but storing dialogue scripts internal to the cart, including a more significant sample script

### Credits
Oli414's [Dialogue Text Box Lib](https://www.lexaloffle.com/bbs/?tid=28465)

## GIFs
![gif demonstration of party_orig_say.p8](https://github.com/tcnj-violaa/partyquest/blob/main/party_orig_say_1.gif?raw=true)
![gif of 2 spritesheets](https://github.com/tcnj-violaa/partyquest/blob/main/spritesheet.gif)
![demonstration of simple looping headline effects](https://github.com/tcnj-violaa/partyquest/blob/main/headlinedemo.gif)
![gif of sprites being independently translated](https://github.com/tcnj-violaa/partyquest/blob/main/sprite-translation.gif)
