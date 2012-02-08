default
{
    touch_start(integer total_number)
    {
        integer i;
        for(i = 0; i < total_number; i++)
            llGiveInventory(llDetectedKey(i), "Message.txt");
    }
}
