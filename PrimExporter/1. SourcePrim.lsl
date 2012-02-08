// helpers
integer AllFacesSame(list params, integer chunkSize)
{
    integer i;
    integer n = llGetListLength(params);
    list firstChunk = llList2List(params, 0, chunkSize - 1);
    list buffer;
    for(i = chunkSize; i < n; i += chunkSize)
    {
        buffer = llList2List(params, i, i + chunkSize - 1);
        if(llListFindList(buffer, firstChunk) == -1)
            return FALSE;
    }
    return TRUE;
}
string Rotation(rotation r)
{
    if(r == ZERO_ROTATION)
        return "<r>";// shorthand
    // replace comma-space delimiters with comma
    return "<" 
        + Float(r.x, TRUE) + ","
        + Float(r.y, TRUE) + ","
        + Float(r.z, TRUE) + ","
        + Float(r.s, TRUE) + ">";
}
string Vector(vector v)
{
    if(v == ZERO_VECTOR)
        return "<v>";// shorthand
    // replace comma-space delimiters with comma
    return "<"
        + Float(v.x, TRUE) + ","
        + Float(v.y, TRUE) + ","
        + Float(v.z, TRUE) + ">";
}
string Float(float f, integer integerOk)
{
    // only get last 3 decimals
    f = llCeil(f * 1000) * .001;
    string s = (string)f;
    
    // remove 0's at end
    while(llGetSubString(s, -1, -1) == "0")
        s = llGetSubString(s, 0, -2);
    
    // if string ends with decimal
    if(llGetSubString(s, -1, -1) == ".")
    {
        // if we can show numbers without decimal point
        if(integerOk)
            // remove decimal
            s = llGetSubString(s, 0, -2);
        else
            // add trailing 0
            s+= "0";
    }
    // remove sign if number is 0
    if(s == "-0") s== "0";
    if(s == "-0.0") s = "0.0";
    
    return s;
}
string ByteToBase64(integer value)
{
    // value is between 0 "AA" and 255 "/w"
    string text = llIntegerToBase64(value);
    // AAAA??==
    return llGetSubString(text, 4, 5);
}

