K Ambient Light
===============

Attempts to simulate ambient light in current minetest engine. And other things lighting related tweaks.


## Settings

### Global Illumination Level

`k_ambient_light.global_illumination` defaults to `3` if mod is active.

Recommended you start out with low values and work your way up.

### Overrides by name/group

It'd be too easy to just have one ambient lighting.

"Extra Match by Name" `k_ambient_light.match_by_name` and "Extra Match by Group" `k_ambient_light.match_by_group` are comma separated list pairs of values to allow specifying extra adjustments.

*Match by Name* list matches finds first partial match on the node name and adds value to `light_level`.

The format is `<pattern1> <delta1>, <pattern2> <delta2>` where `<pattern>` is string as used by `string.match()` function in lua to match against a node name. `<delta>` is the adjustment to `light_level` on top of global illumination value and can be positive or negative.

*Match by Group* list matches finds first exact match on the node groups to add the delta. Format is `<groupnname1> <delta>, <groupname2> <delta>`. The group name is match exactly unlike node name.

Adjustments are applied in the priority they are listed and only the first matched adjustment is applied.

### Practical/Pointless examples:

 * `k_ambient_light.match_by_name = stone_with 2, deepslate_with 2`
    * Will match nodes such as `mcl_core:stone_with_coal` or `mcl_core:stone_with_iron_ore` and make them slightly illuminated compared to their surroundings by adding to the base global illumination.
 * `k_ambient_light.match_by_group = flower 3`
    * Makes all flowers glow slightly. Which you'll agree is quite nice.
 * `k_ambient_light.match_by_name = leaves_cherry_blossom 3, pink_petals 2`
    * Glowing Cherry Grove Biomes.
 * `k_ambient_light.match_by_name = lava -5`
    * Dimmer lava source and flowing lava. For no good reason.

Basically, as long as you know the node name/group, you can add a rule to adjust the `light_level` for that node.

And all together now, for a eerie glowy experience:

```
k_ambient_light.global_illumination = 3
k_ambient_light.match_by_group = leaves 2, flower 2, plant 1
k_ambient_light.match_by_name = leaves_cherry_blossom 3, pink_petals 2, stone_with 2,deepslate_with 2
```

Tested in `mineclonia` and default minetest game. Report bugs if you see any.

