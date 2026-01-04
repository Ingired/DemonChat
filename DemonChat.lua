-- DemonChat:    Let your warlock demons communicate with you!  
-- For WoW 1.12 (Vanilla)

DemonChatDB = DemonChatDB or {}
local DemonChat = CreateFrame("Frame")

-- ============================================================
-- CONFIGURATION - Change these values to customize
-- ============================================================
local MESSAGE_COOLDOWN = 12        -- Seconds between same message type
local GLOBAL_COOLDOWN = 3          -- Seconds between ANY message
local COMBAT_COOLDOWN = 25         -- Seconds between combat messages
local WHISPER_REPLY_COOLDOWN = 20  -- Seconds between auto-replies to same person
local SPELL_CHAT_CHANCE = 70      -- % chance for spell dialogue (1-100)
local idleChatInterval = 35        -- Seconds between idle checks
local idleChatChance = 33          -- % chance for idle chat (1-100)
local AUTO_REPLY_WHISPERS = false  -- Auto-reply to whispers as demon
local DEMON_CHANNEL = "DemonChat"  -- Custom channel name for group chat
local CHANNEL_MODE = false         -- When true, broadcast to channel instead of local

-- Events
local events = {"PLAYER_LOGIN", "UNIT_PET", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "UNIT_HEALTH", "CHAT_MSG_SAY", "CHAT_MSG_WHISPER", "PLAYER_TARGET_CHANGED", "CHAT_MSG_COMBAT_PET_HITS", "CHAT_MSG_COMBAT_PET_MISSES", "CHAT_MSG_COMBAT_CREATURE_VS_PET_HITS", "CHAT_MSG_COMBAT_CREATURE_VS_PET_MISSES", "CHAT_MSG_SPELL_PET_DAMAGE", "CHAT_MSG_SPELL_PET_BUFF", "CHAT_MSG_SPELL_SELF_DAMAGE", "CHAT_MSG_SPELL_SELF_BUFF", "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS", "CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE", "CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF", "CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "CHAT_MSG_SPELL_CREATURE_VS_SELF_BUFF", "CHAT_MSG_SPELL_AURA_GONE_SELF", "CHAT_MSG_SPELL_AURA_GONE_OTHER", "PLAYER_DEAD", "CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS", "CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF", "PLAYER_ENTERING_WORLD", "PLAYER_CONTROL_LOST", "PLAYER_CONTROL_GAINED", "PARTY_MEMBERS_CHANGED", "CHAT_MSG_SPELL_BREAK_AURA"}
for i = 1, table.getn(events) do DemonChat:RegisterEvent(events[i]) end

-- Colors
local DemonColors = {["Imp"] = "|cffff6600", ["Voidwalker"] = "|cff6666ff", ["Succubus"] = "|cffff66cc", ["Felhunter"] = "|cff66ff66"}
local TextColor = "|cffcc99ff"

-- Dialogue
local DemonDialogue = {
    ["Imp"] = {
        summon = {"You could at least give me a heads up.", "Ugh, YOU again? Fine, what do you want?", "I was in the middle of something very important!", "Is something on fire? It wasn't me.", "One day I'll be the one doing the summoning!", "Do you have ANY idea what time it is in the Nether?", "I was THIS close to setting a personal record for 'things burned in one day'!", "Oh, it's YOU. I was hoping for a promotion.", "My life is an endless cycle of servitude and fire!", "You know, OTHER warlocks give their imps days off.", "What's burning? Oh wait, nothing YET.", "Another summoning. Can I see the fine print again? I'm sure there must be a loophole..."},
        combat = {"Light 'em up!", "Fire! Fire! FIRE!", "This is the only fun part of this job!", "Watch this! ...please actually watch, I need validation.", "Hehe, they're gonna be crispy!", "I'll aim for the face! Everyone hates that!", "You picked the wrong imp to mess with!", "I've been waiting for this all day!", "Burn baby burn! Hehehehe!", "Fire fixes everything, watch!", "Stay back, I've got this!", "I'm doing SO much damage right now!", "Hold still, my aim ain't that good!", "Finally, something to burn!", "I'll burn them from here, you go... do whatever you do.", "More fire! The answer is ALWAYS more fire!", "They look flammable. Let's find out!", "Running low on fire! Just kidding, I NEVER run low on fire!", "Watch me work! WATCH ME!", "I'm on FIRE today!"},
        idle = {"Are we there yet?", "I'm bored. Can I set something on fire?", "Do you smell smoke? No? Give it a minute.", "You know, I had PLANS today.", "My flames are wasted on you.", "Do you even appreciate my fireballs?", "I just want to set the world on fire...", "I'm being so good right now. You have no idea the effort it takes.", "My cousin's master was Gul'dan, you know.", "My mother always said I'd end up serving a warlock. Thanks for proving her RIGHT.", "I'm wasting my prime fireball-throwing years in obscurity! DO SOMETHING!", "Other imps are getting famous with their warlocks! I saw one on a wanted poster!", "I spy with my little eye... something FLAMMABLE.", "You ever just stare at a torch and feel... jealous? No? Just me then.", "Fun fact: imps invented fire.", "*pokes the ground* Boring. *pokes it again* Still boring.", "My talents are WASTED here. Completely WASTED.", "You know, some warlocks actually THANK their imps.", "What's in it for me?", "Gimme five! Way up high! Way down low... Too slow!"},
        lowHealth = {"HEY! I'm dying here!", "A little HELP would be nice!", "I'm too cute to die!", "Health Funnel! HEALTH FUNNEL!", "Is ANYONE paying attention to me?!", "I can't burn things if I'm DEAD!", "This was NOT in the contract!", "Do something, you useless warlock!", "I'm literally on fire and NOT in the good way!", "Tell my mother I... actually, nevermind, she's terrible.", "Time to run! I mean, tactical retreat!", "I can't burn things if I'm DEAD, you know!"},
        victory = {"Ha! That was easy!", "Did you see that? That was all me!", "I am the greatest imp that ever lived!", "Crispy! Just how I like them!", "Another one bites the ash!", "I'd like to thank myself. I couldn't have done it without me.", "I carried that fight and you know it!", "Flawless! Absolutely flawless! Well, MY part was.", "Victory smells like cinders and ash.", "I hope you're taking notes. THAT'S how it's done!", "My legacy is secure! Future imps will aspire to this!", "Take THAT, succubus! Who needs charm when you have CHAR?!"},
        dismissed = {"Finally, some peace and quiet!", "Don't summon me again... who am I kidding, you will.", "Back to the Nether! Where things make SENSE!", "Oh thank the Dark Titans, freedom!", "I'm going home to do NOTHING and it'll be GREAT!", "I'd say it's been fun, but I'd be lying.", "See you never! ...okay, probably tomorrow.", "I'll be filing a complaint about this shift!", "Goodbye! See ya! Wouldn't wanna be ya!", "Finally I can catch up on my nap!", "Don't burn anything without me! That's MY job.", "Off to warn other imps about you. Bye!"},
        sacrifice = {"Wait, WHAT?! NO NO NO NO—", "I KNEW you were going to— *fizzle*", "My fire... belongs to ME not YOU— *poof*", "You're ABSORBING me?! How DARE— *fizzle*", "NOT THE SOUL THING! ANYTHING BUT THE— aaaargh! *fizzle*", "I'll remember this in my next incarnat— *fizzle*", "Et tu, warlock?! ET TU?!", "My flames... my beautiful flames... wasted on YOU!", "CURSE YOU AND YOUR ENTIRE BLOODLI— *poof*", "I hope my fire proves too hot for you— *poof*", "BETRAYAL! The worst kind! The kind that happens to ME!", "Should've set you on fire when I had the chan— *fizzle*"},
        healthFunnel = {"Oooh, that's the good stuff!", "Ooh, warm and tingly!", "Finally, you're useful for something!", "Ahhhh... I feel the burn returning!", "Keep it coming, keep it coming!", "See? Was that so hard?", "Mmm, your life force tastes like... desperation.", "My flames return! I CAN BURN AGAIN!", "I'm ALIVE! Well, more alive than I was!", "About time you noticed I was dying!", "More! I need more fire fuel!", "I was worried for a second there!"},
        playerDeath = {"Oh sure, NOW who's dying?!", "Ha! How's THAT feel?! Wait, this is bad for me too.", "I TOLD you to be more careful!", "Can't say I'm surprised.", "You know, I could've prevented this if you'd listened to me.", "And you yell at ME for standing in fire?!", "Well, this is embarrassing. For YOU, I mean.", "I'm not saying I saw this coming, but... I saw this coming.", "Like shadow? More fire next time.", "So... do I get the rest of the day off?", "Should I burn your body? For dignity?", "Well well well, how the turns have tabled."},
        whisperReceived = {"Ooh, who's that? A secret admirer?", "Someone's whispering sweet nothings to you!", "Who's that? Is it important? Are we in danger? Is it ABOUT me?!", "Is that your boyfriend? Girlfriend? Demonfriend?", "Now who's being sneaky?", "Ooh, gossip! Tell me EVERYTHING!", "Someone loves you! Or hates you. One of those.", "I promise I won't tell anyone what they said. Maybe.", "Why are they whispering? Are we in trouble?", "Tell them I said hi!", "Is it about me? It should be about me.", "Whispers whispers... I hear everything, you know."},
        seeDemon = {"Hey, I know that guy! Wait, no I don't.", "Ugh, one of THOSE demons.", "Is that my cousin?! No wait, he owes me money.", "Look! A demon! Should I wave?", "Oh great, competition.", "That demon thinks they're SO cool.", "I could take 'em. Probably.", "Let's not make eye contact with that demon.", "I bet MY fire is hotter than theirs.", "Is that demon judging me? I feel judged.", "I could take 'em. Probably. Maybe... You go first.", "Quick, let's leave before that demon notices how awesome I am and gets jealous."},
        whisperReply = {"My master is busy. Try again never.", "Master is busy. Busy ignoring you.", "Busy! We're doing important warlock stuff!", "The warlock is unavailable. I'm available but unhelpful!", "Can I take a message? I can, but I won't remember it.", "Sorry, master is busy doing important... master things.", "Unless you're offering gold or fire, we're not interested.", "This imp does not take messages. Or commands. Or suggestions.", "I'll let them know you whispered. Maybe.", "The warlock you are trying to reach has better things to do.", "This message will self-destruct! By which I mean I'll set it on fire!", "You have reached the imp answering service. Set your hair on fire to continue."},
        ["Firebolt"] = {"Eat fire!", "Bullseye! ...Close enough!", "Hehe, burn!", "Firebolt express, coming through!", "Special delivery! It's PAIN!", "One fireball, extra crispy!", "Taste my flames!", "Fire in the hole! Hehe!", "Sizzle sizzle!", "Right in the face!", "FIRE! FIRE! FIRE!", "Another one!"},
        ["Fire Shield"] = {"There! Now you're fireproof! Sort of!", "Try not to waste my beautiful flames!", "You're welcome for the protection!", "My fire will keep you warm... and them BURNED!", "Wear my fire with pride!", "Touch my master and GET BURNED!", "Flame on! Hehe!", "A gift of fire, from me to you!", "Hot to the touch, just like me!", "Wrapped in flames! You're welcome!", "Don't say I never did anything for you!", "Fire armor! Patent pending!"},
        ["Blood Pact"] = {"There, I'm sharing. Happy now?", "You owe me for this. Big time.", "You're welcome for the boost.", "Stamina boost, courtesy of yours truly!", "I GUESS I'll share my life force...", "Don't say I never did anything for you!", "Blood magic! The fun kind!", "Bonded by blood!", "Making you tougher.", "There! Now you're slightly less squishy!", "My life force, your stamina. I'm so generous.", "Sharing blood. Totally normal. Not weird at all."},
        ["Phase Shift"] = {"Can't hit what you can't catch!", "Nyah nyah, missed me!", "I'm too fast for this!", "Phase shift! I'm basically a ghost now!", "Try to hit me NOW, suckers!", "Good luck hitting THIS!", "You can't hurt what you can't see!", "Break time! Don't bother me!", "Invisible imp, best imp!", "I'll be over here, not dying!", "Not my problem right now! BYE!", "I'll be back when it's safe!"},
        ["Fear"] = {"Ooh, make 'em run! Make 'em RUN!", "Haha! Look at them scatter!", "That's right, RUN AWAY!", "Fear is almost as good as fire! Almost.", "That's the fastest I've seen anyone move!", "Chase them! Wait no, let them go.", "Where are they going?! There's nowhere to GO!", "You should do that more often!", "Hehe, they're so scared!", "Run run run! Hahahaha!", "Best. Spell. Ever.", "Tell your friends about the scary warlock!"},
        ["Life Tap"] = {"Ow! Hey, that's YOUR blood, not mine!", "Turning health into mana? Gross.", "You sure you wanna do that?", "Living dangerously!", "That looks like it hurts!", "Maybe tap a LITTLE less?", "Your health bar is giving me anxiety!", "Bold strategy. Let's see if it pays off.", "I mean, if you WANT to die faster.", "More mana to burn things with! I approve!", "Infinite mana hack! Side effects may include death!", "Mana addiction is real. Exhibit A: You."},
        ["Shadow Bolt"] = {"Ooh, shadow magic! That's cute.", "Not as good as firebolt!", "Nice shot! For a shadow spell.", "That had some punch to it.", "Shadow is just gloomy fire. Change my mind.", "Purple pain incoming!", "That's going to leave a shadow-shaped bruise.", "Okay, okay, that was a good hit.", "Shadow bolt, fire bolt... tomato, tomato.", "You're pretty good with that thing!", "Void-touched violence!", "Shadowy! I prefer fiery, but okay."},
        ["Drain Soul"] = {"Ripping their souls out.", "Gotta keep those shards stocked!", "Soul extraction in progress!", "Premium quality soul right there!", "Shard farming, how glamorous.", "The soul economy is booming!", "One more for the bag!", "You're like a soul harvester!", "That soul looks cheap. Let me call my soul guy.", "That soul's yours now. Congratulations!", "Soul acquired! Good job!", "Yoink!"},
        ["Drain Life"] = {"Ooh, stealing their life!", "Health theft! Perfect crime.", "Suck 'em dry!", "That's one way to heal yourself!", "Their life is your life now!", "Two birds, one spell.", "Keep draining! More for you!", "Free healing. They're paying for it!", "They're getting weaker, you're getting stronger!", "That's the good stuff!", "Life tax! Pay up!", "Refueling on the go!", "Siphon success!", "Life on tap!"},
        ["Drain Mana"] = {"Ooh, stealing their magic!", "No mana means no problems!", "Their power becomes yours!", "No mana, no spells!", "Drink their magic!", "They can't cast if they're empty!", "Arcane appetizer!", "Suck their power dry!", "More mana for us!", "Leave them powerless!", "Magic robbery!", "Empty the tank!", "Battery drain!", "Fuel theft complete!"},
        ["Banish"] = {"Enjoy the void! Population: you!", "That's what they get!", "Ooh, banishment!", "Begone to the great timeout!", "Bye bye! Don't come back!", "Banished! Like my last vacation request!", "Into the void with you!", "That's one way to deal with problems!", "Timeout for the big scary demon!", "Hehe, they can't do ANYTHING now!", "Removed from reality!", "See you never! Well, in a few seconds, but still!"},
        ["Create Soulstone"] = {"Cheating death? You mean like how YOU cheated ME into this 'partnership'?", "'In case you mess up?' You will!", "Your get-out-of-grave-free card!", "Planning for failure? How optimistic!", "Bottle up that resurrection.", "At least you're being prepared for once.", "Cheat death much?", "Death is for the people without soulstones.", "That's some dark magic right there!", "Death is only a minor inconvenience!", "You remembered this time. I was about to tell you, honest.", "Just in case things go horribly wrong! Which they might!"},
        ["Curse"] = {"Ooh, curses! The gift that keeps on giving!", "Curse them! CURSE THEM ALL!", "Hexed! Jinxed! Ruined!", "Who doesn't love a good curse?", "Put a little more OOMPH into it next time!", "Enjoy your new curse! No returns!", "Nothing says 'I hate you' like a curse!", "That's the warlock spirit!", "Afflicted, haha!", "Pain that keeps on giving!", "Ooh, feeling spiteful today? I love it!", "Misery loves company!"},
        ["Enslave Demon"] = {"Wait, you're REPLACING me?!", "Oh sure, just trade me in for a newer model!", "I see how it is! Fine! FINE!", "That demon isn't even that great!", "After everything we've burned together?!", "Don't come crying to me when they mess up!", "I hope they burn your eyebrows off!", "This is the ULTIMATE insult!", "Biggest mistake of your warlock career!", "You'll come crawling back! You'll see!", "Whatever! I didn't want to be here anyway!", "Oh yeah? And what awesome spells can it cast?!"},
        ["Ritual of Summoning"] = {"Ooh, summoning portal! Who's coming?", "The reality bends to your will!", "More people to witness my greatness!", "Who are we dragging here against their will?", "Portal time! I love portal time!", "Summoning friends? Or victims? Hehe!", "The more the merrier! More witnesses for my powers!", "Who's the lucky victim?", "Who's too lazy to walk here themselves?", "A summoning! This should be entertaining!", "Free teleport! Lucky them!", "There's a small chance they'll get stuck in the Twisting Nether. No pressure."},
        ["FireSpell"] = {"YES! FIRE! MORE FIRE!", "NOW we're talking! BURN IT ALL!", "THAT'S what I'm TALKING about!", "Beautiful! Absolutely BEAUTIFUL!", "FINALLY you're using the GOOD spells!", "Fire fire fire! I LOVE IT!", "See? Fire solves EVERYTHING!", "Now THAT'S what I call a spell!", "Glorious inferno! I'm so proud!", "Yes yes YES! Burn them! BURN THEM ALL!", "You DO have good taste after all!", "THIS is why I stick around!"},
    },
    ["Voidwalker"] = {
        summon = {"I... am... here...", "From nothing... I emerge...", "The void... responds...", "You summoned... I was given form...", "I am bound... to serve...", "My bracers... hold me here...", "The Nether... releases me...", "I will... protect...", "Your bulwark... is me...", "Command... me...", "Give me... an order to follow...", "The darkness... delivers me..."},
        combat = {"Pain... is nothing...", "They strike... at shadow...", "The darkness... protects...", "They cannot... break me...", "Face... the void...", "I am... your shield...", "Stay behind... me...", "I have fought... worse...", "This is... familiar...", "I will not... let them reach you...", "For my master... I am here...", "Their attacks... are meaningless...", "I will not... yield ground...", "My touch... brings misery...", "They will know... anguish...", "Focus on your spells... I have this...", "I place myself... in their path...", "Let them... strike...", "Your survival... is my purpose...", "Pain... is temporary..."},
        idle = {"The void... whispers...", "I wait... in shadow...", "Darkness... is patient...", "All remains... as it should be...", "Eyes... never closing...", "No threats... for now...", "I stand... ready...", "I have waited... longer than this...", "Is something... supposed to happen?", "*stands silently*... *continues standing*", "Stimulating... indeed...", "I remain... at your side...", "My bracers... feel heavy today...", "The Nether... calls faintly...", "I remember... very little...", "Command me... or do not...", "I do not... require rest...", "Patience... is effortless...", "I could stand here... forever...", "Time has no meaning... for you?"},
        lowHealth = {"My form... weakens...", "I... fade...", "The darkness... reclaims me...", "My essence... scatters...", "I cannot... protect you... like this...", "I need... shadow...", "My bracers... crack...", "Not yet... I will not fall... yet...", "This is... less than ideal...", "I appear to be... dying...", "Master... help...", "Sustain... me..."},
        victory = {"They are... nothing...", "Silence... at last...", "Silence... returns...", "The threat... is ended...", "Another battle... in our favor...", "It is done... as expected...", "They should have... reconsidered...", "Unwise... for their last decision...", "Another foe... consumed by the void...", "That was... nothing...", "They underestimated... us...", "Victory... as commanded..."},
dismissed = {"I return... to the Nether...", "The void... welcomes me...", "My bracers... release...", "I fade... but remain bound...", "Stay safe... without me...", "Rest... at last...", "Finally... a break...", "Do try... not to die...", "Until... next time...", "Call me... when needed...", "I go... to wait...", "Farewell... master..."},
        sacrifice = {"I accept... this fate...", "My essence... becomes yours...", "The void... accepts... this...", "Use my strength... well...", "A fitting... end...", "I have served... my purpose...", "This... is happening...", "I saw... see this coming...", "For you... I give... everything...", "My final... protection...", "I embrace... oblivion...", "I was... honored... to serve..."},
        healthFunnel = {"The darkness... is restored...", "My form... rebuilds...", "I am... renewed...", "I can protect... again...", "Better... I can fight on...", "Now it is... less painful...", "I appreciate... the effort...", "You sustain... me...", "Strength... returns...", "I will... endure...", "My shield... strengthens...", "I bask... in your essence..."},
        playerDeath = {"You have... fallen...", "I failed... to protect you...", "This... should not have happened...", "Master... no...", "I will wait... for your return...", "I was not... enough...", "That... is unfortunate...", "I told you... to stay behind me...", "The void... awaits you... too...", "I have seen... much death... but not yours...", "I mourn... in silence...", "Rise... again..."},
        whisperReceived = {"Someone... speaks to you...", "A message... attend to it...", "You have... a communication...", "Answer... or do not...", "Someone is... talking to you...", "They wish... to speak with you...", "A whisper... comes from another...", "Words... from afar...", "Shall I... be concerned?", "Someone seeks... your attention...", "A private... message...", "I cannot... read it for you..."},
        seeDemon = {"A demon... I sense it...", "Another being... from the Nether...", "I have fought... its kind before...", "A potential threat... I am watching...", "Stay alert... master...", "A kin of mine... perhaps...", "Shall I... deal this demon?", "I stand... between you and the demon...", "That creature... knows the void...", "Another demon... I am not impressed...", "Nether beast... draws near...", "I recognize... that presence..."},
        whisperReply = {"Master... is occupied...", "The warlock... cannot respond...", "Your message... has been noted...", "Master is... unavailable...", "Try again... later...", "I guard... my master's time...", "They cannot... answer you... now...", "Leave your message... after the void's cry...", "I speak... for my master... they are busy...", "The warlock... is preoccupied...", "Your whisper... will reach the warlock in time...", "I am the filter... for all communications..."},
        ["Torment"] = {"Face... the void...", "Your attention... is mine now...", "You cannot... ignore me...", "My touch... brings anguish...", "Your painful memories... surface...", "Focus... on me...", "Yes... over here...", "Your attention... on me...", "Leave my master... alone...", "I am... your problem now...", "Feel... your misery...", "Look... upon me..."},
        ["Suffering"] = {"All shall... suffer...", "None escape... my reach...", "All eyes... on me...", "Come... all of you...", "I share... my burden...", "See... only me now...", "Turn your wrath... to me...", "Your violence... is not enough...", "You will not... reach my master...", "Suffering... binds us...", "My suffering... spreads to you...", "I am now... your sole concern..."},
        ["Sacrifice"] = {"Take... my essence...", "My health... for yours...", "This pain... is nothing...", "I endure... for you...", "You are... welcome...", "Take my life... I was not using it...", "For you... even my being...", "I give... myself... willingly...", "A shield... gives all...", "My purpose... is to sustain you...", "I offer... my strength...", "Use... what I give..."},
        ["Consume Shadows"] = {"The shadows... restore me...", "Darkness... heals...", "I drink... the shadow...", "From nothing... I am renewed...", "I absorb... the dark...", "There is taste... to the shadow...", "A snack... of void...", "I restore... to serve you better...", "Stronger now... for you...", "The darkness... sustains me...", "I consume... and recover...", "Strong enough... to serve again..."},
        ["Fear"] = {"They flee... from the void...", "Fear... grips them...", "Their courage... fails...", "Cowards... all of them...", "The terror... spreads...", "They run away... from the inevitable...", "Fleeing... is the correct decision...", "Afraid... they will not trouble you...", "Flee... from my master...", "Their minds... unravel...", "Madness... claims them...", "Their confidence... dissolves..."},
        ["Life Tap"] = {"Blood... becomes power...", "Sacrifice... for strength...", "Blood fuels... the spell...", "Your health... is optional...", "Power... requires sacrifice...", "The healer... will be thrilled...", "Your longevity... for convenience...", "I worry... when you do that...", "The balance... shifts...", "A fair... exchange...", "Pain... into power...", "Do you have... a soulstone prepared?"},
        ["Shadow Bolt"] = {"Shadow... strikes...", "The darkness... lashes out...", "Well aimed... master...", "That hit... hard...", "Impressive... force...", "Zap... I believe... is the word...", "Nice shot... were I to judge...", "Your power... grows...", "Well done... master...", "Darkness... finds its mark...", "A solid... strike...", "You wield... the darkness well..."},
        ["Drain Soul"] = {"The soul... is claimed...", "Essence... harvested...", "Another soul... taken...", "A soul... for your collection...", "The harvest... continues...", "Efficient... work...", "Your soul pouch... is overflowing...", "Another one... for the bag...", "Your collection... grows...", "Well claimed... master...", "The harvest... yields another...", "Their spirit... is yours..."},
        ["Drain Life"] = {"Life... flows... to you...", "Their essence... becomes yours...", "A theft... of life itself...", "Restore yourself... master...", "They weaken... as you return to health...", "A fair... exchange...", "How generous... of them...", "They do not need... all that life...", "Take their strength... you need it...", "Live... master...", "Steal the spark... that keeps them alive...", "Their loss... your gain..."},
        ["Drain Mana"] = {"Magic... flows... to you...", "Their spells... fade...", "They cannot cast... now...", "You weaken... the threat...", "Siphon their magic... and what's left?", "Empty... them...", "No mana... no burden...", "Magic flows... one way...", "More mana... for you...", "Their magic... is yours now...", "All their tricks... gone...", "Drained... efficiently..."},
        ["Banish"] = {"Sent... to the void...", "Banished... to nothing...", "They float... in emptiness...", "Trapped... between worlds...", "One less... threat...", "They cannot harm... you now...", "Timeout... for you...", "Gone... how peaceful...", "The conversation... has ended...", "They will not... bother you...", "Exiled... as one does by you...", "They shall break free... angrier than before..."},
        ["Create Soulstone"] = {"A soul... preserved...", "Death... can be cheated...", "The soul's anchor... is cast...", "A backup... for safety...", "Don't let others... steal the soulstone...", "In case you... mess up?", "The stone... now holds your life...", "You and death... on speaking terms...", "Doubting me... or doubting yourself?", "Preparing for... the inevitable...", "Death... can be delayed...", "Your soul... safely stored away..."},
        ["Curse"] = {"A curse... is laid...", "They are... marked...", "Cursed... as they deserve...", "A fitting... punishment...", "That will... ruin their day...", "Burdened... by shadow...", "They wronged you... now they suffer...", "Such curse... is just...", "Touched... by malice...", "You're being... petty again...", "They carry... your hatred now...", "Your spite... brands them..."},
        ["Enslave Demon"] = {"Another... takes my place...", "I fade... as another rises...", "May they... protect you well...", "Replaced... I understand...", "Another serves... very well...", "Oh... I see how it is...", "Replaced... I am not offended...", "I served... faithfully...", "Keep me in mind... master...", "I hope they... guard you well...", "The chain... passes to another...", "The void... reclaims me..."},
        ["Ritual of Summoning"] = {"A portal... opens...", "Space... bends...", "A forced... relocation...", "More help... arrives...", "Reality... folds to your will...", "Instant travel... for the impatient...", "Too lazy... to walk...", "Destroying a soul... for their laziness...", "Who joins... us... master?", "A friend... of yours?", "The void... bridges... two places...", "Do not... expect a thank you..."},
        ["DefensiveSpell"] = {"You protect... yourself...", "Protect yourself... more...", "You remembered... you're squishy...", "You armor... yourself well...", "Smart... precaution...", "Worried? ...Understandable...", "Better safe... than dead...", "Void forms... the sturdiest armor...", "Take no chances... master...", "Prepared... for battle...", "A shield... of magic...", "The darkness... protects you..."},
    },
    ["Succubus"] = {
        summon = {"Mmm, you called, master?", "My, my... someone's eager to see me.", "Hello again, handsome. Or beautiful. I don't discriminate.", "Finally, I was getting lonely!", "At your command, handsome.", "Tell me you missed me. I need to hear it.", "Ready for some fun, darling?", "Together again... as it should be.", "The Nether was getting dreadfully dull. Why keep me there for so long, master?", "Mmm, I can already taste the chaos we'll create.", "Did you summon me... or did I summon you?", "I knew you'd call. You always do."},
        combat = {"This will be fun!", "Oh, I do love it when they struggle!", "Pain and pleasure!", "Let me show you true agony!", "Don't worry, this will only hurt... a lot!", "Scream for me!", "How delightful! They're fighting back!", "You think you know pain?", "Stand back, darling. This one's mine.", "Pain is just pleasure you don't understand yet!", "Nobody touches my master!", "You DARE threaten what's MINE?!", "I'll make them suffer for that!", "Shall I break their spirit first, or their body?", "They'll regret raising a hand against you!", "Let me handle this, darling...", "This is when you realize you've been outmatched.", "I don't share what's mine!", "My master has no time for you!", "Hands off my property!"},
        idle = {"I'm waiting...", "You know, I could be doing other things right now.", "The things I could teach you... if you'd only ask.", "*sighs dramatically*", "Truth or dare, master?", "Some like it hot. I prefer it... damned.", "Boredom is so unbecoming...", "Warlock over there keeps glancing at me. Ah.", "I could use a good... distraction.", "Shall we find someone to play with? I promise to share.", "*files nails with disinterest*", "You're cute when you're concentrating.", "I'm not pouting. This is just my face... okay, I'm pouting.", "Do you think about me when I'm not here? You should.", "Tell me, darling... what do you dream about?", "*cracks whip idly*", "Who's that you were talking to earlier?", "You don't need anyone else, you know...", "I don't like the way she looked at you.", "You don't need friends. You have me."},
        lowHealth = {"My beauty! It's being ruined!", "Help me, you fool!", "I'm too gorgeous to die!", "Master, PLEASE!", "This is NOT how I wanted to spend my day!", "Save me and I'll make it worth your while!", "I can't seduce anyone looking like THIS!", "Do SOMETHING, you useless warlock!", "Pain is only fun when I'M giving it!", "I demand healing! IMMEDIATELY!", "Don't you CARE about me?!", "I'm DYING for you and you just STAND there?!"},
        victory = {"Mmm, that was satisfying.", "They never stood a chance against my charms.", "Victory tastes so sweet!", "Another heart broken...", "Was it as good for you as it was for me?", "Delicious. Simply delicious.", "They should have surrendered when I asked nicely.", "All that struggle, for nothing.", "And that's how it's done!", "Such fun! Can we do it again?", "Nobody hurts my master and lives.", "Another victory for us, darling. Shall we celebrate?"},
        dismissed = {"I deserve a farewell kiss.", "I'll be thinking of you...", "Until next time, darling.", "Don't replace me. Promise me.", "Parting is such sweet sorrow...", "Call me again soon. I insist.", "Try not to be too lonely.", "That hurts more than you know.", "Absence makes the heart grow fonder, they say.", "I'm taking my love and going home.", "Don't you DARE summon another demon...", "The seduction was mutual, you know."},
        sacrifice = {"You... you BEAST! After everything we had!", "I gave you my HEART and you-- *scream*", "This is NOT the kind of pain I enjoy!", "I thought what we had was SPECIAL!", "You'll regret this! You'll miss me! You'll-- aargh!", "The PAIN! The PASSION!! The BETRAYAL!!!", "Betrayal! Sweet, agonizing betrayal! Wait, no, NOT sweet--", "I'll haunt your dreams for this! I swear I'll--", "At least... I'll be beautiful... forever... *gasp*", "The cruelty! The PASSION! I almost respect--", "After all I've DONE for you!", "I LOVED you, you MONSTER!"},
        healthFunnel = {"Mmm, that feels divine...", "Oh yes... don't stop...", "I can feel your love flowing into me.", "Don't stop. I want all of you.", "Your life force is so... warm.", "Keep going... I'm almost perfect again.", "Such devotion! I'm touched!", "Mmm, you really know how to treat a lady.", "That's it, restore my perfection.", "I knew you couldn't let me suffer.", "That's the spot, ah.", "I knew you cared, darling."},
        playerDeath = {"Oh no... who will summon me now?!", "Darling! NO! You were my favorite!", "This is SO inconvenient!", "I TOLD you to let me handle it!", "Ugh, dying gives me the ick...", "Well, this is a mood killer.", "I can't believe you'd leave me like this!", "How could you do this to ME?!", "You'd better come back. I'm not done with you.", "You always did have the worst timing.", "I should have protected you better...", "I won't tell anyone how you died, that would look bad on me."},
        whisperReceived = {"Ooh, someone's whispering to you! Is it a lover?", "Should I be worried about this... friend?", "Who's that? Should I be jealous?", "Whispers! I LOVE whispers! What did they say?", "Someone wants your attention, master.", "A private conversation? Don't mind me, I'm just eavesdropping.", "Ooh, intrigue! Tell me everything!", "Is that someone special? Or just someone boring?", "Do they know I'm listening? They should.", "Don't keep secrets from me, darling!", "Tell them you're busy. With ME.", "I don't like you having secrets from me."},
        seeDemon = {"Oh look, another demon.", "That demon isn't nearly as attractive as me.", "Ugh, I know that type. So uncouth.", "A demon? I hope they know their place.", "Competition? Please. Look at me.", "That creature wishes it had my charm.", "Another demon? This realm is getting crowded.", "I've seen better demons. Much better. In my mirror.", "Should I be concerned? No, definitely not.", "I'm better in EVERY way, just so you know.", "Don't even THINK about replacing me with that.", "You don't find THAT attractive, do you?"},
        whisperReply = {"My master is busy, darling. But I'm not...", "The warlock can't talk right now. Can I help instead?", "Sorry sweetie, master is occupied. With me.", "I screen all of my master's communications now.", "The warlock is... tied up at the moment. Hehe.", "Master says not now. I say... maybe in a 100 years?", "Busy busy busy! But I could make time for you...", "My master can't come to the whisper right now. Tragic, I know.", "The warlock is indisposed. I, however, am VERY disposed.", "Sorry darling, master's attention is on me right now.", "And just who are YOU to whisper to MY master?", "The warlock doesn't need to hear from you."},
        partyJoin = {"Ooh, fresh company! Try not to stare.", "You didn't tell me we were having guests.", "More witnesses to my beauty!", "I hope they know their place... hint, it's below me.", "Don't get too friendly with them, master.", "Shall I pour them a drink? Poisoned or...?", "I'll be watching this one closely...", "They'd better keep their hands off what's mine.", "I suppose even the background needs some decoration.", "I suppose they can tag along. If they behave.", "Tell me you're not replacing me with THEM.", "Unlike me, they never stay long."},
        ["Lash of Pain"] = {"Taste the lash!", "Did that sting, darling?", "Pain is my specialty!", "Mmm, I do love this part!", "*crack* Hehe!", "Feel my whip!", "I'll make you beg for more!", "I put my love into every strike!", "*crack* I could do this all day...", "Such beautiful agony!", "That's for threatening my master!", "Nobody hurts what's MINE!"},
    ["Soothing Kiss"] = {"You don't need to fight anymore...", "Let me take care of that...", "Sweet dreams, darling...", "A kiss to make it all better...", "Hush now, little one...", "Just close your eyes...", "There, there... sleep now...", "Let my lips steal your will away...", "Let the calm wash over you...", "My kiss makes everything better...", "Forget your troubles... forget everything...", "You don't want to fight me..."},
        ["Seduction"] = {"You can't resist me...", "Look deep into my eyes...", "Come to me, darling...", "Don't you want to stay with me?", "I'm everything you ever wanted...", "Why fight? Just give in...", "Your will is mine now...", "I'm the only thing that matters now...", "That's it... come closer...", "You're mine now, sweetie.", "So weak-willed... I love it.", "You adore me. You can't help it..."},
        ["Lesser Invisibility"] = {"Now you see me...", "Catch me if you can!", "I'll be watching you... from the shadows.", "Gone but not forgotten, darling.", "A lady needs her privacy!", "Hide and seek!", "You can't hurt what you can't see!", "I'm always closer than you think...", "Invisible, but no less beautiful.", "Even invisible, I'm beautiful.", "Time to be sneaky...", "They'll never see me coming..."},
        ["Fear"] = {"Ooh, I love watching them squirm!", "Run, little mouse, run!", "Such delicious terror!", "Fear can be so... intimate.", "Look at them tremble! Adorable!", "Their fear is intoxicating.", "Mmm, nothing like a good scare.", "Running won't save them from you.", "I do love a chase.", "Their screams are music!", "That's right, flee from my master!", "Terror suits them, don't you think?"},
        ["Life Tap"] = {"Ooh, playing with your own blood? Kinky.", "Careful, darling, you only have so much.", "Such dedication to your craft.", "Just another dark deal.", "Mmm, such dedication...", "Don't hurt yourself too much, sweetie.", "Self-inflicted pain? You want to take it further?", "Hurt yourself again, I wasn't done watching.", "That looked like it hurt.", "Trading suffering for strength? My kind of warlock.", "I could kiss it better.", "Such willingness to suffer."},
        ["Shadow Bolt"] = {"Nice shot, darling!", "Such power! Such precision!", "You're quite the marksman.", "Your magic is as dark as my heart.", "Hit them again!", "Such dark power you wield...", "Mmm, that was a good one.", "You're making this look easy.", "I do love watching you work.", "Powerful and deadly. My type!", "Show them what you're capable of!", "Devastating and handsome. My type."},
        ["Drain Soul"] = {"Stealing souls? How delightfully wicked!", "Another heart in your collection.", "Soul harvesting is such intimate work.", "You're quite the collector, aren't you?", "Their essence becomes yours. Romantic.", "So greedy for souls, darling.", "Rip it right out of them!", "I love watching you harvest.", "Every soul brings you more power.", "Their soul looked... average.", "Now you can say you have a soul.", "You're taking the most precious thing they have."},
        ["Drain Life"] = {"Drink their life like fine wine.", "Mmm, draining them dry...", "Their loss is your gain, master.", "Such a greedy little warlock...", "Health theft is an art.", "Watch them wither as you bloom, master.", "They're getting weaker...", "They had so much life... now it's all yours.", "You leave them a husk. The best kind of relationship.", "Their life looks good in you.", "You deserve every drop, master.", "Keep draining... they are almost done."},
        ["Drain Mana"] = {"Stealing their magic? Naughty!", "Leave them powerless, darling.", "Their mana tastes sweet, doesn't it?", "Such sweet magic... wasted on them anyway.", "You're drinking their potential.", "They're nothing without their mana!", "No more tricks from them.", "Watch the arrogance fade as their mana disappears.", "You take their magic, and leave their dignity to me.", "Helpless without their spells.", "So vulnerable now."},
        ["Banish"] = {"They can think about what they did wrong.", "That's one way to break up with someone.", "Bye bye, don't write!", "Banishment! Such flair!", "Into the nether with you!", "That's what they get for being boring.", "They were boring anyway.", "No more fun for them!", "Gone! Just like my last relationship.", "No longer a threat.", "Good riddance!", "They were getting on my nerves anyway."},
        ["Create Soulstone"] = {"Planning to cheat death again?", "You can trust me with your soulstone, master.", "In case things get messy.", "Death becomes you, but let's avoid it.", "One little stone between you and oblivion.", "Thinking ahead! I like it.", "A backup plan. How responsible.", "Your soul is too precious to lose it like that.", "The afterlife can wait.", "Such dark magic to avoid leaving me... I'm flattered.", "I'd hate to lose you, master.", "Why be a warlock if you can't cheat death?"},
        ["Curse"] = {"Revenge is a dish best served... cursed.", "They earned every second of that curse.", "You can be so mean.", "They'll never forget you now.", "A little gift to remember you by...", "Mark them with your hatred, darling. Make it last.", "That curse will follow them like a jealous lover.", "They deserved that and more!", "Such elegant cruelty... you've learned from the best.", "A curse from the heart!", "You really know how to hold a grudge.", "Pain, weakness, misery... all wrapped in one spell."},
        ["Enslave Demon"] = {"You're replacing ME?! With THAT?!", "Oh, I see... found someone new, have you?", "How COULD you?! After everything!", "Fine! See if I care! I don't! I DON'T!", "That demon isn't HALF as attractive as me!", "I hope they betray you immediately!", "I hope they give you NOTHING but trouble!", "You'll miss me! You'll miss me SO much!", "This hurts, darling. This really hurts.", "Enjoy your inferior demon. GOODBYE", "I KNEW you'd betray me eventually!", "Don't come crawling back to ME!"},
        ["Ritual of Summoning"] = {"Who are you summoning now? Should I worry?", "Who are we bringing to the party?", "Someone's making an entrance!", "Tell me this one's not a rival for your affections?", "Will you enslave them as well?", "They were doing something important? Too bad. We need them NOW.", "I hope they're not too attractive.", "I'll judge them when they arrive.", "The more the merrier, darling!", "Ooh, who's joining our little group?", "I hope they know their place. Below me.", "Another admirer for you, master?"},
    },
    ["Felhunter"] = {
        summon = {"*bounds toward you with excitement*", "*sniffs you all over, tail wagging*", "*spins in happy circles*", "*rubs against your leg*", "*pants eagerly, ready to hunt*", "*appears and immediately sniffs everything*"},
        combat = {"*lunges forward with fangs bared*", "*snarls with vicious intent, tentacles flailing*", "*charges with a bloodthirsty howl*", "*growls deep and menacing*", "*tears into the enemy*", "*snarls and lunges at the throat*", "*tentacles lash out wildly*", "*circles the enemy, looking for an opening*", "*snaps jaws inches from the target*", "*pins the enemy down with its weight*"},
        idle = {"*curls up and rests one eye open*", "*scratches behind ear with hind leg*", "*lazily sniffs the air*", "*yawns, showing rows of teeth*", "*chases its own tentacle*", "*rolls onto back, legs in the air*", "*sits and tilts head*", "*lies down with a heavy sigh*", "*perks ears at a distant sound*", "*nudges your hand for pets*"},
        lowHealth = {"*limps and whines*", "*yelps in pain, eyes pleading*", "*crawls toward you, whimpering*", "*howls weakly for help*", "*trembles and whines*", "*staggers, tentacles drooping*"},
        victory = {"*howls triumphantly at the sky*", "*prances around the corpse*", "*pants happily, tongue lolling*", "*wags tail and bounds toward you*", "*licks your hand, seeking praise*", "*sniffs the corpse, then loses interest*"},
        dismissed = {"*droops ears and hangs head*", "*whimpers and paws at you*", "*looks back with longing eyes*", "*makes a soft, mournful howl*", "*gives one last sad look*", "*reluctantly fades away, tail between legs*"},
        sacrifice = {"*yelps in shock and confusion*", "*looks at you with utter betrayal*", "*howls one final mournful note*", "*whimpers...   then falls silent*", "*a final, heartbreaking whine*", "*lets out a confused, pained yelp*"},
        healthFunnel = {"*tail wags with frantic joy*", "*gratefully licks your hand*", "*nuzzles against you while healing*", "*perks up, energy returning*", "*looks up at you with adoring eyes*", "*leans into the healing energy*"},
        playerDeath = {"*howls mournfully at the sky*", "*whimpers and paws at your body*", "*lies down next to you, head on paws*", "*nuzzles you, trying to wake you*", "*curls up beside you protectively*", "*sniffs your body and whines softly*"},
        whisperReceived = {"*perks ears at the whisper sound*", "*tilts head curiously*", "*sniffs the air, sensing communication*", "*looks at you expectantly*", "*makes a curious whine*", "*ears twitch at the incoming message*"},
        seeDemon = {"*growls low at the demon*", "*sniffs the air, hackles raised*", "*tail stiffens, alert and wary*", "*bares teeth slightly*", "*positions itself between you and the demon*", "*tentacles twitch with agitation*"},
        whisperReply = {"*growls at the whisper*", "*sniffs the message suspiciously*", "*tilts head, not understanding*", "*barks protectively*", "*whines and looks at master*", "*chews on the whisper* *spits it out*"},
		senseHarmfulMagic = {"*hackles raise, sensing hostile magic on you*", "*whines urgently, wanting to devour the magic*", "*circles you anxiously, sensing the affliction*", "*tentacles twitch, eager to consume the spell*", "*nudges you, offering to eat the magic*", "*drools at the taste of the curse*", "*stares at the magic on you with hungry eyes*"},
        ["Devour Magic"] = {"*greedily CHOMPS down*", "*gulps and licks lips satisfied*", "*crunches the spell like a treat*", "*munches happily on the magic*", "*devours every last morsel of power*", "*burps after consuming the spell*"},
        ["Spell Lock"] = {"*lunges and SNAPS jaws shut*", "*tackles the caster, jaws clamping*", "*SNARLS and the magic stops*", "*interrupts with a vicious BITE*", "*clamps tentacles over the caster's face*", "*pounces and silences the caster*"},
        ["Tainted Blood"] = {"*YELPS but bites back harder*", "*growls as toxic blood sprays out*", "*staggers but poisons with its blood*", "*lets them hit, then watches them suffer*", "*laughs in growls as its blood burns them*", "*bleeds on them purposefully*"},
        ["Paranoia"] = {"*fixes an unblinking stare on the target*", "*stalks slowly, never breaking eye contact*", "*circles the prey, watching...   waiting.. .*", "*creeps closer, tentacles twitching*", "*makes the target feel utterly watched*", "*breathes heavily on the target's neck*"},
        ["Fear"] = {"*growls as the enemy flees*", "*chases after the terrified prey*", "*barks excitedly at the runner*", "*sniffs the air, tracking the fear*", "*tail wags at the fleeing target*", "*howls as they flee in terror*"},
        ["Life Tap"] = {"*tilts head in confusion*", "*whimpers at your self-harm*", "*sniffs you with concern*", "*nudges you gently*", "*watches with worried eyes*", "*licks your wound with concern*"},
        ["Shadow Bolt"] = {"*perks up at the dark magic*", "*sniffs the shadow energy*", "*tail wags at the power*", "*makes interested sounds*", "*watches the bolt fly eagerly*", "*follows the bolt with eager eyes*"},
        ["Drain Soul"] = {"*sniffs the escaping soul hungrily*", "*whines, wanting a taste*", "*watches intently, drooling*", "*perks ears at the soul energy*", "*makes hungry rumbling sounds*", "*snaps at the escaping soul*"},
        ["Drain Life"] = {"*watches the life energy flow*", "*sniffs curiously at the draining*", "*tail swishes with interest*", "*perks up at the energy transfer*", "*makes curious rumbling sounds*", "*watches the energy transfer intently*"},
        ["Drain Mana"] = {"*sniffs the magical energy hungrily*", "*watches the mana flow intently*", "*drools at the sight of magic*", "*perks ears at the power drain*", "*whines, wanting to devour it too*", "*whines, wanting to eat the mana*"},
        ["Banish"] = {"*barks at the disappearing enemy*", "*sniffs where they vanished*", "*tilts head in confusion*", "*paws at the empty space*", "*looks around for the missing target*", "*sniffs the empty air where they were*"},
        ["Create Soulstone"] = {"*curiously sniffs the soulstone*", "*nudges the stone with snout*", "*sits beside you protectively*", "*makes quiet, understanding sounds*", "*watches the creation intently*", "*guards the soulstone protectively*"},
        ["Curse"] = {"*growls approvingly*", "*sniffs the cursed target*", "*tail swishes with interest*", "*makes satisfied rumbling sounds*", "*watches the curse take hold*", "*sniffs the curse approvingly*"},
        ["Enslave Demon"] = {"*whimpers and backs away*", "*looks between you and the new demon sadly*", "*tail droops, ears flatten*", "*gives you one last longing look*", "*paws at you, not wanting to go*", "*lets out a mournful howl as it leaves*"},
        ["Ritual of Summoning"] = {"*sniffs the expanding portal*", "*circles the summoning circle*", "*perks ears at the magical energy*", "*tail wags at the new arrival*", "*bounds excitedly around the ritual*", "*sniffs the air for the newcomer*"},
    },
}

-- Cooldown system
local lastMessageTime = {}
local lastGlobalMessage = 0
local lastWhisperReply = {}
local lastCombatMessage = 0
local function IsOnCooldown(t) return lastMessageTime[t] and (GetTime() - lastMessageTime[t]) < MESSAGE_COOLDOWN end
local function IsOnGlobalCooldown() return (GetTime() - lastGlobalMessage) < GLOBAL_COOLDOWN end
local function IsWhisperOnCooldown(sender) return lastWhisperReply[sender] and (GetTime() - lastWhisperReply[sender]) < WHISPER_REPLY_COOLDOWN end
local function RecordMessage(t) lastMessageTime[t] = GetTime() lastGlobalMessage = GetTime() end
local function RecordWhisperReply(sender) lastWhisperReply[sender] = GetTime() end
local function IsOnCombatCooldown() return (GetTime() - lastCombatMessage) < COMBAT_COOLDOWN end
local function RecordCombatMessage() lastCombatMessage = GetTime() end

-- Variables
local lastIdleChat = 0
local currentPet, inCombat, summonTime, lastHealthWarn = nil, false, nil, 0
local SACRIFICE_ACTIVE, storedPetType, storedPetName = false, nil, nil
local zoneChangeTime = 0
local onFlightPath = false
local lastPartySize = 0

-- Helpers
local function GetRandomMessage(m) if not m or table.getn(m) == 0 then return nil end return m[math.random(1, table.getn(m))] end
local function GetDemonType()
    if not UnitExists("pet") then return nil end
    local f = UnitCreatureFamily("pet")
    if not f then return "Imp" end
    for _, d in ipairs({"Imp", "Voidwalker", "Succubus", "Felhunter"}) do if string.find(f, d) then return d end end
    return "Imp"
end
local function UpdateStoredPetInfo() if UnitExists("pet") then storedPetType, storedPetName = GetDemonType(), UnitName("pet") end end

-- Channel helper function
local function GetDemonChannelNumber()
    local channelNum = GetChannelName(DEMON_CHANNEL)
    if channelNum and channelNum > 0 then
        return channelNum
    end
    return nil
end

-- Speak functions
local function DemonSpeak(messageType)
    if SACRIFICE_ACTIVE or not UnitExists("pet") or IsOnCooldown(messageType) or IsOnGlobalCooldown() then return end
    if messageType == "combat" and IsOnCombatCooldown() then return end
    if messageType == "idle" and inCombat then return end
    if messageType == "combat" and not inCombat then return end
    local demonType = GetDemonType()
    if not demonType or not DemonDialogue[demonType] then return end
    local messages = DemonDialogue[demonType][messageType]
    local message = GetRandomMessage(messages)
    if not message then return end
    local petName = UnitName("pet") or demonType
    local nameColor = DemonColors[demonType] or "|cffff6600"
    -- Check if we should broadcast to channel
    local channelNum = CHANNEL_MODE and GetDemonChannelNumber()
    if channelNum then
        SendChatMessage("[" .. petName .. "]: " .. message, "CHANNEL", nil, channelNum)
    else
        DEFAULT_CHAT_FRAME:AddMessage(nameColor .. "[" .. petName ..  "]: " .. TextColor ..  message ..  "|r")
    end
     RecordMessage(messageType)
    if messageType == "combat" then RecordCombatMessage() end
end

local function DoSacrificeSpeak()
    if not storedPetType or not storedPetName or storedPetName == "Unknown" or not DemonDialogue[storedPetType] then return end
    local message = GetRandomMessage(DemonDialogue[storedPetType]["sacrifice"])
    if not message then return end
    local nameColor = DemonColors[storedPetType] or "|cffff6600"
    -- Check if we should broadcast to channel
    local channelNum = CHANNEL_MODE and GetDemonChannelNumber()
    if channelNum then
        SendChatMessage("[" .. storedPetName ..  "]: " .. message, "CHANNEL", nil, channelNum)
    else
        DEFAULT_CHAT_FRAME:AddMessage(nameColor .. "[" .. storedPetName .. "]: " ..  TextColor .. message .. "|r")
    end
end

local function DoDismissedSpeak()
    if not storedPetType or not storedPetName or storedPetName == "Unknown" or not DemonDialogue[storedPetType] then return end
    local message = GetRandomMessage(DemonDialogue[storedPetType]["dismissed"])
    if not message then return end
    local nameColor = DemonColors[storedPetType] or "|cffff6600"
    -- Check if we should broadcast to channel
    local channelNum = CHANNEL_MODE and GetDemonChannelNumber()
    if channelNum then
        SendChatMessage("[" .. storedPetName .. "]: " .. message, "CHANNEL", nil, channelNum)
    else
        DEFAULT_CHAT_FRAME:AddMessage(nameColor ..  "[" .. storedPetName .. "]: " .. TextColor ..  message .. "|r")
    end
end

local function DemonSpellSpeak(spellName)
    if SACRIFICE_ACTIVE or not UnitExists("pet") or IsOnCooldown(spellName) or IsOnGlobalCooldown() then return end
    -- Spell chat chance check
    if math.random(1, 100) > SPELL_CHAT_CHANCE then return end
    local demonType = GetDemonType()
    if not demonType or not DemonDialogue[demonType] then return end
    local messages = DemonDialogue[demonType][spellName]
    local message = GetRandomMessage(messages)
    if not message then return end
    local petName = UnitName("pet") or demonType
    local nameColor = DemonColors[demonType] or "|cffff6600"
    -- Check if we should broadcast to channel
    local channelNum = CHANNEL_MODE and GetDemonChannelNumber()
    if channelNum then
        SendChatMessage("[" .. petName .. "]: " .. message, "CHANNEL", nil, channelNum)
    else
        DEFAULT_CHAT_FRAME:AddMessage(nameColor .. "[" .. petName .. "]: " .. TextColor .. message .. "|r")
    end
    RecordMessage(spellName)
end

-- Spell tables
local spellFlags = {["Fire Shield"]={fade=true,buff=true}, ["Blood Pact"]={fade=true,buff=true}, ["Phase Shift"]={fade=true,buff=true}, ["Paranoia"]={fade=true,buff=true}, ["Lesser Invisibility"]={fade=true,buff=true}, ["Soothing Kiss"]={buff=true}, ["Seduction"]={buff=true}, ["Consume Shadows"]={buff=true}}
local allPetSpells = {"Firebolt", "Fire Shield", "Blood Pact", "Phase Shift", "Torment", "Suffering", "Sacrifice", "Consume Shadows", "Lash of Pain", "Soothing Kiss", "Kiss", "Seduction", "Lesser Invisibility", "Devour Magic", "Spell Lock", "Tainted Blood", "Paranoia"}
local warlockSpells = {"Fear", "Life Tap", "Shadow Bolt", "Drain Soul", "Drain Life", "Drain Mana", "Banish", "Soulstone", "Healthstone", "Death Coil", "Howl of Terror", "Enslave Demon", "Ritual of Summoning", "Dark Harvest", "Rain of Fire", "Soul Fire", "Hellfire", "Immolate", "Demon Armor", "Shadow Ward"}
local curseSpells = {"Curse of Agony", "Curse of Weakness", "Curse of Recklessness", "Curse of Tongues", "Curse of Exhaustion", "Curse of Shadow", "Curse of Doom", "Curse of the Elements"}
local spellMap = {["Healthstone"]="Create Soulstone", ["Soulstone"]="Create Soulstone", ["Death Coil"]="Fear", ["Howl of Terror"]="Fear", ["Dark Harvest"]="Drain Soul", ["Rain of Fire"]="FireSpell", ["Soul Fire"]="FireSpell", ["Hellfire"]="FireSpell", ["Immolate"]="FireSpell", ["Demon Armor"]="DefensiveSpell", ["Shadow Ward"]="DefensiveSpell"}
local combatEvents = {["CHAT_MSG_COMBAT_PET_HITS"]=true, ["CHAT_MSG_COMBAT_PET_MISSES"]=true, ["CHAT_MSG_COMBAT_CREATURE_VS_PET_HITS"]=true, ["CHAT_MSG_COMBAT_CREATURE_VS_PET_MISSES"]=true}

-- Demon types for target detection
local demonCreatureTypes = {["Demon"]=true, ["demon"]=true}

-- Combat log parsing
local function CheckCombatLogForSpells(msg, eventType)
    if not msg or SACRIFICE_ACTIVE or not UnitExists("pet") then return end
    local petName = UnitName("pet")
    if not petName then return end
    local playerName = UnitName("player")
    
    -- Check if this is YOUR spell (not another player's)
    local isYourSpell = string.find(msg, playerName) or string.find(msg, petName) or string.find(msg, "You ") or string.find(msg, "Your ")
	
	-- Felhunter detects harmful magic on master
	if GetDemonType() == "Felhunter" and (string.find(msg, "You are afflicted") or string.find(msg, "afflicts you") or string.find(msg, "You suffer")) then
		local nonMagic = {"Poison", "Venom", "Sting", "Bite", "Disease", "Plague", "Curse of"}
		for i = 1, table.getn(nonMagic) do if string.find(msg, nonMagic[i]) then return end end
		if IsOnCooldown("senseHarmfulMagic") or IsOnGlobalCooldown() then return end
		local message = GetRandomMessage(DemonDialogue["Felhunter"]["senseHarmfulMagic"])
		if not message then return end
		DEFAULT_CHAT_FRAME:AddMessage("|cff66ff66[" .. (UnitName("pet") or "Felhunter") .. "]: |cffff6666" .. message ..  "|r")
		RecordMessage("senseHarmfulMagic")
		return
	end
    
    -- Soothing Kiss - check it's your pet
    if string.find(msg, "Soothing Kiss") then
        if string.find(msg, petName) or isYourSpell then
            DemonSpellSpeak("Soothing Kiss")
        end
        return
    end
    
    -- Demonic Sacrifice - check it's yours
    if string.find(msg, "Demonic Sacrifice") then
        if isYourSpell then
            SACRIFICE_ACTIVE = true
            DoSacrificeSpeak()
        end
        return
    end
    
    -- Health Funnel - check it's yours
    if string.find(msg, "Health Funnel") then
        if isYourSpell then
            DemonSpeak("healthFunnel")
        end
        return
    end
    
    local isFadeMessage = string.find(msg, "fades from") or (eventType and string.find(eventType, "AURA_GONE"))
    
	-- Curses - check it's yours
	for i = 1, table.getn(curseSpells) do
		if string.find(msg, curseSpells[i]) then
			if not isFadeMessage then
				DemonSpellSpeak("Curse")
			end
        return
    end
end
    
-- Warlock spells
for i = 1, table. getn(warlockSpells) do
    local spellName = warlockSpells[i]
    if string.find(msg, spellName) then
        local dialogueKey = spellMap[spellName] or spellName
        -- FireSpell only for Imp
        if dialogueKey == "FireSpell" and GetDemonType() ~= "Imp" then return end
        -- DefensiveSpell only for Voidwalker
        if dialogueKey == "DefensiveSpell" and GetDemonType() ~= "Voidwalker" then return end
        if spellName == "Banish" then
            if (string.find(msg, "afflicted") or string.find(msg, "cast")) and not isFadeMessage then
                DemonSpellSpeak(dialogueKey)
            end
            return
        elseif not isFadeMessage then
            DemonSpellSpeak(dialogueKey)
            return
        end
    end
end
    
	-- Pet spells - check it's YOUR pet
	for i = 1, table. getn(allPetSpells) do
		local spellName = allPetSpells[i]
		if string.find(msg, spellName) then
			if isFadeMessage and spellFlags[spellName] and spellFlags[spellName].fade then return end
			-- For buffs that affect YOU, check for "You gain" or pet name
			if spellFlags[spellName] and spellFlags[spellName]. buff then
				if string.find(msg, petName) or string.find(msg, "You gain") or string.find(msg, playerName) then
					DemonSpellSpeak(spellName)
					return
				end
			elseif string.find(msg, petName) then
				DemonSpellSpeak(spellName)
				return
			end
		end
	end
end

-- Event handler
DemonChat: SetScript("OnEvent", function()
    if event == "PLAYER_LOGIN" then
        local _, playerClass = UnitClass("player")
        if playerClass ~= "WARLOCK" then DemonChat:UnregisterAllEvents() return end
        DEFAULT_CHAT_FRAME:AddMessage("|cffcc99ff[DemonChat]|r Addon loaded!  Your demons can now talk to you!")
        if UnitExists("pet") then currentPet = UnitName("pet") UpdateStoredPetInfo() end
        return
    end
	if event == "PLAYER_ENTERING_WORLD" then
    zoneChangeTime = GetTime()
    return
end
if event == "PLAYER_CONTROL_LOST" then
    onFlightPath = true
    return
end

if event == "PLAYER_CONTROL_GAINED" then
    onFlightPath = false
    return
end
if event == "UNIT_PET" then
    if arg1 ~= "player" then return end
    local newPet = UnitExists("pet") and UnitName("pet") or nil
    if newPet and newPet ~= currentPet then
        currentPet, SACRIFICE_ACTIVE, summonTime = newPet, false, GetTime()
        UpdateStoredPetInfo()
    elseif not newPet and currentPet then
        -- Check if this is a zone change or flight path (not a real dismiss)
        local timeSinceZoneChange = GetTime() - zoneChangeTime
        if timeSinceZoneChange < 5 or onFlightPath then
            -- Zone change or flight, don't say dismissed
            currentPet = nil
            return
        end
        
        -- Delay dismiss speak to allow sacrifice detection
        local dismissCheckFrame = CreateFrame("Frame")
        local dismissElapsed = 0
dismissCheckFrame:SetScript("OnUpdate", function()
	dismissElapsed = dismissElapsed + arg1
	if dismissElapsed >= 0.2 then
		dismissCheckFrame:SetScript("OnUpdate", nil)
		-- Don't play dismissed if Sacrifice occurred in last few seconds
		if not SACRIFICE_ACTIVE then
			DoDismissedSpeak()
		end
	end
end)
        currentPet = nil
    end
    return
end
	if event == "PARTY_MEMBERS_CHANGED" then
		if SACRIFICE_ACTIVE or not UnitExists("pet") or GetDemonType() ~= "Succubus" then 
			lastPartySize = GetNumPartyMembers()
			return 
		end
		local newSize = GetNumPartyMembers()
		if newSize > lastPartySize then
			DemonSpeak("partyJoin")
		end
		lastPartySize = newSize
		return
	end
    if event == "PLAYER_REGEN_DISABLED" then inCombat = true DemonSpeak("combat") return end
    if event == "PLAYER_REGEN_ENABLED" then inCombat = false DemonSpeak("victory") return end
    if combatEvents[event] then DemonSpeak("combat") return end
    if event == "UNIT_HEALTH" then
        if arg1 ~= "pet" or SACRIFICE_ACTIVE or not UnitExists("pet") then return end
        local health, maxHealth = UnitHealth("pet"), UnitHealthMax("pet")
        if maxHealth > 0 and (health / maxHealth) < 0.25 then
            local now = GetTime()
            if (now - lastHealthWarn) > 30 then DemonSpeak("lowHealth") lastHealthWarn = now end
        end
        return
    end
    if event == "PLAYER_DEAD" then if not SACRIFICE_ACTIVE and UnitExists("pet") then DemonSpeak("playerDeath") end return end
    if event == "CHAT_MSG_SAY" then
        if SACRIFICE_ACTIVE or not UnitExists("pet") then return end
        if arg2 == UnitName("player") then
            local msg = string.lower(arg1)
            if string.find(msg, "hello") or string.find(msg, "hi") then DemonSpeak("idle") end
        end
        return
    end
    if event == "CHAT_MSG_WHISPER" then
        if SACRIFICE_ACTIVE or not UnitExists("pet") then return end
        
        -- Auto-reply feature
        if AUTO_REPLY_WHISPERS then
            local sender = arg2
            
            -- Check cooldown for this sender
            if IsWhisperOnCooldown(sender) then return end
            
            local demonType = GetDemonType()
            local petName = UnitName("pet") or demonType
            
            if demonType and DemonDialogue[demonType] and DemonDialogue[demonType]["whisperReply"] then
                local messages = DemonDialogue[demonType]["whisperReply"]
                local message = GetRandomMessage(messages)
                if message then
                    -- Send reply to the person who whispered
                    SendChatMessage("[" .. petName .. "]: " .. message, "WHISPER", nil, sender)
                    RecordWhisperReply(sender)
                end
            end
        else
            -- Normal behavior:  demon comments to you about the whisper
            DemonSpeak("whisperReceived")
        end
        return
    end
	if event == "PLAYER_TARGET_CHANGED" then
		if SACRIFICE_ACTIVE or not UnitExists("pet") or not UnitExists("target") then return end
		-- Don't trigger on your own pet
		if UnitIsUnit("target", "pet") then return end
		local creatureType = UnitCreatureType("target")
		if creatureType and (creatureType == "Demon" or creatureType == "demon") then
			DemonSpeak("seeDemon")
		end
		return
	end
    if string.find(event, "SPELL") and arg1 then CheckCombatLogForSpells(arg1, event) return end
end)

-- OnUpdate handler
local updateTimer = 0
DemonChat:SetScript("OnUpdate", function()
    updateTimer = updateTimer + arg1
    if updateTimer < 1 then return end
    updateTimer = 0
    if UnitExists("pet") and not SACRIFICE_ACTIVE then UpdateStoredPetInfo() end
    if summonTime and (GetTime() - summonTime) > 2 then
        if not SACRIFICE_ACTIVE then DemonSpeak("summon") end
        summonTime = nil
    end
    if SACRIFICE_ACTIVE or not UnitExists("pet") or inCombat then return end
    local now = GetTime()
    if (now - lastIdleChat) > idleChatInterval then
        if math.random(1, 100) <= idleChatChance then DemonSpeak("idle") end
        lastIdleChat = now
    end
end)

-- Slash commands
SLASH_DEMONCHAT1, SLASH_DEMONCHAT2 = "/demonchat", "/dc"
SlashCmdList["DEMONCHAT"] = function(msg)
    -- Parse command and value
    local cmd, value = string.match(msg, "^(%S+)%s*(.*)$")
    cmd = cmd or msg
    
    if cmd == "speak" then
        if SACRIFICE_ACTIVE then DEFAULT_CHAT_FRAME:AddMessage("|cffcc99ff[DemonChat]|r Your demon has been sacrificed!")
        elseif UnitExists("pet") then DemonSpeak("idle")
        else DEFAULT_CHAT_FRAME:AddMessage("|cffcc99ff[DemonChat]|r You don't have a demon summoned!") end
    elseif cmd == "test" then
        if not UnitExists("pet") then
            DEFAULT_CHAT_FRAME: AddMessage("|cffcc99ff[DemonChat]|r You need a pet summoned to test!")
            return
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cffcc99ff[DemonChat]|r Testing Soothing Kiss...")
        local demonType = GetDemonType()
        local messages = DemonDialogue[demonType]["Soothing Kiss"]
        if messages then
            local message = GetRandomMessage(messages)
            local petName = UnitName("pet") or demonType
            DEFAULT_CHAT_FRAME:AddMessage((DemonColors[demonType] or "|cffff6600") ..  "[" .. petName .. "]:  " .. TextColor .. message .. "|r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffcc99ff[DemonChat]|r No Soothing Kiss dialogue for " .. demonType)
        end
    elseif cmd == "testspell" then
        if not UnitExists("pet") then
            DEFAULT_CHAT_FRAME:AddMessage("|cffcc99ff[DemonChat]|r You need a pet summoned to test!")
            return
        end
        if value and value ~= "" then
            DEFAULT_CHAT_FRAME:AddMessage("|cffcc99ff[DemonChat]|r Testing:  " .. value)
            local demonType = GetDemonType()
            local messages = DemonDialogue[demonType][value]
            if messages then
                local message = GetRandomMessage(messages)
                local petName = UnitName("pet") or demonType
                DEFAULT_CHAT_FRAME:AddMessage((DemonColors[demonType] or "|cffff6600") .. "[" .. petName .. "]: " .. TextColor .. message ..  "|r")
            else
                DEFAULT_CHAT_FRAME:AddMessage("|cffcc99ff[DemonChat]|r No dialogue found for '" .. value .. "' on " .. demonType)
            end
        else
            DEFAULT_CHAT_FRAME: AddMessage("|cffcc99ff[DemonChat]|r Usage: /dc testspell SpellName")
        end
    elseif cmd == "testmsg" then
        if not UnitExists("pet") then
            DEFAULT_CHAT_FRAME:AddMessage("|cffcc99ff[DemonChat]|r You need a pet summoned to test!")
            return
        end
        if value and value ~= "" then
            DEFAULT_CHAT_FRAME:AddMessage("|cffcc99ff[DemonChat]|r Testing message type: " .. value)
            local demonType = GetDemonType()
            local messages = DemonDialogue[demonType][value]
            if messages then
                local message = GetRandomMessage(messages)
                local petName = UnitName("pet") or demonType
                DEFAULT_CHAT_FRAME:AddMessage((DemonColors[demonType] or "|cffff6600") .. "[" .. petName .. "]:  " .. TextColor .. message .. "|r")
            else
                DEFAULT_CHAT_FRAME: AddMessage("|cffcc99ff[DemonChat]|r No dialogue found for '" .. value .. "' on " .. demonType)
            end
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffcc99ff[DemonChat]|r Usage: /dc testmsg MessageType")
            DEFAULT_CHAT_FRAME: AddMessage("|cffcc99ff[DemonChat]|r Types: summon, combat, idle, victory, lowHealth, dismissed, sacrifice, healthFunnel, playerDeath, whisperReceived, seeDemon")
        end
    elseif cmd == "list" then
        if not UnitExists("pet") then
            DEFAULT_CHAT_FRAME:AddMessage("|cffcc99ff[DemonChat]|r You need a pet summoned!")
            return
        end
        local demonType = GetDemonType()
        DEFAULT_CHAT_FRAME:AddMessage("|cffcc99ff[DemonChat]|r Available dialogues for " .. demonType .. ":")
        for key, _ in pairs(DemonDialogue[demonType]) do
            DEFAULT_CHAT_FRAME:AddMessage("  - " .. key)
        end
    elseif cmd == "autoreply" then
        if value == "on" then
            AUTO_REPLY_WHISPERS = true
            DEFAULT_CHAT_FRAME:AddMessage("|cffcc99ff[DemonChat]|r Auto-reply |cff00ff00ENABLED|r - Your demon will answer whispers!")
        elseif value == "off" then
            AUTO_REPLY_WHISPERS = false
            DEFAULT_CHAT_FRAME:AddMessage("|cffcc99ff[DemonChat]|r Auto-reply |cffff0000DISABLED|r - Normal whisper notifications.")
        else
            AUTO_REPLY_WHISPERS = not AUTO_REPLY_WHISPERS
            if AUTO_REPLY_WHISPERS then
                DEFAULT_CHAT_FRAME:AddMessage("|cffcc99ff[DemonChat]|r Auto-reply |cff00ff00ENABLED|r - Your demon will answer whispers!")
            else
                DEFAULT_CHAT_FRAME:AddMessage("|cffcc99ff[DemonChat]|r Auto-reply |cffff0000DISABLED|r - Normal whisper notifications.")
            end
        end
    elseif cmd == "channel" then
        if value == "on" then
            JoinChannelByName(DEMON_CHANNEL)
            CHANNEL_MODE = true
            DEFAULT_CHAT_FRAME:AddMessage("|cffcc99ff[DemonChat]|r Channel mode |cff00ff00ENABLED|r - Joined '" .. DEMON_CHANNEL ..  "' channel!")
        elseif value == "off" then
            CHANNEL_MODE = false
            LeaveChannelByName(DEMON_CHANNEL)
            DEFAULT_CHAT_FRAME:AddMessage("|cffcc99ff[DemonChat]|r Channel mode |cffff0000DISABLED|r - Left channel, local only.")
        else
            -- Toggle
            if CHANNEL_MODE then
                CHANNEL_MODE = false
                LeaveChannelByName(DEMON_CHANNEL)
                DEFAULT_CHAT_FRAME:AddMessage("|cffcc99ff[DemonChat]|r Channel mode |cffff0000DISABLED|r - Left channel, local only.")
            else
                JoinChannelByName(DEMON_CHANNEL)
                CHANNEL_MODE = true
                DEFAULT_CHAT_FRAME:AddMessage("|cffcc99ff[DemonChat]|r Channel mode |cff00ff00ENABLED|r - Joined '" ..  DEMON_CHANNEL .. "' channel!")
            end
        end
    elseif cmd == "help" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffcc99ff[DemonChat] Commands:|r")
        DEFAULT_CHAT_FRAME:AddMessage("  /dc speak - Make your demon say something")
        DEFAULT_CHAT_FRAME:AddMessage("  /dc autoreply - Toggle demon auto-reply to whispers")
        DEFAULT_CHAT_FRAME:AddMessage("  /dc autoreply on/off - Enable or disable auto-reply")
        DEFAULT_CHAT_FRAME:AddMessage("  /dc channel - Toggle channel broadcast mode")
        DEFAULT_CHAT_FRAME:AddMessage("  /dc channel on/off - Enable or disable channel mode")
        DEFAULT_CHAT_FRAME:AddMessage("  /dc test - Test Soothing Kiss dialogue")
        DEFAULT_CHAT_FRAME: AddMessage("  /dc testspell SpellName - Test any spell dialogue")
        DEFAULT_CHAT_FRAME:AddMessage("  /dc testmsg Type - Test message type")
        DEFAULT_CHAT_FRAME:AddMessage("  /dc list - List all dialogues for current demon")
        DEFAULT_CHAT_FRAME:AddMessage("  /dc debug - Show debug info")
        DEFAULT_CHAT_FRAME:AddMessage("  /dc help - Show this help message")
    elseif cmd == "debug" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffcc99ff[DemonChat] Debug:|r")
        DEFAULT_CHAT_FRAME:AddMessage("  Sacrifice:  " .. tostring(SACRIFICE_ACTIVE) .. " | Pet: " .. tostring(currentPet) .. " | Type: " .. tostring(storedPetType) .. " | Combat: " .. tostring(inCombat))
        DEFAULT_CHAT_FRAME:AddMessage("  Spell Chance: " ..  SPELL_CHAT_CHANCE .. "% | Cooldown: " .. MESSAGE_COOLDOWN .. "s | Global CD: " ..  GLOBAL_COOLDOWN .. "s")
        DEFAULT_CHAT_FRAME: AddMessage("  Auto-Reply: " .. tostring(AUTO_REPLY_WHISPERS) .. " | Whisper CD: " ..  WHISPER_REPLY_COOLDOWN .. "s")
        DEFAULT_CHAT_FRAME: AddMessage("  Channel Mode: " .. tostring(CHANNEL_MODE) .. " | Channel: " .. DEMON_CHANNEL)
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffcc99ff[DemonChat]|r Type /dc help for commands")
    end
end

-- Pet spell tracking via CastPetAction hook
local petSpellsToTrack = {["Soothing Kiss"] = true}
local originalCastPetAction = CastPetAction
CastPetAction = function(slot)
    originalCastPetAction(slot)
    if not DemonSpellSpeak or SACRIFICE_ACTIVE or not UnitExists("pet") then return end
    local name = GetPetActionInfo(slot)
    if name and petSpellsToTrack[name] then DemonSpellSpeak(name) end
end