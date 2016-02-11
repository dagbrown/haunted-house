#!/usr/bin/ruby

# Haunted House, the old adventure game from the 1983 Usborne book
# "Write Your Own Adventure Programs For Your Microcomputer" by Jenny
# Tyler and Les Howarth
#
# This is translated directly from BASIC, and it shows.


# In the original code, they did the variable initialization in a
# subroutine right at the end of the prorgram.  I've just moved it all
# to the beginning.
$verbs=%w{help inventory go n s w e u d get take open examine read say
         dig swing climb light unlight spray use unlock leave score}

$exits=%w{se we we swe we we swe ws
         ns se we nw se w ne nsw
         ns ns se we nsud se wsud ns
         n ns nse we we nsw ns ns
         s nse nsw s nsud n n ns
         ne nw ne w nse we w ns
         se nsw e we nw s sw nw
         ne nwe we we we nwe nwe w}

$exit_name = { "s" =>"south", "n" =>"north", "e" =>"east", "w" =>"west", 
              "u" =>"up", "d" =>"down"}

$rooms=["Dark corner", "Overgrown garden", "By large woodpile", 
       "Yard by rubbish", "Weedpatch", "Forest", "Thick forest",
       "Blasted tree", "Corner of house", "Entrance to kitchen",
       "Kitchen and Grimy Cooker", "Scullery Door", "Room with inches of dust",
       "Rear turret room", "Clearing by house", "Path", "Side of house",
       "Back of hallway", "Dark alcove", "Small dark room",
       "Bottom of spiral staircase", "Wide passage", "Slippery steps",
       "Clifftop", "Near crumbling wall", "Gloomy passage", "Pool of light",
       "Impressive vaulted hallway", "Hall by thick wooden door",
       "Trophy room", "Cellar with barred window", "Cliff path",
       "Cupboard with hanging coat", "Front hall", "Sitting room",
       "Secret room", "Steep marble stairs", "Dining room",
       "Deep cellar with coffin", "Cliff path", "Closet", "Front lobby",
       "Library of evil books", "Study with desk and hole in wall",
       "Weird cobwebby room", "Very cold chamber", "Spooky room",
       "Cliff path by marsh", "Rubble-strewn verandah", "Front porch",
       "Front tower", "Sloping corridor", "Upper gallery", "Marsh by wall",
       "Marsh", "Soggy path", "By twisted railings", "Path through iron gate",
       "By railings", "Beneath front tower", "Debris from crumbling facade",
       "Large fallen brickwork", "Rotting stone arch", "Crumbling clifftop"]

# The first 18 of these are "gettable" objects, the rest are just things
# you can sort of generally refer to
$gettable_objects = 18
$nouns=["", "painting", "ring", "magic spells", "goblet", "scrolls",
        "coins", "statue", "candlestick", "matches", "vacuum",
        "batteries", "shovel", "axe", "rope", "boat", "aerosol",
        "candle", "key", "north", "south", "west", "east", "up", "down",
        "door", "bats", "ghosts", "drawer", "desk", "coat", "rubbish",
        "coffin", "books", "xzanfar", "wall", "spells"]

# man, if only old BASIC programmers had any idea of data structures
$locations=[65,46,38,35,50,13,18,28,42,10,25,26,4,2,7,47,60,43,32]
$object_flags = [ false ] * $nouns.size # I love Ruby!
$carrying_object = [ false ] * $gettable_objects
[18,17,2,26,28,23].each do |i|
    $object_flags[i] = true
end

$player_location = 57
$candle_length = 60

$msg = "OK"

def do_action(verb_num, noun_num, noun_str)
    case verb_num
    when 0
        do_help
    when 1
        do_inventory
    when 2..8
        do_move(verb_num, noun_num)
    when 9..10
        do_get(noun_num, noun_str)
    when 11
        do_open(noun_num)
    when 12
        do_examine(noun_num)
    when 13
        do_read(noun_num)
    when 14
        do_say(noun_num, noun_str)
    when 15
        do_dig(noun_num)
    when 16
        do_swing(noun_num)
    when 17
        do_climb(noun_num)
    when 18
        do_light(noun_num)
    when 19
        do_unlight(noun_num)
    when 20
        do_spray(noun_num)
    when 21
        do_use(noun_num)
    when 22
        do_unlock(noun_num)
    when 23
        do_leave(noun_num)
    when 24
        do_score
    end
end

def do_help
    puts "Words I know:"
    puts $verbs.join(", ")
    $msg = ""
    pause
end

def do_inventory
    puts "You are carrying:"
    (0..$gettable_objects).each do |i|
        if $carrying_object[i] then
            print $nouns[i],", "
        end
    end
    $msg = ""
    pause
