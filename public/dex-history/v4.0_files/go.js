pokemon = new Array("bulbasaur", "ivysaur", "venusaur", "charmander", "charmeleon", "charizard", "squirtle", "wartortle", "blastoise", "caterpie", "metapod", "butterfree", "weedle", "kakuna", "beedrill", "pidgey", "pidgeotto", "pidgeot", "rattata", "raticate", "spearow", "fearow", "ekans", "arbok", "pikachu", "raichu", "sandshrew", "sandslash", "nidoran f", "nidorina", "nidoqueen", "nidoran m", "nidorino", "nidoking", "clefairy", "clefable", "vulpix", "ninetales", "jigglypuff", "wigglytuff", "zubat", "golbat", "oddish", "gloom", "vileplume", "paras", "parasect", "venonat", "venomoth", "diglett", "dugtrio", "meowth", "persian", "psyduck", "golduck", "mankey", "primeape", "growlithe", "arcanine", "poliwag", "poliwhirl", "poliwrath", "abra", "kadabra", "alakazam", "machop", "machoke", "machamp", "bellsprout", "weepinbell", "victreebel", "tentacool", "tentacruel", "geodude", "graveler", "golem", "ponyta", "rapidash", "slowpoke", "slowbro", "magnemite", "magneton", "farfetch'd", "doduo", "dodrio", "seel", "dewgong", "grimer", "muk", "shellder", "cloyster", "gastly", "haunter", "gengar", "onix", "drowzee", "hypno", "krabby", "kingler", "voltorb", "electrode", "exeggcute", "exeggutor", "cubone", "marowak", "hitmonlee", "hitmonchan", "lickitung", "koffing", "weezing", "rhyhorn", "rhydon", "chansey", "tangela", "kangaskhan", "horsea", "seadra", "goldeen", "seaking", "staryu", "starmie", "mr. mime", "scyther", "jynx", "electabuzz", "magmar", "pinsir", "tauros", "magikarp", "gyarados", "lapras", "ditto", "eevee", "vaporeon", "jolteon", "flareon", "porygon", "omanyte", "omastar", "kabuto", "kabutops", "aerodactyl", "snorlax", "articuno", "zapdos", "moltres", "dratini", "dragonair", "dragonite", "mewtwo", "mew", "chikorita", "bayleef", "meganium", "cyndaquil", "quilava", "typhlosion", "totodile", "croconaw", "feraligatr", "sentret", "furret", "hoot hoot", "noctowl", "ledyba", "ledian", "spinarak", "ariados", "crobat", "chinchou", "lanturn", "pichu", "cleffa", "igglybuff", "togepi", "togetic", "natu", "xatu", "mareep", "flaaffy", "ampharos", "bellossom", "marill", "azumarill", "sudowoodo", "politoed", "hoppip", "skiploom", "jumpluff", "aipom", "sunkern", "sunflora", "yanma", "wooper", "quagsire", "espeon", "umbreon", "murkrow", "slowking", "misdreavus", "unown", "wobbuffet", "girafarig", "pineco", "forretress", "dunsparce", "gligar", "steelix", "snubbull", "granbull", "qwilfish", "scizor", "shuckle", "heracross", "sneasel", "teddiursa", "ursaring", "slugma", "magcargo", "swinub", "piloswine", "corsola", "remoraid", "octillery", "delibird", "mantine", "skarmory", "houndour", "houndoom", "kingdra", "phanpy", "donphan", "porygon 2", "stantler", "smeargle", "tyrogue", "hitmontop", "smoochum", "elekid", "magby", "miltank", "blissey", "raikou", "entei", "suicune", "larvitar", "pupitar", "tyranitar", "lugia", "ho-oh", "celebi");
attacks = new Array("pound", "karate chop", "doubleslap", "comet punch", "mega punch", "pay day", "fire punch", "ice punch", "thunderpunch", "scratch", "vicegrip", "guillotine", "razor wind", "swords dance", "cut", "gust", "wing attack", "whirlwind", "fly", "bind", "headbutt", "vine whip", "stomp", "double kick", "mega kick", "jump kick", "rolling kick", "sand-attack", "slam", "horn attack", "fury attack", "horn drill", "tackle", "body slam", "wrap", "take down", "thrash", "double-edge", "tail whip", "poison sting", "twineedle", "pin missile", "leer", "bite", "growl", "roar", "sing", "supersonic", "sonicboom", "disable", "acid", "ember", "flamethrower", "mist", "water gun", "hydro pump", "surf", "ice beam", "blizzard", "psybeam", "bubblebeam", "aurora beam", "hyper beam", "peck", "drill peck", "submission", "low kick", "counter", "seismic toss", "strength", "absorb", "mega drain", "leech seed", "growth", "razor leaf", "solarbeam", "poisonpowder", "stun spore", "sleep powder", "petal dance", "string shot", "dragon rage", "fire spin", "thundershock", "thunderbolt", "thunder wave", "thunder", "rock throw", "earthquake", "fissure", "dig", "toxic", "confusion", "psychic", "hypnosis", "meditate", "agility", "quick attack", "rage", "teleport", "night shade", "mimic", "screech", "double team", "recover", "harden", "minimize", "smokescreen", "confuse ray", "withdraw", "defense curl", "barrier", "light screen", "haze", "reflect", "focus energy", "bide", "metronome", "mirror move", "selfdestruct", "egg bomb", "lick", "smog", "sludge", "bone club", "fire blast", "waterfall", "clamp", "swift", "skull bash", "spike cannon", "constrict", "amnesia", "kinesis", "softboiled", "hi jump kick", "glare", "dream eater", "poison gas", "barrage", "leech life", "lovely kiss", "sky attack", "transform", "bubble", "dizzy punch", "spore", "flash", "psywave", "splash", "acid armor", "crabhammer", "explosion", "fury swipes", "bonemerang", "rest", "rock slide", "hyper fang", "sharpen", "conversion", "tri attack", "super fang", "slash", "substitute", "struggle", "sketch", "triple kick", "thief", "spider web", "mind reader", "nightmare", "flame wheel", "snore", "curse", "flail", "conversion2", "aeroblast", "cotton spore", "reversal", "spite", "powder snow", "protect", "mach punch", "scary face", "faint attack", "sweet kiss", "belly drum", "sludge bomb", "mud-slap", "octazooka", "spikes", "zap cannon", "foresight", "destiny bond", "perish song", "icy wind", "detect", "bone rush", "lock-on", "outrage", "sandstorm", "giga drain", "endure", "charm", "rollout", "false swipe", "swagger", "milk drink", "spark", "fury cutter", "steel wing", "mean look", "attract", "sleep talk", "heal bell", "return", "present", "frustration", "safeguard", "pain split", "sacred fire", "magnitude", "dynamicpunch", "megahorn", "dragonbreath", "baton pass", "encore", "pursuit", "rapid spin", "sweet scent", "iron tail", "metal claw", "vital throw", "morning sun", "synthesis", "moonlight", "hidden power", "cross chop", "twister", "rain dance", "sunny day", "crunch", "mirror coat", "psych up", "extremespeed", "ancientpower", "shadow ball", "future sight", "rock smash", "whirlpool", "beat up");
types = new Array("normal", "dark", "flying", "fighting", "ground", "rock", "ghost", "poison", "grass", "bug", "fire", "ice", "electric", "water", "dragon", "psychic", "steel");
newtms = new Array(222, 20, 173, 204, 45, 91, 191, 248, 243, 236, 240, 229, 172, 58, 62, 195, 181, 239, 201, 202, 217, 75, 230, 224, 86, 88, 215, 90, 93, 246, 188, 103, 7, 206, 213, 187, 200, 125, 128, 110, 8, 137, 196, 155, 212, 167, 210, 6, 209, 170, 14, 18, 56, 69, 147, 249, 126);
oldtms = new Array(4, 12, 13, 17, 24, 91, 31, 33, 35, 37, 60, 54, 57, 58, 62, 5, 65, 67, 68, 98, 71, 75, 81, 84, 86, 88, 89, 90, 93, 99, 101, 103, 114, 116, 117, 119, 120, 125, 128, 129, 134, 137, 142, 155, 85, 148, 152, 156, 160, 163, 14, 18, 56, 69, 147);

