K Ambient Light
===============

Attempts to simulate ambient light in current minetest engine. And other things lighting related tweaks.

Tested in [mineclonia](https://content.minetest.net/packages/ryvnf/mineclonia/) and default minetest game but report bugs if you see any.

## Settings

### Global Illumination Level

**Global Illumination Level**, `k_ambient_light.global_illumination`, defaults to `3` if mod is active.

It tries to apply that value to every node `light_source` definition in the loaded world which has a value less than specified level.

For example with a value of `3`, `default:stone` which has `light_source = nil` value will have it set to `3` but `default:torch` which has a value `14` will be unaffected.

Recommended you start out with low values and work your way up.

### Overrides by name/group

It'd be too easy to just have one global lighting value.

**Extra Match by Name**, `k_ambient_light.match_by_name`, and **Extra Match by Group**, `k_ambient_light.match_by_group`, are comma separated list pairs of values to allow specifying extra adjustments.

*Match by Name* list matches finds first partial match on the node name and adds value to `light_source`.

The format is `<pattern1> <delta1>, <pattern2> <delta2>,...,<patternN> <deltaN>` where `<pattern>` is search string as used by [`string.match()`](https://www.lua.org/manual/5.3/manual.html#6.4.1) function in lua to match against a node name. `<delta>` is the  adjustment to `light_source` on top of global illumination value and can be positive or negative number.

*Match by Group* list matches finds first exact match on the node groups to add the delta. Format is `<groupnname1> <delta1>, <groupname2> <delta2>,...<groupnameN> <deltaN>`.
The group name has to be an _exact_ match and not a pattern like "Match by Name".

The lists must be comma separated pairs of `pattern/name value`. There is a space in between the pattern/name and value. The name/pattern cannot contain a space but extra spaces around the pair are ignored. So `foo 1, bar 2,  mod_name:node_identfier 10  ` is valid, but `fo o o 1,bar,999` doesn't contain anything useful.

Adjustments are applied to each registered node in the priority they are listed and only the first matched adjustment is applied. "Match by Name" takes priority over "Match by Group" since node name is more significant than group. 

### Practical/Pointless examples:

 * `k_ambient_light.match_by_name = stone_with_ 2, deepslate_with_ 2`
    * Will match nodes such as `mcl_core:stone_with_coal` or `mcl_core:deepslate_with_iron_ore` and make them slightly illuminated compared to their surroundings by adding `2` to the base global illumination. If you go in caves, ores will be a bit easier to spot.
 * `k_ambient_light.match_by_group = flower 3`
    * Makes all flowers glow slightly by a value of `3`. Which you'll agree is quite nice.
 * `k_ambient_light.match_by_name = leaves_cherry_blossom 3, pink_petals 2`
    * Glowing `CherryGrove` Biomes in Mineclonia.
 * `k_ambient_light.match_by_name = lava -5`
    * Dimmer lava source and flowing lava by `5`. For no good reason.

Basically, as long as you know the node name/group, you can add a rule to adjust the `light_source` for that node.

And all together now, for a eerie glowy experience:

```
k_ambient_light.global_illumination = 3
k_ambient_light.match_by_group = leaves 2, flower 2, plant 1
k_ambient_light.match_by_name = leaves_cherry_blossom 3, pink_petals 2, stone_with_ 2,deepslate_with_ 2
```

## Common Issues/limitations

**Stale lighting** 

* If the lights seem off, or not updated properly, after changing settings and reloading world, use the `/fixlight` chat command as needed. e.g. `/fixlight here 100`. This seems to happen a lot around "homesteads" where you've been in a particular area for a while and the game caches the light levels for longer. This may have always been the behaviour of the minetest engine, just didn't notice it before because I wasn't paying attention to the lighting as much.

**Overrides with pattern matching is not working**

 * It's likely the pattern specified do not match anything in the game/mods you're playing. Names are matched by [`string.match()`](https://www.lua.org/manual/5.3/manual.html#6.4.1). While some pattern matching is supported, it is sadly not regular expressions and some expressions you think should work are actually invalid. It's safer to just rely on literal values without any patterns.

 **Engine limits**
 
 * Currently, light levels set by mods can go from `0` to `14`. Values outside that range are ignored/clipped to bounds. Global illumination of `10` + override of `9` will not result in `light_source=19` but get clipped at `14`. Similarly, `10` + `-11` will get clipped to `0`. Setting Global Illumination at `14` or higher means everything will be fully lit, except skybox, unless you have some negative value overrides for specific nodes.
