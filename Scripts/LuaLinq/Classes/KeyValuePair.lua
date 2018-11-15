KeyValuePair = {}
KeyValuePair.metatable = {
    __index = KeyValuePair,
}
setmetatable( KeyValuePair, { __call = function(self,...) return self:New(...) end } )

function KeyValuePair:New(key,value)
	local self = setmetatable( {}, KeyValuePair.metatable )

	self.key = key
	self.value = value

	return self
end

function KeyValuePair:ToTable()
	local ret = {}
	ret[self.key] = self.value
	return ret
end