[![Release](https://github.com/notnotmelon/thrower-inserter/actions/workflows/release.yml/badge.svg?branch=main)](https://github.com/notnotmelon/thrower-inserter/actions/workflows/release.yml)

### Adds thrower inserters

![](https://mods-data.factorio.com/assets/4b89c9d3e7ae1cbb8457f0ae75444976ee64570f.png)
#### Renai Transportation
This mod is a fork of Renai Transportation
If you want train launch pads, player launchers, and grenade bounce pads then download that mod instead
https://mods.factorio.com/mod/RenaiTransportation

Renai Transportation is an amazing mod, but it's also a shitpost
I thought the thrower inserters from that mod would work well as a standalone mod. I also found room for UPS and qol improvements
![](https://mods-data.factorio.com/assets/4b89c9d3e7ae1cbb8457f0ae75444976ee64570f.png)
#### Improvements from the original mod
- Thrower inserters will not overflow items onto the ground from machines/chests. They will stop when the target inventory is full
- When you place a thrower inserter, the dropoff point will snap to the furthest entity that it can throw into
- There isn't an extra keybind for changing dropoff position. Instead, simply rotate the inserter
- There is only one thrower inserter. I thought that having a thrower inserter for every variant of normal inserter was excessive
- You don't need a hatch or an open chest to allow items through

![](https://mods-data.factorio.com/assets/4b89c9d3e7ae1cbb8457f0ae75444976ee64570f.png)
#### UPS
Compared to Renai Transportation, UPS is better because of three optimizations

- Inserters update every 7 ticks instead of every 3
- Inserters are stored in a array instead of a table
- If an inserter has a stack size then it will only throw one projectile instead of a projectile for every item in the stack

![](https://mods-data.factorio.com/assets/4b89c9d3e7ae1cbb8457f0ae75444976ee64570f.png)
#### Issues
- If a thrower has less than 33% power, then it will become l o n g. I could fix this easily, but it will hurt UPS

![](https://mods-data.factorio.com/assets/4b89c9d3e7ae1cbb8457f0ae75444976ee64570f.png)

### [> Check out my other mods! <](https://mods.factorio.com/user/notnotmelon)