end

def do_move(verb_num, noun_num)
    direction = 0
    if not noun_num then direction=verb_num - 2 end
    if (19..24).include? noun_num then
        direction = noun_num - 19
    end

    # special cases for up and down because they don't really exist
    if $player_location == 20 then
        if direction == 5 then direction = 1 end
        if direction == 6 then direction = 3 end
    end

    if $player_location == 22 then
        if direction == 5 then direction = 3 end
        if direction == 6 then direction = 2 end
    end

    if $player_location == 36 then
        if direction == 5 then direction = 2 end
        if direction == 6 then direction = 1 end
    end

    # Some logic for the special cases where you're simply not allowed
    # to move at all
    if $object_flags[14] then
        $msg = "Crash! You fell out of the tree!"
        $object_flags[14] = false
        return
    end

    if $object_flags[27] and $player_location == 52 then
        $msg = "Ghosts will not let you move"
        return
    end

    if $player_location == 45 and $carrying_object[1] and
        not $object_flags[34] then
        $msg = "There is a magical barrier to the west."
        return
    end

    if ( $player_location == 26 and not $object_flags[0] ) and
        ( direction == 1 or direction == 4 ) then
        $msg = "It is too dark to move.  You need a light."
        return
    end

    if $player_location == 54 and not $carrying_object[15] then
        $msg = "You're stuck!"
        return
    end

    if $carrying_object[15] and not ( $player_location == 53 or
                                      $player_location == 54 or
                                      $player_location == 55 or
                                      $player_location == 47 ) then
        $msg = "You can't carry a boat!"
        return
    end

    if ( $player_location > 26 and $player_location < 30) and 
        not $object_flags[0] then
        $msg = "It's too dark to move."
        return
    end

    # Alright, special cases over and done with, let's handle a normal
    # move.
    $object_flags[35] = false
    exits = $exits[$player_location].split(//)
    if direction == 1 and exits.include? "n"
        $player_location -= 8
        $object_flags[35] = true
    elsif direction == 2 and exits.include? "s"
        $player_location += 8
        $object_flags[35] = true
    elsif direction == 3 and exits.include? "w"
        $player_location -= 1
        $object_flags[35] = true
    elsif direction == 4 and exits.include? "e"
        $player_location += 1
        $object_flags[35] = true
    end

    $msg = "OK"

    if not $object_flags[35] then
        $msg = "Can't go that way!"
    end

    if direction == 0 then
        $msg = "Go where?"
    end

    if $player_location == 41 and $object_flags[23] then
        $exits[49] = "sw"
        $msg = "The door slams shut behind you!"
        $object_flags[23] = false
    end
end

def do_get(noun_num, noun_str)
    if not noun_num then
        $msg = "I can't get #{noun_str}"
        return
    end

    if $locations[noun_num] != $player_location then
        $msg = "It isn't here."
    end

    if $object_flags[noun_num] then
        $msg = "What #{noun_str}?"
    end

    if $carrying_object[noun_num] then
        $msg = "You already have it."
    end

    if noun_num > 0 and
       $locations[noun_num] == $player_location and
       not $object_flags[noun_num] then
        $carrying_object[noun_num] = true
        $locations[noun_num] = nil
        $msg = "You have the #{noun_str}"
    end
end

def do_open(noun_num)
    if $player_location == 43 and
        ( noun_num == 28 or noun_num == 29 ) then
        $object_flags[17] == false
        $msg = "Drawer open."
    end

    if $player_location == 28 and noun_num == 25 then
        $msg = "It's locked."
    end

    if $player_location == 38 and noun_num == 32 then
        $msg = "That's just creepy!"
        $object_flags[2] == false
    end
end

def do_examine(noun_num)
    if noun_num == 30 then
        $object_flags[18] = false
        $msg = "Something here!"
    end

    if noun_num == 31 then
        $msg = "That's disgusting!"
    end

    if noun_num == 28 or noun_num == 29 then
        $msg = "There's a drawer"
    end

    if noun_num == 33 or noun_num == 5 then
        do_read(noun_num)
    end

    if $player_location == 43 and noun_num == 35 then
        $msg = "There is something beyond..."
    end

    if noun_num == 32 then
        do_open(noun_num)
    end
end

def do_read(noun_num)
    if $player_location == 42 and noun_num == 33 then
        $msg = "They are demonic works"
    end

    if ( noun_num == 3 or noun_num == 36 ) and
        $carrying_object[3] and
        not $object_flag[34] then
        $msg = "Use this word with care: 'xzanfar'"
    end

    if $carrying_object[5] and noun_num == 5 then
        $msg = "The script is in an alien tongue."
    end
end

def do_say(noun_num, noun_str)
    $msg = "Okay, \"#{noun_str}.\""

    if $carrying_object[3] and noun_num == 34 then
        $msg = "*Magic occurs!*"
        if $player_location != 45 then
            $player_location = rand(64)
        else
            $object_flag[34] = true
        end
    end
end

def do_dig(noun_num)
    if $carrying_object[12] then
        $msg = "You made a hole."
    end

    if $carrying_object[12] and $player_location == 30 then
        $msg = "Dug the bars out"
        $rooms[$player_location] = "Hole in wall"
        $exits[$player_location] = "nse"
    end
end

def do_swing(noun_num)
    if not $carrying_object[14] and $player_location == 7 then
        $msg = "This is no time to play games"
    end

    if noun_num == 14 and $carrying_object[14] then
        $msg = "You swung it"
    end

    if noun_num == 13 and $carrying_object[13] then
        $msg = "Whoosh!"
    end

    if noun_num == 13 and $carrying_object[13] and $player_location == 43
        $exits[$player_location] = "nw"
        $rooms[$player_location] = "Study with secret room"
        $msg = "You broke then thin wall"
    end
end

def do_climb(noun_num)
    if noun_num == 14 and $carrying_object[14] then
        $msg = "It isn't attached to anything!"
    end

    if noun_num == 14 and not $carrying_object[14] and
        $player_location == 7 then
        if not $object_flag[14] then
            $msg = "You see thick forest and cliff south"
            $object_flag[14] = true
        else
            $msg = "Going down!"
            $object_flag[14] = false
        end
    end
end

def do_light(noun_num)
    if noun_num == 17 then
        if $carrying_object[17] and not $carrying_object[8] then
            $msg = "It will burn your hands"
        end
        if $carrying_object[17] and not $carrying_object[9] then
            $msg = "You have nothing to light it with"
        end

        if $carrying_object[17] and $carrying_object[8] and
            $carrying_object[9] then
            $msg = "It casts a flickering light"
            $object_flag[0] = true
        end
    end
end

def do_unlight(noun_num)
    if $object_flag[0] then
        $object_flag[0] = false
        $msg = "Extinguished."
    end
end

def do_spray(noun_num)
    if noun_num == 26 and $carrying_object[16] then
        $msg = "Hisssss"
        if $object_flag[26] then
            $object_flag[26] == 0
            $msg = "Pfft!  Got them!"
        end
    end
end

def do_use(noun_num)
end
def do_unlock(noun_num)
end
def do_leave(noun_num)
end
def do_score
end

def pause
    print "Press return to continue:"
    gets
end

# get this show started!  Here's the main loop
while true
    system("clear") # boy, what an improvement over BASIC's "cls" this is,
                    # calling a separate program just to clear the screen
    puts "Haunted House"
    puts "-------------"
    print "Your location: "
    puts $rooms[$player_location]
    print "Exits: "
    puts $exits[$player_location].split(//).map { |e| $exit_name[e] }.join(", ")
    (0..$gettable_objects-1).each do |i|
        if $locations[i] == $player_location and not $object_flags[i] then
            puts "You can see the #{$nouns[i]} here."
        end
    end
    puts "=========================="
    puts $msg
    print "What will you do now? "
    user_input = gets
    # this was like 15 lines of code in the original!
    ( verb, noun ) = user_input.split(" ") 
    verb_num = $verbs.index(verb)
    noun_num = $nouns.index(noun)

    # first, error messages
    if noun and not noun_num then
        $msg = "That's silly."
    end

    if not noun then
        $msg = "I need two words."
    end

    if verb_num.nil? and not noun_num.nil? then
        $msg = "You can't \"#{user_input}\"!"
    end

    if verb_num.nil? and noun_num.nil? then
        $msg = "I didn't understand that."
    end

    if not verb_num.nil? and not noun_num.nil? and
        not $carrying_object[noun_num]
        $msg = "You don't have " + noun.to_s
    end

    # I like how there's suddenly a bunch of game logic here in the
    # middle of the input error handler
    if $object_flags[26] and $player_location == 13 and rand(3) == 3 and \
        verb_num != 21 then
        $msg = "Bats attacking!"
        next
    end

    if $player_location == 44 and rand(2) == 1 and not $object_flags[24] then
        $object_flags[27] == 1
    end

    # The lamp!
    if $object_flags[0] then $candle_length -= 1 end
    do_action(verb_num,noun_num,noun)
    if $candle_length == 10 then
        $msg = "Your candle is waning!"
    end

    if $candle_length == 0 then
        $msg = "Your candle is out!"
    end
end

