trigger UpdateTitleOnContact on Contact (before insert) {
    for(Contact c : trigger.new)
    {
        c.title = 'Sales head';
    }
}