function gobox(input, prefix) {
 if (prefix == null) { prefix = ""; }
 input = input.toLowerCase();
 if (result = input.match(/^(new)?tm(\d?\d)$/, "i")) { goto(prefix + prefix + "a" + padnum(newtms[result[2] - 1] + 1, 3)); return; }
 if (result = input.match(/^oldtm(\d?\d)$/, "i")) { goto(prefix + "a" + padnum(oldtms[result[1] - 1] + 1, 3)); return; }
 if (result = input.match(/^a(\d?\d?\d)$/, "i")) { goto(prefix + "a" + padnum(result[1], 3)); return; }
 if (result = input.match(/^(\d?\d?\d)$/, "i")) { goto(prefix + padnum(result[1], 3)); return; }

 for (i = 0; i < 251; i++) {
  if (input == pokemon[i]) { goto(prefix + padnum(i + 1, 3)); return; }
  if (input == attacks[i]) { goto(prefix + "a" + padnum(i + 1, 3)); return; }
 }
 for (i = 0; i < 17; i++) {
  if (input == types[i]) { goto(prefix + types[i]); return; }
  if (input == types[i] + "-type") { goto(prefix + types[i]); return; }
  if (input == types[i] + " type") { goto(prefix + types[i]); return; }
 }
 alert("Invalid entry");
}

function padnum(num, len) {
 num = num + "";
 for (i = 1; i < len; i++) {
  if (num.length == i) { num = "0" + num; }
 }
 return num;
}
