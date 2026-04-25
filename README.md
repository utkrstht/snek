# snek
snek is a snek game confined completely to the bootloader.

## how it works
we have a 2 stage bootloader!  

stage 1: 512 bytes, it's too small to put the whole game in here, so we're using this to  load stage 2, which CAN run the whole game!  

stage 2: the actual game!

## how to run
if you're running this for the first time, run `./scripts/setup.sh` to install the dependencies! (only once!)  

then run `./main.sh` and it'll automatically build it and run qemu! 

## what is done
i've taken a bootloader from my old OS and modified it!  

stage 1 is working!  

stage 2 is... working? it's abit wonky and doesn't really properly fit the screen, but yeah
