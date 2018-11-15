# MTA-LuaLINQ
This resource adds LINQ-like functionality to lua, giving ability to perform table queries on bulit in lua tables. It's mostly for-fun project, but can be actually useful in some cases. It allows using either anonymous functions in queries, or c# like predicates passed in string form.
&nbsp;


# File structure:
 - The resource is made of 3 classes:
   - Enumerable class, it's a main resource class, that implements all query functions.
   - PredicateParser class, it's used to parse string based predicates as anonymous functions, to be used in query functions.
   - KeyValuePair class, it's a small wrapper that's used internally in enumerable dictionaries, giving us ability to sort them and work on them like on lists.

# Using it in practice
Example code showing usage of enumerables
```lua
    -- This small script will print names of 10 players closest to localPlayer, excluding him.
    local playerPos = {getElementPosition(localPlayer)}
    Enumerable.FromList(getElementsByType("player"))
        :Where([[p => p ~= localPlayer]])
        :OrderBy([[e,pPos => 
            local vPos = {getElementPosition(e)};
            return getDistanceBetweenPoints3D(vPos[1],vPos[2],vPos[3],pPos[1],pPos[2],pPos[3])]], playerPos)
        :Take(10)
        :ForEach([[p => outputChatBox(p)]])
```
```lua
    -- This one will be used to filter a list of random numbers, based on few conditions
    local nums = {}
    for i=1,10000 do
        nums[i] = math.random(1,5000)
    end

    -- Since we know that given table is a list, we can cast it as enumerable and skip the overhead of copying the collection in Enumerable.FromList
    local enum = Enumerable.CastAsEnumerable(nums)
    local filtered = enum
        :Where([[n => n > 1500]]) -- Keep only numbers above 1500
        :OrderBy([[n => n%10]]) -- Order them using their last digit
        :Select([[n => {base = n, inc = n+1}]]) -- cast them to table containing them, and their incremented version
        :ToList() -- convert it back to normal list

    for _,num in ipairs(filtered) do
        print(num.inc)
    end

    -- We can also do some checks using the linq
    local searchedNum = 2000
    if enum:Any([[n,target => n == target]], searchedNum) then
        print("We have our number!")
    end

    -- Or convert them to dictionaries easily
    local dict = enum
        :AsDictionary([[num => "key_"..num, "val_"..num]]) -- table will have form tab["key_num"] = "val_num"
        :ToDictionary() -- Convert to normal dictionary

    for ind,val in pairs(dict) do
        print(ind, val)
    end
```

# All functions availible for Enumerable:
```lua
    -- Static functions
    Enumerable.FromList( list ) -- Creates new enumerable from list, doesn't work in place.
    Enumerable.FromDictionary( dict ) -- Same as above, but works on dictionaries.
    Enumerable.CastAsEnumerable( list ) -- Casts list as enumerable, skips overhead of FromList, but works in place.

    -- Normal class functions
    Enumerable:AddRange( range ) -- Adds collection of items to current enumerable, the type of collection should match current enumerable
    Enumerable:Add( tab, value) -- Same as above, but only adds a single item, in case of list it adds tab, if it's dictionary, tab is key and value is value
    Enumerable:ToList() -- Converts current enumerable to normal lua list
    Enumerable:ToDictionary() -- Converts current enumerable to normal lua dictionary
    Enumerable:AsDictionary() -- Uses given predicate to convert current list enumerable into dictionary enumerable
    Enumerable:Keys() -- Works only on dictionary, returns all item keys in enumerable
    Enumerable:Values() -- Works only on dictionary, returns all values of items in enumerable

    Enumerable:Where( pred, ... ) -- Filters the enumerable based on given predicate
    Enumerable:Select( pred, ... ) -- Converts all items in enumerable to new format specified by predicate
    Enumerable:SelectMany( pred, ... ) -- Creates new enumerable containing all items matching given predicate, same as SelectMany in C# LINQ
    Enumerable:Take( num ) -- Creates new enumerable containing num first item of current enumerable
    Enumerable:Skip( num ) -- Creates new enumerable containing all elements except of num first ones
    Enumerable:TakeWhile( pred, ... ) -- Creates new enumerable containing all elements fullfiling given predicate until it hits first not matching one
    Enumerable:SkipWhile( pred, ... ) -- Same as above, but skips those elements instead of adding them
    Enumerable:OrderBy( pred, ... ) -- Orders the enumerable using given predicate, for now works only on numeric values, so no string comparisions
    Enumerable:OrderByDescending( pred, ... ) -- Same as above, order is reverted.
    Enumerable:Reverse() -- Reverses current enumerable
    Enumerable:Distinct() -- Removes all repeating elements in enumerable, keeps only a single copy of everything

    -- Those can be invoked without predicate/function passed to them
    Enumerable:First( pred, ... ) -- Returns first element matching given predicate
    Enumerable:FirstOrDefault( default, pred, ... ) -- Same as above, returns given default value if no matching item found
    Enumerable:Single( pred, ... ) -- Returns only element matching given predicate, raises error if more than 1 item matches it.
    Enumerable:Sum( pred, ... ) -- Returns sum of items, processed by given predicate
    Enumerable:Average( pred, ... ) -- Returns average of items, processed by given predicate
    Enumerable:Min( pred, ... ) -- Return a minimal value from enumerable, processed by give predicate
    Enumerable:Max( pred, ... ) -- Same as above, returns maximal value
    Enumerable:Any( pred, ... ) -- Checks if there is any item fullfiling given predicate
    Enumerable:All( pred, ... ) -- Checks whether all items in enumerable fullfil given predicate

    Enumerable:ForEach( pred, ... ) -- Invokes given function with every item passed to it as argument
    Enumerable:Count() -- Returns current count of items in enumerable
    
```

License
----
> ----------------------------------------------------------------------------
> Kamil Marciniak <github.com/forkerer> wrote this code. As long as you retain this 
> notice, you can do whatever you want with this stuff. If we
> meet someday, and you think this stuff is worth it, you can
> buy me a beer in return.
 ----------------------------------------------------------------------------