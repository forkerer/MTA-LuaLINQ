local tabInsert = table.insert
local tabRemove = table.remove
local mathMin = math.min
local mathMax = math.max

Enumerable = {}
Enumerable.emptyFunc = function(a) return a end
Enumerable.metatable = {
    __index = Enumerable,
}
setmetatable( Enumerable, { __call = function(self,...) return self:New(...) end } )

function Enumerable:New()
	local self = setmetatable( {}, Enumerable.metatable )

	self.type = "list"
	self.data = {}

	return self
end

function Enumerable:AddInternal(val)
	tabInsert(self.data, val)
end

function Enumerable.FromList(list)
	if type(list) ~= "table" then
		error("Expected table in Enumerable.FromList, got: "..tostring(type(list)))
	end

	local enum = Enumerable()
	enum.type = "list"
	enum:AddRange(list)

  	return enum
end

function Enumerable.FromDictionary(dict)
	if type(dict) ~= "table" then
		error("Expected table in Enumerable.FromDictionary, got: "..tostring(type(dict)))
	end
	
	local enum = Enumerable()
	enum.type = "dict"
	enum:AddRange(dict)

  	return enum
end

function Enumerable.CastAsEnumerable(tab)
	if type(tab) ~= "table" then
		error("Expected table in Enumerable.CastAsEnumerable, got: "..tostring(type(tab)))
	end

	local enum = Enumerable()
	enum.type = "list"
	enum.data = tab

  	return enum
end

function Enumerable:AddRange(tab)
	if self.type == "list" then
		local tSize = #tab
		for i=1,tSize do
			tabInsert(self.data, tab[i])
		end
	elseif self.type == "dict" then
		for k,v in pairs(tab) do
			local pair = KeyValuePair(k,v)
			tabInsert(self.data, pair)
		end
	end

  	return self
end

function Enumerable:Add(tab, value)
	if self.type == "list" then
		tabInsert(self.data, tab)
	elseif self.type == "dict" then
		local pair = KeyValuePair(tab, value)
		tabInsert(self.data, pair)
	end
	return self
end

function Enumerable:ToList()
	if self.type ~= "list" then
		error("Cannot implicitly convert from Dictionary type to list, use :Select() first")
	end

	local ret = {}
	local tSize = #self.data
	for i=1,tSize do
		ret[i] = self.data[i]
	end
	return ret
end

function Enumerable:ToDictionary()
	if self.type ~= "dict" then
		error("Cannot implicitly convert from List type to dictionary, use :AsDictionary() first")
	end

	local ret = {}
	local tSize = #self.data
	for i=1,tSize do
		ret[self.data[i].key] = self.data[i].value
	end
	return ret
end

function Enumerable:AsDictionary(predicate, ...)
	local func = PredicateParser():GetPredicateFunction(predicate, ...)
	if not func then return end

	local enum = Enumerable()
	enum.type = "dict"

	local tSize = #self.data
	for i=1,tSize do
		local key,val = func(self.data[i], ...)
		local pair = KeyValuePair(key, val)
		enum:AddInternal(pair)
	end

	return enum
end

function Enumerable:Keys()
	if self.type ~= "dict" then
		error("Tried to get keys from enumerable that isn't dictionary")
	end
	local enum = Enumerable()
	enum.type = "list"

	local tSize = #self.data
	for i=1,tSize do
		enum:AddInternal(self.data[i].key)
	end
	return enum
end

function Enumerable:Values()
	if self.type ~= "dict" then
		error("Tried to get values from enumerable that isn't dictionary")
	end
	local enum = Enumerable()
	enum.type = "list"

	local tSize = #self.data
	for i=1,tSize do
		enum:AddInternal(self.data[i].value)
	end
	return enum
end

