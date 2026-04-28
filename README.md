# snek
snek is a snek game confined completely to the bootloader.

## how it works
we have a 2 stage bootloader!  

stage 1: 512 bytes, it's too small to put the whole game in here, so we're using this to  load stage 2, which CAN run the whole game!  

stage 2: the actual game!

## how to run
if you're running this for the first time, run `./scripts/setup.sh` to install the dependencies! (only once!)  

then run `./main.sh` and it'll automatically build it and run qemu! 

## features
- colors
- title screen
- deaths
- snek <3 :3
- food rng
- score, best, length bar!
- moar colors
- difficulty levels
- rainbow hint
- returning to menu 
- popups
- random hints :p

## future features
note: everything on this list is subject to change
- store which has skins (red skin, blue skin, rainbow skin)
- sounds (if i can convince qemu to relay sound to my pc)
- ~~returning to menu~~
- better looking food
- ~~better looking snek~~
- ~~better looking menu~~
- ~~random hints~~
- GUI snek

#### latest commit name
ignore this
- feat: add proper menu/settings/credits, new snek design!