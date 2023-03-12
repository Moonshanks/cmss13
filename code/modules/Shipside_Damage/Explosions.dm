//sets explosion chance and size, recommend you have this equal to a glob variable or something that changes.
var/explosion_chance = 50
var/explosion_power = 50
var/explosion_falloff = 50
//handles if the timer for the explosions are started or not
GLOBAL_VAR_INIT(explosions_on, FALSE)


//Handles the explosion when it's turned on as happening each 30 seconds with a probability based on the explosion chance

if(!explosions_on)
return

if(prob(explosion_chance))
	cell_explosion(pick(GLOB.exploding_landmarks), explosion_power, explosion_falloff)
return