function Enumerable:Where(predicate, ...)
	local enum = Enumerable()
	enum.type = self.type

	local func = PredicateParser():GetPredicateFunction(predicate, ...)
	if not func then return end

	local tSize = #self.data
	for i=1,tSize do
		if func(self.data[i], ...) then
			enum:AddInternal(self.data[i])
		end
	end

  	return enum
end

function Enumerable:Select(predicate, ...)
	local enum = Enumerable()
	enum.type = "list"

	local func = PredicateParser():GetPredicateFunction(predicate, ...)
	if not func then return end

	local tSize = #self.data
	for i=1,tSize do
		enum:AddInternal(func(self.data[i], ...))
	end
  	return enum
end

function Enumerable:SelectMany(predicate, ...)
	local enum = Enumerable()
	enum.type = "list"

	local func = PredicateParser():GetPredicateFunction(predicate, ...)
	if not func then return end

	local tSize = #self.data
	for i=1,tSize do
		local tab = func(self.data[i], ...)
		if type(tab) ~= "table" then
			error("Expected table as source of data in Enumerable:SelectMany(), but got: ".. tostring(type(tab)))
		end
		for i,v in pairs(tab) do
			enum:AddInternal(v)
		end
	end

  	return enum
end

function Enumerable:Take(num)
	assert(type(num) == "number" and num >= 0, "Expected positive number as argument to Enumerable:Take()")

	local enum = Enumerable()
	enum.type = self.type

	local maxCnt = mathMin(self:Count(), num)
	if maxCnt < 1 then return enum end

	for i=1,maxCnt do
		enum:AddInternal(self.data[i])
	end
  	return enum
end

function Enumerable:Skip(num)
	assert(type(num) == "number" and number >= 0, "Expected positive number as argument to Enumerable:Take()")

	local enum = Enumerable()
	enum.type = self.type

	local startInd = self:Count() - num
	if startInd < 1 then return enum end

	for i=startInd,self:Count() do
		enum:AddInternal(self.data[i])
	end
  	return enum
end

function Enumerable:TakeWhile(predicate, ...)
	local enum = Enumerable()
	enum.type = self.type

	if self:Count() < 2 then return enum end

	local func = PredicateParser():GetPredicateFunction(predicate, ...)
	if not func then return end

	local startInd = 1
	if startInd <= self:Count() and func(self.data[startInd], ...) then
		enum:AddInternal(self.data[startInd])
		startInd = startInd + 1
	end

  	return enum
end

function Enumerable:SkipWhile(predicate, ...)
	local enum = Enumerable()
	enum.type = self.type

	if self:Count() < 2 then return enum end

	local func = PredicateParser():GetPredicateFunction(predicate, ...)
	if not func then return end

	local startInd = 1
	if startInd <= self:Count() and func(self.data[startInd], ...) then
		startInd = startInd + 1
	end

	if startInd <= self:Count() then
		for i=startInd, self:Count() do
			enum:AddInternal(self.data[i])
		end
	end

  	return enum
end

function Enumerable:OrderBy(predicate, ...)
	local enum = Enumerable()
	enum.type = self.type

	for i=1, self:Count() do
		enum:AddInternal(self.data[i])
	end

	PredicateParser():SortingFunction(enum.data, predicate, ...)

	return enum
end

function Enumerable:OrderByDescending(predicate, ...)
	return self:OrderBy(predicate, ...):Reverse()
end

function Enumerable:Reverse()
	local enum = Enumerable()
	enum.type = self.type

	for i=self:Count(), 1, -1 do
		enum:AddInternal(self.data[i])
	end
	return enum
end

function Enumerable:GroupBy(predicate, ...)
end

function Enumerable:Distinct()
	local enum = Enumerable()
	enum.type = self.type

	local hashTab = {}
	for i=1, self:Count() do
		if self.type == "list" then
			if not hashTab[self.data[i]] then
				hashTab[self.data[i]] = true
				enum:AddInternal(self.data[i])
			end
		elseif self.type == "dict" then
			if not hashTab[self.data[i].value] then
				hashTab[self.data[i].value] = true
				enum:AddInternal(self.data[i])
			end
		end
	end
