Used graph functionality.<BR>
Cached interim results into temp tables in 2 cases to reduce execution times. Both situations could be inlined, but the execution time would have gone through the roof.