# qb-weed
Weed Growing For QB-Core

# Outdoor Edition
v1.3 added outdoor grow ability:
indoor grows have small random chance (10%) to drop high yield hybrid seeds.
these seeds can only be used outside - anywhere thats not inside a qb-interiors house/apartment.
- harvesting it will pay out Bricks of High Yield Hybrid which:
- can be traded between gangs as a commodity, etc
- or broken down into random bags of ~30 2g (skunk, og, purple haze, whitewidow etc) which
- can cornersold or broken down again into joints like usual.

## SQL Installation
### Add the extra sql table
```sql
CREATE TABLE `outdoor_plants` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`citizenid` VARCHAR(10) NULL DEFAULT NULL,
	`stage` VARCHAR(50) NULL DEFAULT 'stage-a',
	`sort` VARCHAR(50) NULL DEFAULT NULL,
	`gender` VARCHAR(50) NULL DEFAULT NULL,
	`food` INT(11) NULL DEFAULT 100,
	`health` INT(11) NULL DEFAULT 100,
	`progress` INT(11) NULL DEFAULT 0,
	`coords` TEXT NULL DEFAULT NULL,
	`plantid` VARCHAR(50) NULL DEFAULT NULL,
	PRIMARY KEY (`id`),
	INDEX `owner` (`citizenid`),
	INDEX `plantid` (`plantid`)
)
COLLATE='utf8_general_ci' ENGINE=InnoDB AUTO_INCREMENT=2 ;
```

## Add Items
### on top of the other items installed by default qb-core, add the following:
```lua
['weed_high-yield_seed'] 	= {['name'] = 'weed_high-yield_seed', 		['label'] = 'High Yield Hybrid Seed', 		['weight'] = 0, 		['type'] = 'item', 		['image'] = 'weed_seed.png', 		    ['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = 'A Hybrid weed seed'},
['brick_HYH'] 				= {['name'] = 'brick_HYH', 			 		['label'] = 'Big Bag of High Yield Hybrid', ['weight'] = 1100, 		['type'] = 'item', 		['image'] = 'weed_brick.png', 			['unique'] = false, 	['useable'] = true, 	['shouldClose'] = false,   ['combinable'] = nil,   ['description'] = 'An Ounce of HYBRID'},
```

# License

    QBCore Framework
    Copyright (C) 2021 Joshua Eger

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>
