integer listener;
list data;
integer myNum;
key myRoot;

integer isVector(string value)
{
    if(value == "<v>") return TRUE;
    if(value == "<,,>") return TRUE;
    if(value == "<, , >") return TRUE;
    if(llGetSubString(value, 0, 0) != "<")
        return FALSE;
    if(llGetSubString(value, -1, -1) != ">")
        return FALSE;
    value = llGetSubString(value, 1, -2);
    list params = llParseString2List(value, [", ", ","], []);
    integer n = llGetListLength(params);
    if(n != 3) return FALSE;
    integer i;
    for(i = 0; i < n; i++)
        if(!isFloat(llList2String(params, i)))
            return FALSE;
    return TRUE;
}
integer isRotation(string value)
{
    if(value == "<r>") return TRUE;
    if(value == "<,,,>") return TRUE;
    if(value == "<, , , >") return TRUE;
    if(llGetSubString(value, 0, 0) != "<")
        return FALSE;
    if(llGetSubString(value, -1, -1) != ">")
        return FALSE;
    value = llGetSubString(value, 1, -2);
    list params = llParseString2List(value, [", ", ","], []);
    integer n = llGetListLength(params);
    if(n != 4) return FALSE;
    integer i;
    for(i = 0; i < n; i++)
        if(!isFloat(llList2String(params, i)))
            return FALSE;
    return TRUE;
}
integer isInteger(string value)
{
    if(value == "") return FALSE;
    integer i;
    integer n = llStringLength(value);
    for(i = 0; i < n; i++)
    {
        string char = llGetSubString(value, i, i);
        if(llSubStringIndex("-0123456789", char) == -1)
            return FALSE;
        if(char == "-" && i != 0)
            return FALSE;
    }
    return TRUE;
}
integer isFloat(string value)
{
    if(value == "") return FALSE;
    integer i;
    integer d = 0;
    integer n = llStringLength(value);
    for(i = 0; i < n; i++)
    {
        string char = llGetSubString(value, i, i);
        if(llSubStringIndex("-0123456789.", char) == -1)
            return FALSE;
        if(char == "-" && i != 0)
            return FALSE;
        if(char == "." && d != 0)
            return FALSE;
        if(char == ".")
            d++;
    }
    return TRUE;
}
integer isString(string value)
{
    if(value == "") return FALSE;
    if(llGetSubString(value, 0, 0) == "\"" && llGetSubString(value, -1, -1) == "\"")
        return TRUE;
    return FALSE;
}
integer isKey(string value)
{
    if(value == "") return FALSE;
    
    if(llGetSubString(value, 0, 0) == "\"" && llGetSubString(value, -1, -1) == "\"")
        value = llGetSubString(value, 1, -2);
    
    integer i;
    integer n = llStringLength(value);
    if(n != 36) return FALSE;
    for(i = 0; i < n; i++)
    {
        string char = llGetSubString(value, i, i);
        if(i == 8 || i == 13 || i == 18 || i == 23)
        {
            if(char != "-")
                return FALSE;
        }
        else
        {
            if(llSubStringIndex("0123456789abcdefABCDEF", char) == -1)
                return FALSE;
        }
    }
    return TRUE;
}

default
{
    state_entry()
    {
        llRequestPermissions(llGetOwner(), PERMISSION_CHANGE_LINKS);
    }
    on_rez(integer start_param)
    {
        if(start_param == 0)
            llRequestPermissions(llGetOwner(), PERMISSION_CHANGE_LINKS);
        else
            listener = llListen(start_param, "", NULL_KEY, "");
    }
    run_time_permissions(integer perm)
    {
        // Only bother rezzing the object if will be able to link it.
        if (perm & PERMISSION_CHANGE_LINKS)
            llOwnerSay("Permission acquired.");
        else
            llRequestPermissions(llGetOwner(), PERMISSION_CHANGE_LINKS);
    }
    listen(integer channel, string name, key id, string message)
    {
        if(llSubStringIndex(message, "EOF:") != 0)
        {
            integer partNum = llBase64ToInteger("AAAA" + llGetSubString(message, 0, 1) + "==");
            //partNum--;
            message = llGetSubString(message, 2, -1);
            while(partNum >= llGetListLength(data))
                data += [""];
            data = llListReplaceList(data, [message], partNum, partNum);            
        }
        else
        {
            llListenRemove(listener);
            key rootPrim = llGetSubString(message, 4, -1);
            
            
            string fullData = llDumpList2String(data, "");
            fullData = llBase64ToString(fullData);
        
            list params = llCSV2List(fullData);
            integer i = 0;
            integer n = llGetListLength(params);
            for(i = 0; i < n; i++)
            {
                string value = llList2String(params, i);
                if(llSubStringIndex(value, "<") == 0)
                {
                    list temp = llParseStringKeepNulls(value, [","], []);
                    value = llDumpList2String(temp, ", ");
                }
                
                if(value == "<,,>" || value == "<v>" || value == "<, , >")
                    params = llListReplaceList(params, [ZERO_VECTOR], i, i);
                else if(value == "<,,,>" || value == "<r>" || value == "<, , , >")
                    params = llListReplaceList(params, [ZERO_ROTATION], i, i);
                else if(isInteger(value))
                    params = llListReplaceList(params, [(integer)value], i, i);
                else if(isFloat(value))
                    params = llListReplaceList(params, [(float)value], i, i);
                else if(isVector(value))
                    params = llListReplaceList(params, [(vector)value], i, i);
                else if(isRotation(value))
                    params = llListReplaceList(params, [(rotation)value], i, i);
                else if(isKey(value))
                {
                    if(isString(value))
                        params = llListReplaceList(params, [(key)llGetSubString(value, 1, -2)], i, i);
                    else
                        params = llListReplaceList(params, [(key)value], i, i);
                }
                else if(isString(value))
                    params = llListReplaceList(params, [llGetSubString(value, 1, -2)], i, i);
                else
                    params = llListReplaceList(params, [value], i, i);
            }
            
            integer linkNum = llList2Integer(params, 0);
            
            string objName = llList2String(params, 1);
            if(objName != "")
                objName = llBase64ToString(objName);
            llSetObjectName(objName);
            
            string desc = llList2String(params, 2);
            if(desc != "")
                desc = llBase64ToString(desc);
            llSetObjectDesc(desc);
            
            vector pos = llList2Vector(params, 3);
            
            // relative position
            //pos += llGetPos();
            //pos = llGetPos() - pos;
            vector rootPos = llGetPos();
            pos.x = rootPos.x + pos.x;
            pos.y = rootPos.y + pos.y;
            pos.z = rootPos.z + pos.z;
            
            vector lastPos = llGetPos();
            float travel = 100.0;
            while(llGetPos() != pos && travel > 9.0)
            {
                lastPos = llGetPos();
                llSetPos(pos);
                travel = llVecDist(lastPos, llGetPos());
            }
            params = llList2List(params, 4, -1);
            
            llSetPrimitiveParams(params);
            
            if(linkNum != 1)
                llCreateLink(rootPrim, FALSE);
            llRemoveInventory(llGetScriptName());
        }
    }
}