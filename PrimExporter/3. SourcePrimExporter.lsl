default
{
    state_entry()
    {
        integer linkNum;
        integer primCount = llGetNumberOfPrims();
        for(linkNum = 1; linkNum <= primCount; linkNum++)
        {
            llMessageLinked(linkNum, 0, "Reveal", NULL_KEY);
        }
        llOwnerSay("Ready.");
    }
}
