This is a nasty one.<BR>
Part 2 pushed me past the 32767 maxrecursion limit, so I had to break the recursion into a loop to process maxrecursion limit each iteration and dump the interim results into a temp table.<BR>
Tried to do the 3 recursion in the same statement, but it hung there forever.
Could be done in a single statement if it wasn't for the maxrecursion limit.
