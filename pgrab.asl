state("pearlgrabber")
{
    int pearls : 0x01FF62D8, 0x240, 0x148, 0x110, 0x0, 0x50, 0x20, 0x08;
    int dialogLinePtr : 0x01FECE90, 0x820, 0x18, 0x140, 0x160, 0x10, 0x0, 0x428;
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

    // Read a UTF-16 string until a null byte
    vars.ReadString = (Func<Process, IntPtr, string>)((p, ptr) => {
        List<char> chars = new List<char>();
        byte c = p.ReadValue<byte>(ptr);
        int offset = 2;
        while (c != 0x00) {
            chars.Add((char)c);
            c = p.ReadValue<byte>(ptr + offset);
            offset += 2;
        }
        return new string(chars.ToArray());
    });

    // First lines of dialogue from conversations we want to split on
    vars.ConvoOpeners = new List<string> {
        "Oh. Hey. Who are you?",
        "Wow! You found six pearls! That is, simply put, great!",
        "Hey… You ready for that gift?",
        "Woah. Nice. Y’now, you’re really good at this.",
        "I'll be honest. You’re scaring me! Please.",
        "Uh oh... I feel weird",
        "HEllO cHIlD. hOw aRE You.",
        "hello!"
    };
}

init {
    current.dialogueLine = "";
}

start
{
    return false;
}

update {
    if (current.pearls != old.pearls){
        vars.Log("Pearls: " + current.pearls);
    }
    if (current.dialogLinePtr != old.dialogLinePtr){
        IntPtr ptr = new IntPtr((UInt32)current.dialogLinePtr);
        current.dialogueLine = vars.ReadString(game, ptr);
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
        if (index == openers.Count || settings["statue" + index]){
            return true;
        }
    }
}