end

function Enumerable:First(predicate, ...)
	if self:Count() < 1 then
		return nil
	end
	if not predicate then
		return self.data[1]
	end

	local func = PredicateParser():GetPredicateFunction(predicate, ...)
	if not func then return end

	for i=1,self:Count() do
		if func(self.data[i], ...) then
			return self.data[i]
		end
	end

  	return nil
end

function Enumerable:FirstOrDefault(default, predicate, ...)
	local res = self:First(predicate, ...)
	if not res then
		res = default
	end
	return res
end

function Enumerable:Last(predicate, ...)
	if self:Count() < 1 then
		return nil
	end
	if not predicate then
		return self.data[self:Count()]
	end

	local func = PredicateParser():GetPredicateFunction(predicate, ...)
	if not func then return end

	for i=self:Count(),1,-1 do
		if func(self.data[i], ...) then
			return self.data[i]
		end
	end

  	return nil
end

function Enumerable:LastOrDefault(default, predicate, ...)
	local res = self:Last(predicate, ...)
	if not res then
		res = default
	end
	return res
end

function Enumerable:Single(predicate, ...)
	if self:Count() < 1 then
		return nil
	end

	local func = PredicateParser():GetPredicateFunction(predicate, ...)
	if not func then return end

	local foundElem = nil
	local tSize = #self.data
	for i=1,tSize do
		if func(self.data[i], ...) then
			if foundElem then
				error("Found multiple entries fitting predicate in Enumerable:Single()")
			end
			foundElem = self.data[i]
		end
	end
	
  	return foundElem
end

function Enumerable:ForEach(predicate, ...)
	if self:Count() < 1 then return end

	local func = PredicateParser():GetPredicateFunction(predicate, ...)
	if not func then return end

	for i=1,self:Count() do
		func(self.data[i], ...)
	end
end

function Enumerable:Count()
	return #self.data
end

function Enumerable:Sum(predicate, ...)
	if self:Count() < 1 then return nil end

	local func = PredicateParser():GetPredicateFunction(predicate, ...)
	if not func then
		func = self.emptyFunc
	end

	local sum = 0
	for i=1,self:Count() do
		sum = sum + func(self.data[i], ...)
	end

	return sum
end

function Enumerable:Average(predicate, ...)
	if self:Count() < 1 then return nil end

	return self:Sum(predicate, ...) / self:Count()
end

function Enumerable:Min(predicate, ...)
	if self:Count() < 1 then return nil end

	local func = PredicateParser():GetPredicateFunction(predicate, ...)
	if not func then
		func = self.emptyFunc
	end

	local min = func(self.data[1])
	if self:Count() < 2 then return min end

	for i=2,self:Count() do
		min = mathMin(min, func(self.data[i], ...)) 
	end

	return min
end

function Enumerable:Max(predicate, ...)
	if self:Count() < 1 then return nil end

	local func = PredicateParser():GetPredicateFunction(predicate, ...)
	if not func then
		func = self.emptyFunc
	end

	local max = func(self.data[1])
	if self:Count() < 2 then return max end

	for i=2,self:Count() do
		max = mathMax(max, func(self.data[i], ...)) 
	end

	return max
end

function Enumerable:Any(predicate, ...)
	if self:Count() < 1 then return false end

	local func = PredicateParser():GetPredicateFunction(predicate, ...)
	if not func then
		func = self.emptyFunc
	end

	for i=1,self:Count() do
		if func(self.data[i], ...) then
			return true
		end
	end
	return false
end

function Enumerable:All(predicate, ...)
	if self:Count() < 1 then return false end

	local func = PredicateParser():GetPredicateFunction(predicate, ...)
	if not func then return end

	for i=1,self:Count() do
		if not func(self.data[i], ...) then
			return false
		end
	end
	return true
end