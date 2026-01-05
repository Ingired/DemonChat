# DemonChat
DemonChat for World of Warcraft (Vanilla 1.12)
Give voice to your warlock demons! 

Customization Options
Adjust message frequency and cooldowns
Toggle auto-reply to whispers
Channel broadcast mode (share demon chat with party)
Configurable pell reaction chances

Installation:
Download the latest release
Extract to your World of Warcraft\Interface\AddOns\DemonChat
Ensure the folder structure looks like:
Interface\AddOns\DemonChat\DemonChat.lua
Interface\AddOns\DemonChat\DemonChat.toc
Log into World of Warcraft (Vanilla/Classic 1.12)

Type /dc help for commands

⚙️ Configuration
In-Game Commands (/dc or /demonchat)
text
/dc speak          - Make your demon say something idle
/dc autoreply      - Toggle demon auto-reply to whispers
/dc channel        - Toggle channel broadcast mode
/dc testspell X    - Test dialogue for spell X
/dc testmsg X      - Test message type X
/dc list           - List all dialogues for current demon
/dc debug          - Show configuration and status
/dc help           - Show all commands
Code Configuration (Edit DemonChat.lua)
Open the file and adjust these values at the top:

Current Lua:
local MESSAGE_COOLDOWN = 12        -- Seconds between same message type
local GLOBAL_COOLDOWN = 3          -- Seconds between ANY message
local SPELL_CHAT_CHANCE = 70       -- % chance for spell dialogue (1-100)
local AUTO_REPLY_WHISPERS = false  -- Auto-reply to whispers as demon
local DEMON_CHANNEL = "DemonChat"  -- Custom channel name for group chat
local CHANNEL_MODE = false         -- When true, broadcast to channel

Message Types:
Each demon has dialogue for:
summon - When first summoned
combat - Entering combat
idle - Random chatter while idle
lowHealth - Below 25% health
victory - Exiting combat
dismissed - When dismissed
sacrifice - When sacrificed (dramatic!)
healthFunnel - Receiving Health Funnel
playerDeath - When you die
whisperReceived - When you get a whisper
seeDemon - When targeting another demon
whisperReply - Auto-reply to whispers
partyJoin - Succubus only, when party members join
senseHarmfulMagic - Felhunter only, senses debuffs

Plus individual spell reactions!

Requirements:
World of Warcraft 1.12 (Vanilla/Classic Era)
Warlock class (automatically disables for other classes)

FAQ:
Q: Will this work on modern WoW?
A: No, it's specifically designed for Vanilla 1.12. The API calls and event system are for the classic client.

Q: Does it affect gameplay or give advantages?
A: No, it's purely cosmetic/roleplay. Demons don't give tactical advice or reveal hidden information.

Q: Can I add my own dialogue?
A: Yes! Edit the DemonDialogue table in the Lua file. Follow the existing format.

Q: Will it spam chat?
A: No, cooldowns prevent frequent messages. Default is ~12 seconds between same message types.

Q: Can other players see my demon's chatter?
A: By default, no. But you can enable Channel Mode to broadcast to a custom channel.
