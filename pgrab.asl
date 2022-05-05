state("pearlgrabber")
{
    int pearls : 0x01FF62D8, 0x240, 0x148, 0x110, 0x0, 0x50, 0x20, 0x08;
    int dialogLinePtr : 0x01FECE90, 0x820, 0x18, 0x140, 0x160, 0x10, 0x0, 0x428;
    bool canMove : 0x01FF62D8, 0x240, 0x148, 0x110, 0x0, 0x50, 0x20, 0x38;
    float playerX : 0x01FEDCB0, 0xE8, 0x0, 0x48, 0x18, 0x180, 0x268, 0x40;
    float playerZ : 0x01FEDCB0, 0xE8, 0x0, 0x48, 0x18, 0x180, 0x268, 0x48;
    bool startVisible : 0x01FECE30, 0x300, 0x18, 0x8, 0x38, 0x70, 0x28, 0x255;
}


startup
{
    vars.Log = (Action<object>)((output) => print("[Pearl Grabber ASL] " + output));

    settings.Add("splitPearl", false, "Split on collecting a pearl");
    settings.Add("splitPearl_6", true, "Split every 6th pearl");
    settings.Add("splitStatue", false, "Split on statue conversation");
    settings.Add("statue0", false, "Intro", "splitStatue");
    settings.Add("statue1", false, "After 6 Pearls", "splitStatue");
    settings.Add("statue2", false, "After 12 Pearls", "splitStatue");
    settings.Add("statue3", false, "After 18 Pearls", "splitStatue");
    settings.Add("statue4", false, "After 24 Pearls", "splitStatue");
    settings.Add("statue5", false, "After 30 Pearls", "splitStatue");
    settings.Add("statue6", false, "After 36 Pearls", "splitStatue");

    // First lines of dialogue from conversations we want to split on
    vars.ConvoOpeners = new List<string> {
        "Oh. Hey. Who are you?",
        "Wow! You found six pearls! That is, simply put, great!",
        "Hey… You ready for that gift?",
        "Woah. Nice. Y’now, you’re really good at this.",
        "I'll be honest. You’re scaring me! Please.",
        "Uh oh... I feel weird",
        "HEllO cHIlD. hOw aRE You.",
        "hello!",
    };

    vars.initPlayerX = 60.344;
    vars.initPlayerZ = 80.504;
}

init {
    current.dialogueLine = "";
    vars.endConvoStarted = false;
    vars.started = false;
    vars.Log("Initialized");
}

start
{
    // Split on either first movement or pressing start
    if (!vars.started){
        // First movement
        if (old.playerX == (float)vars.initPlayerX && old.playerZ == (float)vars.initPlayerZ) {
            if (current.playerX != old.playerX || current.playerZ != old.playerZ) {
                vars.Log("Player moved");
                vars.started = true;
                return true;
            }
        }
        // Start pressed
        if(!current.startVisible && old.startVisible){
            vars.Log("Start clicked");
            return true;
        }
    }

    return false;
}

update {
    if (current.pearls != old.pearls){
        vars.Log("Pearls: " + current.pearls);
    }
    if (current.dialogLinePtr != old.dialogLinePtr){
        IntPtr ptr = new IntPtr((UInt32)current.dialogLinePtr);
        current.dialogueLine = game.ReadString(ptr, 256);
        vars.Log("Dialogue: " + current.dialogueLine);
    }else{
        current.dialogueLine = old.dialogueLine;
    }
}

split {
    if (current.pearls > old.pearls){
        if (settings["splitPearl"] || (settings["splitPearl_6"] && current.pearls % 6 == 0)){
            return true;
        }
    }
    if (current.dialogueLine != old.dialogueLine){
        
        List<string> openers = vars.ConvoOpeners;
        int index = openers.IndexOf(current.dialogueLine);
        if (index == -1){
            return false;
        }
        if (index == openers.Count - 1){
            vars.endConvoStarted = true;
            return false;
        }
        if (settings["statue" + index]){
            return true;
        }
    }
    if (vars.endConvoStarted && current.canMove){
        vars.endConvoStarted = false;
        return true;
    }
}