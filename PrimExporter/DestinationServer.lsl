integer listener;
integer line;
string note;
string params;
integer primChannel = 3214;
string prim;
list prims = [];
key rootPrim;
integer linkNum;

init()
{
}
integer Get64Num(string text)
{
    text = "AAAA" + text + "==";
    return llBase64ToInteger(text);    
}

default
{
    state_entry()
    {
        init();
    }
    on_rez(integer i)
    {
        init();
    }
    touch_start(integer num_detected)
    {
        if(llDetectedKey(0) != llGetOwner())
            return;
            
        note = llGetInventoryName(INVENTORY_NOTECARD, 0);
        prim = llGetInventoryName(INVENTORY_OBJECT, 0);
        prims = [];
        rootPrim = NULL_KEY;
        line = 0;
        llGetNotecardLine(note, line++);    
    }
    dataserver(key queryid, string data)
    {
        integer i;
        
        if(data == EOF)
        {
            integer n = llGetListLength(prims);
            
            prims = llListSort(prims, 1, TRUE);
            
            // Rezzing root prim
            llOwnerSay("Rezzing Root Prim");
            llRegionSay(primChannel + 1, "EOF:" + (string)rootPrim);
            
            llSleep(1.0);
            
            llOwnerSay("Rezzing Child Prims");
            for(i = 0; i < n; i++)
            {
                linkNum = llList2Integer(prims, i);
                if(linkNum != 1)
                {
                    llSleep(0.5);
                    llRegionSay(primChannel + linkNum, "EOF:" + (string)rootPrim);
                }
            }
            llOwnerSay("Ready.");
            return;
        }
        else if(data == "")
        {
            llGetNotecardLine(note, line++);
            return;
        }

        // object name/prompt        
        i = llSubStringIndex(data, ": ");
        if(i != -1)
            data = llGetSubString(data, i + 2, -1);
        
        // get link num
        linkNum = Get64Num(llGetSubString(data, 0, 1));
        data = llGetSubString(data, 2, -1);
        
        if(linkNum < 555)
        {
            if(llListFindList(prims, [linkNum]) == -1)
            {
                prims += [linkNum];
                llRezObject(prim, llGetPos(), ZERO_VECTOR, ZERO_ROTATION, primChannel + linkNum);
                llSleep(0.2);
            }
            llRegionSay(primChannel + linkNum, data);
        }
        llGetNotecardLine(note, line++);
    }
    object_rez(key id)
    {
        if(linkNum == 1 && rootPrim == NULL_KEY)
            rootPrim = id;
    }
}