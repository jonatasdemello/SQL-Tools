/* 
To honor the ORDER BY the engine has two alternatives:

    scan the rows using an index that offers the order requested
    sort the rows

First option is fast, second is slow. The problem is that in order to be used, the index has to be a covering index. Meaning it contains all the columns in the SELECT projection list and all the columns used in WHERE clauses (at a minimum). If the index is not covering then the engine would have to lookup the clustered index (ie the 'table') for each row, in order to retrieve the values of the needed columns. This constant lookup of values is expensive, and there is a tipping point when the engine will (rightfully) decide is more efficient to just scan the clustered index and sort the result, in effect ignoring your non-clustered index. For details, see The Tipping Point Query Answers.

Consider the following three queries:
 */
SELECT dateColumn FROM table ORDER BY dateColumn
SELECT * FROM table ORDER BY dateColumn
SELECT someColumn FROM table ORDER BY dateColumn

/*
The first one will be be using a non-clustered index on dateColumn. But a the second one will not be using an index on dateColumn, will likely choose a scan and sort instead for 1M rows. On the other hand the third query can benefit from an index on Table(dateColumn) INCLUDE (someColumn).

This topic is covered at large on MSDN see Index Design Basics , General Index Design Guidelines , Nonclustered Index Design Guidelines or How To: Optimize SQL Indexes.

Ultimately, the most important choice of your table design is the clustered index you use. Almost always the primary key (usually an auto incremented ID) is left as the clustered index, a decision that benefits only certain OLTP loads.

And finally, a rather obvious question: Why in the world would you order 1 million rows?? You can't possibly display them, can you? Explaining a little bit more about your use case might help us find a better answer for you.
 */