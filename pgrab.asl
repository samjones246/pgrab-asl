state("pearlgrabber")
{
    int pearls : 0x01FF62D8, 0x240, 0x148, 0x110, 0x0, 0x50, 0x20, 0x08;
    bool canMove : 0x01FF62D8, 0x240, 0x148, 0x110, 0x0, 0x50, 0x20, 0x38;
}


startup
{
    vars.Log = (Action<object>)((output) => print("[Process ASL] " + output));    
}
init {
    vars.skipConvo = new bool[] {true, false, true, false, false, true};
    vars.skipped = false;
    vars.split = 0;
}

start
{
    return false;
}

update {
    if (current.canMove != old.canMove){
        vars.Log("Can move: " + current.canMove);
    }
    if (current.pearls != old.pearls){
        vars.Log("Pearls: " + current.pearls);
    }
}

split {
    if (current.pearls % 6 == 0){
        if (!current.canMove && old.canMove){
            if (vars.skipConvo[vars.split] && !vars.skipped){
                vars.Log("Skipping convo");
                vars.skipped = true;
                return false;
            }
            else {
                vars.Log("Splitting");
                vars.skipped = false;
                vars.split++;
                return true;
            }
        }
    }
    return false;
}