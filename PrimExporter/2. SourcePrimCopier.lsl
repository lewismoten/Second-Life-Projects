default
{
    state_entry()
    {
        llOwnerSay("Copying SourcePrim.lsl to child prims.");
        integer linkNum;
        integer primCount = llGetNumberOfPrims();
        string script = "1. SourcePrim.lsl";
        
        if(llGetInventoryType(script) == INVENTORY_NONE)
            llOwnerSay("Script is missing: \"" + script + "\"");
        else
        {        
            // give scripts to children
            for(linkNum = 1; linkNum <= primCount; linkNum++)
            {
                if(linkNum != llGetLinkNumber())
                {
                    key destination = llGetLinkKey(linkNum);
                    llGiveInventory(destination, script);
                }
            }
            
            llOwnerSay("Goto Tools -> Set Scripts to Running in Selection.");
        }
        llRemoveInventory(llGetScriptName());
    }
    
}
