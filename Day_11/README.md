This is a nasty one.<BR>
Part 2 pushed me past the 32767 maxrecursion limit, so I had to break the recursion into 3 steps and dump the interim results into temp tables.
Tried to do the 3 recursion in the same statement, but it hung there forever.