// prim readers
list Shinies()
{
    string s;
    list params = llGetPrimitiveParams([PRIM_BUMP_SHINY, ALL_SIDES]);
    
    if(AllFacesSame(params, 2))
    {
        return Shiny(0, params, ALL_SIDES);
    }
    else
    {
        integer n = llGetListLength(params);
        integer i;
        integer j = 0;
        list rules = [];
        for(i = 0; i < n; i+= 2)
            rules += Shiny(i, params, j++);
        return rules;
    }
}
list Shiny(integer i, list params, integer face)
{
    if(llList2Integer(params, i) == PRIM_SHINY_NONE
        && llList2Integer(params, i + 1) == PRIM_BUMP_NONE)
        return [];
    
    return [PRIM_BUMP_SHINY, face] + llList2List(params, i, i + 1);
}
list Colors()
{
    list params = llGetPrimitiveParams([PRIM_COLOR, ALL_SIDES]);
    if(AllFacesSame(params, 2))
    {
        return Color(0, params, ALL_SIDES);
    }
    else
    {
        integer n = llGetListLength(params);
        integer i;
        integer j = 0;
        list rules = [];
        for(i = 0; i < n; i+= 2)
            rules += Color(i, params, j++);
        return rules;
    }
}
list Color(integer i, list params, integer face)
{
    list params = llList2List(params, i, i + 1);
    if(llListFindList(params, [<1,1,1>, 1.0]) == 0) return [];
    return [PRIM_COLOR, face] + params;
}
list Flexible()
{
    list params = llGetPrimitiveParams([PRIM_FLEXIBLE]);
    if(llListFindList(params, [0, 2, 0.3, 2.0, 0.0, 1.0, ZERO_VECTOR]) == 0) return [];
    return [PRIM_FLEXIBLE] + params;
}
list FullBrights()
{
    list params = llGetPrimitiveParams([PRIM_FULLBRIGHT, ALL_SIDES]);
    if(AllFacesSame(params, 1))
    {
        if(llList2Integer(params, 0) == FALSE) return [];
        return [PRIM_FULLBRIGHT, ALL_SIDES, TRUE];
    }
    else
    {
        integer n = llGetListLength(params);
        integer i;
        list rules = [];
        for(i = 0; i < n; i++)
            if(llList2Integer(params, i) == TRUE)
                rules += [PRIM_FULLBRIGHT, i, llList2Integer(params, i)];
        return rules;
    }
}
list Material()
{
    list params = llGetPrimitiveParams([PRIM_MATERIAL]);
    if(llList2Integer(params, 0) == PRIM_MATERIAL_WOOD) return []; // default
    return [PRIM_MATERIAL] + params;
}
list Phantom()
{
    list params = llGetPrimitiveParams([PRIM_PHANTOM]);
    if(llList2Integer(params, 0) == FALSE) return []; // default
    return [PRIM_PHANTOM, TRUE];
}
list Physics()
{
    list params = llGetPrimitiveParams([PRIM_PHYSICS]);
    if(llList2Integer(params, 0) == FALSE) return [];
    return [PRIM_PHYSICS, TRUE];
}
list PointLight()
{
    list params = llGetPrimitiveParams([PRIM_POINT_LIGHT]);
    if(llListFindList(params, [0, <1.0, 1.0, 1.0>, 1.0, 10.0, 0.75]) == 0) return [];
    return [PRIM_POINT_LIGHT] + params;
}
list PrimRotation()
{
    list params = llGetPrimitiveParams([PRIM_ROTATION]);
    if(llList2Rot(params, 0) == ZERO_ROTATION) return [];
    return [PRIM_ROTATION] + params;
}
list Size()
{
    list params = llGetPrimitiveParams([PRIM_SIZE]);
    if(llList2Vector(params, 0) == <0.5, 0.5, 0.5>) return [];
    return [PRIM_SIZE] + params;
}
list TempOnRez()
{
    list params = llGetPrimitiveParams([PRIM_TEMP_ON_REZ]);
    if(llList2Integer(params, 0) == FALSE) return [];
    return [PRIM_TEMP_ON_REZ, TRUE];
}
list Type()
{
    list params = llGetPrimitiveParams([PRIM_TYPE]);
    if(llListFindList(params, [0, 0, <0.0, 1.0, 0.0>, 0.0, ZERO_VECTOR, <1.0, 1.0, 0.0>, ZERO_VECTOR]) == 0) return [];
    return [PRIM_TYPE] + params;
}
list TextureMaps()
{
    list params = llGetPrimitiveParams([PRIM_TEXGEN, ALL_SIDES]);
    if(AllFacesSame(params, 1))
    {
        return TextureMap(llList2Integer(params, 0), ALL_SIDES);
    }
    else
    {
        integer n = llGetListLength(params);
        integer i;
        list rules = [];
        for(i = 0; i < n; i++)
            rules += TextureMap(llList2Integer(params, i), i);
        return rules;
    }
}
list TextureMap(integer type, integer face)
{
    if(type == 0) return [];
    return [PRIM_TEXGEN, face, type];
}
list Textures()
{
    string s;
    list params = llGetPrimitiveParams([PRIM_TEXTURE, ALL_SIDES]);
    if(AllFacesSame(params, 4))
    {
        return Texture(0, params, ALL_SIDES);
    }
    else
    {
        integer n = llGetListLength(params);
        integer i;
        integer j = 0;
        list rules = [];
        for(i = 0; i < n; i += 4)
            rules += Texture(i, params, j++);
        return rules;
    }
}
list Texture(integer i, list params, integer face)
{
    params = llList2List(params, i, i + 3);
    list defaultParams = [(key)"89556747-24cb-43ed-920b-47caed15465f", <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0];
    if(llListFindList(params, defaultParams) == 0) return [];
    return [PRIM_TEXTURE, face] + params;
}
integer OwnerDetected(integer num_detected)
{
    integer i;
    integer ownerTouched = FALSE;
    for(i = 0; i < num_detected; i++)
    {
        if(llDetectedKey(i) != llGetOwner())
            llInstantMessage(llDetectedKey(i), "Undergoing preperations for export. Please refrain from interacting with me.");
        else
            ownerTouched = TRUE;
    }
    return ownerTouched;
}
vector OffsetPos()
{
    vector pos = ZERO_VECTOR;
    // root prim is always zero
    
    // if we are not the root prim
    if(llGetLinkNumber() != 1)
    {
        // find position within world
        list posParams = llGetPrimitiveParams([PRIM_POSITION]);
        pos = llList2Vector(posParams, 0);
        
        // get relative position to root (within sim)
        pos -= llGetRootPosition();
    }
    
    return pos;
}
default
{
    state_entry()
    {
        if(llGetLinkNumber() == 2)
        {
            llOwnerSay("Once the scripts are running, drop SourcePrimExporter.lsl into the object.");
        }
    }
    touch_start(integer num_detected)
    {
        
        // cancel if owner not detected
        if(!OwnerDetected(num_detected)) return;
        
        // This is for debug purposes, so lets be verbose
        
        vector pos = OffsetPos();
        
        llOwnerSay("Link Number: " + (string)llGetLinkNumber());
        llOwnerSay("Relative Position: " + (string)pos);
        llOwnerSay("Shinies: " + llList2CSV(Shinies()));
        llOwnerSay("Colors: " + llList2CSV(Colors()));
        llOwnerSay("Flexible: " + llList2CSV(Flexible()));
        llOwnerSay("Full Brights: " + llList2CSV(FullBrights()));
        llOwnerSay("Material: " + llList2CSV(Material()));
        llOwnerSay("Phantom: " + llList2CSV(Phantom()));
        llOwnerSay("Physics: " + llList2CSV(Physics()));
        llOwnerSay("Light: " + llList2CSV(PointLight()));
        llOwnerSay("Rotation: " + llList2CSV(PrimRotation()));
        llOwnerSay("Size: " + llList2CSV(Size()));
        llOwnerSay("Temporary: " + llList2CSV(TempOnRez()));
        llOwnerSay("Building Block Type: " + llList2CSV(Type()));
        llOwnerSay("Mapping: " + llList2CSV(TextureMaps()));
        llOwnerSay("Textures: " + llList2CSV(Textures()));
        
        list rules = 
            [
                llGetLinkNumber(), 
                llStringToBase64(llGetObjectName()), // encode commas
                llStringToBase64(llGetObjectDesc()), // encode commas
                pos
            ] +
            Shinies() + 
            Colors() + 
            Flexible() + 
            FullBrights() + 
            Material() + 
            Phantom() + 
            Physics() + 
            PointLight() + 
            PrimRotation() + 
            Size() + 
            TempOnRez() + 
            Type() + 
            TextureMaps() + 
            Textures();
        
        integer i;
        integer n = llGetListLength(rules);
        for(i = 0; i < n; i++)
        {
            integer type = llGetListEntryType(rules, i);
            
            if(type == TYPE_FLOAT)
                rules = llListReplaceList(rules, [Float(llList2Float(rules, i), TRUE)], i, i);
            else if(type == TYPE_VECTOR)
                rules = llListReplaceList(rules, [Vector(llList2Vector(rules, i))], i, i);
            else if(type == TYPE_ROTATION)
                rules = llListReplaceList(rules, [Rotation(llList2Rot(rules, i))], i, i);
        }
        string msg = llList2CSV(rules);
        integer p = 0;
        
        while(msg != "")
        {
            if(llStringLength(msg) <= 75)
            {
                llSleep(5.0);// make short stuff appear at end
                llInstantMessage(llGetOwner(), (string)p + ": " + msg);
                msg = "";
            }
            else
            {
                llInstantMessage(llGetOwner(), (string)p + ": " + llGetSubString(msg, 0, 74));
                msg = llGetSubString(msg, 75, -1);
            }
            p++;
        }
        
        msg = llList2CSV(rules);
        msg = llStringToBase64(msg);
        string prefix = ByteToBase64(llGetLinkNumber());
        p = 0;
        while(msg != "")
        {
            if(llStringLength(msg) <= 75)
            {
                llSleep(5.0);// make short stuff appear at end
                llInstantMessage(llGetOwner(),prefix + ByteToBase64(p) + msg);
                msg = "";
            }
            else
            {
                llInstantMessage(llGetOwner(), prefix + ByteToBase64(p) + llGetSubString(msg, 0, 74));
                msg = llGetSubString(msg, 75, -1);
            }
            p++;
        }        
    }
    link_message(integer sender_num, integer num, string str, key id)
    {
        if(str != "Reveal") return;
        
        vector pos = ZERO_VECTOR;
        if(llGetLinkNumber() != 1)
        {
            list posParams = llGetPrimitiveParams([PRIM_POSITION]);
            pos = llList2Vector(posParams, 0);
            pos -= llGetRootPosition();
        }
        
        list rules = 
            [
                llGetLinkNumber(), 
                llStringToBase64(llGetObjectName()), // encode commas
                llStringToBase64(llGetObjectDesc()), // encode commas
                pos
            ] +
            Shinies() + 
            Colors() + 
            Flexible() + 
            FullBrights() + 
            Material() + 
            Phantom() + 
            Physics() + 
            PointLight() + 
            PrimRotation() + 
            Size() + 
            TempOnRez() + 
            Type() + 
            TextureMaps() + 
            Textures();
        
        integer i;
        integer n = llGetListLength(rules);
        for(i = 0; i < n; i++)
        {
            integer type = llGetListEntryType(rules, i);
            
            if(type == TYPE_FLOAT)
                rules = llListReplaceList(rules, [Float(llList2Float(rules, i), TRUE)], i, i);
            else if(type == TYPE_VECTOR)
                rules = llListReplaceList(rules, [Vector(llList2Vector(rules, i))], i, i);
            else if(type == TYPE_ROTATION)
                rules = llListReplaceList(rules, [Rotation(llList2Rot(rules, i))], i, i);
        }
        string msg = llList2CSV(rules);
        
        string name = llGetObjectName();
        llSetObjectName("Export");
        string prefix = ByteToBase64(llGetLinkNumber());
        integer p = 0;
        msg = llStringToBase64(msg);
        while(msg != "")
        {
            if(llStringLength(msg) <= 75)
            {
                llSleep(5.0);// make short stuff appear at end
                llInstantMessage(llGetOwner(),prefix + ByteToBase64(p) + msg);
                msg = "";
            }
            else
            {
                llInstantMessage(llGetOwner(), prefix + ByteToBase64(p) + llGetSubString(msg, 0, 74));
                msg = llGetSubString(msg, 75, -1);
            }
            p++;
        }
        llSetObjectName(name);
        
        llRemoveInventory(llGetScriptName());
    }
}