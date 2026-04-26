local __M = {}
local __cache = {}
local __loading = {}
local function __register(id, fn)
__M[id] = fn
end
local function __resolve(path)
local id = table.concat(path, "/")
if __M[id] then return id end
local id2 = id .. "/init"
if __M[id2] then return id2 end
return nil
end
local __makeProxy
__makeProxy = function(path)
local self = { __path = path, __isScriptProxy = true }
local proxyMt
proxyMt = {
__index = function(_, k)
if k == "__path" or k == "__isScriptProxy" then return rawget(self, k) end
if k == "Parent" then
local p = table.create(math.max(0, #path - 1))
for i = 1, #path - 1 do p[i] = path[i] end
return __makeProxy(p)
elseif k == "Name" then
return path[#path] or ""
elseif k == "ClassName" then
return "ModuleScript"
elseif k == "FindFirstChild" then
return function(_, name)
local p = table.clone(path)
table.insert(p, name)
if __resolve(p) then return __makeProxy(p) end
return nil
end
elseif k == "WaitForChild" then
return function(_, name)
local p = table.clone(path)
table.insert(p, name)
return __makeProxy(p)
end
elseif k == "FindFirstAncestor" or k == "FindFirstAncestorOfClass" or k == "FindFirstAncestorWhichIsA" then
return function() return nil end
elseif k == "FindFirstDescendant" then
return function() return nil end
elseif k == "GetFullName" then
return function() return table.concat(path, ".") end
elseif k == "IsA" then
return function(_, className)
return className == "ModuleScript" or className == "Instance" or className == "LuaSourceContainer"
end
elseif k == "GetChildren" or k == "GetDescendants" then
return function() return {} end
elseif k == "GetActor" then
return function() return nil end
elseif k == "Archivable" then
return true
else
local p = table.clone(path)
table.insert(p, k)
return __makeProxy(p)
end
end,
__newindex = function() end,
__tostring = function() return table.concat(path, ".") end,
__metatable = "ScriptProxy",
}
setmetatable(self, proxyMt)
return self
end
local __require
__require = function(target)
local id
if type(target) == "string" then
id = __M[target] and target or (__M[target .. "/init"] and (target .. "/init")) or target
elseif type(target) == "table" and target.__isScriptProxy then
id = __resolve(target.__path)
if not id then
error("Roreact: module not found: " .. tostring(target), 2)
end
else
error("Roreact: __require expected proxy or string, got " .. type(target), 2)
end
if __cache[id] ~= nil then
return __cache[id]
end
if __loading[id] then
error("Roreact: circular dependency on " .. id, 2)
end
local loader = __M[id]
if not loader then
error("Roreact: no loader registered for " .. id, 2)
end
__loading[id] = true
local ok, result = pcall(loader)
__loading[id] = nil
if not ok then
error("Roreact: error loading " .. id .. ": " .. tostring(result), 2)
end
__cache[id] = (result == nil) and false or result
return __cache[id]
end
if rawget(_G, "__DEV__") == nil then _G.__DEV__ = false end
if rawget(_G, "__PROFILE__") == nil then _G.__PROFILE__ = false end
if rawget(_G, "__EXPERIMENTAL__") == nil then _G.__EXPERIMENTAL__ = false end
if rawget(_G, "__DEBUG__") == nil then _G.__DEBUG__ = false end
if rawget(_G, "__YOLO__") == nil then _G.__YOLO__ = false end
__register("SafeFlags", function()
return {
createGetFFlag = function(_name)
return function() return false end
end,
createGetFInt = function(_name, default)
local d = tonumber(default) or 0
return function() return d end
end,
createGetFString = function(_name, default)
local d = tostring(default or "")
return function() return d end
end,
}
end)
__register("ES7Types/init", (function()
local script = __makeProxy({"ES7Types"})
return function()
type Object = { [string]: any }
type Array<T> = { [number]: T }
type Function = (...any) -> ...any
type Table<T, V> = { [T]: V }
type Tuple<T, V> = Array<T | V>
type mapCallbackFn<K, V> = (element: V, key: K, map: Map<K, V>) -> ()
type mapCallbackFnWithThisArg<K, V> = (thisArg: Object, value: V, key: K, map: Map<K, V>) -> ()
type Map<K, V> = typeof(setmetatable(
{} :: {
size: number,
set: (self: Map<K, V>, K, V) -> Map<K, V>,
get: (self: Map<K, V>, K) -> V | nil,
clear: (self: Map<K, V>) -> (),
delete: (self: Map<K, V>, K) -> boolean,
forEach: (
self: Map<K, V>,
callback: mapCallbackFn<K, V> | mapCallbackFnWithThisArg<K, V>,
thisArg: Object?
) -> (),
[K]: V,
has: (self: Map<K, V>, K) -> boolean,
keys: (self: Map<K, V>) -> Array<K>,
values: (self: Map<K, V>) -> Array<V>,
entries: (self: Map<K, V>) -> Array<Tuple<K, V>>,
ipairs: (self: Map<K, V>) -> any,
_map: { [K]: V },
_array: { [number]: K },
__index: (self: Map<K, V>, key: K) -> V,
__iter: (self: Map<K, V>) -> (<K, V>({ [K]: V }, K?) -> (K?, V), V),
__newindex: (self: Map<K, V>, key: K, value: V) -> (),
},
{} :: {
__index: Map<K, V>,
__iter: (self: Map<K, V>) -> (<K, V>({ [K]: V }, K?) -> (K, V), V),
__newindex: (self: Map<K, V>, key: K, value: V) -> (),
}
))
type WeakMap<K, V> = {
get: (self: WeakMap<K, V>, K) -> V,
set: (self: WeakMap<K, V>, K, V) -> WeakMap<K, V>,
has: (self: WeakMap<K, V>, K) -> boolean,
}
type setCallbackFn<T> = (value: T, key: T, set: Set<T>) -> ()
type setCallbackFnWithThisArg<T> = (thisArg: Object, value: T, key: T, set: Set<T>) -> ()
type Set<T> = typeof(setmetatable(
{} :: {
size: number,
add: (self: Set<T>, T) -> Set<T>,
clear: (self: Set<T>) -> (),
delete: (self: Set<T>, T) -> boolean,
forEach: (self: Set<T>, callback: setCallbackFn<T> | setCallbackFnWithThisArg<T>, thisArg: Object?) -> (),
has: (self: Set<T>, T) -> boolean,
ipairs: (self: Set<T>) -> any,
},
{} :: {
__index: Set<T>,
__iter: (self: Set<T>) -> (<K, V>({ [K]: V }, K?) -> (K, V), T),
}
))
return {}
end
end)())
__register("Number/init", (function()
local script = __makeProxy({"Number"})
return function()
return {
isFinite = __require(script.isFinite),
isInteger = __require(script.isInteger),
isNaN = __require(script.isNaN),
isSafeInteger = __require(script.isSafeInteger),
MAX_SAFE_INTEGER = __require(script.MAX_SAFE_INTEGER),
MIN_SAFE_INTEGER = __require(script.MIN_SAFE_INTEGER),
NaN = 0 / 0,
toExponential = __require(script.toExponential),
}
end
end)())
__register("Number/isFinite", (function()
local script = __makeProxy({"Number","isFinite"})
return function()
return function(value)
return typeof(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end
end
end)())
__register("Number/isInteger", (function()
local script = __makeProxy({"Number","isInteger"})
return function()
return function(value)
return type(value) == "number" and value ~= math.huge and value == math.floor(value)
end
end
end)())
__register("Number/isNaN", (function()
local script = __makeProxy({"Number","isNaN"})
return function()
return function(value)
return type(value) == "number" and value ~= value
end
end
end)())
__register("Number/isSafeInteger", (function()
local script = __makeProxy({"Number","isSafeInteger"})
return function()
local isInteger = __require(script.Parent.isInteger)
local MAX_SAFE_INTEGER = __require(script.Parent.MAX_SAFE_INTEGER)
return function(value)
return isInteger(value) and math.abs(value) <= MAX_SAFE_INTEGER
end
end
end)())
__register("Number/MAX_SAFE_INTEGER", (function()
local script = __makeProxy({"Number","MAX_SAFE_INTEGER"})
return function()
return 9007199254740991
end
end)())
__register("Number/MIN_SAFE_INTEGER", (function()
local script = __makeProxy({"Number","MIN_SAFE_INTEGER"})
return function()
return -9007199254740991
end
end)())
__register("Number/toExponential", (function()
local script = __makeProxy({"Number","toExponential"})
return function()
return function(value: string | number, fractionDigits: number?): string | nil
local num = value
if typeof(value) == "string" then
local NaN = 0 / 0
num = tonumber(value) or NaN
end
if typeof(num) ~= "number" then
return "nan"
end
if fractionDigits ~= nil then
if typeof(fractionDigits) ~= "number" then
error("TypeError: fractionDigits must be a number between 0 and 100")
end
if fractionDigits < 0 or fractionDigits > 100 then
error("RangeError: fractionDigits must be between 0 and 100")
end
end
local formatString
if fractionDigits == nil then
formatString = "%e"
else
formatString = "%." .. tostring(fractionDigits) .. "e"
end
local retval = string.format(formatString, num):gsub("%+0", "+"):gsub("%-0", "-"):gsub("0*e", "e")
return retval
end
end
end)())
__register("Math/clz32", (function()
local script = __makeProxy({"Math","clz32"})
return function()
return bit32.countlz
end
end)())
__register("Math/init", (function()
local script = __makeProxy({"Math"})
return function()
return {
clz32 = __require(script.clz32),
}
end
end)())
__register("Boolean/init", (function()
local script = __makeProxy({"Boolean"})
return function()
return {
toJSBoolean = __require(script.toJSBoolean),
}
end
end)())
__register("Boolean/toJSBoolean", (function()
local script = __makeProxy({"Boolean","toJSBoolean"})
return function()
local Packages = script.Parent.Parent
local Number = __require(Packages.Number)
return function(val: any): boolean
return not not val and val ~= 0 and val ~= "" and not Number.isNaN(val)
end
end
end)())
__register("InstanceOf/init", (function()
local script = __makeProxy({"InstanceOf"})
return function()
local instanceof = __require(script.instanceof)
return instanceof
end
end)())
__register("InstanceOf/instanceof", (function()
local script = __makeProxy({"InstanceOf","instanceof"})
return function()
local __DEV__ = _G.__DEV__
local function instanceof(tbl: any, class: any): boolean
if __DEV__ then
assert(typeof(class) == "table", "Received a non-table as the second argument for instanceof")
end
if typeof(tbl) ~= "table" then
return false
end
local ok, hasNew = pcall(function()
return class.new ~= nil and tbl.new == class.new
end)
if ok and hasNew then
return true
end
local seen = { [tbl] = true }
while tbl and typeof(tbl) == "table" do
tbl = getmetatable(tbl)
if typeof(tbl) == "table" then
tbl = tbl.__index
if tbl == class then
return true
end
end
if typeof(tbl) == "table" then
if seen[tbl] then
return false
end
seen[tbl] = true
end
end
return false
end
return instanceof
end
end)())
__register("Collections/Array/concat", (function()
local script = __makeProxy({"Collections","Array","concat"})
return function()
local __DEV__ = _G.__DEV__
local Array = script.Parent
local Packages = Array.Parent.Parent
local isArray = __require(Array.isArray)
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
local RECEIVED_OBJECT_ERROR = "Array.concat(...) only works with array-like tables but "
.. "it received an object-like table.\nYou can avoid this error by wrapping the "
.. "object-like table into an array. Example: `concat({1, 2}, {a = true})` should "
.. "be `concat({1, 2}, { {a = true} }`"
local function concat<T, S>(source: Array<T> | T, ...: Array<S> | S): Array<T> & Array<S>
local array
local elementCount = 0
if isArray(source) then
array = table.clone(source :: Array<T>)
elementCount = #(source :: Array<T>)
else
elementCount += 1
array = {}
array[elementCount] = source :: T
end
for i = 1, select("#", ...) do
local value = select(i, ...)
local valueType = typeof(value)
if value == nil then
elseif valueType == "table" then
if __DEV__ then
if not isArray(value) then
error(RECEIVED_OBJECT_ERROR)
end
end
for k = 1, #value do
elementCount += 1
array[elementCount] = value[k]
end
else
elementCount += 1
array[elementCount] = value
end
end
return (array :: any) :: Array<T> & Array<S>
end
return concat
end
end)())
__register("Collections/Array/every", (function()
local script = __makeProxy({"Collections","Array","every"})
return function()
local __DEV__ = _G.__DEV__
local Array = script.Parent
local Packages = Array.Parent.Parent
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
type Object = types.Object
type callbackFn<T> = (element: T, index: number, array: Array<T>) -> boolean
type callbackFnWithThisArg<T, U> = (self: U, element: T, index: number, array: Array<T>) -> boolean
return function<T, U>(t: Array<T>, callback: callbackFn<T> | callbackFnWithThisArg<T, U>, thisArg: U?): boolean
if __DEV__ then
if typeof(t) ~= "table" then
error(string.format("Array.every called on %s", typeof(t)))
end
if typeof(callback) ~= "function" then
error("callback is not a function")
end
end
local len = #t
local k = 1
while k <= len do
local kValue = t[k]
local testResult
if kValue ~= nil then
if thisArg ~= nil then
testResult = (callback :: callbackFnWithThisArg<T, U>)(thisArg, kValue, k, t)
else
testResult = (callback :: callbackFn<T>)(kValue, k, t)
end
if not testResult then
return false
end
end
k += 1
end
return true
end
end
end)())
__register("Collections/Array/filter", (function()
local script = __makeProxy({"Collections","Array","filter"})
return function()
local __DEV__ = _G.__DEV__
local Array = script.Parent
local Packages = Array.Parent.Parent
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
type Object = types.Object
type callbackFn<T> = (element: T, index: number, array: Array<T>) -> boolean
type callbackFnWithThisArg<T, U> = (thisArg: U, element: T, index: number, array: Array<T>) -> boolean
return function<T, U>(t: Array<T>, callback: callbackFn<T> | callbackFnWithThisArg<T, U>, thisArg: U?): Array<T>
if __DEV__ then
if typeof(t) ~= "table" then
error(string.format("Array.filter called on %s", typeof(t)))
end
if typeof(callback) ~= "function" then
error("callback is not a function")
end
end
local len = #t
local res = {}
local index = 1
if thisArg == nil then
for i = 1, len do
local kValue = t[i]
if kValue ~= nil then
if (callback :: callbackFn<T>)(kValue, i, t) then
res[index] = kValue
index += 1
end
end
end
else
for i = 1, len do
local kValue = t[i]
if kValue ~= nil then
if (callback :: callbackFnWithThisArg<T, U>)(thisArg, kValue, i, t) then
res[index] = kValue
index += 1
end
end
end
end
return res
end
end
end)())
__register("Collections/Array/find", (function()
local script = __makeProxy({"Collections","Array","find"})
return function()
local Array = script.Parent
local Packages = Array.Parent.Parent
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
type PredicateFunction<T> = (value: T, index: number, array: Array<T>) -> boolean
return function<T>(array: Array<T>, predicate: PredicateFunction<T>): T | nil
for i = 1, #array do
local element = array[i]
if predicate(element, i, array) then
return element
end
end
return nil
end
end
end)())
__register("Collections/Array/findIndex", (function()
local script = __makeProxy({"Collections","Array","findIndex"})
return function()
local Array = script.Parent
local Packages = Array.Parent.Parent
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
type PredicateFunction<T> = (T, number, Array<T>) -> boolean
return function<T>(array: Array<T>, predicate: PredicateFunction<T>): number
for i = 1, #array do
local element = array[i]
if predicate(element, i, array) then
return i
end
end
return -1
end
end
end)())
__register("Collections/Array/flat", (function()
local script = __makeProxy({"Collections","Array","flat"})
return function()
local __DEV__ = _G.__DEV__
local Array = script.Parent
local Packages = Array.Parent.Parent
local isArray = __require(Array.isArray)
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
local function flat<T>(array: Array<T>, depth_: number?): Array<T>
if __DEV__ then
if typeof(array) ~= "table" then
error(string.format("Array.flat called on %s", typeof(array)))
end
if depth_ ~= nil and typeof(depth_) ~= "number" then
error("depth is not a number or nil")
end
end
local depth = depth_ or 1
local newArray = {}
for _, v in array do
if isArray(v) then
local vArray = (v :: any) :: Array<T>
local innerArrFlat: Array<T> = if depth > 1 then flat(vArray, depth - 1) else vArray
for _, innerValue in innerArrFlat do
table.insert(newArray, innerValue)
end
else
table.insert(newArray, v)
end
end
return newArray
end
return flat
end
end)())
__register("Collections/Array/flatMap", (function()
local script = __makeProxy({"Collections","Array","flatMap"})
return function()
local __DEV__ = _G.__DEV__
local Array = script.Parent
local Packages = Array.Parent.Parent
local flat = __require(Array.flat)
local map = __require(Array.map)
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
type callbackFn<T, U> = (element: T, index: number, array: Array<T>) -> U
type callbackFnWithThisArg<T, U, V> = (thisArg: V, element: T, index: number, array: Array<T>) -> U
local function flatMap<T, U, V>(
array: Array<T>,
callback: callbackFn<T, U> | callbackFnWithThisArg<T, U, V>,
thisArg: V?
): Array<U>
if __DEV__ then
if typeof(array) ~= "table" then
error(string.format("Array.flatMap called on %s", typeof(array)))
end
if typeof(callback) ~= "function" then
error("callback is not a function")
end
end
return flat(map(array, callback, thisArg))
end
return flatMap
end
end)())
__register("Collections/Array/forEach", (function()
local script = __makeProxy({"Collections","Array","forEach"})
return function()
local __DEV__ = _G.__DEV__
local Array = script.Parent
local Packages = Array.Parent.Parent
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
type Object = types.Object
type callbackFn<T> = (element: T, index: number, array: Array<T>) -> ()
type callbackFnWithThisArg<T, U> = (thisArg: U, element: T, index: number, array: Array<T>) -> ()
return function<T, U>(t: Array<T>, callback: callbackFn<T> | callbackFnWithThisArg<T, U>, thisArg: U?): ()
if __DEV__ then
if typeof(t) ~= "table" then
error(string.format("Array.forEach called on %s", typeof(t)))
end
if typeof(callback) ~= "function" then
error("callback is not a function")
end
end
local len = #t
local k = 1
while k <= len do
local kValue = t[k]
if thisArg ~= nil then
(callback :: callbackFnWithThisArg<T, U>)(thisArg, kValue, k, t)
else
(callback :: callbackFn<T>)(kValue, k, t)
end
if #t < len then
len = #t
end
k += 1
end
end
end
end)())
__register("Collections/Array/from/fromArray", (function()
local script = __makeProxy({"Collections","Array","from","fromArray"})
return function()
local Array = script.Parent.Parent
local Packages = Array.Parent.Parent
local types = __require(Packages.ES7Types)
type Object = types.Object
type Array<T> = types.Array<T>
type mapFn<T, U> = (element: T, index: number) -> U
type mapFnWithThisArg<T, U> = (thisArg: any, element: T, index: number) -> U
return function<T, U>(
value: Array<T>,
mapFn: (mapFn<T, U> | mapFnWithThisArg<T, U>)?,
thisArg: Object?
): Array<U> | Array<T> | Array<string>
local array = {}
if mapFn then
local arrayLength = #(value :: Array<T>)
array = table.create(arrayLength)
for i = 1, arrayLength do
if thisArg ~= nil then
(array :: Array<U>)[i] = (mapFn :: mapFnWithThisArg<T, U>)(thisArg, (value :: Array<T>)[i], i)
else
(array :: Array<U>)[i] = (mapFn :: mapFn<T, U>)((value :: Array<T>)[i], i)
end
end
else
array = table.clone(value :: Array<T>)
end
return array
end
end
end)())
__register("Collections/Array/from/fromMap", (function()
local script = __makeProxy({"Collections","Array","from","fromMap"})
return function()
local Array = script.Parent.Parent
local Packages = Array.Parent.Parent
local types = __require(Packages.ES7Types)
type Object = types.Object
type Array<T> = types.Array<T>
type Map<K, V> = types.Map<K, V>
type mapFn<T, U> = (element: T, index: number) -> U
type mapFnWithThisArg<T, U> = (thisArg: any, element: T, index: number) -> U
return function<T, U>(
value: Map<any, any>,
mapFn: (mapFn<T, U> | mapFnWithThisArg<T, U>)?,
thisArg: Object?
): Array<U> | Array<T> | Array<string>
local array = {}
if mapFn then
array = {}
for i, v in value :: any do
if thisArg ~= nil then
(array :: Array<U>)[i] = (mapFn :: mapFnWithThisArg<T, U>)(thisArg, v, i)
else
(array :: Array<U>)[i] = (mapFn :: mapFn<T, U>)(v, i)
end
end
else
array = {}
for i, v in value :: any do
(array :: Array<T>)[i] = v
end
end
return array
end
end
end)())
__register("Collections/Array/from/fromSet", (function()
local script = __makeProxy({"Collections","Array","from","fromSet"})
return function()
local Array = script.Parent.Parent
local Packages = Array.Parent.Parent
local types = __require(Packages.ES7Types)
type Object = types.Object
type Array<T> = types.Array<T>
type Set<T> = types.Set<T>
type mapFn<T, U> = (element: T, index: number) -> U
type mapFnWithThisArg<T, U> = (thisArg: any, element: T, index: number) -> U
return function<T, U>(
value: Set<T>,
mapFn: (mapFn<T, U> | mapFnWithThisArg<T, U>)?,
thisArg: Object?
): Array<U> | Array<T> | Array<string>
local array = {}
if mapFn then
array = {}
for i, v in value :: any do
if thisArg ~= nil then
(array :: Array<U>)[i] = (mapFn :: mapFnWithThisArg<T, U>)(thisArg, v, i)
else
(array :: Array<U>)[i] = (mapFn :: mapFn<T, U>)(v, i)
end
end
else
array = table.clone((value :: any)._array)
end
return array
end
end
end)())
__register("Collections/Array/from/fromString", (function()
local script = __makeProxy({"Collections","Array","from","fromString"})
return function()
local Array = script.Parent.Parent
local Packages = Array.Parent.Parent
local types = __require(Packages.ES7Types)
type Object = types.Object
type Array<T> = types.Array<T>
type mapFn<T, U> = (element: T, index: number) -> U
type mapFnWithThisArg<T, U> = (thisArg: any, element: T, index: number) -> U
return function<T, U>(
value: string,
mapFn: (mapFn<T, U> | mapFnWithThisArg<T, U>)?,
thisArg: Object?
): Array<U> | Array<T> | Array<string>
local array = {}
local valueStringLength = #value
array = table.create(valueStringLength)
if mapFn then
for i = 1, valueStringLength do
if thisArg ~= nil then
(array :: Array<U>)[i] = (mapFn :: mapFnWithThisArg<T, U>)(thisArg, string.sub(value, i, i) :: any, i)
else
(array :: Array<U>)[i] = (mapFn :: mapFn<T, U>)(string.sub(value, i, i) :: any, i)
end
end
else
for i = 1, valueStringLength do
(array :: Array<string>)[i] = string.sub(value, i, i)
end
end
return array
end
end
end)())
__register("Collections/Array/from/init", (function()
local script = __makeProxy({"Collections","Array","from"})
return function()
local Array = script.Parent
local Collections = Array.Parent
local Packages = Collections.Parent
local Set = __require(Collections.Set)
local Map = __require(Collections.Map.Map)
local isArray = __require(Array.isArray)
local instanceof = __require(Packages.InstanceOf)
local types = __require(Packages.ES7Types)
local fromString = __require(script.fromString)
local fromSet = __require(script.fromSet)
local fromMap = __require(script.fromMap)
local fromArray = __require(script.fromArray)
type Array<T> = types.Array<T>
type Object = types.Object
type Set<T> = types.Set<T>
type Map<K, V> = types.Map<K, V>
type mapFn<T, U> = (element: T, index: number) -> U
type mapFnWithThisArg<T, U> = (thisArg: any, element: T, index: number) -> U
return function<T, U>(
value: string | Array<T> | Set<T> | Map<any, any>,
mapFn: (mapFn<T, U> | mapFnWithThisArg<T, U>)?,
thisArg: Object?
): Array<U> | Array<T> | Array<string>
if value == nil then
error("cannot create array from a nil value")
end
local valueType = typeof(value)
local array: Array<U> | Array<T> | Array<string>
if valueType == "table" and isArray(value) then
array = fromArray(value :: Array<T>, mapFn, thisArg)
elseif instanceof(value, Set) then
array = fromSet(value :: Set<T>, mapFn, thisArg)
elseif instanceof(value, Map) then
array = fromMap(value :: Map<any, any>, mapFn, thisArg)
elseif valueType == "string" then
array = fromString(value :: string, mapFn, thisArg)
else
array = {}
end
return array
end
end
end)())
__register("Collections/Array/includes", (function()
local script = __makeProxy({"Collections","Array","includes"})
return function()
local Array = script.Parent
local Packages = Array.Parent.Parent
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
local indexOf = __require(script.Parent.indexOf)
return function<T>(array: Array<T>, searchElement: T, fromIndex: number?): boolean
return indexOf(array, searchElement, fromIndex) ~= -1
end
end
end)())
__register("Collections/Array/indexOf", (function()
local script = __makeProxy({"Collections","Array","indexOf"})
return function()
local Array = script.Parent
local Packages = Array.Parent.Parent
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
return function<T>(array: Array<T>, searchElement: T, fromIndex: number?): number
local fromIndex_ = fromIndex or 1
local length = #array
if fromIndex_ < 1 then
fromIndex_ = math.max(length - math.abs(fromIndex_), 1)
end
for i = fromIndex_, length do
if array[i] == searchElement then
return i
end
end
return -1
end
end
end)())
__register("Collections/Array/init", (function()
local script = __makeProxy({"Collections","Array"})
return function()
local Packages = script.Parent.Parent
local ES7Types = __require(Packages.ES7Types)
type Array<T> = ES7Types.Array<T>
return {
concat = __require(script.concat),
every = __require(script.every),
filter = __require(script.filter),
find = __require(script.find),
findIndex = __require(script.findIndex),
flat = __require(script.flat),
flatMap = __require(script.flatMap),
forEach = __require(script.forEach),
from = __require(script.from),
includes = __require(script.includes),
indexOf = __require(script.indexOf),
isArray = __require(script.isArray),
join = __require(script.join),
map = __require(script.map),
reduce = __require(script.reduce),
reverse = __require(script.reverse),
shift = __require(script.shift),
slice = __require(script.slice),
some = __require(script.some),
sort = __require(script.sort),
splice = __require(script.splice),
unshift = __require(script.unshift),
}
end
end)())
__register("Collections/Array/isArray", (function()
local script = __makeProxy({"Collections","Array","isArray"})
return function()
return function(value: any): boolean
if typeof(value) ~= "table" then
return false
end
if next(value) == nil then
return true
end
local length = #value
if length == 0 then
return false
end
local count = 0
local sum = 0
for key in pairs(value) do
if typeof(key) ~= "number" then
return false
end
if key % 1 ~= 0 or key < 1 then
return false
end
count += 1
sum += key
end
return sum == (count * (count + 1) / 2)
end
end
end)())
__register("Collections/Array/join", (function()
local script = __makeProxy({"Collections","Array","join"})
return function()
local Array = script.Parent
local Packages = Array.Parent.Parent
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
local map = __require(Array.map)
return function<T>(arr: Array<T>, separator: string?): string
if #arr == 0 then
return ""
end
local stringifiedArray = map(arr, function(item)
return tostring(item)
end)
return table.concat(stringifiedArray, separator or ",")
end
end
end)())
__register("Collections/Array/map", (function()
local script = __makeProxy({"Collections","Array","map"})
return function()
local __DEV__ = _G.__DEV__
local Array = script.Parent
local Packages = Array.Parent.Parent
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
type Object = types.Object
type callbackFn<T, U> = (element: T, index: number, array: Array<T>) -> U
type callbackFnWithThisArg<T, U, V> = (thisArg: V, element: T, index: number, array: Array<T>) -> U
return function<T, U, V>(t: Array<T>, callback: callbackFn<T, U> | callbackFnWithThisArg<T, U, V>, thisArg: V?): Array<U>
if __DEV__ then
if typeof(t) ~= "table" then
error(string.format("Array.map called on %s", typeof(t)))
end
if typeof(callback) ~= "function" then
error("callback is not a function")
end
end
local len = #t
local A = {}
local k = 1
while k <= len do
local kValue = t[k]
if kValue ~= nil then
local mappedValue
if thisArg ~= nil then
mappedValue = (callback :: callbackFnWithThisArg<T, U, V>)(thisArg, kValue, k, t)
else
mappedValue = (callback :: callbackFn<T, U>)(kValue, k, t)
end
A[k] = mappedValue
end
k += 1
end
return A
end
end
end)())
__register("Collections/Array/reduce", (function()
local script = __makeProxy({"Collections","Array","reduce"})
return function()
local __DEV__ = _G.__DEV__
local Array = script.Parent
local Packages = Array.Parent.Parent
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
type reduceFn<T, U> = (previousValue: U, currentValue: T, currentIndex: number, array: Array<T>) -> U
return function<T, U>(array: Array<T>, callback: reduceFn<T, U>, initialValue: U?): U
if __DEV__ then
if typeof(array) ~= "table" then
error(string.format("Array.reduce called on %s", typeof(array)))
end
if typeof(callback) ~= "function" then
error("callback is not a function")
end
end
local length = #array
local value: T | U
local initial = 1
if initialValue ~= nil then
value = initialValue
else
initial = 2
if length == 0 then
error("reduce of empty array with no initial value")
end
value = array[1]
end
for i = initial, length do
value = callback(value :: U, array[i], i, array)
end
return value :: U
end
end
end)())
__register("Collections/Array/reverse", (function()
local script = __makeProxy({"Collections","Array","reverse"})
return function()
local Array = script.Parent
local Packages = Array.Parent.Parent
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
return function<T>(t: Array<T>): Array<T>
local n = #t
local i = 1
while i < n do
t[i], t[n] = t[n], t[i]
i = i + 1
n = n - 1
end
return t
end
end
end)())
__register("Collections/Array/shift", (function()
local script = __makeProxy({"Collections","Array","shift"})
return function()
local __DEV__ = _G.__DEV__
local Array = script.Parent
local Packages = Array.Parent.Parent
local isArray = __require(Array.isArray)
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
return function<T>(value: Array<T>): T?
if __DEV__ then
if not isArray(value) then
error(string.format("Array.shift called on non-array %s", typeof(value)))
end
end
if #value > 0 then
return table.remove(value, 1)
else
return nil
end
end
end
end)())
__register("Collections/Array/slice", (function()
local script = __makeProxy({"Collections","Array","slice"})
return function()
local Array = script.Parent
local Packages = Array.Parent.Parent
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
return function<T>(t: Array<T>, start_idx: number?, end_idx: number?): Array<T>
if typeof(t) ~= "table" then
error(string.format("Array.slice called on %s", typeof(t)))
end
local length = #t
local start_idx_ = start_idx or 1
local end_idx_
if end_idx == nil or end_idx > length + 1 then
end_idx_ = length + 1
else
end_idx_ = end_idx
end
if start_idx_ > length + 1 then
return {}
end
local slice = {}
if start_idx_ < 1 then
start_idx_ = math.max(length - math.abs(start_idx_), 1)
end
if end_idx_ < 1 then
end_idx_ = math.max(length - math.abs(end_idx_), 1)
end
local idx = start_idx_
local i = 1
while idx < end_idx_ do
slice[i] = t[idx]
idx = idx + 1
i = i + 1
end
return slice
end
end
end)())
__register("Collections/Array/some", (function()
local script = __makeProxy({"Collections","Array","some"})
return function()
local Array = script.Parent
local Packages = Array.Parent.Parent
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
type Object = types.Object
type callbackFn<T> = (element: T, index: number, array: Array<T>) -> boolean
type callbackFnWithThisArg<T, U> = (thisArg: U, element: T, index: number, array: Array<T>) -> boolean
return function<T, U>(t: Array<T>, callback: callbackFn<T> | callbackFnWithThisArg<T, U>, thisArg: U?): boolean
if typeof(t) ~= "table" then
error(string.format("Array.some called on %s", typeof(t)))
end
if typeof(callback) ~= "function" then
error("callback is not a function")
end
for i, value in t do
if thisArg ~= nil then
if value ~= nil and (callback :: callbackFnWithThisArg<T, U>)(thisArg, value, i, t) then
return true
end
else
if value ~= nil and (callback :: callbackFn<T>)(value, i, t) then
return true
end
end
end
return false
end
end
end)())
__register("Collections/Array/sort", (function()
local script = __makeProxy({"Collections","Array","sort"})
return function()
local Array = script.Parent
local Collections = Array.Parent
local Packages = Collections.Parent
local None = __require(Collections.Object.None)
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
type Comparable = (any, any) -> number
local defaultSort = function<T>(a: T, b: T): boolean
return type(a) .. tostring(a) < type(b) .. tostring(b)
end
return function<T>(array: Array<T>, compare: Comparable?): Array<T>
local wrappedCompare = defaultSort
if compare ~= nil and compare ~= None then
if typeof(compare :: any) ~= "function" then
error("invalid argument to Array.sort: compareFunction must be a function")
end
wrappedCompare = function<T>(a: T, b: T)
local result = compare(a, b)
if typeof(result) ~= "number" then
error(("invalid result from compare function, expected number but got %s"):format(typeof(result)))
end
return result < 0
end
end
table.sort(array, wrappedCompare)
return array
end
end
end)())
__register("Collections/Array/splice", (function()
local script = __makeProxy({"Collections","Array","splice"})
return function()
local Array = script.Parent
local Packages = Array.Parent.Parent
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
return function<T>(array: Array<T>, start: number, deleteCount: number?, ...: T): Array<T>
if start > #array then
local varargCount = select("#", ...)
for i = 1, varargCount do
local toInsert = select(i, ...)
table.insert(array, toInsert)
end
return {}
else
local length = #array
if start < 1 then
start = math.max(length - math.abs(start), 1)
end
local deletedItems = {} :: Array<T>
local deleteCount_: number = deleteCount or length
if deleteCount_ > 0 then
local lastIndex = math.min(length, start + math.max(0, deleteCount_ - 1))
for i = start, lastIndex do
local deleted = table.remove(array, start) :: T
table.insert(deletedItems, deleted)
end
end
local varargCount = select("#", ...)
for i = varargCount, 1, -1 do
local toInsert = select(i, ...)
table.insert(array, start, toInsert)
end
return deletedItems
end
end
end
end)())
__register("Collections/Array/unshift", (function()
local script = __makeProxy({"Collections","Array","unshift"})
return function()
local __DEV__ = _G.__DEV__
local Array = script.Parent
local Packages = Array.Parent.Parent
local isArray = __require(Array.isArray)
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
return function<T>(array: Array<T>, ...: T): number
if __DEV__ then
if not isArray(array) then
error(string.format("Array.unshift called on non-array %s", typeof(array)))
end
end
local numberOfItems = select("#", ...)
if numberOfItems > 0 then
for i = numberOfItems, 1, -1 do
local toInsert = select(i, ...)
table.insert(array, 1, toInsert)
end
end
return #array
end
end
end)())
__register("Collections/init", (function()
local script = __makeProxy({"Collections"})
return function()
local Packages = script.Parent
local Array = __require(script.Array)
local Map = __require(script.Map)
local Object = __require(script.Object)
local Set = __require(script.Set)
local WeakMap = __require(script.WeakMap)
local inspect = __require(script.inspect)
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
type Map<T, V> = types.Map<T, V>
type Object = types.Object
type Set<T> = types.Set<T>
type WeakMap<T, V> = types.WeakMap<T, V>
return {
Array = Array,
Object = Object,
Map = Map.Map,
coerceToMap = Map.coerceToMap,
coerceToTable = Map.coerceToTable,
Set = Set,
WeakMap = WeakMap,
inspect = inspect,
}
end
end)())
__register("Collections/inspect", (function()
local script = __makeProxy({"Collections","inspect"})
return function()
local HttpService = game:GetService("HttpService")
local Collections = script.Parent
local Packages = Collections.Parent
local isArray = __require(Collections.Array.isArray)
local ES7Types = __require(Packages.ES7Types)
type Array<T> = ES7Types.Array<T>
type InspectOptions = {
depth: number?,
}
type FormatOptions = {
depth: number,
}
local MAX_ARRAY_LENGTH = 10
local DEFAULT_RECURSIVE_DEPTH = 2
local formatValue
local formatObjectValue
local formatArray
local formatObject
local getObjectTag
local function inspect(value, options: InspectOptions?): string
local inspectOptions: InspectOptions = options or { depth = DEFAULT_RECURSIVE_DEPTH }
local depth = inspectOptions.depth or DEFAULT_RECURSIVE_DEPTH
inspectOptions.depth = if depth >= 0 then depth else DEFAULT_RECURSIVE_DEPTH
return formatValue(value, {}, inspectOptions :: FormatOptions)
end
local function isIndexKey(k, contiguousLength)
return type(k) == "number"
and k <= contiguousLength
and 1 <= k
and math.floor(k) == k
end
local function getTableLength(tbl)
local length = 1
local value = rawget(tbl, length)
while value ~= nil do
length += 1
value = rawget(tbl, length)
end
return length - 1
end
local function sortKeysForPrinting(a: any, b)
local typeofA = type(a)
local typeofB = type(b)
if typeofA == typeofB and (typeofA == "number" or typeofA == "string") then
return a < b
end
return typeofA < typeofB
end
local function rawpairs(t)
return next, t, nil
end
local function getFragmentedKeys(tbl)
local keys = {}
local keysLength = 0
local tableLength = getTableLength(tbl)
for key, _ in rawpairs(tbl) do
if not isIndexKey(key, tableLength) then
keysLength = keysLength + 1
keys[keysLength] = key
end
end
table.sort(keys, sortKeysForPrinting)
return keys, keysLength, tableLength
end
function formatValue(value, seenValues, options: FormatOptions)
local valueType = typeof(value)
if valueType == "string" then
return HttpService:JSONEncode(value)
elseif valueType == "number" then
if value ~= value then
return "NaN"
elseif value == math.huge then
return "Infinity"
elseif value == -math.huge then
return "-Infinity"
else
return tostring(value)
end
elseif valueType == "function" then
local result = "[function"
local functionName = debug.info(value :: (any) -> any, "n")
if functionName ~= nil and functionName ~= "" then
result ..= " " .. functionName
end
return result .. "]"
elseif valueType == "table" then
return formatObjectValue(value, seenValues, options)
else
return tostring(value)
end
end
function formatObjectValue(value, previouslySeenValues, options: FormatOptions)
if table.find(previouslySeenValues, value) ~= nil then
return "[Circular]"
end
local seenValues = { unpack(previouslySeenValues) }
table.insert(seenValues, value)
if typeof(value.toJSON) == "function" then
local jsonValue = value:toJSON(value)
if jsonValue ~= value then
if typeof(jsonValue) == "string" then
return jsonValue
else
return formatValue(jsonValue, seenValues, options)
end
end
elseif isArray(value) then
return formatArray(value, seenValues, options)
end
return formatObject(value, seenValues, options)
end
function formatObject(object, seenValues, options: FormatOptions)
local result = ""
local mt = getmetatable(object)
if mt and rawget(mt, "__tostring") then
return tostring(object)
end
local fragmentedKeys, fragmentedKeysLength, keysLength = getFragmentedKeys(object)
if keysLength == 0 and fragmentedKeysLength == 0 then
result ..= "{}"
return result
end
if #seenValues > options.depth then
result ..= "[" .. getObjectTag(object) .. "]"
return result
end
local properties = {}
for i = 1, keysLength do
local value = formatValue(object[i], seenValues, options)
table.insert(properties, value)
end
for i = 1, fragmentedKeysLength do
local key = fragmentedKeys[i]
local value = formatValue(object[key], seenValues, options)
table.insert(properties, key .. ": " .. value)
end
result ..= "{ " .. table.concat(properties, ", ") .. " }"
return result
end
function formatArray(array: Array<any>, seenValues: Array<any>, options: FormatOptions): string
local length = #array
if length == 0 then
return "[]"
end
if #seenValues > options.depth then
return "[Array]"
end
local len = math.min(MAX_ARRAY_LENGTH, length)
local remaining = length - len
local items = {}
for i = 1, len do
items[i] = (formatValue(array[i], seenValues, options))
end
if remaining == 1 then
table.insert(items, "... 1 more item")
elseif remaining > 1 then
table.insert(items, ("... %s more items"):format(tostring(remaining)))
end
return "[" .. table.concat(items, ", ") .. "]"
end
function getObjectTag(_object): string
return "Object"
end
return inspect
end
end)())
__register("Collections/Map/coerceToMap", (function()
local script = __makeProxy({"Collections","Map","coerceToMap"})
return function()
local MapModule = script.Parent
local Collections = MapModule.Parent
local Packages = Collections.Parent
local Map = __require(MapModule.Map)
local Object = __require(Collections.Object)
local instanceOf = __require(Packages.InstanceOf)
local types = __require(Packages.ES7Types)
type Map<K, V> = types.Map<K, V>
type Table<K, V> = types.Table<K, V>
local function coerceToMap(mapLike: Map<any, any> | Table<any, any>): Map<any, any>
return instanceOf(mapLike, Map) and mapLike :: Map<any, any>
or Map.new(Object.entries(mapLike))
end
return coerceToMap
end
end)())
__register("Collections/Map/coerceToTable", (function()
local script = __makeProxy({"Collections","Map","coerceToTable"})
return function()
local MapModule = script.Parent
local Collections = MapModule.Parent
local Packages = Collections.Parent
local Map = __require(MapModule.Map)
local instanceOf = __require(Packages.InstanceOf)
local arrayReduce = __require(Collections.Array.reduce)
local types = __require(Packages.ES7Types)
type Map<K, V> = types.Map<K, V>
type Table<K, V> = types.Table<K, V>
local function coerceToTable(mapLike: Map<any, any> | Table<any, any>): Table<any, any>
if not instanceOf(mapLike, Map) then
return mapLike :: Table<any, any>
end
return arrayReduce(mapLike:entries(), function(tbl, entry)
tbl[entry[1]] = entry[2]
return tbl
end, {})
end
return coerceToTable
end
end)())
__register("Collections/Map/init", (function()
local script = __makeProxy({"Collections","Map"})
return function()
local Packages = script.Parent.Parent
local ES7Types = __require(Packages.ES7Types)
local Map = __require(script.Map)
local coerceToMap = __require(script.coerceToMap)
local coerceToTable = __require(script.coerceToTable)
type Map<K, V> = ES7Types.Map<K, V>
return {
Map = Map,
coerceToMap = coerceToMap,
coerceToTable = coerceToTable,
}
end
end)())
__register("Collections/Map/Map", (function()
local script = __makeProxy({"Collections","Map","Map"})
return function()
local __DEV__ = _G.__DEV__
local Collections = script.Parent.Parent
local Packages = Collections.Parent
local arrayForEach = __require(Collections.Array.forEach)
local arrayMap = __require(Collections.Array.map)
local isArray = __require(Collections.Array.isArray)
local instanceof = __require(Packages.InstanceOf)
local types = __require(Packages.ES7Types)
type Object = types.Object
type Array<T> = types.Array<T>
type Table<T, V> = types.Table<T, V>
type Tuple<T, V> = types.Tuple<T, V>
type mapCallbackFn<K, V> = types.mapCallbackFn<K, V>
type mapCallbackFnWithThisArg<K, V> = types.mapCallbackFnWithThisArg<K, V>
type Map<K, V> = types.Map<K, V>
type Map_Statics = {
new: <K, V>(iterable: Array<Array<any>>?) -> Map<K, V>,
}
local Map: Map<any, any> & Map_Statics = ({} :: any) :: Map<any, any> & Map_Statics
function Map.new<K, V>(iterable: (Array<Array<any>> | Map<K, V>)?): Map<K, V>
local array
local map
if iterable == nil then
array = {}
map = {}
elseif isArray(iterable) then
if __DEV__ then
if #(iterable :: Array<Array<any>>) > 0 and typeof((iterable :: Array<Array<any>>)[1]) ~= "table" then
error(
"Value `"
.. typeof((iterable :: Array<Array<any>>)[1])
.. "` is not an entry object.\n "
.. "Cannot create Map from {K, V} form, it must be { {K, V}... }"
)
end
end
array = table.create(#(iterable :: Array<Array<any>>))
map = {}
for _, entry in iterable :: Array<Array<any>> do
local key = entry[1]
if __DEV__ then
if key == nil then
error("cannot create Map from a table that isn't an array.")
end
end
local val = entry[2]
if map[key] == nil then
table.insert(array, key)
end
map[key] = val
end
elseif instanceof(iterable, Map) then
array = table.clone((iterable :: Map<K, V>)._array)
map = table.clone((iterable :: Map<K, V>)._map)
else
error(("`%s` `%s` is not iterable, cannot make Map using it"):format(typeof(iterable), tostring(iterable)))
end
return (setmetatable({
size = #array,
_map = map,
_array = array,
}, Map) :: any) :: Map<K, V>
end
function Map:set(key: any, value: any): Map<any, any>
if self._map[key] == nil then
self.size = self.size :: number + 1
table.insert(self._array, key)
end
self._map[key] = value
return self
end
function Map:get(key)
return self._map[key]
end
function Map:clear()
local table_: any = table
self.size = 0
table_.clear(self._map)
table_.clear(self._array)
end
function Map:delete(key): boolean
if self._map[key] == nil then
return false
end
self.size = self.size :: number - 1
self._map[key] = nil
local index = table.find(self._array, key)
if index then
table.remove(self._array, index)
end
return true
end
function Map:forEach(callback: mapCallbackFn<any, any> | mapCallbackFnWithThisArg<any, any>, thisArg: Object?): ()
if __DEV__ then
if typeof(callback) ~= "function" then
error("callback is not a function")
end
end
arrayForEach(self._array, function(key)
local value = self._map[key]
if thisArg ~= nil then
(callback :: mapCallbackFnWithThisArg<any, any>)(thisArg, value, key, self)
else
(callback :: mapCallbackFn<any, any>)(value, key, self)
end
end)
end
function Map:has(key): boolean
return self._map[key] ~= nil
end
function Map:keys()
return self._array
end
function Map:values()
return arrayMap(self._array, function(key)
return self._map[key]
end)
end
function Map:entries()
return arrayMap(self._array, function(key)
return { key, self._map[key] }
end)
end
function Map:ipairs()
if __DEV__ then
warn(
debug.traceback(
"`for _,_ in myMap:ipairs() do` is deprecated and will be removed in a future release, please use `for _,_ in myMap do` instead\n",
2
)
)
end
return ipairs(self:entries())
end
function Map.__iter(self: Map<any, any>)
return next, self:entries()
end
function Map.__index(self: Map<any, any>, key)
local mapProp = rawget(Map, key)
if mapProp ~= nil then
return mapProp
end
if __DEV__ then
assert(
rawget(self :: any, "_map"),
"Map has been corrupted, and is missing private state! Did you accidentally call table.clear() instead of map:clear()?"
)
end
return Map.get(self, key)
end
function Map.__newindex(self: Map<any, any>, key, value)
self:set(key, value)
end
return Map
end
end)())
__register("Collections/Object/assign", (function()
local script = __makeProxy({"Collections","Object","assign"})
return function()
local Object = script.Parent
local Packages = Object.Parent.Parent
local None = __require(Object.None)
local types = __require(Packages.ES7Types)
type Object = types.Object
return function<T, U, V, W>(target: T, source0: U?, source1: V?, source2: W?, ...): T & U & V & W
if source0 ~= nil and typeof(source0 :: any) == "table" then
for key, value in pairs(source0 :: any) do
if value == None then
(target :: any)[key] = nil
else
(target :: any)[key] = value
end
end
end
if source1 ~= nil and typeof(source1 :: any) == "table" then
for key, value in pairs(source1 :: any) do
if value == None then
(target :: any)[key] = nil
else
(target :: any)[key] = value
end
end
end
if source2 ~= nil and typeof(source2 :: any) == "table" then
for key, value in pairs(source2 :: any) do
if value == None then
(target :: any)[key] = nil
else
(target :: any)[key] = value
end
end
end
for index = 1, select("#", ...) do
local rest = select(index, ...)
if rest ~= nil and typeof(rest) == "table" then
for key, value in pairs(rest) do
if value == None then
(target :: any)[key] = nil
else
(target :: any)[key] = value
end
end
end
end
return (target :: any) :: T & U & V & W
end
end
end)())
__register("Collections/Object/entries", (function()
local script = __makeProxy({"Collections","Object","entries"})
return function()
local Object = script.Parent
local Packages = Object.Parent.Parent
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
type Map<K, V> = types.Map<K, V>
type Tuple<T, V> = types.Tuple<T, V>
return function<T>(value: string | { [string]: T } | Array<T> | Map<any, T>): Array<Tuple<string, T>>
assert(value :: any ~= nil, "cannot get entries from a nil value")
local valueType = typeof(value)
local entries: Array<Tuple<string, T>> = {}
if valueType == "table" then
for key, keyValue in pairs(value :: { [string]: T } | Array<T>) do
table.insert(entries, { key, keyValue })
end
elseif valueType == "string" then
for i = 1, string.len(value :: string) do
entries[i] = { tostring(i), string.sub(value :: string, i, i) }
end
end
return entries
end
end
end)())
__register("Collections/Object/freeze", (function()
local script = __makeProxy({"Collections","Object","freeze"})
return function()
local Object = script.Parent
local Packages = Object.Parent.Parent
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
type Object = types.Object
return function<T>(t: T & (Object | Array<any>)): T
return (table.freeze(t :: any) :: any) :: T
end
end
end)())
__register("Collections/Object/init", (function()
local script = __makeProxy({"Collections","Object"})
return function()
return {
assign = __require(script.assign),
entries = __require(script.entries),
freeze = __require(script.freeze),
is = __require(script.is),
isFrozen = __require(script.isFrozen),
keys = __require(script.keys),
preventExtensions = __require(script.preventExtensions),
seal = __require(script.seal),
values = __require(script.values),
None = __require(script.None),
}
end
end)())
__register("Collections/Object/is", (function()
local script = __makeProxy({"Collections","Object","is"})
return function()
return function(value1: any, value2: any): boolean
if value1 == value2 then
return value1 ~= 0 or 1 / value1 == 1 / value2
else
return value1 ~= value1 and value2 ~= value2
end
end
end
end)())
__register("Collections/Object/isFrozen", (function()
local script = __makeProxy({"Collections","Object","isFrozen"})
return function()
local __DEV__ = _G.__DEV__
local Object = script.Parent
local Packages = Object.Parent.Parent
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
type Object = types.Object
return function(t: Object | Array<any>): boolean
if __DEV__ then
print("Luau now has a direct table.isfrozen call that can save the overhead of this library function call")
end
return table.isfrozen(t)
end
end
end)())
__register("Collections/Object/keys", (function()
local script = __makeProxy({"Collections","Object","keys"})
return function()
local Object = script.Parent
local Collections = Object.Parent
local Packages = Object.Parent.Parent
local Set = __require(Collections.Set)
local types = __require(Packages.ES7Types)
local instanceOf = __require(Packages.InstanceOf)
type Array<T> = types.Array<T>
type Set<T> = types.Set<T>
type Table = { [any]: any }
return function(value: Set<any> | Table | string): Array<string>
if value == nil then
error("cannot extract keys from a nil value")
end
local valueType = typeof(value)
local keys
if valueType == "table" then
keys = {}
if instanceOf(value, Set) then
return keys
end
for key in pairs(value :: Table) do
table.insert(keys, key)
end
elseif valueType == "string" then
local length = (value :: string):len()
keys = table.create(length)
for i = 1, length do
keys[i] = tostring(i)
end
end
return keys
end
end
end)())
__register("Collections/Object/None", (function()
local script = __makeProxy({"Collections","Object","None"})
return function()
local None = newproxy(true)
local mt = getmetatable(None)
mt.__tostring = function()
return "Object.None"
end
return None
end
end)())
__register("Collections/Object/preventExtensions", (function()
local script = __makeProxy({"Collections","Object","preventExtensions"})
return function()
local Object = script.Parent
local Packages = Object.Parent.Parent
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
type Object = types.Object
local function preventExtensions<T>(t: T & (Object | Array<any>)): T
local name = tostring(t)
return (
setmetatable(t :: any, {
__newindex = function(self, key, value)
local message = ("%q (%s) is not a valid member of %s"):format(tostring(key), typeof(key), name)
error(message, 2)
end,
__metatable = false,
}) :: any
) :: T
end
return preventExtensions
end
end)())
__register("Collections/Object/seal", (function()
local script = __makeProxy({"Collections","Object","seal"})
return function()
local Object = script.Parent
local Packages = Object.Parent.Parent
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
type Object = types.Object
return function<T>(t: T & (Object | Array<any>)): T
return (table.freeze(t :: any) :: any) :: T
end
end
end)())
__register("Collections/Object/values", (function()
local script = __makeProxy({"Collections","Object","values"})
return function()
local Object = script.Parent
local Packages = Object.Parent.Parent
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
return function<T>(value: { [string]: T } | Array<T> | string): Array<T> | Array<string>
if value == nil then
error("cannot extract values from a nil value")
end
local valueType = typeof(value)
local array: Array<T> | Array<string>
if valueType == "table" then
array = {} :: Array<T>
for _, keyValue in pairs(value :: { [string]: T } | Array<T>) do
table.insert(array, keyValue)
end
elseif valueType == "string" then
local valueStringLength = (value :: string):len()
array = table.create(valueStringLength)
for i = 1, valueStringLength do
(array :: Array<string>)[i] = (value :: string):sub(i, i)
end
end
return array
end
end
end)())
__register("Collections/Set/init", (function()
local script = __makeProxy({"Collections","Set"})
return function()
local __DEV__ = _G.__DEV__
local Collections = script.Parent
local Packages = Collections.Parent
local inspect = __require(Collections.inspect)
local isArray = __require(Collections.Array.isArray)
local arrayForEach = __require(Collections.Array.forEach)
local arrayFromString = __require(Collections.Array.from.fromString)
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
type Object = types.Object
type setCallbackFn<T> = types.setCallbackFn<T>
type setCallbackFnWithThisArg<T> = types.setCallbackFnWithThisArg<T>
type Set<T> = types.Set<T>
type Set_Statics = {
new: <T>(iterable: Array<T> | Set<T> | string | nil) -> Set<T>,
}
local Set: Set<any> & Set_Statics = (
{
__iter = function(self)
return next, self._array
end,
__tostring = function(self)
local result = "Set "
if #self._array > 0 then
result ..= "(" .. tostring(#self._array) .. ") "
end
result ..= inspect(self._array)
return result
end,
} :: any
) :: Set<any> & Set_Statics;
(Set :: any).__index = Set
function Set.new<T>(iterable: Array<T> | Set<T> | string | nil): Set<T>
local array
local map = {}
if iterable ~= nil then
local arrayIterable
if typeof(iterable) == "table" then
if isArray(iterable) then
arrayIterable = table.clone(iterable)
else
local mt = getmetatable(iterable :: any)
if mt and rawget(mt, "__iter") then
arrayIterable = iterable :: Set<T>
elseif __DEV__ then
error("cannot create array from an object-like table")
end
end
elseif typeof(iterable) == "string" then
arrayIterable = arrayFromString(iterable :: string) :: Array<string>
else
error(("cannot create array from value of type `%s`"):format(typeof(iterable)))
end
if arrayIterable then
array = table.create(#arrayIterable)
for _, element in arrayIterable do
if not map[element] then
map[element] = true
table.insert(array, element)
end
end
else
array = {}
end
else
array = {}
end
return (setmetatable({
size = #array,
_map = map,
_array = array,
}, Set) :: any) :: Set<T>
end
function Set:add(value)
if not self._map[value] then
self.size = self.size :: number + 1
self._map[value] = true
table.insert(self._array, value)
end
return self
end
function Set:clear()
self.size = 0
table.clear(self._map)
table.clear(self._array)
end
function Set:delete(value): boolean
if not self._map[value] then
return false
end
self.size = self.size :: number - 1
self._map[value] = nil
local index = table.find(self._array, value)
if index then
table.remove(self._array, index)
end
return true
end
function Set:forEach(callback: setCallbackFn<any> | setCallbackFnWithThisArg<any>, thisArg: Object?): ()
if typeof(callback) ~= "function" then
error("callback is not a function")
end
arrayForEach(self._array, function(value)
if thisArg ~= nil then
(callback :: setCallbackFnWithThisArg<any>)(thisArg, value, value, self)
else
(callback :: setCallbackFn<any>)(value, value, self)
end
end)
end
function Set:has(value): boolean
return self._map[value] ~= nil
end
function Set:ipairs()
if __DEV__ then
warn(
debug.traceback(
"`for _,_ in mySet:ipairs() do` is deprecated and will be removed in a future release, please use `for _,_ in mySet do` instead\n",
2
)
)
end
return ipairs(self._array)
end
return Set
end
end)())
__register("Collections/WeakMap", (function()
local script = __makeProxy({"Collections","WeakMap"})
return function()
local Collections = script.Parent
local Packages = Collections.Parent
local ES7Types = __require(Packages.ES7Types)
type WeakMap<K, V> = ES7Types.WeakMap<K, V>
type WeakMapPrivate<K, V> = {
_weakMap: { [K]: V },
get: (self: WeakMapPrivate<K, V>, K) -> V,
set: (self: WeakMapPrivate<K, V>, K, V) -> WeakMapPrivate<K, V>,
has: (self: WeakMapPrivate<K, V>, K) -> boolean,
}
type WeakMap_Statics = {
new: <K, V>() -> WeakMap<K, V>,
}
local WeakMap: WeakMapPrivate<any, any> & WeakMap_Statics = {} :: any;
(WeakMap :: any).__index = WeakMap
function WeakMap.new<K, V>(): WeakMap<K, V>
local weakMap = setmetatable({}, { __mode = "k" })
return setmetatable({ _weakMap = weakMap }, WeakMap) :: any
end
function WeakMap:get(key)
return self._weakMap[key]
end
function WeakMap:set(key, value)
self._weakMap[key] = value
return self
end
function WeakMap:has(key): boolean
return self._weakMap[key] ~= nil
end
return WeakMap :: WeakMap<any, any> & WeakMap_Statics
end
end)())
__register("Console/init", (function()
local script = __makeProxy({"Console"})
return function()
local makeConsoleImpl = __require(script.makeConsoleImpl)
return makeConsoleImpl()
end
end)())
__register("Console/makeConsoleImpl", (function()
local script = __makeProxy({"Console","makeConsoleImpl"})
return function()
local root = script.Parent
local Packages = root.Parent
local inspect = __require(Packages.Collections).inspect
local INDENT = "  "
return function()
local console = {}
local indentDepth = 0
local function indent()
return string.rep(INDENT, indentDepth)
end
function console.log(content, ...)
local message
if typeof(content) == "string" then
message = string.format(content, ...)
else
message = inspect(content)
end
print(indent() .. message)
end
function console.debug(content, ...)
local message
if typeof(content) == "string" then
message = string.format(content, ...)
else
message = inspect(content)
end
print(indent() .. message)
end
function console.info(content, ...)
local message
if typeof(content) == "string" then
message = string.format(content, ...)
else
message = inspect(content)
end
print(indent() .. message)
end
function console.warn(content, ...)
local message
if typeof(content) == "string" then
message = string.format(content, ...)
else
message = inspect(content)
end
warn(indent() .. message)
end
function console.error(content, ...)
local message
if typeof(content) == "string" then
message = string.format(content, ...)
else
message = inspect(content)
end
warn(indent() .. message)
end
function console.group(content, ...)
local message
if typeof(content) == "string" then
message = string.format(content, ...)
else
message = inspect(content)
end
print(indent() .. message)
indentDepth = indentDepth + 1
end
function console.groupCollapsed(content, ...)
local message
if typeof(content) == "string" then
message = string.format(content, ...)
else
message = inspect(content)
end
print(indent() .. message)
indentDepth = indentDepth + 1
end
function console.groupEnd()
if indentDepth > 0 then
indentDepth = indentDepth - 1
end
end
return console
end
end
end)())
__register("String/charCodeAt", (function()
local script = __makeProxy({"String","charCodeAt"})
return function()
local String = script.Parent
local Packages = String.Parent
local Number = __require(Packages.Number)
local NaN = Number.NaN
return function(str: string, index: number): number
if type(index) ~= "number" then
index = 1
end
local length = string.len(str)
if index < 1 or index > length then
return NaN
end
local offset = utf8.offset(str, index)
if offset == nil or offset > length then
return NaN
end
local value = utf8.codepoint(str, offset, offset)
if value == nil then
return NaN
end
return value
end
end
end)())
__register("String/endsWith", (function()
local script = __makeProxy({"String","endsWith"})
return function()
local function endsWith(value: string, substring: string, optionalLength: number?): boolean
local substringLength = substring:len()
if substringLength == 0 then
return true
end
local valueLength = value:len()
local length = optionalLength or valueLength
if length > valueLength then
length = valueLength
end
if length < 1 then
return false
end
local position = length - substringLength + 1
return value:find(substring, position, true) == position
end
return endsWith
end
end)())
__register("String/findOr", (function()
local script = __makeProxy({"String","findOr"})
return function()
type Match = {
index: number,
match: string,
}
local luaPatternCharacters = "([" .. ("$%^()-[].?"):gsub("(.)", "%%%1") .. "])"
local function findOr(str: string, patternTable: { string }, initIndex: number?): Match | nil
local init = utf8.offset(str, initIndex or 1)
local matches = {}
for _, value in patternTable do
value = value:gsub(luaPatternCharacters, "%%%1")
local iStart, iEnd = string.find(str, value, init)
if iStart then
local prefix = string.sub(str, 1, iStart - 1)
local prefixEnd, invalidBytePosition = utf8.len(prefix)
if prefixEnd == nil then
error(("string `%s` has an invalid byte at position %s"):format(prefix, tostring(invalidBytePosition)))
end
local iStartIndex = prefixEnd :: number + 1
local match = {
index = iStartIndex,
match = string.sub(str, iStart, iEnd),
}
table.insert(matches, match)
end
end
if #matches == 0 then
return nil
end
local firstMatch
for _, value in matches do
if firstMatch == nil then
firstMatch = value
end
if value.index < firstMatch.index then
firstMatch = value
end
end
return firstMatch
end
return findOr
end
end)())
__register("String/includes", (function()
local script = __makeProxy({"String","includes"})
return function()
local luaPatternCharacters = "([" .. ("$%^()-[].?"):gsub("(.)", "%%%1") .. "])"
local function includes(str: string, substring: string, position: (string | number)?): boolean
local strLen, invalidBytePosition = utf8.len(str)
assert(strLen ~= nil, ("string `%s` has an invalid byte at position %s"):format(str, tostring(invalidBytePosition)))
if strLen == 0 then
return false
end
if #substring == 0 then
return true
end
local startIndex = 1
if position ~= nil then
startIndex = tonumber(position) or 1
if startIndex > strLen then
return false
end
end
if startIndex < 1 then
startIndex = 1
end
local init = utf8.offset(str, startIndex)
local value = substring:gsub(luaPatternCharacters, "%%%1")
local iStart, _ = string.find(str, value, init)
return iStart ~= nil
end
return includes
end
end)())
__register("String/indexOf", (function()
local script = __makeProxy({"String","indexOf"})
return function()
local luaPatternCharacters = "([" .. ("$%^()-[].?"):gsub("(.)", "%%%1") .. "])"
return function(str: string, searchElement: string, fromIndex: number?): number
local length = #str
local fromIndex_ = if fromIndex ~= nil then if fromIndex < 1 then 1 else fromIndex :: number else 1
if #searchElement == 0 then
return if fromIndex_ > length then length else fromIndex_
end
if fromIndex_ > length then
return -1
end
searchElement = searchElement:gsub(luaPatternCharacters, "%%%1")
local searchElementLength = #searchElement
for i = fromIndex_, length do
if string.sub(str, i, i + searchElementLength - 1) == searchElement then
return i
end
end
return -1
end
end
end)())
__register("String/init", (function()
local script = __makeProxy({"String"})
return function()
return {
charCodeAt = __require(script.charCodeAt),
endsWith = __require(script.endsWith),
findOr = __require(script.findOr),
includes = __require(script.includes),
indexOf = __require(script.indexOf),
lastIndexOf = __require(script.lastIndexOf),
slice = __require(script.slice),
split = __require(script.split),
startsWith = __require(script.startsWith),
substr = __require(script.substr),
trim = __require(script.trim),
trimEnd = __require(script.trimEnd),
trimStart = __require(script.trimStart),
trimRight = __require(script.trimEnd),
trimLeft = __require(script.trimStart),
}
end
end)())
__register("String/lastIndexOf", (function()
local script = __makeProxy({"String","lastIndexOf"})
return function()
local function lastIndexOf(str: string, searchValue: string, fromIndex: number?): number
local strLength = string.len(str)
local calculatedFromIndex
if fromIndex then
calculatedFromIndex = fromIndex
else
calculatedFromIndex = strLength
end
if fromIndex and fromIndex < 1 then
calculatedFromIndex = 1
end
if fromIndex and fromIndex > strLength then
calculatedFromIndex = strLength
end
if searchValue == "" then
return calculatedFromIndex :: number
end
local lastFoundStartIndex, foundStartIndex
local foundEndIndex: number? = 0
repeat
lastFoundStartIndex = foundStartIndex
foundStartIndex, foundEndIndex = string.find(str, searchValue, foundEndIndex :: number + 1, true)
until foundStartIndex == nil or foundStartIndex > calculatedFromIndex
if lastFoundStartIndex == nil then
return -1
end
return lastFoundStartIndex :: number
end
return lastIndexOf
end
end)())
__register("String/slice", (function()
local script = __makeProxy({"String","slice"})
return function()
local function slice(str: string, startIndexStr: string | number, lastIndexStr: (string | number)?): string
local strLen, invalidBytePosition = utf8.len(str)
assert(strLen ~= nil, ("string `%s` has an invalid byte at position %s"):format(str, tostring(invalidBytePosition)))
local startIndex = tonumber(startIndexStr)
assert(typeof(startIndex) == "number", "startIndexStr should be a number")
if startIndex + strLen < 0 then
startIndex = 1
end
if startIndex > strLen then
return ""
end
local lastIndex = strLen + 1
if lastIndexStr ~= nil then
local NaN = 0 / 0
lastIndex = tonumber(lastIndexStr) or NaN
end
assert(typeof(lastIndex) == "number", "lastIndexStr should convert to number")
if lastIndex > strLen then
lastIndex = strLen + 1
end
local startIndexByte = utf8.offset(str, startIndex)
local lastIndexByte = utf8.offset(str, lastIndex) - 1
return string.sub(str, startIndexByte, lastIndexByte)
end
return slice
end
end)())
__register("String/split", (function()
local script = __makeProxy({"String","split"})
return function()
local String = script.Parent
local findOr = __require(String.findOr)
local slice = __require(String.slice)
local Packages = String.Parent
local types = __require(Packages.ES7Types)
type Array<T> = types.Array<T>
local MAX_SAFE_INTEGER = __require(Packages.Number).MAX_SAFE_INTEGER
type Pattern = string | Array<string>
local function split(str: string, _pattern: Pattern?, _limit: number?): Array<string>
if _pattern == nil then
return { str }
end
if _limit == 0 then
return {}
end
local limit = if _limit == nil or _limit < 0 then MAX_SAFE_INTEGER else _limit
local pattern = _pattern
local patternList: Array<string>
if typeof(pattern) == "string" then
if pattern == "" then
local result = {}
for c in str:gmatch(".") do
table.insert(result, c)
end
return result
end
patternList = { pattern }
else
patternList = pattern :: Array<string>
end
local init = 1
local result = {}
local lastMatch
local strLen, invalidBytePosition = utf8.len(str)
assert(strLen ~= nil, ("string `%s` has an invalid byte at position %s"):format(str, tostring(invalidBytePosition)))
repeat
local match = findOr(str, patternList, init)
if match ~= nil then
table.insert(result, slice(str, init, match.index))
local matchLength = utf8.len(match.match)
init = match.index + matchLength :: number
else
table.insert(result, slice(str, init, nil))
end
if match ~= nil then
lastMatch = match
end
until match == nil or init > strLen or #result >= limit
if lastMatch ~= nil then
local lastMatchLength, invalidBytePosition_ = utf8.len(lastMatch.match)
assert(
lastMatchLength ~= nil,
("string `%s` has an invalid byte at position %s"):format(lastMatch.match, tostring(invalidBytePosition_))
)
if lastMatch.index + lastMatchLength == strLen + 1 then
table.insert(result, "")
end
end
return result
end
return split
end
end)())
__register("String/startsWith", (function()
local script = __makeProxy({"String","startsWith"})
return function()
local function startsWith(value: string, substring: string, position: number?): boolean
if string.len(substring) == 0 then
return true
end
local position_
if position == nil or position < 1 then
position_ = 1
else
position_ = position
end
if position_ > string.len(value) then
return false
end
return value:find(substring, position_, true) == position_
end
return startsWith
end
end)())
__register("String/substr", (function()
local script = __makeProxy({"String","substr"})
return function()
return function(s: string, startIndex: number, numberOfCharacters: number?): string
if numberOfCharacters and numberOfCharacters <= 0 then
return ""
end
return string.sub(s, startIndex, numberOfCharacters and startIndex + numberOfCharacters - 1 or nil)
end
end
end)())
__register("String/trim", (function()
local script = __makeProxy({"String","trim"})
return function()
local trimStart = __require(script.Parent.trimStart)
local trimEnd = __require(script.Parent.trimEnd)
return function(source: string): string
return trimStart(trimEnd(source))
end
end
end)())
__register("String/trimEnd", (function()
local script = __makeProxy({"String","trimEnd"})
return function()
return function(source: string): string
return (source:gsub("[%s]+$", ""))
end
end
end)())
__register("String/trimStart", (function()
local script = __makeProxy({"String","trimStart"})
return function()
return function(source: string): string
return (source:gsub("^[%s]+", ""))
end
end
end)())
__register("Timers/init", (function()
local script = __makeProxy({"Timers"})
return function()
local Packages = script.Parent
local Object = __require(Packages.Collections).Object
local makeTimerImpl = __require(script.makeTimerImpl)
local makeIntervalImpl = __require(script.makeIntervalImpl)
type Timeout = makeTimerImpl.Timeout
type Interval = makeIntervalImpl.Interval
return Object.assign({}, makeTimerImpl(task.delay), makeIntervalImpl(task.delay))
end
end)())
__register("Timers/makeIntervalImpl", (function()
local script = __makeProxy({"Timers","makeIntervalImpl"})
return function()
local Status = newproxy(false)
type TaskStatus = number
type Interval = { [typeof(Status)]: TaskStatus }
local SCHEDULED = 1
local CANCELLED = 3
return function(delayImpl)
local function setInterval(callback, intervalTime: number, ...): Interval
local args = { ... }
local task = {
[Status] = SCHEDULED,
}
if intervalTime == nil then
intervalTime = 0
end
local intervalTimeMs = intervalTime / 1000
local delay_
delay_ = function()
delayImpl(intervalTimeMs, function()
if task[Status] == SCHEDULED then
callback(unpack(args))
delay_()
end
end)
end
delay_()
return task
end
local function clearInterval(task: Interval)
if task == nil then
return
end
if task[Status] == SCHEDULED then
task[Status] = CANCELLED
end
end
return {
setInterval = setInterval,
clearInterval = clearInterval,
}
end
end
end)())
__register("Timers/makeTimerImpl", (function()
local script = __makeProxy({"Timers","makeTimerImpl"})
return function()
local Status = newproxy(false)
type TaskStatus = number
type Timeout = { [typeof(Status)]: TaskStatus }
local SCHEDULED = 1
local DONE = 2
local CANCELLED = 3
return function(delayImpl)
local function setTimeout(callback, delayTime: number?, ...): Timeout
local args = { ... }
local task = {
[Status] = SCHEDULED,
}
if delayTime == nil then
delayTime = 0
end
local delayTimeMs = delayTime :: number / 1000
delayImpl(delayTimeMs, function()
if task[Status] == SCHEDULED then
callback(unpack(args))
task[Status] = DONE
end
end)
return task
end
local function clearTimeout(task: Timeout)
if task == nil then
return
end
if task[Status] == SCHEDULED then
task[Status] = CANCELLED
end
end
return {
setTimeout = setTimeout,
clearTimeout = clearTimeout,
}
end
end
end)())
__register("Symbol/init", (function()
local script = __makeProxy({"Symbol"})
return function()
local Symbol = __require(script.Symbol)
type Symbol = Symbol.Symbol
local GlobalRegistry = __require(script["Registry.global"])
local SymbolObject = setmetatable({}, {
__call = function(_, name: string?): Symbol.Symbol
return Symbol.new(name)
end,
})
SymbolObject.for_ = GlobalRegistry.getOrInit
return SymbolObject
end
end)())
__register("Symbol/Registry.global", (function()
local script = __makeProxy({"Symbol","Registry.global"})
return function()
local Symbol = __require(script.Parent.Symbol)
local GlobalRegistry: { [string]: Symbol.Symbol } = {}
return {
getOrInit = function(name: string): Symbol.Symbol
if GlobalRegistry[name] == nil then
GlobalRegistry[name] = Symbol.new(name)
end
return GlobalRegistry[name]
end,
__clear = function()
GlobalRegistry = {}
end,
}
end
end)())
__register("Symbol/Symbol", (function()
local script = __makeProxy({"Symbol","Symbol"})
return function()
type Symbol = typeof(newproxy(true)) & { [string]: any }
return {
new = function(name: string?): Symbol
local self = newproxy(true) :: any
local wrappedName = "Symbol()"
if name then
wrappedName = ("Symbol(%s)"):format(name)
end
getmetatable(self).__tostring = function()
return wrappedName
end
return (self :: any) :: Symbol
end,
}
end
end)())
__register("Promise/init", (function()
local script = __makeProxy({"Promise"})
return function()
local ERROR_NON_PROMISE_IN_LIST = "Non-promise value passed into %s at index %s"
local ERROR_NON_LIST = "Please pass a list of promises to %s"
local ERROR_NON_FUNCTION = "Please pass a handler function to %s!"
local MODE_KEY_METATABLE = { __mode = "k" }
local function isCallable(value)
if type(value) == "function" then
return true
end
if type(value) == "table" then
local metatable = getmetatable(value)
if metatable and type(rawget(metatable, "__call")) == "function" then
return true
end
end
return false
end
local function makeEnum(enumName, members)
local enum = {}
for _, memberName in ipairs(members) do
enum[memberName] = memberName
end
return setmetatable(enum, {
__index = function(_, k)
error(string.format("%s is not in %s!", k, enumName), 2)
end,
__newindex = function()
error(string.format("Creating new members in %s is not allowed!", enumName), 2)
end,
})
end
local Error
do
Error = {
Kind = makeEnum("Promise.Error.Kind", {
"ExecutionError",
"AlreadyCancelled",
"NotResolvedInTime",
"TimedOut",
}),
}
Error.__index = Error
function Error.new(options, parent)
options = options or {}
return setmetatable({
error = tostring(options.error) or "[This error has no error text.]",
trace = options.trace,
context = options.context,
kind = options.kind,
parent = parent,
createdTick = os.clock(),
createdTrace = debug.traceback(),
}, Error)
end
function Error.is(anything)
if type(anything) == "table" then
local metatable = getmetatable(anything)
if type(metatable) == "table" then
return rawget(anything, "error") ~= nil and type(rawget(metatable, "extend")) == "function"
end
end
return false
end
function Error.isKind(anything, kind)
assert(kind ~= nil, "Argument #2 to Promise.Error.isKind must not be nil")
return Error.is(anything) and anything.kind == kind
end
function Error:extend(options)
options = options or {}
options.kind = options.kind or self.kind
return Error.new(options, self)
end
function Error:getErrorChain()
local runtimeErrors = { self }
while runtimeErrors[#runtimeErrors].parent do
table.insert(runtimeErrors, runtimeErrors[#runtimeErrors].parent)
end
return runtimeErrors
end
function Error:__tostring()
local errorStrings = {
string.format("-- Promise.Error(%s) --", self.kind or "?"),
}
for _, runtimeError in ipairs(self:getErrorChain()) do
table.insert(
errorStrings,
table.concat({
runtimeError.trace or runtimeError.error,
runtimeError.context,
}, "\n")
)
end
return table.concat(errorStrings, "\n")
end
end
local function pack(...)
return select("#", ...), { ... }
end
local function packResult(success, ...)
return success, select("#", ...), { ... }
end
local function makeErrorHandler(traceback)
assert(traceback ~= nil, "traceback is nil")
return function(err)
if type(err) == "table" then
return err
end
return Error.new({
error = err,
kind = Error.Kind.ExecutionError,
trace = debug.traceback(tostring(err), 2),
context = "Promise created at:\n\n" .. traceback,
})
end
end
local function runExecutor(traceback, callback, ...)
return packResult(xpcall(callback, makeErrorHandler(traceback), ...))
end
local function createAdvancer(traceback, callback, resolve, reject)
return function(...)
local ok, resultLength, result = runExecutor(traceback, callback, ...)
if ok then
resolve(unpack(result, 1, resultLength))
else
reject(result[1])
end
end
end
local function isEmpty(t)
return next(t) == nil
end
local Promise = {
Error = Error,
Status = makeEnum("Promise.Status", { "Started", "Resolved", "Rejected", "Cancelled" }),
_getTime = os.clock,
_timeEvent = game:GetService("RunService").Heartbeat,
_unhandledRejectionCallbacks = {},
}
Promise.prototype = {}
Promise.__index = Promise.prototype
function Promise._new(traceback, callback, parent)
if parent ~= nil and not Promise.is(parent) then
error("Argument #2 to Promise.new must be a promise or nil", 2)
end
local self = {
_source = traceback,
_status = Promise.Status.Started,
_values = nil,
_valuesLength = -1,
_unhandledRejection = true,
_queuedResolve = {},
_queuedReject = {},
_queuedFinally = {},
_cancellationHook = nil,
_parent = parent,
_consumers = setmetatable({}, MODE_KEY_METATABLE),
}
if parent and parent._status == Promise.Status.Started then
parent._consumers[self] = true
end
setmetatable(self, Promise)
local function resolve(...)
self:_resolve(...)
end
local function reject(...)
self:_reject(...)
end
local function onCancel(cancellationHook)
if cancellationHook then
if self._status == Promise.Status.Cancelled then
cancellationHook()
else
self._cancellationHook = cancellationHook
end
end
return self._status == Promise.Status.Cancelled
end
coroutine.wrap(function()
local ok, _, result = runExecutor(self._source, callback, resolve, reject, onCancel)
if not ok then
reject(result[1])
end
end)()
return self
end
function Promise.new(executor)
return Promise._new(debug.traceback(nil, 2), executor)
end
function Promise:__tostring()
return string.format("Promise(%s)", self._status)
end
function Promise.defer(executor)
local traceback = debug.traceback(nil, 2)
local promise
promise = Promise._new(traceback, function(resolve, reject, onCancel)
local connection
connection = Promise._timeEvent:Connect(function()
connection:Disconnect()
local ok, _, result = runExecutor(traceback, executor, resolve, reject, onCancel)
if not ok then
reject(result[1])
end
end)
end)
return promise
end
Promise.async = Promise.defer
function Promise.resolve(...)
local length, values = pack(...)
return Promise._new(debug.traceback(nil, 2), function(resolve)
resolve(unpack(values, 1, length))
end)
end
function Promise.reject(...)
local length, values = pack(...)
return Promise._new(debug.traceback(nil, 2), function(_, reject)
reject(unpack(values, 1, length))
end)
end
function Promise._try(traceback, callback, ...)
local valuesLength, values = pack(...)
return Promise._new(traceback, function(resolve)
resolve(callback(unpack(values, 1, valuesLength)))
end)
end
function Promise.try(callback, ...)
return Promise._try(debug.traceback(nil, 2), callback, ...)
end
function Promise._all(traceback, promises, amount)
if type(promises) ~= "table" then
error(string.format(ERROR_NON_LIST, "Promise.all"), 3)
end
for i, promise in pairs(promises) do
if not Promise.is(promise) then
error(string.format(ERROR_NON_PROMISE_IN_LIST, "Promise.all", tostring(i)), 3)
end
end
if #promises == 0 or amount == 0 then
return Promise.resolve({})
end
return Promise._new(traceback, function(resolve, reject, onCancel)
local resolvedValues = {}
local newPromises = {}
local resolvedCount = 0
local rejectedCount = 0
local done = false
local function cancel()
for _, promise in ipairs(newPromises) do
promise:cancel()
end
end
local function resolveOne(i, ...)
if done then
return
end
resolvedCount = resolvedCount + 1
if amount == nil then
resolvedValues[i] = ...
else
resolvedValues[resolvedCount] = ...
end
if resolvedCount >= (amount or #promises) then
done = true
resolve(resolvedValues)
cancel()
end
end
onCancel(cancel)
for i, promise in ipairs(promises) do
newPromises[i] = promise:andThen(function(...)
resolveOne(i, ...)
end, function(...)
rejectedCount = rejectedCount + 1
if amount == nil or #promises - rejectedCount < amount then
cancel()
done = true
reject(...)
end
end)
end
if done then
cancel()
end
end)
end
function Promise.all(promises)
return Promise._all(debug.traceback(nil, 2), promises)
end
function Promise.fold(list, reducer, initialValue)
assert(type(list) == "table", "Bad argument #1 to Promise.fold: must be a table")
assert(isCallable(reducer), "Bad argument #2 to Promise.fold: must be a function")
local accumulator = Promise.resolve(initialValue)
return Promise.each(list, function(resolvedElement, i)
accumulator = accumulator:andThen(function(previousValueResolved)
return reducer(previousValueResolved, resolvedElement, i)
end)
end):andThen(function()
return accumulator
end)
end
function Promise.some(promises, count)
assert(type(count) == "number", "Bad argument #2 to Promise.some: must be a number")
return Promise._all(debug.traceback(nil, 2), promises, count)
end
function Promise.any(promises)
return Promise._all(debug.traceback(nil, 2), promises, 1):andThen(function(values)
return values[1]
end)
end
function Promise.allSettled(promises)
if type(promises) ~= "table" then
error(string.format(ERROR_NON_LIST, "Promise.allSettled"), 2)
end
for i, promise in pairs(promises) do
if not Promise.is(promise) then
error(string.format(ERROR_NON_PROMISE_IN_LIST, "Promise.allSettled", tostring(i)), 2)
end
end
if #promises == 0 then
return Promise.resolve({})
end
return Promise._new(debug.traceback(nil, 2), function(resolve, _, onCancel)
local fates = {}
local newPromises = {}
local finishedCount = 0
local function resolveOne(i, ...)
finishedCount = finishedCount + 1
fates[i] = ...
if finishedCount >= #promises then
resolve(fates)
end
end
onCancel(function()
for _, promise in ipairs(newPromises) do
promise:cancel()
end
end)
for i, promise in ipairs(promises) do
newPromises[i] = promise:finally(function(...)
resolveOne(i, ...)
end)
end
end)
end
function Promise.race(promises)
assert(type(promises) == "table", string.format(ERROR_NON_LIST, "Promise.race"))
for i, promise in pairs(promises) do
assert(Promise.is(promise), string.format(ERROR_NON_PROMISE_IN_LIST, "Promise.race", tostring(i)))
end
return Promise._new(debug.traceback(nil, 2), function(resolve, reject, onCancel)
local newPromises = {}
local finished = false
local function cancel()
for _, promise in ipairs(newPromises) do
promise:cancel()
end
end
local function finalize(callback)
return function(...)
cancel()
finished = true
return callback(...)
end
end
if onCancel(finalize(reject)) then
return
end
for i, promise in ipairs(promises) do
newPromises[i] = promise:andThen(finalize(resolve), finalize(reject))
end
if finished then
cancel()
end
end)
end
function Promise.each(list, predicate)
assert(type(list) == "table", string.format(ERROR_NON_LIST, "Promise.each"))
assert(isCallable(predicate), string.format(ERROR_NON_FUNCTION, "Promise.each"))
return Promise._new(debug.traceback(nil, 2), function(resolve, reject, onCancel)
local results = {}
local promisesToCancel = {}
local cancelled = false
local function cancel()
for _, promiseToCancel in ipairs(promisesToCancel) do
promiseToCancel:cancel()
end
end
onCancel(function()
cancelled = true
cancel()
end)
local preprocessedList = {}
for index, value in ipairs(list) do
if Promise.is(value) then
if value:getStatus() == Promise.Status.Cancelled then
cancel()
return reject(Error.new({
error = "Promise is cancelled",
kind = Error.Kind.AlreadyCancelled,
context = string.format(
"The Promise that was part of the array at index %d passed into Promise.each was already cancelled when Promise.each began.\n\nThat Promise was created at:\n\n%s",
index,
value._source
),
}))
elseif value:getStatus() == Promise.Status.Rejected then
cancel()
return reject(select(2, value:await()))
end
local ourPromise = value:andThen(function(...)
return ...
end)
table.insert(promisesToCancel, ourPromise)
preprocessedList[index] = ourPromise
else
preprocessedList[index] = value
end
end
for index, value in ipairs(preprocessedList) do
if Promise.is(value) then
local success
success, value = value:await()
if not success then
cancel()
return reject(value)
end
end
if cancelled then
return
end
local predicatePromise = Promise.resolve(predicate(value, index))
table.insert(promisesToCancel, predicatePromise)
local success, result = predicatePromise:await()
if not success then
cancel()
return reject(result)
end
results[index] = result
end
resolve(results)
end)
end
function Promise.is(object)
if type(object) ~= "table" then
return false
end
local objectMetatable = getmetatable(object)
if objectMetatable == Promise then
return true
elseif objectMetatable == nil then
return isCallable(object.andThen)
elseif
type(objectMetatable) == "table"
and type(rawget(objectMetatable, "__index")) == "table"
and isCallable(rawget(rawget(objectMetatable, "__index"), "andThen"))
then
return true
end
return false
end
function Promise.promisify(callback)
return function(...)
return Promise._try(debug.traceback(nil, 2), callback, ...)
end
end
do
local first
local connection
function Promise.delay(seconds)
assert(type(seconds) == "number", "Bad argument #1 to Promise.delay, must be a number.")
if not (seconds >= 1 / 60) or seconds == math.huge then
seconds = 1 / 60
end
return Promise._new(debug.traceback(nil, 2), function(resolve, _, onCancel)
local startTime = Promise._getTime()
local endTime = startTime + seconds
local node = {
resolve = resolve,
startTime = startTime,
endTime = endTime,
}
if connection == nil then
first = node
connection = Promise._timeEvent:Connect(function()
local threadStart = Promise._getTime()
while first ~= nil and first.endTime < threadStart do
local current = first
first = current.next
if first == nil then
connection:Disconnect()
connection = nil
else
first.previous = nil
end
current.resolve(Promise._getTime() - current.startTime)
end
end)
else
if first.endTime < endTime then
local current = first
local next = current.next
while next ~= nil and next.endTime < endTime do
current = next
next = current.next
end
current.next = node
node.previous = current
if next ~= nil then
node.next = next
next.previous = node
end
else
node.next = first
first.previous = node
first = node
end
end
onCancel(function()
local next = node.next
if first == node then
if next == nil then
connection:Disconnect()
connection = nil
else
next.previous = nil
end
first = next
else
local previous = node.previous
previous.next = next
if next ~= nil then
next.previous = previous
end
end
end)
end)
end
end
function Promise.prototype:timeout(seconds, rejectionValue)
local traceback = debug.traceback(nil, 2)
return Promise.race({
Promise.delay(seconds):andThen(function()
return Promise.reject(rejectionValue == nil and Error.new({
kind = Error.Kind.TimedOut,
error = "Timed out",
context = string.format(
"Timeout of %d seconds exceeded.\n:timeout() called at:\n\n%s",
seconds,
traceback
),
}) or rejectionValue)
end),
self,
})
end
function Promise.prototype:getStatus()
return self._status
end
function Promise.prototype:_andThen(traceback, successHandler, failureHandler)
self._unhandledRejection = false
return Promise._new(traceback, function(resolve, reject)
local successCallback = resolve
if successHandler then
successCallback = createAdvancer(traceback, successHandler, resolve, reject)
end
local failureCallback = reject
if failureHandler then
failureCallback = createAdvancer(traceback, failureHandler, resolve, reject)
end
if self._status == Promise.Status.Started then
table.insert(self._queuedResolve, successCallback)
table.insert(self._queuedReject, failureCallback)
elseif self._status == Promise.Status.Resolved then
successCallback(unpack(self._values, 1, self._valuesLength))
elseif self._status == Promise.Status.Rejected then
failureCallback(unpack(self._values, 1, self._valuesLength))
elseif self._status == Promise.Status.Cancelled then
reject(Error.new({
error = "Promise is cancelled",
kind = Error.Kind.AlreadyCancelled,
context = "Promise created at\n\n" .. traceback,
}))
end
end, self)
end
function Promise.prototype:andThen(successHandler, failureHandler)
assert(successHandler == nil or isCallable(successHandler), string.format(ERROR_NON_FUNCTION, "Promise:andThen"))
assert(failureHandler == nil or isCallable(failureHandler), string.format(ERROR_NON_FUNCTION, "Promise:andThen"))
return self:_andThen(debug.traceback(nil, 2), successHandler, failureHandler)
end
function Promise.prototype:catch(failureHandler)
assert(failureHandler == nil or isCallable(failureHandler), string.format(ERROR_NON_FUNCTION, "Promise:catch"))
return self:_andThen(debug.traceback(nil, 2), nil, failureHandler)
end
function Promise.prototype:tap(tapHandler)
assert(isCallable(tapHandler), string.format(ERROR_NON_FUNCTION, "Promise:tap"))
return self:_andThen(debug.traceback(nil, 2), function(...)
local callbackReturn = tapHandler(...)
if Promise.is(callbackReturn) then
local length, values = pack(...)
return callbackReturn:andThen(function()
return unpack(values, 1, length)
end)
end
return ...
end)
end
function Promise.prototype:andThenCall(callback, ...)
assert(isCallable(callback), string.format(ERROR_NON_FUNCTION, "Promise:andThenCall"))
local length, values = pack(...)
return self:_andThen(debug.traceback(nil, 2), function()
return callback(unpack(values, 1, length))
end)
end
function Promise.prototype:andThenReturn(...)
local length, values = pack(...)
return self:_andThen(debug.traceback(nil, 2), function()
return unpack(values, 1, length)
end)
end
function Promise.prototype:cancel()
if self._status ~= Promise.Status.Started then
return
end
self._status = Promise.Status.Cancelled
if self._cancellationHook then
self._cancellationHook()
end
if self._parent then
self._parent:_consumerCancelled(self)
end
for child in pairs(self._consumers) do
child:cancel()
end
self:_finalize()
end
function Promise.prototype:_consumerCancelled(consumer)
if self._status ~= Promise.Status.Started then
return
end
self._consumers[consumer] = nil
if next(self._consumers) == nil then
self:cancel()
end
end
function Promise.prototype:_finally(traceback, finallyHandler, onlyOk)
if not onlyOk then
self._unhandledRejection = false
end
return Promise._new(traceback, function(resolve, reject)
local finallyCallback = resolve
if finallyHandler then
finallyCallback = createAdvancer(traceback, finallyHandler, resolve, reject)
end
if onlyOk then
local callback = finallyCallback
finallyCallback = function(...)
if self._status == Promise.Status.Rejected then
return resolve(self)
end
return callback(...)
end
end
if self._status == Promise.Status.Started then
table.insert(self._queuedFinally, finallyCallback)
else
finallyCallback(self._status)
end
end, self)
end
function Promise.prototype:finally(finallyHandler)
assert(finallyHandler == nil or isCallable(finallyHandler), string.format(ERROR_NON_FUNCTION, "Promise:finally"))
return self:_finally(debug.traceback(nil, 2), finallyHandler)
end
function Promise.prototype:finallyCall(callback, ...)
assert(isCallable(callback), string.format(ERROR_NON_FUNCTION, "Promise:finallyCall"))
local length, values = pack(...)
return self:_finally(debug.traceback(nil, 2), function()
return callback(unpack(values, 1, length))
end)
end
function Promise.prototype:finallyReturn(...)
local length, values = pack(...)
return self:_finally(debug.traceback(nil, 2), function()
return unpack(values, 1, length)
end)
end
function Promise.prototype:done(doneHandler)
assert(doneHandler == nil or isCallable(doneHandler), string.format(ERROR_NON_FUNCTION, "Promise:done"))
return self:_finally(debug.traceback(nil, 2), doneHandler, true)
end
function Promise.prototype:doneCall(callback, ...)
assert(isCallable(callback), string.format(ERROR_NON_FUNCTION, "Promise:doneCall"))
local length, values = pack(...)
return self:_finally(debug.traceback(nil, 2), function()
return callback(unpack(values, 1, length))
end, true)
end
function Promise.prototype:doneReturn(...)
local length, values = pack(...)
return self:_finally(debug.traceback(nil, 2), function()
return unpack(values, 1, length)
end, true)
end
function Promise.prototype:awaitStatus()
self._unhandledRejection = false
if self._status == Promise.Status.Started then
local bindable = Instance.new("BindableEvent")
self:finally(function()
bindable:Fire()
end)
bindable.Event:Wait()
bindable:Destroy()
end
if self._status == Promise.Status.Resolved then
return self._status, unpack(self._values, 1, self._valuesLength)
elseif self._status == Promise.Status.Rejected then
return self._status, unpack(self._values, 1, self._valuesLength)
end
return self._status
end
local function awaitHelper(status, ...)
return status == Promise.Status.Resolved, ...
end
function Promise.prototype:await()
return awaitHelper(self:awaitStatus())
end
local function expectHelper(status, ...)
if status ~= Promise.Status.Resolved then
error((...) == nil and "Expected Promise rejected with no value." or (...), 3)
end
return ...
end
function Promise.prototype:expect()
return expectHelper(self:awaitStatus())
end
Promise.prototype.awaitValue = Promise.prototype.expect
function Promise.prototype:_unwrap()
if self._status == Promise.Status.Started then
error("Promise has not resolved or rejected.", 2)
end
local success = self._status == Promise.Status.Resolved
return success, unpack(self._values, 1, self._valuesLength)
end
function Promise.prototype:_resolve(...)
if self._status ~= Promise.Status.Started then
if Promise.is((...)) then
(...):_consumerCancelled(self)
end
return
end
if Promise.is((...)) then
if select("#", ...) > 1 then
local message = string.format(
"When returning a Promise from andThen, extra arguments are " .. "discarded! See:\n\n%s",
self._source
)
warn(message)
end
local chainedPromise = ...
local promise = chainedPromise:andThen(function(...)
self:_resolve(...)
end, function(...)
local maybeRuntimeError = chainedPromise._values[1]
if chainedPromise._error then
maybeRuntimeError = Error.new({
error = chainedPromise._error,
kind = Error.Kind.ExecutionError,
context = "[No stack trace available as this Promise originated from an older version of the Promise library (< v2)]",
})
end
if Error.isKind(maybeRuntimeError, Error.Kind.ExecutionError) then
return self:_reject(maybeRuntimeError:extend({
error = "This Promise was chained to a Promise that errored.",
trace = "",
context = string.format(
"The Promise at:\n\n%s\n...Rejected because it was chained to the following Promise, which encountered an error:\n",
self._source
),
}))
end
self:_reject(...)
end)
if promise._status == Promise.Status.Cancelled then
self:cancel()
elseif promise._status == Promise.Status.Started then
self._parent = promise
promise._consumers[self] = true
end
return
end
self._status = Promise.Status.Resolved
self._valuesLength, self._values = pack(...)
for _, callback in ipairs(self._queuedResolve) do
coroutine.wrap(callback)(...)
end
self:_finalize()
end
function Promise.prototype:_reject(...)
if self._status ~= Promise.Status.Started then
return
end
self._status = Promise.Status.Rejected
self._valuesLength, self._values = pack(...)
if not isEmpty(self._queuedReject) then
for _, callback in ipairs(self._queuedReject) do
coroutine.wrap(callback)(...)
end
else
local err = tostring((...))
coroutine.wrap(function()
Promise._timeEvent:Wait()
if not self._unhandledRejection then
return
end
local message = string.format("Unhandled Promise rejection:\n\n%s\n\n%s", err, self._source)
for _, callback in ipairs(Promise._unhandledRejectionCallbacks) do
task.spawn(callback, self, unpack(self._values, 1, self._valuesLength))
end
if Promise.TEST then
return
end
warn(message)
end)()
end
self:_finalize()
end
function Promise.prototype:_finalize()
for _, callback in ipairs(self._queuedFinally) do
coroutine.wrap(callback)(self._status)
end
self._queuedFinally = nil
self._queuedReject = nil
self._queuedResolve = nil
if not Promise.TEST then
self._parent = nil
self._consumers = nil
end
end
function Promise.prototype:now(rejectionValue)
local traceback = debug.traceback(nil, 2)
if self._status == Promise.Status.Resolved then
return self:_andThen(traceback, function(...)
return ...
end)
else
return Promise.reject(rejectionValue == nil and Error.new({
kind = Error.Kind.NotResolvedInTime,
error = "This Promise was not resolved in time for :now()",
context = ":now() was called at:\n\n" .. traceback,
}) or rejectionValue)
end
end
function Promise.retry(callback, times, ...)
assert(isCallable(callback), "Parameter #1 to Promise.retry must be a function")
assert(type(times) == "number", "Parameter #2 to Promise.retry must be a number")
local args, length = { ... }, select("#", ...)
return Promise.resolve(callback(...)):catch(function(...)
if times > 0 then
return Promise.retry(callback, times - 1, unpack(args, 1, length))
else
return Promise.reject(...)
end
end)
end
function Promise.retryWithDelay(callback, times, seconds, ...)
assert(isCallable(callback), "Parameter #1 to Promise.retry must be a function")
assert(type(times) == "number", "Parameter #2 (times) to Promise.retry must be a number")
assert(type(seconds) == "number", "Parameter #3 (seconds) to Promise.retry must be a number")
local args, length = { ... }, select("#", ...)
return Promise.resolve(callback(...)):catch(function(...)
if times > 0 then
Promise.delay(seconds):await()
return Promise.retryWithDelay(callback, times - 1, seconds, unpack(args, 1, length))
else
return Promise.reject(...)
end
end)
end
function Promise.fromEvent(event, predicate)
predicate = predicate or function()
return true
end
return Promise._new(debug.traceback(nil, 2), function(resolve, _, onCancel)
local connection
local shouldDisconnect = false
local function disconnect()
connection:Disconnect()
connection = nil
end
connection = event:Connect(function(...)
local callbackValue = predicate(...)
if callbackValue == true then
resolve(...)
if connection then
disconnect()
else
shouldDisconnect = true
end
elseif type(callbackValue) ~= "boolean" then
error("Promise.fromEvent predicate should always return a boolean")
end
end)
if shouldDisconnect and connection then
return disconnect()
end
onCancel(disconnect)
end)
end
function Promise.onUnhandledRejection(callback)
table.insert(Promise._unhandledRejectionCallbacks, callback)
return function()
local index = table.find(Promise._unhandledRejectionCallbacks, callback)
if index then
table.remove(Promise._unhandledRejectionCallbacks, index)
end
end
end
return Promise
end
end)())
__register("LuauPolyfill/AssertionError/AssertionError.global", (function()
local script = __makeProxy({"LuauPolyfill","AssertionError","AssertionError.global"})
return function()
local LuauPolyfill = script.Parent.Parent
local Packages = LuauPolyfill.Parent
local Collections = __require(Packages.Collections)
local Array = Collections.Array
local Object = Collections.Object
local Boolean = __require(Packages.Boolean)
local String = __require(Packages.String)
local types = __require(Packages.ES7Types)
local inspect = Collections.inspect
local Error = __require(LuauPolyfill.Error)
local instanceof = __require(Packages.InstanceOf)
type Error = Error.Error
type Array<T> = types.Array<T>
type Object = types.Object
type Function = types.Function
local process = {
stderr = {
isTTY = false,
columns = 0,
hasColors = function(...)
return true
end,
},
}
function ErrorCaptureStackTrace(err, ...)
Error.captureStackTrace(err, ...)
end
local function removeColors(str)
return str
end
local blue = ""
local green = ""
local red = ""
local white = ""
local kReadableOperator = {
deepStrictEqual = "Expected values to be strictly deep-equal:",
strictEqual = "Expected values to be strictly equal:",
strictEqualObject = 'Expected "actual" to be reference-equal to "expected":',
deepEqual = "Expected values to be loosely deep-equal:",
notDeepStrictEqual = 'Expected "actual" not to be strictly deep-equal to:',
notStrictEqual = 'Expected "actual" to be strictly unequal to:',
notStrictEqualObject = 'Expected "actual" not to be reference-equal to "expected":',
notDeepEqual = 'Expected "actual" not to be loosely deep-equal to:',
notIdentical = "Values have same structure but are not reference-equal:",
notDeepEqualUnequal = "Expected values not to be loosely deep-equal:",
}
local kMaxShortLength = 12
local function copyError(source: Object)
local keys = Object.keys(source)
local target = {}
for _, key in keys do
target[key] = source[key]
end
target.message = source.message
return target
end
local function inspectValue(val)
return inspect(val, {
compact = false,
customInspect = false,
depth = 1000,
maxArrayLength = math.huge,
showHidden = false,
showProxy = false,
sorted = true,
getters = true,
})
end
local function createErrDiff(actual, expected, operator)
local other = ""
local res = ""
local end_ = ""
local skipped = false
local actualInspected = inspectValue(actual)
local actualLines = String.split(actualInspected, "\n")
local expectedLines = String.split(inspectValue(expected), "\n")
local i = 0
local indicator = ""
if
operator == "strictEqual"
and (
typeof(actual) == "table" and actual ~= nil and typeof(expected) == "table" and expected ~= nil
or typeof(actual) == "function" and typeof(expected) == "function"
)
then
operator = "strictEqualObject"
end
if #actualLines == 1 and #expectedLines == 1 and actualLines[1] ~= expectedLines[1] then
local c = false
local actualRaw = if c then removeColors(actualLines[1]) else actualLines[1]
local expectedRaw = if Boolean.toJSBoolean(c) then removeColors(expectedLines[1]) else expectedLines[1]
local inputLength = string.len(actualRaw) + string.len(expectedRaw)
if inputLength <= kMaxShortLength then
if
(typeof(actual) ~= "table" or actual == nil)
and (typeof(expected) ~= "table" or expected == nil)
and (actual ~= 0 or expected ~= 0)
then
return ("%s\n\n"):format(kReadableOperator[operator])
.. ("%s !== %s\n"):format(actualLines[1], expectedLines[1])
end
elseif operator ~= "strictEqualObject" then
local maxLength = if process.stderr.isTTY then process.stderr.columns else 80
if inputLength < maxLength then
while string.sub(actualRaw, i + 1, i + 1) == string.sub(expectedRaw, i + 1, i + 1) do
i += 1
end
if i > 2 then
indicator = ("\n  %s^"):format(string.rep(" ", i))
i = 0
end
end
end
end
local a = actualLines[#actualLines]
local b = expectedLines[#expectedLines]
while a == b do
local i_ = i
i += 1
if i_ < 3 then
end_ = ("\n  %s%s"):format(a, end_)
else
other = a
end
table.remove(actualLines)
table.remove(expectedLines)
if #actualLines == 0 or #expectedLines == 0 then
break
end
a = actualLines[#actualLines]
b = expectedLines[#expectedLines]
end
local maxLines = math.max(#actualLines, #expectedLines)
if maxLines == 0 then
local actualLines_ = String.split(actualInspected, "\n")
if #actualLines_ > 50 then
actualLines_[47] = ("%s...%s"):format(blue, white)
while #actualLines_ > 47 do
table.remove(actualLines_)
end
end
return ("%s\n\n"):format(kReadableOperator.notIdentical) .. ("%s\n"):format(Array.join(actualLines_, "\n"))
end
if i >= 5 then
end_ = ("\n%s...%s%s"):format(blue, white, end_)
skipped = true
end
if other ~= "" then
end_ = ("\n  %s%s"):format(other, end_)
other = ""
end
local printedLines = 0
local identical = 0
local msg = kReadableOperator[operator] .. ("\n%s+ actual%s %s- expected%s"):format(green, white, red, white)
local skippedMsg = (" %s...%s Lines skipped"):format(blue, white)
local lines = actualLines
local plusMinus = ("%s+%s"):format(green, white)
local maxLength = #expectedLines
if #actualLines < maxLines then
lines = expectedLines
plusMinus = ("%s-%s"):format(red, white)
maxLength = #actualLines
end
for ii = 1, maxLines do
i = ii
if maxLength < ii then
if identical > 2 then
if identical > 3 then
if identical > 4 then
if identical == 5 then
res ..= ("\n  %s"):format(lines[(ii - 3)])
printedLines += 1
else
res ..= ("\n%s...%s"):format(blue, white)
skipped = true
end
end
res ..= ("\n  %s"):format(lines[(ii - 2)])
printedLines += 1
end
res ..= ("\n  %s"):format(lines[(ii - 1)])
printedLines += 1
end
identical = 0
if lines == actualLines then
res ..= ("\n%s %s"):format(plusMinus, lines[ii])
else
other ..= ("\n%s %s"):format(plusMinus, lines[ii])
end
printedLines += 1
else
local expectedLine = expectedLines[ii]
local actualLine = actualLines[ii]
local divergingLines = actualLine ~= expectedLine
and (
not Boolean.toJSBoolean(String.endsWith(actualLine, ","))
or String.slice(actualLine, 0, -1) ~= expectedLine
)
if
divergingLines
and String.endsWith(expectedLine, ",")
and String.slice(expectedLine, 0, -1) == actualLine
then
divergingLines = false
actualLine ..= ","
end
if divergingLines then
if identical > 2 then
if identical > 3 then
if identical > 4 then
if identical == 5 then
res ..= ("\n  %s"):format(actualLines[ii - 3])
printedLines += 1
else
res ..= ("\n%s...%s"):format(blue, white)
skipped = true
end
end
res ..= ("\n  %s"):format(actualLines[ii - 2])
printedLines += 1
end
res ..= ("\n  %s"):format(actualLines[ii - 1])
printedLines += 1
end
identical = 0
res ..= ("\n%s+%s %s"):format(green, white, actualLine)
other ..= ("\n%s-%s %s"):format(red, white, expectedLine)
printedLines += 2
else
res ..= other
other = ""
identical += 1
if identical <= 2 then
res ..= ("\n  %s"):format(actualLine)
printedLines += 1
end
end
end
if printedLines > 50 and ii < maxLines - 2 then
return ("%s%s\n%s\n%s...%s%s\n"):format(msg, skippedMsg, res, blue, white, other)
.. ("%s...%s"):format(blue, white)
end
end
return ("%s%s\n%s%s%s%s"):format(msg, if skipped then skippedMsg else "", res, other, end_, indicator)
end
type AssertionError = Error & {
actual: any,
expected: any,
operator: string?,
generatedMessage: boolean,
code: "ERR_ASSERTION",
toString: (self: AssertionError) -> any,
}
type AssertionErrorStatics = {
new: (options: AssertionErrorOptions) -> AssertionError,
__index: AssertionError,
__tostring: (self: AssertionError) -> string,
}
local AssertionError: AssertionError & AssertionErrorStatics = (
setmetatable({}, { __index = Error }) :: any
) :: AssertionError & AssertionErrorStatics
AssertionError.__index = AssertionError
AssertionError.__tostring = function(self: AssertionError)
return self:toString()
end
type AssertionErrorOptions = {
message: string?,
actual: any?,
expected: any?,
operator: string?,
stackStartFn: Function?,
}
function AssertionError.new(options: AssertionErrorOptions): AssertionError
local self: AssertionError
local message, operator, stackStartFn =
options.message,
options.operator,
options.stackStartFn
local actual, expected = options.actual, options.expected
if message ~= nil then
self = (setmetatable(Error.new(tostring(message)), AssertionError) :: any) :: AssertionError
else
if process.stderr.isTTY then
if process.stderr:hasColors() then
blue = "\u{001b}[34m"
green = "\u{001b}[32m"
white = "\u{001b}[39m"
red = "\u{001b}[31m"
else
blue = ""
green = ""
white = ""
red = ""
end
end
if
typeof(actual) == "table"
and actual ~= nil
and typeof(expected) == "table"
and expected ~= nil
and Array.indexOf(Object.keys(actual), "stack") ~= -1
and instanceof(actual, Error)
and Array.indexOf(Object.keys(expected), "stack") ~= -1
and instanceof(expected, Error)
then
actual = copyError(actual)
expected = copyError(expected)
end
if operator == "deepStrictEqual" or operator == "strictEqual" then
self = (
setmetatable(Error.new(createErrDiff(actual, expected, operator)), AssertionError) :: any
) :: AssertionError
elseif operator == "notDeepStrictEqual" or operator == "notStrictEqual" then
local base = kReadableOperator[operator]
local res = String.split(inspectValue(actual), "\n")
if
operator == "notStrictEqual"
and (typeof(actual) == "table" and actual ~= nil or typeof(actual) == "function")
then
base = kReadableOperator.notStrictEqualObject
end
if #res > 50 then
res[47] = ("%s...%s"):format(blue, white)
while #res > 47 do
table.remove(res)
end
end
if #res == 1 then
self = (
setmetatable(
Error.new(("%s%s%s"):format(base, if string.len(res[1]) > 5 then "\n\n" else " ", res[1])),
AssertionError
) :: any
) :: AssertionError
else
self = (
setmetatable(Error.new(("%s\n\n%s\n"):format(base, Array.join(res, "\n"))), AssertionError) :: any
) :: AssertionError
end
else
local res = inspectValue(actual)
local other = inspectValue(expected)
local knownOperator = kReadableOperator[tostring(operator)]
if operator == "notDeepEqual" and res == other then
res = ("%s\n\n%s"):format(knownOperator, res)
if string.len(res) > 1024 then
res = ("%s..."):format(String.slice(res, 0, 1021))
end
self = (setmetatable(Error.new(res), AssertionError) :: any) :: AssertionError
else
if string.len(res) > 512 then
res = ("%s..."):format(String.slice(res, 0, 509))
end
if string.len(other) > 512 then
other = ("%s..."):format(String.slice(other, 0, 509))
end
if operator == "deepEqual" then
res = ("%s\n\n%s\n\nshould loosely deep-equal\n\n"):format(knownOperator, res)
else
local newOp = kReadableOperator[("%sUnequal"):format(tostring(operator))]
if Boolean.toJSBoolean(newOp) then
res = ("%s\n\n%s\n\nshould not loosely deep-equal\n\n"):format(newOp, res)
else
other = (" %s %s"):format(tostring(operator), other)
end
end
self = (setmetatable(Error.new(("%s%s"):format(res, other)), AssertionError) :: any) :: AssertionError
end
end
end
self.generatedMessage = not Boolean.toJSBoolean(message)
self.name = "AssertionError [ERR_ASSERTION]"
self.code = "ERR_ASSERTION"
self.actual = actual
self.expected = expected
self.operator = operator
ErrorCaptureStackTrace(self, stackStartFn or AssertionError.new)
self.name = "AssertionError"
return (self :: any) :: AssertionError
end
function AssertionError:toString()
return ("%s [%s]: %s"):format(self.name, self.code, self.message)
end
AssertionError.name = "AssertionError"
return { AssertionError = AssertionError }
end
end)())
__register("LuauPolyfill/AssertionError/init", (function()
local script = __makeProxy({"LuauPolyfill","AssertionError"})
return function()
local AssertionErrorModule = __require(script["AssertionError.global"])
type AssertionError = AssertionErrorModule.AssertionError
return AssertionErrorModule.AssertionError
end
end)())
__register("LuauPolyfill/encodeURIComponent", (function()
local script = __makeProxy({"LuauPolyfill","encodeURIComponent"})
return function()
local HttpService = game:GetService("HttpService")
local root = script.Parent
local Packages = root.Parent
local String = __require(Packages.String)
local charCodeAt = String.charCodeAt
local Error = __require(script.Parent.Error)
local function encodeURIComponent(value: string): string
local valueLength = utf8.len(value)
if valueLength == 0 or valueLength == nil then
return ""
end
local check = charCodeAt(value, 1)
if valueLength == 1 then
if check == 0xD800 then
error(Error.new("URI malformed"))
end
if check == 0xDFFF then
error(Error.new("URI malformed"))
end
end
if check >= 0xDC00 and check < 0xDFFF then
error(Error.new("URI malformed"))
end
local encoded = HttpService:UrlEncode(value)
local result = encoded
:gsub("%%2D", "-")
:gsub("%%5F", "_")
:gsub("%%2E", ".")
:gsub("%%21", "!")
:gsub("%%7E", "~")
:gsub("%%2A", "*")
:gsub("%%27", "'")
:gsub("%%28", "(")
:gsub("%%29", ")")
return result
end
return encodeURIComponent
end
end)())
__register("LuauPolyfill/Error/Error.global", (function()
local script = __makeProxy({"LuauPolyfill","Error","Error.global"})
return function()
local LuauPolyfill = script.Parent.Parent
local Packages = LuauPolyfill.Parent
local types = __require(Packages.ES7Types)
type Function = types.Function
type Error = { name: string, message: string, stack: string? }
type Error_private = Error & { __stack: string? }
local Error = {}
local DEFAULT_NAME = "Error"
Error.__index = Error
Error.__tostring = function(self)
return getmetatable(Error :: any).__tostring(self)
end
local function __createError(message: string?): Error
local self = (setmetatable({
name = DEFAULT_NAME,
message = message or "",
}, Error) :: any) :: Error
Error.__captureStackTrace(self, 4)
return self
end
function Error.new(message: string?): Error
return __createError(message)
end
function Error.captureStackTrace(err: Error, options: Function?)
Error.__captureStackTrace(err, 3, options)
end
function Error.__captureStackTrace(err_: Error, level: number, options: Function?)
local err = err_ :: Error_private
if typeof(options) == "function" then
local stack = debug.traceback(nil, level)
local functionName: string = debug.info(options, "n")
local sourceFilePath: string = debug.info(options, "s")
local espacedSourceFilePath = string.gsub(sourceFilePath, "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
local stacktraceLinePattern = espacedSourceFilePath .. ":%d* function " .. functionName
local beg = string.find(stack, stacktraceLinePattern)
local end_ = nil
if beg ~= nil then
beg, end_ = string.find(stack, "\n", beg + 1)
end
if end_ ~= nil then
stack = string.sub(stack, end_ + 1)
end
err.__stack = stack
else
err.__stack = debug.traceback(nil, level)
end
Error.__recalculateStacktrace(err)
end
function Error.__recalculateStacktrace(err_: Error)
local err = err_ :: Error_private
local message = err.message
local name = err.name or DEFAULT_NAME
local errName = name .. (if message ~= nil and message ~= "" then (": " .. message) else "")
local stack = if err.__stack then err.__stack else ""
err.stack = errName .. "\n" .. stack
end
return setmetatable(Error, {
__call = function(_, ...)
return __createError(...)
end,
__tostring = function(self)
if self.name ~= nil then
if self.message and self.message ~= "" then
return string.format("%s: %s", tostring(self.name), tostring(self.message))
end
return tostring(self.name)
end
return tostring(DEFAULT_NAME)
end,
})
end
end)())
__register("LuauPolyfill/Error/init", (function()
local script = __makeProxy({"LuauPolyfill","Error"})
return function()
local Error = __require(script["Error.global"])
type Error = Error.Error
return Error
end
end)())
__register("LuauPolyfill/extends", (function()
local script = __makeProxy({"LuauPolyfill","extends"})
return function()
return function(parent, childName, constructor)
local Child = {}
Child.__index = Child
Child.__tostring = function(self)
return getmetatable(parent).__tostring(self)
end
local mt = {}
Child.new = function(...)
local self = {}
constructor(self, ...)
return setmetatable(self, Child)
end
if typeof(getmetatable(parent)) == "table" and getmetatable(parent).__call then
mt.__call = function(_, ...)
return Child.new(...)
end
end
mt.__index = parent
mt.__tostring = function(self)
if self == Child then
return tostring(childName)
end
return getmetatable(parent).__tostring(self)
end
setmetatable(Child, mt)
return Child
end
end
end)())
__register("LuauPolyfill/init", (function()
local script = __makeProxy({"LuauPolyfill"})
return function()
local Packages = script.Parent
local Boolean = __require(Packages.Boolean)
local Collections = __require(Packages.Collections)
local Console = __require(Packages.Console)
local Math = __require(Packages.Math)
local Number = __require(Packages.Number)
local String = __require(Packages.String)
local Symbol = __require(Packages.Symbol)
local Timers = __require(Packages.Timers)
local types = __require(Packages.ES7Types)
local AssertionError = __require(script.AssertionError)
local Error = __require(script.Error)
local PromiseModule = __require(script.Promise)
local extends = __require(script.extends)
local instanceof = __require(Packages.InstanceOf)
type Array<T> = types.Array<T>
type AssertionError = AssertionError.AssertionError
type Error = Error.Error
type Map<T, V> = types.Map<T, V>
type Object = types.Object
type PromiseLike<T> = PromiseModule.PromiseLike<T>
type Promise<T> = PromiseModule.Promise<T>
type Set<T> = types.Set<T>
type Symbol = Symbol.Symbol
type Timeout = Timers.Timeout
type Interval = Timers.Interval
type WeakMap<T, V> = Collections.WeakMap<T, V>
return {
Array = Collections.Array,
AssertionError = AssertionError,
Boolean = Boolean,
console = Console,
Error = Error,
extends = extends,
instanceof = instanceof,
Math = Math,
Number = Number,
Object = Collections.Object,
Map = Collections.Map,
coerceToMap = Collections.coerceToMap,
coerceToTable = Collections.coerceToTable,
Set = Collections.Set,
WeakMap = Collections.WeakMap,
String = String,
Symbol = Symbol,
setTimeout = Timers.setTimeout,
clearTimeout = Timers.clearTimeout,
setInterval = Timers.setInterval,
clearInterval = Timers.clearInterval,
util = {
inspect = Collections.inspect,
},
}
end
end)())
__register("LuauPolyfill/Promise", (function()
local script = __makeProxy({"LuauPolyfill","Promise"})
return function()
type PromiseLike<T> = {
andThen: (
self: PromiseLike<T>,
resolve: ((T) -> ...(nil | T | PromiseLike<T>))?,
reject: ((any) -> ...(nil | T | PromiseLike<T>))?
) -> PromiseLike<T>,
}
type PromiseStatus = "Started" | "Resolved" | "Rejected" | "Cancelled"
type Promise<T> = {
andThen: (
self: Promise<T>,
resolve: ((T) -> ...(nil | T | PromiseLike<T>))?,
reject: ((any) -> ...(nil | T | PromiseLike<T>))?
) -> Promise<T>,
catch: (Promise<T>, ((any) -> ...(nil | T | PromiseLike<nil>))) -> Promise<T>,
onCancel: (Promise<T>, () -> ()?) -> boolean,
expect: (Promise<T>) -> ...T,
await: (Promise<T>) -> (boolean, ...(T | any)),
getStatus: (self: Promise<T>) -> PromiseStatus,
awaitStatus: (self: Promise<T>) -> (PromiseStatus, ...(T | any)),
}
return {}
end
end)())
__register("ReactGlobals/init", (function()
local script = __makeProxy({"ReactGlobals"})
return function()
local ReactGlobals = __require(script["ReactGlobals.global"])
return ReactGlobals
end
end)())
__register("ReactGlobals/ReactGlobals.global", (function()
local script = __makeProxy({"ReactGlobals","ReactGlobals.global"})
return function()
local Packages = script.Parent.Parent
local SafeFlags = __require(Packages.SafeFlags)
local FFlagReactIsolatedGlobalsEnabled =
SafeFlags.createGetFFlag("ReactIsolatedGlobalsEnabled")()
if not FFlagReactIsolatedGlobalsEnabled then
return _G :: ReactGlobals
end
type DevToolsHook = any
type DevToolsAttach = any
type DevToolsComponentFilters = { any }
local function loadFromGlobal<T>(globalValueKey: string, defaultValue: T): T
local globalValue = _G[globalValueKey]
if globalValue ~= nil then
return globalValue
end
return defaultValue
end
local ReactGlobals = {
__DEV__ = loadFromGlobal("__DEV__", false),
__PROFILE__ = loadFromGlobal("__PROFILE__", false),
__EXPERIMENTAL__ = loadFromGlobal("__EXPERIMENTAL__", false),
__DEBUG__ = loadFromGlobal("__DEBUG__", false),
__YOLO__ = loadFromGlobal("__YOLO__", false),
__DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ = loadFromGlobal(
"__DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__",
false
),
__REACT_DEVTOOLS_GLOBAL_HOOK__ = loadFromGlobal(
"__REACT_DEVTOOLS_GLOBAL_HOOK__",
nil :: DevToolsHook?
),
__REACT_DEVTOOLS_ATTACH__ = loadFromGlobal(
"__REACT_DEVTOOLS_ATTACH__",
nil :: DevToolsAttach?
),
__REACT_DEVTOOLS_APPEND_COMPONENT_STACK__ = loadFromGlobal(
"__REACT_DEVTOOLS_APPEND_COMPONENT_STACK__",
false
),
__REACT_DEVTOOLS_BREAK_ON_CONSOLE_ERRORS__ = loadFromGlobal(
"__REACT_DEVTOOLS_BREAK_ON_CONSOLE_ERRORS__",
false
),
__REACT_DEVTOOLS_COMPONENT_FILTERS__ = loadFromGlobal(
"__REACT_DEVTOOLS_COMPONENT_FILTERS__",
nil :: DevToolsComponentFilters?
),
__LOCALSTORAGE__ = loadFromGlobal("__LOCALSTORAGE__", nil :: any?),
__SESSIONSTORAGE__ = loadFromGlobal("__SESSIONSTORAGE__", nil :: any?),
__COMPAT_WARNINGS__ = loadFromGlobal("__COMPAT_WARNINGS__", false),
__TESTEZ_RUNNING_TEST__ = loadFromGlobal("__TESTEZ_RUNNING_TEST__", false),
__ROACT_17_MOCK_SCHEDULER__ = loadFromGlobal("__ROACT_17_MOCK_SCHEDULER__", false),
__ROACT_17_INLINE_ACT__ = loadFromGlobal("__ROACT_17_INLINE_ACT__", false),
}
type ReactGlobals = typeof(ReactGlobals)
return ReactGlobals
end
end)())
__register("Shared/checkPropTypes", (function()
local script = __makeProxy({"Shared","checkPropTypes"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local LuauPolyfill = __require(Packages.LuauPolyfill)
local Error = LuauPolyfill.Error
type Object = LuauPolyfill.Object
type Function = (...any) -> ...any
local console = __require(script.Parent.console)
local loggedTypeFailures = {}
local ReactComponentStackFrame = __require(script.Parent.ReactComponentStackFrame)
local describeUnknownElementTypeFrameInDEV =
ReactComponentStackFrame.describeUnknownElementTypeFrameInDEV
local ReactSharedInternals = __require(script.Parent.ReactSharedInternals)
local describeError = __require(script.Parent["ErrorHandling.roblox"]).describeError
local ReactDebugCurrentFrame = ReactSharedInternals.ReactDebugCurrentFrame
local function setCurrentlyValidatingElement(element: any?)
if ReactGlobals.__DEV__ then
if element then
local owner = element._owner
local stack = describeUnknownElementTypeFrameInDEV(
element.type,
element._source,
if owner ~= nil then owner.type else nil
);
(ReactDebugCurrentFrame.setExtraStackFrame :: any)(stack)
else
(ReactDebugCurrentFrame.setExtraStackFrame :: any)(nil)
end
end
end
local function checkPropTypes<P>(
propTypes: Object?,
validateProps: (P) -> (boolean, string?)?,
props: P,
location: string,
componentName: string?,
element: any?
): ()
if
ReactGlobals.__DEV__
or ReactGlobals.__DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__
then
if propTypes and validateProps then
console.warn(
"You've defined both propTypes and validateProps on "
.. (componentName or "a component")
)
end
if validateProps then
if typeof(validateProps) ~= "function" then
console.error(
("validateProps must be a function, but it is a %s.\nCheck the definition of the component %q."):format(
typeof(validateProps),
componentName or ""
)
)
else
local success, failureReason = validateProps(props)
if not success then
failureReason = failureReason
or "<Validator function did not supply a message>"
local message = string.format(
"validateProps failed on a %s type in %s: %s",
location,
componentName or "<UNKNOWN Component>",
tostring(failureReason)
)
error(message)
end
end
end
if propTypes then
assert(typeof(propTypes) == "table", "propTypes needs to be a table")
for typeSpecName, _ in propTypes do
local _, result = xpcall(function()
if typeof(propTypes[typeSpecName]) ~= "function" then
local err = Error.new(
(componentName or "React class")
.. ": "
.. location
.. " type `"
.. typeSpecName
.. "` is invalid; "
.. "it must be a function, usually from the `prop-types` package, but received `"
.. typeof(propTypes[typeSpecName])
.. "`."
.. "This often happens because of typos such as `PropTypes.function` instead of `PropTypes.func`."
)
err.name = "Invariant Violation"
error(err)
end
return (propTypes[typeSpecName] :: Function)(
props,
typeSpecName,
componentName,
location,
nil,
"SECRET_DO_NOT_PASS_THIS_OR_YOU_WILL_BE_FIRED"
)
end, describeError)
local isErrorObject = typeof(result) == "table"
if result ~= nil and not isErrorObject then
setCurrentlyValidatingElement(element)
console.error(string.format(
"%s: type specification of %s"
.. " `%s` is invalid; the type checker "
.. "function must return `nil` or an `Error` but returned a %s. "
.. "You may have forgotten to pass an argument to the type checker "
.. "creator (arrayOf, instanceOf, objectOf, oneOf, oneOfType, and "
.. "shape all require an argument).",
componentName or "React class",
location,
typeSpecName,
typeof(result)
))
setCurrentlyValidatingElement(nil)
end
if
isErrorObject
and loggedTypeFailures[(result :: any).message] == nil
then
loggedTypeFailures[tostring((result :: any).message)] = true
setCurrentlyValidatingElement(element)
console.warn(
string.format(
"Failed %s type: %s",
location,
tostring((result :: any).message)
)
)
setCurrentlyValidatingElement(nil)
end
end
end
end
end
return checkPropTypes
end
end)())
__register("Shared/console", (function()
local script = __makeProxy({"Shared","console"})
return function()
local Shared = script.Parent
local Packages = Shared.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local LuauPolyfill = __require(Packages.LuauPolyfill)
local console = LuauPolyfill.console
local consoleWithStackDev = __require(Shared.consoleWithStackDev)
if ReactGlobals.__DEV__ then
local newConsole = setmetatable({
warn = consoleWithStackDev.warn,
error = consoleWithStackDev.error,
}, {
__index = console,
})
return newConsole
end
return console
end
end)())
__register("Shared/ConsolePatchingDev.roblox", (function()
local script = __makeProxy({"Shared","ConsolePatchingDev.roblox"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local console = __require(script.Parent.console)
local disabledDepth = 0
local prevLog
local prevInfo
local prevWarn
local prevError
local prevGroup
local prevGroupCollapsed
local prevGroupEnd
local disabledLog = function() end
local exports = {}
exports.disabledLog = disabledLog
exports.disableLogs = function()
if ReactGlobals.__DEV__ then
if disabledDepth == 0 then
prevLog = console.log
prevInfo = console.info
prevWarn = console.warn
prevError = console.error
prevGroup = console.group
prevGroupCollapsed = console.groupCollapsed
prevGroupEnd = console.groupEnd
console.info = disabledLog
console.log = disabledLog
console.warn = disabledLog
console.error = disabledLog
console.group = disabledLog
console.groupCollapsed = disabledLog
console.groupEnd = disabledLog
end
disabledDepth = disabledDepth + 1
end
end
exports.reenableLogs = function()
if ReactGlobals.__DEV__ then
disabledDepth = disabledDepth - 1
if disabledDepth == 0 then
console.log = prevLog
console.info = prevInfo
console.warn = prevWarn
console.error = prevError
console.group = prevGroup
console.groupCollapsed = prevGroupCollapsed
console.groupEnd = prevGroupEnd
end
if disabledDepth < 0 then
console.error(
"disabledDepth fell below zero. "
.. "This is a bug in React. Please file an issue."
)
end
end
end
return exports
end
end)())
__register("Shared/consoleWithStackDev", (function()
local script = __makeProxy({"Shared","consoleWithStackDev"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local LuauPolyfill = __require(Packages.LuauPolyfill)
local console = LuauPolyfill.console
local Array = LuauPolyfill.Array
local ReactSharedInternals = __require(script.Parent.ReactSharedInternals)
local printWarning
local exports = {}
exports.warn = function(format, ...)
if ReactGlobals.__DEV__ then
printWarning("warn", format, { ... })
end
end
exports.error = function(format, ...)
if ReactGlobals.__DEV__ then
printWarning("error", format, { ... })
end
end
function printWarning(level, format, args)
if ReactGlobals.__DEV__ then
local ReactDebugCurrentFrame = ReactSharedInternals.ReactDebugCurrentFrame
local stack = ReactDebugCurrentFrame.getStackAddendum()
if stack ~= "" then
format ..= "%s"
args = Array.slice(args, 1)
table.insert(args, stack)
end
local argsWithFormat = Array.map(args, tostring)
table.insert(argsWithFormat, 1, "Warning: " .. format)
console[level](unpack(argsWithFormat))
end
end
return exports
end
end)())
__register("Shared/enqueueTask.roblox", (function()
local script = __makeProxy({"Shared","enqueueTask.roblox"})
return function()
local Packages = script.Parent.Parent
local LuauPolyfill = __require(Packages.LuauPolyfill)
local setTimeout = LuauPolyfill.setTimeout
return function(task)
return setTimeout(task, 0)
end
end
end)())
__register("Shared/ErrorHandling.roblox", (function()
local script = __makeProxy({"Shared","ErrorHandling.roblox"})
return function()
local Packages = script.Parent.Parent
local LuauPolyfill = __require(Packages.LuauPolyfill)
type Error = LuauPolyfill.Error
type Object = LuauPolyfill.Object
type Array<T> = LuauPolyfill.Array<T>
local Error = LuauPolyfill.Error
local inspect = LuauPolyfill.util.inspect
local ReactFeatureFlags = __require(script.Parent.ReactFeatureFlags)
local filterInternalStackFrames = ReactFeatureFlags.filterInternalStackFrames
local DIVIDER = "\n------ Error caught by React ------\n"
local REACT_PACKAGE_NAMES = {
"React",
"ReactDevtoolsShared",
"ReactNoopRenderer",
"ReactReconciler",
"ReactRefresh",
"ReactRoblox",
"RoactCompat",
"Scheduler",
"Shared",
}
local reactPackagePrefixes: { string }? = nil
local function getReactPackagePrefixes(): { string }
if reactPackagePrefixes then
return reactPackagePrefixes
end
local reactPackagePrefixes_ = {}
for _, packageName in REACT_PACKAGE_NAMES do
local package = Packages.Parent:FindFirstChild(packageName)
if package then
local packagePath = package:GetFullName():gsub("^game%.", "")
table.insert(reactPackagePrefixes_, packagePath)
end
end
reactPackagePrefixes = reactPackagePrefixes_
return reactPackagePrefixes_
end
local function isInternalFrame(source: string): boolean
local prefixes = getReactPackagePrefixes()
for _, prefix in prefixes do
if string.sub(source, 1, #prefix) == prefix then
return true
end
end
return false
end
local function buildStackString(level: number): string
local stack = ""
local handledFirstSource = false
local shouldFilter = false
for i = level + 1, math.huge do
local source, line, fnName = debug.info(i, "sln")
if not source then
break
end
if source == "[C]" then
continue
end
if not handledFirstSource then
shouldFilter = not isInternalFrame(source)
handledFirstSource = true
end
if shouldFilter and isInternalFrame(source) then
continue
end
stack ..= `{source}:{line} function {fnName or "?"}\n`
end
stack = string.gsub(stack, "\n$", "")
return stack
end
local function describeError(e: string | Error): Error
if typeof(e) == "string" then
local _, endOfStackFrame = string.find(e, ":[%d]+: ")
local message = if endOfStackFrame then string.sub(e, endOfStackFrame + 1) else e
local err = LuauPolyfill.Error.new(message)
if filterInternalStackFrames then
err.stack = buildStackString(2)
else
err.stack = debug.traceback(nil, 2)
end
return err
end
return e :: Error
end
local function errorToString(error_: Error | Object | string | Array<any>): string
local errorString
if typeof(error_) == "table" then
if (error_ :: Error).message and (error_ :: Error).stack then
errorString = DIVIDER
.. (error_ :: Error).message
.. DIVIDER
.. tostring((error_ :: Error).stack)
else
errorString = inspect(error_)
end
else
errorString = inspect(error_)
end
return errorString
end
local function parseReactError(error_: string): (Error, string)
local split = string.split(error_, DIVIDER)
if #split == 3 then
local rethrow, message, stack = table.unpack(split)
local newError = Error.new(message)
newError.stack = stack
return newError, rethrow
else
local newError = Error.new(error_)
newError.stack = nil
return newError, ""
end
end
return {
describeError = describeError,
errorToString = errorToString,
parseReactError = parseReactError,
__ERROR_DIVIDER = DIVIDER,
}
end
end)())
__register("Shared/ExecutionEnvironment", (function()
local script = __makeProxy({"Shared","ExecutionEnvironment"})
return function()
local exports = {}
exports.canUseDOM = function()
return false
end
return exports
end
end)())
__register("Shared/flowtypes.roblox", (function()
local script = __makeProxy({"Shared","flowtypes.roblox"})
return function()
local Packages = script.Parent.Parent
local LuauPolyfill = __require(Packages.LuauPolyfill)
type Error = LuauPolyfill.Error
type Array<T> = LuauPolyfill.Array<T>
type Object = { [string]: any }
type Source = {
fileName: string,
lineNumber: number,
}
type React_Node =
nil
| boolean
| number
| string
| React_Element<any>
| Array<React_Node?>
| { [string]: React_Node?, UNIQUE_TAG: any? }
type React_Element<ElementType> = {
type: ElementType,
props: React_ElementProps<ElementType>?,
key: React_Key | nil,
ref: any,
}
type React_PureComponent<Props, State = nil> = React_Component<Props, State>
type React_AbstractComponent<Config, T> =
React_ForwardRefComponent<Config, T>
| React_MemoComponent<Config, T>
type React_BaseAbstractComponent<Config, T> = {
["$$typeof"]: number,
displayName: string?,
defaultProps: Config?,
name: string?,
}
type React_ForwardRefComponent<Config, Instance> = React_BaseAbstractComponent<
Config,
Instance
> & {
render: (props: Config, ref: React_Ref<Instance>) -> React_Node,
[string]: any,
}
type React_MemoComponent<Config, T> = React_BaseAbstractComponent<Config, T> & {
type: React_StatelessFunctionalComponent<Config>,
compare: ((oldProps: Config, newProps: Config) -> boolean)?,
}
type React_ElementConfig<C> = Object
type React_Component<Props, State = nil> = {
props: Props,
state: State,
setState: (
self: React_Component<Props, State>,
partialState: State | ((State, Props) -> State?),
callback: (() -> ())?
) -> (),
forceUpdate: (self: React_Component<Props, State>, callback: (() -> ())?) -> (),
init: ((
self: React_Component<Props, State>,
props: Props,
context: any?
) -> ())?,
render: (self: React_Component<Props, State>) -> React_Node,
componentWillMount: ((self: React_Component<Props, State>) -> ())?,
UNSAFE_componentWillMount: ((self: React_Component<Props, State>) -> ())?,
componentDidMount: ((self: React_Component<Props, State>) -> ())?,
componentWillReceiveProps: ((
self: React_Component<Props, State>,
nextProps: Props,
nextContext: any
) -> ())?,
UNSAFE_componentWillReceiveProps: ((
self: React_Component<Props, State>,
nextProps: Props,
nextContext: any
) -> ())?,
shouldComponentUpdate: ((
self: React_Component<Props, State>,
nextProps: Props,
nextState: State,
nextContext: any
) -> boolean)?,
componentWillUpdate: ((
self: React_Component<Props, State>,
nextProps: Props,
nextState: State,
nextContext: any
) -> ())?,
UNSAFE_componentWillUpdate: ((
self: React_Component<Props, State>,
nextProps: Props,
nextState: State,
nextContext: any
) -> ())?,
componentDidUpdate: ((
self: React_Component<Props, State>,
prevProps: Props,
prevState: State,
prevContext: any
) -> ())?,
componentWillUnmount: ((self: React_Component<Props, State>) -> ())?,
componentDidCatch: ((
self: React_Component<Props, State>,
error: Error,
info: {
componentStack: string,
}
) -> ())?,
getDerivedStateFromProps: ((props: Props, state: State) -> State?)?,
getDerivedStateFromError: ((error: Error) -> State?)?,
getSnapshotBeforeUpdate: ((props: Props, state: State) -> any)?,
__refs: Object,
__updater: any,
context: any,
getChildContext: (self: React_Component<Props, State>) -> any,
__componentName: string,
displayName: string?,
name: string?,
childContextTypes: any?,
contextTypes: any?,
propTypes: any?,
validateProps: ((Props) -> (boolean, string?))?,
defaultProps: Props?,
[string]: any,
}
type React_StatelessFunctionalComponent<Props> = (
props: Props,
context: any
) -> React_Node
type React_ComponentType<Config> = React_Component<Config, any>
type React_ElementType = string | React_Component<any, any>
type React_ElementProps<ElementType> = {
ref: React_Ref<ElementType>?,
key: React_Key?,
__source: Source?,
children: any?,
}
type React_ElementRef<C> = C
type React_Ref<ElementType> =
{ current: React_ElementRef<ElementType> | nil }
| ((React_ElementRef<ElementType> | nil) -> ())
type React_Context<T> = {
Provider: React_ComponentType<{ value: T, children: React_Node? }>,
Consumer: React_ComponentType<{ children: (value: T) -> React_Node? }>,
}
type React_Portal = any
type React_Key = string | number
return {}
end
end)())
__register("Shared/formatProdErrorMessage", (function()
local script = __makeProxy({"Shared","formatProdErrorMessage"})
return function()
local HttpService = game:GetService("HttpService")
local function formatProdErrorMessage(code, ...)
local url = "https://reactjs.org/docs/error-decoder.html?invariant=" .. tostring(code)
local argsLength = select("#", ...)
for i = 1, argsLength, 1 do
url = url .. "&args[]=" .. HttpService:UrlEncode(select(i, ...))
end
return string.format(
"Minified React error #%d; visit %s for the full message or "
.. "use the non-minified dev environment for full errors and additional "
.. "helpful warnings.",
code,
url
)
end
return formatProdErrorMessage
end
end)())
__register("Shared/getComponentName", (function()
local script = __makeProxy({"Shared","getComponentName"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
type Function = (...any) -> ...any
local console = __require(script.Parent.console)
type LazyComponent<T, P> = {
["$$typeof"]: number,
_payload: P,
_init: (payload: P) -> T,
}
local ReactSymbols = __require(script.Parent.ReactSymbols)
local REACT_CONTEXT_TYPE = ReactSymbols.REACT_CONTEXT_TYPE
local REACT_FORWARD_REF_TYPE = ReactSymbols.REACT_FORWARD_REF_TYPE
local REACT_FRAGMENT_TYPE = ReactSymbols.REACT_FRAGMENT_TYPE
local REACT_PORTAL_TYPE = ReactSymbols.REACT_PORTAL_TYPE
local REACT_MEMO_TYPE = ReactSymbols.REACT_MEMO_TYPE
local REACT_PROFILER_TYPE = ReactSymbols.REACT_PROFILER_TYPE
local REACT_PROVIDER_TYPE = ReactSymbols.REACT_PROVIDER_TYPE
local REACT_STRICT_MODE_TYPE = ReactSymbols.REACT_STRICT_MODE_TYPE
local REACT_SUSPENSE_TYPE = ReactSymbols.REACT_SUSPENSE_TYPE
local REACT_SUSPENSE_LIST_TYPE = ReactSymbols.REACT_SUSPENSE_LIST_TYPE
local REACT_LAZY_TYPE = ReactSymbols.REACT_LAZY_TYPE
local REACT_BLOCK_TYPE = ReactSymbols.REACT_BLOCK_TYPE
local ReactTypes = __require(script.Parent.ReactTypes)
type ReactContext<T> = ReactTypes.ReactContext<T>
type ReactProviderType<T> = ReactTypes.ReactProviderType<T>
local describeError = __require(script.Parent["ErrorHandling.roblox"]).describeError
local function getWrappedName(outerType: any, innerType: any, wrapperName: string): string
local functionName = "<function>"
if typeof(innerType) == "table" then
functionName = innerType.displayName or innerType.name or ""
end
return outerType.displayName
or (
functionName ~= "" and string.format("%s(%s)", wrapperName, functionName)
or wrapperName
)
end
local function getContextName(type: ReactContext<any>): string
return type.displayName or "Context"
end
local function getComponentName(type: any): string | nil
if type == nil then
return nil
end
local typeofType = typeof(type)
if ReactGlobals.__DEV__ then
if typeofType == "table" and typeof(type.tag) == "number" then
console.warn(
"Received an unexpected object in getComponentName(). "
.. "This is likely a bug in React. Please file an issue."
)
end
end
if typeofType == "function" then
local name = debug.info((type :: any) :: Function, "n")
if name and string.len(name) > 0 then
return name
else
local fileName, line = debug.info((type :: any) :: Function, "sl")
return string.format("%s:%d", fileName, line)
end
end
if typeofType == "string" then
return (type :: any) :: string
end
if type == REACT_FRAGMENT_TYPE then
return "Fragment"
elseif type == REACT_PORTAL_TYPE then
return "Portal"
elseif type == REACT_PROFILER_TYPE then
return "Profiler"
elseif type == REACT_STRICT_MODE_TYPE then
return "StrictMode"
elseif type == REACT_SUSPENSE_TYPE then
return "Suspense"
elseif type == REACT_SUSPENSE_LIST_TYPE then
return "SuspenseList"
end
if typeofType == "table" then
local typeProp = type["$$typeof"]
if typeProp == REACT_CONTEXT_TYPE then
local context: ReactContext<any> = type :: any
return getContextName(context) .. ".Consumer"
elseif typeProp == REACT_PROVIDER_TYPE then
local provider: ReactProviderType<any> = type :: any
return getContextName(provider._context) .. ".Provider"
elseif typeProp == REACT_FORWARD_REF_TYPE then
return getWrappedName(type, type.render, "ForwardRef")
elseif typeProp == REACT_MEMO_TYPE then
return getComponentName(type.type)
elseif typeProp == REACT_BLOCK_TYPE then
return getComponentName(type._render)
elseif typeProp == REACT_LAZY_TYPE then
local lazyComponent: LazyComponent<any, any> = type :: any
local payload = lazyComponent._payload
local init = lazyComponent._init
local ok, result = xpcall(init, describeError, payload)
if ok then
return getComponentName(result)
else
return nil
end
else
if type.displayName then
return type.displayName
end
if type.name then
return type.name
end
local mt = getmetatable(type)
if mt and rawget(mt, "__tostring") then
return tostring(type)
end
end
end
return nil
end
return getComponentName
end
end)())
__register("Shared/init", (function()
local script = __makeProxy({"Shared"})
return function()
local Packages = script.Parent
local LuauPolyfill = __require(Packages.LuauPolyfill)
type Object = LuauPolyfill.Object
local ReactTypes = __require(script.ReactTypes)
local flowtypes = __require(script["flowtypes.roblox"])
local ReactElementType = __require(script.ReactElementType)
local ReactFiberHostConfig = __require(script.ReactFiberHostConfig)
local ReactSharedInternals = __require(script.ReactSharedInternals)
local ErrorHandling = __require(script["ErrorHandling.roblox"])
type ReactEmpty = ReactTypes.ReactEmpty
type ReactFragment = ReactTypes.ReactFragment
type ReactNodeList = ReactTypes.ReactNodeList
type ReactProviderType<T> = ReactTypes.ReactProviderType<T>
type ReactConsumer<T> = ReactTypes.ReactConsumer<T>
type ReactProvider<T> = ReactTypes.ReactProvider<T>
type ReactContext<T> = ReactTypes.ReactContext<T>
type ReactPortal = ReactTypes.ReactPortal
type RefObject<T = any> = ReactTypes.RefObject<T>
type EventPriority = ReactTypes.EventPriority
type ReactFundamentalComponentInstance<C, H> =
ReactTypes.ReactFundamentalComponentInstance<C, H>
type ReactFundamentalImpl<C, H> = ReactTypes.ReactFundamentalImpl<C, H>
type ReactFundamentalComponent<C, H> = ReactTypes.ReactFundamentalComponent<C, H>
type ReactScope = ReactTypes.ReactScope
type ReactScopeQuery = ReactTypes.ReactScopeQuery
type ReactScopeInstance = ReactTypes.ReactScopeInstance
type ReactBinding<T> = ReactTypes.ReactBinding<T>
type ReactBindingUpdater<T> = ReactTypes.ReactBindingUpdater<T>
type MutableSourceVersion = ReactTypes.MutableSourceVersion
type MutableSourceGetSnapshotFn<Source, Snapshot> =
ReactTypes.MutableSourceGetSnapshotFn<Source, Snapshot>
type MutableSourceSubscribeFn<Source, Snapshot> = ReactTypes.MutableSourceSubscribeFn<
Source,
Snapshot
>
type MutableSourceGetVersionFn = ReactTypes.MutableSourceGetVersionFn
type MutableSource<Source> = ReactTypes.MutableSource<Source>
type Wakeable = ReactTypes.Wakeable
type Thenable<R> = ReactTypes.Thenable<R>
type Source = ReactElementType.Source
type ReactElement<P = Object, T = any> = ReactElementType.ReactElement<P, T>
type OpaqueIDType = ReactFiberHostConfig.OpaqueIDType
type Dispatcher = ReactSharedInternals.Dispatcher
type React_Ref<ElementType> = flowtypes.React_Ref<ElementType>
type React_Context<T> = flowtypes.React_Context<T>
type React_AbstractComponent<Config, Instance> = flowtypes.React_AbstractComponent<
Config,
Instance
>
type React_ForwardRefComponent<Config, Instance> =
flowtypes.React_ForwardRefComponent<Config, Instance>
type React_MemoComponent<Config, T> = flowtypes.React_MemoComponent<Config, T>
type React_ComponentType<Config> = flowtypes.React_ComponentType<Config>
type React_PureComponent<Props, State = nil> = flowtypes.React_PureComponent<
Props,
State
>
type React_Component<Props, State> = flowtypes.React_Component<Props, State>
type React_ElementProps<ElementType> = flowtypes.React_ElementProps<ElementType>
type React_StatelessFunctionalComponent<Props> =
flowtypes.React_StatelessFunctionalComponent<Props>
type React_Node = flowtypes.React_Node
type React_Element<ElementType> = flowtypes.React_Element<ElementType>
type React_ElementType = flowtypes.React_ElementType
type React_ElementConfig<C> = flowtypes.React_ElementConfig<C>
type React_ElementRef<C> = flowtypes.React_ElementRef<C>
type React_Portal = flowtypes.React_Portal
type React_Key = flowtypes.React_Key
return {
checkPropTypes = __require(script.checkPropTypes),
console = __require(script.console),
ConsolePatchingDev = __require(script["ConsolePatchingDev.roblox"]),
consoleWithStackDev = __require(script.consoleWithStackDev),
enqueueTask = __require(script["enqueueTask.roblox"]),
ExecutionEnvironment = __require(script.ExecutionEnvironment),
formatProdErrorMessage = __require(script.formatProdErrorMessage),
getComponentName = __require(script.getComponentName),
invariant = __require(script.invariant),
invokeGuardedCallbackImpl = __require(script.invokeGuardedCallbackImpl),
isValidElementType = __require(script.isValidElementType),
objectIs = __require(script.objectIs),
ReactComponentStackFrame = __require(script.ReactComponentStackFrame),
ReactElementType = __require(script.ReactElementType),
ReactErrorUtils = __require(script.ReactErrorUtils),
ReactFeatureFlags = __require(script.ReactFeatureFlags),
ReactInstanceMap = __require(script.ReactInstanceMap),
ReactSharedInternals = ReactSharedInternals,
ReactFiberHostConfig = ReactFiberHostConfig,
ReactSymbols = __require(script.ReactSymbols),
ReactVersion = __require(script.ReactVersion),
shallowEqual = __require(script.shallowEqual),
UninitializedState = __require(script["UninitializedState.roblox"]),
ReactTypes = ReactTypes,
describeError = ErrorHandling.describeError,
errorToString = ErrorHandling.errorToString,
parseReactError = ErrorHandling.parseReactError,
Symbol = __require(script["Symbol.roblox"]),
Type = __require(script["Type.roblox"]),
Change = __require(script.PropMarkers.Change),
Event = __require(script.PropMarkers.Event),
Tag = __require(script.PropMarkers.Tag),
}
end
end)())
__register("Shared/invariant", (function()
local script = __makeProxy({"Shared","invariant"})
return function()
local Packages = script.Parent.Parent
local LuauPolyfill = __require(Packages.LuauPolyfill)
local Error = LuauPolyfill.Error
local function invariant(condition, format, ...)
if not condition then
error(Error(string.format(format, ...)))
end
end
return invariant
end
end)())
__register("Shared/invokeGuardedCallbackImpl", (function()
local script = __makeProxy({"Shared","invokeGuardedCallbackImpl"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local describeError = __require(script.Parent["ErrorHandling.roblox"]).describeError
local function invokeGuardedCallbackProd(reporter, name, func, context, ...)
local ok, result
if not ReactGlobals.__YOLO__ then
if context == nil then
ok, result = xpcall(func, describeError, ...)
else
ok, result = xpcall(func, describeError, context, ...)
end
else
ok = true
if context == nil then
func(...)
else
func(context, ...)
end
end
if not ok then
reporter.onError(result)
end
end
local invokeGuardedCallbackImpl = invokeGuardedCallbackProd
if ReactGlobals.__DEV__ then
end
return invokeGuardedCallbackImpl
end
end)())
__register("Shared/isValidElementType", (function()
local script = __makeProxy({"Shared","isValidElementType"})
return function()
local ReactSymbols = __require(script.Parent.ReactSymbols)
local REACT_CONTEXT_TYPE = ReactSymbols.REACT_CONTEXT_TYPE
local REACT_FORWARD_REF_TYPE = ReactSymbols.REACT_FORWARD_REF_TYPE
local REACT_FRAGMENT_TYPE = ReactSymbols.REACT_FRAGMENT_TYPE
local REACT_PROFILER_TYPE = ReactSymbols.REACT_PROFILER_TYPE
local REACT_PROVIDER_TYPE = ReactSymbols.REACT_PROVIDER_TYPE
local REACT_DEBUG_TRACING_MODE_TYPE = ReactSymbols.REACT_DEBUG_TRACING_MODE_TYPE
local REACT_STRICT_MODE_TYPE = ReactSymbols.REACT_STRICT_MODE_TYPE
local REACT_SUSPENSE_TYPE = ReactSymbols.REACT_SUSPENSE_TYPE
local REACT_MEMO_TYPE = ReactSymbols.REACT_MEMO_TYPE
local REACT_LAZY_TYPE = ReactSymbols.REACT_LAZY_TYPE
local REACT_FUNDAMENTAL_TYPE = ReactSymbols.REACT_FUNDAMENTAL_TYPE
local REACT_BLOCK_TYPE = ReactSymbols.REACT_BLOCK_TYPE
local REACT_SERVER_BLOCK_TYPE = ReactSymbols.REACT_SERVER_BLOCK_TYPE
local REACT_LEGACY_HIDDEN_TYPE = ReactSymbols.REACT_LEGACY_HIDDEN_TYPE
return function(type)
local typeofType = typeof(type)
if typeofType == "string" or typeofType == "function" then
return true
end
if
type == REACT_FRAGMENT_TYPE
or type == REACT_PROFILER_TYPE
or type == REACT_DEBUG_TRACING_MODE_TYPE
or type == REACT_STRICT_MODE_TYPE
or type == REACT_SUSPENSE_TYPE
or type == REACT_LEGACY_HIDDEN_TYPE
then
return true
end
if typeofType == "table" then
if type.isReactComponent then
return true
end
if
type["$$typeof"] == REACT_LAZY_TYPE
or type["$$typeof"] == REACT_MEMO_TYPE
or type["$$typeof"] == REACT_PROVIDER_TYPE
or type["$$typeof"] == REACT_CONTEXT_TYPE
or type["$$typeof"] == REACT_FORWARD_REF_TYPE
or type["$$typeof"] == REACT_FUNDAMENTAL_TYPE
or type["$$typeof"] == REACT_BLOCK_TYPE
or type[1] == REACT_SERVER_BLOCK_TYPE
then
return true
end
end
return false
end
end
end)())
__register("Shared/objectIs", (function()
local script = __makeProxy({"Shared","objectIs"})
return function()
local function is(x: any, y: any): boolean
return x == y and (x ~= 0 or 1 / x == 1 / y) or x ~= x and y ~= y
end
local objectIs = is
return objectIs
end
end)())
__register("Shared/PropMarkers/Change", (function()
local script = __makeProxy({"Shared","PropMarkers","Change"})
return function()
local Type = __require(script.Parent.Parent["Type.roblox"])
local Change = {}
local changeMetatable = {
__tostring = function(self)
return string.format("RoactHostChangeEvent(%s)", self.name)
end,
}
setmetatable(Change, {
__index = function(self, propertyName)
local changeListener = {
[Type] = Type.HostChangeEvent,
name = propertyName,
}
setmetatable(changeListener, changeMetatable)
Change[propertyName] = changeListener
return changeListener
end,
})
return Change
end
end)())
__register("Shared/PropMarkers/Event", (function()
local script = __makeProxy({"Shared","PropMarkers","Event"})
return function()
local Type = __require(script.Parent.Parent["Type.roblox"])
local Event = {}
local eventMetatable = {
__tostring = function(self)
return string.format("RoactHostEvent(%s)", self.name)
end,
}
setmetatable(Event, {
__index = function(self, eventName)
local event = {
[Type] = Type.HostEvent,
name = eventName,
}
setmetatable(event, eventMetatable)
Event[eventName] = event
return event
end,
})
return Event
end
end)())
__register("Shared/PropMarkers/Tag", (function()
local script = __makeProxy({"Shared","PropMarkers","Tag"})
return function()
local Symbol = __require(script.Parent.Parent["Symbol.roblox"])
local Tag = Symbol.named("RobloxTag")
return Tag
end
end)())
__register("Shared/ReactComponentStackFrame", (function()
local script = __makeProxy({"Shared","ReactComponentStackFrame"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
type Object = { [string]: any }
type Function = (...any) -> ...any
local ReactElementType = __require(script.Parent.ReactElementType)
type Source = ReactElementType.Source
local flowtypes = __require(script.Parent["flowtypes.roblox"])
type React_StatelessFunctionalComponent<P> = flowtypes.React_StatelessFunctionalComponent<
P
>
type React_ComponentType<P> = flowtypes.React_ComponentType<P>
type ReactComponent<P> = React_StatelessFunctionalComponent<P> | React_ComponentType<P>
local ReactSymbols = __require(script.Parent.ReactSymbols)
local REACT_SUSPENSE_TYPE = ReactSymbols.REACT_SUSPENSE_TYPE
local REACT_SUSPENSE_LIST_TYPE = ReactSymbols.REACT_SUSPENSE_LIST_TYPE
local REACT_FORWARD_REF_TYPE = ReactSymbols.REACT_FORWARD_REF_TYPE
local REACT_MEMO_TYPE = ReactSymbols.REACT_MEMO_TYPE
local REACT_BLOCK_TYPE = ReactSymbols.REACT_BLOCK_TYPE
local REACT_LAZY_TYPE = ReactSymbols.REACT_LAZY_TYPE
local ConsolePatchingDev = __require(script.Parent["ConsolePatchingDev.roblox"])
local disableLogs = ConsolePatchingDev.disableLogs
local reenableLogs = ConsolePatchingDev.reenableLogs
local ReactSharedInternals = __require(script.Parent.ReactSharedInternals)
local ReactCurrentDispatcher = ReactSharedInternals.ReactCurrentDispatcher
local prefix = "    in "
local describeComponentFrame
local describeFunctionComponentFrame
local function describeOwner(owner: nil | ReactComponent<any>): string?
if type(owner) == "function" then
return debug.info(owner :: (any) -> any, "n")
elseif type(owner) == "table" then
return tostring(owner)
end
return nil
end
local function describeBuiltInComponentFrame(
name: string,
source: Source | nil,
owner: nil | ReactComponent<any>
): string
local ownerName = nil
if ReactGlobals.__DEV__ and owner then
ownerName = describeOwner(owner)
end
return describeComponentFrame(name, source, ownerName)
end
local reentry = false
local componentFrameCache = nil
if ReactGlobals.__DEV__ then
componentFrameCache = setmetatable({}, { __mode = "k" })
end
local function describeNativeComponentFrame(
fn: nil | ReactComponent<any>,
construct: boolean
): string
if not fn or reentry then
return ""
end
if ReactGlobals.__DEV__ then
local frame = componentFrameCache[fn]
if frame ~= nil then
return frame
end
end
local control
reentry = true
local previousDispatcher
if ReactGlobals.__DEV__ then
previousDispatcher = ReactCurrentDispatcher.current
ReactCurrentDispatcher.current = nil
disableLogs()
end
local traceback
local _, sample = xpcall(function()
if construct then
else
local _, x = pcall(function()
traceback = debug.traceback()
error({
stack = traceback,
})
end)
control = x;
(fn :: (...any) -> ...any)()
end
end, function(message)
return {
message = message,
stack = traceback,
}
end)
local earlyOutValue = nil
if sample and control and type(sample.stack) == "string" then
local sampleLines = string.split(sample.stack, "\n")
local controlLines = string.split(control.stack, "\n")
local sampleIndex = #sampleLines - 1
local controlIndex = #controlLines - 1
while
sampleIndex >= 2
and controlIndex >= 0
and sampleLines[sampleIndex] ~= controlLines[controlIndex]
do
controlIndex = controlIndex - 1
end
while sampleIndex >= 3 and controlIndex >= 1 do
sampleIndex = sampleIndex - 1
controlIndex = controlIndex - 1
if sampleLines[sampleIndex] ~= controlLines[controlIndex] then
if sampleIndex ~= 1 or controlIndex ~= 1 then
repeat
sampleIndex = sampleIndex - 1
controlIndex = controlIndex - 1
if
controlIndex < 0
or sampleLines[sampleIndex] ~= controlLines[controlIndex]
then
local frame = "\n" .. prefix .. sampleLines[sampleIndex]
if ReactGlobals.__DEV__ then
componentFrameCache[fn] = frame
end
earlyOutValue = frame
end
until not (sampleIndex >= 3 and controlIndex >= 1)
end
break
end
end
end
reentry = false
if ReactGlobals.__DEV__ then
ReactCurrentDispatcher.current = previousDispatcher
reenableLogs()
end
if earlyOutValue ~= nil then
return earlyOutValue
end
local name = if type(fn) == "function"
then debug.info(fn :: Function, "n")
else if type(fn) == "table" then tostring(fn) else ""
local syntheticFrame = ""
if name ~= nil and name ~= "" then
syntheticFrame = describeBuiltInComponentFrame(name)
end
if ReactGlobals.__DEV__ then
componentFrameCache[fn] = syntheticFrame
end
return syntheticFrame
end
local BEFORE_SLASH_PATTERN = "^(.*)[\\/]"
function describeComponentFrame(
name: string | nil,
source: Source | nil,
ownerName: string | nil
): string
local sourceInfo = ""
if ReactGlobals.__DEV__ and source then
local path = source.fileName
local fileName = string.gsub(path, BEFORE_SLASH_PATTERN, "")
if string.match(fileName, "^init%.") then
local pathBeforeSlash = string.match(path, BEFORE_SLASH_PATTERN)
if pathBeforeSlash and #pathBeforeSlash ~= 0 then
local folderName = string.gsub(pathBeforeSlash, BEFORE_SLASH_PATTERN, "")
fileName = folderName .. "/" .. fileName
end
end
sourceInfo = " (at " .. fileName .. ":" .. source.lineNumber .. ")"
elseif ownerName then
sourceInfo = " (created by " .. ownerName .. ")"
end
return "\n    in " .. (name or "Unknown") .. sourceInfo
end
local function describeClassComponentFrame(
ctor: any,
source: nil | Source,
owner: nil | ReactComponent<any>
): string
local name = tostring(ctor)
local ownerName = nil
if ReactGlobals.__DEV__ and owner then
ownerName = describeOwner(owner)
end
return describeComponentFrame(name, source, ownerName)
end
function describeFunctionComponentFrame(
fn: nil | Function,
source: nil | Source,
ownerFn: nil | ReactComponent<any>
): string
if not fn then
return ""
end
local name = if type(fn) == "function"
then debug.info(fn :: Function, "n")
else tostring(fn)
local ownerName = nil
if ReactGlobals.__DEV__ and ownerFn then
ownerName = describeOwner(ownerFn)
end
return describeComponentFrame(name, source, ownerName)
end
local function describeUnknownElementTypeFrameInDEV(
type_: any,
source: nil | Source,
ownerFn: nil | ReactComponent<any>
): string
if not ReactGlobals.__DEV__ then
return ""
end
if type_ == nil then
return ""
end
if type(type_) == "table" and type(type_.__ctor) == "function" then
return describeClassComponentFrame(type_, source, ownerFn)
end
if type(type_) == "function" then
return describeFunctionComponentFrame(type_, source, ownerFn)
end
if type(type_) == "string" then
return describeBuiltInComponentFrame(type_, source, ownerFn)
end
if type_ == REACT_SUSPENSE_TYPE then
return describeBuiltInComponentFrame("Suspense", source, ownerFn)
elseif type_ == REACT_SUSPENSE_LIST_TYPE then
return describeBuiltInComponentFrame("SuspenseList", source, ownerFn)
end
if type(type_) == "table" then
local typeProp = type_["$$typeof"]
if typeProp == REACT_FORWARD_REF_TYPE then
return describeFunctionComponentFrame(type_.render, source, ownerFn)
elseif typeProp == REACT_MEMO_TYPE then
return describeUnknownElementTypeFrameInDEV(type_.type, source, ownerFn)
elseif typeProp == REACT_BLOCK_TYPE then
return describeFunctionComponentFrame(type_._render, source, ownerFn)
elseif typeProp == REACT_LAZY_TYPE then
local lazyComponent = type_
local payload = lazyComponent._payload
local init = lazyComponent._init
local ok, result = pcall(function()
describeUnknownElementTypeFrameInDEV(
init(payload),
source,
ownerFn
)
end)
if ok then
return result
end
end
end
return ""
end
return {
describeComponentFrame = describeComponentFrame,
describeBuiltInComponentFrame = describeBuiltInComponentFrame,
describeNativeComponentFrame = describeNativeComponentFrame,
describeClassComponentFrame = describeClassComponentFrame,
describeFunctionComponentFrame = describeFunctionComponentFrame,
describeUnknownElementTypeFrameInDEV = describeUnknownElementTypeFrameInDEV,
}
end
end)())
__register("Shared/ReactElementType", (function()
local script = __makeProxy({"Shared","ReactElementType"})
return function()
local Packages = script.Parent.Parent
local LuauPolyfill = __require(Packages.LuauPolyfill)
type Object = LuauPolyfill.Object
local flowtypes = __require(script.Parent["flowtypes.roblox"])
type React_Element<ElementType> = flowtypes.React_Element<ElementType>
type React_StatelessFunctionalComponent<P> = flowtypes.React_StatelessFunctionalComponent<
P
>
type React_ComponentType<P> = flowtypes.React_ComponentType<P>
type Source = {
fileName: string,
lineNumber: number,
}
type Key = string | number
type ReactElement<P = Object, T = any> = {
["$$typeof"]: number,
type: React_StatelessFunctionalComponent<P> | React_ComponentType<P> | string,
key: Key | nil,
ref: any,
props: P,
_owner: any,
_store: any?,
_self: React_Element<any>?,
_shadowChildren: any?,
_source: Source?,
}
return {}
end
end)())
__register("Shared/ReactErrorUtils", (function()
local script = __makeProxy({"Shared","ReactErrorUtils"})
return function()
local invariant = __require(script.Parent.invariant)
local invokeGuardedCallbackImpl = __require(script.Parent.invokeGuardedCallbackImpl)
local clearCaughtError
local hasError = false
local caughtError = nil
local hasRethrowError = false
local rethrowError = nil
local reporter = {
onError = function(err)
hasError = true
caughtError = err
end,
}
local exports = {}
exports.invokeGuardedCallback = function(...)
hasError = false
caughtError = nil
invokeGuardedCallbackImpl(reporter, ...)
end
exports.invokeGuardedCallbackAndCatchFirstError = function(...)
exports.invokeGuardedCallback(...)
if hasError then
local err = clearCaughtError()
if not hasRethrowError then
hasRethrowError = true
rethrowError = err
end
end
end
exports.rethrowCaughtError = function()
if hasRethrowError then
local err = rethrowError
hasRethrowError = false
rethrowError = nil
error(err)
end
end
exports.hasCaughtError = function()
return hasError
end
clearCaughtError = function()
if hasError then
local err = caughtError
hasError = false
caughtError = nil
return err
else
invariant(
false,
"clearCaughtError was called but no error was captured. This error "
.. "is likely caused by a bug in React. Please file an issue."
)
return nil
end
end
exports.clearCaughtError = clearCaughtError
return exports
end
end)())
__register("Shared/ReactFeatureFlags", (function()
local script = __makeProxy({"Shared","ReactFeatureFlags"})
return function()
local Shared = script.Parent
local Packages = Shared.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local SafeFlags = __require(Packages.SafeFlags)
local GetFFlagReactEnableSchedulingProfiler =
SafeFlags.createGetFFlag("ReactEnableSchedulingProfiler")
local GetFFlagReactCatchYieldingInDEV =
SafeFlags.createGetFFlag("ReactCatchYieldingInDEV")
local GetFFlagReactFilterInternalStackFrames =
SafeFlags.createGetFFlag("ReactFilterInternalStackFrames")
local exports = {}
exports.enableDebugTracing = false
exports.enableSchedulingProfiler = GetFFlagReactEnableSchedulingProfiler()
or (ReactGlobals.__PROFILE__ and ReactGlobals.__EXPERIMENTAL__)
exports.catchYieldingInDEV = ReactGlobals.__DEV__ and GetFFlagReactCatchYieldingInDEV()
exports.debugRenderPhaseSideEffectsForStrictMode = ReactGlobals.__DEV__
exports.replayFailedUnitOfWorkWithInvokeGuardedCallback = ReactGlobals.__DEV__
exports.warnAboutDeprecatedLifecycles = true
exports.enableProfilerTimer = ReactGlobals.__PROFILE__
exports.enableProfilerCommitHooks = ReactGlobals.__PROFILE__
exports.enableSchedulerTracing = ReactGlobals.__PROFILE__
exports.enableSuspenseServerRenderer = ReactGlobals.__EXPERIMENTAL__
exports.enableBlocksAPI = ReactGlobals.__EXPERIMENTAL__
exports.enableLazyElements = ReactGlobals.__EXPERIMENTAL__
exports.enableSchedulerDebugging = false
exports.enableFundamentalAPI = false
exports.enableScopeAPI = false
exports.enableCreateEventHandleAPI = false
exports.warnAboutUnmockedScheduler = false
exports.enableSuspenseCallback = false
exports.warnAboutDefaultPropsOnFunctionComponents = false
exports.warnAboutSpreadingKeyToJSX = true
exports.enableComponentStackLocations = true
exports.enableNewReconciler = true
exports.skipUnmountedBoundaries = true
exports.deletedTreeCleanUpLevel =
SafeFlags.createGetFInt("ReactDeletedTreeCleanUpLevel", 1)()
exports.enableNewTreeCleanupPath =
SafeFlags.createGetFFlag("ReactEnableNewTreeCleanupPath", false)()
exports.filterInternalStackFrames = ReactGlobals.__DEV__
and GetFFlagReactFilterInternalStackFrames()
exports.warnAboutStringRefs = false
exports.disableLegacyContext = false
exports.disableModulePatternComponents = false
exports.warnUnstableRenderSubtreeIntoContainer = false
exports.deferRenderPhaseUpdateToNextBatch = false
exports.decoupleUpdatePriorityFromScheduler = true
exports.enableEagerRootListeners = false
exports.enableDoubleInvokingEffects = false
return exports
end
end)())
__register("Shared/ReactFiberHostConfig/init", (function()
local script = __makeProxy({"Shared","ReactFiberHostConfig"})
return function()
type Object = { [string]: any }
type OpaqueIDType = string | Object
return {
WithNoHydration = __require(script.WithNoHydration),
WithNoPersistence = __require(script.WithNoPersistence),
WithNoTestSelectors = __require(script.WithNoTestSelectors),
}
end
end)())
__register("Shared/ReactFiberHostConfig/WithNoHydration", (function()
local script = __makeProxy({"Shared","ReactFiberHostConfig","WithNoHydration"})
return function()
local invariant = __require(script.Parent.Parent.invariant)
function shim(...)
invariant(
false,
"The current renderer does not support hydration. "
.. "This error is likely caused by a bug in React. "
.. "Please file an issue."
)
end
type SuspenseInstance = any
return {
supportsHydration = false,
canHydrateInstance = shim,
canHydrateTextInstance = shim,
canHydrateSuspenseInstance = shim,
isSuspenseInstancePending = shim,
isSuspenseInstanceFallback = shim,
registerSuspenseInstanceRetry = shim,
getNextHydratableSibling = shim,
getFirstHydratableChild = shim,
hydrateInstance = shim,
hydrateTextInstance = shim,
hydrateSuspenseInstance = shim,
getNextHydratableInstanceAfterSuspenseInstance = shim,
commitHydratedContainer = shim,
commitHydratedSuspenseInstance = shim,
clearSuspenseBoundary = shim,
clearSuspenseBoundaryFromContainer = shim,
didNotMatchHydratedContainerTextInstance = shim,
didNotMatchHydratedTextInstance = shim,
didNotHydrateContainerInstance = shim,
didNotHydrateInstance = shim,
didNotFindHydratableContainerInstance = shim,
didNotFindHydratableContainerTextInstance = shim,
didNotFindHydratableContainerSuspenseInstance = shim,
didNotFindHydratableInstance = shim,
didNotFindHydratableTextInstance = shim,
didNotFindHydratableSuspenseInstance = shim,
}
end
end)())
__register("Shared/ReactFiberHostConfig/WithNoPersistence", (function()
local script = __makeProxy({"Shared","ReactFiberHostConfig","WithNoPersistence"})
return function()
local invariant = __require(script.Parent.Parent.invariant)
local function shim(...)
invariant(
false,
"The current renderer does not support persistence. "
.. "This error is likely caused by a bug in React. "
.. "Please file an issue."
)
end
return {
supportsPersistence = false,
cloneInstance = shim,
cloneFundamentalInstance = shim,
createContainerChildSet = shim,
appendChildToContainerChildSet = shim,
finalizeContainerChildren = shim,
replaceContainerChildren = shim,
cloneHiddenInstance = shim,
cloneHiddenTextInstance = shim,
}
end
end)())
__register("Shared/ReactFiberHostConfig/WithNoTestSelectors", (function()
local script = __makeProxy({"Shared","ReactFiberHostConfig","WithNoTestSelectors"})
return function()
local invariant = __require(script.Parent.Parent.invariant)
local function shim(...)
invariant(
false,
"The current renderer does not support test selectors. "
.. "This error is likely caused by a bug in React. "
.. "Please file an issue."
)
end
return {
supportsTestSelectors = false,
findFiberRoot = shim,
getBoundingRect = shim,
getTextContent = shim,
isHiddenSubtree = shim,
matchAccessibilityRole = shim,
setFocusIfFocusable = shim,
setupIntersectionObserver = shim,
}
end
end)())
__register("Shared/ReactInstanceMap", (function()
local script = __makeProxy({"Shared","ReactInstanceMap"})
return function()
local Shared = script.Parent
local Packages = Shared.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local LuauPolyfill = __require(Packages.LuauPolyfill)
local Error = LuauPolyfill.Error
local inspect = LuauPolyfill.util.inspect
local getComponentName = __require(script.Parent.getComponentName)
local ReactUtils = script:FindFirstAncestor("ReactUtils")
local __DEV__ = ReactGlobals.__DEV__ :: boolean
local SafeFlags = __require(Packages.SafeFlags)
local GetFFlagReactInstanceMapDisableErrorChecking =
SafeFlags.createGetFFlag("ReactInstanceMapDisableErrorChecking")
local FFlagReactInstanceMapDisableErrorChecking =
GetFFlagReactInstanceMapDisableErrorChecking()
local exports = {}
local function isValidFiber(fiber): boolean
return fiber.tag ~= nil
and fiber.subtreeFlags ~= nil
and fiber.lanes ~= nil
and fiber.childLanes ~= nil
end
exports.remove = function(key)
key._reactInternals = nil
end
if not FFlagReactInstanceMapDisableErrorChecking or __DEV__ then
exports.get = function(key)
local value = key._reactInternals
if not isValidFiber(value) then
error(
Error.new(
"invalid fiber in "
.. (getComponentName(key) or "UNNAMED Component")
.. " during get from ReactInstanceMap! "
.. inspect(value)
)
)
elseif value.alternate ~= nil and not isValidFiber(value.alternate) then
error(
Error.new(
"invalid alternate fiber ("
.. (getComponentName(key) or "UNNAMED alternate")
.. ") in "
.. (getComponentName(key) or "UNNAMED Component")
.. " during get from ReactInstanceMap! "
.. inspect(value.alternate)
)
)
end
return value
end
else
exports.get = function(key)
return key._reactInternals
end
end
exports.has = function(key)
return key._reactInternals ~= nil
end
if not FFlagReactInstanceMapDisableErrorChecking or __DEV__ then
exports.set = function(key, value)
local parent = value
local message
while parent ~= nil do
if not isValidFiber(parent) then
message = "invalid fiber in "
.. (getComponentName(key) or "UNNAMED Component")
.. " being set in ReactInstanceMap! "
.. inspect(parent)
.. "\n"
if value ~= parent then
message ..= " (from original fiber " .. (getComponentName(key) or "UNNAMED Component") .. ")"
end
error(Error.new(message))
elseif
(parent :: any).alternate ~= nil
and not isValidFiber((parent :: any).alternate)
then
message = "invalid alternate fiber ("
.. (getComponentName(key) or "UNNAMED alternate")
.. ") in "
.. (getComponentName(key) or "UNNAMED Component")
.. " being set in ReactInstanceMap! "
.. inspect((parent :: any).alternate)
.. "\n"
if value ~= parent then
message ..= " (from original fiber " .. (getComponentName(key) or "UNNAMED Component") .. ")"
end
error(Error.new(message))
end
parent = (parent :: any).return_
end
(key :: any)._reactInternals = value
end
else
exports.set = function(key, value)
(key :: any)._reactInternals = value
end
end
return exports
end
end)())
__register("Shared/ReactSharedInternals/init", (function()
local script = __makeProxy({"Shared","ReactSharedInternals"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local console = __require(Packages.LuauPolyfill).console
local function onlyInTestError(functionName: string)
return function()
console.error(functionName .. " is only available in tests, not in production")
end
end
local ReactCurrentDispatcher = __require(script.ReactCurrentDispatcher)
type Dispatcher = ReactCurrentDispatcher.Dispatcher
local ReactCurrentBatchConfig = __require(script.ReactCurrentBatchConfig)
local ReactCurrentOwner = __require(script.ReactCurrentOwner)
local ReactDebugCurrentFrame = __require(script.ReactDebugCurrentFrame)
local IsSomeRendererActing = __require(script.IsSomeRendererActing)
local ReactSharedInternals = {
ReactCurrentDispatcher = ReactCurrentDispatcher,
ReactCurrentBatchConfig = ReactCurrentBatchConfig,
ReactCurrentOwner = ReactCurrentOwner,
IsSomeRendererActing = IsSomeRendererActing,
ReactDebugCurrentFrame = if ReactGlobals.__DEV__
then ReactDebugCurrentFrame
else {
setExtraStackFrame = function(_: string?): ()
onlyInTestError("setExtraStackFrame")
end,
},
}
return ReactSharedInternals
end
end)())
__register("Shared/ReactSharedInternals/IsSomeRendererActing", (function()
local script = __makeProxy({"Shared","ReactSharedInternals","IsSomeRendererActing"})
return function()
local IsSomeRendererActing = {
current = false,
}
return IsSomeRendererActing
end
end)())
__register("Shared/ReactSharedInternals/ReactCurrentBatchConfig", (function()
local script = __makeProxy({"Shared","ReactSharedInternals","ReactCurrentBatchConfig"})
return function()
local ReactCurrentBatchConfig = {
transition = 0,
}
return ReactCurrentBatchConfig
end
end)())
__register("Shared/ReactSharedInternals/ReactCurrentDispatcher", (function()
local script = __makeProxy({"Shared","ReactSharedInternals","ReactCurrentDispatcher"})
return function()
local Packages = script.Parent.Parent.Parent
local LuauPolyfill = __require(Packages.LuauPolyfill)
type Array<T> = LuauPolyfill.Array<T>
local ReactElementType = __require(script.Parent.Parent.ReactElementType)
type Source = ReactElementType.Source
local ReactTypes = __require(script.Parent.Parent.ReactTypes)
type RefObject = ReactTypes.RefObject
type ReactContext<T> = ReactTypes.ReactContext<T>
type ReactBinding<T> = ReactTypes.ReactBinding<T>
type ReactBindingUpdater<T> = ReactTypes.ReactBindingUpdater<T>
type MutableSourceVersion = ReactTypes.MutableSourceVersion
type MutableSource<Source> = ReactTypes.MutableSource<Source>
type MutableSourceSubscribeFn<Source, Snapshot> = ReactTypes.MutableSourceSubscribeFn<
Source,
Snapshot
>
type MutableSourceGetSnapshotFn<Source, Snapshot> = ReactTypes.MutableSourceGetSnapshotFn<
Source,
Snapshot
>
type BasicStateAction<S> = ((S) -> S) | S
type Dispatch<A> = (A) -> ()
type Dispatcher = {
readContext: <T>(
context: ReactContext<T>,
observedBits: nil | number | boolean
) -> T,
useState: <S>(initialState: (() -> S) | S) -> (S, Dispatch<BasicStateAction<S>>),
useReducer: <S, I, A>(
reducer: (S, A) -> S,
initialArg: I,
init: ((I) -> S)?
) -> (S, Dispatch<A>),
useContext: <T>(
context: ReactContext<T>,
observedBits: nil | number | boolean
) -> T,
useRef: <T>(initialValue: T) -> { current: T },
useBinding: <T>(initialValue: T) -> (ReactBinding<T>, ReactBindingUpdater<T>),
useEffect: (
create: (() -> ()) | (() -> () -> ()),
deps: Array<any> | nil
) -> (),
useLayoutEffect: (
create: (() -> ()) | (() -> () -> ()),
deps: Array<any> | nil
) -> (),
useCallback: <T>(callback: T, deps: Array<any> | nil) -> T,
useMemo: <T...>(nextCreate: () -> T..., deps: Array<any> | nil) -> T...,
useImperativeHandle: <T>(
ref: { current: T | nil } | ((inst: T | nil) -> any) | nil,
create: () -> T,
deps: Array<any> | nil
) -> (),
useDebugValue: <T>(value: T, formatterFn: ((value: T) -> any)?) -> (),
useDeferredValue: (<T>(value: T) -> T)?,
useTransition: (() -> ((() -> ()) -> (), boolean))?,
useMutableSource: <Source, Snapshot>(
source: MutableSource<Source>,
getSnapshot: MutableSourceGetSnapshotFn<Source, Snapshot>,
subscribe: MutableSourceSubscribeFn<Source, Snapshot>
) -> Snapshot,
useOpaqueIdentifier: () -> any,
unstable_isNewReconciler: boolean?,
}
local ReactCurrentDispatcher: { current: nil | Dispatcher } = {
current = nil,
}
return ReactCurrentDispatcher
end
end)())
__register("Shared/ReactSharedInternals/ReactCurrentOwner", (function()
local script = __makeProxy({"Shared","ReactSharedInternals","ReactCurrentOwner"})
return function()
local ReactCurrentOwner = {
current = nil :: any,
}
return ReactCurrentOwner
end
end)())
__register("Shared/ReactSharedInternals/ReactDebugCurrentFrame", (function()
local script = __makeProxy({"Shared","ReactSharedInternals","ReactDebugCurrentFrame"})
return function()
local Packages = script.Parent.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local ReactDebugCurrentFrame = {}
local currentExtraStackFrame = nil :: nil | string
function ReactDebugCurrentFrame.setExtraStackFrame(stack: string?): ()
if ReactGlobals.__DEV__ then
currentExtraStackFrame = stack
end
end
if ReactGlobals.__DEV__ then
ReactDebugCurrentFrame.getCurrentStack = nil :: nil | (() -> string)
function ReactDebugCurrentFrame.getStackAddendum(): string
local stack = ""
if currentExtraStackFrame then
stack = stack .. currentExtraStackFrame
end
local impl = ReactDebugCurrentFrame.getCurrentStack
if impl then
stack = stack .. (impl() or "")
end
return stack
end
end
return ReactDebugCurrentFrame
end
end)())
__register("Shared/ReactSymbols", (function()
local script = __makeProxy({"Shared","ReactSymbols"})
return function()
local exports: { [string]: any } = {}
exports.REACT_ELEMENT_TYPE = 0xeac7
exports.REACT_PORTAL_TYPE = 0xeaca
exports.REACT_FRAGMENT_TYPE = 0xeacb
exports.REACT_STRICT_MODE_TYPE = 0xeacc
exports.REACT_PROFILER_TYPE = 0xead2
exports.REACT_PROVIDER_TYPE = 0xeacd
exports.REACT_CONTEXT_TYPE = 0xeace
exports.REACT_FORWARD_REF_TYPE = 0xead0
exports.REACT_SUSPENSE_TYPE = 0xead1
exports.REACT_SUSPENSE_LIST_TYPE = 0xead8
exports.REACT_MEMO_TYPE = 0xead3
exports.REACT_LAZY_TYPE = 0xead4
exports.REACT_BLOCK_TYPE = 0xead9
exports.REACT_SERVER_BLOCK_TYPE = 0xeada
exports.REACT_FUNDAMENTAL_TYPE = 0xead5
exports.REACT_SCOPE_TYPE = 0xead7
exports.REACT_OPAQUE_ID_TYPE = 0xeae0
exports.REACT_DEBUG_TRACING_MODE_TYPE = 0xeae1
exports.REACT_OFFSCREEN_TYPE = 0xeae2
exports.REACT_LEGACY_HIDDEN_TYPE = 0xeae3
exports.REACT_BINDING_TYPE = 0xeae4
type Iterator<T> = {
next: () -> {
value: T,
key: any,
done: boolean,
},
}
exports.getIteratorFn = function(maybeIterable): nil | (...any) -> Iterator<any>
if typeof(maybeIterable) == "table" then
if maybeIterable["$$typeof"] == exports.REACT_PORTAL_TYPE then
return nil
end
return function()
local currentKey: any, currentValue: any
return {
next = function()
currentKey, currentValue = next(maybeIterable, currentKey)
return {
done = currentValue == nil,
key = currentKey,
value = currentValue,
}
end,
}
end
end
return nil
end
return exports
end
end)())
__register("Shared/ReactTypes", (function()
local script = __makeProxy({"Shared","ReactTypes"})
return function()
local Packages = script.Parent.Parent
local LuauPolyfill = __require(Packages.LuauPolyfill)
type Array<T> = LuauPolyfill.Array<T>
type Object = LuauPolyfill.Object
type void = nil
type NonMaybeType<T> = T
local flowtypes = __require(script.Parent["flowtypes.roblox"])
type React_Element<T> = flowtypes.React_Element<T>
type React_Node = flowtypes.React_Node
type SimpleMap<K, V> = { [K]: V }
type Iterable<T> = SimpleMap<string | number, T> | Array<T>
type ReactNode<T = any> =
React_Element<T>
| ReactPortal
| ReactFragment
| ReactProvider<T>
| ReactConsumer<T>
type ReactEmpty = nil | void | boolean
type ReactFragment = ReactEmpty | Iterable<React_Node>
type ReactNodeList = ReactEmpty | React_Node
type ReactProvider<T> = {
["$$typeof"]: number,
type: ReactProviderType<T>,
key: nil | string,
ref: nil,
props: {
value: T,
children: ReactNodeList?,
},
}
type ReactProviderType<T> = {
["$$typeof"]: number,
_context: ReactContext<T>,
}
type ReactConsumer<T> = {
["$$typeof"]: number,
type: ReactContext<T>,
key: nil | string,
ref: nil,
props: {
children: (value: T) -> ReactNodeList,
unstable_observedBits: number?,
},
}
type ReactContext<T> = {
["$$typeof"]: number,
Consumer: ReactContext<T>,
Provider: ReactProviderType<T>,
_calculateChangedBits: ((T, T) -> number)?,
_currentValue: T,
_currentValue2: T,
_threadCount: number,
_currentRenderer: Object | nil,
_currentRenderer2: Object | nil,
displayName: string?,
}
type ReactPortal = {
["$$typeof"]: number,
key: nil | string,
containerInfo: any,
children: ReactNodeList,
implementation: any,
}
type RefObject<T = any> = { current: T }
type EventPriority = number
local exports = {}
exports.DiscreteEvent = 0
exports.UserBlockingEvent = 1
exports.ContinuousEvent = 2
type ReactFundamentalComponentInstance<C, H> = {
currentFiber: Object,
instance: any,
prevProps: Object?,
props: Object,
impl: ReactFundamentalImpl<C, H>,
state: Object,
}
type ReactFundamentalImpl<C, H> = {
displayName: string,
reconcileChildren: boolean,
getInitialState: nil | (Object) -> Object,
getInstance: (C, Object, Object) -> H,
getServerSideString: nil | (C, Object) -> string,
getServerSideStringClose: nil | (C, Object) -> string,
onMount: (C, any, Object, Object) -> (),
shouldUpdate: nil | (C, Object?, Object, Object) -> boolean,
onUpdate: nil | (C, any, Object?, Object, Object) -> (),
onUnmount: nil | (C, any, Object, Object) -> (),
onHydrate: nil | (C, Object, Object) -> boolean,
onFocus: nil | (C, Object, Object) -> boolean,
}
type ReactFundamentalComponent<C, H> = {
["$$typeof"]: number,
impl: ReactFundamentalImpl<C, H>,
}
type ReactScope = {
["$$typeof"]: number,
}
type ReactScopeQuery = (
type: string,
props: { [string]: any? },
instance: any
) -> boolean
type ReactScopeInstance = {
DO_NOT_USE_queryAllNodes: (ReactScopeQuery) -> nil | Array<Object>,
DO_NOT_USE_queryFirstNode: (ReactScopeQuery) -> nil | Object,
containsNode: (Object) -> boolean,
getChildContextValues: <T>(context: ReactContext<T>) -> Array<T>,
}
type CoreReactBinding<T> = {
getValue: (self: CoreReactBinding<T>) -> T,
_source: string?,
}
type ReactBindingMap = {
map: <T, U>(
self: CoreReactBinding<T> & ReactBindingMap,
(T) -> U
) -> ReactBindingMap & CoreReactBinding<U>,
}
type ReactBinding<T> = CoreReactBinding<T> & ReactBindingMap
type ReactBindingUpdater<T> = (T) -> ()
type MutableSourceVersion = NonMaybeType<any>
type MutableSourceGetSnapshotFn<Source, Snapshot> = (source: Source) -> Snapshot
type MutableSourceSubscribeFn<Source, Snapshot> = (
source: Source,
callback: (snapshot: Snapshot) -> ()
) -> () -> ()
type MutableSourceGetVersionFn = (
_source: NonMaybeType<any>
) -> MutableSourceVersion
type MutableSource<Source> = {
_source: Source,
_getVersion: MutableSourceGetVersionFn,
_workInProgressVersionPrimary: nil | MutableSourceVersion,
_workInProgressVersionSecondary: nil | MutableSourceVersion,
_currentPrimaryRenderer: Object | nil,
_currentSecondaryRenderer: Object | nil,
}
type Wakeable = {
andThen: (
self: Wakeable,
onFulfill: () -> ...any,
onReject: () -> ...any
) -> nil | Wakeable,
__reactDoNotTraceInteractions: boolean?,
}
type _Thenable<R> = {
andThen: <U>(
self: _Thenable<R>,
onFulfill: (R) -> ...U,
onReject: (error: any) -> ...U
) -> (),
}
type Thenable<R> = {
andThen: <U>(
self: Thenable<R>,
onFulfill: (R) -> ...(_Thenable<U> | U),
onReject: (error: any) -> ...(_Thenable<U> | U)
) -> nil | _Thenable<U>,
}
return exports
end
end)())
__register("Shared/ReactVersion", (function()
local script = __makeProxy({"Shared","ReactVersion"})
return function()
return "17.3.7"
end
end)())
__register("Shared/shallowEqual", (function()
local script = __makeProxy({"Shared","shallowEqual"})
return function()
local is = __require(script.Parent.objectIs)
local function shallowEqual(objA, objB)
if is(objA, objB) then
return true
end
if
typeof(objA) ~= "table"
or objA == nil
or typeof(objB) ~= "table"
or objB == nil
then
return false
end
for key, value in objA do
if not is(objB[key], value) then
return false
end
end
for key, value in objB do
if not is(objA[key], value) then
return false
end
end
return true
end
return shallowEqual
end
end)())
__register("Shared/Symbol.roblox", (function()
local script = __makeProxy({"Shared","Symbol.roblox"})
return function()
local Symbol = {}
function Symbol.named(name)
assert(type(name) == "string", "Symbols must be created using a string name!")
local self = newproxy(true)
local wrappedName = string.format("Symbol(%s)", name)
getmetatable(self).__tostring = function()
return wrappedName
end
return self
end
return Symbol
end
end)())
__register("Shared/Type.roblox", (function()
local script = __makeProxy({"Shared","Type.roblox"})
return function()
local Symbol = __require(script.Parent["Symbol.roblox"])
local Type = newproxy(true)
local TypeInternal = {}
local function addType(name)
TypeInternal[name] = Symbol.named("Roact" .. name)
end
addType("HostChangeEvent")
addType("HostEvent")
function TypeInternal.of(value)
if typeof(value) ~= "table" then
return nil
end
return value[Type]
end
getmetatable(Type).__index = TypeInternal
getmetatable(Type).__tostring = function()
return "RoactType"
end
return Type
end
end)())
__register("Shared/UninitializedState.roblox", (function()
local script = __makeProxy({"Shared","UninitializedState.roblox"})
return function()
local console = __require(script.Parent.console)
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local UninitializedState = {}
setmetatable(UninitializedState, {
__index = function(table, key)
if ReactGlobals.__DEV__ then
console.warn(
"Attempted to access uninitialized state. Use setState to initialize state"
)
end
return nil
end,
__newindex = function(table, key)
if ReactGlobals.__DEV__ then
console.error(
"Attempted to directly mutate state. Use setState to assign new values to state."
)
end
return nil
end,
__tostring = function(self)
return "<uninitialized component state>"
end,
__metatable = "UninitializedState",
})
return UninitializedState
end
end)())
__register("Scheduler/forks/SchedulerHostConfig.default", (function()
local script = __makeProxy({"Scheduler","forks","SchedulerHostConfig.default"})
return function()
local Packages = script.Parent.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local LuauPolyfill = __require(Packages.LuauPolyfill)
type Error = LuauPolyfill.Error
local Object = LuauPolyfill.Object
local Shared = __require(Packages.Shared)
local console = Shared.console
local errorToString = Shared.errorToString
local describeError = Shared.describeError
local SafeFlags = __require(Packages.SafeFlags)
local getCurrentTime = function()
return os.clock() * 1000
end
local setTimeout = LuauPolyfill.setTimeout
local clearTimeout = LuauPolyfill.clearTimeout
local isMessageLoopRunning = false
local scheduledHostCallback: ((boolean, number) -> boolean) | nil = nil
local taskTimeoutID = Object.None
local GetFIntReactSchedulerYieldInterval =
SafeFlags.createGetFInt("ReactSchedulerYieldInterval2", 15)
local FIntReactSchedulerDesiredFrameRate =
SafeFlags.createGetFInt("ReactSchedulerDesiredFrameRate", 60)()
local FIntReactSchedulerMinimumFrameRate =
SafeFlags.createGetFInt("ReactSchedulerMinFrameRate", 30)()
local FFlagReactSchedulerEnableDeferredWork =
SafeFlags.createGetFFlag("ReactSchedulerEnableDeferredWork")()
local FFlagReactSchedulerSetFrameMarkerOnHeartbeatEnd =
SafeFlags.createGetFFlag("ReactSchedulerSetFrameMarkerOnHeartbeatEnd")()
local FFlagReactSchedulerSetTargetMsByHeartbeatDelta =
SafeFlags.createGetFFlag("ReactSchedulerSetTargetMsByHeartbeatDelta")()
local FIntReactSchedulerNumberOfLookbackFrames =
SafeFlags.createGetFInt("ReactSchedulerNumberOfLookbackFrames", 1)()
local FFlagReactSchedulerLookbackUseRingBuffer =
SafeFlags.createGetFFlag("ReactSchedulerLookbackUseRingBuffer")()
local isDeferred = false
local frameStartTime = 0
local desiredMillisecondsPerFrame = 1000 / FIntReactSchedulerDesiredFrameRate
local maxMillisecondsPerFrame = 1000 / FIntReactSchedulerMinimumFrameRate
local targetMillisecondsPerFrame = desiredMillisecondsPerFrame
local averageMillisecondsPerFrame = targetMillisecondsPerFrame
local heartbeatConection: RBXScriptConnection? = nil
local lookbackBuffer = if FFlagReactSchedulerLookbackUseRingBuffer
then table.create(FIntReactSchedulerNumberOfLookbackFrames)
else nil :: never
local lookbackIndex = 1
local function createHeartbeatConnection()
if heartbeatConection then
heartbeatConection:Disconnect()
end
heartbeatConection = game:GetService("RunService").Heartbeat
:Connect(function(step: number)
if FIntReactSchedulerNumberOfLookbackFrames > 1 then
if FFlagReactSchedulerLookbackUseRingBuffer then
lookbackBuffer[lookbackIndex] = step * 1000
lookbackIndex = (
lookbackIndex % FIntReactSchedulerNumberOfLookbackFrames
) + 1
local totalFrameTime = 0
local totalFrames = FIntReactSchedulerNumberOfLookbackFrames
for i = 1, totalFrames do
if lookbackBuffer[i] == nil then
totalFrames = i - 1
break
end
totalFrameTime += lookbackBuffer[i]
end
averageMillisecondsPerFrame = totalFrameTime / totalFrames
else
local nFrames = FIntReactSchedulerNumberOfLookbackFrames
averageMillisecondsPerFrame = (
averageMillisecondsPerFrame * (nFrames - 1) + step * 1000
) / nFrames
end
targetMillisecondsPerFrame = math.clamp(
averageMillisecondsPerFrame,
desiredMillisecondsPerFrame,
maxMillisecondsPerFrame
)
else
targetMillisecondsPerFrame = math.clamp(
step * 1000,
desiredMillisecondsPerFrame,
maxMillisecondsPerFrame
)
end
end)
end
if FFlagReactSchedulerSetTargetMsByHeartbeatDelta then
createHeartbeatConnection()
end
local function setFrameMarker()
frameStartTime = getCurrentTime()
end
local yieldInterval = GetFIntReactSchedulerYieldInterval()
local deadline = 0
type SchedulerFlags = {
yieldInterval: number?,
deferredWork: boolean?,
heartbeatFrameMarker: boolean?,
targetMsByHeartbeatDelta: boolean?,
numberOfLookbackFrames: number?,
lookbackUseRingBuffer: boolean?,
}
local function setSchedulerFlags(flags: SchedulerFlags)
if flags.yieldInterval ~= nil then
yieldInterval = flags.yieldInterval
end
if flags.deferredWork ~= nil then
FFlagReactSchedulerEnableDeferredWork = flags.deferredWork
end
if flags.heartbeatFrameMarker ~= nil then
FFlagReactSchedulerSetFrameMarkerOnHeartbeatEnd = flags.heartbeatFrameMarker
end
if flags.targetMsByHeartbeatDelta ~= nil then
FFlagReactSchedulerSetTargetMsByHeartbeatDelta = flags.targetMsByHeartbeatDelta
if flags.targetMsByHeartbeatDelta then
createHeartbeatConnection()
else
if heartbeatConection then
heartbeatConection:Disconnect()
heartbeatConection = nil
targetMillisecondsPerFrame = desiredMillisecondsPerFrame
end
end
end
if flags.numberOfLookbackFrames ~= nil then
FIntReactSchedulerNumberOfLookbackFrames = flags.numberOfLookbackFrames
end
if flags.lookbackUseRingBuffer ~= nil then
FFlagReactSchedulerLookbackUseRingBuffer = flags.lookbackUseRingBuffer
end
end
local function getSchedulerFlags(): SchedulerFlags
return {
yieldInterval = yieldInterval,
deferredWork = FFlagReactSchedulerEnableDeferredWork,
heartbeatFrameMarker = FFlagReactSchedulerSetFrameMarkerOnHeartbeatEnd,
targetMsByHeartbeatDelta = FFlagReactSchedulerSetTargetMsByHeartbeatDelta,
numberOfLookbackFrames = FIntReactSchedulerNumberOfLookbackFrames,
lookbackUseRingBuffer = FFlagReactSchedulerLookbackUseRingBuffer,
}
end
local function doesBudgetRemain(): boolean
local timeElapsed = getCurrentTime() - frameStartTime
local budget = targetMillisecondsPerFrame - timeElapsed
return budget > yieldInterval
end
local function shouldYieldToHost()
return getCurrentTime() >= deadline
end
local function requestPaint() end
local function forceFrameRate(fps)
if fps < 0 or fps > 125 then
console.warn(
"forceFrameRate takes a positive int between 0 and 125, "
.. "forcing frame rates higher than 125 fps is not supported"
)
return
end
if fps > 0 then
yieldInterval = math.floor(1000 / fps)
else
yieldInterval = 5
end
end
local function performWorkUntilDeadline()
if scheduledHostCallback ~= nil then
local currentTime = getCurrentTime()
deadline = currentTime + yieldInterval
local hasTimeRemaining = true
if
FFlagReactSchedulerEnableDeferredWork
and not FFlagReactSchedulerSetFrameMarkerOnHeartbeatEnd
then
if not isDeferred then
frameStartTime = currentTime
end
end
if FFlagReactSchedulerSetFrameMarkerOnHeartbeatEnd then
if isDeferred then
if not doesBudgetRemain() then
hasTimeRemaining = false
end
end
end
local ok, result
local function doWork()
local hasMoreWork = (scheduledHostCallback :: any)(
hasTimeRemaining,
currentTime
)
if not hasMoreWork then
isMessageLoopRunning = false
scheduledHostCallback = nil
else
if FFlagReactSchedulerEnableDeferredWork then
if doesBudgetRemain() then
isDeferred = true
task.defer(performWorkUntilDeadline)
else
isDeferred = false
task.delay(0, performWorkUntilDeadline)
if FFlagReactSchedulerSetFrameMarkerOnHeartbeatEnd then
task.defer(setFrameMarker)
end
end
else
task.delay(0, performWorkUntilDeadline)
end
end
return nil
end
if not ReactGlobals.__YOLO__ then
ok, result = xpcall(doWork, describeError)
else
result = doWork()
ok = true
end
if not ok then
task.delay(0, performWorkUntilDeadline)
if FFlagReactSchedulerSetFrameMarkerOnHeartbeatEnd then
task.defer(setFrameMarker)
end
error(errorToString(result :: any))
end
else
isMessageLoopRunning = false
end
end
local function wrapPerformWorkWithCoroutine(performWork)
local co = coroutine.create(function()
while true do
local wrapped = coroutine.wrap(performWork)
local ok, result = pcall(wrapped)
coroutine.yield(ok, result)
end
end)
return function()
local _, ok, result = coroutine.resume(co)
if not ok then
error(result)
end
end
end
performWorkUntilDeadline = wrapPerformWorkWithCoroutine(performWorkUntilDeadline)
local function requestHostCallback(callback)
scheduledHostCallback = callback
if not isMessageLoopRunning then
isMessageLoopRunning = true
task.delay(0, performWorkUntilDeadline)
if FFlagReactSchedulerSetFrameMarkerOnHeartbeatEnd then
task.defer(setFrameMarker)
end
end
end
local function cancelHostCallback()
scheduledHostCallback = nil
end
local function requestHostTimeout(callback, ms)
taskTimeoutID = setTimeout(function()
callback(getCurrentTime())
end, ms)
end
local function cancelHostTimeout()
clearTimeout(taskTimeoutID)
taskTimeoutID = Object.None
end
return {
requestHostCallback = requestHostCallback,
cancelHostCallback = cancelHostCallback,
requestHostTimeout = requestHostTimeout,
cancelHostTimeout = cancelHostTimeout,
shouldYieldToHost = shouldYieldToHost,
requestPaint = requestPaint,
getCurrentTime = getCurrentTime,
forceFrameRate = forceFrameRate,
setSchedulerFlags = setSchedulerFlags,
getSchedulerFlags = getSchedulerFlags,
}
end
end)())
__register("Scheduler/forks/SchedulerHostConfig.mock", (function()
local script = __makeProxy({"Scheduler","forks","SchedulerHostConfig.mock"})
return function()
local exports = {}
local currentTime: number = 0
local scheduledCallback: ((boolean, number) -> ()) | nil = nil
local scheduledTimeout: ((number) -> ()) | nil = nil
local timeoutTime: number = -1
local yieldedValues: { [number]: any } | nil = nil
local expectedNumberOfYields: number = -1
local didStop: boolean = false
local isFlushing: boolean = false
local needsPaint: boolean = false
local shouldYieldForPaint: boolean = false
local Packages = script.Parent.Parent.Parent
local console = __require(Packages.Shared).console
local ConsolePatchingDev = __require(Packages.Shared).ConsolePatchingDev
local disabledLog = ConsolePatchingDev.disabledLog
exports.requestHostCallback = function(callback: (boolean) -> ())
scheduledCallback = callback
end
exports.cancelHostCallback = function()
scheduledCallback = nil
end
exports.requestHostTimeout = function(callback: (number) -> (), ms: number)
scheduledTimeout = callback
timeoutTime = currentTime + ms
end
exports.cancelHostTimeout = function()
scheduledTimeout = nil
timeoutTime = -1
end
exports.shouldYieldToHost = function(): boolean
local values: any = yieldedValues
if
(
expectedNumberOfYields ~= -1
and values ~= nil
and #values >= expectedNumberOfYields
) or (shouldYieldForPaint and needsPaint)
then
didStop = true
return true
end
return false
end
exports.getCurrentTime = function(): number
return currentTime
end
exports.forceFrameRate = function()
end
exports.reset = function()
if isFlushing then
error("Cannot reset while already flushing work.")
end
currentTime = 0
scheduledCallback = nil
scheduledTimeout = nil
timeoutTime = -1
yieldedValues = nil
expectedNumberOfYields = -1
didStop = false
isFlushing = false
needsPaint = false
end
exports.unstable_flushNumberOfYields = function(count: number)
if isFlushing then
error("Already flushing work.")
end
if scheduledCallback ~= nil then
local cb = scheduledCallback
expectedNumberOfYields = count
isFlushing = true
local ok, result = pcall(function()
local hasMoreWork = true
repeat
hasMoreWork = cb(true, currentTime)
until not hasMoreWork or didStop
if not hasMoreWork then
scheduledCallback = nil
end
end)
expectedNumberOfYields = -1
didStop = false
isFlushing = false
if not ok then
error(result)
end
end
end
exports.unstable_flushUntilNextPaint = function()
if isFlushing then
error("Already flushing work.")
end
if scheduledCallback ~= nil then
local cb = scheduledCallback
shouldYieldForPaint = true
needsPaint = false
isFlushing = true
local ok, result = pcall(function()
local hasMoreWork = true
repeat
hasMoreWork = cb(true, currentTime)
until not hasMoreWork or didStop
if not hasMoreWork then
scheduledCallback = nil
end
end)
shouldYieldForPaint = false
didStop = false
isFlushing = false
if not ok then
error(result)
end
end
end
exports.unstable_flushExpired = function()
if isFlushing then
error("Already flushing work.")
end
if scheduledCallback ~= nil then
isFlushing = true
local ok, result = pcall(function()
local callback: any = scheduledCallback
local hasMoreWork = callback(false, currentTime)
if not hasMoreWork then
scheduledCallback = nil
end
end)
isFlushing = false
if not ok then
error(result)
end
end
end
exports.unstable_flushAllWithoutAsserting = function(): boolean
if isFlushing then
error("Already flushing work.")
end
if scheduledCallback ~= nil then
local cb = scheduledCallback
isFlushing = true
local ok, result = pcall(function()
local hasMoreWork = true
repeat
hasMoreWork = cb(true, currentTime)
until not hasMoreWork
if not hasMoreWork then
scheduledCallback = nil
end
end)
isFlushing = false
if not ok then
error(result)
end
return true
else
return false
end
end
exports.unstable_clearYields = function(): { [number]: any }
if yieldedValues == nil then
return {}
end
local values = yieldedValues
yieldedValues = nil
return values
end
exports.unstable_flushAll = function()
if yieldedValues ~= nil then
error(
"Log is not empty. Assert on the log of yielded values before "
.. "flushing additional work."
)
end
exports.unstable_flushAllWithoutAsserting()
if yieldedValues ~= nil then
error(
"While flushing work, something yielded a value. Use an "
.. "assertion helper to assert on the log of yielded values, e.g. "
.. "expect(Scheduler).toFlushAndYield([...])"
)
end
end
exports.unstable_yieldValue = function(value: any)
if console.log == disabledLog then
return
end
if yieldedValues == nil then
yieldedValues = { value }
else
local values: any = yieldedValues
table.insert(values, value)
end
end
exports.unstable_advanceTime = function(ms: number)
if console.log == disabledLog then
return
end
currentTime += ms
if scheduledTimeout ~= nil and timeoutTime <= currentTime then
local timeout: any = scheduledTimeout
timeout(currentTime)
timeoutTime = -1
scheduledTimeout = nil
end
end
exports.requestPaint = function()
needsPaint = true
end
return exports
end
end)())
__register("Scheduler/init", (function()
local script = __makeProxy({"Scheduler"})
return function()
local Packages = script.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local initializeScheduler = __require(script.Scheduler)
local function onlyInTestError(functionName: string)
return function()
error(functionName .. " is only available in tests, not in production")
end
end
local Scheduler = initializeScheduler(nil )
local Tracing = __require(script.Tracing)
local TracingSubscriptions = __require(script.TracingSubscriptions)
type Interaction = Tracing.Interaction
if ReactGlobals.__ROACT_17_MOCK_SCHEDULER__ then
return __require(script.unstable_mock)
end
local exports = {
unstable_ImmediatePriority = Scheduler.unstable_ImmediatePriority,
unstable_UserBlockingPriority = Scheduler.unstable_UserBlockingPriority,
unstable_NormalPriority = Scheduler.unstable_NormalPriority,
unstable_IdlePriority = Scheduler.unstable_IdlePriority,
unstable_LowPriority = Scheduler.unstable_LowPriority,
unstable_runWithPriority = Scheduler.unstable_runWithPriority,
unstable_next = Scheduler.unstable_next,
unstable_scheduleCallback = Scheduler.unstable_scheduleCallback,
unstable_cancelCallback = Scheduler.unstable_cancelCallback,
unstable_wrapCallback = Scheduler.unstable_wrapCallback,
unstable_getCurrentPriorityLevel = Scheduler.unstable_getCurrentPriorityLevel,
unstable_shouldYield = Scheduler.unstable_shouldYield,
unstable_requestPaint = Scheduler.unstable_requestPaint,
unstable_continueExecution = Scheduler.unstable_continueExecution,
unstable_pauseExecution = Scheduler.unstable_pauseExecution,
unstable_getFirstCallbackNode = Scheduler.unstable_getFirstCallbackNode,
unstable_now = Scheduler.unstable_now,
unstable_forceFrameRate = Scheduler.unstable_forceFrameRate,
unstable_setSchedulerFlags = Scheduler.unstable_setSchedulerFlags,
unstable_getSchedulerFlags = Scheduler.unstable_getSchedulerFlags,
unstable_flushAllWithoutAsserting = onlyInTestError(
"unstable_flushAllWithoutAsserting"
) :: any,
unstable_flushAll = onlyInTestError("unstable_flushAll"),
unstable_flushNumberOfYields = onlyInTestError("unstable_flushNumberOfYields"),
unstable_clearYields = onlyInTestError("unstable_clearYields") :: any,
unstable_flushUntilNextPaint = onlyInTestError("unstable_clearYields"),
unstable_advanceTime = onlyInTestError("unstable_advanceTime"),
unstable_flushExpired = onlyInTestError("unstable_flushExpired"),
unstable_yieldValue = onlyInTestError("unstable_yieldValue"),
tracing = {
unstable_wrap = onlyInTestError("unstable_wrap"),
__interactionsRef = {},
__subscriberRef = {},
},
}
for k, v in Tracing :: any do
exports.tracing[k] = v
end
for k, v in TracingSubscriptions :: any do
exports.tracing[k] = v
end
return exports
end
end)())
__register("Scheduler/NoYield", (function()
local script = __makeProxy({"Scheduler","NoYield"})
return function()
local YIELD_ERROR = [[
Yielding is not allowed inside components or hooks.
Yielding in a component stalls React's scheduler, freezing the entire application until the yield completes.
Check the stack trace below to find the exact location of the yield.
For more details and how to fix this, see: go/react-yield-error
]]
local function resultHandler(co: thread, ok: boolean, ...)
if not ok then
local err = (...)
if typeof(err) == "string" then
error(debug.traceback(co, err), 3)
else
error(err, 3)
end
end
if coroutine.status(co) ~= "dead" then
error(debug.traceback(co, YIELD_ERROR), 3)
end
return ...
end
local function NoYield<A..., R...>(callback: (A...) -> R..., ...: A...): R...
local co = coroutine.create(callback)
return resultHandler(co, coroutine.resume(co, ...))
end
return NoYield
end
end)())
__register("Scheduler/Scheduler", (function()
local script = __makeProxy({"Scheduler","Scheduler"})
return function()
return function(hostConfig)
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local ReactShared = __require(Packages.Shared)
local describeError = ReactShared.describeError
local ReactFeatureFlags = ReactShared.ReactFeatureFlags
local SchedulerFeatureFlags = __require(script.Parent.SchedulerFeatureFlags)
local enableSchedulerDebugging = SchedulerFeatureFlags.enableSchedulerDebugging
local enableProfiling = SchedulerFeatureFlags.enableProfiling
local SchedulerHostConfig = hostConfig or __require(script.Parent.SchedulerHostConfig)
local requestHostCallback = SchedulerHostConfig.requestHostCallback
local requestHostTimeout = SchedulerHostConfig.requestHostTimeout
local cancelHostTimeout = SchedulerHostConfig.cancelHostTimeout
local shouldYieldToHost = SchedulerHostConfig.shouldYieldToHost
local getCurrentTime = SchedulerHostConfig.getCurrentTime
local forceFrameRate = SchedulerHostConfig.forceFrameRate
local requestPaint = SchedulerHostConfig.requestPaint
local setSchedulerFlags = SchedulerHostConfig.setSchedulerFlags
local getSchedulerFlags = SchedulerHostConfig.getSchedulerFlags
local NoYield = __require(script.Parent.NoYield)
type Heap = { [number]: Node? }
type Node = {
id: number,
sortIndex: number,
}
local compare, siftUp, siftDown
local push = function(heap: Heap, node: Node): ()
local index = #heap + 1
heap[index] = node
siftUp(heap, node, index)
end
local peek = function(heap: Heap): Node?
return heap[1]
end
local pop = function(heap: Heap): Node?
local first = heap[1]
if first ~= nil then
local last = heap[#heap]
heap[#heap] = nil
if last :: Node ~= first :: Node then
heap[1] = last
siftDown(heap, last :: Node, 1)
end
return first
else
return nil
end
end
siftUp = function(heap: Heap, node: Node, index: number): ()
while true do
local parentIndex = math.floor(index / 2)
local parent = heap[parentIndex]
if parent ~= nil and compare(parent :: Node, node :: Node) > 0 then
heap[parentIndex] = node
heap[index] = parent
index = parentIndex
else
return
end
end
end
siftDown = function(heap: Heap, node: Node, index: number): ()
local length = #heap
while index < length do
local leftIndex = index * 2
local left = heap[leftIndex]
local rightIndex = leftIndex + 1
local right = heap[rightIndex]
if left ~= nil and compare(left :: Node, node) < 0 then
if right ~= nil and compare(right :: Node, left :: Node) < 0 then
heap[index] = right
heap[rightIndex] = node
index = rightIndex
else
heap[index] = left
heap[leftIndex] = node
index = leftIndex
end
elseif right ~= nil and compare(right :: Node, node :: Node) < 0 then
heap[index] = right
heap[rightIndex] = node
index = rightIndex
else
return
end
end
end
compare = function(a: Node, b: Node): number
local diff = a.sortIndex - b.sortIndex
if diff == 0 then
return a.id - b.id
end
return diff
end
local SchedulerPriorities = __require(script.Parent.SchedulerPriorities)
local ImmediatePriority = SchedulerPriorities.ImmediatePriority
local UserBlockingPriority = SchedulerPriorities.UserBlockingPriority
local NormalPriority = SchedulerPriorities.NormalPriority
local LowPriority = SchedulerPriorities.LowPriority
local IdlePriority = SchedulerPriorities.IdlePriority
local SchedulerProfiling = __require(script.Parent.SchedulerProfiling)
local markTaskRun = SchedulerProfiling.markTaskRun
local markTaskYield = SchedulerProfiling.markTaskYield
local markTaskCompleted = SchedulerProfiling.markTaskCompleted
local markTaskCanceled = SchedulerProfiling.markTaskCanceled
local markTaskErrored = SchedulerProfiling.markTaskErrored
local markSchedulerSuspended = SchedulerProfiling.markSchedulerSuspended
local markSchedulerUnsuspended = SchedulerProfiling.markSchedulerUnsuspended
local markTaskStart = SchedulerProfiling.markTaskStart
local stopLoggingProfilingEvents = SchedulerProfiling.stopLoggingProfilingEvents
local startLoggingProfilingEvents = SchedulerProfiling.startLoggingProfilingEvents
local maxSigned31BitInt = 1073741823
local IMMEDIATE_PRIORITY_TIMEOUT = -1
local USER_BLOCKING_PRIORITY_TIMEOUT = 250
local NORMAL_PRIORITY_TIMEOUT = 5000
local LOW_PRIORITY_TIMEOUT = 10000
local IDLE_PRIORITY_TIMEOUT = maxSigned31BitInt
local taskQueue = {}
local timerQueue = {}
local taskIdCounter = 1
local isSchedulerPaused = false
local currentTask = nil
local currentPriorityLevel = NormalPriority
local isPerformingWork = false
local isHostCallbackScheduled = false
local isHostTimeoutScheduled = false
local handleTimeout, flushWork, workLoop
local function advanceTimers(currentTime)
local timer = peek(timerQueue)
while timer ~= nil do
if timer.callback == nil then
pop(timerQueue)
elseif timer.startTime <= currentTime then
pop(timerQueue)
timer.sortIndex = timer.expirationTime
push(taskQueue, timer)
if enableProfiling then
markTaskStart(timer, currentTime)
timer.isQueued = true
end
else
return
end
timer = peek(timerQueue)
end
end
handleTimeout = function(currentTime)
isHostTimeoutScheduled = false
advanceTimers(currentTime)
if not isHostCallbackScheduled then
if peek(taskQueue) ~= nil then
isHostCallbackScheduled = true
requestHostCallback(flushWork)
else
local firstTimer = peek(timerQueue)
if firstTimer ~= nil then
requestHostTimeout(handleTimeout, firstTimer.startTime - currentTime)
end
end
end
end
flushWork = function(hasTimeRemaining, initialTime)
if enableProfiling then
markSchedulerUnsuspended(initialTime)
end
isHostCallbackScheduled = false
if isHostTimeoutScheduled then
isHostTimeoutScheduled = false
cancelHostTimeout()
end
isPerformingWork = true
local previousPriorityLevel = currentPriorityLevel
local ok, result
if not ReactGlobals.__YOLO__ then
if enableProfiling then
ok, result =
xpcall(workLoop, describeError, hasTimeRemaining, initialTime)
if not ok then
if currentTask ~= nil then
local currentTime = getCurrentTime()
markTaskErrored(currentTask, currentTime)
currentTask.isQueued = false
end
end
else
ok = true
result = workLoop(hasTimeRemaining, initialTime)
end
else
ok = true
result = workLoop(hasTimeRemaining, initialTime)
end
currentTask = nil
currentPriorityLevel = previousPriorityLevel
isPerformingWork = false
if enableProfiling then
local currentTime = getCurrentTime()
markSchedulerSuspended(currentTime)
end
if not ok then
error(result)
end
return result
end
workLoop = function(hasTimeRemaining, initialTime)
local catchYieldingInDEV = ReactGlobals.__DEV__
and ReactFeatureFlags.catchYieldingInDEV
local currentTime = initialTime
advanceTimers(currentTime)
currentTask = peek(taskQueue)
while
currentTask ~= nil and not (enableSchedulerDebugging and isSchedulerPaused)
do
if
currentTask.expirationTime > currentTime
and (not hasTimeRemaining or shouldYieldToHost())
then
break
end
local callback = currentTask.callback
if typeof(callback) == "function" then
currentTask.callback = nil
currentPriorityLevel = currentTask.priorityLevel
local didUserCallbackTimeout = currentTask.expirationTime <= currentTime
markTaskRun(currentTask, currentTime)
local continuationCallback
if catchYieldingInDEV then
continuationCallback = NoYield(callback, didUserCallbackTimeout)
else
continuationCallback = callback(didUserCallbackTimeout)
end
currentTime = getCurrentTime()
if typeof(continuationCallback) == "function" then
currentTask.callback = continuationCallback
markTaskYield(currentTask, currentTime)
else
if enableProfiling then
markTaskCompleted(currentTask, currentTime)
currentTask.isQueued = false
end
if currentTask == peek(taskQueue) then
pop(taskQueue)
end
end
advanceTimers(currentTime)
else
pop(taskQueue)
end
currentTask = peek(taskQueue)
end
if currentTask ~= nil then
return true
else
local firstTimer = peek(timerQueue)
if firstTimer ~= nil then
requestHostTimeout(handleTimeout, firstTimer.startTime - currentTime)
end
return false
end
end
local function unstable_runWithPriority(priorityLevel, eventHandler)
if
priorityLevel == ImmediatePriority
or priorityLevel == UserBlockingPriority
or priorityLevel == NormalPriority
or priorityLevel == LowPriority
or priorityLevel == IdlePriority
then
else
priorityLevel = NormalPriority
end
local previousPriorityLevel = currentPriorityLevel
currentPriorityLevel = priorityLevel
local ok, result
if not ReactGlobals.__YOLO__ then
ok, result = xpcall(eventHandler, describeError)
else
ok = true
result = eventHandler()
end
currentPriorityLevel = previousPriorityLevel
if not ok then
error(result)
end
return result
end
local function unstable_next(eventHandler)
local priorityLevel
if
currentPriorityLevel == ImmediatePriority
or currentPriorityLevel == UserBlockingPriority
or currentPriorityLevel == NormalPriority
then
priorityLevel = NormalPriority
else
priorityLevel = currentPriorityLevel
end
local previousPriorityLevel = currentPriorityLevel
currentPriorityLevel = priorityLevel
local ok, result
if not ReactGlobals.__YOLO__ then
ok, result = xpcall(eventHandler, describeError)
else
ok = true
result = eventHandler()
end
currentPriorityLevel = previousPriorityLevel
if not ok then
error(result)
end
return result
end
local function unstable_wrapCallback(callback)
local parentPriorityLevel = currentPriorityLevel
return function(...)
local previousPriorityLevel = currentPriorityLevel
currentPriorityLevel = parentPriorityLevel
local ok, result
if not ReactGlobals.__YOLO__ then
ok, result = xpcall(callback, describeError, ...)
else
ok = true
result = callback(...)
end
currentPriorityLevel = previousPriorityLevel
if not ok then
error(result)
end
return result
end
end
local function unstable_scheduleCallback(priorityLevel, callback, options)
local currentTime = getCurrentTime()
local startTime
if typeof(options) == "table" then
local delay_ = options.delay
if typeof(delay_) == "number" and delay_ > 0 then
startTime = currentTime + delay_
else
startTime = currentTime
end
else
startTime = currentTime
end
local timeout
if priorityLevel == ImmediatePriority then
timeout = IMMEDIATE_PRIORITY_TIMEOUT
elseif priorityLevel == UserBlockingPriority then
timeout = USER_BLOCKING_PRIORITY_TIMEOUT
elseif priorityLevel == IdlePriority then
timeout = IDLE_PRIORITY_TIMEOUT
elseif priorityLevel == LowPriority then
timeout = LOW_PRIORITY_TIMEOUT
else
timeout = NORMAL_PRIORITY_TIMEOUT
end
local expirationTime = startTime + timeout
local newTask = {
id = taskIdCounter,
callback = callback,
priorityLevel = priorityLevel,
startTime = startTime,
expirationTime = expirationTime,
sortIndex = -1,
}
taskIdCounter += 1
if enableProfiling then
newTask.isQueued = false
end
if startTime > currentTime then
newTask.sortIndex = startTime
push(timerQueue, newTask)
if #taskQueue == 0 and newTask == peek(timerQueue) then
if isHostTimeoutScheduled then
cancelHostTimeout()
else
isHostTimeoutScheduled = true
end
requestHostTimeout(handleTimeout, startTime - currentTime)
end
else
newTask.sortIndex = expirationTime
push(taskQueue, newTask)
if enableProfiling then
markTaskStart(newTask, currentTime)
newTask.isQueued = true
end
if not isHostCallbackScheduled and not isPerformingWork then
isHostCallbackScheduled = true
requestHostCallback(flushWork)
end
end
return newTask
end
local function unstable_pauseExecution()
isSchedulerPaused = true
end
local function unstable_continueExecution()
isSchedulerPaused = false
if not isHostCallbackScheduled and not isPerformingWork then
isHostCallbackScheduled = true
requestHostCallback(flushWork)
end
end
local function unstable_getFirstCallbackNode()
return peek(taskQueue)
end
local function unstable_cancelCallback(task)
if enableProfiling then
if task.isQueued then
local currentTime = getCurrentTime()
markTaskCanceled(task, currentTime)
task.isQueued = false
end
end
task.callback = nil
end
local function unstable_getCurrentPriorityLevel()
return currentPriorityLevel
end
local unstable_requestPaint = requestPaint
return {
unstable_ImmediatePriority = ImmediatePriority,
unstable_UserBlockingPriority = UserBlockingPriority,
unstable_NormalPriority = NormalPriority,
unstable_IdlePriority = IdlePriority,
unstable_LowPriority = LowPriority,
unstable_runWithPriority = unstable_runWithPriority,
unstable_next = unstable_next,
unstable_scheduleCallback = unstable_scheduleCallback,
unstable_cancelCallback = unstable_cancelCallback,
unstable_wrapCallback = unstable_wrapCallback,
unstable_getCurrentPriorityLevel = unstable_getCurrentPriorityLevel,
unstable_shouldYield = shouldYieldToHost,
unstable_requestPaint = unstable_requestPaint,
unstable_continueExecution = unstable_continueExecution,
unstable_pauseExecution = unstable_pauseExecution,
unstable_getFirstCallbackNode = unstable_getFirstCallbackNode,
unstable_now = getCurrentTime,
unstable_forceFrameRate = forceFrameRate,
unstable_setSchedulerFlags = setSchedulerFlags,
unstable_getSchedulerFlags = getSchedulerFlags,
unstable_Profiling = (function()
if enableProfiling then
return {
startLoggingProfilingEvents = startLoggingProfilingEvents,
stopLoggingProfilingEvents = stopLoggingProfilingEvents,
}
end
return nil
end)(),
}
end
end
end)())
__register("Scheduler/SchedulerFeatureFlags", (function()
local script = __makeProxy({"Scheduler","SchedulerFeatureFlags"})
return function()
return {
enableSchedulerDebugging = false,
enableIsInputPending = false,
enableProfiling = false,
}
end
end)())
__register("Scheduler/SchedulerHostConfig", (function()
local script = __makeProxy({"Scheduler","SchedulerHostConfig"})
return function()
return __require(script.Parent.forks["SchedulerHostConfig.default"])
end
end)())
__register("Scheduler/SchedulerMinHeap", (function()
local script = __makeProxy({"Scheduler","SchedulerMinHeap"})
return function()
type Heap = { [number]: Node? }
type Node = {
id: number,
sortIndex: number,
}
local exports = {}
local compare, siftUp, siftDown
exports.push = function(heap: Heap, node: Node): ()
local index = #heap + 1
heap[index] = node
siftUp(heap, node, index)
end
exports.peek = function(heap: Heap): Node?
return heap[1]
end
exports.pop = function(heap: Heap): Node?
local first = heap[1]
if first ~= nil then
local last = heap[#heap]
heap[#heap] = nil
if last :: Node ~= first :: Node then
heap[1] = last
siftDown(heap, last :: Node, 1)
end
return first
else
return nil
end
end
siftUp = function(heap: Heap, node: Node, index: number): ()
while true do
local parentIndex = math.floor(index / 2)
local parent = heap[parentIndex]
if parent ~= nil and compare(parent :: Node, node :: Node) > 0 then
heap[parentIndex] = node
heap[index] = parent
index = parentIndex
else
return
end
end
end
siftDown = function(heap: Heap, node: Node, index: number): ()
local length = #heap
while index < length do
local leftIndex = index * 2
local left = heap[leftIndex]
local rightIndex = leftIndex + 1
local right = heap[rightIndex]
if left ~= nil and compare(left :: Node, node) < 0 then
if right ~= nil and compare(right :: Node, left :: Node) < 0 then
heap[index] = right
heap[rightIndex] = node
index = rightIndex
else
heap[index] = left
heap[leftIndex] = node
index = leftIndex
end
elseif right ~= nil and compare(right :: Node, node :: Node) < 0 then
heap[index] = right
heap[rightIndex] = node
index = rightIndex
else
return
end
end
end
compare = function(a: Node, b: Node): number
local diff = a.sortIndex - b.sortIndex
if diff == 0 then
return a.id - b.id
end
return diff
end
return exports
end
end)())
__register("Scheduler/SchedulerPriorities", (function()
local script = __makeProxy({"Scheduler","SchedulerPriorities"})
return function()
type PriorityLevel = number
return {
NoPriority = 0,
ImmediatePriority = 1,
UserBlockingPriority = 2,
NormalPriority = 3,
LowPriority = 4,
IdlePriority = 5,
}
end
end)())
__register("Scheduler/SchedulerProfiling", (function()
local script = __makeProxy({"Scheduler","SchedulerProfiling"})
return function()
local Packages = script.Parent.Parent
local console = __require(Packages.Shared).console
local exports = {}
local SchedulerPriorities = __require(script.Parent.SchedulerPriorities)
type PriorityLevel = SchedulerPriorities.PriorityLevel
local ScheduleFeatureFlags = __require(script.Parent.SchedulerFeatureFlags)
local enableProfiling = ScheduleFeatureFlags.enableProfiling
local runIdCounter: number = 0
local mainThreadIdCounter: number = 0
local INITIAL_EVENT_LOG_SIZE = 131072
local MAX_EVENT_LOG_SIZE = 524288
type EventLog = { EventLog | { number } }
local eventLogSize = 0
local eventLogBuffer = nil
local eventLog: EventLog? = nil
local eventLogIndex = 1
local TaskStartEvent = 1
local TaskCompleteEvent = 2
local TaskErrorEvent = 3
local TaskCancelEvent = 4
local TaskRunEvent = 5
local TaskYieldEvent = 6
local SchedulerSuspendEvent = 7
local SchedulerResumeEvent = 8
local function logEvent(entries)
if eventLog ~= nil then
eventLogIndex += #entries
if eventLogIndex + 1 > eventLogSize then
eventLogSize *= 2
if eventLogSize > MAX_EVENT_LOG_SIZE then
console["error"](
"Scheduler Profiling: Event log exceeded maximum size. Don't "
.. "forget to call `stopLoggingProfilingEvents()`."
)
exports.stopLoggingProfilingEvents()
return
end
local newEventLog = {}
table.insert(newEventLog, eventLog)
eventLogBuffer = newEventLog
eventLog = newEventLog
end
table.insert(eventLog, entries)
end
end
exports.startLoggingProfilingEvents = function()
eventLogSize = INITIAL_EVENT_LOG_SIZE
eventLogBuffer = {}
eventLog = eventLogBuffer
eventLogIndex = 1
end
exports.stopLoggingProfilingEvents = function()
local buffer = eventLogBuffer
eventLogSize = 0
eventLogBuffer = nil :: any
eventLog = nil :: any
eventLogIndex = 1
return buffer
end
exports.markTaskStart = function(task, ms: number)
if enableProfiling then
if eventLog ~= nil then
logEvent({ TaskStartEvent, ms * 1000, task.id, task.priorityLevel })
end
end
end
exports.markTaskCompleted = function(task, ms: number)
if enableProfiling then
if eventLog ~= nil then
logEvent({ TaskCompleteEvent, ms * 1000, task.id })
end
end
end
exports.markTaskCanceled = function(task, ms: number)
if enableProfiling then
if eventLog ~= nil then
logEvent({ TaskCancelEvent, ms * 1000, task.id })
end
end
end
exports.markTaskErrored = function(task, ms: number)
if enableProfiling then
if eventLog ~= nil then
logEvent({ TaskErrorEvent, ms * 1000, task.id })
end
end
end
exports.markTaskRun = function(task, ms: number)
if enableProfiling then
runIdCounter += 1
if eventLog ~= nil then
logEvent({ TaskRunEvent, ms * 1000, task.id, runIdCounter })
end
end
end
exports.markTaskYield = function(task, ms: number)
if enableProfiling then
if eventLog ~= nil then
logEvent({ TaskYieldEvent, ms * 1000, task.id, runIdCounter })
end
end
end
exports.markSchedulerSuspended = function(ms: number)
if enableProfiling then
mainThreadIdCounter += 1
if eventLog ~= nil then
logEvent({ SchedulerSuspendEvent, ms * 1000, mainThreadIdCounter })
end
end
end
exports.markSchedulerUnsuspended = function(ms: number)
if enableProfiling then
if eventLog ~= nil then
logEvent({ SchedulerResumeEvent, ms * 1000, mainThreadIdCounter })
end
end
end
return exports
end
end)())
__register("Scheduler/Tracing", (function()
local script = __makeProxy({"Scheduler","Tracing"})
return function()
type Function = (any) -> any
local Packages = script.Parent.Parent
local LuauPolyfill = __require(Packages.LuauPolyfill)
type Set<T> = LuauPolyfill.Set<T>
local Set = LuauPolyfill.Set
local exports = {}
local ReactFeatureFlags = __require(Packages.Shared).ReactFeatureFlags
local enableSchedulerTracing = ReactFeatureFlags.enableSchedulerTracing
type Interaction = {
__count: number,
id: number,
name: string,
timestamp: number,
}
type Subscriber = {
onInteractionTraced: (Interaction) -> (),
onInteractionScheduledWorkCompleted: (Interaction) -> (),
onWorkScheduled: (Set<Interaction>, number) -> (),
onWorkCanceled: (Set<Interaction>, number) -> (),
onWorkStarted: (Set<Interaction>, number) -> (),
onWorkStopped: (Set<Interaction>, number) -> (),
}
type InteractionsRef = { current: Set<Interaction> }
type SubscriberRef = { current: Subscriber | nil }
local DEFAULT_THREAD_ID = 0
local interactionIDCounter: number = 0
local threadIDCounter: number = 0
local interactionsRef: InteractionsRef
local subscriberRef: SubscriberRef
if enableSchedulerTracing then
interactionsRef = {
current = Set.new(),
}
subscriberRef = {
current = nil,
}
end
exports.__interactionsRef = interactionsRef
exports.__subscriberRef = subscriberRef
exports.unstable_clear = function(callback: Function)
if not enableSchedulerTracing then
return callback()
end
local prevInteractions = interactionsRef.current
interactionsRef.current = Set.new()
local ok, result = pcall(callback)
interactionsRef.current = prevInteractions
if not ok then
error(result)
end
return result
end
exports.unstable_getCurrent = function(): Set<Interaction> | nil
if not enableSchedulerTracing then
return nil
else
return interactionsRef.current
end
end
exports.unstable_getThreadID = function(): number
threadIDCounter += 1
return threadIDCounter
end
exports.unstable_trace = function(
name: string,
timestamp: number,
callback: Function,
threadID_: number?
): any
local threadID = if threadID_ ~= nil then threadID_ else DEFAULT_THREAD_ID
if not enableSchedulerTracing then
return callback()
end
local interaction: Interaction = {
__count = 1,
id = interactionIDCounter,
name = name,
timestamp = timestamp,
}
interactionIDCounter += 1
local prevInteractions = interactionsRef.current
local interactions = Set.new(prevInteractions)
interactions:add(interaction)
interactionsRef.current = interactions
local subscriber = subscriberRef.current
local returnValue
local ok, result = pcall(function()
if subscriber ~= nil then
subscriber.onInteractionTraced(interaction)
end
end)
local ok2, result2 = pcall(function()
if subscriber ~= nil then
subscriber.onWorkStarted(interactions, threadID)
end
end)
local ok3, result3 = pcall(function()
returnValue = callback()
end)
interactionsRef.current = prevInteractions
local ok4, result4 = pcall(function()
if subscriber ~= nil then
subscriber.onWorkStopped(interactions, threadID)
end
end)
interaction.__count -= 1
if subscriber ~= nil and interaction.__count == 0 then
subscriber.onInteractionScheduledWorkCompleted(interaction)
end
if not ok4 then
error(result4)
end
if not ok3 then
error(result3)
end
if not ok2 then
error(result2)
end
if not ok then
error(result)
end
return returnValue
end
exports.unstable_wrap = function(
callback: Function,
threadID: number
): any
if threadID == nil then
threadID = DEFAULT_THREAD_ID
end
if not enableSchedulerTracing then
return callback
end
local wrappedInteractions = interactionsRef.current
local subscriber = subscriberRef.current
if subscriber ~= nil then
subscriber.onWorkScheduled(wrappedInteractions, threadID)
end
for _, interaction in wrappedInteractions do
interaction.__count += 1
end
local hasRun = false
local function _wrapped(self, ...)
local prevInteractions = interactionsRef.current
interactionsRef.current = wrappedInteractions
subscriber = subscriberRef.current
local ok, result = pcall(function(...)
local returnValue
local ok2, result2 = pcall(function()
if subscriber ~= nil then
subscriber.onWorkStarted(wrappedInteractions, threadID)
end
end)
local ok3, result3 = pcall(function(...)
returnValue = callback(...)
end, ...)
interactionsRef.current = prevInteractions
if subscriber ~= nil then
subscriber.onWorkStopped(wrappedInteractions, threadID)
end
if not ok3 then
error(result3)
end
if not ok2 then
error(result2)
end
return returnValue
end, ...)
if not hasRun then
hasRun = true
for _, interaction in wrappedInteractions do
interaction.__count -= 1
if subscriber ~= nil and interaction.__count == 0 then
subscriber.onInteractionScheduledWorkCompleted(interaction)
end
end
end
if not ok then
error(result)
end
return result
end
local _cancel = function()
subscriber = subscriberRef.current
local ok, result = pcall(function()
if subscriber ~= nil then
subscriber.onWorkCanceled(wrappedInteractions, threadID)
end
end)
for _, interaction in wrappedInteractions do
interaction.__count -= 1
if subscriber ~= nil and interaction.__count == 0 then
subscriber.onInteractionScheduledWorkCompleted(interaction)
end
end
if not ok then
error(result)
end
end
local wrapped = {}
setmetatable(wrapped, {
__call = _wrapped,
})
wrapped.cancel = _cancel
return wrapped
end
return exports
end
end)())
__register("Scheduler/TracingSubscriptions", (function()
local script = __makeProxy({"Scheduler","TracingSubscriptions"})
return function()
type Set<T> = { [T]: boolean? }
type Array<T> = { [number]: T }
local exports = {}
local Packages = script.Parent.Parent
local Object = __require(Packages.LuauPolyfill).Object
local Tracing = __require(script.Parent.Tracing)
type Interaction = Tracing.Interaction
type Subscriber = Tracing.Subscriber
local ReactFeatureFlags = __require(Packages.Shared).ReactFeatureFlags
local enableSchedulerTracing = ReactFeatureFlags.enableSchedulerTracing
local __subscriberRef = Tracing.__subscriberRef
local subscribers: Set<Subscriber> = {}
if enableSchedulerTracing then
subscribers = {}
end
exports.unstable_subscribe = function(subscriber: Subscriber): ()
if enableSchedulerTracing then
subscribers[subscriber] = true
if #Object.keys(subscribers) == 1 then
__subscriberRef.current = {
onInteractionScheduledWorkCompleted = onInteractionScheduledWorkCompleted,
onInteractionTraced = onInteractionTraced,
onWorkCanceled = onWorkCanceled,
onWorkScheduled = onWorkScheduled,
onWorkStarted = onWorkStarted,
onWorkStopped = onWorkStopped,
}
end
end
end
exports.unstable_unsubscribe = function(subscriber: Subscriber): ()
if enableSchedulerTracing then
subscribers[subscriber] = nil
if #Object.keys(subscribers) == 0 then
__subscriberRef.current = nil
end
end
end
function onInteractionTraced(interaction: Interaction): ()
local didCatchError = false
local caughtError = nil
for subscriber, _ in subscribers do
local ok, result = pcall(subscriber.onInteractionTraced, interaction)
if not ok then
local error_ = result
if not didCatchError then
didCatchError = true
caughtError = error_
end
end
end
if didCatchError then
error(caughtError)
end
end
function onInteractionScheduledWorkCompleted(interaction: Interaction): ()
local didCatchError = false
local caughtError = nil
for subscriber, _ in subscribers do
local ok, result =
pcall(subscriber.onInteractionScheduledWorkCompleted, interaction)
if not ok then
local error_ = result
if not didCatchError then
didCatchError = true
caughtError = error_
end
end
end
if didCatchError then
error(caughtError)
end
end
function onWorkScheduled(interactions: Set<Interaction>, threadID: number): ()
local didCatchError = false
local caughtError = nil
for subscriber, _ in subscribers do
local ok, result = pcall(subscriber.onWorkScheduled, interactions, threadID)
if not ok then
local error_ = result
if not didCatchError then
didCatchError = true
caughtError = error_
end
end
end
if didCatchError then
error(caughtError)
end
end
function onWorkStarted(interactions: Set<Interaction>, threadID: number): ()
local didCatchError = false
local caughtError = nil
for subscriber, _ in subscribers do
local ok, result = pcall(subscriber.onWorkStarted, interactions, threadID)
if not ok then
local error_ = result
if not didCatchError then
didCatchError = true
caughtError = error_
end
end
end
if didCatchError then
error(caughtError)
end
end
function onWorkStopped(interactions: Set<Interaction>, threadID: number): ()
local didCatchError = false
local caughtError = nil
for subscriber, _ in subscribers do
local ok, result = pcall(subscriber.onWorkStopped, interactions, threadID)
if not ok then
local error_ = result
if not didCatchError then
didCatchError = true
caughtError = error_
end
end
end
if didCatchError then
error(caughtError)
end
end
function onWorkCanceled(interactions: Set<Interaction>, threadID: number): ()
local didCatchError = false
local caughtError = nil
for subscriber, _ in subscribers do
local ok, result = pcall(subscriber.onWorkCanceled, interactions, threadID)
if not ok then
local error_ = result
if not didCatchError then
didCatchError = true
caughtError = error_
end
end
end
if didCatchError then
error(caughtError)
end
end
return exports
end
end)())
__register("Scheduler/unstable_mock", (function()
local script = __makeProxy({"Scheduler","unstable_mock"})
return function()
local Tracing = __require(script.Parent.Tracing)
local TracingSubscriptions = __require(script.Parent.TracingSubscriptions)
type Interaction = Tracing.Interaction
local initializeScheduler = __require(script.Parent.Scheduler)
local HostConfig = __require(script.Parent.forks["SchedulerHostConfig.mock"])
local Scheduler = initializeScheduler(HostConfig)
local exports = {}
exports.tracing = {}
for key, value in Scheduler :: any do
exports[key] = value
end
for key, value in Tracing :: any do
exports.tracing[key] = value
end
for key, value in TracingSubscriptions :: any do
exports.tracing[key] = value
end
exports.unstable_flushAllWithoutAsserting = HostConfig.unstable_flushAllWithoutAsserting
exports.unstable_flushNumberOfYields = HostConfig.unstable_flushNumberOfYields
exports.unstable_flushExpired = HostConfig.unstable_flushExpired
exports.unstable_clearYields = HostConfig.unstable_clearYields
exports.unstable_flushUntilNextPaint = HostConfig.unstable_flushUntilNextPaint
exports.unstable_flushAll = HostConfig.unstable_flushAll
exports.unstable_yieldValue = HostConfig.unstable_yieldValue
exports.unstable_advanceTime = HostConfig.unstable_advanceTime
exports.unstable_Profiling = Scheduler.unstable_Profiling
return exports
end
end)())
__register("React/createSignal.roblox", (function()
local script = __makeProxy({"React","createSignal.roblox"})
return function()
type Function = (...any) -> ...any
type Connection = { callback: Function, disconnected: boolean }
type Map<K, V> = { [K]: V }
local function createSignal(): ((Function) -> () -> (), (...any) -> ())
local connections: Map<Function, Connection> = {}
local suspendedConnections = {}
local firing = false
local function subscribe(callback)
assert(
typeof(callback) == "function",
"Can only subscribe to signals with a function."
)
local connection = {
callback = callback,
disconnected = false,
}
if firing and not connections[callback] then
suspendedConnections[callback] = connection
end
connections[callback] = connection
local function disconnect()
assert(
not connection.disconnected,
"Listeners can only be disconnected once."
)
connection.disconnected = true
connections[callback] = nil
suspendedConnections[callback] = nil
end
return disconnect
end
local function fire(...)
firing = true
for callback, connection in connections do
if not connection.disconnected and not suspendedConnections[callback] then
callback(...)
end
end
firing = false
table.clear(suspendedConnections)
end
return subscribe, fire
end
return createSignal
end
end)())
__register("React/init", (function()
local script = __makeProxy({"React"})
return function()
local Packages = script.Parent
local LuauPolyfill = __require(Packages.LuauPolyfill)
type Object = LuauPolyfill.Object
local React = __require(script.React)
type Binding<T> = React.ReactBinding<T>
type BindingUpdater<T> = React.ReactBindingUpdater<T>
local ReactLazy = __require(script.ReactLazy)
type LazyComponent<T, P> = ReactLazy.LazyComponent<T, P>
local SharedModule = __require(Packages.Shared)
type StatelessFunctionalComponent<P> =
SharedModule.React_StatelessFunctionalComponent<P>
type ComponentType<P> = ComponentClass<P> | FC<P>
type AbstractComponent<Config, Instance> = SharedModule.React_AbstractComponent<
Config,
Instance
>
type ElementType = SharedModule.React_ElementType
type Element<C> = SharedModule.React_Element<C>
type Key = SharedModule.React_Key
type Ref<ElementType> = SharedModule.React_Ref<ElementType>
type RefObject<T = any> = SharedModule.RefObject<T>
type Node = SharedModule.React_Node
type Context<T> = SharedModule.ReactContext<T>
type ElementProps<C> = SharedModule.React_ElementProps<C>
type ElementConfig<T> = SharedModule.React_ElementConfig<T>
type ElementRef<C> = SharedModule.React_ElementRef<C>
type ComponentClass<P> = SharedModule.React_ComponentType<P>
type PureComponent<Props, State = nil> = React.PureComponent<Props, State>
type ReactElement<Props = Object, ElementType = any> = SharedModule.ReactElement<
Props,
ElementType
>
type ReactChild = SharedModule.ReactElement<any, string> | string | number
type FC<P> = SharedModule.React_StatelessFunctionalComponent<P>
type ReactNode = SharedModule.React_Node
type React_AbstractComponent<Props, Instance> = SharedModule.React_Component<
Props,
Instance
>
type React_FowardRefComponent<Props, Instance> =
SharedModule.React_ForwardRefComponent<Props, Instance>
type React_MemoComponent<Config, T> = SharedModule.React_MemoComponent<Config, T>
type React_Component<Props, State> = SharedModule.React_Component<Props, State>
type React_ComponentType<P> = SharedModule.React_ComponentType<P>
type React_Context<T> = SharedModule.React_Context<T>
type React_Element<ElementType> = SharedModule.React_Element<ElementType>
type React_ElementType = SharedModule.React_ElementType
type React_Node = SharedModule.React_Node
return React
end
end)())
__register("React/None.roblox", (function()
local script = __makeProxy({"React","None.roblox"})
return function()
local Packages = script.Parent.Parent
local LuauPolyfill = __require(Packages.LuauPolyfill)
return LuauPolyfill.Object.None
end
end)())
__register("React/React", (function()
local script = __makeProxy({"React","React"})
return function()
local React = script.Parent
local Packages = React.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local LuauPolyfill = __require(Packages.LuauPolyfill)
type Object = LuauPolyfill.Object
local createMutableSource = __require(React.ReactMutableSource)
local ReactSharedInternals = __require(Packages.Shared).ReactSharedInternals
local ReactBaseClasses = __require(React.ReactBaseClasses)
local ReactChildren = __require(React.ReactChildren)
local ReactElementValidator = __require(React.ReactElementValidator)
local ReactElement = __require(React.ReactElement)
local ReactCreateRef = __require(React.ReactCreateRef)
local ReactForwardRef = __require(React.ReactForwardRef)
local ReactHooks = __require(React.ReactHooks)
local ReactMemo = __require(React.ReactMemo)
local ReactContext = __require(React.ReactContext)
local ReactLazy = __require(React.ReactLazy)
type LazyComponent<T, P> = ReactLazy.LazyComponent<T, P>
local ReactBinding = __require(React["ReactBinding.roblox"])
local ReactNone = __require(React["None.roblox"])
local SharedModule = __require(Packages.Shared)
local ReactSymbols = SharedModule.ReactSymbols
local shouldValidate = ReactGlobals.__DEV__
or ReactGlobals.__DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__
local ReactTypes = __require(Packages.Shared)
type React_StatelessFunctionalComponent<P> =
ReactTypes.React_StatelessFunctionalComponent<P>
type React_ComponentType<P> = ReactTypes.React_ComponentType<P>
type React_AbstractComponent<P, T> = ReactTypes.React_AbstractComponent<P, T>
type React_ElementProps<ElementType> = ReactTypes.React_ElementProps<ElementType>
type ReactElement<P = Object, T = any> = ReactTypes.ReactElement<P, T>
type ReactContext<T> = ReactTypes.ReactContext<T>
type ReactProviderType<T> = ReactTypes.ReactProviderType<T>
type React_Node = ReactTypes.React_Node
type PureComponent<Props, State = nil> = ReactTypes.React_PureComponent<
Props,
State
>
type ReactBinding<T> = ReactTypes.ReactBinding<T>
type ReactBindingUpdater<T> = ReactTypes.ReactBindingUpdater<T>
type createElementFn = <P, T>(
type_: React_StatelessFunctionalComponent<P>
| React_ComponentType<P>
| React_AbstractComponent<P, T>
| string
| ReactContext<any>
| ReactProviderType<any>
| LazyComponent<T, P>,
props: P?,
...(React_Node | (...any) -> React_Node)
) -> ReactElement<P, T>
type cloneElementFn = <P, T>(
element: ReactElement<P, T>,
config: P?,
...React_Node
) -> ReactElement<P, T>
local createElement = if shouldValidate
then ReactElementValidator.createElementWithValidation :: createElementFn
else ReactElement.createElement :: createElementFn
local cloneElement: cloneElementFn = if shouldValidate
then ReactElementValidator.cloneElementWithValidation :: cloneElementFn
else ReactElement.cloneElement :: cloneElementFn
return {
Children = ReactChildren,
createMutableSource = createMutableSource,
createRef = ReactCreateRef.createRef,
Component = ReactBaseClasses.Component,
PureComponent = ReactBaseClasses.PureComponent,
createContext = ReactContext.createContext,
forwardRef = ReactForwardRef.forwardRef,
lazy = ReactLazy.lazy,
memo = ReactMemo.memo,
useCallback = ReactHooks.useCallback,
useContext = ReactHooks.useContext,
useEffect = ReactHooks.useEffect,
useImperativeHandle = ReactHooks.useImperativeHandle,
useDebugValue = ReactHooks.useDebugValue,
useLayoutEffect = ReactHooks.useLayoutEffect,
useMemo = ReactHooks.useMemo,
useMutableSource = ReactHooks.useMutableSource,
useReducer = ReactHooks.useReducer,
useRef = ReactHooks.useRef,
useBinding = ReactHooks.useBinding,
useState = ReactHooks.useState,
Fragment = ReactSymbols.REACT_FRAGMENT_TYPE,
Profiler = ReactSymbols.REACT_PROFILER_TYPE,
StrictMode = ReactSymbols.REACT_STRICT_MODE_TYPE,
unstable_DebugTracingMode = ReactSymbols.REACT_DEBUG_TRACING_MODE_TYPE,
Suspense = ReactSymbols.REACT_SUSPENSE_TYPE,
createElement = createElement,
cloneElement = cloneElement,
isValidElement = ReactElement.isValidElement,
__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED = ReactSharedInternals,
unstable_LegacyHidden = ReactSymbols.REACT_LEGACY_HIDDEN_TYPE,
createBinding = ReactBinding.create,
joinBindings = ReactBinding.join,
None = ReactNone,
__subscribeToBinding = ReactBinding.subscribe,
Event = __require(Packages.Shared).Event,
Change = __require(Packages.Shared).Change,
Tag = __require(Packages.Shared).Tag,
unstable_parseReactError = __require(Packages.Shared).parseReactError,
}
end
end)())
__register("React/ReactBaseClasses", (function()
local script = __makeProxy({"React","ReactBaseClasses"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local LuauPolyfill = __require(Packages.LuauPolyfill)
local Object = LuauPolyfill.Object
type Object = LuauPolyfill.Object
local console = __require(Packages.Shared).console
local SharedModule = __require(Packages.Shared)
type React_Component<Props, State = nil> = SharedModule.React_Component<Props, State>
local ReactNoopUpdateQueue = __require(script.Parent.ReactNoopUpdateQueue)
local emptyObject = {}
local __DEV__ = ReactGlobals.__DEV__ :: boolean
local __COMPAT_WARNINGS__ = ReactGlobals.__COMPAT_WARNINGS__ :: boolean
if __DEV__ then
Object.freeze(emptyObject)
end
local UninitializedState = __require(Packages.Shared).UninitializedState
local componentClassPrototype = {
isReactComponent = true,
}
local function trimPath(path: string): string
local pascalFile = string.match(path, "%.%u[%.%w]-$")
if pascalFile then
return string.gsub(pascalFile, "^%.", "")
end
return path
end
local function warnAboutExistingLifecycle(componentName, newName, existingName)
console.warn(
"%s already defined '%s', but it also defining the deprecated Roact method '%s'. %s should only implement one of these methods, preferably using the non-deprecated name.",
componentName,
existingName,
newName,
componentName
)
end
local function warnAboutDeprecatedLifecycleName(componentName, newName, existingName)
if __DEV__ and __COMPAT_WARNINGS__ then
local path, linenum = debug.info(3, "sln")
console.warn(
"%s is using method '%s', which is no longer supported and should be updated to '%s'\nFile: %s:%s",
componentName,
newName,
existingName,
trimPath(path),
tostring(linenum)
)
end
end
local lifecycleNames = {
didMount = "componentDidMount",
shouldUpdate = "shouldComponentUpdate",
willUpdate = "UNSAFE_componentWillUpdate",
didUpdate = "componentDidUpdate",
willUnmount = "componentWillUnmount",
}
local function handleNewLifecycle(self, key, value)
if lifecycleNames[key] ~= nil then
if self[lifecycleNames[key]] ~= nil then
warnAboutExistingLifecycle(self.__componentName, key, lifecycleNames[key])
elseif key == "willUpdate" and self["componentWillUpdate"] then
warnAboutExistingLifecycle(
self.__componentName,
key,
"UNSAFE_componentWillUpdate"
)
else
warnAboutDeprecatedLifecycleName(
self.__componentName,
key,
lifecycleNames[key]
)
end
key = lifecycleNames[key]
end
rawset(self, key, value)
end
local componentClassMetatable = {
__newindex = handleNewLifecycle,
__index = componentClassPrototype,
__tostring = function(self)
return self.__componentName
end,
}
type React_BaseComponent = React_Component<any, any> & {
extend: (self: React_BaseComponent, name: string) -> React_Component<any, any>,
}
local Component = (
setmetatable({ __componentName = "Component" }, componentClassMetatable) :: any
) :: React_BaseComponent
local InstancePoolSize = if not ReactGlobals.__TESTEZ_RUNNING_TEST__ then 900 else 0
local InstancePoolIndex = 1
local InstancePool = table.create(InstancePoolSize)
for i = 1, InstancePoolSize do
table.insert(InstancePool, {
props = nil,
context = nil,
state = UninitializedState,
__refs = emptyObject,
__updater = ReactNoopUpdateQueue,
})
end
local function setStateInInit(
componentInstance: React_Component<any, any>,
statePayload: any,
callback: nil
): ()
if __DEV__ and (callback :: any) ~= nil then
console.warn(
"Received a `callback` argument to `setState` during initialization of "
.. '"%s". The callback behavior is not supported when using `setState` '
.. "in `init`.\n\nConsider defining similar behavior in a "
.. "`compontentDidMount` method instead.",
componentInstance.__componentName
)
end
local typeStatePayload = statePayload and type(statePayload)
if
statePayload == nil
or (typeStatePayload ~= "table" and typeStatePayload ~= "function")
then
error(
"setState(...): takes an object of state variables to update or a "
.. "function which returns an object of state variables."
)
end
local prevState = componentInstance.state
local partialState
if typeStatePayload == "function" then
partialState = statePayload(prevState, componentInstance.props)
else
partialState = statePayload
end
componentInstance.state = Object.assign({}, prevState, partialState)
end
function Component:extend(name): React_Component<any, any>
if name == nil then
if __COMPAT_WARNINGS__ then
console.warn(
"Component:extend() accepting no arguments is deprecated, and will "
.. "not be supported in a future version of Roact. Please provide an explicit name."
)
end
name = ""
elseif type(name) ~= "string" then
error("Component class name must be a string")
end
local class = {
__componentName = name,
setState = self.setState,
forceUpdate = self.forceUpdate,
init = nil,
}
class.__index = class
function class.__ctor<P>(props: P, context, updater): React_Component<P, any>
local instance
if InstancePoolIndex <= InstancePoolSize then
instance = InstancePool[InstancePoolIndex]
instance.props = props :: any
instance.context = context
InstancePool[InstancePoolIndex] = nil
InstancePoolIndex += 1
else
instance = {
props = props :: any,
context = context,
state = UninitializedState,
__refs = emptyObject,
__updater = updater or ReactNoopUpdateQueue,
}
end
instance = setmetatable(instance, class)
if class.init and type(class.init) == "function" then
instance.setState = setStateInInit
class.init(instance, props, context)
instance.setState = nil :: any
end
return (instance :: any) :: React_Component<P, any>
end
setmetatable(class, getmetatable(self :: any))
return (class :: any) :: React_Component<any, any>
end
function Component:setState(partialState, callback)
if
partialState ~= nil
and type(partialState) ~= "table"
and type(partialState) ~= "function"
then
error(
"setState(...): takes an object of state variables to update or a "
.. "function which returns an object of state variables."
)
end
self.__updater.enqueueSetState(self, partialState, callback, "setState")
end
function Component:forceUpdate(callback)
self.__updater.enqueueForceUpdate(self, callback, "forceUpdate")
end
if __DEV__ then
local deprecatedAPIs = {
isMounted = {
"isMounted",
"Instead, make sure to clean up subscriptions and pending requests in "
.. "componentWillUnmount to prevent memory leaks.",
},
replaceState = {
"replaceState",
"Refactor your code to use setState instead (see "
.. "https://github.com/facebook/react/issues/3236).",
},
} :: any
local defineDeprecationWarning = function(methodName, info)
(Component :: any)[methodName] = function()
console.warn(
"%s(...) is deprecated in plain JavaScript React classes. %s",
info[1],
info[2]
)
return nil
end
end
for fnName, _ in deprecatedAPIs do
if deprecatedAPIs[fnName] ~= nil then
defineDeprecationWarning(fnName, deprecatedAPIs[fnName])
end
end
end
local PureComponent = Component:extend("PureComponent") :: React_BaseComponent;
(PureComponent :: any).extend = Component.extend
local pureComponentClassPrototype = {
isReactComponent = true,
isPureReactComponent = true,
}
setmetatable(PureComponent, {
__newindex = handleNewLifecycle,
__index = pureComponentClassPrototype,
__tostring = function(self)
return self.__componentName
end,
})
return {
Component = Component,
PureComponent = PureComponent :: typeof(Component),
}
end
end)())
__register("React/ReactBinding.roblox", (function()
local script = __makeProxy({"React","ReactBinding.roblox"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local LuauPolyfill = __require(Packages.LuauPolyfill)
local ReactSymbols = __require(Packages.Shared).ReactSymbols
local ReactTypes = __require(Packages.Shared)
type Binding<T> = ReactTypes.ReactBinding<T>
type BindingUpdater<T> = ReactTypes.ReactBindingUpdater<T>
local Symbol = LuauPolyfill.Symbol
local createSignal = __require(script.Parent["createSignal.roblox"])
local BindingImpl = Symbol("BindingImpl")
type BindingInternal<T> = {
["$$typeof"]: typeof(ReactSymbols.REACT_BINDING_TYPE),
value: T,
getValue: (BindingInternal<T>) -> T,
map: <U>(BindingInternal<T>, (T) -> U) -> any,
update: (T) -> (),
subscribe: ((T) -> ()) -> () -> (),
}
local BindingInternalApi = {}
local bindingPrototype = {}
function bindingPrototype.getValue<T>(binding: BindingInternal<T>): T
return BindingInternalApi.getValue(binding)
end
function bindingPrototype.map<T, U>(
binding: BindingInternal<T>,
predicate: (T) -> U
): Binding<U>
return BindingInternalApi.map(binding, predicate)
end
local BindingPublicMeta = {
__index = bindingPrototype,
__tostring = function(self)
return string.format("RoactBinding(%s)", tostring(self:getValue()))
end,
}
function BindingInternalApi.update<T>(binding: any, newValue: T)
return (binding[BindingImpl] :: BindingInternal<T>).update(newValue)
end
function BindingInternalApi.subscribe<T>(binding: any, callback: (T) -> ())
return (binding[BindingImpl] :: BindingInternal<T>).subscribe(callback)
end
function BindingInternalApi.getValue<T>(binding: any): T
return (binding[BindingImpl] :: BindingInternal<T>):getValue()
end
function BindingInternalApi.create<T>(initialValue: T): (Binding<T>, BindingUpdater<T>)
local subscribe, fire = createSignal()
local impl = {
value = initialValue,
subscribe = subscribe,
}
function impl.update(newValue: T)
impl.value = newValue
fire(newValue)
end
function impl.getValue()
return impl.value
end
local source
if ReactGlobals.__DEV__ then
source = debug.traceback("Binding created at:", 3)
end
return (setmetatable({
["$$typeof"] = ReactSymbols.REACT_BINDING_TYPE,
[BindingImpl] = impl,
_source = source,
}, BindingPublicMeta) :: any) :: Binding<T>,
impl.update
end
function BindingInternalApi.map<T, U>(
upstreamBinding: BindingInternal<T>,
predicate: (T) -> U
): Binding<U>
if ReactGlobals.__DEV__ then
assert(
typeof(upstreamBinding) == "table"
and upstreamBinding["$$typeof"] == ReactSymbols.REACT_BINDING_TYPE,
"Expected `self` to be a binding"
)
assert(typeof(predicate) == "function", "Expected arg #1 to be a function")
end
local impl = {}
function impl.subscribe(callback)
return BindingInternalApi.subscribe(upstreamBinding, function(newValue)
callback(predicate(newValue))
end)
end
function impl.update(newValue)
error("Bindings created by Binding:map(fn) cannot be updated directly", 2)
end
function impl.getValue()
return predicate(upstreamBinding:getValue())
end
local source
if ReactGlobals.__DEV__ then
source = debug.traceback("Mapped binding created at:", 3)
end
return (
setmetatable({
["$$typeof"] = ReactSymbols.REACT_BINDING_TYPE,
[BindingImpl] = impl,
_source = source,
}, BindingPublicMeta) :: any
) :: Binding<U>
end
function BindingInternalApi.join<T>(
upstreamBindings: { [string | number]: Binding<any> }
): Binding<T>
if ReactGlobals.__DEV__ then
assert(typeof(upstreamBindings) == "table", "Expected arg #1 to be of type table")
for key, value in upstreamBindings do
if
typeof(value) ~= "table"
or (value :: any)["$$typeof"] ~= ReactSymbols.REACT_BINDING_TYPE
then
local message = ("Expected arg #1 to contain only bindings, but key %q had a non-binding value"):format(
tostring(key)
)
error(message, 2)
end
end
end
local impl = {}
local function getValue()
local value = {}
for key, upstream in pairs(upstreamBindings) do
value[key] = upstream:getValue()
end
return value
end
function impl.subscribe(callback)
local disconnects: any = {}
for key, upstream in upstreamBindings do
disconnects[key] = BindingInternalApi.subscribe(upstream, function(newValue)
callback(getValue())
end)
end
return function()
if disconnects == nil then
return
end
for _, disconnect in disconnects do
disconnect()
end
disconnects = nil
end
end
function impl.update(newValue)
error("Bindings created by joinBindings(...) cannot be updated directly", 2)
end
function impl.getValue()
return getValue()
end
local source
if ReactGlobals.__DEV__ then
source = debug.traceback("Joined binding created at:", 2)
end
return (
setmetatable({
["$$typeof"] = ReactSymbols.REACT_BINDING_TYPE,
[BindingImpl] = impl,
_source = source,
}, BindingPublicMeta) :: any
) :: Binding<T>
end
return BindingInternalApi
end
end)())
__register("React/ReactChildren", (function()
local script = __makeProxy({"React","ReactChildren"})
return function()
local Packages = script.Parent.Parent
local ReactTypes = __require(Packages.Shared)
type ReactNodeList = ReactTypes.ReactNodeList
type React_Node = ReactTypes.React_Node
type ReactElement<P, T> = ReactTypes.ReactElement<P, T>
local invariant = __require(Packages.Shared).invariant
local ReactSymbols = __require(Packages.Shared).ReactSymbols
local getIteratorFn = ReactSymbols.getIteratorFn
local REACT_ELEMENT_TYPE = ReactSymbols.REACT_ELEMENT_TYPE
local REACT_PORTAL_TYPE = ReactSymbols.REACT_PORTAL_TYPE
local LuauPolyfill = __require(Packages.LuauPolyfill)
local Array = LuauPolyfill.Array
type Array<T> = LuauPolyfill.Array<T>
type Object = LuauPolyfill.Object
local ReactElement = __require(script.Parent.ReactElement)
local isValidElement = ReactElement.isValidElement
local cloneAndReplaceKey = ReactElement.cloneAndReplaceKey
local SEPARATOR = "."
local SUBSEPARATOR = ":"
local function escape(key: string): string
local escapedString = string.gsub(key, "=", "=0")
escapedString = string.gsub(escapedString, ":", "=2")
return "$" .. escapedString
end
local function escapeUserProvidedKey(text: string): string
return text
end
local function getElementKey(element: any, index: number): string
if typeof(element) == "table" and element ~= nil and element.key ~= nil then
return escape(tostring(element.key))
end
return tostring(index)
end
local function mapIntoArray(
children: ReactNodeList?,
array: Array<React_Node>,
escapedPrefix: string,
nameSoFar: string,
callback: (React_Node?) -> ReactNodeList?
): number
local type = typeof(children)
if type == "nil" or type == "boolean" or type == "userdata" then
children = nil
end
local invokeCallback = false
if children == nil then
invokeCallback = true
else
if type == "string" or type == "number" then
invokeCallback = true
elseif type == "table" then
local childrenType = (children :: any)["$$typeof"]
if
childrenType == REACT_ELEMENT_TYPE
or childrenType == REACT_PORTAL_TYPE
then
invokeCallback = true
end
end
end
if invokeCallback then
local child = children
local mappedChild = callback(child)
local childKey = if nameSoFar == ""
then SEPARATOR .. getElementKey(child, 1)
else nameSoFar
if Array.isArray(mappedChild) then
local escapedChildKey = ""
if childKey ~= nil then
escapedChildKey = escapeUserProvidedKey(childKey) .. "/"
end
mapIntoArray(mappedChild, array, escapedChildKey, "", function(c)
return c
end)
elseif mappedChild ~= nil then
if isValidElement(mappedChild :: any) then
local mappedChildKey = (mappedChild :: ReactElement<Object, any>).key
mappedChild = cloneAndReplaceKey(
mappedChild :: ReactElement<Object, any>,
escapedPrefix
.. (
if mappedChildKey
and (
not child
or (child :: ReactElement<Object, any>).key
~= mappedChildKey
)
then escapeUserProvidedKey(tostring(mappedChildKey)) .. "/"
else ""
)
.. childKey
)
end
table.insert(array, mappedChild)
end
return 1
end
local child
local nextName
local subtreeCount = 0
local nextNamePrefix = if nameSoFar == ""
then SEPARATOR
else nameSoFar .. SUBSEPARATOR
if Array.isArray(children) then
for i = 1, #(children :: Array<React_Node>) do
child = (children :: Array<React_Node>)[i]
nextName = nextNamePrefix .. getElementKey(child, i)
subtreeCount += mapIntoArray(child, array, escapedPrefix, nextName, callback)
end
else
local iteratorFn = getIteratorFn(children)
if typeof(iteratorFn) == "function" then
local iterableChildren: Object & {
entries: any,
} = children :: any
local iterator = iteratorFn(iterableChildren)
local step
local ii = 1
step = iterator.next()
while not step.done do
child = step.value
nextName = nextNamePrefix .. getElementKey(child, ii)
ii += 1
subtreeCount += mapIntoArray(
child,
array,
escapedPrefix,
nextName,
callback
)
step = iterator.next()
end
end
end
return subtreeCount
end
type MapFunc = (child: React_Node?, index: number) -> ReactNodeList?
local function mapChildren(
children: ReactNodeList?,
func: MapFunc,
context: any
): Array<React_Node>?
if children == nil then
return nil
end
local result = {}
local count = 1
mapIntoArray(children, result, "", "", function(child)
local mapFuncResult = func(child, count)
count += 1
return mapFuncResult
end)
return result
end
local function countChildren(children: ReactNodeList?): number
local n = 0
mapChildren(children, function()
n += 1
return
end)
return n
end
type ForEachFunc = (child: React_Node?, index: number) -> ()
local function forEachChildren(
children: ReactNodeList?,
forEachFunc: ForEachFunc,
forEachContext: any
)
mapChildren(children, function(...)
forEachFunc(...)
return
end, forEachContext)
end
local function toArray(children: ReactNodeList?): Array<React_Node>
return mapChildren(children, function(child)
return child
end) or {}
end
local function onlyChild(children)
invariant(
isValidElement(children),
"React.Children.only expected to receive a single React element child."
)
return children
end
return {
forEach = forEachChildren,
map = mapChildren,
count = countChildren,
only = onlyChild,
toArray = toArray,
}
end
end)())
__register("React/ReactContext", (function()
local script = __makeProxy({"React","ReactContext"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local Shared = __require(Packages.Shared)
local console = Shared.console
local ReactSymbols = __require(Packages.Shared).ReactSymbols
local REACT_PROVIDER_TYPE = ReactSymbols.REACT_PROVIDER_TYPE
local REACT_CONTEXT_TYPE = ReactSymbols.REACT_CONTEXT_TYPE
type ReactContext<T> = Shared.ReactContext<T>
type ReactProviderType<T> = Shared.ReactProviderType<T>
local exports = {}
exports.createContext = function<T>(
defaultValue: T,
calculateChangedBits: ((a: T, b: T) -> number)?
): ReactContext<T>
local context: ReactContext<any> = {
["$$typeof"] = REACT_CONTEXT_TYPE,
_calculateChangedBits = calculateChangedBits,
_currentValue = defaultValue,
_currentValue2 = defaultValue,
_threadCount = 0,
Provider = (nil :: any) :: ReactProviderType<T>,
Consumer = (nil :: any) :: ReactContext<T>,
displayName = nil,
_currentRenderer = nil,
_currentRenderer2 = nil,
}
context.Provider = {
["$$typeof"] = REACT_PROVIDER_TYPE,
_context = context,
}
local hasWarnedAboutDisplayNameOnConsumer = false
if ReactGlobals.__DEV__ then
local Consumer = {
["$$typeof"] = REACT_CONTEXT_TYPE,
_context = context,
_calculateChangedBits = context._calculateChangedBits,
}
setmetatable(Consumer, {
__index = function(self, key)
if key == "_currentValue" then
return context._currentValue
elseif key == "_currentValue2" then
return context._currentValue2
elseif key == "_threadCount" then
return context._threadCount
elseif key == "displayName" then
return context.displayName
end
return nil
end,
__newindex = function(self, key, value)
if key == "_currentValue" then
context._currentValue = value
elseif key == "_currentValue2" then
context._currentValue2 = value
elseif key == "_threadCount" then
context._threadCount = value
elseif key == "displayName" then
if not hasWarnedAboutDisplayNameOnConsumer then
console.warn(
"Setting `displayName` on Context.Consumer has no effect. "
.. "You should set it directly on the context with Context.displayName = "
.. value
.. "."
)
hasWarnedAboutDisplayNameOnConsumer = true
end
end
end,
})
context.Consumer = (Consumer :: any) :: ReactContext<any>
else
context.Consumer = context
end
if ReactGlobals.__DEV__ then
context._currentRenderer = nil
context._currentRenderer2 = nil
end
return context
end
return exports
end
end)())
__register("React/ReactCreateRef", (function()
local script = __makeProxy({"React","ReactCreateRef"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local ReactTypes = __require(Packages.Shared)
type RefObject = ReactTypes.RefObject
local Binding = __require(script.Parent["ReactBinding.roblox"])
local exports = {}
exports.createRef = function(): RefObject
local binding, _ = Binding.create(nil)
local ref = {}
if ReactGlobals.__DEV__ then
binding._source = debug.traceback("Ref created at:", 1)
end
setmetatable(ref, {
__index = function(self, key)
if key == "current" then
return binding:getValue()
else
return (binding :: any)[key]
end
end,
__newindex = function(self, key, value)
if key == "current" then
Binding.update(binding, value)
end
(binding :: any)[key] = value
end,
__tostring = function(self)
return string.format("Ref(%s)", tostring(binding:getValue()))
end,
})
return (ref :: any) :: RefObject
end
return exports
end
end)())
__register("React/ReactElement", (function()
local script = __makeProxy({"React","ReactElement"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local LuauPolyfill = __require(Packages.LuauPolyfill)
local Error = LuauPolyfill.Error
type Object = LuauPolyfill.Object
local __DEV__ = ReactGlobals.__DEV__ :: boolean
local console = __require(Packages.Shared).console
local ReactTypes = __require(Packages.Shared)
type React_StatelessFunctionalComponent<P> = ReactTypes.React_StatelessFunctionalComponent<
P
>
type React_ComponentType<P> = ReactTypes.React_ComponentType<P>
type React_AbstractComponent<P, T> = ReactTypes.React_AbstractComponent<P, T>
type ReactProviderType<T> = ReactTypes.ReactProviderType<T>
type React_ElementProps<ElementType> = ReactTypes.React_ElementProps<ElementType>
type React_Node = ReactTypes.React_Node
type ReactElement<P = Object, T = any> = ReactTypes.ReactElement<P, T>
type ReactContext<T> = ReactTypes.ReactContext<T>
type Source = ReactTypes.Source
local ReactLazy = __require(script.Parent.ReactLazy)
type LazyComponent<T, P> = ReactLazy.LazyComponent<T, P>
local getComponentName = __require(Packages.Shared).getComponentName
local REACT_ELEMENT_TYPE = __require(Packages.Shared).ReactSymbols.REACT_ELEMENT_TYPE
local ReactCurrentOwner = __require(Packages.Shared).ReactSharedInternals.ReactCurrentOwner
local RESERVED_PROPS = {
key = true,
ref = true,
__self = true,
__source = true,
}
local specialPropKeyWarningShown, specialPropRefWarningShown, didWarnAboutStringRefs
if __DEV__ then
didWarnAboutStringRefs = {}
end
local exports = {}
local function hasValidRef(config)
if __DEV__ then
if config.ref ~= nil and type(config.ref) == "table" then
if (config.ref :: any).isReactWarning then
return false
end
end
end
return config.ref ~= nil
end
local function hasValidKey(config)
if __DEV__ then
if config.key ~= nil and type(config.key) == "table" then
if (config.key :: any).isReactWarning then
return false
end
end
end
return config.key ~= nil
end
local reactWarning = { isReactWarning = true }
local function defineKeyPropWarningGetter(props, displayName: string)
local warnAboutAccessingKey = function()
if __DEV__ then
if not specialPropKeyWarningShown then
specialPropKeyWarningShown = true
console.error(
"%s: `key` is not a prop. Trying to access it will result "
.. "in `nil` being returned. If you need to access the same "
.. "value within the child component, you should pass it as a different "
.. "prop. (https://reactjs.org/link/special-props)",
displayName
)
end
end
end
props.key = nil
setmetatable(props, {
__index = function(t, k)
if k == "key" then
warnAboutAccessingKey()
return reactWarning
end
return nil :: any
end,
})
end
local function defineRefPropWarningGetter(props, displayName: string)
local warnAboutAccessingRef = function()
if __DEV__ then
if not specialPropRefWarningShown then
specialPropRefWarningShown = true
console.error(
"%s: `ref` is not a prop. Trying to access it will result "
.. "in `nil` being returned. If you need to access the same "
.. "value within the child component, you should pass it as a different "
.. "prop. (https://reactjs.org/link/special-props)",
displayName
)
end
end
end
props.ref = nil
setmetatable(props :: any, {
__index = function(t, k)
if k == "ref" then
warnAboutAccessingRef()
return reactWarning
end
return nil :: any
end,
})
end
local function warnIfStringRefCannotBeAutoConverted(config)
if __DEV__ then
if
type(config.ref) == "string" and ReactCurrentOwner.current
then
local componentName = getComponentName(ReactCurrentOwner.current.type)
if not didWarnAboutStringRefs[componentName] then
error(
string.format(
'Component "%s" contains the string ref "%s". '
.. "Support for string refs has been removed. "
.. "We recommend using useRef() or createRef() instead. "
.. "Learn more about using refs safely here: "
.. "https://reactjs.org/link/strict-mode-string-ref",
componentName or "Unknown",
config.ref
)
)
end
end
end
end
local function ReactElement<P, T>(
type_: T,
key,
ref,
self,
source: Source?,
owner,
props: P
): ReactElement<P, T>
local element = {
type = type_,
key = key,
ref = ref,
props = props,
_owner = owner,
}
element["$$typeof"] = REACT_ELEMENT_TYPE
if __DEV__ then
local nonEnumerable = {
validated = false,
}
element._store = setmetatable({}, {
__index = nonEnumerable,
__newindex = function(table, key, value)
if key == "validated" then
nonEnumerable.validated = value
else
rawset(table, key, value)
end
end,
})
setmetatable(element, {
__index = {
_self = self,
_source = source,
},
})
end
return element :: any
end
exports.jsx = function(type, config, maybeKey)
error("JSX is currently unsupported")
end
exports.jsxDEV = function(type, config, maybeKey, source, self)
error("JSX is currently unsupported")
return nil
end
local function createElement<P, T>(
type_: React_StatelessFunctionalComponent<P> | React_ComponentType<P> | React_AbstractComponent<P, T> | ReactContext<any> | LazyComponent<T, P> | ReactProviderType<any> | string,
config: P?,
...: React_Node | (...any) -> React_Node
): ReactElement<P, T>
local props = if config ~= nil then table.clone(config :: any) :: any else {}
local key: (string | number)? = nil
local ref = nil
local self = nil
local source: Source? = nil
if config ~= nil then
if hasValidRef(config :: any) then
ref = ((config :: any) :: React_ElementProps<T>).ref
if __DEV__ then
warnIfStringRefCannotBeAutoConverted(
(config :: any) :: React_ElementProps<T>
)
end
end
if hasValidKey(config :: any) then
local configKey = (config :: any).key
if type(configKey) == "number" then
key = configKey
else
key = tostring(configKey :: any)
end
end
source = if ((config :: any) :: React_ElementProps<T>).__source == nil
then nil
else ((config :: any) :: React_ElementProps<T>).__source
if props.key ~= nil then
props.key = nil
end
if props.ref ~= nil then
props.ref = nil
end
if props.__self ~= nil then
props.__self = nil
end
if props.__source ~= nil then
props.__source = nil
end
end
local childrenLength = select("#", ...)
if childrenLength == 1 then
props.children = select(1, ...)
elseif childrenLength > 1 then
local childArray = table.create(childrenLength)
for i = 1, childrenLength do
local toInsert = select(i, ...)
table.insert(childArray, toInsert)
end
if __DEV__ then
table.freeze(childArray)
end
props.children = childArray
end
if
type(type_ :: any) == "table"
and (type_ :: T & React_ComponentType<P>).defaultProps
then
local defaultProps = (type_ :: T & React_ComponentType<P>).defaultProps :: P
for propName, _ in (defaultProps :: any) :: Object do
if props[propName] == nil then
props[propName] = ((defaultProps :: any) :: Object)[propName]
end
end
end
if __DEV__ then
if key or ref then
local displayName
if type(type_) == "function" then
displayName = debug.info(type_, "n") or "<function>"
elseif type(type_) == "table" then
displayName = (
(type_ :: T & React_ComponentType<P>).displayName
or (type_ :: T & React_ComponentType<P>).name
) or "Unknown"
else
displayName = type_ :: string
end
if key then
defineKeyPropWarningGetter(props, displayName)
end
if ref then
defineRefPropWarningGetter(props, displayName)
end
end
if source == nil then
source = {
fileName = debug.info(3, "s"),
lineNumber = debug.info(3, "l"),
}
end
end
return ReactElement(
type_,
key,
ref,
self,
source,
ReactCurrentOwner.current,
props
) :: any
end
exports.createElement = createElement
exports.cloneAndReplaceKey = function<P, T>(
oldElement: ReactElement<P, T>,
newKey: any
): ReactElement<P, T>
local newElement = ReactElement(
oldElement.type,
newKey,
oldElement.ref,
oldElement._self,
oldElement._source,
oldElement._owner,
oldElement.props
)
return newElement
end
exports.cloneElement = function<P, T>(
element: ReactElement<P, T>,
config: (P & React_ElementProps<T>)?,
...: React_Node
): ReactElement<P, T>
if element == nil then
error(
Error.new(
"React.cloneElement(...): The argument must be a React element, but you passed "
.. tostring(element)
)
)
end
local elementProps = element.props
local props: P & React_ElementProps<T> = if elementProps ~= nil
then table.clone(elementProps :: P & React_ElementProps<T>) :: any
else {} :: P & React_ElementProps<T>
local key = element.key
local ref = element.ref
local source = element._source
local owner = element._owner
if config ~= nil then
local configRef = config.ref
if configRef ~= nil then
ref = configRef
owner = ReactCurrentOwner.current
else
hasValidRef(config)
end
local configKey = config.key
if configKey ~= nil then
if type(configKey) == "number" then
key = configKey
else
key = configKey :: any or "nil"
end
else
hasValidKey((config :: any) :: React_ElementProps<T>)
end
end
local elementType = element.type
local defaultProps: P? = if type(elementType) == "table"
then elementType.defaultProps
else nil
if config ~= nil then
for propName, _ in config :: any do
if (config :: any)[propName] ~= nil and not RESERVED_PROPS[propName] then
if (config :: any)[propName] == nil and defaultProps ~= nil then
(props :: any)[propName] = (defaultProps :: any)[propName]
else
(props :: any)[propName] = (config :: any)[propName]
end
end
end
end
local childrenLength = select("#", ...)
if childrenLength == 1 then
props.children = select(1, ...)
elseif childrenLength > 1 then
(props :: any).children = { ... }
end
return ReactElement(
element.type,
key,
ref,
nil,
source,
owner,
(props :: any) :: P & React_ElementProps<T>
) :: any
end
exports.isValidElement = function(object)
return type(object) == "table" and object["$$typeof"] == REACT_ELEMENT_TYPE
end
return exports
end
end)())
__register("React/ReactElementValidator", (function()
local script = __makeProxy({"React","ReactElementValidator"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local LuauPolyfill = __require(Packages.LuauPolyfill)
local Array = LuauPolyfill.Array
type Array<T> = LuauPolyfill.Array<T>
local Boolean = LuauPolyfill.Boolean
local Object = LuauPolyfill.Object
type Object = LuauPolyfill.Object
local console = __require(Packages.Shared).console
local inspect = LuauPolyfill.util.inspect
type Function = (...any) -> ...any
local ReactTypes = __require(Packages.Shared)
type React_StatelessFunctionalComponent<P> = ReactTypes.React_StatelessFunctionalComponent<
P
>
type React_ComponentType<P> = ReactTypes.React_ComponentType<P>
type React_Element<ElementType> = ReactTypes.React_Element<ElementType>
type React_ElementProps<ElementType> = ReactTypes.React_ElementProps<ElementType>
type ReactElement<P, T> = ReactTypes.ReactElement<P, T>
type React_Node = ReactTypes.React_Node
type Source = ReactTypes.Source
local isValidElementType = __require(Packages.Shared).isValidElementType
local getComponentName = __require(Packages.Shared).getComponentName
local ReactSymbols = __require(Packages.Shared).ReactSymbols
local getIteratorFn = ReactSymbols.getIteratorFn
local _REACT_FORWARD_REF_TYPE = ReactSymbols.REACT_FORWARD_REF_TYPE
local _REACT_MEMO_TYPE = ReactSymbols.REACT_MEMO_TYPE
local REACT_FRAGMENT_TYPE = ReactSymbols.REACT_FRAGMENT_TYPE
local REACT_ELEMENT_TYPE = ReactSymbols.REACT_ELEMENT_TYPE
local warnAboutSpreadingKeyToJSX =
__require(Packages.Shared).ReactFeatureFlags.warnAboutSpreadingKeyToJSX
local checkPropTypes = __require(Packages.Shared).checkPropTypes
local ReactCurrentOwner = __require(Packages.Shared).ReactSharedInternals.ReactCurrentOwner
local ReactElement = __require(script.Parent.ReactElement)
local isValidElement = ReactElement.isValidElement
local createElement = ReactElement.createElement
local cloneElement = ReactElement.cloneElement
local jsxDEV = ReactElement.jsxDEV
local setExtraStackFrame =
__require(Packages.Shared).ReactSharedInternals.ReactDebugCurrentFrame.setExtraStackFrame
local describeUnknownElementTypeFrameInDEV =
__require(Packages.Shared).ReactComponentStackFrame.describeUnknownElementTypeFrameInDEV
local exports = {}
local function setCurrentlyValidatingElement(element: ReactElement<any, any> | nil)
if ReactGlobals.__DEV__ then
if element then
local owner = element._owner
local ownerArgument = nil
if owner then
ownerArgument = owner.type
end
local stack = describeUnknownElementTypeFrameInDEV(
element.type,
element._source,
ownerArgument
);
(setExtraStackFrame :: (...any) -> ())(stack)
else
(setExtraStackFrame :: (...any) -> ())(nil)
end
end
end
local propTypesMisspellWarningShown
if ReactGlobals.__DEV__ then
propTypesMisspellWarningShown = false
end
local function hasOwnProperty(object, key)
return object[key] ~= nil
end
local function getDeclarationErrorAddendum(): string
if ReactCurrentOwner.current then
local name = getComponentName(ReactCurrentOwner.current.type)
if name then
return "\n\nCheck the render method of `" .. name .. "`."
end
end
return ""
end
local function getSourceInfoErrorAddendum(source: Source | nil): string
if source ~= nil then
local fileName = string.gsub(source.fileName, "^.*[\\/]", "")
local lineNumber = source.lineNumber
return "\n\nCheck your code at " .. fileName .. ":" .. lineNumber .. "."
end
return ""
end
local function getSourceInfoErrorAddendumForProps(
elementProps: React_ElementProps<any>?
): string
if elementProps ~= nil then
return getSourceInfoErrorAddendum(elementProps.__source)
end
return ""
end
local ownerHasKeyUseWarning = {}
local function getCurrentComponentErrorInfo(
parentType: React_ComponentType<any> | string | Function
): string
local info = getDeclarationErrorAddendum()
if not Boolean.toJSBoolean(info) then
local parentName = if typeof(parentType) == "string"
then parentType
else if typeof(parentType) == "table"
then parentType.displayName or parentType.name
else nil
if not parentName and typeof(parentType) == "function" then
local functionName = debug.info(parentType, "n")
parentName = if functionName ~= "" then functionName else nil
end
if parentName then
info = string.format(
"\n\nCheck the top-level render call using <%s>.",
parentName
)
end
end
return info
end
local function validateExplicitKey<P>(
element: ReactElement<P, any>,
parentType,
tableKey: any?
)
if element._store == nil or element._store.validated then
return
end
(element._store :: any).validated = true
if (element.key ~= nil) ~= (tableKey ~= nil) then
return
end
local currentComponentErrorInfo = getCurrentComponentErrorInfo(parentType)
if ownerHasKeyUseWarning[currentComponentErrorInfo] then
return
end
ownerHasKeyUseWarning[currentComponentErrorInfo] = true
local childOwner = ""
if element and element._owner and element._owner ~= ReactCurrentOwner.current then
childOwner = string.format(
" It was passed a child from %s.",
tostring(getComponentName(element._owner.type))
)
end
if ReactGlobals.__DEV__ then
setCurrentlyValidatingElement(element)
if element.key ~= nil and tableKey ~= nil then
console.error(
'Child element received a "key" prop ("%s") in addition to a key in '
.. 'the "children" table of its parent ("%s"). Please provide only '
.. 'one key definition. When both are present, the "key" prop '
.. "will take precedence."
.. "%s%s See https://reactjs.org/link/warning-keys for more information.",
tostring(element.key),
tostring(tableKey),
currentComponentErrorInfo,
childOwner
)
else
console.error(
'Each child in a list should have a unique "key" prop.'
.. "%s%s See https://reactjs.org/link/warning-keys for more information.",
currentComponentErrorInfo,
childOwner
)
end
setCurrentlyValidatingElement(nil)
end
end
local function validateChildKeys(node, parentType)
if typeof(node) ~= "table" then
return
end
if Array.isArray(node) then
for i = 1, #node do
local child = node[i]
if isValidElement(child) then
validateExplicitKey(child :: ReactElement<any, any>, parentType)
end
end
elseif isValidElement(node) then
if node._store then
node._store.validated = true
end
elseif node then
local iteratorFn = getIteratorFn(node)
if typeof(iteratorFn) == "function" then
if iteratorFn ~= node.entries then
local iterator = iteratorFn(node)
local step = iterator.next()
while not step.done do
if isValidElement(step.value) then
validateExplicitKey(step.value, parentType, step.key)
end
step = iterator.next()
end
end
end
end
end
local function validatePropTypes<P>(element: ReactElement<P, any>)
if
ReactGlobals.__DEV__
or ReactGlobals.__DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__
then
local type = element.type
if type == nil or typeof(type) == "string" then
return
end
local propTypes
local validateProps
if typeof(type) == "function" then
return
elseif typeof(type) == "table" then
propTypes = type.propTypes
validateProps = type.validateProps
else
return
end
if propTypes or validateProps then
local name = getComponentName(type)
checkPropTypes(propTypes, validateProps, element.props, "prop", name, element)
elseif (type :: any).PropTypes ~= nil and not propTypesMisspellWarningShown then
propTypesMisspellWarningShown = true
local name = getComponentName(type)
console.error(
"Component %s declared `PropTypes` instead of `propTypes`. Did you misspell the property assignment?",
name or "Unknown"
)
end
if (type :: any).getDefaultProps ~= nil then
console.error(
"getDefaultProps is only used on classic React.createClass "
.. "definitions. Use a static property named `defaultProps` instead."
)
end
end
end
local function validateFragmentProps<P>(fragment: ReactElement<P & Object, any>)
if ReactGlobals.__DEV__ then
local keys = Object.keys(fragment.props)
for i = 1, #keys do
local key = keys[i]
if key ~= "children" and key ~= "key" then
setCurrentlyValidatingElement(fragment)
console.error(
"Invalid prop `%s` supplied to `React.Fragment`. "
.. "React.Fragment can only have `key` and `children` props.",
key
)
setCurrentlyValidatingElement(nil)
break
end
end
if fragment.ref ~= nil then
setCurrentlyValidatingElement(fragment)
console.error("Invalid attribute `ref` supplied to `React.Fragment`.")
setCurrentlyValidatingElement(nil)
end
end
end
local function jsxWithValidation<P, T>(
type: T,
props: P & React_ElementProps<T>,
key: string | number,
isStaticChildren,
source: Source?,
self: any?
)
local validType = isValidElementType(type)
if not validType then
local info = ""
if type == nil or (typeof(type) == "table" and #Object.keys(type) == 0) then
info ..= (" You likely forgot to export your component from the file " .. "it's defined in, or you might have mixed up default and named imports.")
end
local sourceInfo = getSourceInfoErrorAddendum(source)
if sourceInfo then
info ..= sourceInfo
else
info ..= getDeclarationErrorAddendum()
end
local typeString
if type == nil then
typeString = "nil"
elseif Array.isArray(type) then
typeString = "array"
elseif typeof(type) == "table" and type["$$typeof"] == REACT_ELEMENT_TYPE then
typeString = string.format("<%s />", getComponentName(type.type) or "Unknown")
info ..= " Did you accidentally export a JSX literal or Element instead of a component?"
else
typeString = typeof(type)
info ..= "\n" .. inspect(type)
end
if ReactGlobals.__DEV__ then
console.error(
"React.jsx: type is invalid -- expected a string (for "
.. "built-in components) or a class/function (for composite "
.. "components) but got: %s.%s",
typeString,
info
)
end
end
local element = jsxDEV(type, props, key, source, self)
if element == nil then
return element
end
if validType then
local children = props.children
if children ~= nil then
if isStaticChildren then
if Array.isArray(children) then
for i = 1, #children do
validateChildKeys(children[i], type :: any)
end
Object.freeze(children)
else
if ReactGlobals.__DEV__ then
console.error(
"React.jsx: Static children should always be an array. "
.. "You are likely explicitly calling React.jsxs or React.jsxDEV. "
.. "Use the Babel transform instead."
)
end
end
else
validateChildKeys(children, type :: any)
end
end
end
if ReactGlobals.__DEV__ then
if warnAboutSpreadingKeyToJSX then
if hasOwnProperty(props, "key") then
console.error(
"React.jsx: Spreading a key to JSX is a deprecated pattern. "
.. "Explicitly pass a key after spreading props in your JSX call. "
.. "E.g. <%s {...props} key={key} />",
getComponentName(type) or "ComponentName"
)
end
end
end
if type == REACT_FRAGMENT_TYPE then
validateFragmentProps((element :: any) :: ReactElement<any, any>)
else
validatePropTypes((element :: any) :: ReactElement<any, any>)
end
return element
end
exports.jsxWithValidation = jsxWithValidation
exports.jsxWithValidationStatic = function(type, props, key)
return jsxWithValidation(type, props, key, true)
end
exports.jsxWithValidationDynamic = function(type, props, key)
return jsxWithValidation(type, props, key, false)
end
local function createElementWithValidation<P, T>(
type_: React_StatelessFunctionalComponent<
P
> | React_ComponentType<P> | string,
props: (P & React_ElementProps<T>)?,
...: React_Node
): ReactElement<P, T>
local validType = isValidElementType(type_)
if not validType then
local info = ""
if type_ == nil or (typeof(type_) == "table" and #Object.keys(type_) == 0) then
info ..= (" You likely forgot to export your component from the file " .. "it's defined in, or you might have mixed up default and named imports.")
end
local sourceInfo = getSourceInfoErrorAddendumForProps(props)
if sourceInfo then
info ..= sourceInfo
else
info ..= getDeclarationErrorAddendum()
end
local typeString
if type_ == nil then
typeString = "nil"
elseif Array.isArray(type_) then
typeString = "array"
elseif
type_ ~= nil
and typeof(type_) == "table"
and type_["$$typeof"] == REACT_ELEMENT_TYPE
then
typeString = string.format(
"<%s />",
getComponentName((type_ :: any).type) or "Unknown"
)
info ..= " Did you accidentally export a JSX literal or Element instead of a component?"
else
typeString = typeof(type_)
if type_ ~= nil then
info ..= "\n" .. inspect(type_)
end
end
if ReactGlobals.__DEV__ then
console.error(
"React.createElement: type is invalid -- expected a string (for "
.. "built-in components) or a class/function (for composite "
.. "components) but got: %s.%s",
typeString,
info
)
end
end
local element = createElement(type_ :: any, props, ...)
if element == nil then
return element
end
if validType then
for i = 1, select("#", ...) do
validateChildKeys(select(i, ...), type_ :: any)
end
end
if type_ == REACT_FRAGMENT_TYPE then
validateFragmentProps(element)
else
validatePropTypes(element)
end
return element
end
exports.createElementWithValidation = createElementWithValidation
exports.cloneElementWithValidation = function<P, T>(
element: ReactElement<P, T>,
props: (P & React_ElementProps<T>)?,
...: React_Node
): ReactElement<P, T>
local arguments = { element, props, ... } :: Array<any>
local newElement = cloneElement(element, props, ...)
for i = 3, #arguments do
validateChildKeys(arguments[i], newElement.type)
end
validatePropTypes(newElement)
return newElement
end
return exports
end
end)())
__register("React/ReactForwardRef", (function()
local script = __makeProxy({"React","ReactForwardRef"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local console = __require(Packages.Shared).console
local ReactSymbols = __require(Packages.Shared).ReactSymbols
local ReactTypes = __require(Packages.Shared)
type React_Node = ReactTypes.React_Node
type React_Ref<ElementType> = ReactTypes.React_Ref<ElementType>
type React_ForwardRefComponent<Config, Instance> = ReactTypes.React_ForwardRefComponent<
Config,
Instance
>
local REACT_FORWARD_REF_TYPE = ReactSymbols.REACT_FORWARD_REF_TYPE
local REACT_MEMO_TYPE = ReactSymbols.REACT_MEMO_TYPE
local exports = {}
exports.forwardRef = function<Props, ElementType>(
render: (
props: Props,
ref: React_Ref<ElementType>
) -> React_Node
): React_ForwardRefComponent<
Props,
ElementType
>
if ReactGlobals.__DEV__ then
if
typeof(render :: any) == "table"
and (render :: any)["$$typeof"] == REACT_MEMO_TYPE
then
console.error(
"forwardRef requires a render function but received a `memo` "
.. "component. Instead of forwardRef(memo(...)), use "
.. "memo(forwardRef(...))."
)
elseif typeof(render) ~= "function" then
console.error(
"forwardRef requires a render function but was given %s.",
typeof(render)
)
else
local argumentCount, _variadic = debug.info(render, "a")
if argumentCount ~= 0 and argumentCount ~= 2 then
console.error(
"forwardRef render functions accept exactly two parameters: props and ref. %s",
(function()
if argumentCount == 1 then
return "Did you forget to use the ref parameter?"
end
return "Any additional parameter will be undefined."
end)()
)
end
end
end
local elementType = {
["$$typeof"] = REACT_FORWARD_REF_TYPE,
render = render,
}
if ReactGlobals.__DEV__ then
local ownName
setmetatable(elementType, {
__index = function(self, key)
if key == "displayName" then
return ownName
end
return rawget(self, key)
end,
__newindex = function(self, key, value)
if key == "displayName" then
ownName = value
else
rawset(self, key, value)
end
end,
})
end
return elementType
end
return exports
end
end)())
__register("React/ReactHooks", (function()
local script = __makeProxy({"React","ReactHooks"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local LuauPolyfill = __require(Packages.LuauPolyfill)
local Array = LuauPolyfill.Array
type Array<T> = LuauPolyfill.Array<T>
local console = __require(Packages.Shared).console
local ReactTypes = __require(Packages.Shared)
type Dispatcher = ReactTypes.Dispatcher
type MutableSource<T> = ReactTypes.MutableSource<T>
type MutableSourceGetSnapshotFn<Source, Snapshot> = ReactTypes.MutableSourceGetSnapshotFn<
Source,
Snapshot
>
type MutableSourceSubscribeFn<Source, Snapshot> = ReactTypes.MutableSourceSubscribeFn<
Source,
Snapshot
>
type ReactProviderType<T> = ReactTypes.ReactProviderType<T>
type ReactContext<T> = ReactTypes.ReactContext<T>
local ReactFiberHostConfig = __require(Packages.Shared)
type OpaqueIDType = ReactFiberHostConfig.OpaqueIDType
local ReactCurrentDispatcher =
__require(Packages.Shared).ReactSharedInternals.ReactCurrentDispatcher
type BasicStateAction<S> = ((S) -> S) | S
type Dispatch<A> = (A) -> ()
local function resolveDispatcher(): Dispatcher
local dispatcher = ReactCurrentDispatcher.current
if ReactGlobals.__DEV__ then
if dispatcher == nil then
console.error(
"Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for"
.. " one of the following reasons:\n"
.. "1. You might have mismatching versions of React and the renderer (such as React DOM)\n"
.. "2. You might be breaking the Rules of Hooks\n"
.. "3. You might have more than one copy of React in the same app\n"
.. "See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem."
)
end
end
return dispatcher :: Dispatcher
end
local exports = {}
local function useContext<T>(
Context: ReactContext<T>,
unstable_observedBits: number | boolean | nil,
...
): T
local dispatcher = resolveDispatcher()
if ReactGlobals.__DEV__ then
if unstable_observedBits ~= nil then
console.error(
"useContext() second argument is reserved for future "
.. "use in React. Passing it is not supported. "
.. "You passed: %s.%s",
unstable_observedBits,
(typeof(unstable_observedBits) == "number" and Array.isArray({ ... }))
and "\n\nDid you call Array.map(useContext)? " .. "Calling Hooks inside a loop is not supported. " .. "Learn more at https://reactjs.org/link/rules-of-hooks"
or ""
)
end
if (Context :: any)._context ~= nil then
local realContext = (Context :: any)._context
if realContext.Consumer == Context then
console.error(
"Calling useContext(Context.Consumer) is not supported, may cause bugs, and will be "
.. "removed in a future major release. Did you mean to call useContext(Context) instead?"
)
elseif realContext.Provider == Context then
console.error(
"Calling useContext(Context.Provider) is not supported. "
.. "Did you mean to call useContext(Context) instead?"
)
end
end
end
return dispatcher.useContext(Context, unstable_observedBits)
end
exports.useContext = useContext
local function useState<S>(
initialState: (() -> S) | S,
...
): (S, Dispatch<BasicStateAction<S>>)
local dispatcher = resolveDispatcher()
return dispatcher.useState(initialState, ...)
end
exports.useState = useState
local function useReducer<S, I, A>(
reducer: (S, A) -> S,
initialArg: I,
init: ((I) -> S)?
): (S, Dispatch<A>)
local dispatcher = resolveDispatcher()
return dispatcher.useReducer(reducer, initialArg, init)
end
exports.useReducer = useReducer
local function useRef<T>(initialValue: T): { current: T }
local dispatcher = resolveDispatcher()
return dispatcher.useRef(initialValue)
end
exports.useRef = useRef
local function useBinding<T>(
initialValue: T
): (
ReactTypes.ReactBinding<T>,
ReactTypes.ReactBindingUpdater<T>
)
local dispatcher = resolveDispatcher()
return dispatcher.useBinding(initialValue)
end
exports.useBinding = useBinding
local function useEffect(
create: (() -> ()) | (() -> () -> ()),
deps: Array<any> | nil
): ()
local dispatcher = resolveDispatcher()
return dispatcher.useEffect(create, deps)
end
exports.useEffect = useEffect
local function useLayoutEffect(
create: (() -> ()) | (() -> () -> ()),
deps: Array<any> | nil
): ()
local dispatcher = resolveDispatcher()
return dispatcher.useLayoutEffect(create, deps)
end
exports.useLayoutEffect = useLayoutEffect
local function useCallback<T>(callback: T, deps: Array<any> | nil): T
local dispatcher = resolveDispatcher()
return dispatcher.useCallback(callback, deps)
end
exports.useCallback = useCallback
local function useMemo<T...>(create: () -> T..., deps: Array<any> | nil): T...
local dispatcher = resolveDispatcher()
return dispatcher.useMemo(create, deps)
end
exports.useMemo = useMemo
local function useImperativeHandle<T>(
ref: { current: T | nil } | ((inst: T | nil) -> any) | nil,
create: () -> T,
deps: Array<any> | nil
): ()
local dispatcher = resolveDispatcher()
return dispatcher.useImperativeHandle(ref, create, deps)
end
exports.useImperativeHandle = useImperativeHandle
local function useDebugValue<T>(value: T, formatterFn: ((value: T) -> any)?): ()
if ReactGlobals.__DEV__ then
local dispatcher = resolveDispatcher()
return dispatcher.useDebugValue(value, formatterFn)
end
return nil
end
exports.useDebugValue = useDebugValue
exports.emptyObject = {}
exports.useOpaqueIdentifier = function(): OpaqueIDType | nil
local dispatcher = resolveDispatcher()
return dispatcher.useOpaqueIdentifier()
end
exports.useMutableSource = function<Source, Snapshot>(
source: MutableSource<Source>,
getSnapshot: MutableSourceGetSnapshotFn<
Source,
Snapshot
>,
subscribe: MutableSourceSubscribeFn<
Source,
Snapshot
>
): Snapshot
local dispatcher = resolveDispatcher()
return dispatcher.useMutableSource(source, getSnapshot, subscribe)
end
return exports
end
end)())
__register("React/ReactLazy", (function()
local script = __makeProxy({"React","ReactLazy"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local Shared = __require(Packages.Shared)
local console = Shared.console
local LuauPolyfill = __require(Packages.LuauPolyfill)
local inspect = LuauPolyfill.util.inspect
local ReactTypes = __require(Packages.Shared)
type Wakeable = ReactTypes.Wakeable
type Thenable<R> = ReactTypes.Thenable<R>
local ReactSymbols = __require(Packages.Shared).ReactSymbols
local REACT_LAZY_TYPE = ReactSymbols.REACT_LAZY_TYPE
local Uninitialized = -1
local Pending = 0
local Resolved = 1
local Rejected = 2
type UninitializedPayload<T> = {
_status: number,
_result: () -> Thenable<{ default: T, [string]: any }>,
}
type PendingPayload = {
_status: number,
_result: Wakeable,
}
type ResolvedPayload<T> = {
_status: number,
_result: { default: T, [string]: any },
}
type RejectedPayload = {
_status: number,
_result: any,
}
type Payload<T> =
UninitializedPayload<T>
| PendingPayload
| ResolvedPayload<T>
| RejectedPayload
type LazyComponent<T, P> = {
["$$typeof"]: number,
_payload: P,
_init: (payload: P) -> T,
}
function lazyInitializer<T>(payload: Payload<T>): T
if payload._status == Uninitialized then
local ctor = payload._result
local thenable = ctor()
local pending: PendingPayload = payload :: any
pending._status = Pending
pending._result = thenable
thenable:andThen(function(moduleObject)
if payload._status == Pending then
local defaultExport = moduleObject.default
if ReactGlobals.__DEV__ then
if defaultExport == nil then
console.error(
"lazy: Expected the result of a dynamic import() call. "
.. "Instead received: `%s`\n\nYour code should look like: \n  "
.. "local MyComponent = lazy(function() return req"
.. "quire(script.Parent.MyComponent) end)",
inspect(moduleObject)
)
end
end
local resolved: ResolvedPayload<T> = payload :: any
resolved._status = Resolved
resolved._result = defaultExport
end
end, function(error_)
if payload._status == Pending then
local rejected: RejectedPayload = payload :: any
rejected._status = Rejected
rejected._result = error_
end
end)
end
if payload._status == Resolved then
return payload._result
else
error(payload._result)
end
end
local exports = {}
exports.lazy = function<T>(
ctor: () -> Thenable<{ default: T, [string]: any }>
): LazyComponent<T, Payload<T>>
local payload: Payload<T> = {
_status = -1,
_result = ctor,
}
local lazyType: LazyComponent<T, Payload<T>> = {
["$$typeof"] = REACT_LAZY_TYPE,
_payload = payload,
_init = lazyInitializer :: any,
}
if ReactGlobals.__DEV__ then
local defaultProps
local propTypes
setmetatable(lazyType, {
__index = function(self, key)
if key == "defaultProps" then
return defaultProps
end
if key == "propTypes" then
return propTypes
end
return
end,
__newindex = function(self, key, value)
if key == "defaultProps" then
console.error(
"React.lazy(...): It is not supported to assign `defaultProps` to "
.. "a lazy component import. Either specify them where the component "
.. "is defined, or create a wrapping component around it."
)
defaultProps = value
setmetatable(self, {
__index = function() end,
__newindex = function() end,
})
end
if key == "propTypes" then
console.error(
"React.lazy(...): It is not supported to assign `propTypes` to "
.. "a lazy component import. Either specify them where the component "
.. "is defined, or create a wrapping component around it."
)
propTypes = value
setmetatable(self, {
__index = function() end,
__newindex = function() end,
})
end
end,
})
end
return lazyType
end
return exports
end
end)())
__register("React/ReactMemo", (function()
local script = __makeProxy({"React","ReactMemo"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local Shared = __require(Packages.Shared)
local console = Shared.console
local LuauPolyfill = __require(Packages.LuauPolyfill)
local Array = LuauPolyfill.Array
local Object = LuauPolyfill.Object
local inspect = LuauPolyfill.util.inspect
type React_StatelessFunctionalComponent<Props> = Shared.React_StatelessFunctionalComponent<
Props
>
type React_ElementType = Shared.React_ElementType
type React_Component<Props, State> = Shared.React_Component<Props, State>
type React_ComponentType<Props> = Shared.React_ComponentType<Props>
type React_MemoComponent<Config, T> = Shared.React_MemoComponent<Config, T>
type React_AbstractComponent<Config, Instance> = Shared.React_AbstractComponent<
Config,
Instance
>
local ReactSymbols = Shared.ReactSymbols
local REACT_MEMO_TYPE = ReactSymbols.REACT_MEMO_TYPE
local REACT_ELEMENT_TYPE = ReactSymbols.REACT_ELEMENT_TYPE
local isValidElementType = Shared.isValidElementType
local getComponentName = Shared.getComponentName
local exports = {}
exports.memo = function<Props, T>(
type_: React_StatelessFunctionalComponent<Props> | React_AbstractComponent<Props, T> | string,
compare: ((oldProps: Props, newProps: Props) -> boolean)?
): React_MemoComponent<Props, any>
if ReactGlobals.__DEV__ then
local validType = isValidElementType(type_)
if not validType then
local info = ""
if
type_ == nil
or (typeof(type_) == "table" and #Object.keys(type_) == 0)
then
info = info
.. (
" You likely forgot to export your component from the file "
.. "it's defined in, or you might have mixed up default and named imports."
)
end
local typeString
if type_ == nil then
typeString = "nil"
elseif Array.isArray(type_) then
typeString = "array"
elseif
type_ ~= nil
and typeof(type_) == "table"
and (type_ :: React_MemoComponent<Props, T>)["$$typeof"]
== REACT_ELEMENT_TYPE
then
typeString = string.format(
"<%s />",
getComponentName((type_ :: any).type) or "UNKNOWN"
)
info =
" Did you accidentally export a JSX literal or Element instead of a component?"
else
typeString = typeof(type_)
if type_ ~= nil then
info = "\n" .. inspect(type_)
end
end
console.error(
"memo: The first argument must be a component. Instead received: `%s`.%s",
typeString,
info
)
end
end
local elementType = {
["$$typeof"] = REACT_MEMO_TYPE,
type = type_,
compare = compare or nil,
}
if ReactGlobals.__DEV__ then
local name
setmetatable(elementType, {
__index = function(self, key)
if key == "displayName" then
return name
end
return rawget(self, key)
end,
__newindex = function(self, key, value)
if key == "displayName" then
name = value
if
typeof(type_) == "table"
and (type_ :: React_AbstractComponent<Props, T>).displayName
== nil
then
(type_ :: React_MemoComponent<Props, T>).displayName = name
end
else
rawset(self, key, value)
end
end,
})
end
return elementType :: React_MemoComponent<Props, any>
end
return exports
end
end)())
__register("React/ReactMutableSource", (function()
local script = __makeProxy({"React","ReactMutableSource"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local ReactTypes = __require(Packages.Shared)
type MutableSourceGetVersionFn = ReactTypes.MutableSourceGetVersionFn
type MutableSource<T> = ReactTypes.MutableSource<T>
local function createMutableSource<Source>(
source: Source,
getVersion: MutableSourceGetVersionFn
): MutableSource<Source>
local mutableSource: MutableSource<Source> = {
_getVersion = getVersion,
_source = source,
_workInProgressVersionPrimary = nil,
_workInProgressVersionSecondary = nil,
}
if ReactGlobals.__DEV__ then
mutableSource._currentPrimaryRenderer = nil
mutableSource._currentSecondaryRenderer = nil
end
return mutableSource
end
return createMutableSource
end
end)())
__register("React/ReactNoopUpdateQueue", (function()
local script = __makeProxy({"React","ReactNoopUpdateQueue"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local console = __require(Packages.Shared).console
local didWarnStateUpdateForUnmountedComponent = {}
local function warnNoop(publicInstance: any, callerName: string)
if ReactGlobals.__DEV__ then
local componentName = publicInstance.__componentName or "ReactClass"
local warningKey = componentName .. "." .. callerName
if didWarnStateUpdateForUnmountedComponent[warningKey] then
return
end
console.error(
"Can't call %s on a component that is not yet mounted. "
.. "This is a no-op, but it might indicate a bug in your application. "
.. "Instead, assign to `self.state` directly with the desired state in "
.. "the %s component's `init` method.",
callerName,
componentName
)
didWarnStateUpdateForUnmountedComponent[warningKey] = true
end
end
local ReactNoopUpdateQueue = {
isMounted = function(publicInstance)
return false
end,
enqueueForceUpdate = function(publicInstance, callback, callerName)
warnNoop(publicInstance, "forceUpdate")
end,
enqueueReplaceState = function(publicInstance, completeState, callback, callerName)
warnNoop(publicInstance, "replaceState")
end,
enqueueSetState = function(publicInstance, partialState, callback, callerName)
warnNoop(publicInstance, "setState")
end,
}
return ReactNoopUpdateQueue
end
end)())
__register("ReactReconciler/DebugTracing", (function()
local script = __makeProxy({"ReactReconciler","DebugTracing"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
type Array<T> = { [number]: T }
type Map<K, V> = { [K]: V }
type Object = { [string]: any }
type Function = (any) -> any?
local Shared = __require(Packages.Shared)
local console = Shared.console
local exports = {}
local log
local ReactFiberLaneModule = __require(script.Parent.ReactFiberLane)
type Lane = ReactFiberLaneModule.Lane
type Lanes = ReactFiberLaneModule.Lanes
type Wakeable = Shared.Wakeable
local enableDebugTracing = __require(Packages.Shared).ReactFeatureFlags.enableDebugTracing
local nativeConsole: Object = console
local nativeConsoleLog: nil | Function = nil
local pendingGroupArgs: Array<any> = {}
local printedGroupIndex: number = 0
function decimalToBinaryString(decimal: number): string
local result = ""
repeat
local divres = decimal / 2
local int, frac = math.modf(divres)
decimal = int
result = math.ceil(frac) .. result
until decimal == 0
local nbZero = 31 - string.len(result)
return string.rep("0", nbZero) .. result
end
local function formatLanes(laneOrLanes: Lane | Lanes): string
return "0b"
.. decimalToBinaryString(laneOrLanes)
end
local function group(...): ()
for _, groupArg in { ... } do
table.insert(pendingGroupArgs, groupArg)
end
if nativeConsoleLog == nil then
nativeConsoleLog = nativeConsole.log
nativeConsole.log = log
end
end
local function groupEnd(): ()
table.remove(pendingGroupArgs, 1)
while printedGroupIndex > #pendingGroupArgs do
nativeConsole.groupEnd()
printedGroupIndex -= 1
end
if #pendingGroupArgs == 0 then
nativeConsole.log = nativeConsoleLog
nativeConsoleLog = nil
end
end
function log(...): ()
if printedGroupIndex < #pendingGroupArgs then
for i = printedGroupIndex + 1, #pendingGroupArgs do
local groupArgs = pendingGroupArgs[i]
nativeConsole.group(groupArgs)
end
printedGroupIndex = #pendingGroupArgs
end
if typeof(nativeConsoleLog) == "function" then
(nativeConsoleLog :: any)(...)
else
nativeConsole.log(...)
end
end
local REACT_LOGO_STYLE = ""
local function logCommitStarted(lanes: Lanes): ()
if ReactGlobals.__DEV__ then
if enableDebugTracing then
group(
string.format("* commit (%s)", formatLanes(lanes)),
REACT_LOGO_STYLE,
"",
""
)
end
end
end
exports.logCommitStarted = logCommitStarted
local function logCommitStopped(): ()
if ReactGlobals.__DEV__ then
if enableDebugTracing then
groupEnd()
end
end
end
exports.logCommitStopped = logCommitStopped
local function logComponentSuspended(componentName: string, wakeable: Wakeable): ()
if ReactGlobals.__DEV__ then
if enableDebugTracing then
log(
string.format("* %s suspended", componentName)
)
wakeable:andThen(function()
log(
string.format("* %s resolved", componentName)
)
end, function()
log(
string.format("* %s rejected", componentName)
)
end)
end
end
end
exports.logComponentSuspended = logComponentSuspended
local function logLayoutEffectsStarted(lanes: Lanes): ()
if ReactGlobals.__DEV__ then
if enableDebugTracing then
group(
string.format("* layout effects (%s)", formatLanes(lanes))
)
end
end
end
exports.logLayoutEffectsStarted = logLayoutEffectsStarted
local function logLayoutEffectsStopped(): ()
if ReactGlobals.__DEV__ then
if enableDebugTracing then
groupEnd()
end
end
end
exports.logLayoutEffectsStopped = logLayoutEffectsStopped
local function logPassiveEffectsStarted(lanes: Lanes): ()
if ReactGlobals.__DEV__ then
if enableDebugTracing then
group(
string.format("* passive effects (%s)", formatLanes(lanes))
)
end
end
end
exports.logPassiveEffectsStarted = logPassiveEffectsStarted
local function logPassiveEffectsStopped(): ()
if ReactGlobals.__DEV__ then
if enableDebugTracing then
groupEnd()
end
end
end
exports.logPassiveEffectsStopped = logPassiveEffectsStopped
local function logRenderStarted(lanes: Lanes): ()
if ReactGlobals.__DEV__ then
if enableDebugTracing then
group(
string.format("* render (%s)", formatLanes(lanes))
)
end
end
end
exports.logRenderStarted = logRenderStarted
local function logRenderStopped(): ()
if ReactGlobals.__DEV__ then
if enableDebugTracing then
groupEnd()
end
end
end
exports.logRenderStopped = logRenderStopped
local function logForceUpdateScheduled(componentName: string, lane: Lane): ()
if ReactGlobals.__DEV__ then
if enableDebugTracing then
log(
string.format("* %s forced update (%s)", componentName, formatLanes(lane))
)
end
end
end
exports.logForceUpdateScheduled = logForceUpdateScheduled
local function logStateUpdateScheduled(
componentName: string,
lane: Lane,
payloadOrAction: any
): ()
if ReactGlobals.__DEV__ then
if enableDebugTracing then
log(
string.format("* %s updated state (%s)", componentName, formatLanes(lane))
)
end
end
end
exports.logStateUpdateScheduled = logStateUpdateScheduled
return exports
end
end)())
__register("ReactReconciler/init", (function()
local script = __makeProxy({"ReactReconciler"})
return function()
local ReactInternalTypes = __require(script.ReactInternalTypes)
local ReactRootTags = __require(script.ReactRootTags)
type Dispatcher = ReactInternalTypes.Dispatcher
type Fiber = ReactInternalTypes.Fiber
type FiberRoot = ReactInternalTypes.FiberRoot
type UpdateQueue<T> = ReactInternalTypes.UpdateQueue<T>
type RootTag = ReactRootTags.RootTag
local ReactFiberHostConfigModule = __require(script.ReactFiberHostConfig)
type Instance = ReactFiberHostConfigModule.Instance
local ReactFiberHotReloading = __require(script["ReactFiberHotReloading.new"])
type Family = ReactFiberHotReloading.Family
type RefreshUpdate = ReactFiberHotReloading.RefreshUpdate
type SetRefreshHandler = ReactFiberHotReloading.SetRefreshHandler
type ScheduleRefresh = ReactFiberHotReloading.ScheduleRefresh
type ScheduleRoot = ReactFiberHotReloading.ScheduleRoot
type FindHostInstancesForRefresh = ReactFiberHotReloading.FindHostInstancesForRefresh
local function initialize(config): { [string]: any }
local ReactFiberHostConfig = __require(script.ReactFiberHostConfig)
for name, implementation in config do
ReactFiberHostConfig[name] = implementation
end
return __require(script.ReactFiberReconciler)
end
return initialize
end
end)())
__register("ReactReconciler/MaxInts", (function()
local script = __makeProxy({"ReactReconciler","MaxInts"})
return function()
return { MAX_SIGNED_31_BIT_INT = 1073741823 }
end
end)())
__register("ReactReconciler/ReactCapturedValue", (function()
local script = __makeProxy({"ReactReconciler","ReactCapturedValue"})
return function()
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
local getStackByFiberInDevAndProd =
__require(script.Parent.ReactFiberComponentStack).getStackByFiberInDevAndProd
type CapturedValue<T> = {
value: T,
source: Fiber | nil,
stack: string | nil,
}
local exports = {}
exports.createCapturedValue = function<T>(value: T, source: Fiber | nil): CapturedValue<T>
return {
value = value,
source = source,
stack = getStackByFiberInDevAndProd(source),
}
end
return exports
end
end)())
__register("ReactReconciler/ReactChildFiber.new", (function()
local script = __makeProxy({"ReactReconciler","ReactChildFiber.new"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local LuauPolyfill = __require(Packages.LuauPolyfill)
local Array = LuauPolyfill.Array
local Error = LuauPolyfill.Error
type Array<T> = { [number]: T }
type Set<T> = { [T]: boolean }
type Object = { [any]: any }
type Map<K, V> = { [K]: V }
local console = __require(Packages.Shared).console
local describeError = __require(Packages.Shared).describeError
local __DEV__ = ReactGlobals.__DEV__ :: boolean
local SafeFlags = __require(Packages.SafeFlags)
local FFlagReactPreventAssigningKeyToChildren =
SafeFlags.createGetFFlag("ReactPreventAssigningKeyToChildren")()
local ReactTypes = __require(Packages.Shared)
type ReactElement = ReactTypes.ReactElement<any, any>
type ReactPortal = ReactTypes.ReactPortal
local React = __require(Packages.React)
type LazyComponent<T, P> = React.LazyComponent<T, P>
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
type RoactStableKey = ReactInternalTypes.RoactStableKey
local ReactFiberLanes = __require(script.Parent.ReactFiberLane)
type Lanes = ReactFiberLanes.Lanes
local getComponentName = __require(Packages.Shared).getComponentName
local ReactFiberFlags = __require(script.Parent.ReactFiberFlags)
local Placement = ReactFiberFlags.Placement
local Deletion = ReactFiberFlags.Deletion
local ReactSymbols = __require(Packages.Shared).ReactSymbols
local getIteratorFn = ReactSymbols.getIteratorFn
local REACT_ELEMENT_TYPE = ReactSymbols.REACT_ELEMENT_TYPE
local REACT_FRAGMENT_TYPE = ReactSymbols.REACT_FRAGMENT_TYPE
local REACT_PORTAL_TYPE = ReactSymbols.REACT_PORTAL_TYPE
local REACT_LAZY_TYPE = ReactSymbols.REACT_LAZY_TYPE
local REACT_BLOCK_TYPE = ReactSymbols.REACT_BLOCK_TYPE
local ReactWorkTags = __require(script.Parent.ReactWorkTags)
local FunctionComponent = ReactWorkTags.FunctionComponent
local ClassComponent = ReactWorkTags.ClassComponent
local HostText = ReactWorkTags.HostText
local HostPortal = ReactWorkTags.HostPortal
local ForwardRef = ReactWorkTags.ForwardRef
local Fragment = ReactWorkTags.Fragment
local SimpleMemoComponent = ReactWorkTags.SimpleMemoComponent
local Block = ReactWorkTags.Block
local invariant = __require(Packages.Shared).invariant
local ReactFeatureFlags = __require(Packages.Shared).ReactFeatureFlags
local enableLazyElements = ReactFeatureFlags.enableLazyElements
local enableBlocksAPI = ReactFeatureFlags.enableBlocksAPI
local ReactFiber = __require(script.Parent["ReactFiber.new"])
local createWorkInProgress = ReactFiber.createWorkInProgress
local resetWorkInProgress = ReactFiber.resetWorkInProgress
local createFiberFromElement = ReactFiber.createFiberFromElement
local createFiberFromFragment = ReactFiber.createFiberFromFragment
local createFiberFromText = ReactFiber.createFiberFromText
local createFiberFromPortal = ReactFiber.createFiberFromPortal
local ReactFiberHotReloading = __require(script.Parent["ReactFiberHotReloading.new"])
local isCompatibleFamilyForHotReloading =
ReactFiberHotReloading.isCompatibleFamilyForHotReloading
local exports = {}
local didWarnAboutMaps
local ownerHasKeyUseWarning
local ownerHasFunctionTypeWarning
local warnForMissingKey = function(child: any, returnFiber: Fiber) end
if __DEV__ then
didWarnAboutMaps = false
ownerHasKeyUseWarning = {}
ownerHasFunctionTypeWarning = {}
warnForMissingKey = function(child: any, returnFiber: Fiber)
if child == nil or type(child) ~= "table" then
return
end
if not child._store or child._store.validated or child.key ~= nil then
return
end
invariant(
child._store ~= nil and type(child._store) == "table",
"React Component in warnForMissingKey should have a _store. "
.. "This error is likely caused by a bug in React. Please file an issue."
)
child._store.validated = true
local componentName = getComponentName(returnFiber.type) or "Component"
if ownerHasKeyUseWarning[componentName] then
return
end
ownerHasKeyUseWarning[componentName] = true
console.error(
"Each child in a list should have a unique "
.. '"key" prop. See https://reactjs.org/link/warning-keys for '
.. "more information."
)
end
end
local isArray = Array.isArray
function coerceRef(returnFiber: Fiber, current: Fiber | nil, element: ReactElement)
local mixedRef = element.ref
if mixedRef ~= nil and type(mixedRef) == "string" then
if
not element._owner
or not element._self
or element._owner.stateNode == element._self
then
local componentName
if __DEV__ then
componentName = getComponentName(returnFiber.type) or "Component"
else
componentName = "<enable __DEV__ mode for component names>"
end
error(
Error.new(
string.format(
'Component "%s" contains the string ref "%s". Support for string refs '
.. "has been removed. We recommend using "
.. "useRef() or createRef() instead. "
.. "Learn more about using refs safely here: "
.. "https://reactjs.org/link/strict-mode-string-ref",
componentName,
tostring(mixedRef)
)
)
)
end
if not element._owner then
error(
"Expected ref to be a function or an object returned by React.createRef(), or nil."
)
end
end
return mixedRef
end
local function warnOnFunctionType(returnFiber: Fiber)
if __DEV__ then
local componentName = getComponentName(returnFiber.type) or "Component"
if ownerHasFunctionTypeWarning[componentName] then
return
end
ownerHasFunctionTypeWarning[componentName] = true
console.error(
"Functions are not valid as a React child. This may happen if "
.. "you return a Component instead of <Component /> from render. "
.. "Or maybe you meant to call this function rather than return it."
)
end
end
function resolveLazyType<T, P>(lazyComponent: LazyComponent<T, P>): LazyComponent<T, P> | T
local payload = lazyComponent._payload
local init = lazyComponent._init
local ok, result = xpcall(init, describeError, payload)
if not ok then
return lazyComponent
end
return result
end
local function ChildReconciler(shouldTrackSideEffects)
local function deleteChild(returnFiber: Fiber, childToDelete: Fiber)
if not shouldTrackSideEffects then
return
end
local deletions = returnFiber.deletions
if deletions == nil then
returnFiber.deletions = { childToDelete }
returnFiber.flags = bit32.bor(returnFiber.flags, Deletion)
else
table.insert(deletions, childToDelete)
end
end
local function deleteRemainingChildren(
returnFiber: Fiber,
currentFirstChild: Fiber | nil
)
if not shouldTrackSideEffects then
return nil
end
local childToDelete = currentFirstChild
while childToDelete ~= nil do
deleteChild(returnFiber, childToDelete)
childToDelete = childToDelete.sibling
end
return nil
end
local function mapRemainingChildren(
returnFiber: Fiber,
currentFirstChild: Fiber
): { [string | number]: Fiber }
local existingChildren: { [string | number]: Fiber } = {}
local existingChild: Fiber? = currentFirstChild
while existingChild ~= nil do
if existingChild.key ~= nil then
existingChildren[existingChild.key] = existingChild
else
existingChildren[existingChild.index] = existingChild
end
existingChild = existingChild.sibling
end
return existingChildren
end
local function useFiber(fiber: Fiber, pendingProps: any): Fiber
local clone = createWorkInProgress(fiber, pendingProps)
clone.index = 1
clone.sibling = nil
return clone
end
local function placeChild(
newFiber: Fiber,
lastPlacedIndex: number,
newIndex: number
): number
newFiber.index = newIndex
if not shouldTrackSideEffects then
return lastPlacedIndex
end
local current = newFiber.alternate
if current ~= nil then
local oldIndex = current.index
if oldIndex < lastPlacedIndex then
newFiber.flags = bit32.bor(newFiber.flags, Placement)
return lastPlacedIndex
else
return oldIndex
end
else
newFiber.flags = bit32.bor(newFiber.flags, Placement)
return lastPlacedIndex
end
end
local function placeSingleChild(newFiber: Fiber): Fiber
if shouldTrackSideEffects and newFiber.alternate == nil then
newFiber.flags = bit32.bor(newFiber.flags, Placement)
end
return newFiber
end
local function updateTextNode(
returnFiber: Fiber,
current: Fiber | nil,
textContent: string,
lanes: Lanes
)
if current == nil or (current :: Fiber).tag ~= HostText then
local created = createFiberFromText(textContent, returnFiber.mode, lanes)
created.return_ = returnFiber
return created
else
local existing = useFiber(current :: Fiber, textContent)
existing.return_ = returnFiber
return existing
end
end
local function updateElement(
returnFiber: Fiber,
current: Fiber | nil,
element: ReactElement,
lanes: Lanes
): Fiber
if current ~= nil then
if
(current :: Fiber).elementType == element.type
or (__DEV__ and isCompatibleFamilyForHotReloading(current, element))
then
local existing = useFiber(current :: Fiber, element.props)
existing.ref = coerceRef(returnFiber, current, element)
existing.return_ = returnFiber
if __DEV__ then
existing._debugSource = element._source
existing._debugOwner = element._owner
end
return existing
elseif enableBlocksAPI and (current :: Fiber).tag == Block then
local type_: any = element.type
if type(type_) == "table" and type_["$$typeof"] == REACT_LAZY_TYPE then
type_ = resolveLazyType(type_) :: LazyComponent<any, any>
end
if
type_["$$typeof"] == REACT_BLOCK_TYPE
and type_._render == (current :: Fiber).type._render
then
local existing = useFiber(current :: Fiber, element.props)
existing.return_ = returnFiber
existing.type = type_
if __DEV__ then
existing._debugSource = element._source
existing._debugOwner = element._owner
end
return existing
end
end
end
local created = createFiberFromElement(element, returnFiber.mode, lanes)
created.ref = coerceRef(returnFiber, current, element)
created.return_ = returnFiber
return created
end
local function updatePortal(
returnFiber: Fiber,
current: Fiber | nil,
portal: ReactPortal,
lanes: Lanes
): Fiber
if
current == nil
or (current :: Fiber).tag ~= HostPortal
or (current :: Fiber).stateNode.containerInfo ~= portal.containerInfo
or (current :: Fiber).stateNode.implementation ~= portal.implementation
then
local created = createFiberFromPortal(portal, returnFiber.mode, lanes)
created.return_ = returnFiber
return created
else
local existing = useFiber(current :: Fiber, portal.children or {})
existing.return_ = returnFiber
return existing
end
end
local function updateFragment(
returnFiber: Fiber,
current: Fiber | nil,
fragment: any,
lanes: Lanes,
key: nil | string
): Fiber
if current == nil or (current :: Fiber).tag ~= Fragment then
local created =
createFiberFromFragment(fragment, returnFiber.mode, lanes, key)
created.return_ = returnFiber
return created
else
local existing = useFiber(current :: Fiber, fragment)
existing.return_ = returnFiber
return existing
end
end
local function assignStableKey(tableKey: any?, newChild: Object): ()
if newChild.key == nil then
local typeOfTableKey = type(tableKey)
if typeOfTableKey == "string" or typeOfTableKey == "number" then
newChild.key = tableKey
elseif typeOfTableKey == "table" then
newChild.key = tostring(tableKey)
end
end
end
local function createChild(
returnFiber: Fiber,
newChild: any,
lanes: Lanes,
tableKey: any?
): Fiber | nil
if newChild == nil then
return nil
end
local typeOfNewChild = type(newChild)
if typeOfNewChild == "table" then
assignStableKey(tableKey, newChild)
local newChildTypeof = newChild["$$typeof"]
if newChildTypeof == REACT_ELEMENT_TYPE then
local created = createFiberFromElement(newChild, returnFiber.mode, lanes)
created.ref = coerceRef(returnFiber, nil, newChild)
created.return_ = returnFiber
return created
elseif newChildTypeof == REACT_PORTAL_TYPE then
local created = createFiberFromPortal(newChild, returnFiber.mode, lanes)
created.return_ = returnFiber
return created
elseif newChildTypeof == REACT_LAZY_TYPE then
if enableLazyElements then
local payload = newChild._payload
local init = newChild._init
return createChild(returnFiber, init(payload), lanes)
end
end
local created =
createFiberFromFragment(newChild, returnFiber.mode, lanes, nil)
created.return_ = returnFiber
return created
end
if typeOfNewChild == "string" or typeOfNewChild == "number" then
local created =
createFiberFromText(tostring(newChild), returnFiber.mode, lanes)
created.return_ = returnFiber
return created
end
if __DEV__ then
if typeOfNewChild == "function" then
warnOnFunctionType(returnFiber)
end
end
return nil
end
local function updateSlot(
returnFiber: Fiber,
oldFiber: Fiber | nil,
newChild: any,
lanes: Lanes,
tableKey: any?
): Fiber | nil
if newChild == nil then
return nil
end
local key = if oldFiber ~= nil then oldFiber.key else nil
local typeOfNewChild = type(newChild)
if typeOfNewChild == "table" then
assignStableKey(tableKey, newChild)
local newChildTypeof = newChild["$$typeof"]
if newChildTypeof == REACT_ELEMENT_TYPE then
if newChild.key == key then
if newChild.type == REACT_FRAGMENT_TYPE then
return updateFragment(
returnFiber,
oldFiber,
newChild.props.children,
lanes,
key :: string?
)
end
return updateElement(returnFiber, oldFiber, newChild, lanes)
else
return nil
end
elseif newChildTypeof == REACT_PORTAL_TYPE then
if newChild.key == key then
return updatePortal(returnFiber, oldFiber, newChild, lanes)
else
return nil
end
elseif newChildTypeof == REACT_LAZY_TYPE then
if enableLazyElements then
local payload = newChild._payload
local init = newChild._init
return updateSlot(returnFiber, oldFiber, init(payload), lanes)
end
end
if key ~= nil then
return nil
end
return updateFragment(returnFiber, oldFiber, newChild, lanes)
end
if typeOfNewChild == "string" or typeOfNewChild == "number" then
if key ~= nil then
return nil
end
return updateTextNode(returnFiber, oldFiber, tostring(newChild), lanes)
end
if __DEV__ then
if typeOfNewChild == "function" then
warnOnFunctionType(returnFiber)
end
end
return nil
end
local function updateFromMap(
existingChildren: Map<string | number, Fiber>,
returnFiber: Fiber,
newIdx: number,
newChild: any,
lanes: Lanes,
tableKey: any?
): Fiber | nil
if newChild == nil then
return nil
end
local typeOfNewChild = type(newChild)
if typeOfNewChild == "table" then
assignStableKey(tableKey, newChild)
local existingChildrenKey
local newChildTypeof = newChild["$$typeof"]
if newChildTypeof == REACT_ELEMENT_TYPE then
if newChild.key == nil then
existingChildrenKey = newIdx
else
existingChildrenKey = newChild.key
end
local matchedFiber = existingChildren[existingChildrenKey]
if newChild.type == REACT_FRAGMENT_TYPE then
return updateFragment(
returnFiber,
matchedFiber,
newChild.props.children,
lanes,
newChild.key
)
end
return updateElement(returnFiber, matchedFiber, newChild, lanes)
elseif newChildTypeof == REACT_PORTAL_TYPE then
if newChild.key == nil then
existingChildrenKey = newIdx
else
existingChildrenKey = newChild.key
end
local matchedFiber = existingChildren[existingChildrenKey]
return updatePortal(returnFiber, matchedFiber, newChild, lanes)
elseif newChildTypeof == REACT_LAZY_TYPE then
if enableLazyElements then
local payload = newChild._payload
local init = newChild._init
return updateFromMap(
existingChildren,
returnFiber,
newIdx,
init(payload),
lanes
)
end
end
local matchedFiber = existingChildren[newIdx]
return updateFragment(returnFiber, matchedFiber, newChild, lanes)
end
if typeOfNewChild == "string" or typeOfNewChild == "number" then
local matchedFiber = existingChildren[newIdx] or nil
return updateTextNode(returnFiber, matchedFiber, tostring(newChild), lanes)
end
if __DEV__ then
if typeOfNewChild == "function" then
warnOnFunctionType(returnFiber)
end
end
return nil
end
local function warnOnInvalidKey(
child: any,
knownKeys: Set<string> | nil,
returnFiber: Fiber
): Set<string> | nil
if __DEV__ then
if child == nil or type(child) ~= "table" then
return knownKeys
end
local childTypeof = child["$$typeof"]
if childTypeof == REACT_ELEMENT_TYPE or childTypeof == REACT_PORTAL_TYPE then
warnForMissingKey(child, returnFiber)
local key = child.key
if type(key) ~= "string" then
elseif knownKeys == nil then
knownKeys = {};
(knownKeys :: Set<string>)[key] = true
elseif not (knownKeys :: Set<string>)[key] then
(knownKeys :: Set<string>)[key] = true
else
console.error(
"Encountered two children with the same key, `%s`. "
.. "Keys should be unique so that components maintain their identity "
.. "across updates. Non-unique keys may cause children to be "
.. "duplicated and/or omitted — the behavior is unsupported and "
.. "could change in a future version.",
key
)
end
elseif childTypeof == REACT_LAZY_TYPE then
if enableLazyElements then
local payload = child._payload
local init = child._init
warnOnInvalidKey(init(payload), knownKeys, returnFiber)
end
end
end
return knownKeys
end
local function reconcileChildrenArray(
returnFiber: Fiber,
currentFirstChild: Fiber | nil,
newChildren: Array<any>,
lanes: Lanes
): Fiber | nil
if __DEV__ then
local knownKeys = nil
for i, child in newChildren do
knownKeys = warnOnInvalidKey(child, knownKeys, returnFiber)
end
end
local resultingFirstChild: Fiber | nil = nil
local previousNewFiber: Fiber | nil = nil
local oldFiber: Fiber | nil = currentFirstChild
local lastPlacedIndex = 1
local newIdx = 1
local nextOldFiber: Fiber | nil = nil
local newChildrenCount = #newChildren
while oldFiber ~= nil and newIdx <= newChildrenCount do
if oldFiber.index > newIdx then
nextOldFiber = oldFiber
oldFiber = nil
else
nextOldFiber = oldFiber.sibling
end
local newFiber
local newChildNewIdx = newChildren[newIdx]
if
newChildNewIdx ~= nil
and type(newChildNewIdx) == "table"
and newChildNewIdx["$$typeof"] ~= nil
then
newFiber =
updateSlot(returnFiber, oldFiber, newChildNewIdx, lanes, newIdx)
else
newFiber = updateSlot(returnFiber, oldFiber, newChildNewIdx, lanes)
end
if newFiber == nil then
if oldFiber == nil then
oldFiber = nextOldFiber
end
break
end
if shouldTrackSideEffects then
if oldFiber and (newFiber :: Fiber).alternate == nil then
deleteChild(returnFiber, oldFiber :: Fiber)
end
end
lastPlacedIndex = placeChild(newFiber :: Fiber, lastPlacedIndex, newIdx)
if previousNewFiber == nil then
resultingFirstChild = newFiber
else
(previousNewFiber :: Fiber).sibling = newFiber
end
previousNewFiber = newFiber
oldFiber = nextOldFiber
newIdx += 1
end
if newIdx > newChildrenCount then
deleteRemainingChildren(returnFiber, oldFiber)
return resultingFirstChild
end
if oldFiber == nil then
while newIdx <= newChildrenCount do
local newFiber
local newChildNewIdx = newChildren[newIdx]
if
newChildNewIdx ~= nil
and type(newChildNewIdx) == "table"
and newChildNewIdx["$$typeof"] ~= nil
then
newFiber = createChild(returnFiber, newChildNewIdx, lanes, newIdx)
else
newFiber = createChild(returnFiber, newChildNewIdx, lanes)
end
if newFiber == nil then
newIdx += 1
continue
end
lastPlacedIndex = placeChild(newFiber :: Fiber, lastPlacedIndex, newIdx)
if previousNewFiber == nil then
resultingFirstChild = newFiber
else
(previousNewFiber :: Fiber).sibling = newFiber
end
previousNewFiber = newFiber
newIdx += 1
end
return resultingFirstChild
end
local existingChildren = mapRemainingChildren(returnFiber, oldFiber :: Fiber)
while newIdx <= newChildrenCount do
local newFiber
local newChildNewIdx = newChildren[newIdx]
if
not FFlagReactPreventAssigningKeyToChildren
or (
newChildNewIdx ~= nil
and type(newChildNewIdx) == "table"
and newChildNewIdx["$$typeof"] ~= nil
)
then
newFiber = updateFromMap(
existingChildren,
returnFiber,
newIdx,
newChildNewIdx,
lanes,
newIdx
)
else
newFiber = updateFromMap(
existingChildren,
returnFiber,
newIdx,
newChildNewIdx,
lanes
)
end
if newFiber ~= nil then
if shouldTrackSideEffects then
if newFiber.alternate ~= nil then
existingChildren[if newFiber.key == nil
then newIdx
else newFiber.key] =
nil
end
end
lastPlacedIndex = placeChild(newFiber, lastPlacedIndex, newIdx)
if previousNewFiber == nil then
resultingFirstChild = newFiber
else
(previousNewFiber :: Fiber).sibling = newFiber
end
previousNewFiber = newFiber
end
newIdx += 1
end
if shouldTrackSideEffects then
for _, child in existingChildren do
deleteChild(returnFiber, child)
end
end
return resultingFirstChild
end
local function reconcileChildrenIterator(
returnFiber: Fiber,
currentFirstChild: Fiber | nil,
newChildrenIterable: any,
lanes: Lanes,
iteratorFn: (...any) -> any
): Fiber | nil
if __DEV__ then
if newChildrenIterable.entries == iteratorFn then
if not didWarnAboutMaps then
console.error(
"Using Maps as children is not supported. "
.. "Use an array of keyed ReactElements instead."
)
end
didWarnAboutMaps = true
end
local newChildren = iteratorFn(newChildrenIterable)
if newChildren then
local knownKeys = nil
local step = newChildren.next()
while not step.done do
step = newChildren.next()
local child = step.value
knownKeys = warnOnInvalidKey(child, knownKeys, returnFiber)
end
end
end
local newChildren = iteratorFn(newChildrenIterable)
local resultingFirstChild: Fiber | nil = nil
local previousNewFiber: Fiber = nil
local oldFiber = currentFirstChild
local lastPlacedIndex = 1
local newIdx = 1
local nextOldFiber: Fiber | nil = nil
local step = newChildren.next()
while oldFiber ~= nil and not step.done do
if oldFiber.index > newIdx then
nextOldFiber = oldFiber
oldFiber = nil
else
nextOldFiber = oldFiber.sibling
end
local newFiber =
updateSlot(returnFiber, oldFiber, step.value, lanes, step.key)
if newFiber == nil then
if oldFiber == nil then
oldFiber = nextOldFiber
end
break
end
if shouldTrackSideEffects then
if oldFiber and (newFiber :: Fiber).alternate == nil then
deleteChild(returnFiber, oldFiber)
end
end
lastPlacedIndex = placeChild(newFiber :: Fiber, lastPlacedIndex, newIdx)
if previousNewFiber == nil then
resultingFirstChild = newFiber
else
previousNewFiber.sibling = newFiber :: Fiber
end
previousNewFiber = newFiber :: Fiber
oldFiber = nextOldFiber
newIdx += 1
step = newChildren.next()
end
if step.done then
deleteRemainingChildren(returnFiber, oldFiber)
return resultingFirstChild
end
if oldFiber == nil then
while not step.done do
local newFiber = createChild(returnFiber, step.value, lanes, step.key)
if newFiber == nil then
newIdx += 1
step = newChildren.next()
continue
end
lastPlacedIndex = placeChild(newFiber :: Fiber, lastPlacedIndex, newIdx)
if previousNewFiber == nil then
resultingFirstChild = newFiber
else
previousNewFiber.sibling = newFiber
end
previousNewFiber = newFiber :: Fiber
newIdx += 1
step = newChildren.next()
end
return resultingFirstChild
end
local existingChildren
while not step.done do
if not existingChildren then
existingChildren = mapRemainingChildren(returnFiber, oldFiber :: Fiber)
end
local newFiber = updateFromMap(
existingChildren,
returnFiber,
newIdx,
step.value,
lanes,
step.key
)
if newFiber ~= nil then
if shouldTrackSideEffects then
if newFiber.alternate ~= nil then
if newFiber.key == nil then
existingChildren[newIdx] = nil
else
existingChildren[newFiber.key] = nil
end
end
end
lastPlacedIndex = placeChild(newFiber, lastPlacedIndex, newIdx)
if previousNewFiber == nil then
resultingFirstChild = newFiber
else
previousNewFiber.sibling = newFiber
end
previousNewFiber = newFiber
end
newIdx += 1
step = newChildren.next()
end
if shouldTrackSideEffects then
for _, child in existingChildren do
deleteChild(returnFiber, child)
end
end
return resultingFirstChild
end
local function reconcileSingleTextNode(
returnFiber: Fiber,
currentFirstChild: Fiber | nil,
textContent: string,
lanes: Lanes
): Fiber
if currentFirstChild ~= nil and (currentFirstChild :: Fiber).tag == HostText then
deleteRemainingChildren(returnFiber, (currentFirstChild :: Fiber).sibling)
local existing = useFiber(currentFirstChild :: Fiber, textContent)
existing.return_ = returnFiber
return existing
end
deleteRemainingChildren(returnFiber, currentFirstChild)
local created = createFiberFromText(textContent, returnFiber.mode, lanes)
created.return_ = returnFiber
return created
end
local function reconcileSingleElement(
returnFiber: Fiber,
currentFirstChild: Fiber | nil,
element: ReactElement,
lanes: Lanes
): Fiber
local key = element.key
local child = currentFirstChild
while child ~= nil do
if child.key == key then
if child.tag == Fragment then
if element.type == REACT_FRAGMENT_TYPE then
deleteRemainingChildren(returnFiber, child.sibling)
local existing = useFiber(child, element.props.children)
existing.return_ = returnFiber
if __DEV__ then
existing._debugSource = element._source
existing._debugOwner = element._owner
end
return existing
end
else
if
child.elementType == element.type
or (__DEV__ and isCompatibleFamilyForHotReloading(child, element))
then
deleteRemainingChildren(returnFiber, child.sibling)
local existing = useFiber(child, element.props)
existing.ref = coerceRef(returnFiber, child, element)
existing.return_ = returnFiber
if __DEV__ then
existing._debugSource = element._source
existing._debugOwner = element._owner
end
return existing
end
end
deleteRemainingChildren(returnFiber, child)
break
else
deleteChild(returnFiber, child)
end
child = child.sibling
end
if element.type == REACT_FRAGMENT_TYPE then
local created = createFiberFromFragment(
element.props.children,
returnFiber.mode,
lanes,
element.key :: string
)
created.return_ = returnFiber
return created
else
local created = createFiberFromElement(element, returnFiber.mode, lanes)
created.ref = coerceRef(returnFiber, currentFirstChild, element)
created.return_ = returnFiber
return created
end
end
local function reconcileSinglePortal(
returnFiber: Fiber,
currentFirstChild: Fiber | nil,
portal: ReactPortal,
lanes: Lanes
): Fiber
local key = portal.key
local child = currentFirstChild
while child ~= nil do
if child.key == key then
if
child.tag == HostPortal
and child.stateNode.containerInfo == portal.containerInfo
and child.stateNode.implementation == portal.implementation
then
deleteRemainingChildren(returnFiber, child.sibling)
local existing = useFiber(child, portal.children or {})
existing.return_ = returnFiber
return existing
else
deleteRemainingChildren(returnFiber, child)
break
end
else
deleteChild(returnFiber, child)
end
child = child.sibling
end
local created = createFiberFromPortal(portal, returnFiber.mode, lanes)
created.return_ = returnFiber
return created
end
local function reconcileChildFibers(
returnFiber: Fiber,
currentFirstChild: Fiber | nil,
newChild: any,
lanes: Lanes
): Fiber | nil
local typeOfNewChild = type(newChild)
local isUnkeyedTopLevelFragment = newChild ~= nil
and typeOfNewChild == "table"
and newChild.type == REACT_FRAGMENT_TYPE
and newChild.key == nil
if isUnkeyedTopLevelFragment then
newChild = newChild.props.children
typeOfNewChild = type(newChild)
end
local newChildIsArray = isArray(newChild)
local isObject = newChild ~= nil
and typeOfNewChild == "table"
and not newChildIsArray
if isObject then
local newChildTypeof = newChild["$$typeof"]
if newChildTypeof == REACT_ELEMENT_TYPE then
return placeSingleChild(
reconcileSingleElement(
returnFiber,
currentFirstChild,
newChild,
lanes
)
)
elseif newChildTypeof == REACT_PORTAL_TYPE then
return placeSingleChild(
reconcileSinglePortal(returnFiber, currentFirstChild, newChild, lanes)
)
elseif newChildTypeof == REACT_LAZY_TYPE then
if enableLazyElements then
local payload = newChild._payload
local init = newChild._init
return reconcileChildFibers(
returnFiber,
currentFirstChild,
init(payload),
lanes
)
end
end
elseif newChildIsArray then
return reconcileChildrenArray(returnFiber, currentFirstChild, newChild, lanes)
elseif typeOfNewChild == "string" or typeOfNewChild == "number" then
return placeSingleChild(
reconcileSingleTextNode(
returnFiber,
currentFirstChild,
tostring(newChild),
lanes
)
)
end
local newChildIteratorFn = getIteratorFn(newChild)
if newChildIteratorFn then
return reconcileChildrenIterator(
returnFiber,
currentFirstChild,
newChild,
lanes,
newChildIteratorFn
)
end
if __DEV__ then
if typeOfNewChild == "function" then
warnOnFunctionType(returnFiber)
end
end
if newChild == nil and not isUnkeyedTopLevelFragment then
local shouldFallThrough = false
if
shouldFallThrough
and (
returnFiber.tag == ClassComponent
or returnFiber.tag == FunctionComponent
or returnFiber.tag == ForwardRef
or returnFiber.tag == SimpleMemoComponent
)
then
invariant(
false,
"%s(...): Nothing was returned from render. This usually means a "
.. "return statement is missing. Or, to render nothing, "
.. "return nil.",
getComponentName(returnFiber.type) or "Component"
)
end
end
return deleteRemainingChildren(returnFiber, currentFirstChild)
end
return reconcileChildFibers
end
exports.reconcileChildFibers = ChildReconciler(true)
exports.mountChildFibers = ChildReconciler(false)
exports.cloneChildFibers = function(current: Fiber | nil, workInProgress: Fiber)
if workInProgress.child == nil then
return
end
local currentChild = workInProgress.child :: Fiber
local newChild = createWorkInProgress(currentChild, currentChild.pendingProps)
workInProgress.child = newChild
newChild.return_ = workInProgress
while currentChild.sibling ~= nil do
currentChild = currentChild.sibling
newChild.sibling = createWorkInProgress(currentChild, currentChild.pendingProps)
newChild = newChild.sibling :: Fiber
newChild.return_ = workInProgress
end
newChild.sibling = nil
end
exports.resetChildFibers = function(workInProgress: Fiber, lanes: Lanes): ()
local child = workInProgress.child
while child ~= nil do
resetWorkInProgress(child, lanes)
child = child.sibling
end
end
return exports
end
end)())
__register("ReactReconciler/ReactCurrentFiber", (function()
local script = __makeProxy({"ReactReconciler","ReactCurrentFiber"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local __DEV__ = ReactGlobals.__DEV__ :: boolean
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
local ReactSharedInternals = __require(Packages.Shared).ReactSharedInternals
local ReactFiberComponentStack = __require(script.Parent.ReactFiberComponentStack)
local getStackByFiberInDevAndProd = ReactFiberComponentStack.getStackByFiberInDevAndProd
local getComponentName = __require(Packages.Shared).getComponentName
local ReactDebugCurrentFrame = ReactSharedInternals.ReactDebugCurrentFrame
type Exports = {
current: Fiber | nil,
isRendering: boolean,
[string]: any,
}
local exports: Exports = {
current = nil,
isRendering = false,
}
exports.getCurrentFiberOwnerNameInDevOrNull = function(): string?
if __DEV__ then
if exports.current == nil then
return nil
end
local owner = (exports.current :: Fiber)._debugOwner
if owner then
return getComponentName(owner.type)
end
end
return nil
end
local function getCurrentFiberStackInDev(): string
if __DEV__ then
if exports.current == nil then
return ""
end
return getStackByFiberInDevAndProd(exports.current :: Fiber)
end
return ""
end
exports.resetCurrentFiber = function(): ()
if __DEV__ then
(ReactDebugCurrentFrame :: any).getCurrentStack = nil
exports.current = nil
exports.isRendering = false
end
end
exports.setCurrentFiber = function(fiber: Fiber): ()
if __DEV__ then
(ReactDebugCurrentFrame :: any).getCurrentStack = getCurrentFiberStackInDev
exports.current = fiber
exports.isRendering = false
end
end
exports.setIsRendering = function(rendering: boolean): ()
if __DEV__ then
exports.isRendering = rendering
end
end
exports.getIsRendering = function(): boolean
if __DEV__ then
return exports.isRendering
end
return false
end
return exports
end
end)())
__register("ReactReconciler/ReactFiber.new", (function()
local script = __makeProxy({"ReactReconciler","ReactFiber.new"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local LuauPolyfill = __require(Packages.LuauPolyfill)
local Object = LuauPolyfill.Object
local Array = LuauPolyfill.Array
local inspect = LuauPolyfill.util.inspect
local __DEV__ = ReactGlobals.__DEV__
local console = __require(Packages.Shared).console
local ReactTypes = __require(Packages.Shared)
type ReactElement = ReactTypes.ReactElement<any, any>
type ReactFragment = ReactTypes.ReactFragment
type ReactPortal = ReactTypes.ReactPortal
type ReactFundamentalComponent<T, U> = ReactTypes.ReactFundamentalComponent<T, U>
type ReactScope = ReactTypes.ReactScope
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
type RoactStableKey = ReactInternalTypes.RoactStableKey
local ReactRootTags = __require(script.Parent.ReactRootTags)
type RootTag = ReactRootTags.RootTag
local ReactWorkTags = __require(script.Parent.ReactWorkTags)
type WorkTag = ReactWorkTags.WorkTag
local ReactTypeOfMode = __require(script.Parent.ReactTypeOfMode)
type TypeOfMode = ReactTypeOfMode.TypeOfMode
local ReactFiberLane = __require(script.Parent.ReactFiberLane)
type Lanes = ReactFiberLane.Lanes
local ReactFiberHostConfig = __require(script.Parent.ReactFiberHostConfig)
type SuspenseInstance = ReactFiberHostConfig.SuspenseInstance
local ReactFiberOffscreenComponent = __require(script.Parent.ReactFiberOffscreenComponent)
type OffscreenProps = ReactFiberOffscreenComponent.OffscreenProps
local invariant = __require(Packages.Shared).invariant
local ReactFeatureFlags = __require(Packages.Shared).ReactFeatureFlags
local enableProfilerTimer = ReactFeatureFlags.enableProfilerTimer
local ReactFiberFlags = __require(script.Parent.ReactFiberFlags)
local NoFlags = ReactFiberFlags.NoFlags
local Placement = ReactFiberFlags.Placement
local StaticMask = ReactFiberFlags.StaticMask
local ConcurrentRoot = ReactRootTags.ConcurrentRoot
local BlockingRoot = ReactRootTags.BlockingRoot
local IndeterminateComponent = ReactWorkTags.IndeterminateComponent
local ClassComponent = ReactWorkTags.ClassComponent
local HostRoot = ReactWorkTags.HostRoot
local HostComponent = ReactWorkTags.HostComponent
local HostText = ReactWorkTags.HostText
local HostPortal = ReactWorkTags.HostPortal
local ForwardRef = ReactWorkTags.ForwardRef
local Fragment = ReactWorkTags.Fragment
local Mode = ReactWorkTags.Mode
local ContextProvider = ReactWorkTags.ContextProvider
local ContextConsumer = ReactWorkTags.ContextConsumer
local Profiler = ReactWorkTags.Profiler
local SuspenseComponent = ReactWorkTags.SuspenseComponent
local SuspenseListComponent = ReactWorkTags.SuspenseListComponent
local DehydratedFragment = ReactWorkTags.DehydratedFragment
local FunctionComponent = ReactWorkTags.FunctionComponent
local MemoComponent = ReactWorkTags.MemoComponent
local SimpleMemoComponent = ReactWorkTags.SimpleMemoComponent
local LazyComponent = ReactWorkTags.LazyComponent
local FundamentalComponent = ReactWorkTags.FundamentalComponent
local ScopeComponent = ReactWorkTags.ScopeComponent
local OffscreenComponent = ReactWorkTags.OffscreenComponent
local LegacyHiddenComponent = ReactWorkTags.LegacyHiddenComponent
local getComponentName = __require(Packages.Shared).getComponentName
local ReactFiberDevToolsHook = __require(script.Parent["ReactFiberDevToolsHook.new"])
local isDevToolsPresent = ReactFiberDevToolsHook.isDevToolsPresent
local ReactFiberHotReloading = __require(script.Parent["ReactFiberHotReloading.new"])
local resolveClassForHotReloading = ReactFiberHotReloading.resolveClassForHotReloading
local resolveFunctionForHotReloading =
ReactFiberHotReloading.resolveFunctionForHotReloading
local resolveForwardRefForHotReloading =
ReactFiberHotReloading.resolveForwardRefForHotReloading
local NoLanes = ReactFiberLane.NoLanes
local NoMode = ReactTypeOfMode.NoMode
local ConcurrentMode = ReactTypeOfMode.ConcurrentMode
local DebugTracingMode = ReactTypeOfMode.DebugTracingMode
local ProfileMode = ReactTypeOfMode.ProfileMode
local StrictMode = ReactTypeOfMode.StrictMode
local BlockingMode = ReactTypeOfMode.BlockingMode
local ReactSymbols = __require(Packages.Shared).ReactSymbols
local REACT_FORWARD_REF_TYPE = ReactSymbols.REACT_FORWARD_REF_TYPE
local REACT_FRAGMENT_TYPE = ReactSymbols.REACT_FRAGMENT_TYPE
local REACT_ELEMENT_TYPE = ReactSymbols.REACT_ELEMENT_TYPE
local REACT_DEBUG_TRACING_MODE_TYPE = ReactSymbols.REACT_DEBUG_TRACING_MODE_TYPE
local REACT_STRICT_MODE_TYPE = ReactSymbols.REACT_STRICT_MODE_TYPE
local REACT_PROFILER_TYPE = ReactSymbols.REACT_PROFILER_TYPE
local REACT_PROVIDER_TYPE = ReactSymbols.REACT_PROVIDER_TYPE
local REACT_CONTEXT_TYPE = ReactSymbols.REACT_CONTEXT_TYPE
local REACT_SUSPENSE_TYPE = ReactSymbols.REACT_SUSPENSE_TYPE
local REACT_SUSPENSE_LIST_TYPE = ReactSymbols.REACT_SUSPENSE_LIST_TYPE
local REACT_MEMO_TYPE = ReactSymbols.REACT_MEMO_TYPE
local REACT_LAZY_TYPE = ReactSymbols.REACT_LAZY_TYPE
local REACT_OFFSCREEN_TYPE = ReactSymbols.REACT_OFFSCREEN_TYPE
local REACT_LEGACY_HIDDEN_TYPE = ReactSymbols.REACT_LEGACY_HIDDEN_TYPE
local createFiberFromScope, createFiberFromProfiler, createFiberFromFragment, createFiberFromFundamental, createFiberFromSuspense, createFiberFromOffscreen, createFiberFromLegacyHidden, createFiberFromSuspenseList
local debugCounter = 1
local function createFiber(
tag: WorkTag,
pendingProps: any,
key: RoactStableKey?,
mode: TypeOfMode,
elementType: any?,
type_: any?,
stateNode: any?,
lanes: Lanes?
): Fiber
local node: Fiber = {
tag = tag,
key = key,
elementType = elementType,
type = type_,
stateNode = stateNode,
index = 1,
pendingProps = pendingProps,
mode = mode,
flags = NoFlags,
subtreeFlags = NoFlags,
lanes = if lanes then lanes else NoLanes,
childLanes = NoLanes,
} :: any
if enableProfilerTimer then
node.actualDuration = 0
node.actualStartTime = -1
node.selfBaseDuration = 0
node.treeBaseDuration = 0
end
if __DEV__ then
node._debugID = debugCounter
debugCounter += 1
node._debugSource = nil
node._debugOwner = nil
node._debugNeedsRemount = false
node._debugHookTypes = nil
end
return node
end
function _shouldConstruct(Component)
return type(Component) ~= "function" and not not Component.isReactComponent
end
local function isSimpleFunctionComponent(type_: any)
return type(type_) == "function"
end
local function resolveLazyComponentTag(Component: any): WorkTag
local typeofComponent = typeof(Component)
if typeofComponent == "function" then
return FunctionComponent
end
if typeofComponent == "table" then
if Component.isReactComponent then
return ClassComponent
end
local __typeof = Component["$$typeof"]
if __typeof == REACT_FORWARD_REF_TYPE then
return ForwardRef
end
if __typeof == REACT_MEMO_TYPE then
return MemoComponent
end
end
return IndeterminateComponent
end
local function createWorkInProgress(current: Fiber, pendingProps: any): Fiber
local workInProgress = current.alternate :: Fiber
if workInProgress == nil then
workInProgress = createFiber(
current.tag,
pendingProps,
current.key,
current.mode,
current.elementType,
current.type,
current.stateNode
)
if __DEV__ then
workInProgress._debugID = current._debugID
workInProgress._debugSource = current._debugSource
workInProgress._debugOwner = current._debugOwner
workInProgress._debugHookTypes = current._debugHookTypes
end
workInProgress.alternate = current
current.alternate = workInProgress
else
workInProgress.pendingProps = pendingProps
workInProgress.type = current.type
workInProgress.flags = NoFlags
workInProgress.subtreeFlags = NoFlags
workInProgress.deletions = nil
if enableProfilerTimer then
workInProgress.actualDuration = 0
workInProgress.actualStartTime = -1
end
end
workInProgress.flags = bit32.band(current.flags, StaticMask)
workInProgress.childLanes = current.childLanes
workInProgress.lanes = current.lanes
workInProgress.child = current.child
workInProgress.memoizedProps = current.memoizedProps
workInProgress.memoizedState = current.memoizedState
workInProgress.updateQueue = current.updateQueue
local currentDependencies = current.dependencies
if currentDependencies == nil then
workInProgress.dependencies = nil
else
workInProgress.dependencies = {
lanes = currentDependencies.lanes,
firstContext = currentDependencies.firstContext,
}
end
workInProgress.sibling = current.sibling
workInProgress.index = current.index
workInProgress.ref = current.ref
if enableProfilerTimer then
workInProgress.selfBaseDuration = current.selfBaseDuration
workInProgress.treeBaseDuration = current.treeBaseDuration
end
if __DEV__ then
workInProgress._debugNeedsRemount = current._debugNeedsRemount
if
workInProgress.tag == IndeterminateComponent
or workInProgress.tag == FunctionComponent
or workInProgress.tag == SimpleMemoComponent
then
workInProgress.type = resolveFunctionForHotReloading(current.type)
elseif workInProgress.tag == ClassComponent then
workInProgress.type = resolveClassForHotReloading(current.type)
elseif workInProgress.tag == ForwardRef then
workInProgress.type = resolveForwardRefForHotReloading(current.type)
end
end
return workInProgress
end
local function resetWorkInProgress(workInProgress: Fiber, renderLanes: Lanes)
workInProgress.flags =
bit32.band(workInProgress.flags, bit32.bor(StaticMask, Placement))
local current = workInProgress.alternate
if current == nil then
workInProgress.childLanes = NoLanes
workInProgress.lanes = renderLanes
workInProgress.child = nil
workInProgress.subtreeFlags = NoFlags
workInProgress.memoizedProps = nil
workInProgress.memoizedState = nil
workInProgress.updateQueue = nil
workInProgress.dependencies = nil
workInProgress.stateNode = nil
if enableProfilerTimer then
workInProgress.selfBaseDuration = 0
workInProgress.treeBaseDuration = 0
end
else
workInProgress.childLanes = current.childLanes
workInProgress.lanes = current.lanes
workInProgress.child = current.child
workInProgress.subtreeFlags = current.subtreeFlags
workInProgress.deletions = nil
workInProgress.memoizedProps = current.memoizedProps
workInProgress.memoizedState = current.memoizedState
workInProgress.updateQueue = current.updateQueue
workInProgress.type = current.type
local currentDependencies = current.dependencies
if currentDependencies == nil then
workInProgress.dependencies = nil
else
workInProgress.dependencies = {
lanes = currentDependencies.lanes,
firstContext = currentDependencies.firstContext,
}
end
if enableProfilerTimer then
workInProgress.selfBaseDuration = current.selfBaseDuration
workInProgress.treeBaseDuration = current.treeBaseDuration
end
end
return workInProgress
end
local function createHostRootFiber(tag: RootTag): Fiber
local mode
if tag == ConcurrentRoot then
mode = bit32.bor(ConcurrentMode, BlockingMode, StrictMode)
elseif tag == BlockingRoot then
mode = bit32.bor(BlockingMode, StrictMode)
else
mode = NoMode
end
if enableProfilerTimer and isDevToolsPresent() then
mode = bit32.bor(mode, ProfileMode)
end
return createFiber(HostRoot, nil, nil, mode)
end
local function createFiberFromTypeAndProps(
type_: any,
key: string?,
pendingProps: any,
owner: nil | Fiber,
mode: TypeOfMode,
lanes: Lanes
): Fiber
local fiberTag = IndeterminateComponent
local resolvedType = type_
local typeOfType_ = type(type_)
if typeOfType_ == "function" then
if __DEV__ then
resolvedType = resolveFunctionForHotReloading(resolvedType)
end
elseif typeOfType_ == "table" and not not type_.isReactComponent then
fiberTag = ClassComponent
if __DEV__ then
resolvedType = resolveClassForHotReloading(resolvedType)
end
elseif typeOfType_ == "string" then
fiberTag = HostComponent
else
if type_ == REACT_FRAGMENT_TYPE then
return createFiberFromFragment(pendingProps.children, mode, lanes, key)
elseif type_ == REACT_DEBUG_TRACING_MODE_TYPE then
fiberTag = Mode
mode = bit32.bor(mode, DebugTracingMode)
elseif type_ == REACT_STRICT_MODE_TYPE then
fiberTag = Mode
mode = bit32.bor(mode, StrictMode)
elseif type_ == REACT_PROFILER_TYPE then
return createFiberFromProfiler(pendingProps, mode, lanes, key)
elseif type_ == REACT_SUSPENSE_TYPE then
return createFiberFromSuspense(pendingProps, mode, lanes, key)
elseif type_ == REACT_OFFSCREEN_TYPE then
return createFiberFromOffscreen(pendingProps, mode, lanes, key)
elseif type_ == REACT_LEGACY_HIDDEN_TYPE then
return createFiberFromLegacyHidden(pendingProps, mode, lanes, key)
else
local shouldBreak = false
local type_typeof
if typeOfType_ == "table" then
type_typeof = type_["$$typeof"]
if type_typeof == REACT_PROVIDER_TYPE then
fiberTag = ContextProvider
shouldBreak = true
elseif type_typeof == REACT_CONTEXT_TYPE then
fiberTag = ContextConsumer
shouldBreak = true
elseif type_typeof == REACT_FORWARD_REF_TYPE then
fiberTag = ForwardRef
if __DEV__ then
resolvedType = resolveForwardRefForHotReloading(resolvedType)
end
shouldBreak = true
elseif type_typeof == REACT_MEMO_TYPE then
fiberTag = MemoComponent
shouldBreak = true
elseif type_typeof == REACT_LAZY_TYPE then
fiberTag = LazyComponent
resolvedType = nil
shouldBreak = true
end
end
if not shouldBreak then
local info = ""
if __DEV__ then
if
type_ == nil
or (typeOfType_ == "table" and #Object.keys(type_) == 0)
then
info ..= " You likely forgot to export your component from the file " .. "it's defined in, or you might have mixed up default and " .. "named imports."
elseif type_ ~= nil and typeOfType_ == "table" then
info ..= "\n" .. inspect(type_)
end
local ownerName
if owner then
ownerName = getComponentName(owner.type)
end
if ownerName ~= nil and ownerName ~= "" then
info ..= "\n\nCheck the render method of `" .. ownerName .. "`."
elseif owner then
info ..= "\n" .. inspect(owner)
end
end
local typeString
if type_ == nil then
typeString = "nil"
elseif Array.isArray(type_) then
typeString = "array"
elseif typeOfType_ == "table" and type_typeof == REACT_ELEMENT_TYPE then
typeString =
string.format("<%s />", getComponentName(type_.type) or "Unknown")
info =
" Did you accidentally export a JSX literal or Element instead of a component?"
else
typeString = typeOfType_
end
invariant(
false,
"Element type is invalid: expected a string (for built-in "
.. "components) or a class/function (for composite components) "
.. "but got: %s.%s",
typeString,
info
)
end
end
end
local fiber =
createFiber(fiberTag, pendingProps, key, mode, type_, resolvedType, nil, lanes)
if __DEV__ then
fiber._debugOwner = owner
end
return fiber
end
local function createFiberFromElement(
element: ReactElement,
mode: TypeOfMode,
lanes: Lanes
): Fiber
local owner = nil
if __DEV__ then
owner = element._owner
end
local type = element.type
local key = element.key
local pendingProps = element.props
local fiber = createFiberFromTypeAndProps(
type,
key :: string,
pendingProps,
owner,
mode,
lanes
)
if __DEV__ then
fiber._debugSource = element._source
fiber._debugOwner = element._owner
end
return fiber
end
function createFiberFromFragment(
elements: ReactFragment,
mode: TypeOfMode,
lanes: Lanes,
key: string?
): Fiber
local fiber = createFiber(Fragment, elements, key, mode, nil, nil, nil, lanes)
return fiber
end
function createFiberFromFundamental(
fundamentalComponent: ReactFundamentalComponent<any, any>,
pendingProps: any,
mode: TypeOfMode,
lanes: Lanes,
key: string?
): Fiber
local fiber = createFiber(
FundamentalComponent,
pendingProps,
key,
mode,
fundamentalComponent,
fundamentalComponent,
nil,
lanes
)
return fiber
end
function createFiberFromScope(
scope: ReactScope,
pendingProps: any,
mode: TypeOfMode,
lanes: Lanes,
key: string?
): Fiber
local fiber =
createFiber(ScopeComponent, pendingProps, key, mode, scope, scope, nil, lanes)
return fiber
end
function createFiberFromProfiler(
pendingProps: any,
mode: TypeOfMode,
lanes: Lanes,
key: string?
): Fiber
if __DEV__ then
if typeof(pendingProps.id) ~= "string" then
console.error('Profiler must specify an "id" as a prop')
end
end
local fiber = createFiber(
Profiler,
pendingProps,
key,
bit32.bor(mode, ProfileMode),
REACT_PROFILER_TYPE,
REACT_PROFILER_TYPE,
if enableProfilerTimer
then {
effectDuration = 0,
passiveEffectDuration = 0,
}
else nil,
lanes
)
return fiber
end
function createFiberFromSuspense(
pendingProps: any,
mode: TypeOfMode,
lanes: Lanes,
key: string?
): Fiber
local fiber = createFiber(
SuspenseComponent,
pendingProps,
key,
mode,
REACT_SUSPENSE_TYPE,
REACT_SUSPENSE_TYPE,
nil,
lanes
)
return fiber
end
function createFiberFromSuspenseList(
pendingProps: any,
mode: TypeOfMode,
lanes: Lanes,
key: string?
): Fiber
local fiber = createFiber(
SuspenseListComponent,
pendingProps,
key,
mode,
REACT_SUSPENSE_LIST_TYPE,
if __DEV__ then REACT_SUSPENSE_LIST_TYPE else nil,
nil,
lanes
)
return fiber
end
function createFiberFromOffscreen(
pendingProps: OffscreenProps,
mode: TypeOfMode,
lanes: Lanes,
key: string?
): Fiber
local fiber = createFiber(
OffscreenComponent,
pendingProps,
key,
mode,
REACT_OFFSCREEN_TYPE,
if __DEV__ then REACT_OFFSCREEN_TYPE else nil,
nil,
lanes
)
return fiber
end
function createFiberFromLegacyHidden(
pendingProps: OffscreenProps,
mode: TypeOfMode,
lanes: Lanes,
key: string?
): Fiber
local fiber = createFiber(
LegacyHiddenComponent,
pendingProps,
key,
mode,
REACT_LEGACY_HIDDEN_TYPE,
if __DEV__ then REACT_LEGACY_HIDDEN_TYPE else nil,
nil,
lanes
)
return fiber
end
local function createFiberFromText(content: string, mode: TypeOfMode, lanes: Lanes): Fiber
local fiber = createFiber(HostText, content, nil, mode, nil, nil, nil, lanes)
return fiber
end
local function createFiberFromHostInstanceForDeletion(): Fiber
local fiber = createFiber(HostComponent, nil, nil, NoMode, "DELETED", "DELETED")
return fiber
end
local function createFiberFromDehydratedFragment(dehydratedNode: SuspenseInstance): Fiber
local fiber =
createFiber(DehydratedFragment, nil, nil, NoMode, nil, nil, dehydratedNode)
return fiber
end
local function createFiberFromPortal(
portal: ReactPortal,
mode: TypeOfMode,
lanes: Lanes
): Fiber
local pendingProps = if portal.children ~= nil then portal.children else {}
local fiber = createFiber(HostPortal, pendingProps, portal.key, mode, nil, nil, {
containerInfo = portal.containerInfo,
pendingChildren = nil,
implementation = portal.implementation,
}, lanes)
return fiber
end
local function assignFiberPropertiesInDEV(target: Fiber, source: Fiber): Fiber
if target == nil then
target = createFiber(IndeterminateComponent, nil, nil, NoMode)
end
target.tag = source.tag
target.key = source.key
target.elementType = source.elementType
target.type = source.type
target.stateNode = source.stateNode
target.return_ = source.return_
target.child = source.child
target.sibling = source.sibling
target.index = source.index
target.ref = source.ref
target.pendingProps = source.pendingProps
target.memoizedProps = source.memoizedProps
target.updateQueue = source.updateQueue
target.memoizedState = source.memoizedState
target.dependencies = source.dependencies
target.mode = source.mode
target.flags = source.flags
target.subtreeFlags = source.subtreeFlags
target.deletions = source.deletions
target.lanes = source.lanes
target.childLanes = source.childLanes
target.alternate = source.alternate
if enableProfilerTimer then
target.actualDuration = source.actualDuration
target.actualStartTime = source.actualStartTime
target.selfBaseDuration = source.selfBaseDuration
target.treeBaseDuration = source.treeBaseDuration
end
target._debugID = source._debugID
target._debugSource = source._debugSource
target._debugOwner = source._debugOwner
target._debugNeedsRemount = source._debugNeedsRemount
target._debugHookTypes = source._debugHookTypes
return target
end
return {
isSimpleFunctionComponent = isSimpleFunctionComponent,
resolveLazyComponentTag = resolveLazyComponentTag,
createWorkInProgress = createWorkInProgress,
resetWorkInProgress = resetWorkInProgress,
createHostRootFiber = createHostRootFiber,
createFiberFromTypeAndProps = createFiberFromTypeAndProps,
createFiberFromElement = createFiberFromElement,
createFiberFromFragment = createFiberFromFragment,
createFiberFromFundamental = createFiberFromFundamental,
createFiberFromSuspense = createFiberFromSuspense,
createFiberFromSuspenseList = createFiberFromSuspenseList,
createFiberFromOffscreen = createFiberFromOffscreen,
createFiberFromLegacyHidden = createFiberFromLegacyHidden,
createFiberFromText = createFiberFromText,
createFiberFromHostInstanceForDeletion = createFiberFromHostInstanceForDeletion,
createFiberFromDehydratedFragment = createFiberFromDehydratedFragment,
createFiberFromPortal = createFiberFromPortal,
assignFiberPropertiesInDEV = assignFiberPropertiesInDEV,
}
end
end)())
__register("ReactReconciler/ReactFiberBeginWork.new", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberBeginWork.new"})
return function()
local function unimplemented(message: string)
print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
print("UNIMPLEMENTED ERROR: " .. tostring(message))
error("FIXME (roblox): " .. message .. " is unimplemented", 2)
end
local Packages = script.Parent.Parent
local Shared = __require(Packages.Shared)
local console = Shared.console
local LuauPolyfill = __require(Packages.LuauPolyfill)
local Array = LuauPolyfill.Array
local Object = LuauPolyfill.Object
local inspect = LuauPolyfill.util.inspect
local __DEV__ = __require(Packages.ReactGlobals).__DEV__
local __DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ =
__require(Packages.ReactGlobals).__DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__
local __COMPAT_WARNINGS__ = __require(Packages.ReactGlobals).__COMPAT_WARNINGS__
local ReactTypes = __require(Packages.Shared)
type ReactProviderType<T> = ReactTypes.ReactProviderType<T>
type ReactContext<T> = ReactTypes.ReactContext<T>
type React_Component<Props, State> = ReactTypes.React_Component<Props, State>
local React = __require(Packages.React)
type LazyComponentType<T, P> = React.LazyComponent<T, P>
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
type FiberRoot = ReactInternalTypes.FiberRoot
local ReactFiberLane = __require(script.Parent.ReactFiberLane)
type Lanes = ReactFiberLane.Lanes
local ReactFiberSuspenseComponent =
__require(script.Parent["ReactFiberSuspenseComponent.new"])
type SuspenseState = ReactFiberSuspenseComponent.SuspenseState
type SuspenseListRenderState = ReactFiberSuspenseComponent.SuspenseListRenderState
type SuspenseListTailMode = ReactFiberSuspenseComponent.SuspenseListTailMode
local ReactFiberSuspenseContext = __require(script.Parent["ReactFiberSuspenseContext.new"])
type SuspenseContext = ReactFiberSuspenseContext.SuspenseContext
local ReactFiberOffscreenComponent = __require(script.Parent.ReactFiberOffscreenComponent)
type OffscreenProps = ReactFiberOffscreenComponent.OffscreenProps
type OffscreenState = ReactFiberOffscreenComponent.OffscreenState
local checkPropTypes = __require(Packages.Shared).checkPropTypes
local ReactWorkTags = __require(script.Parent.ReactWorkTags)
local FunctionComponent = ReactWorkTags.FunctionComponent
local ClassComponent = ReactWorkTags.ClassComponent
local HostRoot = ReactWorkTags.HostRoot
local HostComponent = ReactWorkTags.HostComponent
local HostText = ReactWorkTags.HostText
local HostPortal = ReactWorkTags.HostPortal
local ForwardRef = ReactWorkTags.ForwardRef
local Fragment = ReactWorkTags.Fragment
local Mode = ReactWorkTags.Mode
local ContextProvider = ReactWorkTags.ContextProvider
local ContextConsumer = ReactWorkTags.ContextConsumer
local Profiler = ReactWorkTags.Profiler
local SuspenseComponent = ReactWorkTags.SuspenseComponent
local SuspenseListComponent = ReactWorkTags.SuspenseListComponent
local MemoComponent = ReactWorkTags.MemoComponent
local SimpleMemoComponent = ReactWorkTags.SimpleMemoComponent
local LazyComponent = ReactWorkTags.LazyComponent
local IncompleteClassComponent = ReactWorkTags.IncompleteClassComponent
local OffscreenComponent = ReactWorkTags.OffscreenComponent
local LegacyHiddenComponent = ReactWorkTags.LegacyHiddenComponent
local ReactFiberFlags = __require(script.Parent.ReactFiberFlags)
local NoFlags = ReactFiberFlags.NoFlags
local StaticMask = ReactFiberFlags.StaticMask
local PerformedWork = ReactFiberFlags.PerformedWork
local Placement = ReactFiberFlags.Placement
local Hydrating = ReactFiberFlags.Hydrating
local ContentReset = ReactFiberFlags.ContentReset
local DidCapture = ReactFiberFlags.DidCapture
local Ref = ReactFiberFlags.Ref
local Deletion = ReactFiberFlags.Deletion
local ForceUpdateForLegacySuspense = ReactFiberFlags.ForceUpdateForLegacySuspense
local ReactSharedInternals = __require(Packages.Shared).ReactSharedInternals
local ReactFeatureFlags = __require(Packages.Shared).ReactFeatureFlags
local debugRenderPhaseSideEffectsForStrictMode =
ReactFeatureFlags.debugRenderPhaseSideEffectsForStrictMode
local disableLegacyContext = ReactFeatureFlags.disableLegacyContext
local disableModulePatternComponents = ReactFeatureFlags.disableModulePatternComponents
local enableProfilerTimer = ReactFeatureFlags.enableProfilerTimer
local enableSchedulerTracing = ReactFeatureFlags.enableSchedulerTracing
local enableSuspenseServerRenderer = ReactFeatureFlags.enableSuspenseServerRenderer
local warnAboutDefaultPropsOnFunctionComponents =
ReactFeatureFlags.warnAboutDefaultPropsOnFunctionComponents
local invariant = __require(Packages.Shared).invariant
local describeError = __require(Packages.Shared).describeError
local shallowEqual = __require(Packages.Shared).shallowEqual
local getComponentName = __require(Packages.Shared).getComponentName
local ReactSymbols = __require(Packages.Shared).ReactSymbols
local REACT_LAZY_TYPE = ReactSymbols.REACT_LAZY_TYPE
local _getIteratorFn = ReactSymbols.getIteratorFn
local ReactStrictModeWarnings = __require(script.Parent["ReactStrictModeWarnings.new"])
local ReactCurrentFiber = __require(script.Parent.ReactCurrentFiber)
local getCurrentFiberOwnerNameInDevOrNull =
ReactCurrentFiber.getCurrentFiberOwnerNameInDevOrNull
local setIsRendering = ReactCurrentFiber.setIsRendering
local ReactFiberHotReloadingModule = __require(script.Parent["ReactFiberHotReloading.new"])
local resolveFunctionForHotReloading =
ReactFiberHotReloadingModule.resolveFunctionForHotReloading
local resolveForwardRefForHotReloading =
ReactFiberHotReloadingModule.resolveForwardRefForHotReloading
local resolveClassForHotReloading =
ReactFiberHotReloadingModule.resolveClassForHotReloading
local ReactChildFiber = __require(script.Parent["ReactChildFiber.new"]) :: any
local mountChildFibers = ReactChildFiber.mountChildFibers
local reconcileChildFibers = ReactChildFiber.reconcileChildFibers
local cloneChildFibers = ReactChildFiber.cloneChildFibers
local ReactUpdateQueue = __require(script.Parent["ReactUpdateQueue.new"])
local processUpdateQueue = ReactUpdateQueue.processUpdateQueue
local cloneUpdateQueue = ReactUpdateQueue.cloneUpdateQueue
local initializeUpdateQueue = ReactUpdateQueue.initializeUpdateQueue
local ReactTypeOfMode = __require(script.Parent.ReactTypeOfMode)
local ConcurrentMode = ReactTypeOfMode.ConcurrentMode
local NoMode = ReactTypeOfMode.NoMode
local ProfileMode = ReactTypeOfMode.ProfileMode
local StrictMode = ReactTypeOfMode.StrictMode
local BlockingMode = ReactTypeOfMode.BlockingMode
local ReactFiberHostConfig = __require(script.Parent.ReactFiberHostConfig)
local shouldSetTextContent = ReactFiberHostConfig.shouldSetTextContent
local isSuspenseInstancePending = ReactFiberHostConfig.isSuspenseInstancePending
local isSuspenseInstanceFallback = ReactFiberHostConfig.isSuspenseInstanceFallback
local registerSuspenseInstanceRetry = ReactFiberHostConfig.registerSuspenseInstanceRetry
local supportsHydration = ReactFiberHostConfig.supportsHydration
type SuspenseInstance = ReactFiberHostConfig.SuspenseInstance
local ReactFiberHostContext = __require(script.Parent["ReactFiberHostContext.new"])
local pushHostContext = ReactFiberHostContext.pushHostContext
local pushHostContainer = ReactFiberHostContext.pushHostContainer
local suspenseStackCursor = ReactFiberSuspenseContext.suspenseStackCursor
local hasSuspenseContext = ReactFiberSuspenseContext.hasSuspenseContext
local ForceSuspenseFallback = ReactFiberSuspenseContext.ForceSuspenseFallback
local addSubtreeSuspenseContext = ReactFiberSuspenseContext.addSubtreeSuspenseContext
local InvisibleParentSuspenseContext =
ReactFiberSuspenseContext.InvisibleParentSuspenseContext
local pushSuspenseContext = ReactFiberSuspenseContext.pushSuspenseContext
local setDefaultShallowSuspenseContext =
ReactFiberSuspenseContext.setDefaultShallowSuspenseContext
local ReactFiberNewContext = __require(script.Parent["ReactFiberNewContext.new"])
local propagateContextChange = ReactFiberNewContext.propagateContextChange
local readContext = ReactFiberNewContext.readContext
local calculateChangedBits = ReactFiberNewContext.calculateChangedBits
local prepareToReadContext = ReactFiberNewContext.prepareToReadContext
local pushProvider = ReactFiberNewContext.pushProvider
local lazyRefs = {
renderWithHooksRef = nil :: any,
bailoutHooksRef = nil :: any,
shouldSuspendRef = nil :: any,
}
local function shouldSuspend(fiber: Fiber): boolean
if not lazyRefs.shouldSuspendRef then
lazyRefs.shouldSuspendRef =
__require(script.Parent.ReactFiberReconciler).shouldSuspend
end
return lazyRefs.shouldSuspendRef(fiber)
end
local function initReactFiberHooks()
local ReactFiberHooks = __require(script.Parent["ReactFiberHooks.new"])
lazyRefs.renderWithHooksRef = ReactFiberHooks.renderWithHooks
lazyRefs.bailoutHooksRef = ReactFiberHooks.bailoutHooks
end
local function renderWithHooks(...)
if not lazyRefs.renderWithHooksRef then
initReactFiberHooks()
end
return lazyRefs.renderWithHooksRef(...)
end
local function bailoutHooks(...)
if not lazyRefs.bailoutHooksRef then
initReactFiberHooks()
end
return lazyRefs.bailoutHooksRef(...)
end
local stopProfilerTimerIfRunning =
__require(script.Parent["ReactProfilerTimer.new"]).stopProfilerTimerIfRunning
local ReactFiberContext = __require(script.Parent["ReactFiberContext.new"])
local getMaskedContext = ReactFiberContext.getMaskedContext
local getUnmaskedContext = ReactFiberContext.getUnmaskedContext
local hasLegacyContextChanged = ReactFiberContext.hasContextChanged
local pushLegacyContextProvider = ReactFiberContext.pushContextProvider
local isLegacyContextProvider = ReactFiberContext.isContextProvider
local pushTopLevelContextObject = ReactFiberContext.pushTopLevelContextObject
local invalidateContextProvider = ReactFiberContext.invalidateContextProvider
local ReactFiberHydrationContext =
__require(script.Parent["ReactFiberHydrationContext.new"])
local resetHydrationState = ReactFiberHydrationContext.resetHydrationState
local enterHydrationState = ReactFiberHydrationContext.enterHydrationState
local reenterHydrationStateFromDehydratedSuspenseInstance =
ReactFiberHydrationContext.reenterHydrationStateFromDehydratedSuspenseInstance
local tryToClaimNextHydratableInstance =
ReactFiberHydrationContext.tryToClaimNextHydratableInstance
local warnIfHydrating = ReactFiberHydrationContext.warnIfHydrating
local ReactFiberClassComponent =
__require(script.Parent["ReactFiberClassComponent.new"]) :: any
local adoptClassInstance = ReactFiberClassComponent.adoptClassInstance
local applyDerivedStateFromProps = ReactFiberClassComponent.applyDerivedStateFromProps
local constructClassInstance = ReactFiberClassComponent.constructClassInstance
local mountClassInstance = ReactFiberClassComponent.mountClassInstance
local resumeMountClassInstance = ReactFiberClassComponent.resumeMountClassInstance
local updateClassInstance = ReactFiberClassComponent.updateClassInstance
local resolveDefaultProps =
__require(script.Parent["ReactFiberLazyComponent.new"]).resolveDefaultProps
local ReactFiber = __require(script.Parent["ReactFiber.new"])
local resolveLazyComponentTag = ReactFiber.resolveLazyComponentTag
local createFiberFromFragment = ReactFiber.createFiberFromFragment
local createFiberFromOffscreen = ReactFiber.createFiberFromOffscreen
local createFiberFromTypeAndProps = ReactFiber.createFiberFromTypeAndProps
local isSimpleFunctionComponent = ReactFiber.isSimpleFunctionComponent
local createWorkInProgress = ReactFiber.createWorkInProgress
local ReactFiberWorkLoop = __require(script.Parent["ReactFiberWorkLoop.new"]) :: any
local pushRenderLanes = ReactFiberWorkLoop.pushRenderLanes
local markSpawnedWork = ReactFiberWorkLoop.markSpawnedWork
local retryDehydratedSuspenseBoundary = ReactFiberWorkLoop.retryDehydratedSuspenseBoundary
local scheduleUpdateOnFiber = ReactFiberWorkLoop.scheduleUpdateOnFiber
local renderDidSuspendDelayIfPossible = ReactFiberWorkLoop.renderDidSuspendDelayIfPossible
local getWorkInProgressRoot = ReactFiberWorkLoop.getWorkInProgressRoot
local getExecutionContext = ReactFiberWorkLoop.getExecutionContext
local RetryAfterError = ReactFiberWorkLoop.RetryAfterError
local NoContext = ReactFiberWorkLoop.NoContext
local Schedule_tracing_wrap
local setWorkInProgressVersion =
__require(script.Parent["ReactMutableSource.new"]).setWorkInProgressVersion
local markSkippedUpdateLanes =
__require(script.Parent.ReactFiberWorkInProgress).markSkippedUpdateLanes
local ConsolePatchingDev = __require(Packages.Shared).ConsolePatchingDev
local disableLogs = ConsolePatchingDev.disableLogs
local reenableLogs = ConsolePatchingDev.reenableLogs
local ReactCurrentOwner = ReactSharedInternals.ReactCurrentOwner
local exports: { [string]: any } = {}
local bailoutOnAlreadyFinishedWork, updateFunctionComponent
local didReceiveUpdate: boolean = false
local DidWarn = {
didWarnAboutBadClass = {} :: { [string]: boolean },
didWarnAboutModulePatternComponent = {} :: { [string]: boolean },
didWarnAboutContextTypeOnFunctionComponent = {} :: { [string]: boolean },
didWarnAboutGetDerivedStateOnFunctionComponent = {} :: { [string]: boolean },
didWarnAboutFunctionRefs = {} :: { [string]: boolean },
didWarnAboutDefaultPropsOnFunctionComponent = {} :: { [string]: boolean },
}
local updateSimpleMemoComponent
if __DEV__ then
DidWarn.didWarnAboutBadClass = {}
DidWarn.didWarnAboutModulePatternComponent = {}
DidWarn.didWarnAboutContextTypeOnFunctionComponent = {}
DidWarn.didWarnAboutGetDerivedStateOnFunctionComponent = {}
DidWarn.didWarnAboutFunctionRefs = {}
exports.didWarnAboutReassigningProps = false
DidWarn.didWarnAboutDefaultPropsOnFunctionComponent = {}
end
local function reconcileChildren(
current: Fiber | nil,
workInProgress: Fiber,
nextChildren: any,
renderLanes: Lanes
)
if current == nil then
workInProgress.child =
mountChildFibers(workInProgress, nil, nextChildren, renderLanes)
else
workInProgress.child = reconcileChildFibers(
workInProgress,
(current :: Fiber).child,
nextChildren,
renderLanes
)
end
end
local function forceUnmountCurrentAndReconcile(
current: Fiber,
workInProgress: Fiber,
nextChildren: any,
renderLanes: Lanes
)
workInProgress.child =
reconcileChildFibers(workInProgress, current.child, nil, renderLanes)
workInProgress.child =
reconcileChildFibers(workInProgress, nil, nextChildren, renderLanes)
end
local function updateForwardRef(
current: Fiber | nil,
workInProgress: Fiber,
Component: any,
nextProps: any,
renderLanes: Lanes
)
if __DEV__ or __DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ then
if workInProgress.type ~= workInProgress.elementType then
local innerPropTypes = Component.propTypes
local validateProps = Component.validateProps
if innerPropTypes or validateProps then
checkPropTypes(
innerPropTypes,
validateProps,
nextProps,
"prop",
getComponentName(Component)
)
end
end
end
local render = Component.render
local ref = workInProgress.ref
local nextChildren
prepareToReadContext(
workInProgress,
renderLanes,
exports.markWorkInProgressReceivedUpdate
)
if __DEV__ then
ReactCurrentOwner.current = workInProgress
setIsRendering(true)
nextChildren =
renderWithHooks(current, workInProgress, render, nextProps, ref, renderLanes)
if
debugRenderPhaseSideEffectsForStrictMode
and bit32.band(workInProgress.mode, StrictMode) ~= 0
then
disableLogs()
local ok, result = xpcall(
renderWithHooks,
describeError,
current,
workInProgress,
render,
nextProps,
ref,
renderLanes
)
if ok then
nextChildren = result
end
reenableLogs()
if not ok then
error(result)
end
end
setIsRendering(false)
else
nextChildren =
renderWithHooks(current, workInProgress, render, nextProps, ref, renderLanes)
end
if current ~= nil and not didReceiveUpdate then
bailoutHooks(current, workInProgress, renderLanes)
return bailoutOnAlreadyFinishedWork(current, workInProgress, renderLanes)
end
workInProgress.flags = bit32.bor(workInProgress.flags, PerformedWork)
reconcileChildren(current, workInProgress, nextChildren, renderLanes)
return workInProgress.child
end
local function updateMemoComponent(
current: Fiber | nil,
workInProgress: Fiber,
Component: any,
nextProps: any,
updateLanes: Lanes,
renderLanes: Lanes
): nil | Fiber
if current == nil then
local type_ = Component.type
if
isSimpleFunctionComponent(type_)
and Component.compare == nil
and Component.defaultProps == nil
then
local resolvedType = type_
if __DEV__ then
resolvedType = resolveFunctionForHotReloading(type_)
end
workInProgress.tag = SimpleMemoComponent
workInProgress.type = resolvedType
if __DEV__ then
validateFunctionComponentInDev(workInProgress, type_)
end
return updateSimpleMemoComponent(
current,
workInProgress,
resolvedType,
nextProps,
updateLanes,
renderLanes
)
end
if __DEV__ or __DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ then
local innerPropTypes
local validateProps
if type(type_) == "table" then
innerPropTypes = type_.propTypes
validateProps = type_.validateProps
end
if innerPropTypes or validateProps then
checkPropTypes(
innerPropTypes,
validateProps,
nextProps,
"prop",
getComponentName(type_)
)
end
end
local child = createFiberFromTypeAndProps(
Component.type,
nil,
nextProps,
workInProgress,
workInProgress.mode,
renderLanes
)
child.ref = workInProgress.ref
child.return_ = workInProgress
workInProgress.child = child
return child
end
local current = current :: Fiber
if __DEV__ or __DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ then
local type_ = Component.type
local innerPropTypes
local validateProps
if type(type_) == "table" then
innerPropTypes = type_.propTypes
validateProps = type_.validateProps
end
if innerPropTypes or validateProps then
checkPropTypes(
innerPropTypes,
validateProps,
nextProps,
"prop",
getComponentName(type_)
)
end
end
local currentChild = (current.child :: any) :: Fiber
if not ReactFiberLane.includesSomeLane(updateLanes, renderLanes) then
local prevProps = currentChild.memoizedProps
local compare = Component.compare
if compare == nil then
compare = shallowEqual
end
if compare(prevProps, nextProps) and current.ref == workInProgress.ref then
return bailoutOnAlreadyFinishedWork(current, workInProgress, renderLanes)
end
end
workInProgress.flags = bit32.bor(workInProgress.flags, PerformedWork)
local newChild = createWorkInProgress(currentChild, nextProps)
newChild.ref = workInProgress.ref
newChild.return_ = workInProgress
workInProgress.child = newChild
return newChild
end
function updateSimpleMemoComponent(
current: Fiber | nil,
workInProgress: Fiber,
Component: any,
nextProps: any,
updateLanes: Lanes,
renderLanes: Lanes
): nil | Fiber
if __DEV__ or __DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ then
if workInProgress.type ~= workInProgress.elementType then
local outerMemoType = workInProgress.elementType
if outerMemoType["$$typeof"] == REACT_LAZY_TYPE then
local lazyComponent: LazyComponentType<any, any> = outerMemoType
local payload = lazyComponent._payload
local init = lazyComponent._init
local ok, result = xpcall(init, describeError, payload)
if ok then
outerMemoType = result
else
outerMemoType = nil
end
local outerPropTypes
local validateProps
if outerMemoType ~= nil and type(outerMemoType) == "table" then
outerPropTypes = (outerMemoType :: any).propTypes
validateProps = (outerMemoType :: any).validateProps
end
if outerPropTypes or validateProps then
checkPropTypes(
outerPropTypes,
validateProps,
nextProps,
"prop",
getComponentName(outerMemoType)
)
end
end
end
end
if current ~= nil then
local current = current :: Fiber
local prevProps = current.memoizedProps
local preventBailout = true
if __DEV__ then
preventBailout = workInProgress.type == current.type
end
if
shallowEqual(prevProps, nextProps)
and current.ref == workInProgress.ref
and preventBailout
then
didReceiveUpdate = false
if not ReactFiberLane.includesSomeLane(renderLanes, updateLanes) then
workInProgress.lanes = current.lanes
return bailoutOnAlreadyFinishedWork(current, workInProgress, renderLanes)
elseif bit32.band(current.flags, ForceUpdateForLegacySuspense) ~= NoFlags then
didReceiveUpdate = true
end
end
end
return updateFunctionComponent(
current,
workInProgress,
Component,
nextProps,
renderLanes
)
end
local function updateOffscreenComponent(
current: Fiber?,
workInProgress: Fiber,
renderLanes: Lanes
): Fiber | nil
local nextProps: OffscreenProps = workInProgress.pendingProps
local nextChildren = nextProps.children
local prevState: OffscreenState?
if current ~= nil then
prevState = (current :: Fiber).memoizedState
end
if
nextProps.mode == "hidden"
or nextProps.mode == "unstable-defer-without-hiding"
then
if bit32.band(workInProgress.mode, ConcurrentMode) == NoMode then
local nextState: OffscreenState = {
baseLanes = ReactFiberLane.NoLanes,
}
workInProgress.memoizedState = nextState
pushRenderLanes(workInProgress, renderLanes)
elseif
not ReactFiberLane.includesSomeLane(renderLanes, ReactFiberLane.OffscreenLane)
then
local nextBaseLanes
if prevState ~= nil then
local prevBaseLanes = (prevState :: OffscreenState).baseLanes
nextBaseLanes = ReactFiberLane.mergeLanes(prevBaseLanes, renderLanes)
else
nextBaseLanes = renderLanes
end
if enableSchedulerTracing then
markSpawnedWork(ReactFiberLane.OffscreenLane)
end
workInProgress.childLanes =
ReactFiberLane.laneToLanes(ReactFiberLane.OffscreenLane)
workInProgress.lanes = workInProgress.childLanes
local nextState: OffscreenState = {
baseLanes = nextBaseLanes,
}
workInProgress.memoizedState = nextState
pushRenderLanes(workInProgress, nextBaseLanes)
return nil
else
local nextState: OffscreenState = {
baseLanes = ReactFiberLane.NoLanes,
}
workInProgress.memoizedState = nextState
local subtreeRenderLanes = renderLanes
if prevState ~= nil then
subtreeRenderLanes = (prevState :: OffscreenState).baseLanes
end
pushRenderLanes(workInProgress, subtreeRenderLanes)
end
else
local subtreeRenderLanes
if prevState ~= nil then
subtreeRenderLanes = ReactFiberLane.mergeLanes(
(prevState :: OffscreenState).baseLanes,
renderLanes
)
workInProgress.memoizedState = nil
else
subtreeRenderLanes = renderLanes
end
pushRenderLanes(workInProgress, subtreeRenderLanes)
end
reconcileChildren(current, workInProgress, nextChildren, renderLanes)
return workInProgress.child
end
local updateLegacyHiddenComponent = updateOffscreenComponent
function updateFragment(current: Fiber | nil, workInProgress: Fiber, renderLanes: Lanes)
local nextChildren = workInProgress.pendingProps
reconcileChildren(current, workInProgress, nextChildren, renderLanes)
return workInProgress.child
end
function updateMode(current: Fiber | nil, workInProgress: Fiber, renderLanes: Lanes)
local nextChildren = workInProgress.pendingProps.children
reconcileChildren(current, workInProgress, nextChildren, renderLanes)
return workInProgress.child
end
function updateProfiler(current: Fiber | nil, workInProgress: Fiber, renderLanes: Lanes)
if enableProfilerTimer then
local stateNode = workInProgress.stateNode
stateNode.effectDuration = 0
stateNode.passiveEffectDuration = 0
end
local nextProps = workInProgress.pendingProps
local nextChildren = nextProps.children
reconcileChildren(current, workInProgress, nextChildren, renderLanes)
return workInProgress.child
end
local function markRef(current: Fiber | nil, workInProgress: Fiber)
local ref = workInProgress.ref
if
(current == nil and ref ~= nil)
or (current ~= nil and (current :: Fiber).ref ~= ref)
then
workInProgress.flags = bit32.bor(workInProgress.flags, Ref)
end
end
function updateFunctionComponent(
current,
workInProgress,
Component,
nextProps: any,
renderLanes
)
if __DEV__ or __DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ then
if
type(Component) ~= "function"
and (workInProgress.type ~= workInProgress.elementType)
then
local innerPropTypes
local validateProps
if type(Component) == "table" then
innerPropTypes = (Component :: any).propTypes
validateProps = (Component :: any).validateProps
end
if innerPropTypes or validateProps then
checkPropTypes(
innerPropTypes,
validateProps,
nextProps,
"prop",
getComponentName(Component)
)
end
end
end
local context
if not disableLegacyContext then
local unmaskedContext = getUnmaskedContext(workInProgress, Component, true)
context = getMaskedContext(workInProgress, unmaskedContext)
end
local nextChildren
prepareToReadContext(
workInProgress,
renderLanes,
exports.markWorkInProgressReceivedUpdate
)
if __DEV__ then
ReactCurrentOwner.current = workInProgress
setIsRendering(true)
nextChildren = renderWithHooks(
current,
workInProgress,
Component,
nextProps,
context,
renderLanes
)
if
debugRenderPhaseSideEffectsForStrictMode
and bit32.band(workInProgress.mode, StrictMode) ~= 0
then
disableLogs()
local ok, result = xpcall(
renderWithHooks,
describeError,
current,
workInProgress,
Component,
nextProps,
context,
renderLanes
)
reenableLogs()
if ok then
nextChildren = result
else
error(result)
end
end
setIsRendering(false)
else
nextChildren = renderWithHooks(
current,
workInProgress,
Component,
nextProps,
context,
renderLanes
)
end
if current ~= nil and not didReceiveUpdate then
bailoutHooks(current, workInProgress, renderLanes)
return bailoutOnAlreadyFinishedWork(current, workInProgress, renderLanes)
end
workInProgress.flags = bit32.bor(workInProgress.flags, PerformedWork)
reconcileChildren(current, workInProgress, nextChildren, renderLanes)
return workInProgress.child
end
local function updateClassComponent(
current: any,
workInProgress: Fiber,
Component: any,
nextProps: any,
renderLanes: Lanes
)
if __DEV__ or __DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ then
if workInProgress.type ~= workInProgress.elementType then
local innerPropTypes = Component.propTypes
local validateProps = Component.validateProps
if innerPropTypes or validateProps then
checkPropTypes(
innerPropTypes,
validateProps,
nextProps,
"prop",
getComponentName(Component)
)
end
end
end
local hasContext
if isLegacyContextProvider(Component) then
hasContext = true
pushLegacyContextProvider(workInProgress)
else
hasContext = false
end
prepareToReadContext(
workInProgress,
renderLanes,
exports.markWorkInProgressReceivedUpdate
)
local instance = workInProgress.stateNode
local shouldUpdate
if instance == nil then
if current ~= nil then
current.alternate = nil
workInProgress.alternate = nil
workInProgress.flags = bit32.bor(workInProgress.flags, Placement)
end
constructClassInstance(workInProgress, Component, nextProps)
mountClassInstance(workInProgress, Component, nextProps, renderLanes)
shouldUpdate = true
elseif current == nil then
shouldUpdate =
resumeMountClassInstance(workInProgress, Component, nextProps, renderLanes)
else
shouldUpdate = updateClassInstance(
current,
workInProgress,
Component,
nextProps,
renderLanes
)
end
local nextUnitOfWork = finishClassComponent(
current,
workInProgress,
Component,
shouldUpdate,
hasContext,
renderLanes
)
if __DEV__ then
local inst = workInProgress.stateNode
if shouldUpdate and inst.props ~= nextProps then
if not exports.didWarnAboutReassigningProps then
console.error(
"It looks like %s is reassigning its own `this.props` while rendering. "
.. "This is not supported and can lead to confusing bugs.",
getComponentName(workInProgress.type) or "a component"
)
end
exports.didWarnAboutReassigningProps = true
end
end
return nextUnitOfWork
end
function finishClassComponent(
current: Fiber | nil,
workInProgress: Fiber,
Component: any,
shouldUpdate: boolean,
hasContext: boolean,
renderLanes: Lanes
)
markRef(current, workInProgress)
local didCaptureError = bit32.band(workInProgress.flags, DidCapture) ~= NoFlags
if not shouldUpdate and not didCaptureError then
if hasContext then
invalidateContextProvider(workInProgress, Component, false)
end
return bailoutOnAlreadyFinishedWork(current, workInProgress, renderLanes)
end
local instance = workInProgress.stateNode
ReactCurrentOwner.current = workInProgress
local nextChildren
if
didCaptureError
and (
Component.getDerivedStateFromError == nil
or type(Component.getDerivedStateFromError) ~= "function"
)
then
nextChildren = nil
if enableProfilerTimer then
stopProfilerTimerIfRunning(workInProgress)
end
else
if __DEV__ then
setIsRendering(true)
nextChildren = instance:render()
if
debugRenderPhaseSideEffectsForStrictMode
and bit32.band(workInProgress.mode, StrictMode) ~= 0
then
disableLogs()
local ok, result = xpcall(instance.render, describeError, instance)
reenableLogs()
if not ok then
error(result)
end
end
setIsRendering(false)
else
nextChildren = instance:render()
end
end
workInProgress.flags = bit32.bor(workInProgress.flags, PerformedWork)
if current ~= nil and didCaptureError then
forceUnmountCurrentAndReconcile(
current :: Fiber,
workInProgress,
nextChildren,
renderLanes
)
else
reconcileChildren(current, workInProgress, nextChildren, renderLanes)
end
workInProgress.memoizedState = instance.state
if hasContext then
invalidateContextProvider(workInProgress, Component, true)
end
return workInProgress.child
end
local function pushHostRootContext(workInProgress)
local root = workInProgress.stateNode
if root.pendingContext then
pushTopLevelContextObject(
workInProgress,
root.pendingContext,
root.pendingContext ~= root.context
)
elseif root.context then
pushTopLevelContextObject(workInProgress, root.context, false)
end
pushHostContainer(workInProgress, root.containerInfo)
end
local function updateHostRoot(current, workInProgress, renderLanes)
pushHostRootContext(workInProgress)
local updateQueue = workInProgress.updateQueue
invariant(
current ~= nil and updateQueue ~= nil,
"If the root does not have an updateQueue, we should have already "
.. "bailed out. This error is likely caused by a bug in React. Please "
.. "file an issue."
)
local nextProps = workInProgress.pendingProps
local prevState = workInProgress.memoizedState
local prevChildren
if prevState ~= nil then
prevChildren = prevState.element
end
cloneUpdateQueue(current, workInProgress)
processUpdateQueue(workInProgress, nextProps, nil, renderLanes)
local nextState = workInProgress.memoizedState
local nextChildren = nextState.element
if nextChildren == prevChildren then
resetHydrationState()
return bailoutOnAlreadyFinishedWork(current, workInProgress, renderLanes)
end
local root: FiberRoot = workInProgress.stateNode
if root.hydrate and enterHydrationState(workInProgress) then
if supportsHydration then
local mutableSourceEagerHydrationData = root.mutableSourceEagerHydrationData
if mutableSourceEagerHydrationData ~= nil then
for i = 1, #mutableSourceEagerHydrationData, 2 do
local mutableSource = mutableSourceEagerHydrationData[i]
local version = mutableSourceEagerHydrationData[i + 1]
setWorkInProgressVersion(mutableSource, version)
end
end
end
local child = mountChildFibers(workInProgress, nil, nextChildren, renderLanes)
workInProgress.child = child
local node = child
while node do
node.flags =
bit32.bor(bit32.band(node.flags, bit32.bnot(Placement)), Hydrating)
node = node.sibling
end
else
reconcileChildren(current, workInProgress, nextChildren, renderLanes)
resetHydrationState()
end
return workInProgress.child
end
local function updateHostComponent(
current: any,
workInProgress: Fiber,
renderLanes: Lanes
)
pushHostContext(workInProgress)
if current == nil then
tryToClaimNextHydratableInstance(workInProgress)
end
local type_ = workInProgress.type
local nextProps = workInProgress.pendingProps
local prevProps
if current ~= nil then
prevProps = current.memoizedProps
end
local nextChildren = nextProps.children
local isDirectTextChild = shouldSetTextContent(type_, nextProps)
if isDirectTextChild then
nextChildren = nil
elseif prevProps ~= nil and shouldSetTextContent(type_, prevProps) then
workInProgress.flags = bit32.bor(workInProgress.flags, ContentReset)
end
workInProgress.flags = bit32.bor(workInProgress.flags, PerformedWork)
markRef(current, workInProgress)
reconcileChildren(current, workInProgress, nextChildren, renderLanes)
return workInProgress.child
end
local function updateHostText(current, workInProgress)
if current == nil then
tryToClaimNextHydratableInstance(workInProgress)
end
return nil
end
local function mountLazyComponent(
_current,
workInProgress,
elementType,
updateLanes,
renderLanes
)
if _current ~= nil then
_current.alternate = nil
workInProgress.alternate = nil
workInProgress.flags = bit32.bor(workInProgress.flags, Placement)
end
local props = workInProgress.pendingProps
local lazyComponent: LazyComponentType<any, any> = elementType
local payload = lazyComponent._payload
local init = lazyComponent._init
local Component = init(payload)
workInProgress.type = Component
workInProgress.tag = resolveLazyComponentTag(Component)
local resolvedTag = workInProgress.tag
local resolvedProps = resolveDefaultProps(Component, props)
local child
if resolvedTag == FunctionComponent then
if __DEV__ then
validateFunctionComponentInDev(workInProgress, Component)
Component = resolveFunctionForHotReloading(Component)
workInProgress.type = Component
end
child = updateFunctionComponent(
nil,
workInProgress,
Component,
resolvedProps,
renderLanes
)
return child
elseif resolvedTag == ClassComponent then
if __DEV__ then
Component = resolveClassForHotReloading(Component)
workInProgress.type = Component
end
child = updateClassComponent(
nil,
workInProgress,
Component,
resolvedProps,
renderLanes
)
return child
elseif resolvedTag == ForwardRef then
if __DEV__ then
Component = resolveForwardRefForHotReloading(Component)
workInProgress.type = Component
end
child =
updateForwardRef(nil, workInProgress, Component, resolvedProps, renderLanes)
return child
elseif resolvedTag == MemoComponent then
if __DEV__ or __DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ then
if workInProgress.type ~= workInProgress.elementType then
local outerPropTypes = Component.propTypes
local validateProps = Component.validateProps
if outerPropTypes or validateProps then
checkPropTypes(
outerPropTypes,
validateProps,
resolvedProps,
"prop",
getComponentName(Component)
)
end
end
end
child = updateMemoComponent(
nil,
workInProgress,
Component,
resolveDefaultProps(Component.type, resolvedProps),
updateLanes,
renderLanes
)
return child
end
local hint = ""
if __DEV__ then
if
Component ~= nil
and type(Component) == "table"
and Component["$$typeof"] == REACT_LAZY_TYPE
then
hint = " Did you wrap a component in React.lazy() more than once?"
elseif type(Component) == "table" and Component["$$typeof"] == nil then
hint = "\n" .. inspect(Component)
end
end
invariant(
false,
"Element type is invalid. Received a promise that resolves to: %s. "
.. "Lazy element type must resolve to a class or function.%s",
tostring(Component),
hint
)
return nil
end
function mountIncompleteClassComponent(
_current,
workInProgress,
Component,
nextProps,
renderLanes
)
if _current ~= nil then
_current.alternate = nil
workInProgress.alternate = nil
workInProgress.flags = bit32.bor(workInProgress.flags, Placement)
end
workInProgress.tag = ClassComponent
local hasContext
if isLegacyContextProvider(Component) then
hasContext = true
pushLegacyContextProvider(workInProgress)
else
hasContext = false
end
prepareToReadContext(
workInProgress,
renderLanes,
exports.markWorkInProgressReceivedUpdate
)
constructClassInstance(workInProgress, Component, nextProps)
mountClassInstance(workInProgress, Component, nextProps, renderLanes)
return finishClassComponent(
nil,
workInProgress,
Component,
true,
hasContext,
renderLanes
)
end
local function mountIndeterminateComponent(
current,
workInProgress,
Component,
renderLanes
)
if current ~= nil then
current.alternate = nil
workInProgress.alternate = nil
workInProgress.flags = bit32.bor(workInProgress.flags, Placement)
end
local props = workInProgress.pendingProps
local context
if not disableLegacyContext then
local unmaskedContext = getUnmaskedContext(workInProgress, Component, false)
context = getMaskedContext(workInProgress, unmaskedContext)
end
prepareToReadContext(
workInProgress,
renderLanes,
exports.markWorkInProgressReceivedUpdate
)
local value
if __DEV__ then
if
type(Component) == "table" and type(Component.render) == "function"
then
local componentName = getComponentName(Component) or "Unknown"
if not DidWarn.didWarnAboutBadClass[componentName] then
console.error(
"The <%s /> component appears to have a render method, but doesn't extend React.Component. "
.. "This is likely to cause errors. Change %s to extend React.Component instead.",
componentName,
componentName
)
DidWarn.didWarnAboutBadClass[componentName] = true
end
end
if bit32.band(workInProgress.mode, StrictMode) ~= 0 then
ReactStrictModeWarnings.recordLegacyContextWarning(workInProgress)
end
setIsRendering(true)
ReactCurrentOwner.current = workInProgress
value =
renderWithHooks(nil, workInProgress, Component, props, context, renderLanes)
setIsRendering(false)
else
value =
renderWithHooks(nil, workInProgress, Component, props, context, renderLanes)
end
workInProgress.flags = bit32.bor(workInProgress.flags, PerformedWork)
local typeofValue = type(value)
if __DEV__ then
if
value ~= nil
and typeofValue == "table"
and type(value.render) == "function"
and value["$$typeof"] == nil
then
local componentName = getComponentName(Component) or "Unknown"
if not DidWarn.didWarnAboutModulePatternComponent[componentName] then
console.error(
"The <%s /> component appears to be a function component that returns a class instance. "
.. "Change %s to a class that extends React.Component instead. ",
componentName,
componentName
)
DidWarn.didWarnAboutModulePatternComponent[componentName] = true
end
end
end
if
not disableModulePatternComponents
and value ~= nil
and typeofValue == "table"
and type(value.render) == "function"
and value["$$typeof"] == nil
then
if __DEV__ then
local componentName = getComponentName(Component) or "Unknown"
if not DidWarn.didWarnAboutModulePatternComponent[componentName] then
console.error(
"The <%s /> component appears to be a function component that returns a class instance. "
.. "Change %s to a class that extends React.Component instead. "
.. componentName,
componentName
)
DidWarn.didWarnAboutModulePatternComponent[componentName] = true
end
end
workInProgress.tag = ClassComponent
workInProgress.memoizedState = nil
workInProgress.updateQueue = nil
local hasContext = false
if isLegacyContextProvider(Component) then
hasContext = true
pushLegacyContextProvider(workInProgress)
else
hasContext = false
end
workInProgress.memoizedState = value.state
initializeUpdateQueue(workInProgress)
local getDerivedStateFromProps
if type(Component) ~= "function" then
getDerivedStateFromProps = (Component :: React_Component<any, any>).getDerivedStateFromProps
end
if
getDerivedStateFromProps ~= nil
and type(getDerivedStateFromProps) == "function"
then
applyDerivedStateFromProps(
workInProgress,
Component,
getDerivedStateFromProps,
props
)
end
adoptClassInstance(workInProgress, value)
mountClassInstance(workInProgress, Component, props, renderLanes)
return finishClassComponent(
nil,
workInProgress,
Component,
true,
hasContext,
renderLanes
)
else
workInProgress.tag = FunctionComponent
if __DEV__ then
if disableLegacyContext and Component.contextTypes then
console.error(
"%s uses the legacy contextTypes API which is no longer supported. "
.. "Use React.createContext() with React.useContext() instead.",
getComponentName(Component) or "Unknown"
)
end
if
debugRenderPhaseSideEffectsForStrictMode
and bit32.band(workInProgress.mode, StrictMode) ~= 0
then
disableLogs()
local ok, result = xpcall(
renderWithHooks,
describeError,
nil,
workInProgress,
Component,
props,
context,
renderLanes
)
reenableLogs()
if ok then
value = result
else
error(result)
end
end
end
reconcileChildren(nil, workInProgress, value, renderLanes)
if __DEV__ then
validateFunctionComponentInDev(workInProgress, Component)
end
return workInProgress.child
end
end
function validateFunctionComponentInDev(workInProgress: Fiber, Component: any)
if __DEV__ then
if workInProgress.ref ~= nil then
local info = ""
local ownerName = getCurrentFiberOwnerNameInDevOrNull()
if ownerName then
info ..= "\n\nCheck the render method of `" .. ownerName .. "`."
end
local warningKey = ownerName or workInProgress._debugID or ""
local debugSource = workInProgress._debugSource
if debugSource then
warningKey = debugSource.fileName .. ":" .. debugSource.lineNumber
end
if not DidWarn.didWarnAboutFunctionRefs[warningKey] then
DidWarn.didWarnAboutFunctionRefs[warningKey] = true
console.error(
"Function components cannot be given refs. "
.. "Attempts to access this ref will fail. "
.. "Did you mean to use React.forwardRef()?%s",
info
)
end
end
if
warnAboutDefaultPropsOnFunctionComponents
and type(Component) ~= "function"
and Component.defaultProps ~= nil
then
local componentName = getComponentName(Component) or "Unknown"
if not DidWarn.didWarnAboutDefaultPropsOnFunctionComponent[componentName] then
console.error(
"%s: Support for defaultProps will be removed from function components "
.. "in a future major release.",
componentName
)
DidWarn.didWarnAboutDefaultPropsOnFunctionComponent[componentName] = true
end
end
if
type(Component) ~= "function"
and Component.getDerivedStateFromProps ~= nil
and type(Component.getDerivedStateFromProps) == "function"
then
local componentName = getComponentName(Component) or "Unknown"
if
not DidWarn.didWarnAboutGetDerivedStateOnFunctionComponent[componentName]
then
console.error(
"%s: Function components do not support getDerivedStateFromProps.",
componentName
)
DidWarn.didWarnAboutGetDerivedStateOnFunctionComponent[componentName] =
true
end
end
if
type(Component) ~= "function"
and Component.contextType ~= nil
and type(Component.contextType) == "table"
then
local componentName = getComponentName(Component) or "Unknown"
if not DidWarn.didWarnAboutContextTypeOnFunctionComponent[componentName] then
console.error(
"%s: Function components do not support contextType.",
componentName
)
DidWarn.didWarnAboutContextTypeOnFunctionComponent[componentName] = true
end
end
end
end
local SUSPENDED_MARKER: SuspenseState = {
dehydrated = nil,
retryLane = ReactFiberLane.NoLane,
}
local function mountSuspenseOffscreenState(renderLanes: Lanes): OffscreenState
return {
baseLanes = renderLanes,
}
end
local function updateSuspenseOffscreenState(
prevOffscreenState: OffscreenState,
renderLanes: Lanes
): OffscreenState
return {
baseLanes = ReactFiberLane.mergeLanes(prevOffscreenState.baseLanes, renderLanes),
}
end
local function shouldRemainOnFallback(
suspenseContext: SuspenseContext,
current: nil | Fiber,
workInProgress: Fiber,
renderLanes: Lanes
)
if current ~= nil then
local suspenseState: SuspenseState = (current :: Fiber).memoizedState
if suspenseState == nil then
return false
end
end
return hasSuspenseContext(suspenseContext, ForceSuspenseFallback)
end
local function getRemainingWorkInPrimaryTree(current: Fiber, renderLanes)
return ReactFiberLane.removeLanes(current.childLanes, renderLanes)
end
local updateSuspensePrimaryChildren
local mountDehydratedSuspenseComponent
local mountSuspensePrimaryChildren
local updateSuspenseFallbackChildren
local updateDehydratedSuspenseComponent
local function updateSuspenseComponent(current, workInProgress, renderLanes)
local nextProps = workInProgress.pendingProps
if __DEV__ then
if shouldSuspend(workInProgress) then
workInProgress.flags = bit32.bor(workInProgress.flags, DidCapture)
end
end
local suspenseContext: SuspenseContext = suspenseStackCursor.current
local showFallback = false
local didSuspend = bit32.band(workInProgress.flags, DidCapture) ~= NoFlags
if
didSuspend
or shouldRemainOnFallback(suspenseContext, current, workInProgress, renderLanes)
then
showFallback = true
workInProgress.flags = bit32.band(workInProgress.flags, bit32.bnot(DidCapture))
else
if current == nil or current.memoizedState ~= nil then
if
nextProps.fallback ~= nil
and nextProps.unstable_avoidThisFallback ~= true
then
suspenseContext = addSubtreeSuspenseContext(
suspenseContext,
InvisibleParentSuspenseContext
)
end
end
end
suspenseContext = setDefaultShallowSuspenseContext(suspenseContext)
pushSuspenseContext(workInProgress, suspenseContext)
if current == nil then
if nextProps.fallback ~= nil then
tryToClaimNextHydratableInstance(workInProgress)
if enableSuspenseServerRenderer then
local suspenseState: nil | SuspenseState = workInProgress.memoizedState
if suspenseState ~= nil then
local dehydrated = (suspenseState :: SuspenseState).dehydrated
if dehydrated ~= nil then
return mountDehydratedSuspenseComponent(
workInProgress,
dehydrated,
renderLanes
)
end
end
end
end
local nextPrimaryChildren = nextProps.children
local nextFallbackChildren = nextProps.fallback
if showFallback then
local fallbackFragment = mountSuspenseFallbackChildren(
workInProgress,
nextPrimaryChildren,
nextFallbackChildren,
renderLanes
)
local primaryChildFragment: Fiber = workInProgress.child :: any
primaryChildFragment.memoizedState = mountSuspenseOffscreenState(renderLanes)
workInProgress.memoizedState = SUSPENDED_MARKER
return fallbackFragment
elseif
nextProps.unstable_expectedLoadTime ~= nil
and type(nextProps.unstable_expectedLoadTime) == "number"
then
local fallbackFragment = mountSuspenseFallbackChildren(
workInProgress,
nextPrimaryChildren,
nextFallbackChildren,
renderLanes
)
local primaryChildFragment: Fiber = workInProgress.child :: any
primaryChildFragment.memoizedState = mountSuspenseOffscreenState(renderLanes)
workInProgress.memoizedState = SUSPENDED_MARKER
workInProgress.lanes = ReactFiberLane.SomeRetryLane
if enableSchedulerTracing then
markSpawnedWork(ReactFiberLane.SomeRetryLane)
end
return fallbackFragment
else
return mountSuspensePrimaryChildren(
workInProgress,
nextPrimaryChildren,
renderLanes
)
end
else
local prevState: nil | SuspenseState = current.memoizedState
if prevState ~= nil then
if enableSuspenseServerRenderer then
local dehydrated = (prevState :: SuspenseState).dehydrated
if dehydrated ~= nil then
if not didSuspend then
return updateDehydratedSuspenseComponent(
current,
workInProgress,
dehydrated,
prevState,
renderLanes
)
elseif workInProgress.memoizedState ~= nil then
workInProgress.child = current.child
workInProgress.flags = bit32.bor(workInProgress.flags, DidCapture)
return nil
else
local nextPrimaryChildren = nextProps.children
local nextFallbackChildren = nextProps.fallback
local fallbackChildFragment =
mountSuspenseFallbackAfterRetryWithoutHydrating(
current,
workInProgress,
nextPrimaryChildren,
nextFallbackChildren,
renderLanes
)
local primaryChildFragment: Fiber = workInProgress.child :: any
primaryChildFragment.memoizedState =
mountSuspenseOffscreenState(renderLanes)
workInProgress.memoizedState = SUSPENDED_MARKER
return fallbackChildFragment
end
end
end
if showFallback then
local nextFallbackChildren = nextProps.fallback
local nextPrimaryChildren = nextProps.children
local fallbackChildFragment = updateSuspenseFallbackChildren(
current,
workInProgress,
nextPrimaryChildren,
nextFallbackChildren,
renderLanes
)
local primaryChildFragment: Fiber = workInProgress.child :: any
local prevOffscreenState: OffscreenState | nil = (current.child :: any).memoizedState
if prevOffscreenState == nil then
primaryChildFragment.memoizedState =
mountSuspenseOffscreenState(renderLanes)
else
primaryChildFragment.memoizedState = updateSuspenseOffscreenState(
prevOffscreenState :: OffscreenState,
renderLanes
)
end
primaryChildFragment.childLanes =
getRemainingWorkInPrimaryTree(current, renderLanes)
workInProgress.memoizedState = SUSPENDED_MARKER
return fallbackChildFragment
else
local nextPrimaryChildren = nextProps.children
local primaryChildFragment = updateSuspensePrimaryChildren(
current,
workInProgress,
nextPrimaryChildren,
renderLanes
)
workInProgress.memoizedState = nil
return primaryChildFragment
end
else
if showFallback then
local nextFallbackChildren = nextProps.fallback
local nextPrimaryChildren = nextProps.children
local fallbackChildFragment = updateSuspenseFallbackChildren(
current,
workInProgress,
nextPrimaryChildren,
nextFallbackChildren,
renderLanes
)
local primaryChildFragment: Fiber = workInProgress.child :: any
local prevOffscreenState: OffscreenState | nil = (current.child :: any).memoizedState
if prevOffscreenState == nil then
primaryChildFragment.memoizedState =
mountSuspenseOffscreenState(renderLanes)
else
primaryChildFragment.memoizedState = updateSuspenseOffscreenState(
prevOffscreenState :: OffscreenState,
renderLanes
)
end
primaryChildFragment.childLanes =
getRemainingWorkInPrimaryTree(current, renderLanes)
workInProgress.memoizedState = SUSPENDED_MARKER
return fallbackChildFragment
else
local nextPrimaryChildren = nextProps.children
local primaryChildFragment = updateSuspensePrimaryChildren(
current,
workInProgress,
nextPrimaryChildren,
renderLanes
)
workInProgress.memoizedState = nil
return primaryChildFragment
end
end
end
end
function mountSuspensePrimaryChildren(workInProgress, primaryChildren, renderLanes)
local mode = workInProgress.mode
local primaryChildProps: OffscreenProps = {
mode = "visible",
children = primaryChildren,
}
local primaryChildFragment =
createFiberFromOffscreen(primaryChildProps, mode, renderLanes, nil)
primaryChildFragment.return_ = workInProgress
workInProgress.child = primaryChildFragment
return primaryChildFragment
end
function mountSuspenseFallbackChildren(
workInProgress,
primaryChildren,
fallbackChildren,
renderLanes
)
local mode = workInProgress.mode
local progressedPrimaryFragment: Fiber | nil = workInProgress.child
local primaryChildProps: OffscreenProps = {
mode = "hidden",
children = primaryChildren,
}
local primaryChildFragment
local fallbackChildFragment
if bit32.band(mode, BlockingMode) == NoMode and progressedPrimaryFragment ~= nil then
primaryChildFragment = progressedPrimaryFragment
primaryChildFragment.childLanes = ReactFiberLane.NoLanes
primaryChildFragment.pendingProps = primaryChildProps
if enableProfilerTimer and bit32.band(workInProgress.mode, ProfileMode) ~= 0 then
primaryChildFragment.actualDuration = 0
primaryChildFragment.actualStartTime = -1
primaryChildFragment.selfBaseDuration = 0
primaryChildFragment.treeBaseDuration = 0
end
fallbackChildFragment =
createFiberFromFragment(fallbackChildren, mode, renderLanes, nil)
else
primaryChildFragment =
createFiberFromOffscreen(primaryChildProps, mode, ReactFiberLane.NoLanes, nil)
fallbackChildFragment =
createFiberFromFragment(fallbackChildren, mode, renderLanes, nil)
end
primaryChildFragment.return_ = workInProgress
fallbackChildFragment.return_ = workInProgress
primaryChildFragment.sibling = fallbackChildFragment
workInProgress.child = primaryChildFragment
return fallbackChildFragment
end
local function createWorkInProgressOffscreenFiber(
current: Fiber,
offscreenProps: OffscreenProps
)
return createWorkInProgress(current, offscreenProps)
end
function updateSuspensePrimaryChildren(
current,
workInProgress,
primaryChildren,
renderLanes
)
local currentPrimaryChildFragment: Fiber = current.child :: any
local currentFallbackChildFragment: Fiber | nil = currentPrimaryChildFragment.sibling
local primaryChildFragment =
createWorkInProgressOffscreenFiber(currentPrimaryChildFragment, {
mode = "visible",
children = primaryChildren,
})
if bit32.band(workInProgress.mode, BlockingMode) == NoMode then
primaryChildFragment.lanes = renderLanes
end
primaryChildFragment.return_ = workInProgress
primaryChildFragment.sibling = nil
if currentFallbackChildFragment ~= nil then
local deletions = workInProgress.deletions
if deletions == nil then
workInProgress.deletions = { currentFallbackChildFragment }
workInProgress.flags = bit32.bor(workInProgress.flags, Deletion)
else
table.insert(deletions, currentFallbackChildFragment)
end
end
workInProgress.child = primaryChildFragment
return primaryChildFragment
end
function updateSuspenseFallbackChildren(
current,
workInProgress,
primaryChildren,
fallbackChildren,
renderLanes
)
local mode = workInProgress.mode
local currentPrimaryChildFragment: Fiber = current.child :: any
local currentFallbackChildFragment: Fiber | nil = currentPrimaryChildFragment.sibling
local primaryChildProps: OffscreenProps = {
mode = "hidden",
children = primaryChildren,
}
local primaryChildFragment
if
bit32.band(mode, BlockingMode) == NoMode
and workInProgress.child ~= currentPrimaryChildFragment
then
local progressedPrimaryFragment: Fiber = workInProgress.child
primaryChildFragment = progressedPrimaryFragment
primaryChildFragment.childLanes = ReactFiberLane.NoLanes
primaryChildFragment.pendingProps = primaryChildProps
if enableProfilerTimer and bit32.band(workInProgress.mode, ProfileMode) ~= 0 then
primaryChildFragment.actualDuration = 0
primaryChildFragment.actualStartTime = -1
primaryChildFragment.selfBaseDuration =
currentPrimaryChildFragment.selfBaseDuration
primaryChildFragment.treeBaseDuration =
currentPrimaryChildFragment.treeBaseDuration
end
workInProgress.deletions = nil
else
primaryChildFragment = createWorkInProgressOffscreenFiber(
currentPrimaryChildFragment,
primaryChildProps
)
primaryChildFragment.subtreeFlags =
bit32.band(currentPrimaryChildFragment.subtreeFlags, StaticMask)
end
local fallbackChildFragment
if currentFallbackChildFragment ~= nil then
fallbackChildFragment =
createWorkInProgress(currentFallbackChildFragment, fallbackChildren)
else
fallbackChildFragment =
createFiberFromFragment(fallbackChildren, mode, renderLanes, nil)
fallbackChildFragment.flags = bit32.bor(fallbackChildFragment.flags, Placement)
end
fallbackChildFragment.return_ = workInProgress
primaryChildFragment.return_ = workInProgress
primaryChildFragment.sibling = fallbackChildFragment
workInProgress.child = primaryChildFragment
return fallbackChildFragment
end
local function retrySuspenseComponentWithoutHydrating(
current: Fiber,
workInProgress: Fiber,
renderLanes: Lanes
)
reconcileChildFibers(workInProgress, current.child, nil, renderLanes)
local nextProps = workInProgress.pendingProps
local primaryChildren = nextProps.children
local primaryChildFragment =
mountSuspensePrimaryChildren(workInProgress, primaryChildren, renderLanes)
primaryChildFragment.flags = bit32.bor(primaryChildFragment.flags, Placement)
workInProgress.memoizedState = nil
return primaryChildFragment
end
function mountSuspenseFallbackAfterRetryWithoutHydrating(
current,
workInProgress,
primaryChildren,
fallbackChildren,
renderLanes
)
local mode = workInProgress.mode
local primaryChildFragment =
createFiberFromOffscreen(primaryChildren, mode, ReactFiberLane.NoLanes, nil)
local fallbackChildFragment =
createFiberFromFragment(fallbackChildren, mode, renderLanes, nil)
fallbackChildFragment.flags = bit32.bor(fallbackChildFragment.flags, Placement)
primaryChildFragment.return_ = workInProgress
fallbackChildFragment.return_ = workInProgress
primaryChildFragment.sibling = fallbackChildFragment
workInProgress.child = primaryChildFragment
if bit32.band(workInProgress.mode, BlockingMode) ~= NoMode then
reconcileChildFibers(workInProgress, current.child, nil, renderLanes)
end
return fallbackChildFragment
end
function mountDehydratedSuspenseComponent(
workInProgress: Fiber,
suspenseInstance: SuspenseInstance,
renderLanes: Lanes
): nil | Fiber
if bit32.band(workInProgress.mode, BlockingMode) == NoMode then
if __DEV__ then
console.error(
"Cannot hydrate Suspense in legacy mode. Switch from"
.. "ReactDOM.hydrate(element, container) to "
.. "ReactDOM.createBlockingRoot(container, { hydrate: true })"
.. ".render(element) or remove the Suspense components"
.. "the server rendered components."
)
end
workInProgress.lanes = ReactFiberLane.laneToLanes(ReactFiberLane.SyncLane)
elseif isSuspenseInstanceFallback(suspenseInstance) then
if enableSchedulerTracing then
markSpawnedWork(ReactFiberLane.DefaultHydrationLane)
end
workInProgress.lanes =
ReactFiberLane.laneToLanes(ReactFiberLane.DefaultHydrationLane)
else
workInProgress.lanes = ReactFiberLane.laneToLanes(ReactFiberLane.OffscreenLane)
if enableSchedulerTracing then
markSpawnedWork(ReactFiberLane.OffscreenLane)
end
end
return nil
end
function updateDehydratedSuspenseComponent(
current: Fiber,
workInProgress: Fiber,
suspenseInstance: SuspenseInstance,
suspenseState: SuspenseState,
renderLanes: Lanes
): nil | Fiber
warnIfHydrating()
if bit32.band(getExecutionContext(), RetryAfterError) ~= NoContext then
return retrySuspenseComponentWithoutHydrating(
current,
workInProgress,
renderLanes
)
end
if bit32.band(workInProgress.mode, BlockingMode) == NoMode then
return retrySuspenseComponentWithoutHydrating(
current,
workInProgress,
renderLanes
)
end
if isSuspenseInstanceFallback(suspenseInstance) then
return retrySuspenseComponentWithoutHydrating(
current,
workInProgress,
renderLanes
)
end
local hasContextChanged =
ReactFiberLane.includesSomeLane(renderLanes, current.childLanes)
if didReceiveUpdate or hasContextChanged then
local root = getWorkInProgressRoot()
if root ~= nil then
local attemptHydrationAtLane =
ReactFiberLane.getBumpedLaneForHydration(root, renderLanes)
if
attemptHydrationAtLane ~= ReactFiberLane.NoLane
and attemptHydrationAtLane ~= suspenseState.retryLane
then
suspenseState.retryLane = attemptHydrationAtLane
local eventTime = ReactFiberLane.NoTimestamp
scheduleUpdateOnFiber(current, attemptHydrationAtLane, eventTime)
else
end
end
renderDidSuspendDelayIfPossible()
return retrySuspenseComponentWithoutHydrating(
current,
workInProgress,
renderLanes
)
elseif isSuspenseInstancePending(suspenseInstance) then
workInProgress.flags = bit32.bor(workInProgress.flags, DidCapture)
workInProgress.child = current.child
local retry = function()
return retryDehydratedSuspenseBoundary(current)
end
if enableSchedulerTracing then
if Schedule_tracing_wrap == nil then
Schedule_tracing_wrap = __require(Packages.Scheduler).tracing.unstable_wrap
end
retry = Schedule_tracing_wrap(retry)
end
registerSuspenseInstanceRetry(suspenseInstance, retry)
return nil
else
reenterHydrationStateFromDehydratedSuspenseInstance(
workInProgress,
suspenseInstance
)
local nextProps = workInProgress.pendingProps
local primaryChildren = nextProps.children
local primaryChildFragment =
mountSuspensePrimaryChildren(workInProgress, primaryChildren, renderLanes)
primaryChildFragment.flags = bit32.bor(primaryChildFragment.flags, Hydrating)
return primaryChildFragment
end
end
function updatePortalComponent(
current: Fiber | nil,
workInProgress: Fiber,
renderLanes: Lanes
)
pushHostContainer(workInProgress, workInProgress.stateNode.containerInfo)
local nextChildren = workInProgress.pendingProps
if current == nil then
workInProgress.child =
reconcileChildFibers(workInProgress, nil, nextChildren, renderLanes)
else
reconcileChildren(current, workInProgress, nextChildren, renderLanes)
end
return workInProgress.child
end
local hasWarnedAboutUsingNoValuePropOnContextProvider = false
local function updateContextProvider(
current: Fiber | nil,
workInProgress: Fiber,
renderLanes: Lanes
)
local providerType: ReactProviderType<any> = workInProgress.type
local context: ReactContext<any> = providerType._context
local newProps = workInProgress.pendingProps
local oldProps = workInProgress.memoizedProps
local newValue = newProps.value
if __DEV__ or __DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ then
if Array.indexOf(Object.keys(newProps), "value") < 1 then
if not hasWarnedAboutUsingNoValuePropOnContextProvider then
hasWarnedAboutUsingNoValuePropOnContextProvider = true
console.error(
"The `value` prop is required for the `<Context.Provider>`. Did you misspell it or forget to pass it?"
)
end
end
local providerPropTypes = workInProgress.type.propTypes
local validateProps = workInProgress.type.validateProps
if providerPropTypes or validateProps then
checkPropTypes(
providerPropTypes,
validateProps,
newProps,
"prop",
"Context.Provider"
)
end
end
pushProvider(workInProgress, newValue)
if oldProps ~= nil then
local oldValue = oldProps.value
local changedBits = calculateChangedBits(context, newValue, oldValue)
if changedBits == 0 then
if
oldProps.children == newProps.children
and not hasLegacyContextChanged()
then
return bailoutOnAlreadyFinishedWork(current, workInProgress, renderLanes)
end
else
propagateContextChange(workInProgress, context, changedBits, renderLanes)
end
end
local newChildren = newProps.children
reconcileChildren(current, workInProgress, newChildren, renderLanes)
return workInProgress.child
end
local hasWarnedAbout = {
usingContextAsConsumer = false,
usingLegacyConsumer = false,
}
function updateContextConsumer(
current: Fiber | nil,
workInProgress: Fiber,
renderLanes: Lanes
)
local context: ReactContext<any> = workInProgress.type
if __DEV__ then
if (context :: any)._context == nil then
if context ~= context.Consumer then
if not hasWarnedAbout.usingContextAsConsumer then
hasWarnedAbout.usingContextAsConsumer = true
console.error(
"Rendering <Context> directly is not supported and will be removed in "
.. "a future major release. Did you mean to render <Context.Consumer> instead?"
)
end
end
else
context = (context :: any)._context
end
end
local newProps = workInProgress.pendingProps
local render
if newProps.render then
if __DEV__ and __COMPAT_WARNINGS__ then
if not hasWarnedAbout.usingLegacyConsumer then
hasWarnedAbout.usingLegacyConsumer = true
console.warn(
"Your Context.Consumer component is using legacy Roact syntax, which won't be supported in future versions of Roact. \n"
.. "Please provide no props and supply the 'render' function as a child (the 3rd argument of createElement). For example: \n"
.. "       createElement(ContextConsumer, {render = function(...) end})\n"
.. "becomes:\n"
.. "       createElement(ContextConsumer, nil, function(...) end)\n"
.. "For more info, reference the React documentation here: \n"
.. "https://reactjs.org/docs/context.html#contextconsumer"
)
end
end
render = newProps.render
else
render = newProps.children
end
if __DEV__ then
if type(render) ~= "function" then
console.error(
"A context consumer was rendered with multiple children, or a child "
.. "that isn't a function. A context consumer expects a single child "
.. "that is a function. If you did pass a function, make sure there "
.. "is no trailing or leading whitespace around it."
)
end
end
prepareToReadContext(
workInProgress,
renderLanes,
exports.markWorkInProgressReceivedUpdate
)
local newValue = readContext(context, newProps.unstable_observedBits)
local newChildren
if __DEV__ then
ReactCurrentOwner.current = workInProgress
setIsRendering(true)
newChildren = render(newValue)
setIsRendering(false)
else
newChildren = render(newValue)
end
workInProgress.flags = bit32.bor(workInProgress.flags, PerformedWork)
reconcileChildren(current, workInProgress, newChildren, renderLanes)
return workInProgress.child
end
exports.markWorkInProgressReceivedUpdate = function()
didReceiveUpdate = true
end
function bailoutOnAlreadyFinishedWork(
current: Fiber | nil,
workInProgress: Fiber,
renderLanes: Lanes
): Fiber | nil
if current then
workInProgress.dependencies = current.dependencies
end
if enableProfilerTimer then
stopProfilerTimerIfRunning(workInProgress)
end
markSkippedUpdateLanes(workInProgress.lanes)
if not ReactFiberLane.includesSomeLane(renderLanes, workInProgress.childLanes) then
return nil
else
cloneChildFibers(current, workInProgress)
return workInProgress.child
end
end
function remountFiber(
current: Fiber,
oldWorkInProgress: Fiber,
newWorkInProgress: Fiber
): Fiber | nil
if __DEV__ then
local returnFiber = oldWorkInProgress.return_
if returnFiber == nil then
error("Cannot swap the root fiber.")
end
assert(returnFiber ~= nil, "returnFiber was nil in remountFiber")
current.alternate = nil
oldWorkInProgress.alternate = nil
newWorkInProgress.index = oldWorkInProgress.index
newWorkInProgress.sibling = oldWorkInProgress.sibling
newWorkInProgress.return_ = oldWorkInProgress.return_
newWorkInProgress.ref = oldWorkInProgress.ref
if oldWorkInProgress == returnFiber.child then
returnFiber.child = newWorkInProgress
else
local prevSibling = returnFiber.child
if prevSibling == nil then
error("Expected parent to have a child.")
end
assert(prevSibling ~= nil, "prevSibling was nil in remountFiber")
while prevSibling.sibling ~= oldWorkInProgress do
prevSibling = prevSibling.sibling
if prevSibling == nil then
error("Expected to find the previous sibling.")
end
end
prevSibling.sibling = newWorkInProgress
end
local deletions = returnFiber.deletions
if deletions == nil then
returnFiber.deletions = { current }
returnFiber.flags = bit32.bor(returnFiber.flags, Deletion)
else
table.insert(deletions, current)
end
newWorkInProgress.flags = bit32.bor(newWorkInProgress.flags, Placement)
return newWorkInProgress
else
error(
"Did not expect this call in production. "
.. "This is a bug in React. Please file an issue."
)
end
end
local function beginWork(current: any, workInProgress: Fiber, renderLanes: Lanes): Fiber?
local updateLanes = workInProgress.lanes
if __DEV__ then
if workInProgress._debugNeedsRemount and current ~= nil then
return remountFiber(
current,
workInProgress,
createFiberFromTypeAndProps(
workInProgress.type,
workInProgress.key :: string?,
workInProgress.pendingProps,
workInProgress._debugOwner or nil,
workInProgress.mode,
workInProgress.lanes
)
)
end
end
if current ~= nil then
local oldProps = current.memoizedProps
local newProps = workInProgress.pendingProps
if
oldProps ~= newProps
or hasLegacyContextChanged()
or if __DEV__ then workInProgress.type ~= current.type else false
then
didReceiveUpdate = true
elseif not ReactFiberLane.includesSomeLane(renderLanes, updateLanes) then
didReceiveUpdate = false
if workInProgress.tag == HostRoot then
pushHostRootContext(workInProgress)
resetHydrationState()
elseif workInProgress.tag == HostComponent then
pushHostContext(workInProgress)
elseif workInProgress.tag == ClassComponent then
local Component = workInProgress.type
if isLegacyContextProvider(Component) then
pushLegacyContextProvider(workInProgress)
end
elseif workInProgress.tag == HostPortal then
pushHostContainer(workInProgress, workInProgress.stateNode.containerInfo)
elseif workInProgress.tag == ContextProvider then
local newValue = workInProgress.memoizedProps.value
pushProvider(workInProgress, newValue)
elseif workInProgress.tag == Profiler then
if enableProfilerTimer then
local stateNode = workInProgress.stateNode
stateNode.effectDuration = 0
stateNode.passiveEffectDuration = 0
end
elseif workInProgress.tag == SuspenseComponent then
local state: SuspenseState | nil = workInProgress.memoizedState
if state ~= nil then
if enableSuspenseServerRenderer then
if (state :: SuspenseState).dehydrated ~= nil then
pushSuspenseContext(
workInProgress,
setDefaultShallowSuspenseContext(
suspenseStackCursor.current
)
)
workInProgress.flags =
bit32.bor(workInProgress.flags, DidCapture)
return nil
end
end
local primaryChildFragment: Fiber = workInProgress.child :: any
local primaryChildLanes = primaryChildFragment.childLanes
if
ReactFiberLane.includesSomeLane(renderLanes, primaryChildLanes)
then
return updateSuspenseComponent(
current,
workInProgress,
renderLanes
)
else
pushSuspenseContext(
workInProgress,
setDefaultShallowSuspenseContext(suspenseStackCursor.current)
)
local child = bailoutOnAlreadyFinishedWork(
current,
workInProgress,
renderLanes
)
if child ~= nil then
return child.sibling
else
return nil
end
end
else
pushSuspenseContext(
workInProgress,
setDefaultShallowSuspenseContext(suspenseStackCursor.current)
)
end
elseif workInProgress.tag == SuspenseListComponent then
unimplemented("beginWork: SuspenseListComponent")
elseif
workInProgress.tag == OffscreenComponent
or workInProgress.tag == LegacyHiddenComponent
then
workInProgress.lanes = ReactFiberLane.NoLanes
return updateOffscreenComponent(current, workInProgress, renderLanes)
end
return bailoutOnAlreadyFinishedWork(current, workInProgress, renderLanes)
else
if bit32.band(current.flags, ForceUpdateForLegacySuspense) ~= NoFlags then
didReceiveUpdate = true
else
didReceiveUpdate = false
end
end
else
didReceiveUpdate = false
end
workInProgress.lanes = ReactFiberLane.NoLanes
if workInProgress.tag == ReactWorkTags.IndeterminateComponent then
return mountIndeterminateComponent(
current,
workInProgress,
workInProgress.type,
renderLanes
)
elseif workInProgress.tag == LazyComponent then
local elementType = workInProgress.elementType
return mountLazyComponent(
current,
workInProgress,
elementType,
updateLanes,
renderLanes
)
elseif workInProgress.tag == FunctionComponent then
local Component = workInProgress.type
local unresolvedProps = workInProgress.pendingProps
local resolvedProps
if workInProgress.elementType == Component then
resolvedProps = unresolvedProps
else
resolvedProps = resolveDefaultProps(Component, unresolvedProps)
end
return updateFunctionComponent(
current,
workInProgress,
Component,
resolvedProps,
renderLanes
)
elseif workInProgress.tag == ClassComponent then
local Component = workInProgress.type
local unresolvedProps = workInProgress.pendingProps
local resolvedProps = workInProgress.elementType == Component and unresolvedProps
or resolveDefaultProps(Component, unresolvedProps)
return updateClassComponent(
current,
workInProgress,
Component,
resolvedProps,
renderLanes
)
elseif workInProgress.tag == HostRoot then
return updateHostRoot(current, workInProgress, renderLanes)
elseif workInProgress.tag == HostComponent then
return updateHostComponent(current, workInProgress, renderLanes)
elseif workInProgress.tag == HostText then
return updateHostText(current, workInProgress)
elseif workInProgress.tag == SuspenseComponent then
return updateSuspenseComponent(current, workInProgress, renderLanes)
elseif workInProgress.tag == HostPortal then
return updatePortalComponent(current, workInProgress, renderLanes)
elseif workInProgress.tag == ForwardRef then
local type = workInProgress.type
local unresolvedProps = workInProgress.pendingProps
local resolvedProps = unresolvedProps
if workInProgress.elementType ~= type then
resolvedProps = resolveDefaultProps(type, unresolvedProps)
end
return updateForwardRef(current, workInProgress, type, resolvedProps, renderLanes)
elseif workInProgress.tag == Fragment then
return updateFragment(current, workInProgress, renderLanes)
elseif workInProgress.tag == Mode then
return updateMode(current, workInProgress, renderLanes)
elseif workInProgress.tag == Profiler then
return updateProfiler(current, workInProgress, renderLanes)
elseif workInProgress.tag == ContextProvider then
return updateContextProvider(current, workInProgress, renderLanes)
elseif workInProgress.tag == ContextConsumer then
return updateContextConsumer(current, workInProgress, renderLanes)
elseif workInProgress.tag == MemoComponent then
local type_ = workInProgress.type
local unresolvedProps = workInProgress.pendingProps
local resolvedProps = resolveDefaultProps(type_, unresolvedProps)
if __DEV__ or __DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ then
if workInProgress.type ~= workInProgress.elementType then
local outerPropTypes
local validateProps
if type(type_) == "table" then
outerPropTypes = type_.propTypes
validateProps = type_.validateProps
end
if outerPropTypes or validateProps then
checkPropTypes(
outerPropTypes,
validateProps,
resolvedProps,
"prop",
getComponentName(type_)
)
end
end
end
resolvedProps = resolveDefaultProps(type_.type, resolvedProps)
return updateMemoComponent(
current,
workInProgress,
type_,
resolvedProps,
updateLanes,
renderLanes
)
elseif workInProgress.tag == SimpleMemoComponent then
return updateSimpleMemoComponent(
current,
workInProgress,
workInProgress.type,
workInProgress.pendingProps,
updateLanes,
renderLanes
)
elseif workInProgress.tag == IncompleteClassComponent then
local Component = workInProgress.type
local unresolvedProps = workInProgress.pendingProps
local resolvedProps = workInProgress.elementType == Component and unresolvedProps
or resolveDefaultProps(Component, unresolvedProps)
return mountIncompleteClassComponent(
current,
workInProgress,
Component,
resolvedProps,
renderLanes
)
elseif workInProgress.tag == OffscreenComponent then
return updateOffscreenComponent(current, workInProgress, renderLanes)
elseif workInProgress.tag == LegacyHiddenComponent then
return updateLegacyHiddenComponent(current, workInProgress, renderLanes)
end
invariant(
false,
"Unknown unit of work tag (%s). This error is likely caused by a bug in "
.. "React. Please file an issue.",
tostring(workInProgress.tag)
)
return nil
end
exports.beginWork = beginWork
return exports
end
end)())
__register("ReactReconciler/ReactFiberClassComponent.new", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberClassComponent.new"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local LuauPolyfill = __require(Packages.LuauPolyfill)
local Object = LuauPolyfill.Object
local __DEV__ = ReactGlobals.__DEV__ :: boolean
local console = __require(Packages.Shared).console
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
local ReactFiberLane = __require(script.Parent.ReactFiberLane)
type Lanes = ReactFiberLane.Lanes
local ReactUpdateQueue = __require(script.Parent["ReactUpdateQueue.new"])
type UpdateQueue<State> = ReactInternalTypes.UpdateQueue<State>
local ReactTypes = __require(Packages.Shared)
type React_Component<Props, State> = ReactTypes.React_Component<Props, State>
local React = __require(Packages.React)
local ReactFiberFlags = __require(script.Parent.ReactFiberFlags)
local Update = ReactFiberFlags.Update
local Snapshot = ReactFiberFlags.Snapshot
local MountLayoutDev = ReactFiberFlags.MountLayoutDev
local ReactFeatureFlags = __require(Packages.Shared).ReactFeatureFlags
local debugRenderPhaseSideEffectsForStrictMode =
ReactFeatureFlags.debugRenderPhaseSideEffectsForStrictMode
local disableLegacyContext = ReactFeatureFlags.disableLegacyContext
local enableDebugTracing = ReactFeatureFlags.enableDebugTracing
local enableSchedulingProfiler = ReactFeatureFlags.enableSchedulingProfiler
local warnAboutDeprecatedLifecycles = ReactFeatureFlags.warnAboutDeprecatedLifecycles
local enableDoubleInvokingEffects = ReactFeatureFlags.enableDoubleInvokingEffects
local ReactStrictModeWarnings = __require(script.Parent["ReactStrictModeWarnings.new"])
local isMounted = __require(script.Parent.ReactFiberTreeReflection).isMounted
local ReactInstanceMap = __require(Packages.Shared).ReactInstanceMap
local getInstance = ReactInstanceMap.get
local setInstance = ReactInstanceMap.set
local shallowEqual = __require(Packages.Shared).shallowEqual
local getComponentName = __require(Packages.Shared).getComponentName
local UninitializedState = __require(Packages.Shared).UninitializedState
local describeError = __require(Packages.Shared).describeError
local ReactSymbols = __require(Packages.Shared).ReactSymbols
local REACT_CONTEXT_TYPE = ReactSymbols.REACT_CONTEXT_TYPE
local REACT_PROVIDER_TYPE = ReactSymbols.REACT_PROVIDER_TYPE
local resolveDefaultProps =
__require(script.Parent["ReactFiberLazyComponent.new"]).resolveDefaultProps
local ReactTypeOfMode = __require(script.Parent.ReactTypeOfMode)
local DebugTracingMode = ReactTypeOfMode.DebugTracingMode
local StrictMode = ReactTypeOfMode.StrictMode
local enqueueUpdate = ReactUpdateQueue.enqueueUpdate
local processUpdateQueue = ReactUpdateQueue.processUpdateQueue
local checkHasForceUpdateAfterProcessing =
ReactUpdateQueue.checkHasForceUpdateAfterProcessing
local resetHasForceUpdateBeforeProcessing =
ReactUpdateQueue.resetHasForceUpdateBeforeProcessing
local createUpdate = ReactUpdateQueue.createUpdate
local ReplaceState = ReactUpdateQueue.ReplaceState
local ForceUpdate = ReactUpdateQueue.ForceUpdate
local initializeUpdateQueue = ReactUpdateQueue.initializeUpdateQueue
local cloneUpdateQueue = ReactUpdateQueue.cloneUpdateQueue
local NoLanes = ReactFiberLane.NoLanes
local ReactFiberContext = __require(script.Parent["ReactFiberContext.new"])
local cacheContext = ReactFiberContext.cacheContext
local getMaskedContext = ReactFiberContext.getMaskedContext
local getUnmaskedContext = ReactFiberContext.getUnmaskedContext
local hasContextChanged = ReactFiberContext.hasContextChanged
local emptyContextObject = ReactFiberContext.emptyContextObject
local ReactFiberNewContext = __require(script.Parent["ReactFiberNewContext.new"])
local readContext = ReactFiberNewContext.readContext
local DebugTracing = __require(script.Parent.DebugTracing)
local logForceUpdateScheduled = DebugTracing.logForceUpdateScheduled
local logStateUpdateScheduled = DebugTracing.logStateUpdateScheduled
local ConsolePatchingDev = __require(Packages.Shared).ConsolePatchingDev
local disableLogs = ConsolePatchingDev.disableLogs
local reenableLogs = ConsolePatchingDev.reenableLogs
local SchedulingProfiler = __require(script.Parent.SchedulingProfiler)
local markForceUpdateScheduled = SchedulingProfiler.markForceUpdateScheduled
local markStateUpdateScheduled = SchedulingProfiler.markStateUpdateScheduled
local fakeInternalInstance = {}
local emptyRefsObject = React.Component:extend("").__refs
local didWarnAboutStateAssignmentForComponent
local didWarnAboutUninitializedState
local didWarnAboutGetSnapshotBeforeUpdateWithoutDidUpdate
local didWarnAboutLegacyLifecyclesAndDerivedState
local _didWarnAboutUndefinedDerivedState
local warnOnUndefinedDerivedState
local warnOnInvalidCallback
local didWarnAboutDirectlyAssigningPropsToState
local didWarnAboutContextTypeAndContextTypes
local didWarnAboutInvalidateContextType
if __DEV__ then
didWarnAboutStateAssignmentForComponent = {}
didWarnAboutUninitializedState = {}
didWarnAboutGetSnapshotBeforeUpdateWithoutDidUpdate = {}
didWarnAboutLegacyLifecyclesAndDerivedState = {}
didWarnAboutDirectlyAssigningPropsToState = {}
_didWarnAboutUndefinedDerivedState = {}
didWarnAboutContextTypeAndContextTypes = {}
didWarnAboutInvalidateContextType = {}
local didWarnOnInvalidCallback = {}
function warnOnInvalidCallback(callback: any, callerName: string)
if callback == nil or type(callback) == "function" then
return
end
local key = callerName .. "_" .. tostring(callback)
if not didWarnOnInvalidCallback[key] then
didWarnOnInvalidCallback[key] = true
console.error(
"%s(...): Expected the last optional `callback` argument to be a "
.. "function. Instead received: %s.",
callerName,
tostring(callback)
)
end
end
function warnOnUndefinedDerivedState(type_, partialState)
end
end
local function applyDerivedStateFromProps<Props, State>(
workInProgress: Fiber,
ctor: React_Component<Props, State>,
getDerivedStateFromProps: (Props, State) -> State?,
nextProps: Props
)
local prevState = workInProgress.memoizedState
if __DEV__ then
if
debugRenderPhaseSideEffectsForStrictMode
and bit32.band(workInProgress.mode, StrictMode) ~= 0
then
disableLogs()
local ok, result =
xpcall(getDerivedStateFromProps, describeError, nextProps, prevState)
reenableLogs()
if not ok then
error(result)
end
end
end
local partialState = getDerivedStateFromProps(nextProps, prevState)
if __DEV__ then
warnOnUndefinedDerivedState(ctor, partialState)
end
local memoizedState = if partialState == nil
then prevState
else Object.assign({}, prevState, partialState)
workInProgress.memoizedState = memoizedState
if workInProgress.lanes == NoLanes then
local updateQueue: UpdateQueue<any> = workInProgress.updateQueue
updateQueue.baseState = memoizedState
end
end
local classComponentUpdater = nil
local function initializeClassComponentUpdater()
local ReactFiberWorkLoop = __require(script.Parent["ReactFiberWorkLoop.new"])
local requestEventTime = ReactFiberWorkLoop.requestEventTime
local requestUpdateLane = ReactFiberWorkLoop.requestUpdateLane
local scheduleUpdateOnFiber = ReactFiberWorkLoop.scheduleUpdateOnFiber
classComponentUpdater = {
isMounted = isMounted,
enqueueSetState = function(inst, payload, callback: (() -> ...any)?)
local fiber = getInstance(inst)
local eventTime = requestEventTime()
local lane = requestUpdateLane(fiber)
local update = createUpdate(eventTime, lane, payload, callback)
if callback ~= nil then
if __DEV__ then
warnOnInvalidCallback(callback, "setState")
end
end
enqueueUpdate(fiber, update)
scheduleUpdateOnFiber(fiber, lane, eventTime)
if __DEV__ then
if enableDebugTracing then
if bit32.band(fiber.mode, DebugTracingMode) ~= 0 then
local name = getComponentName(fiber.type) or "Unknown"
logStateUpdateScheduled(name, lane, payload)
end
end
end
if enableSchedulingProfiler then
markStateUpdateScheduled(fiber, lane)
end
end,
enqueueReplaceState = function(inst, payload, callback)
local fiber = getInstance(inst)
local eventTime = requestEventTime()
local lane = requestUpdateLane(fiber)
local update = createUpdate(eventTime, lane, payload, callback)
update.tag = ReplaceState
if callback ~= nil then
if __DEV__ then
warnOnInvalidCallback(callback, "replaceState")
end
end
enqueueUpdate(fiber, update)
scheduleUpdateOnFiber(fiber, lane, eventTime)
if __DEV__ then
if enableDebugTracing then
if bit32.band(fiber.mode, DebugTracingMode) ~= 0 then
local name = getComponentName(fiber.type) or "Unknown"
logStateUpdateScheduled(name, lane, payload)
end
end
end
if enableSchedulingProfiler then
markStateUpdateScheduled(fiber, lane)
end
end,
enqueueForceUpdate = function(inst, callback)
local fiber = getInstance(inst)
local eventTime = requestEventTime()
local lane = requestUpdateLane(fiber)
local update = createUpdate(eventTime, lane, nil, callback)
update.tag = ForceUpdate
if callback ~= nil then
if __DEV__ then
warnOnInvalidCallback(callback, "forceUpdate")
end
end
enqueueUpdate(fiber, update)
scheduleUpdateOnFiber(fiber, lane, eventTime)
if __DEV__ then
if enableDebugTracing then
if bit32.band(fiber.mode, DebugTracingMode) ~= 0 then
local name = getComponentName(fiber.type) or "Unknown"
logForceUpdateScheduled(name, lane)
end
end
end
if enableSchedulingProfiler then
markForceUpdateScheduled(fiber, lane)
end
end,
}
end
local function getClassComponentUpdater()
if classComponentUpdater == nil then
initializeClassComponentUpdater()
end
return classComponentUpdater
end
function checkShouldComponentUpdate(
workInProgress,
ctor,
oldProps,
newProps,
oldState,
newState,
nextContext
)
local instance = workInProgress.stateNode
if
instance.shouldComponentUpdate ~= nil
and type(instance.shouldComponentUpdate) == "function"
then
if __DEV__ then
if
debugRenderPhaseSideEffectsForStrictMode
and bit32.band(workInProgress.mode, StrictMode) ~= 0
then
disableLogs()
local ok, result = xpcall(
instance.shouldComponentUpdate,
describeError,
instance,
newProps,
newState,
nextContext
)
reenableLogs()
if not ok then
error(result)
end
end
end
local shouldUpdate =
instance:shouldComponentUpdate(newProps, newState, nextContext)
if __DEV__ then
if shouldUpdate == nil then
console.error(
"%s.shouldComponentUpdate(): Returned nil instead of a "
.. "boolean value. Make sure to return true or false.",
getComponentName(ctor) or "Component"
)
end
end
return shouldUpdate
end
if type(ctor) == "table" and ctor.isPureReactComponent then
return (
not shallowEqual(oldProps, newProps) or not shallowEqual(oldState, newState)
)
end
return true
end
local function checkClassInstance(workInProgress: Fiber, ctor: any, newProps: any)
local instance = workInProgress.stateNode
if __DEV__ then
local name = getComponentName(ctor) or "Component"
local renderPresent = instance.render
if not renderPresent then
if type(ctor.render) == "function" then
console.error(
"%s(...): No `render` method found on the returned component "
.. "instance: did you accidentally return an object from the constructor?",
name
)
else
console.error(
"%s(...): No `render` method found on the returned component "
.. "instance: you may have forgotten to define `render`.",
name
)
end
end
if
instance.getInitialState
and not instance.getInitialState.isReactClassApproved
and not instance.state
then
console.error(
"getInitialState was defined on %s, a plain JavaScript class. "
.. "This is only supported for classes created using React.createClass. "
.. "Did you mean to define a state property instead?",
name
)
end
if
instance.getDefaultProps
and not instance.getDefaultProps.isReactClassApproved
then
console.error(
"getDefaultProps was defined on %s, a plain JavaScript class. "
.. "This is only supported for classes created using React.createClass. "
.. "Use a static property to define defaultProps instead.",
name
)
end
if instance.propTypes and not ctor.propTypes then
console.error(
"propTypes was defined as an instance property on %s. Use a static "
.. "property to define propTypes instead.",
name
)
end
if instance.contextType and not ctor.contextType then
console.error(
"contextType was defined as an instance property on %s. Use a static "
.. "property to define contextType instead.",
name
)
end
if disableLegacyContext then
if ctor.childContextTypes then
console.error(
"%s uses the legacy childContextTypes API which is no longer supported. "
.. "Use React.createContext() instead.",
name
)
end
if ctor.contextTypes then
console.error(
"%s uses the legacy contextTypes API which is no longer supported. "
.. "Use React.createContext() with static contextType instead.",
name
)
end
else
if instance.contextTypes and not ctor.contextTypes then
console.error(
"contextTypes was defined as an instance property on %s. Use a static "
.. "property to define contextTypes instead.",
name
)
end
if
type(ctor) == "table"
and ctor.contextType
and ctor.contextTypes
and not didWarnAboutContextTypeAndContextTypes[ctor]
then
didWarnAboutContextTypeAndContextTypes[ctor] = true
console.error(
"%s declares both contextTypes and contextType static properties. "
.. "The legacy contextTypes property will be ignored.",
name
)
end
end
if type(instance.componentShouldUpdate) == "function" then
console.error(
"%s has a method called "
.. "componentShouldUpdate(). Did you mean shouldComponentUpdate()? "
.. "The name is phrased as a question because the function is "
.. "expected to return a value.",
name
)
end
if
type(ctor) == "table"
and ctor.isPureReactComponent
and instance.shouldComponentUpdate ~= nil
then
console.error(
"%s has a method called shouldComponentUpdate(). "
.. "shouldComponentUpdate should not be used when extending React.PureComponent. "
.. "Please extend React.Component if shouldComponentUpdate is used.",
getComponentName(ctor) or "A pure component"
)
end
if type(instance.componentDidUnmount) == "function" then
console.error(
"%s has a method called "
.. "componentDidUnmount(). But there is no such lifecycle method. "
.. "Did you mean componentWillUnmount()?",
name
)
end
if type(instance.componentDidReceiveProps) == "function" then
console.error(
"%s has a method called "
.. "componentDidReceiveProps(). But there is no such lifecycle method. "
.. "If you meant to update the state in response to changing props, "
.. "use componentWillReceiveProps(). If you meant to fetch data or "
.. "run side-effects or mutations after React has updated the UI, use componentDidUpdate().",
name
)
end
if type(instance.componentWillRecieveProps) == "function" then
console.error(
"%s has a method called "
.. "componentWillRecieveProps(). Did you mean componentWillReceiveProps()?",
name
)
end
if type(instance.UNSAFE_componentWillRecieveProps) == "function" then
console.error(
"%s has a method called "
.. "UNSAFE_componentWillRecieveProps(). Did you mean UNSAFE_componentWillReceiveProps()?",
name
)
end
local hasMutatedProps = instance.props ~= newProps
if instance.props ~= nil and hasMutatedProps then
console.error(
"%s(...): When calling super() in `%s`, make sure to pass "
.. "up the same props that your component's constructor was passed.",
name,
name
)
end
if rawget(instance, "defaultProps") then
console.error(
"Setting defaultProps as an instance property on %s is not supported and will be ignored."
.. " Instead, define defaultProps as a static property on %s.",
name,
name
)
end
if
type(instance.getSnapshotBeforeUpdate) == "function"
and type(instance.componentDidUpdate) ~= "function"
and not didWarnAboutGetSnapshotBeforeUpdateWithoutDidUpdate[ctor]
then
didWarnAboutGetSnapshotBeforeUpdateWithoutDidUpdate[ctor] = true
console.error(
"%s: getSnapshotBeforeUpdate() should be used with componentDidUpdate(). "
.. "This component defines getSnapshotBeforeUpdate() only.",
getComponentName(ctor)
)
end
local state = instance.state
if state ~= nil and type(state) ~= "table" then
console.error("%s.state: must be set to an object or nil", name)
end
if
type(ctor) == "table"
and type(instance.getChildContext) == "function"
and type(ctor.childContextTypes) ~= "table"
then
console.error(
"%s.getChildContext(): childContextTypes must be defined in order to "
.. "use getChildContext().",
name
)
end
end
end
local function adoptClassInstance(workInProgress: Fiber, instance: any)
instance.__updater = getClassComponentUpdater()
workInProgress.stateNode = instance
setInstance(instance, workInProgress)
if __DEV__ then
instance._reactInternalInstance = fakeInternalInstance
end
end
local function constructClassInstance(workInProgress: Fiber, ctor: any, props: any): any
local isLegacyContextConsumer = false
local unmaskedContext = emptyContextObject
local context = emptyContextObject
local contextType = ctor.contextType
if __DEV__ then
if ctor["contextType"] ~= nil then
local isValid =
contextType == nil or (contextType["$$typeof"] == REACT_CONTEXT_TYPE and contextType._context == nil)
if not isValid and not didWarnAboutInvalidateContextType[ctor] then
didWarnAboutInvalidateContextType[ctor] = true
local addendum = ""
if contextType == nil then
addendum =
" However, it is set to nil. " .. "This can be caused by a typo or by mixing up named and default imports. " .. "This can also happen due to a circular dependency, so " .. "try moving the createContext() call to a separate file."
elseif type(contextType) ~= "table" then
addendum = " However, it is set to a " .. type(contextType) .. "."
elseif contextType["$$typeof"] == REACT_PROVIDER_TYPE then
addendum = " Did you accidentally pass the Context.Provider instead?"
elseif contextType._context ~= nil then
addendum = " Did you accidentally pass the Context.Consumer instead?"
else
addendum ..= " However, it is set to an object with keys {"
for key, _ in contextType do
addendum ..= key .. ", "
end
addendum ..= "}."
end
console.error(
"%s defines an invalid contextType. "
.. "contextType should point to the Context object returned by React.createContext().%s",
getComponentName(ctor) or "Component",
addendum
)
end
end
end
if contextType ~= nil and type(contextType) == "table" then
context = readContext(contextType)
elseif not disableLegacyContext then
unmaskedContext = getUnmaskedContext(workInProgress, ctor, true)
local contextTypes = ctor.contextTypes
isLegacyContextConsumer = contextTypes ~= nil
context = isLegacyContextConsumer
and getMaskedContext(workInProgress, unmaskedContext)
or emptyContextObject
end
if __DEV__ then
if
debugRenderPhaseSideEffectsForStrictMode
and bit32.band(workInProgress.mode, StrictMode) ~= 0
then
disableLogs()
local ok, result = xpcall(ctor.__ctor, describeError, props, context)
reenableLogs()
if not ok then
error(result)
end
end
end
local instance = ctor.__ctor(props, context)
workInProgress.memoizedState = instance.state
local state = workInProgress.memoizedState
adoptClassInstance(workInProgress, instance)
if __DEV__ then
if
type(ctor.getDerivedStateFromProps) == "function"
and state == UninitializedState
then
local componentName = getComponentName(ctor) or "Component"
if not didWarnAboutUninitializedState[componentName] then
didWarnAboutUninitializedState[componentName] = true
console.error(
"`%s` uses `getDerivedStateFromProps` but its initial state has not been initialized. "
.. "This is not recommended. Instead, define the initial state by "
.. "passing an object to `self:setState` in the `init` method of `%s`. "
.. "This ensures that `getDerivedStateFromProps` arguments have a consistent shape.",
componentName,
componentName
)
end
end
if
type(ctor.getDerivedStateFromProps) == "function"
or type(instance.getSnapshotBeforeUpdate) == "function"
then
local foundWillMountName = nil
local foundWillReceivePropsName = nil
local foundWillUpdateName = nil
if
type(instance.componentWillMount) == "function"
then
foundWillMountName = "componentWillMount"
elseif type(instance.UNSAFE_componentWillMount) == "function" then
foundWillMountName = "UNSAFE_componentWillMount"
end
if
type(instance.componentWillReceiveProps) == "function"
then
foundWillReceivePropsName = "componentWillReceiveProps"
elseif type(instance.UNSAFE_componentWillReceiveProps) == "function" then
foundWillReceivePropsName = "UNSAFE_componentWillReceiveProps"
end
if
type(instance.componentWillUpdate) == "function"
then
foundWillUpdateName = "componentWillUpdate"
elseif type(instance.UNSAFE_componentWillUpdate) == "function" then
foundWillUpdateName = "UNSAFE_componentWillUpdate"
end
if
foundWillMountName ~= nil
or foundWillReceivePropsName ~= nil
or foundWillUpdateName ~= nil
then
local componentName = getComponentName(ctor) or "Component"
local newApiName
if type(ctor.getDerivedStateFromProps) == "function" then
newApiName = "getDerivedStateFromProps()"
else
newApiName = "getSnapshotBeforeUpdate()"
end
local willMountName
if foundWillMountName ~= nil then
willMountName = ("\n  " .. tostring(foundWillMountName))
else
willMountName = ""
end
local willReceievePropsName
if foundWillReceivePropsName ~= nil then
willReceievePropsName = (
"\n  " .. tostring(foundWillReceivePropsName)
)
else
willReceievePropsName = ""
end
local willUpdateName
if foundWillUpdateName ~= nil then
willUpdateName = "\n  " .. tostring(foundWillUpdateName)
else
willUpdateName = ""
end
if not didWarnAboutLegacyLifecyclesAndDerivedState[componentName] then
didWarnAboutLegacyLifecyclesAndDerivedState[componentName] = true
console.error(
"Unsafe legacy lifecycles will not be called for components using new component APIs.\n\n"
.. "%s uses %s but also contains the following legacy lifecycles:%s%s%s\n\n"
.. "The above lifecycles should be removed. Learn more about this warning here:\n"
.. "https://reactjs.org/link/unsafe-component-lifecycles",
componentName,
newApiName,
willMountName,
willReceievePropsName,
willUpdateName
)
end
end
end
end
if isLegacyContextConsumer then
cacheContext(workInProgress, unmaskedContext, context)
end
return instance
end
local function callComponentWillMount(workInProgress, instance)
local oldState = instance.state
if
instance.componentWillMount ~= nil
and type(instance.componentWillMount) == "function"
then
instance:componentWillMount()
end
if
instance.UNSAFE_componentWillMount ~= nil
and type(instance.UNSAFE_componentWillMount) == "function"
then
instance:UNSAFE_componentWillMount()
end
if oldState ~= instance.state then
if __DEV__ then
console.error(
"%s.componentWillMount(): Assigning directly to this.state is "
.. "deprecated (except inside a component's "
.. "constructor). Use setState instead.",
getComponentName(workInProgress.type) or "Component"
)
end
getClassComponentUpdater().enqueueReplaceState(instance, instance.state)
end
end
function callComponentWillReceiveProps(workInProgress, instance, newProps, nextContext)
local oldState = instance.state
if
instance.componentWillReceiveProps ~= nil
and type(instance.componentWillReceiveProps) == "function"
then
instance:componentWillReceiveProps(newProps, nextContext)
end
if
instance.UNSAFE_componentWillReceiveProps ~= nil
and type(instance.UNSAFE_componentWillReceiveProps) == "function"
then
instance:UNSAFE_componentWillReceiveProps(newProps, nextContext)
end
if instance.state ~= oldState then
if __DEV__ then
local componentName = getComponentName(workInProgress.type) or "Component"
if not didWarnAboutStateAssignmentForComponent[componentName] then
didWarnAboutStateAssignmentForComponent[componentName] = true
console.error(
"%s.componentWillReceiveProps(): Assigning directly to "
.. "this.state is deprecated (except inside a component's "
.. "constructor). Use setState instead.",
componentName
)
end
end
getClassComponentUpdater().enqueueReplaceState(instance, instance.state)
end
end
local function mountClassInstance(
workInProgress: Fiber,
ctor: any,
newProps: any,
renderLanes: Lanes
)
if __DEV__ then
checkClassInstance(workInProgress, ctor, newProps)
end
local instance = workInProgress.stateNode
instance.props = newProps
instance.state = workInProgress.memoizedState
instance.__refs = emptyRefsObject
initializeUpdateQueue(workInProgress)
local contextType
if type(ctor) == "table" then
contextType = ctor.contextType
end
if contextType ~= nil and type(contextType) == "table" then
instance.context = readContext(contextType)
elseif disableLegacyContext then
instance.context = emptyContextObject
else
local unmaskedContext = getUnmaskedContext(workInProgress, ctor, true)
instance.context = getMaskedContext(workInProgress, unmaskedContext)
end
if __DEV__ then
if instance.state == newProps then
local componentName = getComponentName(ctor) or "Component"
if not didWarnAboutDirectlyAssigningPropsToState[componentName] then
didWarnAboutDirectlyAssigningPropsToState[componentName] = true
console.error(
"%s: It is not recommended to assign props directly to state "
.. "because updates to props won't be reflected in state. "
.. "In most cases, it is better to use props directly.",
componentName
)
end
end
if bit32.band(workInProgress.mode, StrictMode) ~= 0 then
ReactStrictModeWarnings.recordLegacyContextWarning(workInProgress, instance)
end
if warnAboutDeprecatedLifecycles then
ReactStrictModeWarnings.recordUnsafeLifecycleWarnings(
workInProgress,
instance
)
end
end
processUpdateQueue(workInProgress, newProps, instance, renderLanes)
instance.state = workInProgress.memoizedState
local typeofCtor = type(ctor)
local getDerivedStateFromProps
if type(ctor) == "table" then
getDerivedStateFromProps = ctor.getDerivedStateFromProps
end
if
getDerivedStateFromProps ~= nil
and type(getDerivedStateFromProps) == "function"
then
applyDerivedStateFromProps(
workInProgress,
ctor,
getDerivedStateFromProps,
newProps
)
instance.state = workInProgress.memoizedState
end
if
typeofCtor == "table"
and type(ctor.getDerivedStateFromProps) ~= "function"
and type(instance.getSnapshotBeforeUpdate) ~= "function"
and (
type(instance.UNSAFE_componentWillMount) == "function"
or type(instance.componentWillMount) == "function"
)
then
callComponentWillMount(workInProgress, instance)
processUpdateQueue(workInProgress, newProps, instance, renderLanes)
instance.state = workInProgress.memoizedState
end
if type(instance.componentDidMount) == "function" then
if __DEV__ and enableDoubleInvokingEffects then
workInProgress.flags =
bit32.bor(workInProgress.flags, bit32.bor(MountLayoutDev, Update))
else
workInProgress.flags = bit32.bor(workInProgress.flags, Update)
end
end
end
function resumeMountClassInstance(
workInProgress: Fiber,
ctor: any,
newProps: any,
renderLanes: Lanes
): boolean
local instance = workInProgress.stateNode
local oldProps = workInProgress.memoizedProps
instance.props = oldProps
local oldContext = instance.context
local contextType = ctor.contextType
local nextContext = emptyContextObject
if contextType ~= nil and type(contextType) == "table" then
nextContext = readContext(contextType)
elseif not disableLegacyContext then
local nextLegacyUnmaskedContext = getUnmaskedContext(workInProgress, ctor, true)
nextContext = getMaskedContext(workInProgress, nextLegacyUnmaskedContext)
end
local getDerivedStateFromProps = ctor.getDerivedStateFromProps
local hasNewLifecycles = type(getDerivedStateFromProps) == "function"
or type(instance.getSnapshotBeforeUpdate) == "function"
if
not hasNewLifecycles
and (
type(instance.UNSAFE_componentWillReceiveProps) == "function"
or type(instance.componentWillReceiveProps) == "function"
)
then
if oldProps ~= newProps or oldContext ~= nextContext then
callComponentWillReceiveProps(workInProgress, instance, newProps, nextContext)
end
end
resetHasForceUpdateBeforeProcessing()
local oldState = workInProgress.memoizedState
instance.state = oldState
local newState = oldState
processUpdateQueue(workInProgress, newProps, instance, renderLanes)
newState = workInProgress.memoizedState
if
oldProps == newProps
and oldState == newState
and not hasContextChanged()
and not checkHasForceUpdateAfterProcessing()
then
if type(instance.componentDidMount) == "function" then
if __DEV__ and enableDoubleInvokingEffects then
workInProgress.flags =
bit32.bor(workInProgress.flags, MountLayoutDev, Update)
else
workInProgress.flags = bit32.bor(workInProgress.flags, Update)
end
end
return false
end
if
getDerivedStateFromProps ~= nil
and type(getDerivedStateFromProps) == "function"
then
applyDerivedStateFromProps(
workInProgress,
ctor,
getDerivedStateFromProps,
newProps
)
newState = workInProgress.memoizedState
end
local shouldUpdate = checkHasForceUpdateAfterProcessing()
or checkShouldComponentUpdate(
workInProgress,
ctor,
oldProps,
newProps,
oldState,
newState,
nextContext
)
if shouldUpdate then
if
not hasNewLifecycles
and (
type(instance.UNSAFE_componentWillMount) == "function"
or type(instance.componentWillMount) == "function"
)
then
if type(instance.componentWillMount) == "function" then
instance:componentWillMount()
end
if type(instance.UNSAFE_componentWillMount) == "function" then
instance:UNSAFE_componentWillMount()
end
end
if type(instance.componentDidMount) == "function" then
if __DEV__ and enableDoubleInvokingEffects then
workInProgress.flags =
bit32.bor(workInProgress.flags, MountLayoutDev, Update)
else
workInProgress.flags = bit32.bor(workInProgress.flags, Update)
end
end
else
if type(instance.componentDidMount) == "function" then
if __DEV__ and enableDoubleInvokingEffects then
workInProgress.flags =
bit32.bor(workInProgress.flags, MountLayoutDev, Update)
else
workInProgress.flags = bit32.bor(workInProgress.flags, Update)
end
end
workInProgress.memoizedProps = newProps
workInProgress.memoizedState = newState
end
instance.props = newProps
instance.state = newState
instance.context = nextContext
return shouldUpdate
end
local function updateClassInstance(
current: Fiber,
workInProgress: Fiber,
ctor: any,
newProps: any,
renderLanes: Lanes
): boolean
local instance = workInProgress.stateNode
cloneUpdateQueue(current, workInProgress)
local unresolvedOldProps = workInProgress.memoizedProps
local oldProps = if workInProgress.type == workInProgress.elementType
then unresolvedOldProps
else resolveDefaultProps(workInProgress.type, unresolvedOldProps)
instance.props = oldProps
local unresolvedNewProps = workInProgress.pendingProps
local oldContext = instance.context
local contextType
local getDerivedStateFromProps
if type(ctor) == "table" then
contextType = ctor.contextType
getDerivedStateFromProps = ctor.getDerivedStateFromProps
end
local nextContext = emptyContextObject
if type(contextType) == "table" then
nextContext = readContext(contextType)
elseif not disableLegacyContext then
local nextUnmaskedContext = getUnmaskedContext(workInProgress, ctor, true)
nextContext = getMaskedContext(workInProgress, nextUnmaskedContext)
end
local hasNewLifecycles = (
getDerivedStateFromProps ~= nil
and type(getDerivedStateFromProps) == "function"
)
or (
instance.getSnapshotBeforeUpdate ~= nil
and type(instance.getSnapshotBeforeUpdate) == "function"
)
if
not hasNewLifecycles
and (
(
instance.UNSAFE_componentWillReceiveProps ~= nil
and type(instance.UNSAFE_componentWillReceiveProps) == "function"
)
or (
instance.componentWillReceiveProps ~= nil
and type(instance.componentWillReceiveProps) == "function"
)
)
then
if unresolvedOldProps ~= unresolvedNewProps or oldContext ~= nextContext then
callComponentWillReceiveProps(workInProgress, instance, newProps, nextContext)
end
end
resetHasForceUpdateBeforeProcessing()
local oldState = workInProgress.memoizedState
instance.state = oldState
local newState = instance.state
processUpdateQueue(workInProgress, newProps, instance, renderLanes)
newState = workInProgress.memoizedState
if
unresolvedOldProps == unresolvedNewProps
and oldState == newState
and not hasContextChanged()
and not checkHasForceUpdateAfterProcessing()
then
if
instance.componentDidUpdate ~= nil
and type(instance.componentDidUpdate) == "function"
then
if
unresolvedOldProps ~= current.memoizedProps
or oldState ~= current.memoizedState
then
workInProgress.flags = bit32.bor(workInProgress.flags, Update)
end
end
if
instance.getSnapshotBeforeUpdate ~= nil
and type(instance.getSnapshotBeforeUpdate) == "function"
then
if
unresolvedOldProps ~= current.memoizedProps
or oldState ~= current.memoizedState
then
workInProgress.flags = bit32.bor(workInProgress.flags, Snapshot)
end
end
return false
end
if
getDerivedStateFromProps ~= nil
and type(getDerivedStateFromProps) == "function"
then
applyDerivedStateFromProps(
workInProgress,
ctor,
getDerivedStateFromProps,
newProps
)
newState = workInProgress.memoizedState
end
local shouldUpdate = checkHasForceUpdateAfterProcessing()
or checkShouldComponentUpdate(
workInProgress,
ctor,
oldProps,
newProps,
oldState,
newState,
nextContext
)
if shouldUpdate then
if
not hasNewLifecycles
and (
(
instance.UNSAFE_componentWillUpdate ~= nil
and type(instance.UNSAFE_componentWillUpdate) == "function"
)
or (
instance.componentWillUpdate ~= nil
and type(instance.componentWillUpdate) == "function"
)
)
then
if
instance.componentWillUpdate ~= nil
and type(instance.componentWillUpdate) == "function"
then
instance:componentWillUpdate(newProps, newState, nextContext)
end
if
instance.UNSAFE_componentWillUpdate ~= nil
and type(instance.UNSAFE_componentWillUpdate) == "function"
then
instance:UNSAFE_componentWillUpdate(newProps, newState, nextContext)
end
end
if
instance.componentDidUpdate ~= nil
and type(instance.componentDidUpdate) == "function"
then
workInProgress.flags = bit32.bor(workInProgress.flags, Update)
end
if
instance.getSnapshotBeforeUpdate ~= nil
and type(instance.getSnapshotBeforeUpdate) == "function"
then
workInProgress.flags = bit32.bor(workInProgress.flags, Snapshot)
end
else
if
instance.componentDidUpdate ~= nil
and type(instance.componentDidUpdate) == "function"
then
if
unresolvedOldProps ~= current.memoizedProps
or oldState ~= current.memoizedState
then
workInProgress.flags = bit32.bor(workInProgress.flags, Update)
end
end
if
instance.getSnapshotBeforeUpdate ~= nil
and type(instance.getSnapshotBeforeUpdate) == "function"
then
if
unresolvedOldProps ~= current.memoizedProps
or oldState ~= current.memoizedState
then
workInProgress.flags = bit32.bor(workInProgress.flags, Snapshot)
end
end
workInProgress.memoizedProps = newProps
workInProgress.memoizedState = newState
end
instance.props = newProps
instance.state = newState
instance.context = nextContext
return shouldUpdate
end
return {
adoptClassInstance = adoptClassInstance,
constructClassInstance = constructClassInstance,
mountClassInstance = mountClassInstance,
resumeMountClassInstance = resumeMountClassInstance,
updateClassInstance = updateClassInstance,
applyDerivedStateFromProps = applyDerivedStateFromProps,
emptyRefsObject = emptyRefsObject,
}
end
end)())
__register("ReactReconciler/ReactFiberCommitWork.new", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberCommitWork.new"})
return function()
local function unimplemented(message: string)
print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
print("UNIMPLEMENTED ERROR: " .. tostring(message))
error("FIXME (roblox): " .. message .. " is unimplemented", 2)
end
local runDepth = 0
local MAX_RUN_DEPTH = 20
local function isCallable(value)
if typeof(value) == "function" then
return true
end
if typeof(value) == "table" then
local mt = getmetatable(value)
if mt and rawget(mt, "__call") then
return true
end
if value._isMockFunction then
return true
end
end
return false
end
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local console = __require(Packages.Shared).console
local LuauPolyfill = __require(Packages.LuauPolyfill)
local Error = LuauPolyfill.Error
local Set = LuauPolyfill.Set
type Array<T> = { [number]: T }
local __DEV__ = ReactGlobals.__DEV__ :: boolean
local __YOLO__ = ReactGlobals.__YOLO__ :: boolean
local ReactFiberHostConfig = __require(script.Parent.ReactFiberHostConfig)
type Instance = ReactFiberHostConfig.Instance
type Container = ReactFiberHostConfig.Container
type TextInstance = ReactFiberHostConfig.TextInstance
type UpdatePayload = Array<any>
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
type FiberRoot = ReactInternalTypes.FiberRoot
local ReactFiberSuspenseComponent =
__require(script.Parent["ReactFiberSuspenseComponent.new"])
type SuspenseState = ReactFiberSuspenseComponent.SuspenseState
local ReactUpdateQueueModule = __require(script.Parent["ReactUpdateQueue.new"])
type UpdateQueue<T> = ReactInternalTypes.UpdateQueue<T>
type Effect = {
tag: HookFlags,
create: () -> (() -> ())?,
destroy: (() -> ())?,
deps: Array<any>?,
next: Effect,
}
type FunctionComponentUpdateQueue = {
lastEffect: Effect?,
}
local ReactTypes = __require(Packages.Shared)
type Wakeable = ReactTypes.Wakeable
type ReactPriorityLevel = ReactInternalTypes.ReactPriorityLevel
local ReactFiberOffscreenComponent = __require(script.Parent.ReactFiberOffscreenComponent)
type OffscreenState = ReactFiberOffscreenComponent.OffscreenState
local ReactHookEffectTags = __require(script.Parent.ReactHookEffectTags)
type HookFlags = ReactHookEffectTags.HookFlags
local Schedule_tracing_wrap = __require(Packages.Scheduler).tracing.unstable_wrap
local ReactFeatureFlags = __require(Packages.Shared).ReactFeatureFlags
local enableSchedulerTracing = ReactFeatureFlags.enableSchedulerTracing
local enableProfilerTimer = ReactFeatureFlags.enableProfilerTimer
local enableProfilerCommitHooks = ReactFeatureFlags.enableProfilerCommitHooks
local enableSuspenseCallback = ReactFeatureFlags.enableSuspenseCallback
local enableDoubleInvokingEffects = ReactFeatureFlags.enableDoubleInvokingEffects
local enableNewTreeCleanupPath = ReactFeatureFlags.enableNewTreeCleanupPath
local ReactWorkTags = __require(script.Parent.ReactWorkTags)
local FunctionComponent = ReactWorkTags.FunctionComponent
local ForwardRef = ReactWorkTags.ForwardRef
local ClassComponent = ReactWorkTags.ClassComponent
local HostRoot = ReactWorkTags.HostRoot
local HostComponent = ReactWorkTags.HostComponent
local HostText = ReactWorkTags.HostText
local HostPortal = ReactWorkTags.HostPortal
local Profiler = ReactWorkTags.Profiler
local SuspenseComponent = ReactWorkTags.SuspenseComponent
local DehydratedFragment = ReactWorkTags.DehydratedFragment
local IncompleteClassComponent = ReactWorkTags.IncompleteClassComponent
local MemoComponent = ReactWorkTags.MemoComponent
local SimpleMemoComponent = ReactWorkTags.SimpleMemoComponent
local SuspenseListComponent = ReactWorkTags.SuspenseListComponent
local FundamentalComponent = ReactWorkTags.FundamentalComponent
local ScopeComponent = ReactWorkTags.ScopeComponent
local Block = ReactWorkTags.Block
local OffscreenComponent = ReactWorkTags.OffscreenComponent
local LegacyHiddenComponent = ReactWorkTags.LegacyHiddenComponent
local ReactErrorUtils = __require(Packages.Shared).ReactErrorUtils
local invokeGuardedCallback = ReactErrorUtils.invokeGuardedCallback
local hasCaughtError = ReactErrorUtils.hasCaughtError
local clearCaughtError = ReactErrorUtils.clearCaughtError
local ReactFiberFlags = __require(script.Parent.ReactFiberFlags)
local NoFlags = ReactFiberFlags.NoFlags
local ContentReset = ReactFiberFlags.ContentReset
local Placement = ReactFiberFlags.Placement
local Snapshot = ReactFiberFlags.Snapshot
local Update = ReactFiberFlags.Update
local Callback = ReactFiberFlags.Callback
local LayoutMask = ReactFiberFlags.LayoutMask
local PassiveMask = ReactFiberFlags.PassiveMask
local Ref = ReactFiberFlags.Ref
local getComponentName = __require(Packages.Shared).getComponentName
local invariant = __require(Packages.Shared).invariant
local describeError = __require(Packages.Shared).describeError
local ReactCurrentFiber = __require(script.Parent.ReactCurrentFiber)
local currentDebugFiberInDEV = ReactCurrentFiber.current
local resetCurrentDebugFiberInDEV = ReactCurrentFiber.resetCurrentFiber
local setCurrentDebugFiberInDEV = ReactCurrentFiber.setCurrentFiber
local onCommitUnmount =
__require(script.Parent["ReactFiberDevToolsHook.new"]).onCommitUnmount
local resolveDefaultProps =
__require(script.Parent["ReactFiberLazyComponent.new"]).resolveDefaultProps
local ReactProfilerTimer = __require(script.Parent["ReactProfilerTimer.new"])
local startLayoutEffectTimer = ReactProfilerTimer.startLayoutEffectTimer
local recordPassiveEffectDuration = ReactProfilerTimer.recordPassiveEffectDuration
local recordLayoutEffectDuration = ReactProfilerTimer.recordLayoutEffectDuration
local startPassiveEffectTimer = ReactProfilerTimer.startPassiveEffectTimer
local getCommitTime = ReactProfilerTimer.getCommitTime
local ProfileMode = __require(script.Parent.ReactTypeOfMode).ProfileMode
local commitUpdateQueue = ReactUpdateQueueModule.commitUpdateQueue
local getPublicInstance = ReactFiberHostConfig.getPublicInstance
local supportsMutation = ReactFiberHostConfig.supportsMutation
local supportsPersistence = ReactFiberHostConfig.supportsPersistence
local supportsHydration = ReactFiberHostConfig.supportsHydration
local commitMount = ReactFiberHostConfig.commitMount
local commitUpdate = ReactFiberHostConfig.commitUpdate
local resetTextContent = ReactFiberHostConfig.resetTextContent
local commitTextUpdate = ReactFiberHostConfig.commitTextUpdate
local appendChild = ReactFiberHostConfig.appendChild
local appendChildToContainer = ReactFiberHostConfig.appendChildToContainer
local insertBefore = ReactFiberHostConfig.insertBefore
local insertInContainerBefore = ReactFiberHostConfig.insertInContainerBefore
local removeChild = ReactFiberHostConfig.removeChild
local removeChildFromContainer = ReactFiberHostConfig.removeChildFromContainer
local hideInstance = ReactFiberHostConfig.hideInstance
local hideTextInstance = ReactFiberHostConfig.hideTextInstance
local unhideInstance = ReactFiberHostConfig.unhideInstance
local unhideTextInstance = ReactFiberHostConfig.unhideTextInstance
local commitHydratedSuspenseInstance = ReactFiberHostConfig.commitHydratedSuspenseInstance
local clearContainer = ReactFiberHostConfig.clearContainer
local ReactFiberWorkLoop
local function resolveRetryWakeable(boundaryFiber: Fiber, wakeable: Wakeable): ()
if not ReactFiberWorkLoop then
ReactFiberWorkLoop = __require(script.Parent["ReactFiberWorkLoop.new"]) :: any
end
ReactFiberWorkLoop.resolveRetryWakeable(boundaryFiber, wakeable)
end
local function markCommitTimeOfFallback(): ()
if not ReactFiberWorkLoop then
ReactFiberWorkLoop = __require(script.Parent["ReactFiberWorkLoop.new"]) :: any
end
ReactFiberWorkLoop.markCommitTimeOfFallback()
end
local function schedulePassiveEffectCallback(): ()
console.warn(
"ReactFiberCommitWork: schedulePassiveEffectCallback causes a dependency cycle\n"
.. debug.traceback()
)
end
local function captureCommitPhaseError(
rootFiber: Fiber,
sourceFiber: Fiber | nil,
error_: any?
): ()
console.warn(
"ReactFiberCommitWork: captureCommitPhaseError causes a dependency cycle"
)
error(error_)
end
local NoHookEffect = ReactHookEffectTags.NoFlags
local HookHasEffect = ReactHookEffectTags.HasEffect
local HookLayout = ReactHookEffectTags.Layout
local HookPassive = ReactHookEffectTags.Passive
local didWarnAboutReassigningPropsRef
local didWarnAboutReassigningProps = function()
if not didWarnAboutReassigningPropsRef then
didWarnAboutReassigningPropsRef =
__require(script.Parent["ReactFiberBeginWork.new"]).didWarnAboutReassigningProps
end
return didWarnAboutReassigningPropsRef
end
type Set<T> = { [T]: boolean }
local isHostParent, getHostSibling, insertOrAppendPlacementNode, insertOrAppendPlacementNodeIntoContainer, commitLayoutEffectsForHostRoot, commitLayoutEffectsForHostComponent, commitLayoutEffectsForClassComponent, unmountHostComponents, commitNestedUnmounts, commitUnmount
local nearestProfilerOnStack: Fiber | nil = nil
local function callComponentWillUnmountWithTimer(current, instance)
instance.props = current.memoizedProps
instance.state = current.memoizedState
if
enableProfilerTimer
and enableProfilerCommitHooks
and bit32.band(current.mode, ProfileMode) ~= 0
then
local ok, exception = xpcall(function()
startLayoutEffectTimer()
instance:componentWillUnmount()
end, describeError)
recordLayoutEffectDuration(current)
if not ok then
error(exception)
end
else
instance:componentWillUnmount()
end
end
function safelyCallComponentWillUnmount(
current: Fiber,
instance: any,
nearestMountedAncestor
): ()
local ok, error_ =
xpcall(callComponentWillUnmountWithTimer, describeError, current, instance)
if not ok then
captureCommitPhaseError(current, nearestMountedAncestor, error_)
end
end
local function safelyDetachRef(current: Fiber, nearestMountedAncestor: Fiber): ()
local ref = current.ref
if ref ~= nil then
if typeof(ref) == "function" then
local ok, error_ = xpcall(ref, describeError)
if not ok then
captureCommitPhaseError(current, nearestMountedAncestor, error_)
end
else
ref.current = nil
end
end
end
local function safelyCallDestroy(
current: Fiber,
nearestMountedAncestor: Fiber | nil,
destroy: () -> ()
): ()
local ok, error_ = xpcall(destroy, describeError)
if not ok then
captureCommitPhaseError(current, nearestMountedAncestor, error_)
end
end
local function commitBeforeMutationLifeCycles(
current: Fiber | nil,
finishedWork: Fiber
): ()
if
finishedWork.tag == FunctionComponent
or finishedWork.tag == ForwardRef
or finishedWork.tag == SimpleMemoComponent
or finishedWork.tag == Block
then
return
elseif finishedWork.tag == ClassComponent then
if bit32.band(finishedWork.flags, Snapshot) ~= 0 then
if current ~= nil then
local prevProps = (current :: Fiber).memoizedProps
local prevState = (current :: Fiber).memoizedState
local instance = finishedWork.stateNode
if __DEV__ then
if
finishedWork.type == finishedWork.elementType
and not didWarnAboutReassigningProps
then
if instance.props ~= finishedWork.memoizedProps then
console.error(
"Expected %s props to match memoized props before "
.. "getSnapshotBeforeUpdate. "
.. "This might either be because of a bug in React, or because "
.. "a component reassigns its own `this.props`. "
.. "Please file an issue.",
getComponentName(finishedWork.type) or "instance"
)
end
if instance.state ~= finishedWork.memoizedState then
console.error(
"Expected %s state to match memoized state before "
.. "getSnapshotBeforeUpdate. "
.. "This might either be because of a bug in React, or because "
.. "a component reassigns its own `this.state`. "
.. "Please file an issue.",
getComponentName(finishedWork.type) or "instance"
)
end
end
end
local snapshot = instance:getSnapshotBeforeUpdate(
finishedWork.elementType == finishedWork.type and prevProps
or resolveDefaultProps(finishedWork.type, prevProps),
prevState
)
if __DEV__ then
end
instance.__reactInternalSnapshotBeforeUpdate = snapshot
end
end
return
elseif finishedWork.tag == HostRoot then
if supportsMutation then
if bit32.band(finishedWork.flags, Snapshot) ~= 0 then
local root = finishedWork.stateNode
clearContainer(root.containerInfo)
end
end
return
elseif
finishedWork.tag == HostComponent
or finishedWork.tag == HostText
or finishedWork.tag == HostPortal
or finishedWork.tag == IncompleteClassComponent
then
return
end
invariant(
false,
"This unit of work tag should not have side-effects. This error is "
.. "likely caused by a bug in React. Please file an issue."
)
end
local function commitHookEffectListUnmount(
flags: HookFlags,
finishedWork: Fiber,
nearestMountedAncestor: Fiber?
)
local updateQueue: FunctionComponentUpdateQueue | nil = finishedWork.updateQueue
local lastEffect
if updateQueue ~= nil then
lastEffect = (updateQueue :: FunctionComponentUpdateQueue).lastEffect
end
if lastEffect ~= nil then
local firstEffect = lastEffect.next
local effect = firstEffect
repeat
if bit32.band(effect.tag, flags) == flags then
local destroy = effect.destroy
effect.destroy = nil
if destroy ~= nil then
safelyCallDestroy(finishedWork, nearestMountedAncestor, destroy)
end
end
effect = effect.next
until effect == firstEffect
end
end
local function commitHookEffectListMount(flags: HookFlags, finishedWork: Fiber)
local updateQueue: FunctionComponentUpdateQueue | nil =
finishedWork.updateQueue :: any
local lastEffect = if updateQueue ~= nil then updateQueue.lastEffect else nil
if lastEffect ~= nil then
local firstEffect = lastEffect.next
local effect = firstEffect
repeat
if bit32.band(effect.tag, flags) == flags then
local create = effect.create
effect.destroy = create()
if __DEV__ then
local destroy = effect.destroy
if destroy ~= nil and typeof(destroy) ~= "function" then
local addendum
if destroy == nil then
addendum = " You returned nil. If your effect does not require clean "
.. "up, return nil (or nothing)."
elseif typeof(destroy.andThen) == "function" then
addendum =
"\n\nIt looks like you wrote useEffect(Promise.new(function() --[[...]] end) or returned a Promise. " .. "Instead, write the async function inside your effect " .. "and call it immediately:\n\n" .. "useEffect(function()\n" .. "  function fetchData()\n" .. "    -- You can await here\n" .. "    local response = MyAPI.getData(someId):await()\n" .. "    -- ...\n" .. "  end\n" .. "  fetchData()\n" .. "end, {someId}) -- Or {} if effect doesn't need props or state\n\n" .. "Learn more about data fetching with Hooks: https://reactjs.org/link/hooks-data-fetching"
else
addendum = " You returned: " .. destroy
end
console.error(
"An effect function must not return anything besides a function, "
.. "which is used for clean-up.%s",
addendum
)
end
end
end
effect = effect.next
until effect == firstEffect
end
end
function commitProfilerPassiveEffect(finishedRoot: FiberRoot, finishedWork: Fiber): ()
if enableProfilerTimer and enableProfilerCommitHooks then
if finishedWork.tag == Profiler then
local passiveEffectDuration = finishedWork.stateNode.passiveEffectDuration
local id, onPostCommit =
finishedWork.memoizedProps.id, finishedWork.memoizedProps.onPostCommit
local commitTime = getCommitTime()
if typeof(onPostCommit) == "function" then
if enableSchedulerTracing then
onPostCommit(
id,
if finishedWork.alternate == nil then "mount" else "update",
passiveEffectDuration,
commitTime,
finishedRoot.memoizedInteractions
)
else
onPostCommit(
id,
if finishedWork.alternate == nil then "mount" else "update",
passiveEffectDuration,
commitTime
)
end
end
end
end
end
local function recursivelyCommitLayoutEffects(
finishedWork: Fiber,
finishedRoot: FiberRoot,
_captureCommitPhaseError: (
sourceFiber: Fiber,
nearestMountedAncestor: Fiber?,
error: any
) -> (),
_schedulePassiveEffectCallback: () -> ()
)
if _captureCommitPhaseError ~= nil then
captureCommitPhaseError = _captureCommitPhaseError
end
if _schedulePassiveEffectCallback ~= nil then
schedulePassiveEffectCallback = _schedulePassiveEffectCallback
end
local flags = finishedWork.flags
local tag = finishedWork.tag
if tag == Profiler then
local prevProfilerOnStack = nil
if enableProfilerTimer and enableProfilerCommitHooks then
prevProfilerOnStack = nearestProfilerOnStack
nearestProfilerOnStack = finishedWork
end
local child = finishedWork.child
while child ~= nil do
local primarySubtreeFlags = bit32.band(finishedWork.subtreeFlags, LayoutMask)
if primarySubtreeFlags ~= NoFlags then
if __DEV__ then
local prevCurrentFiberInDEV = currentDebugFiberInDEV
setCurrentDebugFiberInDEV(child)
invokeGuardedCallback(
nil,
recursivelyCommitLayoutEffects,
nil,
child,
finishedRoot,
captureCommitPhaseError,
schedulePassiveEffectCallback
)
if hasCaughtError() then
local error_ = clearCaughtError()
captureCommitPhaseError(child, finishedWork, error_)
end
if prevCurrentFiberInDEV ~= nil then
setCurrentDebugFiberInDEV(prevCurrentFiberInDEV)
else
resetCurrentDebugFiberInDEV()
end
else
local ok, error_ = xpcall(
recursivelyCommitLayoutEffects,
describeError,
child,
finishedRoot,
captureCommitPhaseError,
schedulePassiveEffectCallback
)
if not ok then
captureCommitPhaseError(child, finishedWork, error_)
end
end
end
child = child.sibling
end
local primaryFlags = bit32.band(flags, bit32.bor(Update, Callback))
if primaryFlags ~= NoFlags then
if enableProfilerTimer then
if __DEV__ then
local prevCurrentFiberInDEV = currentDebugFiberInDEV
setCurrentDebugFiberInDEV(finishedWork)
invokeGuardedCallback(
nil,
commitLayoutEffectsForProfiler,
nil,
finishedWork,
finishedRoot
)
if hasCaughtError() then
local error_ = clearCaughtError()
captureCommitPhaseError(
finishedWork,
finishedWork.return_,
error_
)
end
if prevCurrentFiberInDEV ~= nil then
setCurrentDebugFiberInDEV(prevCurrentFiberInDEV)
else
resetCurrentDebugFiberInDEV()
end
else
local ok, error_ = xpcall(
commitLayoutEffectsForProfiler,
describeError,
finishedWork,
finishedRoot
)
if not ok then
captureCommitPhaseError(
finishedWork,
finishedWork.return_,
error_
)
end
end
end
end
if enableProfilerTimer and enableProfilerCommitHooks then
if prevProfilerOnStack ~= nil then
prevProfilerOnStack.stateNode.effectDuration += finishedWork.stateNode.effectDuration
end
nearestProfilerOnStack = prevProfilerOnStack
end
else
local child = finishedWork.child
while child ~= nil do
local primarySubtreeFlags = bit32.band(finishedWork.subtreeFlags, LayoutMask)
if primarySubtreeFlags ~= NoFlags then
if __DEV__ then
local prevCurrentFiberInDEV = ReactCurrentFiber.current
setCurrentDebugFiberInDEV(child)
if runDepth < MAX_RUN_DEPTH then
runDepth += 1
invokeGuardedCallback(
nil,
recursivelyCommitLayoutEffects,
nil,
child,
finishedRoot,
captureCommitPhaseError,
schedulePassiveEffectCallback
)
runDepth -= 1
if hasCaughtError() then
local error_ = clearCaughtError()
captureCommitPhaseError(child, finishedWork, error_)
end
else
recursivelyCommitLayoutEffects(
child,
finishedRoot,
captureCommitPhaseError,
schedulePassiveEffectCallback
)
end
if prevCurrentFiberInDEV ~= nil then
setCurrentDebugFiberInDEV(prevCurrentFiberInDEV)
else
resetCurrentDebugFiberInDEV()
end
else
local ok, error_
if not __YOLO__ and runDepth < MAX_RUN_DEPTH then
runDepth += 1
ok, error_ = xpcall(
recursivelyCommitLayoutEffects,
describeError,
child,
finishedRoot,
captureCommitPhaseError,
schedulePassiveEffectCallback
)
runDepth -= 1
else
ok = true
recursivelyCommitLayoutEffects(
child,
finishedRoot,
captureCommitPhaseError,
schedulePassiveEffectCallback
)
end
if not ok then
captureCommitPhaseError(child, finishedWork, error_)
end
end
end
child = child.sibling
end
local primaryFlags = bit32.band(flags, bit32.bor(Update, Callback))
if primaryFlags ~= NoFlags then
if
tag == FunctionComponent
or tag == ForwardRef
or tag == SimpleMemoComponent
or tag == Block
then
if
enableProfilerTimer
and enableProfilerCommitHooks
and bit32.band(finishedWork.mode, ProfileMode) ~= 0
then
local ok, error_ = xpcall(function()
startLayoutEffectTimer()
commitHookEffectListMount(
bit32.bor(HookLayout, HookHasEffect),
finishedWork
)
end, describeError)
recordLayoutEffectDuration(finishedWork)
if not ok then
error(error_)
end
else
commitHookEffectListMount(
bit32.bor(HookLayout, HookHasEffect),
finishedWork
)
end
if bit32.band(finishedWork.subtreeFlags, PassiveMask) ~= NoFlags then
schedulePassiveEffectCallback()
end
elseif tag == ClassComponent then
commitLayoutEffectsForClassComponent(finishedWork)
elseif tag == HostRoot then
commitLayoutEffectsForHostRoot(finishedWork)
elseif tag == HostComponent then
commitLayoutEffectsForHostComponent(finishedWork)
elseif tag == SuspenseComponent then
commitSuspenseHydrationCallbacks(finishedRoot, finishedWork)
elseif
tag == FundamentalComponent
or tag == HostPortal
or tag == HostText
or tag == IncompleteClassComponent
or tag == LegacyHiddenComponent
or tag == OffscreenComponent
or tag == ScopeComponent
or tag == SuspenseListComponent
then
else
invariant(
false,
"This unit of work tag should not have side-effects. This error is "
.. "likely caused by a bug in React. Please file an issue."
)
end
end
if bit32.band(flags, Ref) ~= 0 then
commitAttachRef(finishedWork)
end
end
end
function commitLayoutEffectsForProfiler(finishedWork: Fiber, finishedRoot: FiberRoot)
if enableProfilerTimer then
local flags = finishedWork.flags
local current = finishedWork.alternate
local onCommit, onRender =
finishedWork.memoizedProps.onCommit, finishedWork.memoizedProps.onRender
local effectDuration = finishedWork.stateNode.effectDuration
local commitTime = getCommitTime()
local OnRenderFlag = Update
local OnCommitFlag = Callback
if
bit32.band(flags, OnRenderFlag) ~= NoFlags
and isCallable(onRender)
then
if enableSchedulerTracing then
onRender(
finishedWork.memoizedProps.id,
if current == nil then "mount" else "update",
finishedWork.actualDuration,
finishedWork.treeBaseDuration,
finishedWork.actualStartTime,
commitTime,
finishedRoot.memoizedInteractions
)
else
onRender(
finishedWork.memoizedProps.id,
if current == nil then "mount" else "update",
finishedWork.actualDuration,
finishedWork.treeBaseDuration,
finishedWork.actualStartTime,
commitTime
)
end
end
if enableProfilerCommitHooks then
if
bit32.band(flags, OnCommitFlag) ~= NoFlags
and isCallable(onCommit)
then
if enableSchedulerTracing then
onCommit(
finishedWork.memoizedProps.id,
if current == nil then "mount" else "update",
effectDuration,
commitTime,
finishedRoot.memoizedInteractions
)
else
onCommit(
finishedWork.memoizedProps.id,
if current == nil then "mount" else "update",
effectDuration,
commitTime
)
end
end
end
end
end
function commitLayoutEffectsForClassComponent(finishedWork: Fiber)
local instance = finishedWork.stateNode
local current = finishedWork.alternate
if bit32.band(finishedWork.flags, Update) ~= 0 then
if current == nil then
if __DEV__ then
if
finishedWork.type == finishedWork.elementType
and not didWarnAboutReassigningProps
then
if instance.props ~= finishedWork.memoizedProps then
console.error(
"Expected %s props to match memoized props before "
.. "componentDidMount. "
.. "This might either be because of a bug in React, or because "
.. "a component reassigns its own `this.props`. "
.. "Please file an issue.",
getComponentName(finishedWork.type) or "instance"
)
end
if instance.state ~= finishedWork.memoizedState then
console.error(
"Expected %s state to match memoized state before "
.. "componentDidMount. "
.. "This might either be because of a bug in React, or because "
.. "a component reassigns its own `this.state`. "
.. "Please file an issue.",
getComponentName(finishedWork.type) or "instance"
)
end
end
end
if
enableProfilerTimer
and enableProfilerCommitHooks
and bit32.band(finishedWork.mode, ProfileMode) ~= 0
then
local ok, result = xpcall(function()
startLayoutEffectTimer()
instance:componentDidMount()
end, describeError)
recordLayoutEffectDuration(finishedWork)
if not ok then
error(result)
end
else
instance:componentDidMount()
end
else
local prevProps = finishedWork.elementType == finishedWork.type
and current.memoizedProps
or resolveDefaultProps(finishedWork.type, current.memoizedProps)
local prevState = current.memoizedState
if __DEV__ then
if
finishedWork.type == finishedWork.elementType
and not didWarnAboutReassigningProps
then
if instance.props ~= finishedWork.memoizedProps then
console.error(
"Expected %s props to match memoized props before "
.. "componentDidUpdate. "
.. "This might either be because of a bug in React, or because "
.. "a component reassigns its own `this.props`. "
.. "Please file an issue.",
getComponentName(finishedWork.type) or "instance"
)
end
if instance.state ~= finishedWork.memoizedState then
console.error(
"Expected %s state to match memoized state before "
.. "componentDidUpdate. "
.. "This might either be because of a bug in React, or because "
.. "a component reassigns its own `this.state`. "
.. "Please file an issue.",
getComponentName(finishedWork.type) or "instance"
)
end
end
end
if
enableProfilerTimer
and enableProfilerCommitHooks
and bit32.band(finishedWork.mode, ProfileMode) ~= 0
then
local ok, result = xpcall(function()
startLayoutEffectTimer()
instance:componentDidUpdate(
prevProps,
prevState,
instance.__reactInternalSnapshotBeforeUpdate
)
end, describeError)
recordLayoutEffectDuration(finishedWork)
if not ok then
error(result)
end
else
instance:componentDidUpdate(
prevProps,
prevState,
instance.__reactInternalSnapshotBeforeUpdate
)
end
end
end
local updateQueue: UpdateQueue<any> | nil = finishedWork.updateQueue
if updateQueue ~= nil then
if __DEV__ then
if
finishedWork.type == finishedWork.elementType
and not didWarnAboutReassigningProps
then
if instance.props ~= finishedWork.memoizedProps then
console.error(
"Expected %s props to match memoized props before "
.. "processing the update queue. "
.. "This might either be because of a bug in React, or because "
.. "a component reassigns its own `this.props`. "
.. "Please file an issue.",
getComponentName(finishedWork.type) or "instance"
)
end
if instance.state ~= finishedWork.memoizedState then
console.error(
"Expected %s state to match memoized state before "
.. "processing the update queue. "
.. "This might either be because of a bug in React, or because "
.. "a component reassigns its own `this.state`. "
.. "Please file an issue.",
getComponentName(finishedWork.type) or "instance"
)
end
end
end
commitUpdateQueue(finishedWork, updateQueue, instance)
end
end
function commitLayoutEffectsForHostRoot(finishedWork: Fiber)
local updateQueue: UpdateQueue<any> | nil = finishedWork.updateQueue
if updateQueue ~= nil then
local instance = nil
if finishedWork.child ~= nil then
local child = finishedWork.child
if child.tag == HostComponent then
instance = getPublicInstance(child.stateNode)
elseif child.tag == ClassComponent then
instance = child.stateNode
end
end
commitUpdateQueue(finishedWork, updateQueue, instance)
end
end
function commitLayoutEffectsForHostComponent(finishedWork: Fiber)
local instance: Instance = finishedWork.stateNode
local current = finishedWork.alternate
if current == nil and bit32.band(finishedWork.flags, Update) ~= 0 then
local type = finishedWork.type
local props = finishedWork.memoizedProps
commitMount(instance, type, props, finishedWork)
end
end
local function hideOrUnhideAllChildren(finishedWork, isHidden)
if supportsMutation then
local node: Fiber = finishedWork
while true do
if node.tag == HostComponent then
local instance = node.stateNode
if isHidden then
hideInstance(instance)
else
unhideInstance(node.stateNode, node.memoizedProps)
end
elseif node.tag == HostText then
local instance = node.stateNode
if isHidden then
hideTextInstance(instance)
else
unhideTextInstance(instance, node.memoizedProps)
end
elseif
(node.tag == OffscreenComponent or node.tag == LegacyHiddenComponent)
and (node.memoizedState :: OffscreenState) ~= nil
and node ~= finishedWork
then
elseif node.child ~= nil then
(node.child :: Fiber).return_ = node
node = node.child :: Fiber
continue
end
if node == finishedWork then
return
end
while node.sibling == nil do
if node.return_ == nil or node.return_ == finishedWork then
return
end
node = node.return_ :: Fiber
end
(node.sibling :: Fiber).return_ = node.return_
node = node.sibling :: Fiber
end
end
end
function commitAttachRef(finishedWork: Fiber)
local ref = finishedWork.ref
if ref ~= nil then
local instance = finishedWork.stateNode
local instanceToUse
if finishedWork.tag == HostComponent then
instanceToUse = getPublicInstance(instance)
else
instanceToUse = instance
end
if typeof(ref) == "function" then
ref(instanceToUse)
else
if __DEV__ then
if typeof(ref) ~= "table" then
console.error(
"Unexpected ref object provided for %s. "
.. "Use either a ref-setter function or React.createRef().",
getComponentName(finishedWork.type) or "instance"
)
return
end
end
ref.current = instanceToUse
end
end
end
function commitDetachRef(current: Fiber)
local currentRef = current.ref
if currentRef ~= nil then
if typeof(currentRef) == "function" then
currentRef(nil)
else
currentRef.current = nil
end
end
end
function commitUnmount(
finishedRoot: FiberRoot,
current: Fiber,
nearestMountedAncestor: Fiber,
renderPriorityLevel: ReactPriorityLevel
): ()
onCommitUnmount(current)
if
current.tag == FunctionComponent
or current.tag == ForwardRef
or current.tag == MemoComponent
or current.tag == SimpleMemoComponent
or current.tag == Block
then
local updateQueue: FunctionComponentUpdateQueue | nil = current.updateQueue
if updateQueue ~= nil then
local lastEffect = (updateQueue :: FunctionComponentUpdateQueue).lastEffect
if lastEffect ~= nil then
local firstEffect = lastEffect.next
local effect = firstEffect
repeat
if effect.destroy ~= nil then
if bit32.band(effect.tag, HookLayout) ~= NoHookEffect then
if
enableProfilerTimer
and enableProfilerCommitHooks
and bit32.band(current.mode, ProfileMode) ~= 0
then
startLayoutEffectTimer()
safelyCallDestroy(
current,
nearestMountedAncestor,
effect.destroy
)
recordLayoutEffectDuration(current)
else
safelyCallDestroy(
current,
nearestMountedAncestor,
effect.destroy
)
end
end
end
effect = effect.next
until effect == firstEffect
end
end
return
elseif current.tag == ClassComponent then
safelyDetachRef(current, nearestMountedAncestor)
local instance = current.stateNode
if typeof(instance.componentWillUnmount) == "function" then
safelyCallComponentWillUnmount(current, instance, nearestMountedAncestor)
end
return
elseif current.tag == HostComponent then
safelyDetachRef(current, nearestMountedAncestor)
return
elseif current.tag == HostPortal then
if supportsMutation then
unmountHostComponents(
finishedRoot,
current,
nearestMountedAncestor,
renderPriorityLevel
)
elseif supportsPersistence then
unimplemented("emptyPortalContainer")
end
return
end
end
function commitNestedUnmounts(
finishedRoot: FiberRoot,
root: Fiber,
nearestMountedAncestor: Fiber,
renderPriorityLevel: ReactPriorityLevel
)
local node: Fiber = root
while true do
commitUnmount(finishedRoot, node, nearestMountedAncestor, renderPriorityLevel)
if
node.child ~= nil
and (not supportsMutation or node.tag ~= HostPortal)
then
(node.child :: Fiber).return_ = node
node = node.child :: Fiber
continue
end
if node == root then
return
end
while node.sibling == nil do
if node.return_ == nil or node.return_ == root then
return
end
node = node.return_ :: Fiber
end
(node.sibling :: Fiber).return_ = node.return_
node = node.sibling :: Fiber
end
end
local function detachFiberMutation(fiber: Fiber)
local alternate = fiber.alternate
if alternate ~= nil then
alternate.return_ = nil
if not enableNewTreeCleanupPath then
fiber.alternate = nil
end
end
fiber.return_ = nil
end
local function getHostParentFiber(fiber: Fiber): Fiber
local parent = fiber.return_
while parent ~= nil do
if isHostParent(parent) then
return parent
end
parent = parent.return_
end
error(
Error.new(
"Expected to find a host parent. This error is likely caused by a bug "
.. "in React. Please file an issue."
)
)
end
function isHostParent(fiber: Fiber): boolean
return fiber.tag == HostComponent or fiber.tag == HostRoot or fiber.tag == HostPortal
end
function getHostSibling(fiber: Fiber): Instance?
local node: Fiber = fiber
while true do
local continueOuter = false
while node.sibling == nil do
if node.return_ == nil or isHostParent(node.return_) then
return nil
end
node = node.return_ :: Fiber
end
(node.sibling :: Fiber).return_ = node.return_ :: Fiber
node = node.sibling :: Fiber
while
node.tag ~= HostComponent
and node.tag ~= HostText
and node.tag ~= DehydratedFragment
do
if bit32.band(node.flags, Placement) ~= 0 then
continueOuter = true
break
end
if node.child == nil or node.tag == HostPortal then
continueOuter = true
break
else
(node.child :: Fiber).return_ = node
node = node.child :: Fiber
end
end
if continueOuter then
continue
end
if bit32.band(node.flags, Placement) == 0 then
return node.stateNode
end
end
end
local function commitPlacement(finishedWork: Fiber)
if not supportsMutation then
return
end
local parentFiber = getHostParentFiber(finishedWork)
local parent
local isContainer
local parentStateNode = parentFiber.stateNode
if parentFiber.tag == HostComponent then
parent = parentStateNode
isContainer = false
elseif parentFiber.tag == HostRoot then
parent = parentStateNode.containerInfo
isContainer = true
elseif parentFiber.tag == HostPortal then
parent = parentStateNode.containerInfo
isContainer = true
else
invariant(
false,
"Invalid host parent fiber. This error is likely caused by a bug "
.. "in React. Please file an issue."
)
end
if bit32.band(parentFiber.flags, ContentReset) ~= 0 then
resetTextContent(parent)
parentFiber.flags = bit32.band(parentFiber.flags, bit32.bnot(ContentReset))
end
local before = getHostSibling(finishedWork)
if isContainer then
insertOrAppendPlacementNodeIntoContainer(finishedWork, before, parent)
else
insertOrAppendPlacementNode(finishedWork, before, parent)
end
end
function insertOrAppendPlacementNodeIntoContainer(
node: Fiber,
before: Instance?,
parent: Container
)
local tag = node.tag
local isHost = tag == HostComponent or tag == HostText
if isHost then
local stateNode = node.stateNode
if before then
insertInContainerBefore(parent, stateNode, before)
else
appendChildToContainer(parent, stateNode)
end
elseif tag == HostPortal then
else
local child = node.child
if child ~= nil then
insertOrAppendPlacementNodeIntoContainer(child, before, parent)
local sibling = child.sibling
while sibling ~= nil do
insertOrAppendPlacementNodeIntoContainer(sibling, before, parent)
sibling = sibling.sibling
end
end
end
end
function insertOrAppendPlacementNode(node: Fiber, before: Instance?, parent: Instance): ()
local tag = node.tag
local isHost = tag == HostComponent or tag == HostText
if isHost then
local stateNode = node.stateNode
if before then
insertBefore(parent, stateNode, before)
else
appendChild(parent, stateNode)
end
elseif tag == HostPortal then
else
local child = node.child
if child ~= nil then
insertOrAppendPlacementNode(child, before, parent)
local sibling = child.sibling
while sibling ~= nil do
insertOrAppendPlacementNode(sibling, before, parent)
sibling = sibling.sibling
end
end
end
end
function unmountHostComponents(
finishedRoot: FiberRoot,
current: Fiber,
nearestMountedAncestor: Fiber,
renderPriorityLevel: ReactPriorityLevel
): ()
local node: Fiber = current
local currentParentIsValid = false
local currentParent
local currentParentIsContainer
while true do
if not currentParentIsValid then
local parent = node.return_ :: Fiber
while true do
if parent == nil then
error(
Error.new(
"Expected to find a host parent. This error is likely caused by "
.. "a bug in React. Please file an issue."
)
)
end
local parentStateNode = parent.stateNode
if parent.tag == HostComponent then
currentParent = parentStateNode
currentParentIsContainer = false
break
elseif parent.tag == HostRoot then
currentParent = parentStateNode.containerInfo
currentParentIsContainer = true
break
elseif parent.tag == HostPortal then
currentParent = parentStateNode.containerInfo
currentParentIsContainer = true
break
end
parent = parent.return_ :: Fiber
end
currentParentIsValid = true
end
if node.tag == HostComponent or node.tag == HostText then
commitNestedUnmounts(
finishedRoot,
node,
nearestMountedAncestor,
renderPriorityLevel
)
if currentParentIsContainer then
removeChildFromContainer(currentParent, node.stateNode)
else
removeChild(currentParent, node.stateNode)
end
elseif node.tag == HostPortal then
if node.child ~= nil then
currentParent = node.stateNode.containerInfo
currentParentIsContainer = true
node.child.return_ = node
node = node.child
continue
end
else
commitUnmount(finishedRoot, node, nearestMountedAncestor, renderPriorityLevel)
if node.child ~= nil then
node.child.return_ = node
node = node.child
continue
end
end
if node == current then
return
end
while node.sibling == nil do
if node.return_ == nil or node.return_ == current then
return
end
node = node.return_ :: Fiber
if node.tag == HostPortal then
currentParentIsValid = false
end
end
(node.sibling :: Fiber).return_ = node.return_
node = node.sibling :: Fiber
end
end
local function commitDeletion(
finishedRoot: FiberRoot,
current: Fiber,
nearestMountedAncestor: Fiber,
renderPriorityLevel: ReactPriorityLevel
): ()
unmountHostComponents(
finishedRoot,
current,
nearestMountedAncestor,
renderPriorityLevel
)
local alternate
if not enableNewTreeCleanupPath then
alternate = current.alternate
end
detachFiberMutation(current)
if not enableNewTreeCleanupPath and alternate ~= nil then
detachFiberMutation(alternate)
end
end
local function commitWork(current: Fiber | nil, finishedWork: Fiber)
if
finishedWork.tag == FunctionComponent
or finishedWork.tag == ForwardRef
or finishedWork.tag == MemoComponent
or finishedWork.tag == SimpleMemoComponent
or finishedWork.tag == Block
then
if
enableProfilerTimer
and enableProfilerCommitHooks
and bit32.band(finishedWork.mode, ProfileMode) ~= 0
then
local ok, result = xpcall(function()
startLayoutEffectTimer()
commitHookEffectListUnmount(
bit32.bor(HookLayout, HookHasEffect),
finishedWork,
finishedWork.return_
)
end, describeError)
recordLayoutEffectDuration(finishedWork)
if not ok then
error(result)
end
else
commitHookEffectListUnmount(
bit32.bor(HookLayout, HookHasEffect),
finishedWork,
finishedWork.return_
)
end
return
elseif finishedWork.tag == ClassComponent then
return
elseif finishedWork.tag == HostComponent then
local instance: Instance = finishedWork.stateNode
if instance ~= nil then
local newProps = finishedWork.memoizedProps
local oldProps
if current then
oldProps = current.memoizedProps
else
oldProps = newProps
end
local type = finishedWork.type
local updatePayload: nil | UpdatePayload = finishedWork.updateQueue :: any
finishedWork.updateQueue = nil
if updatePayload ~= nil then
commitUpdate(
instance,
updatePayload,
type,
oldProps,
newProps,
finishedWork
)
end
end
return
elseif finishedWork.tag == HostText then
invariant(
finishedWork.stateNode ~= nil,
"This should have a text node initialized. This error is likely "
.. "caused by a bug in React. Please file an issue."
)
local textInstance: TextInstance = finishedWork.stateNode
local newText: string = finishedWork.memoizedProps
local oldText: string
if current ~= nil then
oldText = (current :: Fiber).memoizedProps
oldText = newText
end
commitTextUpdate(textInstance, oldText, newText)
return
elseif finishedWork.tag == HostRoot then
if supportsHydration then
local root: FiberRoot = finishedWork.stateNode
if root.hydrate then
root.hydrate = false
unimplemented("commitWork: HostRoot: commitHydratedContainer")
end
end
return
elseif finishedWork.tag == Profiler then
return
elseif finishedWork.tag == SuspenseComponent then
commitSuspenseComponent(finishedWork)
attachSuspenseRetryListeners(finishedWork)
return
elseif finishedWork.tag == SuspenseListComponent then
unimplemented("commitWork: SuspenseListComponent")
elseif finishedWork.tag == IncompleteClassComponent then
return
elseif
finishedWork.tag == OffscreenComponent
or finishedWork.tag == LegacyHiddenComponent
then
local newState: OffscreenState | nil = finishedWork.memoizedState
local isHidden = newState ~= nil
hideOrUnhideAllChildren(finishedWork, isHidden)
return
end
invariant(
false,
"This unit of work tag should not have side-effects. This error is "
.. "likely caused by a bug in React. Please file an issue."
)
end
function commitSuspenseComponent(finishedWork: Fiber)
local newState: SuspenseState | nil = finishedWork.memoizedState
if newState ~= nil then
markCommitTimeOfFallback()
if supportsMutation then
local primaryChildParent: Fiber = finishedWork.child :: any
hideOrUnhideAllChildren(primaryChildParent, true)
end
end
if enableSuspenseCallback and newState ~= nil then
local suspenseCallback = finishedWork.memoizedProps.suspenseCallback
if typeof(suspenseCallback) == "function" then
local wakeables: Set<Wakeable> | nil = finishedWork.updateQueue :: any
if wakeables ~= nil then
suspenseCallback(table.clone(wakeables))
end
elseif __DEV__ then
if suspenseCallback ~= nil then
console.error(
"Unexpected type for suspenseCallback: %s",
tostring(suspenseCallback)
)
end
end
end
end
function commitSuspenseHydrationCallbacks(finishedRoot: FiberRoot, finishedWork: Fiber)
if not supportsHydration then
return
end
local newState: SuspenseState | nil = finishedWork.memoizedState
if newState == nil then
local current = finishedWork.alternate
if current ~= nil then
local prevState: SuspenseState | nil = current.memoizedState
if prevState ~= nil then
local suspenseInstance = prevState.dehydrated
if suspenseInstance ~= nil then
commitHydratedSuspenseInstance(suspenseInstance)
if enableSuspenseCallback then
local hydrationCallbacks = finishedRoot.hydrationCallbacks
if hydrationCallbacks ~= nil then
local onHydrated = hydrationCallbacks.onHydrated
if onHydrated then
onHydrated(suspenseInstance)
end
end
end
end
end
end
end
end
function attachSuspenseRetryListeners(finishedWork: Fiber)
local wakeables: Set<Wakeable> | nil = finishedWork.updateQueue :: any
if wakeables ~= nil then
finishedWork.updateQueue = nil
local retryCache = finishedWork.stateNode
if retryCache == nil then
finishedWork.stateNode = Set.new()
retryCache = finishedWork.stateNode
end
for wakeable, _ in wakeables :: Set<Wakeable> do
local retry = function()
return resolveRetryWakeable(finishedWork, wakeable)
end
if not retryCache:has(wakeable) then
if enableSchedulerTracing then
if wakeable.__reactDoNotTraceInteractions ~= true then
retry = Schedule_tracing_wrap(retry)
end
end
retryCache:add(wakeable)
wakeable:andThen(function()
return retry()
end, function()
return retry()
end)
end
end
end
end
function isSuspenseBoundaryBeingHidden(current: Fiber | nil, finishedWork: Fiber): boolean
if current ~= nil then
local oldState: SuspenseState | nil = (current :: Fiber).memoizedState
if oldState == nil or (oldState :: SuspenseState).dehydrated ~= nil then
local newState: SuspenseState | nil = finishedWork.memoizedState
return newState ~= nil and (newState :: SuspenseState).dehydrated == nil
end
end
return false
end
function commitResetTextContent(current: Fiber): ()
if not supportsMutation then
return
end
resetTextContent(current.stateNode)
end
local function commitPassiveUnmount(finishedWork: Fiber): ()
if
finishedWork.tag == FunctionComponent
or finishedWork.tag == ForwardRef
or finishedWork.tag == SimpleMemoComponent
or finishedWork.tag == Block
then
if
enableProfilerTimer
and enableProfilerCommitHooks
and bit32.band(finishedWork.mode, ProfileMode) ~= 0
then
startPassiveEffectTimer()
commitHookEffectListUnmount(
bit32.bor(HookPassive, HookHasEffect),
finishedWork,
finishedWork.return_
)
recordPassiveEffectDuration(finishedWork)
else
commitHookEffectListUnmount(
bit32.bor(HookPassive, HookHasEffect),
finishedWork,
finishedWork.return_
)
end
end
end
local function commitPassiveUnmountInsideDeletedTree(
current: Fiber,
nearestMountedAncestor: Fiber | nil
): ()
if
current.tag == FunctionComponent
or current.tag == ForwardRef
or current.tag == SimpleMemoComponent
or current.tag == Block
then
if
enableProfilerTimer
and enableProfilerCommitHooks
and bit32.band(current.mode, ProfileMode) ~= 0
then
startPassiveEffectTimer()
commitHookEffectListUnmount(HookPassive, current, nearestMountedAncestor)
recordPassiveEffectDuration(current)
else
commitHookEffectListUnmount(HookPassive, current, nearestMountedAncestor)
end
end
end
local function commitPassiveMount(finishedRoot: FiberRoot, finishedWork: Fiber): ()
if
finishedWork.tag == FunctionComponent
or finishedWork.tag == ForwardRef
or finishedWork.tag == SimpleMemoComponent
or finishedWork.tag == Block
then
if
enableProfilerTimer
and enableProfilerCommitHooks
and bit32.band(finishedWork.mode, ProfileMode) ~= 0
then
startPassiveEffectTimer()
local ok, error_ = xpcall(
commitHookEffectListMount,
describeError,
bit32.bor(HookPassive, HookHasEffect),
finishedWork
)
recordPassiveEffectDuration(finishedWork)
if not ok then
error(error_)
end
else
commitHookEffectListMount(bit32.bor(HookPassive, HookHasEffect), finishedWork)
end
elseif finishedWork.tag == Profiler then
commitProfilerPassiveEffect(finishedRoot, finishedWork)
end
end
function invokeLayoutEffectMountInDEV(fiber: Fiber): ()
if __DEV__ and enableDoubleInvokingEffects then
if
fiber.tag == FunctionComponent
or fiber.tag == ForwardRef
or fiber.tag == SimpleMemoComponent
or fiber.tag == Block
then
invokeGuardedCallback(
nil,
commitHookEffectListMount,
nil,
bit32.bor(HookLayout, HookHasEffect),
fiber
)
if hasCaughtError() then
local mountError = clearCaughtError()
captureCommitPhaseError(fiber, fiber.return_, mountError)
end
return
end
elseif fiber.tag == ClassComponent then
local instance = fiber.stateNode
invokeGuardedCallback(nil, instance.componentDidMount, instance)
if hasCaughtError() then
local mountError = clearCaughtError()
captureCommitPhaseError(fiber, fiber.return_, mountError)
end
return
end
end
function invokePassiveEffectMountInDEV(fiber: Fiber): ()
if __DEV__ and enableDoubleInvokingEffects then
if
fiber.tag == FunctionComponent
or fiber.tag == ForwardRef
or fiber.tag == SimpleMemoComponent
or fiber.tag == Block
then
invokeGuardedCallback(
nil,
commitHookEffectListMount,
nil,
bit32.bor(HookPassive, HookHasEffect),
fiber
)
if hasCaughtError() then
local mountError = clearCaughtError()
captureCommitPhaseError(fiber, fiber.return_, mountError)
end
return
end
end
end
function invokeLayoutEffectUnmountInDEV(fiber: Fiber): ()
if __DEV__ and enableDoubleInvokingEffects then
if
fiber.tag == FunctionComponent
or fiber.tag == ForwardRef
or fiber.tag == SimpleMemoComponent
or fiber.tag == Block
then
invokeGuardedCallback(
nil,
commitHookEffectListUnmount,
nil,
bit32.bor(HookLayout, HookHasEffect),
fiber,
fiber.return_
)
if hasCaughtError() then
local unmountError = clearCaughtError()
captureCommitPhaseError(fiber, fiber.return_, unmountError)
end
return
end
elseif fiber.tag == ClassComponent then
local instance = fiber.stateNode
if typeof(instance.componentWillUnmount) == "function" then
safelyCallComponentWillUnmount(fiber, instance, fiber.return_)
end
return
end
end
function invokePassiveEffectUnmountInDEV(fiber: Fiber): ()
if __DEV__ and enableDoubleInvokingEffects then
if
fiber.tag == FunctionComponent
or fiber.tag == ForwardRef
or fiber.tag == SimpleMemoComponent
or fiber.tag == Block
then
invokeGuardedCallback(
nil,
commitHookEffectListUnmount,
nil,
bit32.bor(HookPassive, HookHasEffect),
fiber,
fiber.return_
)
if hasCaughtError() then
local unmountError = clearCaughtError()
captureCommitPhaseError(fiber, fiber.return_, unmountError)
end
return
end
end
end
return {
safelyCallDestroy = safelyCallDestroy,
commitBeforeMutationLifeCycles = commitBeforeMutationLifeCycles,
commitResetTextContent = commitResetTextContent,
commitPlacement = commitPlacement,
commitDeletion = commitDeletion,
commitWork = commitWork,
commitAttachRef = commitAttachRef,
commitDetachRef = commitDetachRef,
commitPassiveUnmount = commitPassiveUnmount,
commitPassiveUnmountInsideDeletedTree = commitPassiveUnmountInsideDeletedTree,
commitPassiveMount = commitPassiveMount,
invokeLayoutEffectMountInDEV = invokeLayoutEffectMountInDEV,
invokeLayoutEffectUnmountInDEV = invokeLayoutEffectUnmountInDEV,
invokePassiveEffectMountInDEV = invokePassiveEffectMountInDEV,
invokePassiveEffectUnmountInDEV = invokePassiveEffectUnmountInDEV,
isSuspenseBoundaryBeingHidden = isSuspenseBoundaryBeingHidden,
recursivelyCommitLayoutEffects = recursivelyCommitLayoutEffects,
}
end
end)())
__register("ReactReconciler/ReactFiberCompleteWork.new", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberCompleteWork.new"})
return function()
local function unimplemented(message: string)
print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
print("UNIMPLEMENTED ERROR: " .. tostring(message))
error("FIXME (roblox): " .. message .. " is unimplemented", 2)
end
local Packages = script.Parent.Parent
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
local ReactFiberLane = __require(script.Parent.ReactFiberLane)
type Lanes = ReactFiberLane.Lanes
type Lane = ReactFiberLane.Lane
local OffscreenLane = ReactFiberLane.OffscreenLane
local ReactFiberHostConfig = __require(script.Parent.ReactFiberHostConfig)
type Instance = ReactFiberHostConfig.Instance
type Type = ReactFiberHostConfig.Type
type Props = ReactFiberHostConfig.Props
type Container = ReactFiberHostConfig.Container
type ChildSet = ReactFiberHostConfig.ChildSet
local ReactFiberOffscreenComponent = __require(script.Parent.ReactFiberOffscreenComponent)
type OffscreenState = ReactFiberOffscreenComponent.OffscreenState
local ReactMutableSource = __require(script.Parent["ReactMutableSource.new"])
local resetMutableSourceWorkInProgressVersions =
ReactMutableSource.resetWorkInProgressVersions
local ReactWorkTags = __require(script.Parent.ReactWorkTags)
local IndeterminateComponent = ReactWorkTags.IndeterminateComponent
local FunctionComponent = ReactWorkTags.FunctionComponent
local ClassComponent = ReactWorkTags.ClassComponent
local HostRoot = ReactWorkTags.HostRoot
local HostComponent = ReactWorkTags.HostComponent
local HostText = ReactWorkTags.HostText
local HostPortal = ReactWorkTags.HostPortal
local ContextProvider = ReactWorkTags.ContextProvider
local ContextConsumer = ReactWorkTags.ContextConsumer
local ForwardRef = ReactWorkTags.ForwardRef
local Fragment = ReactWorkTags.Fragment
local Mode = ReactWorkTags.Mode
local Profiler = ReactWorkTags.Profiler
local SuspenseComponent = ReactWorkTags.SuspenseComponent
local SuspenseListComponent = ReactWorkTags.SuspenseListComponent
local MemoComponent = ReactWorkTags.MemoComponent
local SimpleMemoComponent = ReactWorkTags.SimpleMemoComponent
local LazyComponent = ReactWorkTags.LazyComponent
local IncompleteClassComponent = ReactWorkTags.IncompleteClassComponent
local FundamentalComponent = ReactWorkTags.FundamentalComponent
local ScopeComponent = ReactWorkTags.ScopeComponent
local Block = ReactWorkTags.Block
local OffscreenComponent = ReactWorkTags.OffscreenComponent
local LegacyHiddenComponent = ReactWorkTags.LegacyHiddenComponent
local ReactFiberSuspenseComponent =
__require(script.Parent["ReactFiberSuspenseComponent.new"])
type SuspenseState = ReactFiberSuspenseComponent.SuspenseState
type SuspenseListRenderState = ReactFiberSuspenseComponent.SuspenseState
local ReactTypeOfMode = __require(script.Parent.ReactTypeOfMode)
local NoMode = ReactTypeOfMode.NoMode
local ConcurrentMode = ReactTypeOfMode.ConcurrentMode
local BlockingMode = ReactTypeOfMode.BlockingMode
local ProfileMode = ReactTypeOfMode.ProfileMode
local ReactFiberFlags = __require(script.Parent.ReactFiberFlags)
local Ref = ReactFiberFlags.Ref
local Update = ReactFiberFlags.Update
local Callback = ReactFiberFlags.Callback
local Passive = ReactFiberFlags.Passive
local Deletion = ReactFiberFlags.Deletion
local NoFlags = ReactFiberFlags.NoFlags
local DidCapture = ReactFiberFlags.DidCapture
local Snapshot = ReactFiberFlags.Snapshot
local MutationMask = ReactFiberFlags.MutationMask
local LayoutMask = ReactFiberFlags.LayoutMask
local PassiveMask = ReactFiberFlags.PassiveMask
local StaticMask = ReactFiberFlags.StaticMask
local PerformedWork = ReactFiberFlags.PerformedWork
local invariant = __require(Packages.Shared).invariant
local createInstance = ReactFiberHostConfig.createInstance
local createTextInstance = ReactFiberHostConfig.createTextInstance
local appendInitialChild = ReactFiberHostConfig.appendInitialChild
local finalizeInitialChildren = ReactFiberHostConfig.finalizeInitialChildren
local prepareUpdate = ReactFiberHostConfig.prepareUpdate
local supportsMutation = ReactFiberHostConfig.supportsMutation
local supportsPersistence = ReactFiberHostConfig.supportsPersistence
local createContainerChildSet = ReactFiberHostConfig.createContainerChildSet
local finalizeContainerChildren = ReactFiberHostConfig.finalizeContainerChildren
local preparePortalMount = ReactFiberHostConfig.preparePortalMount
local ReactFiberHostContext = __require(script.Parent["ReactFiberHostContext.new"])
local getRootHostContainer = ReactFiberHostContext.getRootHostContainer
local popHostContext = ReactFiberHostContext.popHostContext
local getHostContext = ReactFiberHostContext.getHostContext
local popHostContainer = ReactFiberHostContext.popHostContainer
local ReactFiberSuspenseContext = __require(script.Parent["ReactFiberSuspenseContext.new"])
local popSuspenseContext = ReactFiberSuspenseContext.popSuspenseContext
local suspenseStackCursor = ReactFiberSuspenseContext.suspenseStackCursor
local InvisibleParentSuspenseContext =
ReactFiberSuspenseContext.InvisibleParentSuspenseContext
local hasSuspenseContext = ReactFiberSuspenseContext.hasSuspenseContext
type SuspenseContext = ReactFiberSuspenseContext.SuspenseContext
local ReactFiberContext = __require(script.Parent["ReactFiberContext.new"])
local isLegacyContextProvider = ReactFiberContext.isContextProvider
local popLegacyContext = ReactFiberContext.popContext
local popTopLevelLegacyContextObject = ReactFiberContext.popTopLevelContextObject
local popProvider = __require(script.Parent["ReactFiberNewContext.new"]).popProvider
local ReactFiberHydrationContext =
__require(script.Parent["ReactFiberHydrationContext.new"])
local prepareToHydrateHostSuspenseInstance =
ReactFiberHydrationContext.prepareToHydrateHostSuspenseInstance
local popHydrationState = ReactFiberHydrationContext.popHydrationState
local resetHydrationState = ReactFiberHydrationContext.resetHydrationState
local prepareToHydrateHostInstance =
ReactFiberHydrationContext.prepareToHydrateHostInstance
local prepareToHydrateHostTextInstance =
ReactFiberHydrationContext.prepareToHydrateHostTextInstance
local ReactFeatureFlags = __require(Packages.Shared).ReactFeatureFlags
local enableSchedulerTracing = ReactFeatureFlags.enableSchedulerTracing
local enableSuspenseCallback = ReactFeatureFlags.enableSuspenseCallback
local enableSuspenseServerRenderer = ReactFeatureFlags.enableSuspenseServerRenderer
local enableFundamentalAPI = ReactFeatureFlags.enableFundamentalAPI
local enableProfilerTimer = ReactFeatureFlags.enableProfilerTimer
local ReactFiberWorkLoop = __require(script.Parent["ReactFiberWorkLoop.new"]) :: any
local popRenderLanes = ReactFiberWorkLoop.popRenderLanes
local markSpawnedWork = ReactFiberWorkLoop.markSpawnedWork
local renderDidSuspend = ReactFiberWorkLoop.renderDidSuspend
local renderDidSuspendDelayIfPossible = ReactFiberWorkLoop.renderDidSuspendDelayIfPossible
local NoLanes = ReactFiberLane.NoLanes
local includesSomeLane = ReactFiberLane.includesSomeLane
local mergeLanes = ReactFiberLane.mergeLanes
local ReactProfilerTimer = __require(script.Parent["ReactProfilerTimer.new"])
local transferActualDuration = ReactProfilerTimer.transferActualDuration
local function markUpdate(workInProgress: Fiber)
workInProgress.flags = bit32.bor(workInProgress.flags, Update)
end
local function markRef(workInProgress: Fiber)
workInProgress.flags = bit32.bor(workInProgress.flags, Ref)
end
local function hadNoMutationsEffects(current, completedWork: Fiber)
local didBailout = current ~= nil and current.child == completedWork.child
if didBailout then
return true
end
local child = completedWork.child
while child ~= nil do
if bit32.band(child.flags, MutationMask) ~= NoFlags then
return false
end
if bit32.band(child.subtreeFlags, MutationMask) ~= NoFlags then
return false
end
child = child.sibling
end
return true
end
local appendAllChildren
local updateHostContainer
local updateHostComponent
local updateHostText
if supportsMutation then
appendAllChildren = function(
parent: Instance,
workInProgress: Fiber,
needsVisibilityToggle: boolean,
isHidden: boolean
)
local node = workInProgress.child
while node ~= nil do
if node.tag == HostComponent or node.tag == HostText then
appendInitialChild(parent, node.stateNode)
elseif enableFundamentalAPI and node.tag == FundamentalComponent then
appendInitialChild(parent, node.stateNode.instance)
elseif node.tag == HostPortal then
elseif node.child ~= nil then
node.child.return_ = node
node = node.child
continue
end
if node == workInProgress then
return
end
while node.sibling == nil do
if node.return_ == nil or node.return_ == workInProgress then
return
end
node = node.return_
end
(node.sibling :: Fiber).return_ = node.return_
node = node.sibling
end
end
updateHostContainer = function(current: nil | Fiber, workInProgress: Fiber)
end
function updateHostComponent(
current: Fiber,
workInProgress: Fiber,
type: Type,
newProps: Props,
rootContainerInstance: Container
)
local oldProps = current.memoizedProps
if oldProps == newProps then
return
end
local instance: Instance = workInProgress.stateNode
local currentHostContext = getHostContext()
local updatePayload = prepareUpdate(
instance,
type,
oldProps,
newProps,
rootContainerInstance,
currentHostContext
)
workInProgress.updateQueue = updatePayload
if updatePayload then
markUpdate(workInProgress)
end
end
function updateHostText(
current: Fiber,
workInProgress: Fiber,
oldText: string,
newText: string
)
if oldText ~= newText then
markUpdate(workInProgress)
end
end
elseif supportsPersistence then
appendAllChildren = function(
parent: Instance,
workInProgress: Fiber,
needsVisibilityToggle: boolean,
isHidden: boolean
)
unimplemented("appendAllChildren")
end
local function appendAllChildrenToContainer(
containerChildSet: ChildSet,
workInProgress: Fiber,
needsVisibilityToggle: boolean,
isHidden: boolean
)
unimplemented("appendAllChildrenToContainer")
end
function updateHostContainer(current: nil | Fiber, workInProgress: Fiber)
local portalOrRoot: {
containerInfo: Container,
pendingChildren: ChildSet,
[any]: any,
} =
workInProgress.stateNode
local childrenUnchanged = hadNoMutationsEffects(current, workInProgress)
if childrenUnchanged then
else
local container = portalOrRoot.containerInfo
local newChildSet = createContainerChildSet(container)
appendAllChildrenToContainer(newChildSet, workInProgress, false, false)
portalOrRoot.pendingChildren = newChildSet
markUpdate(workInProgress)
finalizeContainerChildren(container, newChildSet)
end
end
else
updateHostContainer = function(current: nil | Fiber, workInProgress: Fiber)
end
end
local function bubbleProperties(completedWork: Fiber)
local didBailout = completedWork.alternate ~= nil
and (completedWork.alternate :: Fiber).child == completedWork.child
local newChildLanes = NoLanes
local subtreeFlags = NoFlags
if not didBailout then
if
enableProfilerTimer
and bit32.band(completedWork.mode, ProfileMode) ~= NoMode
then
local actualDuration = completedWork.actualDuration
local treeBaseDuration = completedWork.selfBaseDuration
local child = completedWork.child
while child ~= nil do
newChildLanes =
mergeLanes(newChildLanes, mergeLanes(child.lanes, child.childLanes))
subtreeFlags = bit32.bor(subtreeFlags, child.subtreeFlags)
subtreeFlags = bit32.bor(subtreeFlags, child.flags)
actualDuration += child.actualDuration
treeBaseDuration += child.treeBaseDuration
child = child.sibling
end
completedWork.actualDuration = actualDuration
completedWork.treeBaseDuration = treeBaseDuration
else
local child = completedWork.child
while child ~= nil do
newChildLanes =
bit32.bor(newChildLanes, bit32.bor(child.lanes, child.childLanes))
subtreeFlags = bit32.bor(subtreeFlags, child.subtreeFlags)
subtreeFlags = bit32.bor(subtreeFlags, child.flags)
child.return_ = completedWork
child = child.sibling
end
end
completedWork.subtreeFlags = bit32.bor(completedWork.subtreeFlags, subtreeFlags)
else
if
enableProfilerTimer
and bit32.band(completedWork.mode, ProfileMode) ~= NoMode
then
local treeBaseDuration = completedWork.selfBaseDuration
local child = completedWork.child
while child ~= nil do
newChildLanes =
mergeLanes(newChildLanes, mergeLanes(child.lanes, child.childLanes))
subtreeFlags =
bit32.bor(subtreeFlags, bit32.band(child.subtreeFlags, StaticMask))
subtreeFlags =
bit32.bor(subtreeFlags, bit32.band(child.flags, StaticMask))
treeBaseDuration += child.treeBaseDuration
child = child.sibling
end
completedWork.treeBaseDuration = treeBaseDuration
else
local child = completedWork.child
while child ~= nil do
newChildLanes =
bit32.bor(newChildLanes, bit32.bor(child.lanes, child.childLanes))
subtreeFlags =
bit32.bor(subtreeFlags, bit32.band(child.subtreeFlags, StaticMask))
subtreeFlags =
bit32.bor(subtreeFlags, bit32.band(child.flags, StaticMask))
child.return_ = completedWork
child = child.sibling
end
end
completedWork.subtreeFlags = bit32.bor(completedWork.subtreeFlags, subtreeFlags)
end
completedWork.childLanes = newChildLanes
return didBailout
end
local function completeWork(
current,
workInProgress: Fiber,
renderLanes: Lanes
): Fiber | nil
local newProps = workInProgress.pendingProps
if
workInProgress.tag == IndeterminateComponent
or workInProgress.tag == LazyComponent
or workInProgress.tag == SimpleMemoComponent
or workInProgress.tag == FunctionComponent
or workInProgress.tag == ForwardRef
or workInProgress.tag == Fragment
or workInProgress.tag == Mode
or workInProgress.tag == ContextConsumer
or workInProgress.tag == MemoComponent
then
bubbleProperties(workInProgress)
return nil
elseif workInProgress.tag == ClassComponent then
local Component = workInProgress.type
if isLegacyContextProvider(Component) then
popLegacyContext(workInProgress)
end
bubbleProperties(workInProgress)
return nil
elseif workInProgress.tag == HostRoot then
popHostContainer(workInProgress)
popTopLevelLegacyContextObject(workInProgress)
resetMutableSourceWorkInProgressVersions()
local fiberRoot = workInProgress.stateNode
if fiberRoot.pendingContext then
fiberRoot.context = fiberRoot.pendingContext
fiberRoot.pendingContext = nil
end
if current == nil or current.child == nil then
local wasHydrated = popHydrationState(workInProgress)
if wasHydrated then
markUpdate(workInProgress)
elseif not fiberRoot.hydrate then
workInProgress.flags = bit32.bor(workInProgress.flags, Snapshot)
end
end
updateHostContainer(current, workInProgress)
bubbleProperties(workInProgress)
return nil
elseif workInProgress.tag == HostComponent then
popHostContext(workInProgress)
local rootContainerInstance = getRootHostContainer()
local type = workInProgress.type
if current ~= nil and workInProgress.stateNode ~= nil then
updateHostComponent(
current,
workInProgress,
type,
newProps,
rootContainerInstance
)
if current.ref ~= workInProgress.ref then
markRef(workInProgress)
end
else
if not newProps then
invariant(
workInProgress.stateNode ~= nil,
"We must have new props for new mounts. This error is likely "
.. "caused by a bug in React. Please file an issue."
)
bubbleProperties(workInProgress)
return nil
end
local currentHostContext = getHostContext()
local wasHydrated = popHydrationState(workInProgress)
if wasHydrated then
if
prepareToHydrateHostInstance(
workInProgress,
rootContainerInstance,
currentHostContext
)
then
markUpdate(workInProgress)
end
else
local instance = createInstance(
type,
newProps,
rootContainerInstance,
currentHostContext,
workInProgress
)
appendAllChildren(instance, workInProgress, false, false)
workInProgress.stateNode = instance
if
finalizeInitialChildren(
instance,
type,
newProps,
rootContainerInstance,
currentHostContext
)
then
markUpdate(workInProgress)
end
end
if workInProgress.ref ~= nil then
markRef(workInProgress)
end
end
bubbleProperties(workInProgress)
return nil
elseif workInProgress.tag == HostText then
local newText = newProps
if current and workInProgress.stateNode ~= nil then
local oldText = current.memoizedProps
updateHostText(current, workInProgress, oldText, newText)
else
if typeof(newText) ~= "string" then
invariant(
workInProgress.stateNode ~= nil,
"We must have new props for new mounts. This error is likely "
.. "caused by a bug in React. Please file an issue."
)
end
local rootContainerInstance = getRootHostContainer()
local currentHostContext = getHostContext()
local wasHydrated = popHydrationState(workInProgress)
if wasHydrated then
if prepareToHydrateHostTextInstance(workInProgress) then
markUpdate(workInProgress)
end
else
workInProgress.stateNode = createTextInstance(
newText,
rootContainerInstance,
currentHostContext,
workInProgress
)
end
end
bubbleProperties(workInProgress)
return nil
elseif workInProgress.tag == Profiler then
local didBailout = bubbleProperties(workInProgress)
if not didBailout then
local OnRenderFlag = Update
local OnCommitFlag = Callback
local OnPostCommitFlag = Passive
local subtreeFlags = workInProgress.subtreeFlags
local flags = workInProgress.flags
local newFlags = flags
if
bit32.band(flags, PerformedWork) ~= NoFlags
or bit32.band(subtreeFlags, PerformedWork) ~= NoFlags
then
newFlags = bit32.bor(newFlags, OnRenderFlag)
end
if
bit32.band(flags, bit32.bor(LayoutMask, Deletion)) ~= NoFlags
or bit32.band(subtreeFlags, bit32.bor(LayoutMask, Deletion))
~= NoFlags
then
newFlags = bit32.bor(newFlags, OnCommitFlag)
end
if
bit32.band(flags, PassiveMask) ~= NoFlags
or bit32.band(subtreeFlags, PassiveMask) ~= NoFlags
then
newFlags = bit32.bor(newFlags, OnPostCommitFlag)
end
workInProgress.flags = newFlags
else
end
return nil
elseif workInProgress.tag == SuspenseComponent then
popSuspenseContext(workInProgress)
local nextState: nil | SuspenseState = workInProgress.memoizedState
if enableSuspenseServerRenderer then
if nextState ~= nil and (nextState :: SuspenseState).dehydrated ~= nil then
if current == nil then
local wasHydrated = popHydrationState(workInProgress)
invariant(
wasHydrated,
"A dehydrated suspense component was completed without a hydrated node. "
.. "This is probably a bug in React."
)
prepareToHydrateHostSuspenseInstance(workInProgress)
if enableSchedulerTracing then
markSpawnedWork(OffscreenLane)
end
bubbleProperties(workInProgress)
if enableProfilerTimer then
if bit32.band(workInProgress.mode, ProfileMode) ~= NoMode then
local isTimedOutSuspense = nextState ~= nil
if isTimedOutSuspense then
local primaryChildFragment = workInProgress.child
if primaryChildFragment ~= nil then
workInProgress.treeBaseDuration = (
primaryChildFragment.treeBaseDuration :: any
) :: number
end
end
end
end
return nil
else
resetHydrationState()
if bit32.band(workInProgress.flags, DidCapture) == NoFlags then
workInProgress.memoizedState = nil
end
workInProgress.flags = bit32.bor(workInProgress.flags, Update)
bubbleProperties(workInProgress)
if enableProfilerTimer then
if bit32.band(workInProgress.mode, ProfileMode) ~= NoMode then
local isTimedOutSuspense = nextState ~= nil
if isTimedOutSuspense then
local primaryChildFragment = workInProgress.child
if primaryChildFragment ~= nil then
workInProgress.treeBaseDuration -= primaryChildFragment.treeBaseDuration
end
end
end
end
return nil
end
end
end
if bit32.band(workInProgress.flags, DidCapture) ~= NoFlags then
workInProgress.lanes = renderLanes
if
enableProfilerTimer
and bit32.band(workInProgress.mode, ProfileMode) ~= NoMode
then
transferActualDuration(workInProgress)
end
return workInProgress
end
local nextDidTimeout = nextState ~= nil
local prevDidTimeout = false
if current == nil then
if workInProgress.memoizedProps.fallback ~= nil then
popHydrationState(workInProgress)
end
else
local prevState: nil | SuspenseState = current.memoizedState
prevDidTimeout = prevState ~= nil
end
if nextDidTimeout and not prevDidTimeout then
if bit32.band(workInProgress.mode, BlockingMode) ~= NoMode then
local hasInvisibleChildContext = current == nil
and workInProgress.memoizedProps.unstable_avoidThisFallback
~= true
if
hasInvisibleChildContext
or hasSuspenseContext(
suspenseStackCursor.current,
InvisibleParentSuspenseContext :: SuspenseContext
)
then
renderDidSuspend()
else
renderDidSuspendDelayIfPossible()
end
end
end
if supportsPersistence then
if nextDidTimeout then
workInProgress.flags = bit32.bor(workInProgress.flags, Update)
end
end
if supportsMutation then
if nextDidTimeout or prevDidTimeout then
workInProgress.flags = bit32.bor(workInProgress.flags, Update)
end
end
if
enableSuspenseCallback
and workInProgress.updateQueue ~= nil
and workInProgress.memoizedProps.suspenseCallback ~= nil
then
workInProgress.flags = bit32.bor(workInProgress.flags, Update)
end
bubbleProperties(workInProgress)
if enableProfilerTimer then
if bit32.band(workInProgress.mode, ProfileMode) ~= NoMode then
if nextDidTimeout then
local primaryChildFragment = workInProgress.child
if primaryChildFragment ~= nil then
workInProgress.treeBaseDuration -= primaryChildFragment.treeBaseDuration
end
end
end
end
return nil
elseif workInProgress.tag == HostPortal then
popHostContainer(workInProgress)
updateHostContainer(current, workInProgress)
if current == nil then
preparePortalMount(workInProgress.stateNode.containerInfo)
end
bubbleProperties(workInProgress)
return nil
elseif workInProgress.tag == ContextProvider then
popProvider(workInProgress)
bubbleProperties(workInProgress)
return nil
elseif workInProgress.tag == IncompleteClassComponent then
local Component = workInProgress.type
if isLegacyContextProvider(Component) then
popLegacyContext(workInProgress)
end
bubbleProperties(workInProgress)
return nil
elseif workInProgress.tag == SuspenseListComponent then
unimplemented("SuspenseListComponent")
elseif workInProgress.tag == FundamentalComponent then
unimplemented("FundamentalComponent")
elseif workInProgress.tag == ScopeComponent then
unimplemented("ScopeComponent")
elseif workInProgress.tag == Block then
unimplemented("Block")
elseif
workInProgress.tag == OffscreenComponent
or workInProgress.tag == LegacyHiddenComponent
then
popRenderLanes(workInProgress)
local nextState: OffscreenState | nil = workInProgress.memoizedState
local nextIsHidden = nextState ~= nil
if current ~= nil then
local prevState: OffscreenState | nil = current.memoizedState
local prevIsHidden = prevState ~= nil
if
prevIsHidden ~= nextIsHidden
and newProps.mode ~= "unstable-defer-without-hiding"
then
workInProgress.flags = bit32.bor(workInProgress.flags, Update)
end
end
if
not nextIsHidden
or includesSomeLane(
ReactFiberWorkLoop.subtreeRenderLanes,
OffscreenLane :: Lane
)
or bit32.band(workInProgress.mode, ConcurrentMode) == NoMode
then
bubbleProperties(workInProgress)
end
return nil
end
invariant(
false,
"Unknown unit of work tag (%s). This error is likely caused by a bug in "
.. "React. Please file an issue.",
tostring(workInProgress.tag)
)
return nil
end
return {
completeWork = completeWork,
}
end
end)())
__register("ReactReconciler/ReactFiberComponentStack", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberComponentStack"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local LuauPolyfill = __require(Packages.LuauPolyfill)
type Function = (...any) -> ...any
type Error = LuauPolyfill.Error
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
local ReactWorkTags = __require(script.Parent.ReactWorkTags)
local HostComponent = ReactWorkTags.HostComponent
local LazyComponent = ReactWorkTags.LazyComponent
local SuspenseComponent = ReactWorkTags.SuspenseComponent
local SuspenseListComponent = ReactWorkTags.SuspenseListComponent
local FunctionComponent = ReactWorkTags.FunctionComponent
local IndeterminateComponent = ReactWorkTags.IndeterminateComponent
local ForwardRef = ReactWorkTags.ForwardRef
local SimpleMemoComponent = ReactWorkTags.SimpleMemoComponent
local ClassComponent = ReactWorkTags.ClassComponent
local ReactComponentStackFrame = __require(Packages.Shared).ReactComponentStackFrame
local describeBuiltInComponentFrame =
ReactComponentStackFrame.describeBuiltInComponentFrame
local describeFunctionComponentFrame =
ReactComponentStackFrame.describeFunctionComponentFrame
local describeClassComponentFrame = ReactComponentStackFrame.describeClassComponentFrame
local function describeFiber(fiber: Fiber): string
local owner: nil | Function = nil
if ReactGlobals.__DEV__ then
local debugOwner = fiber._debugOwner
if debugOwner then
owner = debugOwner.type
end
end
local source = nil
if ReactGlobals.__DEV__ then
source = fiber._debugSource
end
if fiber.tag == HostComponent then
return describeBuiltInComponentFrame(fiber.type, source, owner)
elseif fiber.tag == LazyComponent then
return describeBuiltInComponentFrame("Lazy", source, owner)
elseif fiber.tag == SuspenseComponent then
return describeBuiltInComponentFrame("Suspense", source, owner)
elseif fiber.tag == SuspenseListComponent then
return describeBuiltInComponentFrame("SuspenseList", source, owner)
elseif
fiber.tag == FunctionComponent
or fiber.tag == IndeterminateComponent
or fiber.tag == SimpleMemoComponent
then
return describeFunctionComponentFrame(fiber.type, source, owner)
elseif fiber.tag == ForwardRef then
return describeFunctionComponentFrame(fiber.type.render, source, owner)
elseif fiber.tag == ClassComponent then
return describeClassComponentFrame(fiber.type, source, owner)
else
return ""
end
end
return {
getStackByFiberInDevAndProd = function(workInProgress: Fiber?): string
local ok: boolean, result: Error | string = pcall(function()
local info = ""
local node = workInProgress
repeat
info ..= describeFiber(node :: Fiber)
node = (node :: Fiber).return_
until node == nil
return info
end)
if not ok then
local message = "\nError generating stack: "
if
typeof(result) == "table"
and (result :: Error).message
and (result :: Error).stack
then
return message
.. (result :: Error).message
.. "\n"
.. tostring((result :: Error).stack)
end
return message .. tostring(result)
end
return result :: string
end,
}
end
end)())
__register("ReactReconciler/ReactFiberContext.new", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberContext.new"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local LuauPolyfill = __require(Packages.LuauPolyfill)
local Object = LuauPolyfill.Object
local Error = LuauPolyfill.Error
local __DEV__ = ReactGlobals.__DEV__ :: boolean
local __DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ =
ReactGlobals.__DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ :: boolean
local console = __require(Packages.Shared).console
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
local ReactFiberStack = __require(script.Parent["ReactFiberStack.new"])
type StackCursor<T> = ReactFiberStack.StackCursor<T>
local isFiberMounted = __require(script.Parent.ReactFiberTreeReflection).isFiberMounted
local disableLegacyContext =
__require(Packages.Shared).ReactFeatureFlags.disableLegacyContext
local ReactWorkTags = __require(script.Parent.ReactWorkTags)
local ClassComponent = ReactWorkTags.ClassComponent
local HostRoot = ReactWorkTags.HostRoot
local getComponentName = __require(Packages.Shared).getComponentName
local checkPropTypes = __require(Packages.Shared).checkPropTypes
local createCursor = ReactFiberStack.createCursor
local push = ReactFiberStack.push
local pop = ReactFiberStack.pop
local warnedAboutMissingGetChildContext
if __DEV__ then
warnedAboutMissingGetChildContext = {}
end
local emptyContextObject = {}
if __DEV__ then
Object.freeze(emptyContextObject)
end
type Object = { [any]: any }
local contextStackCursor: StackCursor<Object> = createCursor(emptyContextObject)
local didPerformWorkStackCursor: StackCursor<boolean> = createCursor(false)
local previousContext: Object = emptyContextObject
local isContextProvider
local function getUnmaskedContext(
workInProgress: Fiber,
Component: any,
didPushOwnContextIfProvider: boolean
): Object
if didPushOwnContextIfProvider and isContextProvider(Component) then
return previousContext
end
return contextStackCursor.current
end
local function cacheContext(
workInProgress: Fiber,
unmaskedContext: Object,
maskedContext: Object
): ()
local instance = workInProgress.stateNode
instance.__reactInternalMemoizedUnmaskedChildContext = unmaskedContext
instance.__reactInternalMemoizedMaskedChildContext = maskedContext
end
local function getMaskedContext(workInProgress: Fiber, unmaskedContext: Object): Object
local type_ = workInProgress.type
if type(type_) == "function" then
return unmaskedContext
end
local contextTypes = type_.contextTypes
if not contextTypes then
return emptyContextObject
end
local instance = workInProgress.stateNode
if
instance
and instance.__reactInternalMemoizedUnmaskedChildContext == unmaskedContext
then
return instance.__reactInternalMemoizedMaskedChildContext
end
local context = {}
for key, _ in contextTypes do
context[key] = unmaskedContext[key]
end
if __DEV__ or __DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ then
local name = getComponentName(type_) or "Unknown"
checkPropTypes(contextTypes, nil, context, "context", name)
end
if instance then
cacheContext(workInProgress, unmaskedContext, context)
end
return context
end
local function hasContextChanged(): boolean
if disableLegacyContext then
return false
else
return didPerformWorkStackCursor.current
end
end
function isContextProvider(type_): boolean
if type(type_) == "function" then
return false
end
local childContextTypes = type_.childContextTypes
return childContextTypes ~= nil
end
local function popContext(fiber: Fiber): ()
pop(didPerformWorkStackCursor, fiber)
pop(contextStackCursor, fiber)
end
local function popTopLevelContextObject(fiber: Fiber): ()
pop(didPerformWorkStackCursor, fiber)
pop(contextStackCursor, fiber)
end
local function pushTopLevelContextObject(
fiber: Fiber,
context: Object,
didChange: boolean
): ()
if contextStackCursor.current ~= emptyContextObject then
error(
Error.new(
"Unexpected context found on stack. "
.. "This error is likely caused by a bug in React. Please file an issue."
)
)
end
push(contextStackCursor, context, fiber)
push(didPerformWorkStackCursor, didChange, fiber)
end
local function processChildContext(
fiber: Fiber,
type_: any,
parentContext: Object
): Object
local instance = fiber.stateNode
local childContextTypes = type_.childContextTypes
if
instance.getChildContext == nil
or type(instance.getChildContext) ~= "function"
then
if __DEV__ then
local componentName = getComponentName(type_) or "Unknown"
if not warnedAboutMissingGetChildContext[componentName] then
warnedAboutMissingGetChildContext[componentName] = true
console.error(
"%s.childContextTypes is specified but there is no getChildContext() method "
.. "on the instance. You can either define getChildContext() on %s or remove "
.. "childContextTypes from it.",
componentName,
componentName
)
end
end
return parentContext
end
local childContext = instance:getChildContext()
for contextKey, _ in childContext do
if childContextTypes[contextKey] == nil then
local name = getComponentName(type_) or "Unknown"
error(
Error.new(
string.format(
'%s.getChildContext(): key "%s" is not defined in childContextTypes.',
name,
contextKey
)
)
)
end
end
if __DEV__ or __DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ then
local name = getComponentName(type_) or "Unknown"
checkPropTypes(childContextTypes, nil, childContext, "child context", name)
end
return Object.assign({}, parentContext, childContext)
end
local function pushContextProvider(workInProgress: Fiber): boolean
local instance = workInProgress.stateNode
local memoizedMergedChildContext = (
instance and instance.__reactInternalMemoizedMergedChildContext
) or emptyContextObject
previousContext = contextStackCursor.current
push(contextStackCursor, memoizedMergedChildContext, workInProgress)
push(didPerformWorkStackCursor, didPerformWorkStackCursor.current, workInProgress)
return true
end
local function invalidateContextProvider(
workInProgress: Fiber,
type_: any,
didChange: boolean
): ()
local instance = workInProgress.stateNode
if not instance then
error(
Error.new(
"Expected to have an instance by this point. "
.. "This error is likely caused by a bug in React. Please file an issue."
)
)
end
if didChange then
local mergedContext = processChildContext(workInProgress, type_, previousContext)
instance.__reactInternalMemoizedMergedChildContext = mergedContext
pop(didPerformWorkStackCursor, workInProgress)
pop(contextStackCursor, workInProgress)
push(contextStackCursor, mergedContext, workInProgress)
push(didPerformWorkStackCursor, didChange, workInProgress)
else
pop(didPerformWorkStackCursor, workInProgress)
push(didPerformWorkStackCursor, didChange, workInProgress)
end
end
local function findCurrentUnmaskedContext(fiber: Fiber): Object
if fiber.tag ~= ClassComponent or not isFiberMounted(fiber) then
error(
Error.new(
"Expected subtree parent to be a mounted class component. "
.. "This error is likely caused by a bug in React. Please file an issue."
)
)
end
local node: any = fiber
repeat
if node.tag == HostRoot then
return node.stateNode.context
elseif node.tag == ClassComponent then
local Component = node.type
if Component.childContextTypes ~= nil then
return node.stateNode.__reactInternalMemoizedMergedChildContext
end
end
node = node.return_
until node == nil
error(
Error.new(
"Found unexpected detached subtree parent. "
.. "This error is likely caused by a bug in React. Please file an issue."
)
)
end
return {
emptyContextObject = emptyContextObject,
getUnmaskedContext = getUnmaskedContext,
cacheContext = cacheContext,
getMaskedContext = getMaskedContext,
hasContextChanged = hasContextChanged,
popContext = popContext,
popTopLevelContextObject = popTopLevelContextObject,
pushTopLevelContextObject = pushTopLevelContextObject,
processChildContext = processChildContext,
isContextProvider = isContextProvider,
pushContextProvider = pushContextProvider,
invalidateContextProvider = invalidateContextProvider,
findCurrentUnmaskedContext = findCurrentUnmaskedContext,
}
end
end)())
__register("ReactReconciler/ReactFiberDevToolsHook.new", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberDevToolsHook.new"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local console = __require(Packages.Shared).console
local LuauPolyfill = __require(Packages.LuauPolyfill)
type Object = LuauPolyfill.Object
local exports = {}
type DevToolsHook = {
inject: (Object) -> number | nil,
supportsFiber: boolean,
isDisabled: boolean,
}
local function isCallable(value)
if typeof(value) == "function" then
return true
end
if typeof(value) == "table" then
local mt = getmetatable(value)
if mt and rawget(mt, "__call") then
return true
end
if value._isMockFunction then
return true
end
end
return false
end
local enableProfilerTimer = __require(Packages.Shared).ReactFeatureFlags.enableProfilerTimer
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
type FiberRoot = ReactInternalTypes.FiberRoot
type ReactPriorityLevel = ReactInternalTypes.ReactPriorityLevel
local ReactTypes = __require(Packages.Shared)
type ReactNodeList = ReactTypes.ReactNodeList
local DidCapture = __require(script.Parent.ReactFiberFlags).DidCapture
local rendererID = nil
local injectedHook = nil
local hasLoggedError = false
exports.isDevToolsPresent = function()
return ReactGlobals.__REACT_DEVTOOLS_GLOBAL_HOOK__ ~= nil
end
exports.injectInternals = function(internals: Object): boolean
if ReactGlobals.__REACT_DEVTOOLS_GLOBAL_HOOK__ == nil then
return false
end
local hook: DevToolsHook = ReactGlobals.__REACT_DEVTOOLS_GLOBAL_HOOK__
if hook.isDisabled then
return true
end
if not hook.supportsFiber then
if ReactGlobals.__DEV__ then
console.error(
"The installed version of React DevTools is too old and will not work "
.. "with the current version of React. Please update React DevTools. "
.. "https://reactjs.org/link/react-devtools"
)
end
return true
end
local ok, err = pcall(function()
rendererID = hook.inject(internals)
injectedHook = hook
end)
if not ok then
if ReactGlobals.__DEV__ then
console.error("React instrumentation encountered an error: %s.", err)
end
end
return true
end
exports.onScheduleRoot = function(root: FiberRoot, children: ReactNodeList)
if ReactGlobals.__DEV__ then
if
injectedHook
and isCallable(injectedHook.onScheduleFiberRoot)
then
local ok, err =
pcall(injectedHook.onScheduleFiberRoot, rendererID, root, children)
if not ok then
if ReactGlobals.__DEV__ and not hasLoggedError then
hasLoggedError = true
console.error("React instrumentation encountered an error: %s", err)
end
end
end
end
end
exports.onCommitRoot = function(root: FiberRoot, priorityLevel: ReactPriorityLevel)
if
injectedHook
and isCallable(injectedHook.onCommitFiberRoot)
then
local ok, err = pcall(function()
local didError = bit32.band(root.current.flags, DidCapture) == DidCapture
if enableProfilerTimer then
injectedHook.onCommitFiberRoot(rendererID, root, priorityLevel, didError)
else
injectedHook.onCommitFiberRoot(rendererID, root, nil, didError)
end
end)
if not ok then
if ReactGlobals.__DEV__ then
if not hasLoggedError then
hasLoggedError = true
console.error("React instrumentation encountered an error: %s", err)
end
end
end
end
end
exports.onCommitUnmount = function(fiber: Fiber)
if
injectedHook
and isCallable(injectedHook.onCommitFiberUnmount)
then
local ok, err = pcall(injectedHook.onCommitFiberUnmount, rendererID, fiber)
if not ok then
if ReactGlobals.__DEV__ then
if not hasLoggedError then
hasLoggedError = true
console.error("React instrumentation encountered an error: %s", err)
end
end
end
end
end
return exports
end
end)())
__register("ReactReconciler/ReactFiberErrorDialog", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberErrorDialog"})
return function()
local exports = {}
exports.showErrorDialog = function(boundary, errorInfo): boolean
return true
end
return exports
end
end)())
__register("ReactReconciler/ReactFiberErrorLogger", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberErrorLogger"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local LuauPolyfill = __require(Packages.LuauPolyfill)
type Error = LuauPolyfill.Error
local inspect = LuauPolyfill.util.inspect
local setTimeout = LuauPolyfill.setTimeout
local Shared = __require(Packages.Shared)
local console = Shared.console
local errorToString = Shared.errorToString
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
local ReactCapturedValue = __require(script.Parent.ReactCapturedValue)
type CapturedValue<T> = ReactCapturedValue.CapturedValue<T>
local showErrorDialog = __require(script.Parent.ReactFiberErrorDialog).showErrorDialog
local ClassComponent = __require(script.Parent.ReactWorkTags).ClassComponent
local getComponentName = __require(Packages.Shared).getComponentName
local exports = {}
exports.logCapturedError = function(boundary: Fiber, errorInfo: CapturedValue<any>)
local ok, e = pcall(function()
local logError = showErrorDialog(boundary, errorInfo)
if logError == false then
return nil
end
local error_ = errorInfo.value
if ReactGlobals.__DEV__ then
local source = errorInfo.source
local stack = errorInfo.stack
local componentStack = stack or ""
if error_ ~= nil and error_._suppressLogging then
if boundary.tag == ClassComponent then
return
end
console["error"](error_)
end
local componentName
if source ~= nil then
componentName = getComponentName(source.type)
else
componentName = nil
end
local componentNameMessage
if componentName then
componentNameMessage = "The above error occurred in the <"
.. tostring(componentName)
.. "> component:"
else
componentNameMessage =
"The above error occurred in one of your React components:"
end
local errorBoundaryMessage
local errorBoundaryName = getComponentName(boundary.type)
if errorBoundaryName then
errorBoundaryMessage = "React will try to recreate this component tree from scratch "
.. "using the error boundary you provided, "
.. errorBoundaryName
.. "."
else
errorBoundaryMessage = "Consider adding an error boundary to your tree to customize error handling behavior.\n"
.. "Visit https://reactjs.org/link/error-boundaries to learn more about error boundaries."
end
local combinedMessage = componentNameMessage
.. "\n"
.. componentStack
.. "\n\n"
.. errorBoundaryMessage
console["error"](combinedMessage)
else
console["error"](inspect(error_))
end
return nil
end)
if not ok then
warn("failed to error with error: " .. inspect(e))
setTimeout(function()
error(errorToString(e :: any))
end)
end
end
return exports
end
end)())
__register("ReactReconciler/ReactFiberFlags", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberFlags"})
return function()
type Flags = number
local exports = {}
exports.NoFlags =
0b000000000000000000
exports.PerformedWork =
0b000000000000000001
exports.Placement =
0b000000000000000010
exports.Update =
0b000000000000000100
exports.PlacementAndUpdate =
0b000000000000000110
exports.Deletion =
0b000000000000001000
exports.ContentReset =
0b000000000000010000
exports.Callback =
0b000000000000100000
exports.DidCapture =
0b000000000001000000
exports.Ref =
0b000000000010000000
exports.Snapshot =
0b000000000100000000
exports.Passive =
0b000000001000000000
exports.PassiveUnmountPendingDev =
0b000010000000000000
exports.Hydrating =
0b000000010000000000
exports.HydratingAndUpdate =
0b000000010000000100
exports.LifecycleEffectMask =
0b000000001110100100
exports.HostEffectMask =
0b000000011111111111
exports.Incomplete =
0b000000100000000000
exports.ShouldCapture =
0b000001000000000000
exports.ForceUpdateForLegacySuspense =
0b000100000000000000
exports.PassiveStatic =
0b001000000000000000
exports.BeforeMutationMask =
0b000000001100001010
exports.MutationMask =
0b000000010010011110
exports.LayoutMask =
0b000000000010100100
exports.PassiveMask =
0b000000001000001000
exports.StaticMask =
0b001000000000000000
exports.MountLayoutDev =
0b010000000000000000
exports.MountPassiveDev =
0b100000000000000000
return exports
end
end)())
__register("ReactReconciler/ReactFiberHooks.new", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberHooks.new"})
return function()
local function unimplemented(message: string)
print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
print("UNIMPLEMENTED ERROR: " .. message)
error("FIXME (roblox): " .. message .. " is unimplemented")
end
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local LuauPolyfill = __require(Packages.LuauPolyfill)
local Array = LuauPolyfill.Array
local Error = LuauPolyfill.Error
local Object = LuauPolyfill.Object
local __DEV__ = ReactGlobals.__DEV__ :: boolean
local createRef = __require(Packages.React).createRef
local createBinding = __require(Packages.React).createBinding
local console = __require(Packages.Shared).console
local ReactTypes = __require(Packages.Shared)
type ReactContext<T> = ReactTypes.ReactContext<T>
type ReactBinding<T> = ReactTypes.ReactBinding<T>
type ReactBindingUpdater<T> = ReactTypes.ReactBindingUpdater<T>
type MutableSource<T> = ReactTypes.MutableSource<T>
type MutableSourceGetSnapshotFn<Source, Snapshot> = ReactTypes.MutableSourceGetSnapshotFn<
Source,
Snapshot
>
type MutableSourceSubscribeFn<Source, Snapshot> = ReactTypes.MutableSourceSubscribeFn<
Source,
Snapshot
>
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
type Dispatcher = ReactInternalTypes.Dispatcher
type HookType = ReactInternalTypes.HookType
type ReactPriorityLevel = ReactInternalTypes.ReactPriorityLevel
local ReactFiberLane = __require(script.Parent.ReactFiberLane)
type Lanes = ReactFiberLane.Lanes
type Lane = ReactFiberLane.Lane
local ReactHookEffectTags = __require(script.Parent.ReactHookEffectTags)
type HookFlags = ReactHookEffectTags.HookFlags
type FiberRoot = ReactInternalTypes.FiberRoot
type OpaqueIDType = any
local ReactSharedInternals = __require(Packages.Shared).ReactSharedInternals
local ReactFeatureFlags = __require(Packages.Shared).ReactFeatureFlags
local enableDebugTracing: boolean? = ReactFeatureFlags.enableDebugTracing
local enableSchedulingProfiler: boolean? = ReactFeatureFlags.enableSchedulingProfiler
local enableNewReconciler: boolean? = ReactFeatureFlags.enableNewReconciler
local enableDoubleInvokingEffects = ReactFeatureFlags.enableDoubleInvokingEffects
local DebugTracingMode = __require(script.Parent.ReactTypeOfMode).DebugTracingMode
local NoLane = ReactFiberLane.NoLane
local NoLanes = ReactFiberLane.NoLanes
local isSubsetOfLanes = ReactFiberLane.isSubsetOfLanes
local mergeLanes = ReactFiberLane.mergeLanes
local removeLanes = ReactFiberLane.removeLanes
local markRootEntangled = ReactFiberLane.markRootEntangled
local markRootMutableRead = ReactFiberLane.markRootMutableRead
local ReactFiberNewContext = __require(script.Parent["ReactFiberNewContext.new"])
local readContext = ReactFiberNewContext.readContext
local ReactFiberFlags = __require(script.Parent.ReactFiberFlags)
local UpdateEffect = ReactFiberFlags.Update
local PassiveEffect = ReactFiberFlags.Passive
local PassiveStaticEffect = ReactFiberFlags.PassiveStatic
local MountLayoutDevEffect = ReactFiberFlags.MountLayoutDev
local MountPassiveDevEffect = ReactFiberFlags.MountPassiveDev
local HookHasEffect = ReactHookEffectTags.HasEffect
local HookLayout = ReactHookEffectTags.Layout
local HookPassive = ReactHookEffectTags.Passive
local ReactFiberWorkLoop = __require(script.Parent["ReactFiberWorkLoop.new"]) :: any
local warnIfNotCurrentlyActingUpdatesInDEV =
ReactFiberWorkLoop.warnIfNotCurrentlyActingUpdatesInDEV
local scheduleUpdateOnFiber = ReactFiberWorkLoop.scheduleUpdateOnFiber
local warnIfNotScopedWithMatchingAct = ReactFiberWorkLoop.warnIfNotScopedWithMatchingAct
local requestEventTime = ReactFiberWorkLoop.requestEventTime
local requestUpdateLane = ReactFiberWorkLoop.requestUpdateLane
local markSkippedUpdateLanes = ReactFiberWorkLoop.markSkippedUpdateLanes
local getWorkInProgressRoot = ReactFiberWorkLoop.getWorkInProgressRoot
local warnIfNotCurrentlyActingEffectsInDEV =
ReactFiberWorkLoop.warnIfNotCurrentlyActingEffectsInDEV
local invariant = __require(Packages.Shared).invariant
local getComponentName = __require(Packages.Shared).getComponentName
local function is(x: any, y: any)
return x == y and (x ~= 0 or 1 / x == 1 / y) or x ~= x and y ~= y
end
local markWorkInProgressReceivedUpdate =
__require(script.Parent["ReactFiberBeginWork.new"]).markWorkInProgressReceivedUpdate :: any
local getIsHydrating =
__require(script.Parent["ReactFiberHydrationContext.new"]).getIsHydrating
local ReactFiberHostConfig = __require(script.Parent.ReactFiberHostConfig)
local makeClientId = ReactFiberHostConfig.makeClientId
local ReactMutableSource = __require(script.Parent["ReactMutableSource.new"])
local warnAboutMultipleRenderersDEV = ReactMutableSource.warnAboutMultipleRenderersDEV
local getWorkInProgressVersion = ReactMutableSource.getWorkInProgressVersion
local setWorkInProgressVersion = ReactMutableSource.setWorkInProgressVersion
local markSourceAsDirty = ReactMutableSource.markSourceAsDirty
local logStateUpdateScheduled =
__require(script.Parent.DebugTracing).logStateUpdateScheduled
local markStateUpdateScheduled =
__require(script.Parent.SchedulingProfiler).markStateUpdateScheduled
local ReactCurrentDispatcher = ReactSharedInternals.ReactCurrentDispatcher
local FFlagReactCleanQueueOnUpdateBailout =
__require(Packages.SafeFlags).createGetFFlag("ReactCleanQueueOnUpdateBailout")()
type Array<T> = { [number]: T }
type Update<S, A> = {
lane: Lane,
action: A,
eagerReducer: ((S, A) -> S) | nil,
eagerState: S | nil,
next: Update<S, A>,
priority: ReactPriorityLevel?,
}
type UpdateQueue<S, A> = {
pending: Update<S, A> | nil,
dispatch: ((A) -> ...any) | nil,
lastRenderedReducer: ((S, A) -> S) | nil,
lastRenderedState: S | nil,
}
local didWarnAboutMismatchedHooksForComponent
local _didWarnAboutUseOpaqueIdentifier
if __DEV__ then
_didWarnAboutUseOpaqueIdentifier = {}
didWarnAboutMismatchedHooksForComponent = {}
end
type Hook = {
memoizedState: any,
baseState: any,
baseQueue: Update<any, any> | nil,
queue: UpdateQueue<any, any> | nil,
next: Hook?,
}
type Effect = {
tag: HookFlags,
create: (() -> () -> ()) | () -> (),
destroy: (() -> ())?,
deps: Array<any> | nil,
next: Effect,
}
type FunctionComponentUpdateQueue = {
lastEffect: Effect?,
}
type BasicStateAction<S> = ((S) -> S) | S
type Dispatch<A> = (A) -> ()
local exports: any = {}
local renderLanes: Lanes = NoLanes
local currentlyRenderingFiber: Fiber = nil :: any
local currentHook: any = nil
local workInProgressHook: any = nil
local didScheduleRenderPhaseUpdate: boolean = false
local didScheduleRenderPhaseUpdateDuringThisPass: boolean = false
local RE_RENDER_LIMIT = 25
local currentHookNameInDev: HookType? = nil
local hookTypesDev: Array<HookType> | nil = nil
local hookTypesUpdateIndexDev: number = 0
local ignorePreviousDependencies: boolean = false
local HooksDispatcherOnMountInDEV: Dispatcher | nil = nil
local HooksDispatcherOnMountWithHookTypesInDEV: Dispatcher | nil = nil
local HooksDispatcherOnUpdateInDEV: Dispatcher | nil = nil
local HooksDispatcherOnRerenderInDEV: Dispatcher | nil = nil
local InvalidNestedHooksDispatcherOnMountInDEV: Dispatcher | nil = nil
local InvalidNestedHooksDispatcherOnUpdateInDEV: Dispatcher | nil = nil
local InvalidNestedHooksDispatcherOnRerenderInDEV: Dispatcher | nil = nil
local function getHighestIndex(array: Array<any>)
local highestIndex = 0
for k, v in array do
highestIndex = if k > highestIndex then k else highestIndex
end
return highestIndex
end
local function isArrayOrSparseArray(deps: any)
if type(deps) ~= "table" then
return false
end
for k, _v in deps do
if type(k) ~= "number" then
return false
end
end
return true
end
local function mountHookTypesDev()
if __DEV__ then
local hookName = (currentHookNameInDev :: any) :: HookType
if hookTypesDev == nil then
hookTypesDev = ({ hookName } :: any) :: Array<HookType>
else
table.insert(hookTypesDev, hookName)
end
end
end
function updateHookTypesDev()
if __DEV__ then
local hookName: HookType = (currentHookNameInDev :: any) :: HookType
if hookTypesDev ~= nil then
hookTypesUpdateIndexDev += 1
if hookTypesDev[hookTypesUpdateIndexDev] ~= hookName then
warnOnHookMismatchInDev(hookName)
end
end
end
end
local function checkDepsAreArrayDev(deps: any)
if __DEV__ then
if deps ~= nil and not isArrayOrSparseArray(deps) then
console.error(
"%s received a final argument that is not an array (instead, received `%s`). When "
.. "specified, the final argument must be an array.",
currentHookNameInDev,
type(deps)
)
end
end
end
function warnOnHookMismatchInDev(currentHookName: HookType)
if __DEV__ then
local componentName = getComponentName(currentlyRenderingFiber.type)
or "Component"
if not didWarnAboutMismatchedHooksForComponent[componentName] then
didWarnAboutMismatchedHooksForComponent[componentName] = true
if hookTypesDev ~= nil then
local table_ = ""
local secondColumnStart = 30
for i = 1, hookTypesUpdateIndexDev do
local oldHookName = (hookTypesDev :: any)[i]
local newHookName
if i == hookTypesUpdateIndexDev then
newHookName = currentHookName
else
newHookName = oldHookName
end
local row = tostring(i) .. ". " .. (oldHookName or "undefined")
while string.len(row) < secondColumnStart do
row ..= " "
end
row ..= newHookName .. "\n"
table_ ..= row
end
console.error(
"React has detected a change in the order of Hooks called by %s. "
.. "This will lead to bugs and errors if not fixed. "
.. "For more information, read the Rules of Hooks: https://reactjs.org/link/rules-of-hooks\n\n"
.. "   Previous render            Next render\n"
.. "   ------------------------------------------------------\n"
.. "%s"
.. "   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n",
componentName,
table_
)
end
end
end
end
local function throwInvalidHookError(): ()
error(
Error.new(
"Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for"
.. " one of the following reasons:\n"
.. "1. You might have mismatching versions of React and the renderer (such as React DOM)\n"
.. "2. You might be breaking the Rules of Hooks\n"
.. "3. You might have more than one copy of React in the same app\n"
.. "See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem."
)
)
end
local function areHookInputsEqual(nextDeps: Array<any>, prevDeps: Array<any>)
if __DEV__ then
if ignorePreviousDependencies then
return false
end
end
if prevDeps == nil then
if __DEV__ then
console.error(
"%s received a final argument during this render, but not during "
.. "the previous render. Even though the final argument is optional, "
.. "its type cannot change between renders.",
currentHookNameInDev
)
end
return false
end
local nextDepsLength = getHighestIndex(nextDeps)
local prevDepsLength = getHighestIndex(prevDeps)
if nextDepsLength ~= prevDepsLength then
return false
end
local minDependencyCount = math.min(prevDepsLength, nextDepsLength)
for i = 1, minDependencyCount do
if is(nextDeps[i], prevDeps[i]) then
continue
end
return false
end
return true
end
exports.bailoutHooks = function(current: Fiber, workInProgress: Fiber, lanes: Lanes)
workInProgress.updateQueue = current.updateQueue
if __DEV__ and enableDoubleInvokingEffects then
workInProgress.flags = bit32.band(
workInProgress.flags,
bit32.bnot(
bit32.bor(
MountPassiveDevEffect,
PassiveEffect,
MountLayoutDevEffect,
UpdateEffect
)
)
)
else
workInProgress.flags = bit32.band(
workInProgress.flags,
bit32.bnot(bit32.bor(PassiveEffect, UpdateEffect))
)
end
current.lanes = removeLanes(current.lanes, lanes)
end
local _isUpdatingOpaqueValueInRenderPhase = false
exports.resetHooksAfterThrow = function(): ()
ReactCurrentDispatcher.current = exports.ContextOnlyDispatcher
if didScheduleRenderPhaseUpdate then
local hook: any = currentlyRenderingFiber.memoizedState
while hook ~= nil do
local queue = hook.queue
if queue ~= nil then
queue.pending = nil
end
hook = hook.next
end
didScheduleRenderPhaseUpdate = false
end
renderLanes = NoLanes
currentlyRenderingFiber = nil :: any
currentHook = nil
workInProgressHook = nil
if __DEV__ then
hookTypesDev = nil
hookTypesUpdateIndexDev = 0
currentHookNameInDev = nil
_isUpdatingOpaqueValueInRenderPhase = false
end
didScheduleRenderPhaseUpdateDuringThisPass = false
end
local function mountWorkInProgressHook(): Hook
local hook: Hook = {
memoizedState = nil,
baseState = nil,
baseQueue = nil,
queue = nil,
next = nil,
}
if workInProgressHook == nil then
currentlyRenderingFiber.memoizedState = hook
workInProgressHook = hook
else
workInProgressHook.next = hook
workInProgressHook = hook
end
return workInProgressHook
end
local function updateWorkInProgressHook(): Hook
local nextCurrentHook
if currentHook == nil then
local current = currentlyRenderingFiber.alternate
if current ~= nil then
nextCurrentHook = current.memoizedState
else
nextCurrentHook = nil
end
else
nextCurrentHook = currentHook.next
end
local nextWorkInProgressHook: Hook
if workInProgressHook == nil then
nextWorkInProgressHook = currentlyRenderingFiber.memoizedState
else
nextWorkInProgressHook = workInProgressHook.next
end
if nextWorkInProgressHook ~= nil then
workInProgressHook = nextWorkInProgressHook
nextWorkInProgressHook = workInProgressHook.next
currentHook = nextCurrentHook
else
if nextCurrentHook == nil then
error(Error.new("Rendered more hooks than during the previous render."))
end
currentHook = nextCurrentHook
local newHook: Hook = {
memoizedState = currentHook.memoizedState,
baseState = currentHook.baseState,
baseQueue = currentHook.baseQueue,
queue = currentHook.queue,
next = nil,
}
if workInProgressHook == nil then
workInProgressHook = newHook
currentlyRenderingFiber.memoizedState = newHook
else
workInProgressHook.next = newHook
workInProgressHook = newHook
end
end
return workInProgressHook
end
function basicStateReducer<S>(state: S, action: BasicStateAction<S>): S
if type(action) == "function" then
return action(state)
else
return action
end
end
function mountReducer<S, I, A>(
reducer: (S, A) -> S,
initialArg: I,
init: ((I) -> S)?
): (S, Dispatch<A>)
local hook = mountWorkInProgressHook()
local initialState
if init ~= nil then
initialState = init(initialArg)
else
initialState = (initialArg :: any) :: S
end
hook.baseState = initialState
hook.memoizedState = hook.baseState
local queue: UpdateQueue<S, A> = {
pending = nil,
dispatch = nil,
lastRenderedReducer = reducer,
lastRenderedState = initialState :: any,
}
hook.queue = queue
local cRF = currentlyRenderingFiber
local dispatch: Dispatch<A> = function(action, ...)
dispatchAction(cRF, queue :: UpdateQueue<any, any>, action, ...)
end :: any
queue.dispatch = dispatch :: any
return hook.memoizedState, dispatch
end
function updateReducer<S, I, A>(
reducer: (S, A) -> S,
initialArg: I,
init: ((I) -> S)?
): (S, Dispatch<A>)
local hook = updateWorkInProgressHook()
local queue = hook.queue
assert(
queue ~= nil,
"Should have a queue. This is likely a bug in React. Please file an issue."
)
queue.lastRenderedReducer = reducer
local current: Hook = currentHook
local baseQueue = current.baseQueue
local pendingQueue = queue.pending
if pendingQueue ~= nil then
if baseQueue ~= nil then
local baseFirst = baseQueue.next
local pendingFirst = pendingQueue.next
baseQueue.next = pendingFirst
pendingQueue.next = baseFirst
end
baseQueue = pendingQueue
current.baseQueue = baseQueue
queue.pending = nil
end
if baseQueue ~= nil then
local first = baseQueue.next
local newState = current.baseState
local newBaseState = nil
local newBaseQueueFirst = nil
local newBaseQueueLast = nil
local update = first
repeat
local updateLane = update.lane
if bit32.band(renderLanes, updateLane) ~= updateLane then
local clone: Update<S, A> = {
lane = updateLane,
action = update.action,
eagerReducer = update.eagerReducer,
eagerState = update.eagerState,
next = nil :: any,
}
if newBaseQueueLast == nil then
newBaseQueueLast = clone
newBaseQueueFirst = newBaseQueueLast
newBaseState = newState
else
newBaseQueueLast.next = clone
newBaseQueueLast = newBaseQueueLast.next
end
currentlyRenderingFiber.lanes =
mergeLanes(currentlyRenderingFiber.lanes, updateLane)
markSkippedUpdateLanes(updateLane)
else
if newBaseQueueLast ~= nil then
local clone: Update<S, A> = {
lane = NoLane,
action = update.action,
eagerReducer = update.eagerReducer,
eagerState = update.eagerState,
next = nil :: any,
}
newBaseQueueLast.next = clone
newBaseQueueLast = newBaseQueueLast.next
end
if update.eagerReducer == reducer then
newState = update.eagerState
else
local action = update.action
newState = reducer(newState, action)
end
end
update = update.next
until update == nil or update == first
if newBaseQueueLast == nil then
newBaseState = newState
else
newBaseQueueLast.next = newBaseQueueFirst
end
if not is(newState, hook.memoizedState) then
markWorkInProgressReceivedUpdate()
end
hook.memoizedState = newState
hook.baseState = newBaseState
hook.baseQueue = newBaseQueueLast
queue.lastRenderedState = newState
end
local dispatch: Dispatch<A> = queue.dispatch :: any
return hook.memoizedState, dispatch
end
function rerenderReducer<S, I, A>(
reducer: (S, A) -> S,
initialArg: I,
init: ((I) -> S)?
): (S, Dispatch<A>)
local hook = updateWorkInProgressHook()
local queue = hook.queue
assert(
queue ~= nil,
"Should have a queue. This is likely a bug in React. Please file an issue."
)
queue.lastRenderedReducer = reducer
local dispatch: Dispatch<A> = queue.dispatch :: Dispatch<A>
local lastRenderPhaseUpdate = queue.pending
local newState = hook.memoizedState
if lastRenderPhaseUpdate ~= nil then
queue.pending = nil
local firstRenderPhaseUpdate = lastRenderPhaseUpdate.next
local update = firstRenderPhaseUpdate
repeat
local action = update.action
newState = reducer(newState, action)
update = update.next
until update == firstRenderPhaseUpdate
if not is(newState, hook.memoizedState) then
markWorkInProgressReceivedUpdate()
end
hook.memoizedState = newState
if hook.baseQueue == nil then
hook.baseState = newState
end
queue.lastRenderedState = newState
end
return newState, dispatch
end
type MutableSourceMemoizedState<Source, Snapshot> = {
refs: {
getSnapshot: MutableSourceGetSnapshotFn<Source, Snapshot>,
setSnapshot: (Snapshot) -> (),
},
source: MutableSource<any>,
subscribe: MutableSourceSubscribeFn<Source, Snapshot>,
}
function readFromUnsubcribedMutableSource<Source, Snapshot>(
root: FiberRoot,
source: MutableSource<Source>,
getSnapshot: MutableSourceGetSnapshotFn<
Source,
Snapshot
>
): Snapshot
if __DEV__ then
warnAboutMultipleRenderersDEV(source)
end
local getVersion = source._getVersion
local version_ = getVersion(source._source)
local isSafeToReadFromSource = false
local currentRenderVersion = getWorkInProgressVersion(source)
if currentRenderVersion ~= nil then
isSafeToReadFromSource = currentRenderVersion == version_
else
isSafeToReadFromSource = isSubsetOfLanes(renderLanes, root.mutableReadLanes)
if isSafeToReadFromSource then
setWorkInProgressVersion(source, version_)
end
end
if isSafeToReadFromSource then
local snapshot = getSnapshot(source._source)
if __DEV__ then
if type(snapshot :: any) == "function" then
console.error(
"Mutable source should not return a function as the snapshot value. "
.. "Functions may close over mutable values and cause tearing."
)
end
end
return snapshot
else
markSourceAsDirty(source)
error(
Error.new(
"Cannot read from mutable source during the current render without tearing. This is a bug in React. Please file an issue."
)
)
end
end
function useMutableSource<Source, Snapshot>(
hook: Hook,
source: MutableSource<Source>,
getSnapshot: MutableSourceGetSnapshotFn<
Source,
Snapshot
>,
subscribe: MutableSourceSubscribeFn<
Source,
Snapshot
>
): Snapshot
local root: FiberRoot = getWorkInProgressRoot()
invariant(
root ~= nil,
"Expected a work-in-progress root. This is a bug in React. Please file an issue."
)
local getVersion = source._getVersion
local version_ = getVersion(source._source)
local dispatcher = ReactCurrentDispatcher.current
assert(dispatcher ~= nil, "dispatcher was nil, this is a bug in React")
local currentSnapshot, setSnapshot = dispatcher.useState(function()
return readFromUnsubcribedMutableSource(root, source, getSnapshot)
end)
local snapshot = currentSnapshot
local stateHook = workInProgressHook
local memoizedState: MutableSourceMemoizedState<any, any> = hook.memoizedState
if memoizedState.refs == nil then
error(tostring(debug.traceback()))
end
local refs = memoizedState.refs
local prevGetSnapshot = refs.getSnapshot
local prevSource = memoizedState.source
local prevSubscribe = memoizedState.subscribe
local fiber = currentlyRenderingFiber
hook.memoizedState = {
refs = refs,
source = source,
subscribe = subscribe,
}
dispatcher.useEffect(function()
refs.getSnapshot = getSnapshot
refs.setSnapshot = setSnapshot
local maybeNewVersion = getVersion(source._source)
if not is(version_, maybeNewVersion) then
local maybeNewSnapshot = getSnapshot(source._source)
if __DEV__ then
if type(maybeNewSnapshot :: any) == "function" then
console.error(
"Mutable source should not return a function as the snapshot value. "
.. "Functions may close over mutable values and cause tearing."
)
end
end
if not is(snapshot, maybeNewSnapshot) then
setSnapshot(maybeNewSnapshot)
local lane = requestUpdateLane(fiber)
markRootMutableRead(root, lane)
end
markRootEntangled(root, root.mutableReadLanes)
end
end, { getSnapshot, source, subscribe } :: Array<any>)
dispatcher.useEffect(function()
local handleChange = function()
local latestGetSnapshot = refs.getSnapshot
local latestSetSnapshot = refs.setSnapshot
local ok, result = pcall(function()
latestSetSnapshot(latestGetSnapshot(source._source))
local lane = requestUpdateLane(fiber)
markRootMutableRead(root, lane)
end)
if not ok then
latestSetSnapshot(function()
error(result)
end)
end
end
local unsubscribe = subscribe(source._source, handleChange)
if __DEV__ then
if type(unsubscribe) ~= "function" then
console.error(
"Mutable source subscribe function must return an unsubscribe function."
)
end
end
return unsubscribe
end, { source, subscribe } :: Array<any>)
if
not is(prevGetSnapshot, getSnapshot)
or not is(prevSource, source)
or not is(prevSubscribe, subscribe)
then
local newQueue = {
pending = nil,
dispatch = nil,
lastRenderedReducer = basicStateReducer,
lastRenderedState = snapshot,
}
local cRF = currentlyRenderingFiber
setSnapshot = function(...)
dispatchAction(cRF, newQueue, ...)
end :: any
newQueue.dispatch = setSnapshot :: any
stateHook.queue = newQueue
stateHook.baseQueue = nil
snapshot = readFromUnsubcribedMutableSource(root, source, getSnapshot)
stateHook.baseState = snapshot
stateHook.memoizedState = stateHook.baseState
end
return snapshot
end
function mountMutableSource<Source, Snapshot>(
source: MutableSource<Source>,
getSnapshot: MutableSourceGetSnapshotFn<
Source,
Snapshot
>,
subscribe: MutableSourceSubscribeFn<
Source,
Snapshot
>
): Snapshot
local hook = mountWorkInProgressHook()
hook.memoizedState = {
refs = {
getSnapshot = getSnapshot,
setSnapshot = nil,
},
source = source,
subscribe = subscribe,
}
return useMutableSource(hook, source, getSnapshot, subscribe)
end
function updateMutableSource<Source, Snapshot>(
source: MutableSource<Source>,
getSnapshot: MutableSourceGetSnapshotFn<
Source,
Snapshot
>,
subscribe: MutableSourceSubscribeFn<
Source,
Snapshot
>
): Snapshot
local hook = updateWorkInProgressHook()
return useMutableSource(hook, source, getSnapshot, subscribe)
end
function mountState<S>(initialState: (() -> S) | S): (S, Dispatch<BasicStateAction<S>>)
local hook = mountWorkInProgressHook()
if type(initialState) == "function" then
local initialStateAsFunction: () -> S = initialState
initialState = initialStateAsFunction()
end
hook.baseState = initialState
hook.memoizedState = hook.baseState
local queue: UpdateQueue<S, BasicStateAction<S>> = {
pending = nil,
dispatch = nil,
lastRenderedReducer = nil,
lastRenderedState = initialState :: any,
}
queue.lastRenderedReducer = basicStateReducer
hook.queue = queue
local cRF = currentlyRenderingFiber
local dispatch: Dispatch<BasicStateAction<S>> = function(action, ...)
dispatchAction(cRF, queue :: UpdateQueue<any, any>, action, ...)
end :: any
queue.dispatch = dispatch
return hook.memoizedState, dispatch
end
function updateState<S>(initialState: (() -> S) | S): (S, Dispatch<BasicStateAction<S>>)
return updateReducer(basicStateReducer, initialState)
end
function rerenderState<S>(initialState: (() -> S) | S): (S, Dispatch<BasicStateAction<S>>)
return rerenderReducer(basicStateReducer, initialState)
end
local function pushEffect(tag, create, destroy, deps)
local effect: Effect = {
tag = tag,
create = create,
destroy = destroy,
deps = deps,
next = nil :: any,
}
local componentUpdateQueue: FunctionComponentUpdateQueue =
currentlyRenderingFiber.updateQueue :: any
if componentUpdateQueue == nil then
componentUpdateQueue = {
lastEffect = nil,
}
currentlyRenderingFiber.updateQueue = componentUpdateQueue
effect.next = effect
componentUpdateQueue.lastEffect = effect
else
local lastEffect = componentUpdateQueue.lastEffect
if lastEffect == nil then
componentUpdateQueue.lastEffect = effect
effect.next = effect
else
local firstEffect = lastEffect.next
lastEffect.next = effect
effect.next = firstEffect
componentUpdateQueue.lastEffect = effect
end
end
return effect
end
function mountBinding<T>(initialValue: T): (ReactBinding<T>, ReactBindingUpdater<T>)
local hook = mountWorkInProgressHook()
local value, updateValue = createBinding(initialValue)
hook.memoizedState = { value :: any, updateValue :: any }
return value, updateValue
end
function updateBinding<T>(initialValue: T): (ReactBinding<T>, ReactBindingUpdater<T>)
local hook = updateWorkInProgressHook()
return unpack(hook.memoizedState)
end
function mountRef<T>(initialValue: T): { current: T }
local hook = mountWorkInProgressHook()
local ref: any = createRef()
ref.current = initialValue
hook.memoizedState = ref
return ref
end
function updateRef<T>(initialValue: T): { current: T }
local hook = updateWorkInProgressHook()
return hook.memoizedState
end
local function mountEffectImpl(fiberFlags, hookFlags, create, deps): ()
local hook = mountWorkInProgressHook()
local nextDeps = deps
currentlyRenderingFiber.flags = bit32.bor(currentlyRenderingFiber.flags, fiberFlags)
hook.memoizedState =
pushEffect(bit32.bor(HookHasEffect, hookFlags), create, nil, nextDeps)
end
function updateEffectImpl(fiberFlags, hookFlags, create, deps: Array<any>?): ()
local hook = updateWorkInProgressHook()
local nextDeps = deps
local destroy
if currentHook ~= nil then
local prevEffect = currentHook.memoizedState
destroy = prevEffect.destroy
if nextDeps ~= nil then
local prevDeps = prevEffect.deps
if areHookInputsEqual(nextDeps, prevDeps) then
hook.memoizedState = pushEffect(hookFlags, create, destroy, nextDeps)
return
end
end
end
currentlyRenderingFiber.flags = bit32.bor(currentlyRenderingFiber.flags, fiberFlags)
hook.memoizedState =
pushEffect(bit32.bor(HookHasEffect, hookFlags), create, destroy, nextDeps)
end
local function mountEffect(
create: (() -> ()) | (() -> () -> ()),
deps: Array<any>?
): ()
if __DEV__ then
if type(_G.jest) ~= "nil" or ReactGlobals.__TESTEZ_RUNNING_TEST__ then
warnIfNotCurrentlyActingEffectsInDEV(currentlyRenderingFiber)
end
end
if __DEV__ and enableDoubleInvokingEffects then
mountEffectImpl(
bit32.bor(MountPassiveDevEffect, PassiveEffect, PassiveStaticEffect),
HookPassive,
create,
deps
)
else
mountEffectImpl(
bit32.bor(PassiveEffect, PassiveStaticEffect),
HookPassive,
create,
deps
)
end
end
local function updateEffect(
create: (() -> ()) | (() -> () -> ()),
deps: Array<any>?
): ()
if __DEV__ then
if type(_G.jest) ~= "nil" or ReactGlobals.__TESTEZ_RUNNING_TEST__ then
warnIfNotCurrentlyActingEffectsInDEV(currentlyRenderingFiber)
end
end
updateEffectImpl(PassiveEffect, HookPassive, create, deps)
end
local function mountLayoutEffect(
create: (() -> ()) | (() -> () -> ()),
deps: Array<any>?
): ()
if __DEV__ and enableDoubleInvokingEffects then
mountEffectImpl(
bit32.bor(MountLayoutDevEffect, UpdateEffect),
HookLayout,
create,
deps
)
else
mountEffectImpl(UpdateEffect, HookLayout, create, deps)
end
end
local function updateLayoutEffect(
create: (() -> ()) | (() -> () -> ()),
deps: Array<any>?
): ()
updateEffectImpl(UpdateEffect, HookLayout, create, deps)
end
function imperativeHandleEffect<T>(
create: () -> T,
ref: { current: T | nil } | ((inst: T | nil) -> ...any) | nil
): nil | () -> ...any
if ref ~= nil and type(ref) == "function" then
local refCallback = ref
local inst = create()
refCallback(inst)
return function()
return refCallback(nil)
end
elseif ref ~= nil then
local refObject = ref :: any
if __DEV__ then
local isRefObject = getmetatable(refObject) ~= nil
and #Object.keys(refObject) == 0
if not isRefObject then
console.error(
"Expected useImperativeHandle() first argument to either be a "
.. "ref callback or React.createRef() object. Instead received: %s.",
"an object with keys {"
.. Array.join(Object.keys(refObject), ", ")
.. "}"
)
end
end
local inst = create()
refObject.current = inst
return function()
refObject.current = nil
end
else
return nil
end
end
function mountImperativeHandle<T>(
ref: { current: T | nil } | ((inst: T | nil) -> ...any) | nil,
create: () -> T,
deps: Array<any> | nil
): ()
if __DEV__ then
if type(create) ~= "function" then
console.error(
"Expected useImperativeHandle() second argument to be a function "
.. "that creates a handle. Instead received: %s.",
if create ~= nil then type(create) else "nil"
)
end
end
local effectDeps = if deps ~= nil then Array.concat(deps, { ref }) else nil
if __DEV__ and enableDoubleInvokingEffects then
return mountEffectImpl(
bit32.bor(MountLayoutDevEffect, UpdateEffect),
HookLayout,
function()
return imperativeHandleEffect(create, ref)
end,
effectDeps
)
else
return mountEffectImpl(UpdateEffect, HookLayout, function()
return imperativeHandleEffect(create, ref)
end, effectDeps)
end
end
function updateImperativeHandle<T>(
ref: { current: T | nil } | ((inst: T | nil) -> ...any) | nil,
create: () -> T,
deps: Array<any> | nil
): ()
if __DEV__ then
if type(create) ~= "function" then
local errorArg = "nil"
if create then
errorArg = type(create)
end
console.error(
"Expected useImperativeHandle() second argument to be a function "
.. "that creates a handle. Instead received: %s.",
errorArg
)
end
end
local effectDeps
if deps ~= nil then
effectDeps = table.clone(deps)
table.insert(effectDeps, ref)
end
return updateEffectImpl(UpdateEffect, HookLayout, function()
return imperativeHandleEffect(create, ref)
end, effectDeps)
end
function mountDebugValue<T>(value: T, formatterFn: nil | (T) -> any): ()
end
local updateDebugValue = mountDebugValue
function mountCallback<T>(callback: T, deps: Array<any> | nil): T
local hook = mountWorkInProgressHook()
local nextDeps = deps
hook.memoizedState = { callback :: any, nextDeps :: any }
return callback
end
function updateCallback<T>(callback: T, deps: Array<any> | nil): T
local hook = updateWorkInProgressHook()
local nextDeps = deps
local prevState = hook.memoizedState
if prevState ~= nil then
if nextDeps ~= nil then
local prevDeps: Array<any> = prevState[2]
if areHookInputsEqual(nextDeps, prevDeps) then
return prevState[1]
end
end
end
hook.memoizedState = { callback :: any, nextDeps :: any }
return callback
end
function mountMemo<T...>(nextCreate: () -> T..., deps: Array<any> | nil): ...any
local hook = mountWorkInProgressHook()
local nextDeps = deps
local nextValue = { nextCreate() }
hook.memoizedState = { nextValue :: any, nextDeps }
return unpack(nextValue)
end
function updateMemo<T...>(nextCreate: () -> T..., deps: Array<any> | nil): ...any
local hook = updateWorkInProgressHook()
local nextDeps = deps
local prevState = hook.memoizedState
if prevState ~= nil then
if nextDeps ~= nil then
local prevDeps: Array<any> = prevState[2]
if areHookInputsEqual(nextDeps, prevDeps) then
return unpack(prevState[1])
end
end
end
local nextValue = { nextCreate() }
hook.memoizedState = { nextValue :: any, nextDeps }
return unpack(nextValue)
end
local isUpdatingOpaqueValueInRenderPhase = false
exports.getIsUpdatingOpaqueValueInRenderPhaseInDEV = function(): boolean?
if __DEV__ then
return isUpdatingOpaqueValueInRenderPhase
end
return nil
end
function mountOpaqueIdentifier()
local makeId
if __DEV__ then
console.warn("!!! unimplemented: warnOnOpaqueIdentifierAccessInDEV")
else
makeId = makeClientId
end
if getIsHydrating() then
unimplemented("ReactFiberHooks: getIsHydrating() true")
return nil
else
local id = makeId()
mountState(id)
return id
end
end
function updateOpaqueIdentifier(): OpaqueIDType
local id, _ = updateState(nil)
return id
end
function rerenderOpaqueIdentifier(): OpaqueIDType
local id, _ = rerenderState(nil)
return id
end
function dispatchAction<S, A>(fiber: Fiber, queue: UpdateQueue<S, A>, action: A, ...): ()
if __DEV__ then
local childrenLength = select("#", ...)
local extraArg
if childrenLength == 1 then
extraArg = select(1, ...)
end
if type(extraArg) == "function" then
console.error(
"State updates from the useState() and useReducer() Hooks don't support the "
.. "second callback argument. To execute a side effect after "
.. "rendering, declare it in the component body with useEffect()."
)
end
end
local eventTime = requestEventTime()
local lane = requestUpdateLane(fiber)
local update: Update<S, A> = {
lane = lane,
action = action,
eagerReducer = nil,
eagerState = nil,
next = nil :: any,
}
local pending = queue.pending
if pending == nil then
update.next = update
else
update.next = pending.next
pending.next = update
end
queue.pending = update
local alternate = fiber.alternate
if
fiber == currentlyRenderingFiber
or (alternate ~= nil and alternate == currentlyRenderingFiber)
then
didScheduleRenderPhaseUpdate = true
didScheduleRenderPhaseUpdateDuringThisPass = true
else
if
fiber.lanes == NoLanes and (alternate == nil or alternate.lanes == NoLanes)
then
local lastRenderedReducer = queue.lastRenderedReducer
if lastRenderedReducer ~= nil then
local prevDispatcher
if __DEV__ then
prevDispatcher = ReactCurrentDispatcher.current
ReactCurrentDispatcher.current =
InvalidNestedHooksDispatcherOnUpdateInDEV
end
local currentState: S = queue.lastRenderedState :: any
local ok, eagerState = pcall(lastRenderedReducer, currentState, action)
if ok then
update.eagerReducer = lastRenderedReducer
update.eagerState = eagerState
end
if __DEV__ then
ReactCurrentDispatcher.current = prevDispatcher
end
if is(eagerState, currentState) then
if FFlagReactCleanQueueOnUpdateBailout then
if pending == nil then
queue.pending = nil
else
pending.next = update.next
queue.pending = pending
end
end
return
end
if not ok then
end
end
end
if __DEV__ then
if type(_G.jest) ~= "nil" or ReactGlobals.__TESTEZ_RUNNING_TEST__ then
warnIfNotScopedWithMatchingAct(fiber)
warnIfNotCurrentlyActingUpdatesInDEV(fiber)
end
end
scheduleUpdateOnFiber(fiber, lane, eventTime)
end
if __DEV__ then
if enableDebugTracing then
if bit32.band(fiber.mode, DebugTracingMode) ~= 0 then
local name = getComponentName(fiber.type) or "Unknown"
logStateUpdateScheduled(name, lane, action)
end
end
end
if enableSchedulingProfiler then
markStateUpdateScheduled(fiber, lane)
end
return
end
local ContextOnlyDispatcher: Dispatcher = {
readContext = readContext,
useCallback = throwInvalidHookError :: any,
useContext = throwInvalidHookError :: any,
useEffect = throwInvalidHookError :: any,
useImperativeHandle = throwInvalidHookError :: any,
useLayoutEffect = throwInvalidHookError :: any,
useMemo = throwInvalidHookError :: any,
useReducer = throwInvalidHookError :: any,
useRef = throwInvalidHookError :: any,
useBinding = throwInvalidHookError :: any,
useState = throwInvalidHookError :: any,
useDebugValue = throwInvalidHookError :: any,
useMutableSource = throwInvalidHookError :: any,
useOpaqueIdentifier = throwInvalidHookError :: any,
unstable_isNewReconciler = enableNewReconciler,
}
exports.ContextOnlyDispatcher = ContextOnlyDispatcher
local HooksDispatcherOnMount: Dispatcher = {
readContext = readContext,
useCallback = mountCallback,
useContext = readContext,
useEffect = mountEffect,
useImperativeHandle = mountImperativeHandle,
useLayoutEffect = mountLayoutEffect,
useMemo = mountMemo :: any,
useReducer = mountReducer,
useRef = mountRef,
useBinding = mountBinding,
useState = mountState,
useDebugValue = mountDebugValue,
useMutableSource = mountMutableSource,
useOpaqueIdentifier = mountOpaqueIdentifier,
unstable_isNewReconciler = enableNewReconciler,
}
local HooksDispatcherOnUpdate: Dispatcher = {
readContext = readContext,
useCallback = updateCallback,
useContext = readContext,
useEffect = updateEffect,
useImperativeHandle = updateImperativeHandle,
useLayoutEffect = updateLayoutEffect,
useMemo = updateMemo :: any,
useReducer = updateReducer,
useRef = updateRef,
useBinding = updateBinding,
useState = updateState,
useDebugValue = updateDebugValue,
useMutableSource = updateMutableSource,
useOpaqueIdentifier = updateOpaqueIdentifier,
unstable_isNewReconciler = enableNewReconciler,
}
local HooksDispatcherOnRerender: Dispatcher = {
readContext = readContext,
useCallback = updateCallback,
useContext = readContext,
useEffect = updateEffect,
useImperativeHandle = updateImperativeHandle,
useLayoutEffect = updateLayoutEffect,
useMemo = updateMemo :: any,
useReducer = rerenderReducer,
useRef = updateRef,
useBinding = updateBinding,
useState = rerenderState,
useDebugValue = updateDebugValue,
useMutableSource = updateMutableSource,
useOpaqueIdentifier = rerenderOpaqueIdentifier,
unstable_isNewReconciler = enableNewReconciler,
}
if __DEV__ then
local warnInvalidContextAccess = function()
console.error(
"Context can only be read while React is rendering. "
.. "In classes, you can read it in the render method or getDerivedStateFromProps. "
.. "In function components, you can read it directly in the function body, but not "
.. "inside Hooks like useReducer() or useMemo()."
)
end
local warnInvalidHookAccess = function()
console.error(
"Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks. "
.. "You can only call Hooks at the top level of your React function. "
.. "For more information, see "
.. "https://reactjs.org/link/rules-of-hooks"
)
end
HooksDispatcherOnMountInDEV = {
readContext = function<T>(
context: ReactContext<T>,
observedBits: number | boolean | nil
): T
return readContext(context, observedBits)
end,
useCallback = function<T>(callback: T, deps: Array<any> | nil): T
currentHookNameInDev = "useCallback"
mountHookTypesDev()
checkDepsAreArrayDev(deps)
return mountCallback(callback, deps)
end,
useContext = function<T>(
context: ReactContext<T>,
observedBits: nil | number | boolean
): T
currentHookNameInDev = "useContext"
mountHookTypesDev()
return readContext(context, observedBits)
end,
useEffect = function(
create: (() -> ()) | (() -> () -> ()),
deps: Array<any>?
): ()
currentHookNameInDev = "useEffect"
mountHookTypesDev()
checkDepsAreArrayDev(deps)
return mountEffect(create, deps)
end,
useImperativeHandle = function<T>(
ref: { current: T | nil } | ((inst: T | nil) -> ...any) | nil,
create: () -> T,
deps: Array<any> | nil
): ()
currentHookNameInDev = "useImperativeHandle"
mountHookTypesDev()
checkDepsAreArrayDev(deps)
return mountImperativeHandle(ref, create, deps)
end,
useLayoutEffect = function(
create: (() -> ()) | (() -> () -> ()),
deps: Array<any>?
): ()
currentHookNameInDev = "useLayoutEffect"
mountHookTypesDev()
checkDepsAreArrayDev(deps)
return mountLayoutEffect(create, deps)
end,
useMemo = function<T...>(create: () -> T..., deps: Array<any> | nil): ...any
currentHookNameInDev = "useMemo"
mountHookTypesDev()
checkDepsAreArrayDev(deps)
local prevDispatcher = ReactCurrentDispatcher.current
ReactCurrentDispatcher.current = InvalidNestedHooksDispatcherOnMountInDEV
local results = { pcall(mountMemo, create, deps) }
ReactCurrentDispatcher.current = prevDispatcher
if not results[1] then
error(results[2])
end
return unpack(results, 2)
end :: any,
useReducer = function<S, I, A>(
reducer: (S, A) -> S,
initialArg: I,
init: ((I) -> S)?
): (S, Dispatch<A>)
currentHookNameInDev = "useReducer"
mountHookTypesDev()
local prevDispatcher = ReactCurrentDispatcher.current
ReactCurrentDispatcher.current = InvalidNestedHooksDispatcherOnMountInDEV
local ok, result, setResult = pcall(mountReducer, reducer, initialArg, init)
ReactCurrentDispatcher.current = prevDispatcher
if not ok then
error(result)
end
return result, setResult
end,
useRef = function<T>(initialValue: T): { current: T }
currentHookNameInDev = "useRef"
mountHookTypesDev()
return mountRef(initialValue)
end,
useBinding = function<T>(initialValue: T): (ReactBinding<T>, ReactBindingUpdater<T>)
currentHookNameInDev = "useBinding"
mountHookTypesDev()
return mountBinding(initialValue)
end,
useState = function<S>(
initialState: (() -> S) | S
): (S, Dispatch<BasicStateAction<S>>)
currentHookNameInDev = "useState"
mountHookTypesDev()
local prevDispatcher = ReactCurrentDispatcher.current
ReactCurrentDispatcher.current = InvalidNestedHooksDispatcherOnMountInDEV
local ok, result, setResult = pcall(mountState, initialState)
ReactCurrentDispatcher.current = prevDispatcher
if not ok then
error(result)
end
return result, setResult
end,
useDebugValue = function<T>(value: T, formatterFn: ((value: T) -> any)?): ()
currentHookNameInDev = "useDebugValue"
mountHookTypesDev()
return mountDebugValue(value, formatterFn)
end,
useMutableSource = function<Source, Snapshot>(
source: MutableSource<Source>,
getSnapshot: MutableSourceGetSnapshotFn<
Source,
Snapshot
>,
subscribe: MutableSourceSubscribeFn<
Source,
Snapshot
>
): Snapshot
currentHookNameInDev = "useMutableSource"
mountHookTypesDev()
return mountMutableSource(source, getSnapshot, subscribe)
end,
useOpaqueIdentifier = function()
currentHookNameInDev = "useOpaqueIdentifier"
mountHookTypesDev()
return mountOpaqueIdentifier()
end,
unstable_isNewReconciler = enableNewReconciler,
}
HooksDispatcherOnMountWithHookTypesInDEV = {
readContext = function<T>(
context: ReactContext<T>,
observedBits: number | boolean | nil
): T
return readContext(context, observedBits)
end,
useCallback = function<T>(callback: T, deps: Array<any> | nil): T
currentHookNameInDev = "useCallback"
updateHookTypesDev()
checkDepsAreArrayDev(deps)
return mountCallback(callback, deps)
end,
useContext = function<T>(
context: ReactContext<T>,
observedBits: nil | number | boolean
): T
currentHookNameInDev = "useContext"
updateHookTypesDev()
return readContext(context, observedBits)
end,
useEffect = function(
create: (() -> ()) | (() -> () -> ()),
deps: Array<any>?
): ()
currentHookNameInDev = "useEffect"
updateHookTypesDev()
return mountEffect(create, deps)
end,
useImperativeHandle = function<T>(
ref: { current: T | nil } | ((inst: T | nil) -> ...any) | nil,
create: () -> T,
deps: Array<any> | nil
): ()
currentHookNameInDev = "useImperativeHandle"
updateHookTypesDev()
return mountImperativeHandle(ref, create, deps)
end,
useLayoutEffect = function(
create: (() -> ()) | (() -> () -> ()),
deps: Array<any>?
): ()
currentHookNameInDev = "useLayoutEffect"
updateHookTypesDev()
return mountLayoutEffect(create, deps)
end,
useMemo = function<T...>(create: () -> T..., deps: Array<any> | nil): ...any
currentHookNameInDev = "useMemo"
updateHookTypesDev()
local prevDispatcher = ReactCurrentDispatcher.current
ReactCurrentDispatcher.current = InvalidNestedHooksDispatcherOnMountInDEV
local results = { pcall(mountMemo, create, deps) }
ReactCurrentDispatcher.current = prevDispatcher
if not results[1] then
error(results[2])
end
return unpack(results, 2)
end :: any,
useReducer = function<S, I, A>(
reducer: (S, A) -> S,
initialArg: I,
init: ((I) -> S)?
): (S, Dispatch<A>)
currentHookNameInDev = "useReducer"
updateHookTypesDev()
local prevDispatcher = ReactCurrentDispatcher.current
ReactCurrentDispatcher.current = InvalidNestedHooksDispatcherOnMountInDEV
local ok, result, setResult = pcall(mountReducer, reducer, initialArg, init)
ReactCurrentDispatcher.current = prevDispatcher
if not ok then
error(result)
end
return result, setResult
end,
useRef = function<T>(initialValue: T): { current: T }
currentHookNameInDev = "useRef"
updateHookTypesDev()
return mountRef(initialValue)
end,
useBinding = function<T>(initialValue: T): (ReactBinding<T>, ReactBindingUpdater<T>)
currentHookNameInDev = "useBinding"
updateHookTypesDev()
return mountBinding(initialValue)
end,
useState = function<S>(
initialState: (() -> S) | S
): (S, Dispatch<BasicStateAction<S>>)
currentHookNameInDev = "useState"
updateHookTypesDev()
local prevDispatcher = ReactCurrentDispatcher.current
ReactCurrentDispatcher.current = InvalidNestedHooksDispatcherOnMountInDEV
local ok, result, setResult = pcall(mountState, initialState)
ReactCurrentDispatcher.current = prevDispatcher
if not ok then
error(result)
end
return result, setResult
end,
useDebugValue = function<T>(value: T, formatterFn: ((value: T) -> any)?): ()
currentHookNameInDev = "useDebugValue"
updateHookTypesDev()
return mountDebugValue(value, formatterFn)
end,
useMutableSource = function<Source, Snapshot>(
source: MutableSource<Source>,
getSnapshot: MutableSourceGetSnapshotFn<
Source,
Snapshot
>,
subscribe: MutableSourceSubscribeFn<
Source,
Snapshot
>
): Snapshot
currentHookNameInDev = "useMutableSource"
updateHookTypesDev()
return mountMutableSource(source, getSnapshot, subscribe)
end,
useOpaqueIdentifier = function()
currentHookNameInDev = "useOpaqueIdentifier"
updateHookTypesDev()
return mountOpaqueIdentifier()
end,
unstable_isNewReconciler = enableNewReconciler,
}
HooksDispatcherOnUpdateInDEV = {
readContext = function<T>(
context: ReactContext<T>,
observedBits: number | boolean | nil
): T
return readContext(context, observedBits)
end,
useCallback = function<T>(callback: T, deps: Array<any> | nil): T
currentHookNameInDev = "useCallback"
updateHookTypesDev()
return updateCallback(callback, deps)
end,
useContext = function<T>(
context: ReactContext<T>,
observedBits: nil | number | boolean
): T
currentHookNameInDev = "useContext"
updateHookTypesDev()
return readContext(context, observedBits)
end,
useEffect = function(
create: (() -> ()) | (() -> () -> ()),
deps: Array<any>?
): ()
currentHookNameInDev = "useEffect"
updateHookTypesDev()
return updateEffect(create, deps)
end,
useImperativeHandle = function<T>(
ref: { current: T | nil } | ((inst: T | nil) -> ...any) | nil,
create: () -> T,
deps: Array<any> | nil
): ()
currentHookNameInDev = "useImperativeHandle"
updateHookTypesDev()
return updateImperativeHandle(ref, create, deps)
end,
useLayoutEffect = function(
create: (() -> ()) | (() -> () -> ()),
deps: Array<any>?
): ()
currentHookNameInDev = "useLayoutEffect"
updateHookTypesDev()
return updateLayoutEffect(create, deps)
end,
useMemo = function<T...>(create: () -> T..., deps: Array<any> | nil): ...any
currentHookNameInDev = "useMemo"
updateHookTypesDev()
local prevDispatcher = ReactCurrentDispatcher.current
ReactCurrentDispatcher.current = InvalidNestedHooksDispatcherOnUpdateInDEV
local results = { pcall(updateMemo, create, deps) }
ReactCurrentDispatcher.current = prevDispatcher
if not results[1] then
error(results[2])
end
return unpack(results, 2)
end :: any,
useReducer = function<S, I, A>(
reducer: (S, A) -> S,
initialArg: I,
init: ((I) -> S)?
): (S, Dispatch<A>)
currentHookNameInDev = "useReducer"
updateHookTypesDev()
local prevDispatcher = ReactCurrentDispatcher.current
ReactCurrentDispatcher.current = InvalidNestedHooksDispatcherOnUpdateInDEV
local ok, result, setResult = pcall(updateReducer, reducer, initialArg, init)
ReactCurrentDispatcher.current = prevDispatcher
if not ok then
error(result)
end
return result, setResult
end,
useRef = function<T>(initialValue: T): { current: T }
currentHookNameInDev = "useRef"
updateHookTypesDev()
return updateRef(initialValue)
end,
useBinding = function<T>(initialValue: T): (ReactBinding<T>, ReactBindingUpdater<T>)
currentHookNameInDev = "useBinding"
updateHookTypesDev()
return updateBinding(initialValue)
end,
useState = function<S>(
initialState: (() -> S) | S
): (S, Dispatch<BasicStateAction<S>>)
currentHookNameInDev = "useState"
updateHookTypesDev()
local prevDispatcher = ReactCurrentDispatcher.current
ReactCurrentDispatcher.current = InvalidNestedHooksDispatcherOnUpdateInDEV
local ok, result, setResult = pcall(updateState, initialState)
ReactCurrentDispatcher.current = prevDispatcher
if not ok then
error(result)
end
return result, setResult
end,
useDebugValue = function<T>(value: T, formatterFn: ((value: T) -> any)?): ()
currentHookNameInDev = "useDebugValue"
updateHookTypesDev()
return updateDebugValue(value, formatterFn)
end,
useMutableSource = function<Source, Snapshot>(
source: MutableSource<Source>,
getSnapshot: MutableSourceGetSnapshotFn<
Source,
Snapshot
>,
subscribe: MutableSourceSubscribeFn<
Source,
Snapshot
>
): Snapshot
currentHookNameInDev = "useMutableSource"
updateHookTypesDev()
return updateMutableSource(source, getSnapshot, subscribe)
end,
useOpaqueIdentifier = function(): OpaqueIDType
currentHookNameInDev = "useOpaqueIdentifier"
updateHookTypesDev()
return updateOpaqueIdentifier()
end,
unstable_isNewReconciler = enableNewReconciler,
}
HooksDispatcherOnRerenderInDEV = {
readContext = function<T>(
context: ReactContext<T>,
observedBits: number | boolean | nil
): T
return readContext(context, observedBits)
end,
useCallback = function<T>(callback: T, deps: Array<any> | nil): T
currentHookNameInDev = "useCallback"
updateHookTypesDev()
return updateCallback(callback, deps)
end,
useContext = function<T>(
context: ReactContext<T>,
observedBits: nil | number | boolean
): T
currentHookNameInDev = "useContext"
updateHookTypesDev()
return readContext(context, observedBits)
end,
useEffect = function(
create: (() -> ()) | (() -> () -> ()),
deps: Array<any> | nil
): ()
currentHookNameInDev = "useEffect"
updateHookTypesDev()
return updateEffect(create, deps)
end,
useImperativeHandle = function<T>(
ref: { current: T | nil } | ((inst: T | nil) -> ...any) | nil,
create: () -> T,
deps: Array<any> | nil
): ()
currentHookNameInDev = "useImperativeHandle"
updateHookTypesDev()
return updateImperativeHandle(ref, create, deps)
end,
useLayoutEffect = function(
create: (() -> ()) | (() -> () -> ()),
deps: Array<any>?
): ()
currentHookNameInDev = "useLayoutEffect"
updateHookTypesDev()
return updateLayoutEffect(create, deps)
end,
useMemo = function<T...>(create: () -> T..., deps: Array<any> | nil): ...any
currentHookNameInDev = "useMemo"
updateHookTypesDev()
local prevDispatcher = ReactCurrentDispatcher.current
ReactCurrentDispatcher.current = InvalidNestedHooksDispatcherOnRerenderInDEV
local results = { pcall(updateMemo, create, deps) }
ReactCurrentDispatcher.current = prevDispatcher
if not results[1] then
error(results[2])
end
return unpack(results, 2)
end :: any,
useReducer = function<S, I, A>(
reducer: (S, A) -> S,
initialArg: I,
init: ((I) -> S)?
): (S, Dispatch<A>)
currentHookNameInDev = "useReducer"
updateHookTypesDev()
local prevDispatcher = ReactCurrentDispatcher.current
ReactCurrentDispatcher.current = InvalidNestedHooksDispatcherOnRerenderInDEV
local ok, result, setResult =
pcall(rerenderReducer, reducer, initialArg, init)
ReactCurrentDispatcher.current = prevDispatcher
if not ok then
error(result)
end
return result, setResult
end,
useRef = function<T>(initialValue: T): { current: T }
currentHookNameInDev = "useRef"
updateHookTypesDev()
return updateRef(initialValue)
end,
useBinding = function<T>(initialValue: T): (ReactBinding<T>, ReactBindingUpdater<T>)
currentHookNameInDev = "useBinding"
updateHookTypesDev()
return updateBinding(initialValue)
end,
useState = function<S>(
initialState: (() -> S) | S
): (S, Dispatch<BasicStateAction<S>>)
currentHookNameInDev = "useState"
updateHookTypesDev()
local prevDispatcher = ReactCurrentDispatcher.current
ReactCurrentDispatcher.current = InvalidNestedHooksDispatcherOnRerenderInDEV
local ok, result, setResult = pcall(rerenderState, initialState)
ReactCurrentDispatcher.current = prevDispatcher
if not ok then
error(result)
end
return result, setResult
end,
useDebugValue = function<T>(value: T, formatterFn: ((value: T) -> any)?): ()
currentHookNameInDev = "useDebugValue"
updateHookTypesDev()
return updateDebugValue(value, formatterFn)
end,
useMutableSource = function<Source, Snapshot>(
source: MutableSource<Source>,
getSnapshot: MutableSourceGetSnapshotFn<
Source,
Snapshot
>,
subscribe: MutableSourceSubscribeFn<
Source,
Snapshot
>
): Snapshot
currentHookNameInDev = "useMutableSource"
updateHookTypesDev()
return updateMutableSource(source, getSnapshot, subscribe)
end,
useOpaqueIdentifier = function(): OpaqueIDType
currentHookNameInDev = "useOpaqueIdentifier"
updateHookTypesDev()
return rerenderOpaqueIdentifier()
end,
unstable_isNewReconciler = enableNewReconciler,
}
InvalidNestedHooksDispatcherOnMountInDEV = {
readContext = function<T>(
context: ReactContext<T>,
observedBits: number | boolean | nil
): T
warnInvalidContextAccess()
return readContext(context, observedBits)
end,
useCallback = function<T>(callback: T, deps: Array<any> | nil): T
currentHookNameInDev = "useCallback"
warnInvalidHookAccess()
mountHookTypesDev()
return mountCallback(callback, deps)
end,
useContext = function<T>(
context: ReactContext<T>,
observedBits: nil | number | boolean
): T
currentHookNameInDev = "useContext"
warnInvalidHookAccess()
mountHookTypesDev()
return readContext(context, observedBits)
end,
useEffect = function(
create: (() -> ()) | (() -> () -> ()),
deps: Array<any> | nil
): ()
currentHookNameInDev = "useEffect"
warnInvalidHookAccess()
mountHookTypesDev()
return mountEffect(create, deps)
end,
useImperativeHandle = function<T>(
ref: { current: T | nil } | ((inst: T | nil) -> ...any) | nil,
create: () -> T,
deps: Array<any> | nil
): ()
currentHookNameInDev = "useImperativeHandle"
warnInvalidHookAccess()
mountHookTypesDev()
return mountImperativeHandle(ref, create, deps)
end,
useLayoutEffect = function(
create: (() -> ()) | (() -> () -> ()),
deps: Array<any> | nil
): ()
currentHookNameInDev = "useLayoutEffect"
warnInvalidHookAccess()
mountHookTypesDev()
return mountLayoutEffect(create, deps)
end,
useMemo = function<T...>(create: () -> T..., deps: Array<any> | nil): ...any
currentHookNameInDev = "useMemo"
warnInvalidHookAccess()
mountHookTypesDev()
local prevDispatcher = ReactCurrentDispatcher.current
ReactCurrentDispatcher.current = InvalidNestedHooksDispatcherOnMountInDEV
local results = { pcall(mountMemo, create, deps) }
ReactCurrentDispatcher.current = prevDispatcher
if not results[1] then
error(results[2])
end
return unpack(results, 2)
end :: any,
useReducer = function<S, I, A>(
reducer: (S, A) -> S,
initialArg: I,
init: ((I) -> S)?
): (S, Dispatch<A>)
currentHookNameInDev = "useReducer"
warnInvalidHookAccess()
mountHookTypesDev()
local prevDispatcher = ReactCurrentDispatcher.current
ReactCurrentDispatcher.current = InvalidNestedHooksDispatcherOnMountInDEV
local ok, result, setResult = pcall(mountReducer, reducer, initialArg, init)
ReactCurrentDispatcher.current = prevDispatcher
if not ok then
error(result)
end
return result, setResult
end,
useRef = function<T>(initialValue: T): { current: T }
currentHookNameInDev = "useRef"
warnInvalidHookAccess()
mountHookTypesDev()
return mountRef(initialValue)
end,
useBinding = function<T>(initialValue: T): (ReactBinding<T>, ReactBindingUpdater<T>)
currentHookNameInDev = "useBinding"
warnInvalidHookAccess()
mountHookTypesDev()
return mountBinding(initialValue)
end,
useState = function<S>(
initialState: (() -> S) | S
): (S, Dispatch<BasicStateAction<S>>)
currentHookNameInDev = "useState"
warnInvalidHookAccess()
mountHookTypesDev()
local prevDispatcher = ReactCurrentDispatcher.current
ReactCurrentDispatcher.current = InvalidNestedHooksDispatcherOnMountInDEV
local ok, result, setResult = pcall(mountState, initialState)
ReactCurrentDispatcher.current = prevDispatcher
if not ok then
error(result)
end
return result, setResult
end,
useDebugValue = function<T>(value: T, formatterFn: ((value: T) -> any)?): ()
currentHookNameInDev = "useDebugValue"
warnInvalidHookAccess()
mountHookTypesDev()
return mountDebugValue(value, formatterFn)
end,
useMutableSource = function<Source, Snapshot>(
source: MutableSource<Source>,
getSnapshot: MutableSourceGetSnapshotFn<
Source,
Snapshot
>,
subscribe: MutableSourceSubscribeFn<
Source,
Snapshot
>
): Snapshot
currentHookNameInDev = "useMutableSource"
warnInvalidHookAccess()
mountHookTypesDev()
return mountMutableSource(source, getSnapshot, subscribe)
end,
useOpaqueIdentifier = function(): OpaqueIDType
currentHookNameInDev = "useOpaqueIdentifier"
warnInvalidHookAccess()
mountHookTypesDev()
return mountOpaqueIdentifier()
end,
unstable_isNewReconciler = enableNewReconciler,
}
InvalidNestedHooksDispatcherOnUpdateInDEV = {
readContext = function<T>(
context: ReactContext<T>,
observedBits: number | boolean | nil
): T
warnInvalidContextAccess()
return readContext(context, observedBits)
end,
useCallback = function<T>(callback: T, deps: Array<any> | nil): T
currentHookNameInDev = "useCallback"
warnInvalidHookAccess()
updateHookTypesDev()
return mountCallback(callback, deps)
end,
useContext = function<T>(
context: ReactContext<T>,
observedBits: nil | number | boolean
): T
currentHookNameInDev = "useContext"
warnInvalidHookAccess()
updateHookTypesDev()
return readContext(context, observedBits)
end,
useEffect = function(
create: (() -> ()) | (() -> () -> ()),
deps: Array<any> | nil
): ()
currentHookNameInDev = "useEffect"
warnInvalidHookAccess()
updateHookTypesDev()
return updateEffect(create, deps)
end,
useImperativeHandle = function<T>(
ref: { current: T | nil } | ((inst: T | nil) -> ...any) | nil,
create: () -> T,
deps: Array<any> | nil
): ()
currentHookNameInDev = "useImperativeHandle"
warnInvalidHookAccess()
updateHookTypesDev()
return updateImperativeHandle(ref, create, deps)
end,
useLayoutEffect = function(
create: (() -> ()) | (() -> () -> ()),
deps: Array<any>?
): ()
currentHookNameInDev = "useLayoutEffect"
warnInvalidHookAccess()
updateHookTypesDev()
return updateLayoutEffect(create, deps)
end,
useMemo = function<T...>(create: () -> T..., deps: Array<any> | nil): ...any
currentHookNameInDev = "useMemo"
warnInvalidHookAccess()
updateHookTypesDev()
local prevDispatcher = ReactCurrentDispatcher.current
ReactCurrentDispatcher.current = InvalidNestedHooksDispatcherOnUpdateInDEV
local results = { pcall(updateMemo, create, deps) }
ReactCurrentDispatcher.current = prevDispatcher
if not results[1] then
error(results[2])
end
return unpack(results, 2)
end :: any,
useReducer = function<S, I, A>(
reducer: (S, A) -> S,
initialArg: I,
init: ((I) -> S)?
): (S, Dispatch<A>)
currentHookNameInDev = "useReducer"
warnInvalidHookAccess()
updateHookTypesDev()
local prevDispatcher = ReactCurrentDispatcher.current
ReactCurrentDispatcher.current = InvalidNestedHooksDispatcherOnUpdateInDEV
local ok, result, setResult = pcall(updateReducer, reducer, initialArg, init)
ReactCurrentDispatcher.current = prevDispatcher
if not ok then
error(result)
end
return result, setResult
end,
useRef = function<T>(initialValue: T): { current: T }
currentHookNameInDev = "useRef"
warnInvalidHookAccess()
updateHookTypesDev()
return updateRef(initialValue)
end,
useBinding = function<T>(initialValue: T): (ReactBinding<T>, ReactBindingUpdater<T>)
currentHookNameInDev = "useBinding"
warnInvalidHookAccess()
updateHookTypesDev()
return updateBinding(initialValue)
end,
useState = function<S>(
initialState: (() -> S) | S
): (S, Dispatch<BasicStateAction<S>>)
currentHookNameInDev = "useState"
warnInvalidHookAccess()
updateHookTypesDev()
local prevDispatcher = ReactCurrentDispatcher.current
ReactCurrentDispatcher.current = InvalidNestedHooksDispatcherOnUpdateInDEV
local ok, result, setResult = pcall(updateState, initialState)
ReactCurrentDispatcher.current = prevDispatcher
if not ok then
error(result)
end
return result, setResult
end,
useDebugValue = function<T>(value: T, formatterFn: ((value: T) -> any)?): ()
currentHookNameInDev = "useDebugValue"
warnInvalidHookAccess()
updateHookTypesDev()
return updateDebugValue(value, formatterFn)
end,
useMutableSource = function<Source, Snapshot>(
source: MutableSource<Source>,
getSnapshot: MutableSourceGetSnapshotFn<
Source,
Snapshot
>,
subscribe: MutableSourceSubscribeFn<
Source,
Snapshot
>
): Snapshot
currentHookNameInDev = "useMutableSource"
warnInvalidHookAccess()
updateHookTypesDev()
return updateMutableSource(source, getSnapshot, subscribe)
end,
useOpaqueIdentifier = function(): OpaqueIDType
currentHookNameInDev = "useOpaqueIdentifier"
warnInvalidHookAccess()
updateHookTypesDev()
return updateOpaqueIdentifier()
end,
unstable_isNewReconciler = enableNewReconciler,
}
InvalidNestedHooksDispatcherOnRerenderInDEV = {
readContext = function<T>(
context: ReactContext<T>,
observedBits: number | boolean | nil
): T
warnInvalidContextAccess()
return readContext(context, observedBits)
end,
useCallback = function<T>(callback: T, deps: Array<any> | nil): T
currentHookNameInDev = "useCallback"
warnInvalidHookAccess()
updateHookTypesDev()
return updateCallback(callback, deps)
end,
useContext = function<T>(
context: ReactContext<T>,
observedBits: nil | number | boolean
): T
currentHookNameInDev = "useContext"
warnInvalidHookAccess()
updateHookTypesDev()
return readContext(context, observedBits)
end,
useEffect = function(
create: (() -> ()) | (() -> () -> ()),
deps: Array<any> | nil
): ()
currentHookNameInDev = "useEffect"
warnInvalidHookAccess()
updateHookTypesDev()
return updateEffect(create, deps)
end,
useImperativeHandle = function<T>(
ref: { current: T | nil } | ((inst: T | nil) -> ...any) | nil,
create: () -> T,
deps: Array<any> | nil
): ()
currentHookNameInDev = "useImperativeHandle"
warnInvalidHookAccess()
updateHookTypesDev()
return updateImperativeHandle(ref, create, deps)
end,
useLayoutEffect = function(
create: (() -> ()) | (() -> () -> ()),
deps: Array<any>?
): ()
currentHookNameInDev = "useLayoutEffect"
warnInvalidHookAccess()
updateHookTypesDev()
return updateLayoutEffect(create, deps)
end,
useMemo = function<T...>(create: () -> T..., deps: Array<any> | nil): ...any
currentHookNameInDev = "useMemo"
warnInvalidHookAccess()
updateHookTypesDev()
local prevDispatcher = ReactCurrentDispatcher.current
ReactCurrentDispatcher.current = InvalidNestedHooksDispatcherOnUpdateInDEV
local results = { pcall(updateMemo, create, deps) }
ReactCurrentDispatcher.current = prevDispatcher
if not results[1] then
error(results[2])
end
return unpack(results, 2)
end :: any,
useReducer = function<S, I, A>(
reducer: (S, A) -> S,
initialArg: I,
init: ((I) -> S)?
): (S, Dispatch<A>)
currentHookNameInDev = "useReducer"
warnInvalidHookAccess()
updateHookTypesDev()
local prevDispatcher = ReactCurrentDispatcher.current
ReactCurrentDispatcher.current = InvalidNestedHooksDispatcherOnUpdateInDEV
local ok, result, setResult =
pcall(rerenderReducer, reducer, initialArg, init)
ReactCurrentDispatcher.current = prevDispatcher
if not ok then
error(result)
end
return result, setResult
end,
useRef = function<T>(initialValue: T): { current: T }
currentHookNameInDev = "useRef"
warnInvalidHookAccess()
updateHookTypesDev()
return updateRef(initialValue)
end,
useBinding = function<T>(initialValue: T): (ReactBinding<T>, ReactBindingUpdater<T>)
currentHookNameInDev = "useBinding"
warnInvalidHookAccess()
updateHookTypesDev()
return updateBinding(initialValue)
end,
useState = function<S>(
initialState: (() -> S) | S
): (S, Dispatch<BasicStateAction<S>>)
currentHookNameInDev = "useState"
warnInvalidHookAccess()
updateHookTypesDev()
local prevDispatcher = ReactCurrentDispatcher.current
ReactCurrentDispatcher.current = InvalidNestedHooksDispatcherOnUpdateInDEV
local ok, result, setResult = pcall(rerenderState, initialState)
ReactCurrentDispatcher.current = prevDispatcher
if not ok then
error(result)
end
return result, setResult
end,
useDebugValue = function<T>(value: T, formatterFn: ((value: T) -> any)?): ()
currentHookNameInDev = "useDebugValue"
warnInvalidHookAccess()
updateHookTypesDev()
return updateDebugValue(value, formatterFn)
end,
useMutableSource = function<Source, Snapshot>(
source: MutableSource<Source>,
getSnapshot: MutableSourceGetSnapshotFn<
Source,
Snapshot
>,
subscribe: MutableSourceSubscribeFn<
Source,
Snapshot
>
): Snapshot
currentHookNameInDev = "useMutableSource"
warnInvalidHookAccess()
updateHookTypesDev()
return updateMutableSource(source, getSnapshot, subscribe)
end,
useOpaqueIdentifier = function(): OpaqueIDType
currentHookNameInDev = "useOpaqueIdentifier"
warnInvalidHookAccess()
updateHookTypesDev()
return rerenderOpaqueIdentifier()
end,
unstable_isNewReconciler = enableNewReconciler,
}
end
local function renderWithHooks<Props, SecondArg>(
current: Fiber | nil,
workInProgress: Fiber,
Component: (p: Props, arg: SecondArg) -> any,
props: Props,
secondArg: SecondArg,
nextRenderLanes: Lanes
): any
renderLanes = nextRenderLanes
currentlyRenderingFiber = workInProgress
if __DEV__ then
hookTypesDev = if current ~= nil
then (current._debugHookTypes :: any) :: Array<HookType>
else nil
hookTypesUpdateIndexDev = 0
end
workInProgress.memoizedState = nil
workInProgress.updateQueue = nil
workInProgress.lanes = NoLanes
if __DEV__ then
if current ~= nil and current.memoizedState ~= nil then
ReactCurrentDispatcher.current = HooksDispatcherOnUpdateInDEV
elseif hookTypesDev ~= nil then
ReactCurrentDispatcher.current = HooksDispatcherOnMountWithHookTypesInDEV
else
ReactCurrentDispatcher.current = HooksDispatcherOnMountInDEV
end
else
ReactCurrentDispatcher.current = (current == nil or current.memoizedState == nil)
and HooksDispatcherOnMount
or HooksDispatcherOnUpdate
end
local children = Component(props, secondArg)
if didScheduleRenderPhaseUpdateDuringThisPass then
local numberOfReRenders: number = 0
repeat
didScheduleRenderPhaseUpdateDuringThisPass = false
if numberOfReRenders >= RE_RENDER_LIMIT then
error(
Error.new(
"Too many re-renders. React limits the number of renders to prevent "
.. "an infinite loop."
)
)
end
numberOfReRenders += 1
currentHook = nil
workInProgressHook = nil
workInProgress.updateQueue = nil
if __DEV__ then
hookTypesUpdateIndexDev = 0
end
ReactCurrentDispatcher.current = __DEV__ and HooksDispatcherOnRerenderInDEV
or HooksDispatcherOnRerender
children = Component(props, secondArg)
until not didScheduleRenderPhaseUpdateDuringThisPass
end
ReactCurrentDispatcher.current = ContextOnlyDispatcher
if __DEV__ then
workInProgress._debugHookTypes = hookTypesDev
end
local didRenderTooFewHooks = currentHook ~= nil and currentHook.next ~= nil
renderLanes = NoLanes
currentlyRenderingFiber = nil :: any
currentHook = nil
workInProgressHook = nil
if __DEV__ then
currentHookNameInDev = nil
hookTypesDev = nil
hookTypesUpdateIndexDev = 0
end
didScheduleRenderPhaseUpdate = false
if didRenderTooFewHooks then
local childrenName = "unknown"
if children and children.type then
childrenName = getComponentName(children.type) or childrenName
end
error(
Error.new(
"Rendered fewer hooks than expected. This may be caused by an accidental "
.. "early return statement. Inside '"
.. childrenName
.. "'"
)
)
end
return children
end
exports.renderWithHooks = renderWithHooks
return exports
end
end)())
__register("ReactReconciler/ReactFiberHostConfig", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberHostConfig"})
return function()
type Object = { [string]: any }
type Instance = Object
type HostInstance = Instance
type TextInstance = Instance
type Container = Object
type HostContext = Object
type HydratableInstance = Instance | SuspenseInstance
type SuspenseInstance = Object
type PublicInstance = HostInstance
type Type = string
type Props = Object
type ChildSet = {}
type RendererInspectionConfig = Object
local exports: { [string]: any } = {}
return exports
end
end)())
__register("ReactReconciler/ReactFiberHostContext.new", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberHostContext.new"})
return function()
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
local ReactFiberStack = __require(script.Parent["ReactFiberStack.new"])
type StackCursor<T> = ReactFiberStack.StackCursor<T>
local ReactFiberHostConfig = __require(script.Parent.ReactFiberHostConfig)
type Container = ReactFiberHostConfig.Container
type HostContext = ReactFiberHostConfig.HostContext
local getChildHostContext = ReactFiberHostConfig.getChildHostContext
local getRootHostContext = ReactFiberHostConfig.getRootHostContext
local createCursor = ReactFiberStack.createCursor
local push = ReactFiberStack.push
local pop = ReactFiberStack.pop
type NoContextT = {}
local NO_CONTEXT: NoContextT = {}
local contextStackCursor: StackCursor<HostContext | NoContextT> = createCursor(NO_CONTEXT)
local contextFiberStackCursor: StackCursor<Fiber | NoContextT> = createCursor(NO_CONTEXT)
local rootInstanceStackCursor: StackCursor<Container | NoContextT> =
createCursor(NO_CONTEXT)
function requiredContext<Value>(c: Value | NoContextT): Value
return c :: any
end
function getRootHostContainer(): Container
return rootInstanceStackCursor.current
end
function pushHostContainer(fiber: Fiber, nextRootInstance: Container)
push(rootInstanceStackCursor, nextRootInstance, fiber)
push(contextFiberStackCursor, fiber, fiber)
push(contextStackCursor, NO_CONTEXT, fiber)
local nextRootContext = getRootHostContext(nextRootInstance)
pop(contextStackCursor, fiber)
push(contextStackCursor, nextRootContext, fiber)
end
function popHostContainer(fiber: Fiber)
pop(contextStackCursor, fiber)
pop(contextFiberStackCursor, fiber)
pop(rootInstanceStackCursor, fiber)
end
function getHostContext(): HostContext
return contextStackCursor.current
end
function pushHostContext(fiber: Fiber)
local rootInstance: Container = requiredContext(rootInstanceStackCursor.current)
local context: HostContext = requiredContext(contextStackCursor.current)
local nextContext = getChildHostContext(context, fiber.type, rootInstance)
if context == nextContext then
return
end
push(contextFiberStackCursor, fiber, fiber)
push(contextStackCursor, nextContext, fiber)
end
function popHostContext(fiber: Fiber)
if contextFiberStackCursor.current ~= fiber then
return
end
pop(contextStackCursor, fiber)
pop(contextFiberStackCursor, fiber)
end
return {
getHostContext = getHostContext,
getRootHostContainer = getRootHostContainer,
popHostContainer = popHostContainer,
popHostContext = popHostContext,
pushHostContainer = pushHostContainer,
pushHostContext = pushHostContext,
}
end
end)())
__register("ReactReconciler/ReactFiberHotReloading.new", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberHotReloading.new"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local LuauPolyfill = __require(Packages.LuauPolyfill)
local Array = LuauPolyfill.Array
local Error = LuauPolyfill.Error
local Set = LuauPolyfill.Set
local WeakSet = Set
type Array<T> = LuauPolyfill.Array<T>
type Set<T> = LuauPolyfill.Set<T>
type WeakSet<T> = Set<T>
local ReactElementType = __require(Packages.Shared)
type ReactElement = ReactElementType.ReactElement<any, any>
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
type FiberRoot = ReactInternalTypes.FiberRoot
local ReactFiberHostConfigModule = __require(script.Parent.ReactFiberHostConfig)
type Instance = ReactFiberHostConfigModule.Instance
type ReactNodeList = ReactElementType.ReactNodeList
local ReactFiberLaneModule = __require(script.Parent.ReactFiberLane)
local SyncLane = ReactFiberLaneModule.SyncLane
local NoTimestamp = ReactFiberLaneModule.NoTimestamp
local ReactWorkTagsModule = __require(script.Parent.ReactWorkTags)
local ClassComponent = ReactWorkTagsModule.ClassComponent
local FunctionComponent = ReactWorkTagsModule.FunctionComponent
local ForwardRef = ReactWorkTagsModule.ForwardRef
local HostComponent = ReactWorkTagsModule.HostComponent
local HostPortal = ReactWorkTagsModule.HostPortal
local HostRoot = ReactWorkTagsModule.HostRoot
local MemoComponent = ReactWorkTagsModule.MemoComponent
local SimpleMemoComponent = ReactWorkTagsModule.SimpleMemoComponent
local ReactSymbols = __require(Packages.Shared).ReactSymbols
local REACT_FORWARD_REF_TYPE = ReactSymbols.REACT_FORWARD_REF_TYPE
local REACT_MEMO_TYPE = ReactSymbols.REACT_MEMO_TYPE
local REACT_LAZY_TYPE = ReactSymbols.REACT_LAZY_TYPE
local __DEV__ = ReactGlobals.__DEV__
type Family = {
current: any,
}
type RefreshUpdate = {
staleFamilies: Set<Family>,
updatedFamilies: Set<Family>,
}
type RefreshHandler = (any) -> Family?
type SetRefreshHandler = (handler: RefreshHandler | nil) -> ()
type ScheduleRefresh = (root: FiberRoot, update: RefreshUpdate) -> ()
type ScheduleRoot = (root: FiberRoot, element: ReactNodeList) -> ()
type FindHostInstancesForRefresh = (
root: FiberRoot,
families: Array<Family>
) -> Set<Instance>
local resolveFamily: RefreshHandler? = nil
local failedBoundaries: WeakSet<Fiber>? = nil
local exports = {}
local findChildHostInstancesForFiberShallowly, findHostInstancesForFiberShallowly, findHostInstancesForMatchingFibersRecursively, scheduleFibersWithFamiliesRecursively
local function setRefreshHandler(handler: RefreshHandler | nil): ()
if __DEV__ then
resolveFamily = handler
end
end
exports.setRefreshHandler = setRefreshHandler
local function resolveFunctionForHotReloading(type: any): any
if __DEV__ then
if resolveFamily == nil then
return type
end
local family = resolveFamily(type)
if family == nil then
return type
end
return family.current
else
return type
end
end
exports.resolveFunctionForHotReloading = resolveFunctionForHotReloading
local function resolveClassForHotReloading(type: any): any
return resolveFunctionForHotReloading(type)
end
exports.resolveClassForHotReloading = resolveClassForHotReloading
local function resolveForwardRefForHotReloading(type: any): any
if __DEV__ then
if resolveFamily == nil then
return type
end
local family = resolveFamily(type)
if family == nil then
if type ~= nil and typeof(type.render) == "function" then
local currentRender = resolveFunctionForHotReloading(type.render)
if type.render ~= currentRender then
local syntheticType = {
["$$typeof"] = REACT_FORWARD_REF_TYPE,
render = currentRender,
displayName = nil,
}
if type.displayName ~= nil then
syntheticType.displayName = type.displayName
end
return syntheticType
end
end
return type
end
return family.current
else
return type
end
end
exports.resolveForwardRefForHotReloading = resolveForwardRefForHotReloading
local function isCompatibleFamilyForHotReloading(
fiber: Fiber,
element: ReactElement
): boolean
if __DEV__ then
if resolveFamily == nil then
return false
end
local prevType = fiber.elementType
local nextType = element.type
local needsCompareFamilies = false
local __typeofNextType = if typeof(nextType) == "table"
and nextType ~= nil
then nextType["$$typeof"]
else nil
repeat
local condition_ = fiber.tag
if condition_ == ClassComponent then
do
if typeof(nextType) == "function" then
needsCompareFamilies = true
end
break
end
elseif condition_ == FunctionComponent then
do
if typeof(nextType) == "function" then
needsCompareFamilies = true
elseif __typeofNextType == REACT_LAZY_TYPE then
needsCompareFamilies = true
end
break
end
elseif condition_ == ForwardRef then
do
if __typeofNextType == REACT_FORWARD_REF_TYPE then
needsCompareFamilies = true
elseif __typeofNextType == REACT_LAZY_TYPE then
needsCompareFamilies = true
end
break
end
elseif condition_ == MemoComponent or condition_ == SimpleMemoComponent then
do
if __typeofNextType == REACT_MEMO_TYPE then
needsCompareFamilies = true
elseif __typeofNextType == REACT_LAZY_TYPE then
needsCompareFamilies = true
end
break
end
else
return false
end
until true
if needsCompareFamilies then
local prevFamily = resolveFamily(prevType)
if prevFamily ~= nil and prevFamily == resolveFamily(nextType) then
return true
end
end
return false
else
return false
end
end
exports.isCompatibleFamilyForHotReloading = isCompatibleFamilyForHotReloading
local function markFailedErrorBoundaryForHotReloading(fiber: Fiber)
if __DEV__ then
if resolveFamily == nil then
return
end
if failedBoundaries == nil then
failedBoundaries = WeakSet.new()
end
(failedBoundaries :: WeakSet<Fiber>):add(fiber)
end
end
exports.markFailedErrorBoundaryForHotReloading = markFailedErrorBoundaryForHotReloading
local scheduleRefresh: ScheduleRefresh
function scheduleRefresh(root: FiberRoot, update: RefreshUpdate): ()
if __DEV__ then
if resolveFamily == nil then
return
end
local staleFamilies, updatedFamilies =
update.staleFamilies, update.updatedFamilies
local ReactFiberWorkLoop = __require(script.Parent["ReactFiberWorkLoop.new"]) :: any
local flushPassiveEffects = ReactFiberWorkLoop.flushPassiveEffects
local flushSync = ReactFiberWorkLoop.flushSync
flushPassiveEffects()
flushSync(function()
scheduleFibersWithFamiliesRecursively(
root.current,
updatedFamilies,
staleFamilies
)
end)
end
end
exports.scheduleRefresh = scheduleRefresh
local scheduleRoot: ScheduleRoot
function scheduleRoot(root: FiberRoot, element: ReactNodeList): ()
if __DEV__ then
local emptyContextObject = (
__require(script.Parent["ReactFiberContext.new"]) :: any
).emptyContextObject
if root.context ~= emptyContextObject then
return
end
local ReactFiberWorkLoop = __require(script.Parent["ReactFiberWorkLoop.new"]) :: any
local flushPassiveEffects = ReactFiberWorkLoop.flushPassiveEffects
local flushSync = ReactFiberWorkLoop.flushSync
flushPassiveEffects()
flushSync(function()
local updateContainer = (
__require(script.Parent["ReactFiberReconciler.new"]) :: any
).updateContainer
updateContainer(element, root, nil, nil)
end)
end
end
exports.scheduleRoot = scheduleRoot
function scheduleFibersWithFamiliesRecursively(
fiber: Fiber,
updatedFamilies: Set<Family>,
staleFamilies: Set<Family>
)
if __DEV__ then
local alternate, child, sibling, tag, type_ =
fiber.alternate, fiber.child, fiber.sibling, fiber.tag, fiber.type
local candidateType = nil
local condition_ = tag
if
condition_ == FunctionComponent
or condition_ == SimpleMemoComponent
or condition_ == ClassComponent
then
candidateType = type_
elseif condition_ == ForwardRef then
candidateType = type_.render
end
if resolveFamily == nil then
error(Error.new("Expected resolveFamily to be set during hot reload."))
end
local needsRender = false
local needsRemount = false
if candidateType ~= nil then
local family = resolveFamily(candidateType)
if family ~= nil then
if staleFamilies:has(family) then
needsRemount = true
elseif updatedFamilies:has(family) then
if tag == ClassComponent then
needsRemount = true
else
needsRender = true
end
end
end
end
if failedBoundaries ~= nil then
if
failedBoundaries:has(fiber)
or (alternate ~= nil and failedBoundaries:has(alternate))
then
needsRemount = true
end
end
if needsRemount then
fiber._debugNeedsRemount = true
end
if needsRemount or needsRender then
local ReactFiberWorkLoop =
__require(script.Parent["ReactFiberWorkLoop.new"]) :: any
local scheduleUpdateOnFiber = ReactFiberWorkLoop.scheduleUpdateOnFiber
scheduleUpdateOnFiber(fiber, SyncLane, NoTimestamp)
end
if child ~= nil and not needsRemount then
scheduleFibersWithFamiliesRecursively(child, updatedFamilies, staleFamilies)
end
if sibling ~= nil then
scheduleFibersWithFamiliesRecursively(sibling, updatedFamilies, staleFamilies)
end
end
end
local findHostInstancesForRefresh: FindHostInstancesForRefresh
function findHostInstancesForRefresh(
root: FiberRoot,
families: Array<Family>
): Set<Instance>
if __DEV__ then
local hostInstances = Set.new()
local types = Set.new(Array.map(families, function(family)
return family.current
end))
findHostInstancesForMatchingFibersRecursively(root.current, types, hostInstances)
return hostInstances
else
error(
Error.new(
"Did not expect findHostInstancesForRefresh to be called in production."
)
)
end
end
exports.findHostInstancesForRefresh = findHostInstancesForRefresh
function findHostInstancesForMatchingFibersRecursively(
fiber: Fiber,
types: Set<any>,
hostInstances: Set<Instance>
)
if __DEV__ then
local child, sibling, tag, type_ =
fiber.child, fiber.sibling, fiber.tag, fiber.type
local candidateType = nil
local condition_ = tag
if
condition_ == FunctionComponent
or condition_ == SimpleMemoComponent
or condition_ == ClassComponent
then
candidateType = type_
elseif condition_ == ForwardRef then
candidateType = type_.render
end
local didMatch = false
if candidateType ~= nil then
if types:has(candidateType) then
didMatch = true
end
end
if didMatch then
findHostInstancesForFiberShallowly(fiber, hostInstances)
else
if child ~= nil then
findHostInstancesForMatchingFibersRecursively(child, types, hostInstances)
end
end
if sibling ~= nil then
findHostInstancesForMatchingFibersRecursively(sibling, types, hostInstances)
end
end
end
function findHostInstancesForFiberShallowly(
fiber: Fiber,
hostInstances: Set<Instance>
): ()
if __DEV__ then
local foundHostInstances =
findChildHostInstancesForFiberShallowly(fiber, hostInstances)
if foundHostInstances then
return
end
local node = fiber
while true do
local condition_ = node.tag
if condition_ == HostComponent then
hostInstances:add(node.stateNode)
return
elseif condition_ == HostPortal then
hostInstances:add(node.stateNode.containerInfo)
return
elseif condition_ == HostRoot then
hostInstances:add(node.stateNode.containerInfo)
return
end
if node.return_ == nil then
error(Error.new("Expected to reach root first."))
end
node = node.return_
end
end
end
function findChildHostInstancesForFiberShallowly(
fiber: Fiber,
hostInstances: Set<Instance>
): boolean
if __DEV__ then
local node: Fiber = fiber
local foundHostInstances = false
while true do
if node.tag == HostComponent then
foundHostInstances = true
hostInstances:add(node.stateNode)
elseif node.child ~= nil then
node.child.return_ = node
node = node.child
continue
end
if node == fiber then
return foundHostInstances
end
while node.sibling == nil do
if node.return_ == nil or node.return_ == fiber then
return foundHostInstances
end
node = node.return_
end
assert(node.sibling ~= nil, "should be non-nil")
node.sibling.return_ = node.return_
node = node.sibling
end
end
return false
end
return exports
end
end)())
__register("ReactReconciler/ReactFiberHydrationContext.new", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberHydrationContext.new"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local console = __require(Packages.Shared).console
local function unimplemented(message: string)
print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
print("UNIMPLEMENTED ERROR: " .. message)
error("FIXME (roblox): " .. message .. " is unimplemented", 2)
end
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
local ReactFiberHostConfig = __require(script.Parent.ReactFiberHostConfig)
type Instance = ReactFiberHostConfig.Instance
type TextInstance = ReactFiberHostConfig.TextInstance
type HydratableInstance = ReactFiberHostConfig.HydratableInstance
type SuspenseInstance = ReactFiberHostConfig.SuspenseInstance
type Container = ReactFiberHostConfig.Container
type HostContext = ReactFiberHostConfig.HostContext
local ReactFiberSuspenseComponent =
__require(script.Parent["ReactFiberSuspenseComponent.new"])
type SuspenseState = ReactFiberSuspenseComponent.SuspenseState
local ReactWorkTags = __require(script.Parent.ReactWorkTags)
local HostComponent = ReactWorkTags.HostComponent
local HostText = ReactWorkTags.HostText
local HostRoot = ReactWorkTags.HostRoot
local SuspenseComponent = ReactWorkTags.SuspenseComponent
local ReactFiberFlags = __require(script.Parent.ReactFiberFlags)
local Placement = ReactFiberFlags.Placement
local Hydrating = ReactFiberFlags.Hydrating
local invariant = __require(Packages.Shared).invariant
local ReactFiber = __require(script.Parent["ReactFiber.new"])
local createFiberFromDehydratedFragment = ReactFiber.createFiberFromDehydratedFragment
local supportsHydration = ReactFiberHostConfig.supportsHydration
local getNextHydratableSibling = ReactFiberHostConfig.getNextHydratableSibling
local getFirstHydratableChild = ReactFiberHostConfig.getFirstHydratableChild
local canHydrateInstance = ReactFiberHostConfig.canHydrateInstance
local canHydrateTextInstance = ReactFiberHostConfig.canHydrateTextInstance
local canHydrateSuspenseInstance = ReactFiberHostConfig.canHydrateSuspenseInstance
local hydrateInstance = ReactFiberHostConfig.hydrateInstance
local hydrateTextInstance = ReactFiberHostConfig.hydrateTextInstance
local hydrateSuspenseInstance = ReactFiberHostConfig.hydrateSuspenseInstance
local getNextHydratableInstanceAfterSuspenseInstance =
ReactFiberHostConfig.getNextHydratableInstanceAfterSuspenseInstance
local didNotMatchHydratedContainerTextInstance =
ReactFiberHostConfig.didNotMatchHydratedContainerTextInstance
local didNotMatchHydratedTextInstance =
ReactFiberHostConfig.didNotMatchHydratedTextInstance
local shouldSetTextContent = ReactFiberHostConfig.shouldSetTextContent
local enableSuspenseServerRenderer =
__require(Packages.Shared).ReactFeatureFlags.enableSuspenseServerRenderer
local OffscreenLane = __require(script.Parent.ReactFiberLane).OffscreenLane
local hydrationParentFiber: Fiber? = nil
local nextHydratableInstance: nil | HydratableInstance = nil
local isHydrating: boolean = false
function warnIfHydrating()
if ReactGlobals.__DEV__ then
if isHydrating then
console.error(
"We should not be hydrating here. This is a bug in React. Please file a bug."
)
end
end
end
function enterHydrationState(fiber: Fiber): boolean
if not supportsHydration then
return false
end
local parentInstance = fiber.stateNode.containerInfo
nextHydratableInstance = getFirstHydratableChild(parentInstance)
hydrationParentFiber = fiber
isHydrating = true
return true
end
function reenterHydrationStateFromDehydratedSuspenseInstance(
fiber: Fiber,
suspenseInstance: SuspenseInstance
): boolean
if not supportsHydration then
return false
end
nextHydratableInstance = getNextHydratableSibling(suspenseInstance)
popToNextHostParent(fiber)
isHydrating = true
return true
end
function deleteHydratableInstance(returnFiber: Fiber?, instance: HydratableInstance)
unimplemented("deleteHydratableInstance")
end
function insertNonHydratedInstance(returnFiber: Fiber?, fiber: Fiber)
unimplemented("insertNonHydratedInstance")
fiber.flags = bit32.bor(bit32.band(fiber.flags, bit32.bnot(Hydrating)), Placement)
if ReactGlobals.__DEV__ then
end
end
function tryHydrate(fiber, nextInstance)
if fiber.tag == HostComponent then
local type_ = fiber.type
local props = fiber.pendingProps
local instance = canHydrateInstance(nextInstance, type_, props)
if instance ~= nil then
fiber.stateNode = instance
return true
end
return false
elseif fiber.tag == HostText then
local text = fiber.pendingProps
local textInstance = canHydrateTextInstance(nextInstance, text)
if textInstance ~= nil then
fiber.stateNode = textInstance
return true
end
return false
elseif fiber.tag == SuspenseComponent then
if enableSuspenseServerRenderer then
local suspenseInstance: nil | SuspenseInstance =
canHydrateSuspenseInstance(nextInstance)
if suspenseInstance ~= nil then
local suspenseState: SuspenseState = {
dehydrated = suspenseInstance,
retryLane = OffscreenLane,
}
fiber.memoizedState = suspenseState
local dehydratedFragment =
createFiberFromDehydratedFragment(suspenseInstance)
dehydratedFragment.return_ = fiber
fiber.child = dehydratedFragment
return true
end
end
return false
else
return false
end
end
function tryToClaimNextHydratableInstance(fiber: Fiber)
if not isHydrating then
return
end
local nextInstance = nextHydratableInstance
if not nextInstance then
insertNonHydratedInstance(hydrationParentFiber, fiber)
isHydrating = false
hydrationParentFiber = fiber
return
end
local firstAttemptedInstance = nextInstance :: HydratableInstance
if not tryHydrate(fiber, nextInstance) then
nextInstance = getNextHydratableSibling(firstAttemptedInstance)
if not nextInstance or not tryHydrate(fiber, nextInstance) then
insertNonHydratedInstance(hydrationParentFiber, fiber)
isHydrating = false
hydrationParentFiber = fiber
return
end
deleteHydratableInstance(hydrationParentFiber, firstAttemptedInstance)
end
hydrationParentFiber = fiber
nextHydratableInstance = getFirstHydratableChild(nextInstance)
end
function prepareToHydrateHostInstance(
fiber: Fiber,
rootContainerInstance: Container,
hostContext: HostContext
): boolean
if not supportsHydration then
invariant(
false,
"Expected prepareToHydrateHostInstance() to never be called. "
.. "This error is likely caused by a bug in React. Please file an issue."
)
end
local instance: Instance = fiber.stateNode
local updatePayload = hydrateInstance(
instance,
fiber.type,
fiber.memoizedProps,
rootContainerInstance,
hostContext,
fiber
)
fiber.updateQueue = updatePayload
if updatePayload ~= nil then
return true
end
return false
end
function prepareToHydrateHostTextInstance(fiber: Fiber): boolean
if not supportsHydration then
invariant(
false,
"Expected prepareToHydrateHostTextInstance() to never be called. "
.. "This error is likely caused by a bug in React. Please file an issue."
)
end
local textInstance: TextInstance = fiber.stateNode
local textContent: string = fiber.memoizedProps
local shouldUpdate = hydrateTextInstance(textInstance, textContent, fiber)
if ReactGlobals.__DEV__ then
if shouldUpdate then
local returnFiber = hydrationParentFiber
if returnFiber ~= nil then
if returnFiber.tag == HostRoot then
local parentContainer = returnFiber.stateNode.containerInfo
didNotMatchHydratedContainerTextInstance(
parentContainer,
textInstance,
textContent
)
elseif returnFiber.tag == HostComponent then
local parentType = returnFiber.type
local parentProps = returnFiber.memoizedProps
local parentInstance = returnFiber.stateNode
didNotMatchHydratedTextInstance(
parentType,
parentProps,
parentInstance,
textInstance,
textContent
)
end
end
end
end
return shouldUpdate
end
function prepareToHydrateHostSuspenseInstance(fiber: Fiber)
if not supportsHydration then
invariant(
false,
"Expected prepareToHydrateHostSuspenseInstance() to never be called. "
.. "This error is likely caused by a bug in React. Please file an issue."
)
end
local suspenseState: SuspenseState = fiber.memoizedState
local suspenseInstance: nil | SuspenseInstance
if suspenseState ~= nil then
suspenseInstance = suspenseState.dehydrated
else
suspenseInstance = nil
end
invariant(
suspenseInstance,
"Expected to have a hydrated suspense instance. "
.. "This error is likely caused by a bug in React. Please file an issue."
)
hydrateSuspenseInstance(suspenseInstance, fiber)
end
function skipPastDehydratedSuspenseInstance(fiber: Fiber): nil | HydratableInstance
if not supportsHydration then
invariant(
false,
"Expected skipPastDehydratedSuspenseInstance() to never be called. "
.. "This error is likely caused by a bug in React. Please file an issue."
)
end
local suspenseState: SuspenseState = fiber.memoizedState
local suspenseInstance: nil | SuspenseInstance
if suspenseState ~= nil then
suspenseInstance = suspenseState.dehydrated
else
suspenseInstance = nil
end
invariant(
suspenseInstance,
"Expected to have a hydrated suspense instance. "
.. "This error is likely caused by a bug in React. Please file an issue."
)
return getNextHydratableInstanceAfterSuspenseInstance(suspenseInstance)
end
function popToNextHostParent(fiber: Fiber)
local parent = fiber.return_
while
parent ~= nil
and parent.tag ~= HostComponent
and parent.tag ~= HostRoot
and parent.tag ~= SuspenseComponent
do
parent = parent.return_
end
hydrationParentFiber = parent
end
function popHydrationState(fiber: Fiber): boolean
if not supportsHydration then
return false
end
if fiber ~= hydrationParentFiber then
return false
end
if not isHydrating then
popToNextHostParent(fiber)
isHydrating = true
return false
end
local type_ = fiber.type
if
fiber.tag ~= HostComponent
or (
type_ ~= "head"
and type_ ~= "body"
and not shouldSetTextContent(type_, fiber.memoizedProps)
)
then
local nextInstance = nextHydratableInstance
while nextInstance do
deleteHydratableInstance(fiber, nextInstance)
nextInstance = getNextHydratableSibling(nextInstance)
end
end
popToNextHostParent(fiber)
if fiber.tag == SuspenseComponent then
nextHydratableInstance = skipPastDehydratedSuspenseInstance(fiber)
else
if hydrationParentFiber then
nextHydratableInstance = getNextHydratableSibling(fiber.stateNode)
else
nextHydratableInstance = nil
end
end
return true
end
function resetHydrationState()
if not supportsHydration then
return
end
hydrationParentFiber = nil
nextHydratableInstance = nil
isHydrating = false
end
function getIsHydrating(): boolean
return isHydrating
end
return {
warnIfHydrating = warnIfHydrating,
enterHydrationState = enterHydrationState,
getIsHydrating = getIsHydrating,
reenterHydrationStateFromDehydratedSuspenseInstance = reenterHydrationStateFromDehydratedSuspenseInstance,
resetHydrationState = resetHydrationState,
tryToClaimNextHydratableInstance = tryToClaimNextHydratableInstance,
prepareToHydrateHostInstance = prepareToHydrateHostInstance,
prepareToHydrateHostTextInstance = prepareToHydrateHostTextInstance,
prepareToHydrateHostSuspenseInstance = prepareToHydrateHostSuspenseInstance,
popHydrationState = popHydrationState,
}
end
end)())
__register("ReactReconciler/ReactFiberLane", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberLane"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type FiberRoot = ReactInternalTypes.FiberRoot
type ReactPriorityLevel = ReactInternalTypes.ReactPriorityLevel
local console = __require(Packages.Shared).console
local ReactFiberSchedulerPriorities =
__require(script.Parent["ReactFiberSchedulerPriorities.roblox"])
local SafeFlags = __require(Packages.SafeFlags)
local GetFFlagReactInlineMergeLanes = SafeFlags.createGetFFlag("ReactInlineMergeLanes")
local FFlagReactInlineMergeLanes = GetFFlagReactInlineMergeLanes()
type LanePriority = ReactInternalTypes.LanePriority
type Lane = ReactInternalTypes.Lane
type Lanes = ReactInternalTypes.Lanes
type LaneMap<T> = ReactInternalTypes.LaneMap<T>
local invariant = __require(Packages.Shared).invariant
local ImmediateSchedulerPriority = ReactFiberSchedulerPriorities.ImmediatePriority
local UserBlockingSchedulerPriority = ReactFiberSchedulerPriorities.UserBlockingPriority
local NormalSchedulerPriority = ReactFiberSchedulerPriorities.NormalPriority
local LowSchedulerPriority = ReactFiberSchedulerPriorities.LowPriority
local IdleSchedulerPriority = ReactFiberSchedulerPriorities.IdlePriority
local NoSchedulerPriority = ReactFiberSchedulerPriorities.NoPriority
local exports = {}
local SyncLanePriority: LanePriority = 15
exports.SyncLanePriority = SyncLanePriority
local SyncBatchedLanePriority: LanePriority = 14
exports.SyncBatchedLanePriority = SyncBatchedLanePriority
local InputDiscreteHydrationLanePriority: LanePriority = 13
local InputDiscreteLanePriority: LanePriority = 12
exports.InputDiscreteLanePriority = InputDiscreteLanePriority
local InputContinuousHydrationLanePriority: LanePriority = 11
local InputContinuousLanePriority: LanePriority = 10
exports.InputContinuousLanePriority = InputContinuousLanePriority
local DefaultHydrationLanePriority: LanePriority = 9
local DefaultLanePriority: LanePriority = 8
exports.DefaultLanePriority = DefaultLanePriority
local TransitionHydrationPriority: LanePriority = 7
local TransitionPriority: LanePriority = 6
exports.TransitionPriority = TransitionPriority
local RetryLanePriority: LanePriority = 5
local SelectiveHydrationLanePriority: LanePriority = 4
local IdleHydrationLanePriority: LanePriority = 3
local IdleLanePriority: LanePriority = 2
local OffscreenLanePriority: LanePriority = 1
local NoLanePriority: LanePriority = 0
exports.NoLanePriority = NoLanePriority
local NoLanes: Lanes =
0b0000000000000000000000000000000
exports.NoLanes = NoLanes
local NoLane: Lane =
0b0000000000000000000000000000000
exports.NoLane = NoLane
local SyncLane: Lane =
0b0000000000000000000000000000001
exports.SyncLane = SyncLane
local SyncBatchedLane: Lanes =
0b0000000000000000000000000000010
exports.SyncBatchedLane = SyncBatchedLane
local InputDiscreteHydrationLane: Lane =
0b0000000000000000000000000000100
exports.InputDiscreteHydrationLane = InputDiscreteHydrationLane
local InputDiscreteLanes: Lanes =
0b0000000000000000000000000011000
local InputContinuousHydrationLane: Lane =
0b0000000000000000000000000100000
local InputContinuousLanes: Lanes =
0b0000000000000000000000011000000
local DefaultHydrationLane: Lane =
0b0000000000000000000000100000000
exports.DefaultHydrationLane = DefaultHydrationLane
local DefaultLanes: Lanes =
0b0000000000000000000111000000000
exports.DefaultLanes = DefaultLanes
local TransitionHydrationLane: Lane =
0b0000000000000000001000000000000
local TransitionLanes: Lanes =
0b0000000001111111110000000000000
local RetryLanes: Lanes =
0b0000011110000000000000000000000
exports.RetryLanes = RetryLanes
local SomeRetryLane: Lanes =
0b0000010000000000000000000000000
exports.SomeRetryLane = SomeRetryLane
local SelectiveHydrationLane: Lane =
0b0000100000000000000000000000000
exports.SelectiveHydrationLane = SelectiveHydrationLane
local NonIdleLanes =
0b0000111111111111111111111111111
local IdleHydrationLane: Lane =
0b0001000000000000000000000000000
exports.IdleHydrationLane = IdleHydrationLane
local IdleLanes: Lanes =
0b0110000000000000000000000000000
local OffscreenLane: Lane =
0b1000000000000000000000000000000
exports.OffscreenLane = OffscreenLane
local NoTimestamp = -1
exports.NoTimestamp = NoTimestamp
local currentUpdateLanePriority: LanePriority = exports.NoLanePriority
exports.getCurrentUpdateLanePriority = function(): LanePriority
return currentUpdateLanePriority
end
exports.setCurrentUpdateLanePriority = function(newLanePriority: LanePriority)
currentUpdateLanePriority = newLanePriority
end
local return_highestLanePriority: LanePriority = exports.DefaultLanePriority
local function getHighestPriorityLanes(lanes: Lanes | Lane): Lanes
if bit32.band(SyncLane, lanes) ~= NoLanes then
return_highestLanePriority = SyncLanePriority
return SyncLane
end
if bit32.band(SyncBatchedLane, lanes) ~= NoLanes then
return_highestLanePriority = SyncBatchedLanePriority
return SyncBatchedLane
end
if bit32.band(InputDiscreteHydrationLane, lanes) ~= NoLanes then
return_highestLanePriority = InputDiscreteHydrationLanePriority
return InputDiscreteHydrationLane
end
local inputDiscreteLanes = bit32.band(InputDiscreteLanes, lanes)
if inputDiscreteLanes ~= NoLanes then
return_highestLanePriority = InputDiscreteLanePriority
return inputDiscreteLanes
end
if bit32.band(lanes, InputContinuousHydrationLane) ~= NoLanes then
return_highestLanePriority = InputContinuousHydrationLanePriority
return InputContinuousHydrationLane
end
local inputContinuousLanes = bit32.band(InputContinuousLanes, lanes)
if inputContinuousLanes ~= NoLanes then
return_highestLanePriority = InputContinuousLanePriority
return inputContinuousLanes
end
if bit32.band(lanes, DefaultHydrationLane) ~= NoLanes then
return_highestLanePriority = DefaultHydrationLanePriority
return DefaultHydrationLane
end
local defaultLanes = bit32.band(DefaultLanes, lanes)
if defaultLanes ~= NoLanes then
return_highestLanePriority = DefaultLanePriority
return defaultLanes
end
if bit32.band(lanes, TransitionHydrationLane) ~= NoLanes then
return_highestLanePriority = TransitionHydrationPriority
return TransitionHydrationLane
end
local transitionLanes = bit32.band(TransitionLanes, lanes)
if transitionLanes ~= NoLanes then
return_highestLanePriority = TransitionPriority
return transitionLanes
end
local retryLanes = bit32.band(RetryLanes, lanes)
if retryLanes ~= NoLanes then
return_highestLanePriority = RetryLanePriority
return retryLanes
end
if bit32.band(lanes, SelectiveHydrationLane) ~= 0 then
return_highestLanePriority = SelectiveHydrationLanePriority
return SelectiveHydrationLane
end
if bit32.band(lanes, IdleHydrationLane) ~= NoLanes then
return_highestLanePriority = IdleHydrationLanePriority
return IdleHydrationLane
end
local idleLanes = bit32.band(IdleLanes, lanes)
if idleLanes ~= NoLanes then
return_highestLanePriority = IdleLanePriority
return idleLanes
end
if bit32.band(OffscreenLane, lanes) ~= NoLanes then
return_highestLanePriority = OffscreenLanePriority
return OffscreenLane
end
if ReactGlobals.__DEV__ then
console.error("Should have found matching lanes. This is a bug in React.")
end
return_highestLanePriority = DefaultLanePriority
return lanes
end
local function schedulerPriorityToLanePriority(
schedulerPriorityLevel: ReactPriorityLevel
): LanePriority
if schedulerPriorityLevel == ImmediateSchedulerPriority then
return SyncLanePriority
elseif schedulerPriorityLevel == UserBlockingSchedulerPriority then
return InputContinuousLanePriority
elseif
schedulerPriorityLevel == NormalSchedulerPriority
or schedulerPriorityLevel == LowSchedulerPriority
then
return DefaultLanePriority
elseif schedulerPriorityLevel == IdleSchedulerPriority then
return IdleLanePriority
else
return NoLanePriority
end
end
exports.schedulerPriorityToLanePriority = schedulerPriorityToLanePriority
local function lanePriorityToSchedulerPriority(
lanePriority: LanePriority
): ReactPriorityLevel
if lanePriority == SyncLanePriority or lanePriority == SyncBatchedLanePriority then
return ImmediateSchedulerPriority
elseif
lanePriority == InputDiscreteHydrationLanePriority
or lanePriority == InputDiscreteLanePriority
or lanePriority == InputContinuousHydrationLanePriority
or lanePriority == InputContinuousLanePriority
then
return UserBlockingSchedulerPriority
elseif
lanePriority == DefaultHydrationLanePriority
or lanePriority == DefaultLanePriority
or lanePriority == TransitionHydrationPriority
or lanePriority == TransitionPriority
or lanePriority == SelectiveHydrationLanePriority
or lanePriority == RetryLanePriority
then
return NormalSchedulerPriority
elseif
lanePriority == IdleHydrationLanePriority
or lanePriority == IdleLanePriority
or lanePriority == OffscreenLanePriority
then
return IdleSchedulerPriority
elseif lanePriority == NoLanePriority then
return NoSchedulerPriority
else
invariant(
false,
"Invalid update priority: %s. This is a bug in React.",
lanePriority
)
error("unreachable")
end
end
exports.lanePriorityToSchedulerPriority = lanePriorityToSchedulerPriority
local pickArbitraryLaneIndex, getLowestPriorityLane, getEqualOrHigherPriorityLanes
local function getNextLanes(root: FiberRoot, wipLanes: Lanes): Lanes
local pendingLanes = root.pendingLanes
if pendingLanes == NoLanes then
return_highestLanePriority = NoLanePriority
return NoLanes
end
local nextLanes = NoLanes
local nextLanePriority = NoLanePriority
local expiredLanes = root.expiredLanes
local suspendedLanes = root.suspendedLanes
local pingedLanes = root.pingedLanes
if expiredLanes ~= NoLanes then
nextLanes = expiredLanes
return_highestLanePriority = SyncLanePriority
nextLanePriority = SyncLanePriority
else
local nonIdlePendingLanes = bit32.band(pendingLanes, NonIdleLanes)
if nonIdlePendingLanes ~= NoLanes then
local nonIdleUnblockedLanes =
bit32.band(nonIdlePendingLanes, bit32.bnot(suspendedLanes))
if nonIdleUnblockedLanes ~= NoLanes then
nextLanes = getHighestPriorityLanes(nonIdleUnblockedLanes)
nextLanePriority = return_highestLanePriority
else
local nonIdlePingedLanes = bit32.band(nonIdlePendingLanes, pingedLanes)
if nonIdlePingedLanes ~= NoLanes then
nextLanes = getHighestPriorityLanes(nonIdlePingedLanes)
nextLanePriority = return_highestLanePriority
end
end
else
local unblockedLanes = bit32.band(pendingLanes, bit32.bnot(suspendedLanes))
if unblockedLanes ~= NoLanes then
nextLanes = getHighestPriorityLanes(unblockedLanes)
nextLanePriority = return_highestLanePriority
else
if pingedLanes ~= NoLanes then
nextLanes = getHighestPriorityLanes(pingedLanes)
nextLanePriority = return_highestLanePriority
end
end
end
end
if nextLanes == NoLanes then
return NoLanes
end
nextLanes =
bit32.band(pendingLanes, bit32.lshift(getLowestPriorityLane(nextLanes), 1) - 1)
if
wipLanes ~= NoLanes
and wipLanes ~= nextLanes
and bit32.band(wipLanes, suspendedLanes) == NoLanes
then
getHighestPriorityLanes(wipLanes)
local wipLanePriority = return_highestLanePriority
if nextLanePriority <= wipLanePriority then
return wipLanes
else
return_highestLanePriority = nextLanePriority
end
end
local entangledLanes = root.entangledLanes
if entangledLanes ~= NoLanes then
local entanglements = root.entanglements
local lanes = bit32.band(nextLanes, entangledLanes)
while lanes > 0 do
local index = pickArbitraryLaneIndex(lanes)
local lane = bit32.lshift(1, index)
nextLanes = bit32.bor(nextLanes, entanglements[index])
lanes = bit32.band(lanes, bit32.bnot(lane))
end
end
return nextLanes
end
exports.getNextLanes = getNextLanes
local function getMostRecentEventTime(root: FiberRoot, lanes: Lanes): number
local eventTimes = root.eventTimes
local mostRecentEventTime = NoTimestamp
while lanes > 0 do
local index = pickArbitraryLaneIndex(lanes)
local lane = bit32.lshift(1, index)
local eventTime = eventTimes[index]
if eventTime > mostRecentEventTime then
mostRecentEventTime = eventTime
end
lanes = bit32.band(lanes, bit32.bnot(lane))
end
return mostRecentEventTime
end
exports.getMostRecentEventTime = getMostRecentEventTime
local function computeExpirationTime(lane: Lane, currentTime: number)
getHighestPriorityLanes(lane)
local priority = return_highestLanePriority
if priority >= InputContinuousLanePriority then
return currentTime + 250
elseif priority >= TransitionPriority then
return currentTime + 5000
else
return NoTimestamp
end
end
exports.computeExpirationTime = computeExpirationTime
local function markStarvedLanesAsExpired(root: FiberRoot, currentTime: number)
local pendingLanes = root.pendingLanes
local suspendedLanes = root.suspendedLanes
local pingedLanes = root.pingedLanes
local expirationTimes = root.expirationTimes
local lanes = pendingLanes
while lanes > 0 do
local index = pickArbitraryLaneIndex(lanes)
local lane = bit32.lshift(1, index)
local expirationTime = expirationTimes[index]
if expirationTime == NoTimestamp then
if
bit32.band(lane, suspendedLanes) == NoLanes
or bit32.band(lane, pingedLanes) ~= NoLanes
then
expirationTimes[index] = computeExpirationTime(lane, currentTime)
end
elseif expirationTime <= currentTime then
root.expiredLanes = bit32.bor(root.expiredLanes, lane)
end
lanes = bit32.band(lanes, bit32.bnot(lane))
end
end
exports.markStarvedLanesAsExpired = markStarvedLanesAsExpired
local function getHighestPriorityPendingLanes(root: FiberRoot)
return getHighestPriorityLanes(root.pendingLanes)
end
exports.getHighestPriorityPendingLanes = getHighestPriorityPendingLanes
local function getLanesToRetrySynchronouslyOnError(root: FiberRoot): Lanes
local everythingButOffscreen =
bit32.band(root.pendingLanes, bit32.bnot(OffscreenLane))
if everythingButOffscreen ~= NoLanes then
return everythingButOffscreen
end
if bit32.band(everythingButOffscreen, OffscreenLane) ~= 0 then
return OffscreenLane
end
return NoLanes
end
exports.getLanesToRetrySynchronouslyOnError = getLanesToRetrySynchronouslyOnError
local function returnNextLanesPriority()
return return_highestLanePriority
end
exports.returnNextLanesPriority = returnNextLanesPriority
local function includesNonIdleWork(lanes: Lanes)
return bit32.band(lanes, NonIdleLanes) ~= NoLanes
end
exports.includesNonIdleWork = includesNonIdleWork
local function includesOnlyRetries(lanes: Lanes)
return bit32.band(lanes, RetryLanes) == lanes
end
exports.includesOnlyRetries = includesOnlyRetries
local function includesOnlyTransitions(lanes: Lanes)
return bit32.band(lanes, TransitionLanes) == lanes
end
exports.includesOnlyTransitions = includesOnlyTransitions
local pickArbitraryLane
local function findUpdateLane(lanePriority: LanePriority, wipLanes: Lanes): Lane
if lanePriority == NoLanePriority then
elseif lanePriority == SyncLanePriority then
return SyncLane
elseif lanePriority == SyncBatchedLanePriority then
return SyncBatchedLane
elseif lanePriority == InputDiscreteLanePriority then
local lane =
pickArbitraryLane(bit32.band(InputDiscreteLanes, bit32.bnot(wipLanes)))
if lane == NoLane then
return findUpdateLane(InputContinuousLanePriority, wipLanes)
end
return lane
elseif lanePriority == InputContinuousLanePriority then
local lane =
pickArbitraryLane(bit32.band(InputContinuousLanes, bit32.bnot(wipLanes)))
if lane == NoLane then
return findUpdateLane(DefaultLanePriority, wipLanes)
end
return lane
elseif lanePriority == DefaultLanePriority then
local lane = pickArbitraryLane(bit32.band(DefaultLanes, bit32.bnot(wipLanes)))
if lane == NoLane then
lane = pickArbitraryLane(bit32.band(TransitionLanes, bit32.bnot(wipLanes)))
if lane == NoLane then
lane = pickArbitraryLane(DefaultLanes)
end
end
return lane
elseif
lanePriority == TransitionPriority
or lanePriority == RetryLanePriority
then
elseif lanePriority == IdleLanePriority then
local lane = pickArbitraryLane(bit32.band(IdleLanes, bit32.bnot(wipLanes)))
if lane == NoLane then
lane = pickArbitraryLane(IdleLanes)
end
return lane
else
end
invariant(false, "Invalid update priority: %s. This is a bug in React.", lanePriority)
error("unreachable")
end
exports.findUpdateLane = findUpdateLane
local function findTransitionLane(wipLanes: Lanes, pendingLanes: Lanes): Lane
local lane = pickArbitraryLane(bit32.band(TransitionLanes, bit32.bnot(pendingLanes)))
if lane == NoLane then
lane = pickArbitraryLane(bit32.band(TransitionLanes, bit32.bnot(wipLanes)))
if lane == NoLane then
lane = pickArbitraryLane(TransitionLanes)
end
end
return lane
end
exports.findTransitionLane = findTransitionLane
local function findRetryLane(wipLanes: Lanes): Lane
local lane = pickArbitraryLane(bit32.band(RetryLanes, bit32.bnot(wipLanes)))
if lane == NoLane then
lane = pickArbitraryLane(RetryLanes)
end
return lane
end
exports.findRetryLane = findRetryLane
local function getHighestPriorityLane(lanes: Lanes)
return bit32.band(lanes, -lanes)
end
function getLowestPriorityLane(lanes: Lanes): Lane
local index = 31 - bit32.countlz(lanes)
if index < 0 then
return NoLanes
else
return bit32.lshift(1, index)
end
end
function getEqualOrHigherPriorityLanes(lanes: Lanes | Lane): Lanes
return bit32.lshift(getLowestPriorityLane(lanes), 1) - 1
end
function pickArbitraryLane(lanes: Lanes): Lane
return getHighestPriorityLane(lanes)
end
exports.pickArbitraryLane = pickArbitraryLane
function pickArbitraryLaneIndex(lanes: Lanes)
return 31 - bit32.countlz(lanes)
end
local function includesSomeLane(a: Lanes | Lane, b: Lanes | Lane)
return bit32.band(a, b) ~= NoLanes
end
exports.includesSomeLane = includesSomeLane
local function isSubsetOfLanes(set: Lanes, subset: Lanes | Lane)
return bit32.band(set, subset) == subset
end
exports.isSubsetOfLanes = isSubsetOfLanes
local function mergeLanes(a: Lanes | Lane, b: Lanes | Lane): Lanes
return bit32.bor(a, b)
end
type MergeLanes = (a: Lanes | Lane, b: Lanes | Lane) -> Lanes
exports.mergeLanes = (
if FFlagReactInlineMergeLanes then bit32.bor else mergeLanes
) :: MergeLanes
local function removeLanes(set: Lanes, subset: Lanes | Lane): Lanes
return bit32.band(set, bit32.bnot(subset))
end
exports.removeLanes = removeLanes
local function laneToLanes(lane: Lane): Lanes
return lane
end
exports.laneToLanes = laneToLanes
local function higherPriorityLane(a: Lane, b: Lane)
if a ~= NoLane and b ~= NoLane then
if a < b then
return a
end
return b
else
if a ~= NoLane then
return a
end
return b
end
end
exports.higherPriorityLane = higherPriorityLane
local function higherLanePriority(a: LanePriority, b: LanePriority): LanePriority
if a ~= NoLanePriority and a > b then
return a
else
return b
end
end
exports.higherLanePriority = higherLanePriority
local function createLaneMap(initial): LaneMap<any>
local laneMap = {
[0] = initial,
[1] = initial,
[2] = initial,
[3] = initial,
[4] = initial,
[5] = initial,
[6] = initial,
[7] = initial,
[8] = initial,
[9] = initial,
[10] = initial,
[11] = initial,
[12] = initial,
[13] = initial,
[14] = initial,
[15] = initial,
[16] = initial,
[17] = initial,
[18] = initial,
[19] = initial,
[20] = initial,
[21] = initial,
[22] = initial,
[23] = initial,
[24] = initial,
[25] = initial,
[26] = initial,
[27] = initial,
[28] = initial,
[29] = initial,
[30] = initial,
[31] = initial,
}
return laneMap
end
exports.createLaneMap = createLaneMap
local function markRootUpdated(root: FiberRoot, updateLane: Lane, eventTime: number)
root.pendingLanes = bit32.bor(root.pendingLanes, updateLane)
local higherPriorityLanes = updateLane - 1
root.suspendedLanes = bit32.band(root.suspendedLanes, higherPriorityLanes)
root.pingedLanes = bit32.band(root.pingedLanes, higherPriorityLanes)
local eventTimes = root.eventTimes
local index = 31 - bit32.countlz(updateLane)
eventTimes[index] = eventTime
end
exports.markRootUpdated = markRootUpdated
local function markRootSuspended(root: FiberRoot, suspendedLanes: Lanes)
root.suspendedLanes = bit32.bor(root.suspendedLanes, suspendedLanes)
root.pingedLanes = bit32.band(root.pingedLanes, bit32.bnot(suspendedLanes))
local expirationTimes = root.expirationTimes
local lanes = suspendedLanes
while lanes > 0 do
local index = pickArbitraryLaneIndex(lanes)
local lane = bit32.lshift(1, index)
expirationTimes[index] = NoTimestamp
lanes = bit32.band(lanes, bit32.bnot(lane))
end
end
exports.markRootSuspended = markRootSuspended
local function markRootPinged(root: FiberRoot, pingedLanes: Lanes, eventTime: number)
root.pingedLanes =
bit32.bor(root.pingedLanes, bit32.band(root.suspendedLanes, pingedLanes))
end
exports.markRootPinged = markRootPinged
local function markRootExpired(root: FiberRoot, expiredLanes: Lanes)
root.expiredLanes =
bit32.bor(root.expiredLanes, bit32.band(expiredLanes, root.pendingLanes))
end
exports.markRootExpired = markRootExpired
local function markDiscreteUpdatesExpired(root: FiberRoot)
root.expiredLanes =
bit32.bor(root.expiredLanes, bit32.band(InputDiscreteLanes, root.pendingLanes))
end
exports.markDiscreteUpdatesExpired = markDiscreteUpdatesExpired
local function hasDiscreteLanes(lanes: Lanes)
return bit32.band(lanes, InputDiscreteLanes) ~= NoLanes
end
exports.hasDiscreteLanes = hasDiscreteLanes
local function markRootMutableRead(root: FiberRoot, updateLane: Lane)
root.mutableReadLanes =
bit32.bor(root.mutableReadLanes, bit32.band(updateLane, root.pendingLanes))
end
exports.markRootMutableRead = markRootMutableRead
local function markRootFinished(root: FiberRoot, remainingLanes: Lanes)
local noLongerPendingLanes = bit32.band(root.pendingLanes, bit32.bnot(remainingLanes))
root.pendingLanes = remainingLanes
root.suspendedLanes = 0
root.pingedLanes = 0
root.expiredLanes = bit32.band(root.expiredLanes, remainingLanes)
root.mutableReadLanes = bit32.band(root.mutableReadLanes, remainingLanes)
root.entangledLanes = bit32.band(root.entangledLanes, remainingLanes)
local entanglements = root.entanglements
local eventTimes = root.eventTimes
local expirationTimes = root.expirationTimes
local lanes = noLongerPendingLanes
while lanes > 0 do
local index = pickArbitraryLaneIndex(lanes)
local lane = bit32.lshift(1, index)
entanglements[index] = NoLanes
eventTimes[index] = NoTimestamp
expirationTimes[index] = NoTimestamp
lanes = bit32.band(lanes, bit32.bnot(lane))
end
end
exports.markRootFinished = markRootFinished
local function markRootEntangled(root: FiberRoot, entangledLanes: Lanes)
root.entangledLanes = bit32.bor(root.entangledLanes, entangledLanes)
local entanglements = root.entanglements
local lanes = entangledLanes
while lanes > 0 do
local index = pickArbitraryLaneIndex(lanes)
local lane = bit32.lshift(1, index)
entanglements[index] = bit32.bor(entanglements[index], entangledLanes)
lanes = bit32.band(lanes, bit32.bnot(lane))
end
end
exports.markRootEntangled = markRootEntangled
local function getBumpedLaneForHydration(root: FiberRoot, renderLanes: Lanes): Lane
getHighestPriorityLanes(renderLanes)
local highestLanePriority = return_highestLanePriority
local lane
if
highestLanePriority == SyncLanePriority
or highestLanePriority == SyncBatchedLanePriority
then
lane = NoLane
elseif
highestLanePriority == InputDiscreteHydrationLanePriority
or highestLanePriority == InputDiscreteLanePriority
then
lane = InputDiscreteHydrationLane
elseif
highestLanePriority == InputContinuousHydrationLanePriority
or highestLanePriority == InputContinuousLanePriority
then
lane = InputContinuousHydrationLane
elseif
highestLanePriority == DefaultHydrationLanePriority
or highestLanePriority == DefaultLanePriority
then
lane = DefaultHydrationLane
elseif
highestLanePriority == TransitionHydrationPriority
or highestLanePriority == TransitionPriority
then
lane = TransitionHydrationLane
elseif highestLanePriority == RetryLanePriority then
lane = TransitionHydrationLane
elseif highestLanePriority == SelectiveHydrationLanePriority then
lane = SelectiveHydrationLane
elseif
highestLanePriority == IdleHydrationLanePriority
or highestLanePriority == IdleLanePriority
then
lane = IdleHydrationLane
elseif
highestLanePriority == OffscreenLanePriority
or highestLanePriority == NoLanePriority
then
lane = NoLane
else
invariant(false, "Invalid lane: %s. This is a bug in React.", tostring(lane))
end
if bit32.band(lane, bit32.bor(root.suspendedLanes, renderLanes)) ~= NoLane then
return NoLane
end
return lane
end
exports.getBumpedLaneForHydration = getBumpedLaneForHydration
return exports
end
end)())
__register("ReactReconciler/ReactFiberLazyComponent.new", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberLazyComponent.new"})
return function()
type Object = { [any]: any }
local function resolveDefaultProps(Component: any, baseProps: Object): Object
if Component and typeof(Component) == "table" and Component.defaultProps then
local props = table.clone(baseProps) :: Object
local defaultProps = Component.defaultProps
for propName, _ in defaultProps do
if props[propName] == nil then
props[propName] = defaultProps[propName]
end
end
return props
end
return baseProps
end
return {
resolveDefaultProps = resolveDefaultProps,
}
end
end)())
__register("ReactReconciler/ReactFiberNewContext.new", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberNewContext.new"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local LuauPolyfill = __require(Packages.LuauPolyfill)
local Number = LuauPolyfill.Number
local Error = LuauPolyfill.Error
local console = __require(Packages.Shared).console
local ReactTypes = __require(Packages.Shared)
type ReactContext<T> = ReactTypes.ReactContext<T>
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
type ContextDependency<T> = ReactInternalTypes.ContextDependency<T>
local ReactFiberStack = __require(script.Parent["ReactFiberStack.new"])
type StackCursor<T> = ReactFiberStack.StackCursor<T>
local ReactFiberLane = __require(script.Parent.ReactFiberLane)
type Lanes = ReactFiberLane.Lanes
local ReactUpdateQueue = __require(script.Parent["ReactUpdateQueue.new"])
type SharedQueue<T> = ReactUpdateQueue.SharedQueue<T>
local ReactFiberHostConfig = __require(script.Parent.ReactFiberHostConfig)
local isPrimaryRenderer = ReactFiberHostConfig.isPrimaryRenderer
local createCursor = ReactFiberStack.createCursor
local push = ReactFiberStack.push
local pop = ReactFiberStack.pop
local MAX_SIGNED_31_BIT_INT = __require(script.Parent.MaxInts).MAX_SIGNED_31_BIT_INT
local ReactWorkTags = __require(script.Parent.ReactWorkTags)
local ContextProvider = ReactWorkTags.ContextProvider
local ClassComponent = ReactWorkTags.ClassComponent
local NoLanes = ReactFiberLane.NoLanes
local NoTimestamp = ReactFiberLane.NoTimestamp
local isSubsetOfLanes = ReactFiberLane.isSubsetOfLanes
local includesSomeLane = ReactFiberLane.includesSomeLane
local mergeLanes = ReactFiberLane.mergeLanes
local pickArbitraryLane = ReactFiberLane.pickArbitraryLane
local is = __require(Packages.Shared).objectIs
local createUpdate = ReactUpdateQueue.createUpdate
local ForceUpdate = ReactUpdateQueue.ForceUpdate
local exports = {}
local valueCursor: StackCursor<any> = createCursor(nil)
local rendererSigil
if ReactGlobals.__DEV__ then
rendererSigil = {}
end
local currentlyRenderingFiber: Fiber | nil = nil
local lastContextDependency: ContextDependency<any> | nil = nil
local lastContextWithAllBitsObserved: ReactContext<any> | nil = nil
local isDisallowedContextReadInDEV: boolean = false
exports.resetContextDependencies = function(): ()
currentlyRenderingFiber = nil
lastContextDependency = nil
lastContextWithAllBitsObserved = nil
if ReactGlobals.__DEV__ then
isDisallowedContextReadInDEV = false
end
end
exports.enterDisallowedContextReadInDEV = function(): ()
if ReactGlobals.__DEV__ then
isDisallowedContextReadInDEV = true
end
end
exports.exitDisallowedContextReadInDEV = function(): ()
if ReactGlobals.__DEV__ then
isDisallowedContextReadInDEV = false
end
end
exports.pushProvider = function<T>(providerFiber: Fiber, nextValue: T): ()
local context: ReactContext<T> = providerFiber.type._context
if isPrimaryRenderer then
push(valueCursor, context._currentValue, providerFiber)
context._currentValue = nextValue
if ReactGlobals.__DEV__ then
if
context._currentRenderer ~= nil
and context._currentRenderer ~= rendererSigil
then
console.error(
"Detected multiple renderers concurrently rendering the "
.. "same context provider. This is currently unsupported."
)
end
context._currentRenderer = rendererSigil
end
else
push(valueCursor, context._currentValue2, providerFiber)
context._currentValue2 = nextValue
if ReactGlobals.__DEV__ then
if
context._currentRenderer2 ~= nil
and context._currentRenderer2 ~= rendererSigil
then
console.error(
"Detected multiple renderers concurrently rendering the "
.. "same context provider. This is currently unsupported."
)
end
context._currentRenderer2 = rendererSigil
end
end
end
exports.popProvider = function(providerFiber: Fiber)
local currentValue = valueCursor.current
pop(valueCursor, providerFiber)
local context: ReactContext<any> = providerFiber.type._context
if isPrimaryRenderer then
context._currentValue = currentValue
else
context._currentValue2 = currentValue
end
end
exports.calculateChangedBits = function<T>(
context: ReactContext<T>,
newValue: T,
oldValue: T
)
if is(oldValue, newValue) then
return 0
else
local changedBits = MAX_SIGNED_31_BIT_INT
if typeof(context._calculateChangedBits) == "function" then
changedBits = context._calculateChangedBits(oldValue, newValue)
end
return math.floor(changedBits)
end
end
exports.scheduleWorkOnParentPath = function(parent: Fiber | nil, renderLanes: Lanes)
local node = parent
while node ~= nil do
local alternate = node.alternate
if not isSubsetOfLanes(node.childLanes, renderLanes) then
node.childLanes = mergeLanes(node.childLanes, renderLanes)
if alternate ~= nil then
alternate.childLanes = mergeLanes(alternate.childLanes, renderLanes)
end
elseif
alternate ~= nil and not isSubsetOfLanes(alternate.childLanes, renderLanes)
then
alternate.childLanes = mergeLanes(alternate.childLanes, renderLanes)
else
break
end
node = node.return_
end
end
exports.propagateContextChange = function<T>(
workInProgress: Fiber,
context: ReactContext<T>,
changedBits: number,
renderLanes: Lanes
): ()
local fiber = workInProgress.child
if fiber ~= nil then
fiber.return_ = workInProgress
end
while fiber ~= nil do
local nextFiber
local list = fiber.dependencies
if list ~= nil then
nextFiber = fiber.child
local dependency = list.firstContext
while dependency ~= nil do
if
dependency.context == context
and bit32.band(dependency.observedBits, changedBits) ~= 0
then
if fiber.tag == ClassComponent then
local update =
createUpdate(NoTimestamp, pickArbitraryLane(renderLanes))
update.tag = ForceUpdate
local updateQueue = fiber.updateQueue
if updateQueue == nil then
else
local sharedQueue: SharedQueue<any> = (updateQueue :: any).shared
local pending = sharedQueue.pending
if pending == nil then
update.next = update
else
update.next = pending.next
pending.next = update
end
sharedQueue.pending = update
end
end
fiber.lanes = bit32.bor(fiber.lanes, renderLanes)
local alternate = fiber.alternate
if alternate ~= nil then
alternate.lanes = bit32.bor(alternate.lanes, renderLanes)
end
exports.scheduleWorkOnParentPath(fiber.return_, renderLanes)
list.lanes = bit32.bor(list.lanes, renderLanes)
break
end
dependency = dependency.next
end
elseif fiber.tag == ContextProvider then
if fiber.type == workInProgress.type then
nextFiber = nil
else
nextFiber = fiber.child
end
else
nextFiber = fiber.child
end
if nextFiber ~= nil then
nextFiber.return_ = fiber
else
nextFiber = fiber
while nextFiber ~= nil do
if nextFiber == workInProgress then
nextFiber = nil
break
end
local sibling = nextFiber.sibling
if sibling ~= nil then
sibling.return_ = nextFiber.return_
nextFiber = sibling
break
end
nextFiber = nextFiber.return_
end
end
fiber = nextFiber
end
end
exports.prepareToReadContext = function(
workInProgress: Fiber,
renderLanes: Lanes,
markWorkInProgressReceivedUpdate: () -> ()
): ()
currentlyRenderingFiber = workInProgress
lastContextDependency = nil
lastContextWithAllBitsObserved = nil
local dependencies = workInProgress.dependencies
if dependencies ~= nil then
local firstContext = dependencies.firstContext
if firstContext ~= nil then
if includesSomeLane(dependencies.lanes, renderLanes) then
markWorkInProgressReceivedUpdate()
end
dependencies.firstContext = nil
end
end
end
exports.readContext = function<T>(
context: ReactContext<T>,
observedBits: nil | number | boolean
): T
if ReactGlobals.__DEV__ then
if isDisallowedContextReadInDEV then
console.error(
"Context can only be read while React is rendering. "
.. "In classes, you can read it in the render method or getDerivedStateFromProps. "
.. "In function components, you can read it directly in the function body, but not "
.. "inside Hooks like useReducer() or useMemo()."
)
end
end
if lastContextWithAllBitsObserved == context then
elseif observedBits == false or observedBits == 0 then
else
local resolvedObservedBits
if
typeof(observedBits) ~= "number"
or observedBits == Number.MAX_SAFE_INTEGER
then
lastContextWithAllBitsObserved = context
resolvedObservedBits = Number.MAX_SAFE_INTEGER
else
resolvedObservedBits = observedBits
end
local contextItem = {
context = context,
observedBits = resolvedObservedBits,
next = nil,
}
if lastContextDependency == nil then
if currentlyRenderingFiber == nil then
error(
Error.new(
"Context can only be read while React is rendering. "
.. "In classes, you can read it in the render method or getDerivedStateFromProps. "
.. "In function components, you can read it directly in the function body, but not "
.. "inside Hooks like useReducer() or useMemo()."
)
)
end
lastContextDependency = contextItem;
(currentlyRenderingFiber :: Fiber).dependencies = {
lanes = NoLanes,
firstContext = contextItem,
responders = nil,
}
else
(lastContextDependency :: any).next = contextItem
lastContextDependency = contextItem
end
end
return if isPrimaryRenderer then context._currentValue else context._currentValue2
end
return exports
end
end)())
__register("ReactReconciler/ReactFiberOffscreenComponent", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberOffscreenComponent"})
return function()
local Packages = script.Parent.Parent
local ReactTypes = __require(Packages.Shared)
type ReactNodeList = ReactTypes.ReactNodeList
local ReactFiberLanes = __require(script.Parent.ReactFiberLane)
type Lanes = ReactFiberLanes.Lanes
type OffscreenProps = {
mode: string | nil,
children: ReactNodeList,
}
type OffscreenState = {
baseLanes: Lanes,
}
return {}
end
end)())
__register("ReactReconciler/ReactFiberReconciler", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberReconciler"})
return function()
return __require(script.Parent["ReactFiberReconciler.new"])
end
end)())
__register("ReactReconciler/ReactFiberReconciler.new", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberReconciler.new"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local flowtypes = __require(Packages.Shared)
type React_Component<Props, State> = flowtypes.React_Component<Props, State>
local LuauPolyfill = __require(Packages.LuauPolyfill)
local Array = LuauPolyfill.Array
local Object = LuauPolyfill.Object
type Function = (...any) -> ...any
local __DEV__ = ReactGlobals.__DEV__ :: boolean
local console = __require(Packages.Shared).console
type Object = { [string]: any }
type Array<T> = { [number]: T }
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
type SuspenseHydrationCallbacks = ReactInternalTypes.SuspenseHydrationCallbacks
type FiberRoot = ReactInternalTypes.FiberRoot
local ReactRootTags = __require(script.Parent.ReactRootTags)
type RootTag = ReactRootTags.RootTag
local ReactFiberFlags = __require(script.Parent.ReactFiberFlags)
local ReactFiberHostConfig = __require(script.Parent.ReactFiberHostConfig)
type Instance = ReactFiberHostConfig.Instance
type TextInstance = ReactFiberHostConfig.TextInstance
type Container = ReactFiberHostConfig.Container
type PublicInstance = ReactFiberHostConfig.PublicInstance
type RendererInspectionConfig = ReactFiberHostConfig.RendererInspectionConfig
local ReactWorkTags = __require(script.Parent.ReactWorkTags)
local FundamentalComponent = ReactWorkTags.FundamentalComponent
local ReactTypes = __require(Packages.Shared)
type ReactNodeList = ReactTypes.ReactNodeList
local ReactFiberLane = __require(script.Parent.ReactFiberLane)
type Lane = ReactFiberLane.Lane
type LanePriority = ReactFiberLane.LanePriority
local ReactFiberSuspenseComponent =
__require(script.Parent["ReactFiberSuspenseComponent.new"])
type SuspenseState = ReactFiberSuspenseComponent.SuspenseState
local ReactFiberTreeReflection = __require(script.Parent.ReactFiberTreeReflection)
local findCurrentHostFiber = ReactFiberTreeReflection.findCurrentHostFiber
local findCurrentHostFiberWithNoPortals =
ReactFiberTreeReflection.findCurrentHostFiberWithNoPortals
local getInstance = __require(Packages.Shared).ReactInstanceMap.get
local HostComponent = ReactWorkTags.HostComponent
local ClassComponent = ReactWorkTags.ClassComponent
local HostRoot = ReactWorkTags.HostRoot
local SuspenseComponent = ReactWorkTags.SuspenseComponent
local getComponentName = __require(Packages.Shared).getComponentName
local invariant = __require(Packages.Shared).invariant
local describeError = __require(Packages.Shared).describeError
local enableSchedulingProfiler =
__require(Packages.Shared).ReactFeatureFlags.enableSchedulingProfiler
local ReactSharedInternals = __require(Packages.Shared).ReactSharedInternals
local getPublicInstance = __require(script.Parent.ReactFiberHostConfig).getPublicInstance
local ReactFiberContext = __require(script.Parent["ReactFiberContext.new"])
local findCurrentUnmaskedContext = ReactFiberContext.findCurrentUnmaskedContext
local processChildContext = ReactFiberContext.processChildContext
local emptyContextObject = ReactFiberContext.emptyContextObject
local isLegacyContextProvider = ReactFiberContext.isContextProvider
local ReactFiberRoot = __require(script.Parent["ReactFiberRoot.new"])
local createFiberRoot = ReactFiberRoot.createFiberRoot
local ReactFiberDevToolsHook = __require(script.Parent["ReactFiberDevToolsHook.new"])
local injectInternals = ReactFiberDevToolsHook.injectInternals
local onScheduleRoot = ReactFiberDevToolsHook.onScheduleRoot
local ReactFiberWorkLoop = __require(script.Parent["ReactFiberWorkLoop.new"]) :: any
local requestEventTime = ReactFiberWorkLoop.requestEventTime
local requestUpdateLane = ReactFiberWorkLoop.requestUpdateLane
local scheduleUpdateOnFiber = ReactFiberWorkLoop.scheduleUpdateOnFiber
local flushRoot = ReactFiberWorkLoop.flushRoot
local batchedEventUpdates = ReactFiberWorkLoop.batchedEventUpdates
local batchedUpdates = ReactFiberWorkLoop.batchedUpdates
local unbatchedUpdates = ReactFiberWorkLoop.unbatchedUpdates
local flushSync = ReactFiberWorkLoop.flushSync
local flushControlled = ReactFiberWorkLoop.flushControlled
local deferredUpdates = ReactFiberWorkLoop.deferredUpdates
local discreteUpdates = ReactFiberWorkLoop.discreteUpdates
local flushDiscreteUpdates = ReactFiberWorkLoop.flushDiscreteUpdates
local flushPassiveEffects = ReactFiberWorkLoop.flushPassiveEffects
local warnIfNotScopedWithMatchingAct = ReactFiberWorkLoop.warnIfNotScopedWithMatchingAct
local warnIfUnmockedScheduler = ReactFiberWorkLoop.warnIfUnmockedScheduler
local IsThisRendererActing = ReactFiberWorkLoop.IsThisRendererActing
local act = ReactFiberWorkLoop.act :: (() -> ()) -> ()
local ReactUpdateQueue = __require(script.Parent["ReactUpdateQueue.new"])
local createUpdate = ReactUpdateQueue.createUpdate
local enqueueUpdate = ReactUpdateQueue.enqueueUpdate
local ReactCurrentFiber = __require(script.Parent.ReactCurrentFiber)
local ReactCurrentFiberIsRendering = ReactCurrentFiber.isRendering
local resetCurrentDebugFiberInDEV = ReactCurrentFiber.resetCurrentFiber
local setCurrentDebugFiberInDEV = ReactCurrentFiber.setCurrentFiber
local ReactTypeOfMode = __require(script.Parent.ReactTypeOfMode)
local StrictMode = ReactTypeOfMode.StrictMode
local SyncLane = ReactFiberLane.SyncLane
local InputDiscreteHydrationLane = ReactFiberLane.InputDiscreteHydrationLane
local SelectiveHydrationLane = ReactFiberLane.SelectiveHydrationLane
local NoTimestamp = ReactFiberLane.NoTimestamp
local getHighestPriorityPendingLanes = ReactFiberLane.getHighestPriorityPendingLanes
local higherPriorityLane = ReactFiberLane.higherPriorityLane
local getCurrentUpdateLanePriority = ReactFiberLane.getCurrentUpdateLanePriority
local setCurrentUpdateLanePriority = ReactFiberLane.setCurrentUpdateLanePriority
local ReactFiberHotReloading = __require(script.Parent["ReactFiberHotReloading.new"])
local scheduleRefresh = ReactFiberHotReloading.scheduleRefresh
local scheduleRoot = ReactFiberHotReloading.scheduleRoot
local setRefreshHandler = ReactFiberHotReloading.setRefreshHandler
local findHostInstancesForRefresh = ReactFiberHotReloading.findHostInstancesForRefresh
local SchedulingProfiler = __require(script.Parent.SchedulingProfiler)
local markRenderScheduled = SchedulingProfiler.markRenderScheduled
local exports = {}
exports.ReactRootTags = ReactRootTags
exports.ReactWorkTags = ReactWorkTags
exports.ReactTypeOfMode = ReactTypeOfMode
exports.ReactFiberFlags = ReactFiberFlags
exports.getNearestMountedFiber = ReactFiberTreeReflection.getNearestMountedFiber
exports.findCurrentFiberUsingSlowPath =
ReactFiberTreeReflection.findCurrentFiberUsingSlowPath
exports.createPortal = __require(script.Parent.ReactPortal).createPortal
type OpaqueRoot = FiberRoot
type BundleType = number
type DevToolsConfig = {
bundleType: BundleType,
version: string,
rendererPackageName: string,
findFiberByHostInstance: ((Instance | TextInstance) -> Fiber)?,
rendererConfig: RendererInspectionConfig?,
}
local didWarnAboutNestedUpdates
local didWarnAboutFindNodeInStrictMode
if __DEV__ then
didWarnAboutNestedUpdates = false
didWarnAboutFindNodeInStrictMode = {}
end
local function getContextForSubtree(parentComponent: any?): Object
if not parentComponent then
return emptyContextObject
end
local fiber = getInstance(parentComponent)
local parentContext = findCurrentUnmaskedContext(fiber)
if fiber.tag == ClassComponent then
local Component = fiber.type
if isLegacyContextProvider(Component) then
return processChildContext(fiber, Component, parentContext)
end
end
return parentContext
end
local function findHostInstance(component: Object): PublicInstance | nil
local fiber = getInstance(component)
if fiber == nil then
if typeof(component.render) == "function" then
invariant(false, "Unable to find node on an unmounted component.")
else
invariant(
false,
"Argument appears to not be a ReactComponent. Keys: %s",
table.concat(Object.keys(component))
)
end
end
local hostFiber = findCurrentHostFiber(fiber)
if hostFiber == nil then
return nil
end
return hostFiber.stateNode
end
local function findHostInstanceWithWarning(
component: Object,
methodName: string
): PublicInstance | nil
if __DEV__ then
local fiber = getInstance(component)
if fiber == nil then
if typeof(component.render) == "function" then
invariant(false, "Unable to find node on an unmounted component.")
else
invariant(
false,
"Argument appears to not be a ReactComponent. Keys: %s",
table.concat(Object.keys(component))
)
end
end
local hostFiber = findCurrentHostFiber(fiber)
if hostFiber == nil then
return nil
end
if bit32.band(hostFiber.mode, StrictMode) ~= 0 then
local componentName = getComponentName(fiber.type) or "Component"
if not didWarnAboutFindNodeInStrictMode[componentName] then
didWarnAboutFindNodeInStrictMode[componentName] = true
local previousFiber = ReactCurrentFiber.current
local ok, result = xpcall(function()
setCurrentDebugFiberInDEV(hostFiber)
if bit32.band(fiber.mode, StrictMode) ~= 0 then
console.error(
"%s is deprecated in StrictMode. "
.. "%s was passed an instance of %s which is inside StrictMode. "
.. "Instead, add a ref directly to the element you want to reference. "
.. "Learn more about using refs safely here: "
.. "https://reactjs.org/link/strict-mode-find-node",
methodName,
methodName,
componentName
)
else
console.error(
"%s is deprecated in StrictMode. "
.. "%s was passed an instance of %s which renders StrictMode children. "
.. "Instead, add a ref directly to the element you want to reference. "
.. "Learn more about using refs safely here: "
.. "https://reactjs.org/link/strict-mode-find-node",
methodName,
methodName,
componentName
)
end
end, describeError)
if previousFiber then
setCurrentDebugFiberInDEV(previousFiber)
else
resetCurrentDebugFiberInDEV()
end
if not ok then
error(result)
end
end
end
return hostFiber.stateNode
end
return findHostInstance(component)
end
exports.createContainer = function(
containerInfo: Container,
tag: RootTag,
hydrate: boolean,
hydrationCallbacks: nil | SuspenseHydrationCallbacks
): OpaqueRoot
return createFiberRoot(containerInfo, tag, hydrate, hydrationCallbacks)
end
exports.updateContainer = function(
element: ReactNodeList,
container: OpaqueRoot,
parentComponent,
callback: Function?
): Lane
if __DEV__ then
onScheduleRoot(container, element)
end
local current = container.current
local eventTime = requestEventTime()
if __DEV__ then
if ReactGlobals.__TESTEZ_RUNNING_TEST__ then
warnIfUnmockedScheduler(current)
warnIfNotScopedWithMatchingAct(current)
end
end
local lane = requestUpdateLane(current)
if enableSchedulingProfiler then
markRenderScheduled(lane)
end
local context = getContextForSubtree(parentComponent)
if container.context == nil then
container.context = context
else
container.pendingContext = context
end
if __DEV__ then
if
ReactCurrentFiberIsRendering
and ReactCurrentFiber.current ~= nil
and not didWarnAboutNestedUpdates
then
didWarnAboutNestedUpdates = true
console.error(
"Render methods should be a pure function of props and state; "
.. "triggering nested component updates from render is not allowed. "
.. "If necessary, trigger nested updates in componentDidUpdate.\n\n"
.. "Check the render method of %s.",
getComponentName((ReactCurrentFiber.current :: any).type) or "Unknown"
)
end
end
local update = createUpdate(eventTime, lane)
if element == nil then
element = Object.None
end
update.payload = {
element = element,
}
if callback ~= nil then
if __DEV__ then
if typeof(callback) ~= "function" then
console.error(
"render(...): Expected the last optional `callback` argument to be a "
.. "function. Instead received: %s.",
tostring(callback)
)
end
end
update.callback = callback
end
enqueueUpdate(current, update)
scheduleUpdateOnFiber(current, lane, eventTime)
return lane
end
exports.batchedEventUpdates = batchedEventUpdates
exports.batchedUpdates = batchedUpdates
exports.unbatchedUpdates = unbatchedUpdates
exports.deferredUpdates = deferredUpdates
exports.discreteUpdates = discreteUpdates
exports.flushDiscreteUpdates = flushDiscreteUpdates
exports.flushControlled = flushControlled
exports.flushSync = flushSync
exports.flushPassiveEffects = flushPassiveEffects
exports.IsThisRendererActing = IsThisRendererActing
exports.act = act
exports.getPublicRootInstance = function(
container: OpaqueRoot
): React_Component<any, any> | PublicInstance | nil
local containerFiber = container.current
if not containerFiber.child then
return nil
end
if containerFiber.child.tag == HostComponent then
return getPublicInstance(containerFiber.child.stateNode)
else
return containerFiber.child.stateNode
end
end
local markRetryLaneIfNotHydrated
exports.attemptSynchronousHydration = function(fiber: Fiber)
if fiber.tag == HostRoot then
local root: FiberRoot = fiber.stateNode
if root.hydrate then
local lanes = getHighestPriorityPendingLanes(root)
flushRoot(root, lanes)
end
elseif fiber.tag == SuspenseComponent then
local eventTime = requestEventTime()
flushSync(function()
return scheduleUpdateOnFiber(fiber, SyncLane, eventTime)
end)
local retryLane = InputDiscreteHydrationLane
markRetryLaneIfNotHydrated(fiber, retryLane)
end
end
local function markRetryLaneImpl(fiber: Fiber, retryLane: Lane)
local suspenseState: SuspenseState? = fiber.memoizedState
if suspenseState then
if suspenseState ~= nil and suspenseState.dehydrated ~= nil then
suspenseState.retryLane =
higherPriorityLane(suspenseState.retryLane, retryLane)
end
end
end
markRetryLaneIfNotHydrated = function(fiber: Fiber, retryLane: Lane)
markRetryLaneImpl(fiber, retryLane)
local alternate = fiber.alternate
if alternate then
markRetryLaneImpl(alternate, retryLane)
end
end
exports.attemptUserBlockingHydration = function(fiber: Fiber)
if fiber.tag ~= SuspenseComponent then
return
end
local eventTime = requestEventTime()
local lane = InputDiscreteHydrationLane
scheduleUpdateOnFiber(fiber, lane, eventTime)
markRetryLaneIfNotHydrated(fiber, lane)
end
exports.attemptContinuousHydration = function(fiber: Fiber)
if fiber.tag ~= SuspenseComponent then
return
end
local eventTime = requestEventTime()
local lane = SelectiveHydrationLane
scheduleUpdateOnFiber(fiber, lane, eventTime)
markRetryLaneIfNotHydrated(fiber, lane)
end
exports.attemptHydrationAtCurrentPriority = function(fiber: Fiber)
if fiber.tag ~= SuspenseComponent then
return
end
local eventTime = requestEventTime()
local lane = requestUpdateLane(fiber)
scheduleUpdateOnFiber(fiber, lane, eventTime)
markRetryLaneIfNotHydrated(fiber, lane)
end
exports.runWithPriority = function<T>(priority: LanePriority, fn: () -> T): T
local previousPriority = getCurrentUpdateLanePriority()
setCurrentUpdateLanePriority(priority)
local ok, result = xpcall(fn, describeError)
setCurrentUpdateLanePriority(previousPriority)
if not ok then
error(result)
end
return result
end
exports.getCurrentUpdateLanePriority = getCurrentUpdateLanePriority
exports.findHostInstance = findHostInstance
exports.findHostInstanceWithWarning = findHostInstanceWithWarning
exports.findHostInstanceWithNoPortals = function(fiber: Fiber): PublicInstance?
local hostFiber = findCurrentHostFiberWithNoPortals(fiber)
if hostFiber == nil then
return nil
end
if hostFiber.tag == FundamentalComponent then
return hostFiber.stateNode.instance
end
return hostFiber.stateNode
end
local function shouldSuspendImpl(fiber)
return false
end
exports.shouldSuspend = function(fiber: Fiber): boolean
return shouldSuspendImpl(fiber)
end
local overrideHookState = nil
local overrideHookStateDeletePath = nil
local overrideHookStateRenamePath = nil
local overrideProps = nil
local overridePropsDeletePath = nil
local overridePropsRenamePath = nil
local scheduleUpdate = nil
local setSuspenseHandler = nil
if __DEV__ then
local function copyWithDeleteImpl(
obj: Object,
path: Array<string | number>,
index: number
)
local key = path[index]
local updated
if Array.isArray(obj) then
updated = Array.slice(obj)
else
updated = table.clone(obj)
end
if index + 1 == #path then
if Array.isArray(updated) then
local updatedIndex: number = key
Array.splice(updated, updatedIndex, 1)
else
updated[key] = nil
end
return updated
end
updated[key] = copyWithDeleteImpl(obj[key], path, index + 1)
return updated
end
local function copyWithDelete(
obj: Object,
path: Array<string | number>
): Object | Array<any>
return copyWithDeleteImpl(obj, path, 0)
end
local function copyWithRenameImpl(
obj: Object,
oldPath: Array<string | number>,
newPath: Array<string | number>,
index: number
)
local oldKey = oldPath[index]
local updated
if Array.isArray(obj) then
updated = Array.slice(obj)
else
updated = table.clone(obj)
end
if index + 1 == #oldPath then
local newKey = newPath[index]
updated[newKey] = updated[oldKey]
if Array.isArray(updated) then
Array.splice(updated, oldKey, 1)
else
updated[oldKey] = nil
end
else
updated[oldKey] = copyWithRenameImpl(
obj[oldKey],
oldPath,
newPath,
index + 1
)
end
return updated
end
local function copyWithRename(
obj: Object,
oldPath: Array<string | number>,
newPath: Array<string | number>
): Object | Array<any> | nil
if #oldPath ~= #newPath then
console.warn("copyWithRename() expects paths of the same length")
return nil
else
for i = 1, #newPath do
if oldPath[i] ~= newPath[i] then
console.warn(
"copyWithRename() expects paths to be the same except for the deepest key"
)
return nil
end
end
end
return copyWithRenameImpl(obj, oldPath, newPath, 0)
end
local function copyWithSetImpl(
obj: Object,
path: Array<string | number>,
index: number,
value: any
)
if index >= (#path + 1) then
return value
end
local key = path[index]
local updated
if Array.isArray(obj) then
updated = Array.slice(obj)
else
updated = table.clone(obj)
end
updated[key] = copyWithSetImpl(obj[key], path, index + 2, value)
return updated
end
local function copyWithSet(
obj: Object,
path: Array<string | number>,
value: any
): Object | Array<any>
return copyWithSetImpl(obj, path, 1, value)
end
local function findHook(fiber: Fiber, id: number)
local currentHook = fiber.memoizedState
while currentHook ~= nil and id > 1 do
currentHook = currentHook.next
id -= 1
end
return currentHook
end
overrideHookState = function(
fiber: Fiber,
id: number,
path: Array<string | number>,
value: any
)
local hook = findHook(fiber, id)
if hook ~= nil then
local newState = copyWithSet(hook.memoizedState, path, value)
hook.memoizedState = newState
hook.baseState = newState
fiber.memoizedProps = table.clone(fiber.memoizedProps)
scheduleUpdateOnFiber(fiber, SyncLane, NoTimestamp)
end
end
overrideHookStateDeletePath = function(
fiber: Fiber,
id: number,
path: Array<string | number>
)
local hook = findHook(fiber, id)
if hook ~= nil then
local newState = copyWithDelete(hook.memoizedState, path)
hook.memoizedState = newState
hook.baseState = newState
fiber.memoizedProps = table.clone(fiber.memoizedProps)
scheduleUpdateOnFiber(fiber, SyncLane, NoTimestamp)
end
end
overrideHookStateRenamePath = function(
fiber: Fiber,
id: number,
oldPath: Array<string | number>,
newPath: Array<string | number>
)
local hook = findHook(fiber, id)
if hook ~= nil then
local newState = copyWithRename(hook.memoizedState, oldPath, newPath)
hook.memoizedState = newState
hook.baseState = newState
fiber.memoizedProps = table.clone(fiber.memoizedProps)
scheduleUpdateOnFiber(fiber, SyncLane, NoTimestamp)
end
end
overrideProps = function(fiber: Fiber, path: Array<string | number>, value: any)
fiber.pendingProps = copyWithSet(fiber.memoizedProps, path, value)
local alternate = fiber.alternate
if alternate then
alternate.pendingProps = fiber.pendingProps
end
scheduleUpdateOnFiber(fiber, SyncLane, NoTimestamp)
end
overridePropsDeletePath = function(fiber: Fiber, path: Array<string | number>)
fiber.pendingProps = copyWithDelete(fiber.memoizedProps, path)
local alternate = fiber.alternate
if alternate then
alternate.pendingProps = fiber.pendingProps
end
scheduleUpdateOnFiber(fiber, SyncLane, NoTimestamp)
end
overridePropsRenamePath = function(
fiber: Fiber,
oldPath: Array<string | number>,
newPath: Array<string | number>
)
fiber.pendingProps = copyWithRename(fiber.memoizedProps, oldPath, newPath)
local alternate = fiber.alternate
if alternate then
alternate.pendingProps = fiber.pendingProps
end
scheduleUpdateOnFiber(fiber, SyncLane, NoTimestamp)
end
scheduleUpdate = function(fiber: Fiber)
scheduleUpdateOnFiber(fiber, SyncLane, NoTimestamp)
end
setSuspenseHandler = function(newShouldSuspendImpl: (Fiber) -> boolean)
shouldSuspendImpl = newShouldSuspendImpl
end
end
function findHostInstanceByFiber(fiber: Fiber): Instance | TextInstance | nil
local hostFiber = findCurrentHostFiber(fiber)
if hostFiber == nil then
return nil
end
return hostFiber.stateNode
end
function emptyFindFiberByHostInstance(instance: Instance | TextInstance): Fiber | nil
return nil
end
function getCurrentFiberForDevTools()
return ReactCurrentFiber.current
end
exports.injectIntoDevTools = function(devToolsConfig: DevToolsConfig): boolean
local findFiberByHostInstance = devToolsConfig.findFiberByHostInstance
local ReactCurrentDispatcher = ReactSharedInternals.ReactCurrentDispatcher
local getCurrentFiber = nil
if __DEV__ then
getCurrentFiber = getCurrentFiberForDevTools
end
return injectInternals({
bundleType = devToolsConfig.bundleType,
version = devToolsConfig.version,
rendererPackageName = devToolsConfig.rendererPackageName,
rendererConfig = devToolsConfig.rendererConfig,
overrideHookState = overrideHookState,
overrideHookStateDeletePath = overrideHookStateDeletePath,
overrideHookStateRenamePath = overrideHookStateRenamePath,
overrideProps = overrideProps,
overridePropsDeletePath = overridePropsDeletePath,
overridePropsRenamePath = overridePropsRenamePath,
setSuspenseHandler = setSuspenseHandler,
scheduleUpdate = scheduleUpdate,
currentDispatcherRef = ReactCurrentDispatcher,
findHostInstanceByFiber = findHostInstanceByFiber,
findFiberByHostInstance = findFiberByHostInstance or emptyFindFiberByHostInstance,
findHostInstancesForRefresh = if __DEV__
then findHostInstancesForRefresh
else nil,
scheduleRefresh = if __DEV__ then scheduleRefresh else nil,
scheduleRoot = if __DEV__ then scheduleRoot else nil,
setRefreshHandler = if __DEV__ then setRefreshHandler else nil,
getCurrentFiber = getCurrentFiber,
})
end
exports.robloxReactProfiling = __require(script.Parent.RobloxReactProfiling)
exports.schedulingProfiler = {
profilerEventTypes = SchedulingProfiler.profilerEventTypes,
registerProfilerEventCallback = SchedulingProfiler.registerProfilerEventCallback,
}
return exports
end
end)())
__register("ReactReconciler/ReactFiberRoot.new", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberRoot.new"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local LuauPolyfill = __require(Packages.LuauPolyfill)
local Set = LuauPolyfill.Set
local Map = LuauPolyfill.Map
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
type FiberRoot = ReactInternalTypes.FiberRoot
type SuspenseHydrationCallbacks = ReactInternalTypes.SuspenseHydrationCallbacks
local ReactRootTags = __require(script.Parent.ReactRootTags)
type RootTag = ReactRootTags.RootTag
local ReactFiberHostConfig = __require(script.Parent.ReactFiberHostConfig)
local noTimeout = ReactFiberHostConfig.noTimeout
local supportsHydration = ReactFiberHostConfig.supportsHydration
local ReactFiber = __require(script.Parent["ReactFiber.new"])
local createHostRootFiber = ReactFiber.createHostRootFiber
local ReactFiberLane = __require(script.Parent.ReactFiberLane)
local NoLanes = ReactFiberLane.NoLanes
local NoLanePriority = ReactFiberLane.NoLanePriority
local NoTimestamp = ReactFiberLane.NoTimestamp
local createLaneMap = ReactFiberLane.createLaneMap
local ReactFeatureFlags = __require(Packages.Shared).ReactFeatureFlags
local enableSchedulerTracing = ReactFeatureFlags.enableSchedulerTracing
local enableSuspenseCallback = ReactFeatureFlags.enableSuspenseCallback
local Scheduler = __require(Packages.Scheduler).tracing
local unstable_getThreadID = Scheduler.unstable_getThreadID
local ReactUpdateQueue = __require(script.Parent["ReactUpdateQueue.new"])
local initializeUpdateQueue = ReactUpdateQueue.initializeUpdateQueue
local LegacyRoot = ReactRootTags.LegacyRoot
local BlockingRoot = ReactRootTags.BlockingRoot
local ConcurrentRoot = ReactRootTags.ConcurrentRoot
local exports = {}
local function FiberRootNode(containerInfo, tag, hydrate)
local rootNode = {
tag = tag,
containerInfo = containerInfo,
pendingChildren = nil,
current = (nil :: any) :: Fiber,
pingCache = nil,
finishedWork = nil,
timeoutHandle = noTimeout,
context = nil,
pendingContext = nil,
hydrate = hydrate,
callbackNode = nil,
callbackPriority = NoLanePriority,
eventTimes = createLaneMap(NoLanes),
expirationTimes = createLaneMap(NoTimestamp),
pendingLanes = NoLanes,
suspendedLanes = NoLanes,
pingedLanes = NoLanes,
expiredLanes = NoLanes,
mutableReadLanes = NoLanes,
finishedLanes = NoLanes,
entangledLanes = NoLanes,
entanglements = createLaneMap(NoLanes),
}
if supportsHydration then
rootNode.mutableSourceEagerHydrationData = nil
end
if enableSchedulerTracing then
rootNode.interactionThreadID = unstable_getThreadID()
rootNode.memoizedInteractions = Set.new()
rootNode.pendingInteractionMap = Map.new()
end
if enableSuspenseCallback then
rootNode.hydrationCallbacks = nil
end
if ReactGlobals.__DEV__ then
if tag == BlockingRoot then
rootNode._debugRootType = "createBlockingRoot()"
elseif tag == ConcurrentRoot then
rootNode._debugRootType = "createRoot()"
elseif tag == LegacyRoot then
rootNode._debugRootType = "createLegacyRoot()"
end
end
return rootNode
end
exports.createFiberRoot = function(
containerInfo: any,
tag: RootTag,
hydrate: boolean,
hydrationCallbacks: SuspenseHydrationCallbacks?
): FiberRoot
local root: FiberRoot = FiberRootNode(containerInfo, tag, hydrate)
if enableSuspenseCallback then
root.hydrationCallbacks = hydrationCallbacks
end
local uninitializedFiber = createHostRootFiber(tag)
root.current = uninitializedFiber
uninitializedFiber.stateNode = root
initializeUpdateQueue(uninitializedFiber)
return root
end
return exports
end
end)())
__register("ReactReconciler/ReactFiberSchedulerPriorities.roblox", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberSchedulerPriorities.roblox"})
return function()
type ReactPriorityLevel = number
local exports: { [string]: ReactPriorityLevel } = {
ImmediatePriority = 99,
UserBlockingPriority = 98,
NormalPriority = 97,
LowPriority = 96,
IdlePriority = 95,
NoPriority = 90,
}
return exports
end
end)())
__register("ReactReconciler/ReactFiberStack.new", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberStack.new"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local console = __require(Packages.Shared).console
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
type Array<T> = { [number]: T }
type null = {}
local NULL: null = {}
type StackCursor<T> = { current: T }
local valueStack: Array<any> = {}
local fiberStack: Array<Fiber | null>
if ReactGlobals.__DEV__ then
fiberStack = {}
end
local index = 0
local function createCursor<T>(defaultValue: T): StackCursor<T>
return {
current = defaultValue,
}
end
local function isEmpty(): boolean
return index == 0
end
local function pop<T>(cursor: StackCursor<T>, fiber: Fiber): ()
if index < 1 then
if ReactGlobals.__DEV__ then
console.error("Unexpected pop.")
end
return
end
if ReactGlobals.__DEV__ then
if fiber ~= fiberStack[index] :: Fiber then
console.error("Unexpected Fiber popped.")
end
end
local value = valueStack[index]
if value == NULL then
cursor.current = nil :: any
else
cursor.current = value
end
valueStack[index] = nil
if ReactGlobals.__DEV__ then
fiberStack[index] = nil
end
index -= 1
end
local function push<T>(cursor: StackCursor<T>, value: T, fiber: Fiber): ()
index += 1
local stackValue = cursor.current
if stackValue == nil then
valueStack[index] = NULL
else
valueStack[index] = stackValue
end
if ReactGlobals.__DEV__ then
fiberStack[index] = fiber
end
cursor.current = value
end
local function checkThatStackIsEmpty()
if ReactGlobals.__DEV__ then
if index ~= 0 then
console.error("Expected an empty stack. Something was not reset properly.")
end
end
end
local function resetStackAfterFatalErrorInDev()
if ReactGlobals.__DEV__ then
index = 0
table.clear(valueStack)
table.clear(fiberStack)
end
end
return {
createCursor = createCursor,
isEmpty = isEmpty,
pop = pop,
push = push,
checkThatStackIsEmpty = checkThatStackIsEmpty,
resetStackAfterFatalErrorInDev = resetStackAfterFatalErrorInDev,
}
end
end)())
__register("ReactReconciler/ReactFiberSuspenseComponent.new", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberSuspenseComponent.new"})
return function()
local Packages = script.Parent.Parent
local ReactTypes = __require(Packages.Shared)
type ReactNodeList = ReactTypes.ReactNodeList
type Wakeable = ReactTypes.Wakeable
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
local ReactFiberHostConfig = __require(script.Parent.ReactFiberHostConfig)
type SuspenseInstance = ReactFiberHostConfig.SuspenseInstance
local ReactFiberLane = __require(script.Parent.ReactFiberLane)
type Lane = ReactFiberLane.Lane
local ReactWorkTags = __require(script.Parent.ReactWorkTags)
local SuspenseComponent = ReactWorkTags.SuspenseComponent
local SuspenseListComponent = ReactWorkTags.SuspenseListComponent
local ReactFiberFlags = __require(script.Parent.ReactFiberFlags)
local NoFlags = ReactFiberFlags.NoFlags
local DidCapture = ReactFiberFlags.DidCapture
local isSuspenseInstancePending = ReactFiberHostConfig.isSuspenseInstancePending
local isSuspenseInstanceFallback = ReactFiberHostConfig.isSuspenseInstanceFallback
type Set<T> = { [T]: boolean }
type SuspenseProps = {
children: ReactNodeList?,
fallback: ReactNodeList?,
suspenseCallback: (Set<Wakeable>?) -> any,
unstable_expectedLoadTime: number?,
}
type SuspenseState = {
dehydrated: SuspenseInstance?,
retryLane: Lane,
}
type SuspenseListTailMode = string?
type SuspenseListRenderState = {
isBackwards: boolean,
rendering: Fiber?,
renderingStartTime: number,
last: Fiber?,
tail: Fiber?,
tailMode: SuspenseListTailMode,
}
local exports = {}
exports.shouldCaptureSuspense = function(
workInProgress: Fiber,
hasInvisibleParent: boolean
): boolean
local nextState: SuspenseState? = workInProgress.memoizedState
if nextState then
if nextState.dehydrated ~= nil then
return true
end
return false
end
local props = workInProgress.memoizedProps
if props.fallback == nil then
return false
end
if props.unstable_avoidThisFallback ~= true then
return true
end
if hasInvisibleParent then
return false
end
return true
end
exports.findFirstSuspended = function(row: Fiber): Fiber?
local node = row
while node ~= nil do
if node.tag == SuspenseComponent then
local state: SuspenseState? = node.memoizedState
if state then
local dehydrated: SuspenseInstance? = state.dehydrated
if
dehydrated == nil
or isSuspenseInstancePending(dehydrated)
or isSuspenseInstanceFallback(dehydrated)
then
return node
end
end
elseif
node.tag == SuspenseListComponent
and node.memoizedProps.revealOrder ~= nil
then
local didSuspend = bit32.band(node.flags, DidCapture) ~= NoFlags
if didSuspend then
return node
end
elseif node.child ~= nil then
node.child.return_ = node
node = node.child
continue
end
if node == row then
return nil
end
while node.sibling == nil do
if node.return_ == nil or node.return_ == row then
return nil
end
node = node.return_ :: Fiber
end
(node.sibling :: Fiber).return_ = node.return_
node = node.sibling :: Fiber
end
return nil
end
return exports
end
end)())
__register("ReactReconciler/ReactFiberSuspenseContext.new", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberSuspenseContext.new"})
return function()
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
local ReactFiberStack = __require(script.Parent["ReactFiberStack.new"])
type StackCursor<T> = ReactFiberStack.StackCursor<T>
local createCursor = ReactFiberStack.createCursor
local push = ReactFiberStack.push
local pop = ReactFiberStack.pop
type SuspenseContext = number
type SubtreeSuspenseContext = SuspenseContext
type ShallowSuspenseContext = SuspenseContext
local exports = {}
local DefaultSuspenseContext: SuspenseContext = 0b00
local SubtreeSuspenseContextMask: SuspenseContext = 0b01
local InvisibleParentSuspenseContext: SubtreeSuspenseContext = 0b01
exports.InvisibleParentSuspenseContext = InvisibleParentSuspenseContext
local ForceSuspenseFallback: ShallowSuspenseContext = 0b10
exports.ForceSuspenseFallback = ForceSuspenseFallback
local suspenseStackCursor: StackCursor<SuspenseContext> =
createCursor(DefaultSuspenseContext)
exports.suspenseStackCursor = suspenseStackCursor
function exports.hasSuspenseContext(
parentContext: SuspenseContext,
flag: SuspenseContext
): boolean
return bit32.band(parentContext, flag) ~= 0
end
function exports.setDefaultShallowSuspenseContext(
parentContext: SuspenseContext
): SuspenseContext
return bit32.band(parentContext, SubtreeSuspenseContextMask)
end
function exports.setShallowSuspenseContext(
parentContext: SuspenseContext,
shallowContext: ShallowSuspenseContext
): SuspenseContext
return bit32.bor(
bit32.band(parentContext, SubtreeSuspenseContextMask),
shallowContext
)
end
function exports.addSubtreeSuspenseContext(
parentContext: SuspenseContext,
subtreeContext: SubtreeSuspenseContext
): SuspenseContext
return bit32.bor(parentContext, subtreeContext)
end
function exports.pushSuspenseContext(fiber: Fiber, newContext: SuspenseContext)
push(suspenseStackCursor, newContext, fiber)
end
function exports.popSuspenseContext(fiber: Fiber)
pop(suspenseStackCursor, fiber)
end
return exports
end
end)())
__register("ReactReconciler/ReactFiberThrow.new", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberThrow.new"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local LuauPolyfill = __require(Packages.LuauPolyfill)
local Object = LuauPolyfill.Object
local console = __require(Packages.Shared).console
type Error = LuauPolyfill.Error
type Map<K, V> = { [K]: V }
type Object = { [string]: any }
type Set<T> = { [T]: boolean }
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
type FiberRoot = ReactInternalTypes.FiberRoot
type ReactPriorityLevel = ReactInternalTypes.ReactPriorityLevel
local ReactFiberLane = __require(script.Parent.ReactFiberLane)
type Lanes = ReactFiberLane.Lanes
type Lane = ReactFiberLane.Lane
local ReactCapturedValue = __require(script.Parent.ReactCapturedValue)
type CapturedValue<T> = ReactCapturedValue.CapturedValue<T>
local ReactUpdateQueue = __require(script.Parent["ReactUpdateQueue.new"])
type Update<T> = ReactInternalTypes.Update<T>
local ReactTypes = __require(Packages.Shared)
type React_Component<Props, State> = ReactTypes.React_Component<Props, State>
type Thenable<T> = ReactTypes.Thenable<T>
type Wakeable = ReactTypes.Wakeable
local ReactFiberSuspenseContext = __require(script.Parent["ReactFiberSuspenseContext.new"])
type SuspenseContext = ReactFiberSuspenseContext.SuspenseContext
local getComponentName = __require(Packages.Shared).getComponentName
local ReactWorkTags = __require(script.Parent.ReactWorkTags)
local ClassComponent = ReactWorkTags.ClassComponent
local HostRoot = ReactWorkTags.HostRoot
local SuspenseComponent = ReactWorkTags.SuspenseComponent
local IncompleteClassComponent = ReactWorkTags.IncompleteClassComponent
local ReactFiberFlags = __require(script.Parent.ReactFiberFlags)
local DidCapture = ReactFiberFlags.DidCapture
local Incomplete = ReactFiberFlags.Incomplete
local NoFlags = ReactFiberFlags.NoFlags
local ShouldCapture = ReactFiberFlags.ShouldCapture
local LifecycleEffectMask = ReactFiberFlags.LifecycleEffectMask
local ForceUpdateForLegacySuspense = ReactFiberFlags.ForceUpdateForLegacySuspense
local shouldCaptureSuspense =
__require(script.Parent["ReactFiberSuspenseComponent.new"]).shouldCaptureSuspense
local ReactTypeOfMode = __require(script.Parent.ReactTypeOfMode)
local NoMode = ReactTypeOfMode.NoMode
local BlockingMode = ReactTypeOfMode.BlockingMode
local DebugTracingMode = ReactTypeOfMode.DebugTracingMode
local ReactFeatureFlags = __require(Packages.Shared).ReactFeatureFlags
local enableDebugTracing = ReactFeatureFlags.enableDebugTracing
local enableSchedulingProfiler = ReactFeatureFlags.enableSchedulingProfiler
local createCapturedValue = __require(script.Parent.ReactCapturedValue).createCapturedValue
local enqueueCapturedUpdate = ReactUpdateQueue.enqueueCapturedUpdate
local createUpdate = ReactUpdateQueue.createUpdate
local CaptureUpdate = ReactUpdateQueue.CaptureUpdate
local ForceUpdate = ReactUpdateQueue.ForceUpdate
local enqueueUpdate = ReactUpdateQueue.enqueueUpdate
local markFailedErrorBoundaryForHotReloading = __require(
script.Parent["ReactFiberHotReloading.new"]
).markFailedErrorBoundaryForHotReloading
local hasSuspenseContext = ReactFiberSuspenseContext.hasSuspenseContext
local InvisibleParentSuspenseContext =
ReactFiberSuspenseContext.InvisibleParentSuspenseContext
local suspenseStackCursor = ReactFiberSuspenseContext.suspenseStackCursor
local ReactFiberWorkLoop
local markLegacyErrorBoundaryAsFailedRef, isAlreadyFailedLegacyErrorBoundaryRef, pingSuspendedRootRef
local markLegacyErrorBoundaryAsFailed = function(...)
if not markLegacyErrorBoundaryAsFailedRef then
ReactFiberWorkLoop = __require(script.Parent["ReactFiberWorkLoop.new"])
markLegacyErrorBoundaryAsFailedRef =
ReactFiberWorkLoop.markLegacyErrorBoundaryAsFailed
end
return markLegacyErrorBoundaryAsFailedRef(...)
end
local pingSuspendedRoot = function(...)
if ReactFiberWorkLoop == nil then
ReactFiberWorkLoop = __require(script.Parent["ReactFiberWorkLoop.new"])
end
pingSuspendedRootRef = ReactFiberWorkLoop.pingSuspendedRoot
return pingSuspendedRootRef(...)
end
local isAlreadyFailedLegacyErrorBoundary = function(...)
if ReactFiberWorkLoop == nil then
ReactFiberWorkLoop = __require(script.Parent["ReactFiberWorkLoop.new"])
end
isAlreadyFailedLegacyErrorBoundaryRef =
ReactFiberWorkLoop.isAlreadyFailedLegacyErrorBoundary
return isAlreadyFailedLegacyErrorBoundaryRef(...)
end
local logCapturedError = __require(script.Parent.ReactFiberErrorLogger).logCapturedError
local logComponentSuspended = __require(script.Parent.DebugTracing).logComponentSuspended
local markComponentSuspended =
__require(script.Parent.SchedulingProfiler).markComponentSuspended
local SyncLane = ReactFiberLane.SyncLane
local NoTimestamp = ReactFiberLane.NoTimestamp
local includesSomeLane = ReactFiberLane.includesSomeLane
local mergeLanes = ReactFiberLane.mergeLanes
local pickArbitraryLane = ReactFiberLane.pickArbitraryLane
function createRootErrorUpdate(
fiber: Fiber,
errorInfo: CapturedValue<Error>,
lane: Lane,
onUncaughtError
): Update<any>
local update = createUpdate(NoTimestamp, lane)
update.tag = CaptureUpdate
update.payload = { element = Object.None }
local _error = errorInfo.value
update.callback = function()
if onUncaughtError ~= nil then
onUncaughtError(_error)
end
logCapturedError(fiber, errorInfo)
end
return update
end
function createClassErrorUpdate(
fiber: Fiber,
errorInfo: CapturedValue<Error>,
lane: Lane
): Update<any>
local update = createUpdate(NoTimestamp, lane)
update.tag = CaptureUpdate
local getDerivedStateFromError = (fiber.type :: React_Component<any, any>).getDerivedStateFromError
if typeof(getDerivedStateFromError) == "function" then
local error_ = errorInfo.value
update.payload = function()
logCapturedError(fiber, errorInfo)
return getDerivedStateFromError(error_)
end
end
local inst = fiber.stateNode
if inst ~= nil and typeof(inst.componentDidCatch) == "function" then
update.callback = function()
if ReactGlobals.__DEV__ then
markFailedErrorBoundaryForHotReloading(fiber)
end
if typeof(getDerivedStateFromError) ~= "function" then
markLegacyErrorBoundaryAsFailed(inst)
logCapturedError(fiber, errorInfo)
end
local error_ = errorInfo.value
local stack = errorInfo.stack
inst:componentDidCatch(error_, {
componentStack = stack or "",
})
if ReactGlobals.__DEV__ then
if typeof(getDerivedStateFromError) ~= "function" then
if not includesSomeLane(fiber.lanes, SyncLane) then
console.error(
"%s: Error boundaries should implement getDerivedStateFromError(). "
.. "In that method, return a state update to display an error message or fallback UI.",
getComponentName(fiber.type) or "Unknown"
)
end
end
end
end
elseif ReactGlobals.__DEV__ then
update.callback = function()
markFailedErrorBoundaryForHotReloading(fiber)
end
end
return update
end
local function attachPingListener(root: FiberRoot, wakeable: Wakeable, lanes: Lanes)
local pingCache: Map<Wakeable, (Set<any> | Map<Wakeable, Set<any>>)> | nil =
root.pingCache
local threadIDs
if pingCache == nil then
threadIDs = {} :: Set<any>
root.pingCache = {
[wakeable] = threadIDs,
} :: Map<Wakeable, (Set<any> | Map<Wakeable, Set<any>>)>
pingCache = root.pingCache :: Map<Wakeable, (Set<any> | Map<Wakeable, Set<any>>)>
else
threadIDs = (
pingCache :: Map<Wakeable, (Set<any> | Map<Wakeable, Set<any>>)>
)[wakeable] :: Set<any>
if threadIDs == nil then
threadIDs = {} :: Set<any>;
(pingCache :: Map<Wakeable, (Set<any> | Map<Wakeable, Set<any>>)>)[wakeable] =
threadIDs
end
end
if not threadIDs[lanes] then
threadIDs[lanes] = true
local ping = function()
return pingSuspendedRoot(root, wakeable, lanes)
end
wakeable:andThen(ping, ping)
end
end
function throwException(
root: FiberRoot,
returnFiber: Fiber,
sourceFiber: Fiber,
value: any,
rootRenderLanes: Lanes,
onUncaughtError,
renderDidError
)
sourceFiber.flags = bit32.bor(sourceFiber.flags, Incomplete)
if
value ~= nil
and typeof(value) == "table"
and typeof(value.andThen) == "function"
then
local wakeable: Wakeable = value
if ReactGlobals.__DEV__ then
if enableDebugTracing then
if bit32.band(sourceFiber.mode, DebugTracingMode) ~= 0 then
local name = getComponentName(sourceFiber.type) or "Unknown"
logComponentSuspended(name, wakeable)
end
end
end
if enableSchedulingProfiler then
markComponentSuspended(sourceFiber, wakeable)
end
if bit32.band(sourceFiber.mode, BlockingMode) == NoMode then
local currentSource = sourceFiber.alternate
if currentSource then
sourceFiber.updateQueue = currentSource.updateQueue
sourceFiber.memoizedState = currentSource.memoizedState
sourceFiber.lanes = currentSource.lanes
else
sourceFiber.updateQueue = nil
sourceFiber.memoizedState = nil
end
end
local hasInvisibleParentBoundary = hasSuspenseContext(
suspenseStackCursor.current,
InvisibleParentSuspenseContext :: SuspenseContext
)
local workInProgress = returnFiber
repeat
if
workInProgress.tag == SuspenseComponent
and shouldCaptureSuspense(workInProgress, hasInvisibleParentBoundary)
then
local wakeables: Set<Wakeable> = workInProgress.updateQueue
if wakeables == nil then
local updateQueue = {
[wakeable] = true,
}
workInProgress.updateQueue = updateQueue
else
wakeables[wakeable] = true
end
if bit32.band(workInProgress.mode, BlockingMode) == NoMode then
workInProgress.flags = bit32.bor(workInProgress.flags, DidCapture)
sourceFiber.flags =
bit32.bor(sourceFiber.flags, ForceUpdateForLegacySuspense)
sourceFiber.flags = bit32.band(
sourceFiber.flags,
bit32.bnot(bit32.bor(LifecycleEffectMask, Incomplete))
)
if sourceFiber.tag == ClassComponent then
local currentSourceFiber = sourceFiber.alternate
if currentSourceFiber == nil then
sourceFiber.tag = IncompleteClassComponent
else
local update = createUpdate(NoTimestamp, SyncLane)
update.tag = ForceUpdate
enqueueUpdate(sourceFiber, update)
end
end
sourceFiber.lanes = mergeLanes(sourceFiber.lanes, SyncLane)
return
end
attachPingListener(root, wakeable, rootRenderLanes)
workInProgress.flags = bit32.bor(workInProgress.flags, ShouldCapture)
workInProgress.lanes = rootRenderLanes
return
end
workInProgress = workInProgress.return_ :: Fiber
until workInProgress == nil
value = (getComponentName(sourceFiber.type) or "A React component")
.. " suspended while rendering, but no fallback UI was specified.\n"
.. "\n"
.. "Add a <Suspense fallback=...> component higher in the tree to "
.. "provide a loading indicator or placeholder to display."
end
renderDidError()
value = createCapturedValue(value, sourceFiber)
local workInProgress = returnFiber
repeat
if workInProgress.tag == HostRoot then
local errorInfo = value
workInProgress.flags = bit32.bor(workInProgress.flags, ShouldCapture)
local lane = pickArbitraryLane(rootRenderLanes)
workInProgress.lanes = mergeLanes(workInProgress.lanes, lane)
local update =
createRootErrorUpdate(workInProgress, errorInfo, lane, onUncaughtError)
enqueueCapturedUpdate(workInProgress, update)
return
elseif workInProgress.tag == ClassComponent then
local errorInfo = value
local ctor = workInProgress.type
local instance = workInProgress.stateNode
if
bit32.band(workInProgress.flags, DidCapture) == NoFlags
and (
typeof(ctor.getDerivedStateFromError) == "function"
or (
instance ~= nil
and typeof(instance.componentDidCatch) == "function"
and not isAlreadyFailedLegacyErrorBoundary(instance)
)
)
then
workInProgress.flags = bit32.bor(workInProgress.flags, ShouldCapture)
local lane = pickArbitraryLane(rootRenderLanes)
workInProgress.lanes = mergeLanes(workInProgress.lanes, lane)
local update = createClassErrorUpdate(workInProgress, errorInfo, lane)
enqueueCapturedUpdate(workInProgress, update)
return
end
end
workInProgress = workInProgress.return_ :: Fiber
until workInProgress == nil
end
return {
throwException = throwException,
createRootErrorUpdate = createRootErrorUpdate,
createClassErrorUpdate = createClassErrorUpdate,
}
end
end)())
__register("ReactReconciler/ReactFiberTransition", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberTransition"})
return function()
local Packages = script.Parent.Parent
local ReactSharedInternals = __require(Packages.Shared).ReactSharedInternals
local ReactCurrentBatchConfig = ReactSharedInternals.ReactCurrentBatchConfig
return {
NoTransition = 0,
requestCurrentTransition = function(): number
return ReactCurrentBatchConfig.transition
end,
}
end
end)())
__register("ReactReconciler/ReactFiberTreeReflection", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberTreeReflection"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local console = __require(Packages.Shared).console
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
local ReactFiberHostConfig = __require(script.Parent.ReactFiberHostConfig)
type Container = ReactFiberHostConfig.Container
type SuspenseInstance = ReactFiberHostConfig.SuspenseInstance
local ReactFiberSuspenseComponent =
__require(script.Parent["ReactFiberSuspenseComponent.new"])
type SuspenseState = ReactFiberSuspenseComponent.SuspenseState
local invariant = __require(Packages.Shared).invariant
local getInstance = __require(Packages.Shared).ReactInstanceMap.get
local ReactSharedInternals = __require(Packages.Shared).ReactSharedInternals
local getComponentName = __require(Packages.Shared).getComponentName
local ReactWorkTags = __require(script.Parent.ReactWorkTags)
local ClassComponent = ReactWorkTags.ClassComponent
local HostComponent = ReactWorkTags.HostComponent
local HostRoot = ReactWorkTags.HostRoot
local HostPortal = ReactWorkTags.HostPortal
local HostText = ReactWorkTags.HostText
local FundamentalComponent = ReactWorkTags.FundamentalComponent
local SuspenseComponent = ReactWorkTags.SuspenseComponent
local ReactFiberFlags = __require(script.Parent.ReactFiberFlags)
local NoFlags = ReactFiberFlags.NoFlags
local Placement = ReactFiberFlags.Placement
local Hydrating = ReactFiberFlags.Hydrating
local enableFundamentalAPI =
__require(Packages.Shared).ReactFeatureFlags.enableFundamentalAPI
local ReactCurrentOwner = ReactSharedInternals.ReactCurrentOwner
local exports = {}
local function getNearestMountedFiber(fiber: Fiber): Fiber?
local node = fiber
local nearestMounted: Fiber | nil = fiber
if not fiber.alternate then
local nextNode = node
repeat
node = nextNode
if bit32.band(node.flags, bit32.bor(Placement, Hydrating)) ~= NoFlags then
nearestMounted = node.return_
end
nextNode = node.return_
until not nextNode
else
while node.return_ do
node = node.return_
end
end
if node.tag == HostRoot then
return nearestMounted
end
return nil
end
exports.getNearestMountedFiber = getNearestMountedFiber
exports.getSuspenseInstanceFromFiber = function(fiber: Fiber): SuspenseInstance?
if fiber.tag == SuspenseComponent then
local suspenseState: SuspenseState? = fiber.memoizedState
if suspenseState == nil then
local current = fiber.alternate
if current ~= nil then
suspenseState = current.memoizedState
end
end
if suspenseState then
return suspenseState.dehydrated
end
end
return nil
end
exports.getContainerFromFiber = function(fiber: Fiber): Container?
return if fiber.tag == HostRoot then fiber.stateNode.containerInfo else nil
end
exports.isFiberMounted = function(fiber: Fiber): boolean
return getNearestMountedFiber(fiber) == fiber
end
exports.isMounted = function(component): boolean
if ReactGlobals.__DEV__ then
local owner: any = ReactCurrentOwner.current
if owner ~= nil and owner.tag == ClassComponent then
local ownerFiber: Fiber = owner
local instance = ownerFiber.stateNode
if not instance._warnedAboutRefsInRender then
console.error(
"%s is accessing isMounted inside its render() function. "
.. "render() should be a pure function of props and state. It should "
.. "never access something that requires stale data from the previous "
.. "render, such as refs. Move this logic to componentDidMount and "
.. "componentDidUpdate instead.",
getComponentName(ownerFiber.type) or "A component"
)
end
instance._warnedAboutRefsInRender = true
end
end
local fiber: Fiber? = getInstance(component)
if not fiber then
return false
else
local fiberNonNil: any = fiber
return getNearestMountedFiber(fiberNonNil) == fiber
end
end
local function assertIsMounted(fiber)
invariant(
getNearestMountedFiber(fiber) == fiber,
"Unable to find node on an unmounted component."
)
end
local function findCurrentFiberUsingSlowPath(fiber: Fiber): Fiber?
local alternate = fiber.alternate
if not alternate then
local nearestMounted = getNearestMountedFiber(fiber)
invariant(nearestMounted ~= nil, "Unable to find node on an unmounted component.")
if nearestMounted ~= fiber then
return nil
end
return fiber
end
local a: Fiber = fiber
local b: Fiber = alternate
while true do
local parentA = a.return_
if parentA == nil then
break
end
local parentB = parentA.alternate
if parentB == nil then
local nextParent = parentA.return_
if nextParent ~= nil then
a = nextParent
b = nextParent
continue
end
break
end
if parentA.child == parentB.child then
local child = parentA.child
while child do
if child == a then
assertIsMounted(parentA)
return fiber
end
if child == b then
assertIsMounted(parentA)
return alternate
end
child = child.sibling
end
invariant(false, "Unable to find node on an unmounted component.")
end
if a.return_ ~= b.return_ then
a = parentA
b = parentB
else
local didFindChild = false
local child = parentA.child
while child do
if child == a then
didFindChild = true
a = parentA
b = parentB
break
end
if child == b then
didFindChild = true
b = parentA
a = parentB
break
end
child = child.sibling
end
if not didFindChild then
child = parentB.child
while child do
if child == a then
didFindChild = true
a = parentB
b = parentA
break
end
if child == b then
didFindChild = true
b = parentB
a = parentA
break
end
child = child.sibling
end
invariant(
didFindChild,
"Child was not found in either parent set. This indicates a bug "
.. "in React related to the return pointer. Please file an issue."
)
end
end
invariant(
a.alternate == b,
"Return fibers should always be each others' alternates. "
.. "This error is likely caused by a bug in React. Please file an issue."
)
end
invariant(a.tag == HostRoot, "Unable to find node on an unmounted component.")
if a.stateNode.current == a then
return fiber
end
return alternate
end
exports.findCurrentFiberUsingSlowPath = findCurrentFiberUsingSlowPath
exports.findCurrentHostFiber = function(parent: Fiber): Fiber?
local currentParent = findCurrentFiberUsingSlowPath(parent)
if not currentParent then
return nil
end
local node: Fiber = currentParent :: Fiber
while true do
local child = node.child
if node.tag == HostComponent or node.tag == HostText then
return node
elseif child then
child.return_ = node
node = child
continue
end
if node == currentParent then
return nil
end
local return_ = node.return_
local sibling = node.sibling
while not sibling do
if not return_ or return_ == currentParent then
return nil
end
node = return_ :: Fiber
end
(sibling :: Fiber).return_ = return_ :: Fiber
node = sibling :: Fiber
end
return nil
end
exports.findCurrentHostFiberWithNoPortals = function(parent: Fiber): Fiber?
local currentParent = findCurrentFiberUsingSlowPath(parent)
if not currentParent then
return nil
end
local node: Fiber = currentParent :: Fiber
while true do
local child = node.child
if
node.tag == HostComponent
or node.tag == HostText
or (enableFundamentalAPI and node.tag == FundamentalComponent)
then
return node
elseif child and node.tag ~= HostPortal then
child.return_ = node
node = child
continue
end
if node == currentParent then
return nil
end
local return_ = node.return_
local sibling = node.sibling
while not sibling do
if not return_ or return_ == currentParent then
return nil
end
node = return_ :: Fiber
end
(sibling :: Fiber).return_ = return_ :: Fiber
node = sibling :: Fiber
end
return nil
end
exports.isFiberSuspenseAndTimedOut = function(fiber: Fiber): boolean
local memoizedState = fiber.memoizedState
return fiber.tag == SuspenseComponent
and memoizedState ~= nil
and memoizedState.dehydrated == nil
end
exports.doesFiberContain = function(parentFiber: Fiber, childFiber: Fiber): boolean
local node = childFiber
local parentFiberAlternate = parentFiber.alternate
while node ~= nil do
if node == parentFiber or node == parentFiberAlternate then
return true
end
node = node.return_ :: Fiber
end
return false
end
return exports
end
end)())
__register("ReactReconciler/ReactFiberUnwindWork.new", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberUnwindWork.new"})
return function()
local Packages = script.Parent.Parent
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
local ReactFiberLane = __require(script.Parent.ReactFiberLane)
type Lanes = ReactFiberLane.Lanes
local ReactFiberSuspenseComponent =
__require(script.Parent["ReactFiberSuspenseComponent.new"])
type SuspenseState = ReactFiberSuspenseComponent.SuspenseState
local resetMutableSourceWorkInProgressVersions =
__require(script.Parent["ReactMutableSource.new"]).resetWorkInProgressVersions
local ReactWorkTags = __require(script.Parent.ReactWorkTags)
local ReactFiberFlags = __require(script.Parent.ReactFiberFlags)
local ReactTypeOfMode = __require(script.Parent.ReactTypeOfMode)
local ReactFeatureFlags = __require(Packages.Shared).ReactFeatureFlags
local enableSuspenseServerRenderer = ReactFeatureFlags.enableSuspenseServerRenderer
local enableProfilerTimer = ReactFeatureFlags.enableProfilerTimer
local ReactFiberHostContext = __require(script.Parent["ReactFiberHostContext.new"])
local popHostContainer = ReactFiberHostContext.popHostContainer
local popHostContext = ReactFiberHostContext.popHostContext
local popSuspenseContext =
__require(script.Parent["ReactFiberSuspenseContext.new"]).popSuspenseContext
local resetHydrationState =
__require(script.Parent["ReactFiberHydrationContext.new"]).resetHydrationState
local ReactFiberContext = __require(script.Parent["ReactFiberContext.new"])
local isLegacyContextProvider = ReactFiberContext.isContextProvider
local popLegacyContext = ReactFiberContext.popContext
local popTopLevelLegacyContextObject = ReactFiberContext.popTopLevelContextObject
local popProvider = __require(script.Parent["ReactFiberNewContext.new"]).popProvider
local popRenderLanesRef
local popRenderLanes = function(...)
if not popRenderLanesRef then
popRenderLanesRef =
__require(script.Parent["ReactFiberWorkLoop.new"]).popRenderLanes
end
return popRenderLanesRef(...)
end
local transferActualDuration =
__require(script.Parent["ReactProfilerTimer.new"]).transferActualDuration
local invariant = __require(Packages.Shared).invariant
local function unwindWork(workInProgress: Fiber, renderLanes: Lanes): Fiber?
if workInProgress.tag == ReactWorkTags.ClassComponent then
local Component = workInProgress.type
if isLegacyContextProvider(Component) then
popLegacyContext(workInProgress)
end
local flags = workInProgress.flags
if bit32.band(flags, ReactFiberFlags.ShouldCapture) ~= 0 then
workInProgress.flags = bit32.bor(
bit32.band(flags, bit32.bnot(ReactFiberFlags.ShouldCapture)),
ReactFiberFlags.DidCapture
)
if
enableProfilerTimer
and bit32.band(workInProgress.mode, ReactTypeOfMode.ProfileMode)
~= ReactTypeOfMode.NoMode
then
transferActualDuration(workInProgress)
end
return workInProgress
end
return nil
elseif workInProgress.tag == ReactWorkTags.HostRoot then
popHostContainer(workInProgress)
popTopLevelLegacyContextObject(workInProgress)
resetMutableSourceWorkInProgressVersions()
local flags = workInProgress.flags
invariant(
bit32.band(flags, ReactFiberFlags.DidCapture) == ReactFiberFlags.NoFlags,
"The root failed to unmount after an error. This is likely a bug in "
.. "React. Please file an issue."
)
workInProgress.flags = bit32.bor(
bit32.band(flags, bit32.bnot(ReactFiberFlags.ShouldCapture)),
ReactFiberFlags.DidCapture
)
return workInProgress
elseif workInProgress.tag == ReactWorkTags.HostComponent then
popHostContext(workInProgress)
return nil
elseif workInProgress.tag == ReactWorkTags.SuspenseComponent then
popSuspenseContext(workInProgress)
if enableSuspenseServerRenderer then
local suspenseState = workInProgress.memoizedState
if suspenseState ~= nil and suspenseState.dehydrated ~= nil then
invariant(
workInProgress.alternate ~= nil,
"Threw in newly mounted dehydrated component. This is likely a bug in "
.. "React. Please file an issue."
)
resetHydrationState()
end
end
local flags = workInProgress.flags
if bit32.band(flags, ReactFiberFlags.ShouldCapture) ~= 0 then
workInProgress.flags = bit32.bor(
bit32.band(flags, bit32.bnot(ReactFiberFlags.ShouldCapture)),
ReactFiberFlags.DidCapture
)
if
enableProfilerTimer
and (
bit32.band(workInProgress.mode, ReactTypeOfMode.ProfileMode)
~= ReactTypeOfMode.NoMode
)
then
transferActualDuration(workInProgress)
end
return workInProgress
end
return nil
elseif workInProgress.tag == ReactWorkTags.SuspenseListComponent then
popSuspenseContext(workInProgress)
return nil
elseif workInProgress.tag == ReactWorkTags.HostPortal then
popHostContainer(workInProgress)
return nil
elseif workInProgress.tag == ReactWorkTags.ContextProvider then
popProvider(workInProgress)
return nil
elseif
workInProgress.tag == ReactWorkTags.OffscreenComponent
or workInProgress.tag == ReactWorkTags.LegacyHiddenComponent
then
popRenderLanes(workInProgress)
return nil
else
return nil
end
end
function unwindInterruptedWork(interruptedWork: Fiber)
if interruptedWork.tag == ReactWorkTags.ClassComponent then
local childContextTypes
if typeof(interruptedWork.type) == "table" then
childContextTypes = interruptedWork.type.childContextTypes
end
if childContextTypes ~= nil then
popLegacyContext(interruptedWork)
end
elseif interruptedWork.tag == ReactWorkTags.HostRoot then
popHostContainer(interruptedWork)
popTopLevelLegacyContextObject(interruptedWork)
resetMutableSourceWorkInProgressVersions()
elseif interruptedWork.tag == ReactWorkTags.HostComponent then
popHostContext(interruptedWork)
elseif interruptedWork.tag == ReactWorkTags.HostPortal then
popHostContainer(interruptedWork)
elseif interruptedWork.tag == ReactWorkTags.SuspenseComponent then
popSuspenseContext(interruptedWork)
elseif interruptedWork.tag == ReactWorkTags.SuspenseListComponent then
popSuspenseContext(interruptedWork)
elseif interruptedWork.tag == ReactWorkTags.ContextProvider then
popProvider(interruptedWork)
elseif
interruptedWork.tag == ReactWorkTags.OffscreenComponent
or interruptedWork.tag == ReactWorkTags.LegacyHiddenComponent
then
popRenderLanes(interruptedWork)
return
else
return
end
end
return {
unwindWork = unwindWork,
unwindInterruptedWork = unwindInterruptedWork,
}
end
end)())
__register("ReactReconciler/ReactFiberWorkInProgress", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberWorkInProgress"})
return function()
local ReactFiberLane = __require(script.Parent.ReactFiberLane)
local _workInProgressRootSkippedLanes: Lanes = ReactFiberLane.NoLanes
local mergeLanes = ReactFiberLane.mergeLanes
type Lanes = ReactFiberLane.Lanes
type Lane = ReactFiberLane.Lane
local exports = {}
exports.workInProgressRootSkippedLanes = function(value: Lanes?): Lanes
if value == nil then
return _workInProgressRootSkippedLanes
end
_workInProgressRootSkippedLanes = value :: Lanes
return _workInProgressRootSkippedLanes
end
exports.markSkippedUpdateLanes = function(lane: Lane | Lanes): ()
_workInProgressRootSkippedLanes = mergeLanes(lane, _workInProgressRootSkippedLanes)
end
return exports
end
end)())
__register("ReactReconciler/ReactFiberWorkLoop.new", (function()
local script = __makeProxy({"ReactReconciler","ReactFiberWorkLoop.new"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local console = __require(Packages.Shared).console
local LuauPolyfill = __require(Packages.LuauPolyfill)
local Set = LuauPolyfill.Set
type Set<T> = LuauPolyfill.Set<T>
type Array<T> = LuauPolyfill.Array<T>
local __DEV__ = ReactGlobals.__DEV__
local __YOLO__ = ReactGlobals.__YOLO__
local exports: any = {}
local ReactTypes = __require(Packages.Shared)
type Thenable<T> = ReactTypes.Thenable<T>
type Wakeable = ReactTypes.Wakeable
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
type FiberRoot = ReactInternalTypes.FiberRoot
type ReactPriorityLevel = ReactInternalTypes.ReactPriorityLevel
local ReactFiberLane = __require(script.Parent.ReactFiberLane)
type Lanes = ReactFiberLane.Lanes
type Lane = ReactFiberLane.Lane
local Scheduler = __require(Packages.Scheduler)
type Interaction = Scheduler.Interaction
local ReactFiberSuspenseComponent =
__require(script.Parent["ReactFiberSuspenseComponent.new"])
type SuspenseState = ReactFiberSuspenseComponent.SuspenseState
local ReactFiberStack = __require(script.Parent["ReactFiberStack.new"])
type StackCursor<T> = ReactFiberStack.StackCursor<T>
local ReactFeatureFlags = __require(Packages.Shared).ReactFeatureFlags
local enableDebugTracing = ReactFeatureFlags.enableDebugTracing
local enableSchedulingProfiler = ReactFeatureFlags.enableSchedulingProfiler
local skipUnmountedBoundaries = ReactFeatureFlags.skipUnmountedBoundaries
local enableDoubleInvokingEffects = ReactFeatureFlags.enableDoubleInvokingEffects
local deletedTreeCleanUpLevel = ReactFeatureFlags.deletedTreeCleanUpLevel
local enableNewTreeCleanupPath = ReactFeatureFlags.enableNewTreeCleanupPath
local ReactShared = __require(Packages.Shared)
type Dispatcher = ReactShared.Dispatcher
local describeError = __require(Packages.Shared).describeError
local ReactSharedInternals = ReactShared.ReactSharedInternals
local invariant = ReactShared.invariant
local SchedulerWithReactIntegration =
__require(script.Parent["SchedulerWithReactIntegration.new"])
local scheduleCallback = SchedulerWithReactIntegration.scheduleCallback
local cancelCallback = SchedulerWithReactIntegration.cancelCallback
local getCurrentPriorityLevel = SchedulerWithReactIntegration.getCurrentPriorityLevel
local runWithPriority = SchedulerWithReactIntegration.runWithPriority
local shouldYield = SchedulerWithReactIntegration.shouldYield
local requestPaint = SchedulerWithReactIntegration.requestPaint
local now = SchedulerWithReactIntegration.now
local NoSchedulerPriority = SchedulerWithReactIntegration.NoPriority
local ImmediateSchedulerPriority = SchedulerWithReactIntegration.ImmediatePriority
local UserBlockingSchedulerPriority = SchedulerWithReactIntegration.UserBlockingPriority
local NormalSchedulerPriority = SchedulerWithReactIntegration.NormalPriority
local flushSyncCallbackQueue = SchedulerWithReactIntegration.flushSyncCallbackQueue
local scheduleSyncCallback = SchedulerWithReactIntegration.scheduleSyncCallback
local DebugTracing = __require(script.Parent.DebugTracing)
local SchedulingProfiler = __require(script.Parent.SchedulingProfiler)
local SchedulerTracing = __require(Packages.Scheduler).tracing
local __interactionsRef, __subscriberRef =
SchedulerTracing.__interactionsRef, SchedulerTracing.__subscriberRef
local ReactFiberHostConfig = __require(script.Parent.ReactFiberHostConfig)
local ReactFiber = __require(script.Parent["ReactFiber.new"])
local ReactTypeOfMode = __require(script.Parent.ReactTypeOfMode)
local ReactWorkTags = __require(script.Parent.ReactWorkTags)
local LegacyRoot = __require(script.Parent.ReactRootTags).LegacyRoot
local ReactFiberFlags = __require(script.Parent.ReactFiberFlags)
type Flags = ReactFiberFlags.Flags
local SyncLane = ReactFiberLane.SyncLane
local SyncBatchedLane = ReactFiberLane.SyncBatchedLane
local NoTimestamp = ReactFiberLane.NoTimestamp
local findUpdateLane = ReactFiberLane.findUpdateLane
local findTransitionLane = ReactFiberLane.findTransitionLane
local findRetryLane = ReactFiberLane.findRetryLane
local includesSomeLane = ReactFiberLane.includesSomeLane
local isSubsetOfLanes = ReactFiberLane.isSubsetOfLanes
local mergeLanes = ReactFiberLane.mergeLanes
local removeLanes = ReactFiberLane.removeLanes
local pickArbitraryLane = ReactFiberLane.pickArbitraryLane
local hasDiscreteLanes = ReactFiberLane.hasDiscreteLanes
local includesNonIdleWork = ReactFiberLane.includesNonIdleWork
local includesOnlyRetries = ReactFiberLane.includesOnlyRetries
local includesOnlyTransitions = ReactFiberLane.includesOnlyTransitions
local getNextLanes = ReactFiberLane.getNextLanes
local returnNextLanesPriority = ReactFiberLane.returnNextLanesPriority
local setCurrentUpdateLanePriority = ReactFiberLane.setCurrentUpdateLanePriority
local getCurrentUpdateLanePriority = ReactFiberLane.getCurrentUpdateLanePriority
local markStarvedLanesAsExpired = ReactFiberLane.markStarvedLanesAsExpired
local getLanesToRetrySynchronouslyOnError =
ReactFiberLane.getLanesToRetrySynchronouslyOnError
local markRootUpdated = ReactFiberLane.markRootUpdated
local markRootPinged = ReactFiberLane.markRootPinged
local markRootExpired = ReactFiberLane.markRootExpired
local markDiscreteUpdatesExpired = ReactFiberLane.markDiscreteUpdatesExpired
local markRootFinished = ReactFiberLane.markRootFinished
local schedulerPriorityToLanePriority = ReactFiberLane.schedulerPriorityToLanePriority
local lanePriorityToSchedulerPriority = ReactFiberLane.lanePriorityToSchedulerPriority
local ReactFiberTransition = __require(script.Parent.ReactFiberTransition)
local ReactFiberUnwindWork = __require(script.Parent["ReactFiberUnwindWork.new"]) :: any
local unwindWork = ReactFiberUnwindWork.unwindWork
local unwindInterruptedWork = ReactFiberUnwindWork.unwindInterruptedWork
local ReactFiberThrow = __require(script.Parent["ReactFiberThrow.new"]) :: any
local throwException = ReactFiberThrow.throwException
local createRootErrorUpdate = ReactFiberThrow.createRootErrorUpdate
local createClassErrorUpdate = ReactFiberThrow.createClassErrorUpdate
local ReactFiberCommitWork = __require(script.Parent["ReactFiberCommitWork.new"])
local commitBeforeMutationEffectOnFiber =
ReactFiberCommitWork.commitBeforeMutationLifeCycles
local commitPlacement = ReactFiberCommitWork.commitPlacement
local commitWork = ReactFiberCommitWork.commitWork
local commitDeletion = ReactFiberCommitWork.commitDeletion
local commitPassiveUnmountOnFiber = ReactFiberCommitWork.commitPassiveUnmount
local commitPassiveUnmountInsideDeletedTreeOnFiber =
ReactFiberCommitWork.commitPassiveUnmountInsideDeletedTree
local commitPassiveMountOnFiber = ReactFiberCommitWork.commitPassiveMount
local commitDetachRef = ReactFiberCommitWork.commitDetachRef
local invokeLayoutEffectMountInDEV = ReactFiberCommitWork.invokeLayoutEffectMountInDEV
local invokePassiveEffectMountInDEV = ReactFiberCommitWork.invokePassiveEffectMountInDEV
local invokeLayoutEffectUnmountInDEV = ReactFiberCommitWork.invokeLayoutEffectUnmountInDEV
local invokePassiveEffectUnmountInDEV =
ReactFiberCommitWork.invokePassiveEffectUnmountInDEV
local recursivelyCommitLayoutEffects = ReactFiberCommitWork.recursivelyCommitLayoutEffects
local Promise = __require(Packages.Promise)
local enqueueUpdate = __require(script.Parent["ReactUpdateQueue.new"]).enqueueUpdate
local resetContextDependencies =
__require(script.Parent["ReactFiberNewContext.new"]).resetContextDependencies
local RobloxReactProfiling = __require(script.Parent.RobloxReactProfiling)
local ensureRootIsScheduled
local lazyInitRefs = {
resetHooksAfterThrowRef = (nil :: any) :: (...any) -> ...any,
ContextOnlyDispatcherRef = (nil :: any) :: Dispatcher,
getIsUpdatingOpaqueValueInRenderPhaseInDEVRef = (nil :: any) :: (...any) -> ...any,
originalBeginWorkRef = (nil :: any) :: (...any) -> ...any,
completeWorkRef = (nil :: any) :: (...any) -> ...any,
}
local originalBeginWork = function(
current: Fiber | nil,
workInProgress: Fiber,
renderLanes: Lanes
): Fiber | nil
if not lazyInitRefs.originalBeginWorkRef then
lazyInitRefs.originalBeginWorkRef =
__require(script.Parent["ReactFiberBeginWork.new"]).beginWork
end
return lazyInitRefs.originalBeginWorkRef(current, workInProgress, renderLanes)
end
local completeWork = function(
current: Fiber | nil,
workInProgress: Fiber,
renderLanes: Lanes
): Fiber | nil
if not lazyInitRefs.completeWorkRef then
lazyInitRefs.completeWorkRef =
__require(script.Parent["ReactFiberCompleteWork.new"]).completeWork
end
return (lazyInitRefs.completeWorkRef :: any)(current, workInProgress, renderLanes)
end
local ReactFiberHooks
local function initReactFiberHooks()
ReactFiberHooks = __require(script.Parent["ReactFiberHooks.new"])
lazyInitRefs.resetHooksAfterThrowRef = ReactFiberHooks.resetHooksAfterThrow
lazyInitRefs.ContextOnlyDispatcherRef = ReactFiberHooks.ContextOnlyDispatcher
lazyInitRefs.getIsUpdatingOpaqueValueInRenderPhaseInDEVRef =
ReactFiberHooks.getIsUpdatingOpaqueValueInRenderPhaseInDEV
end
local resetHooksAfterThrow = function(): ()
if not lazyInitRefs.resetHooksAfterThrowRef then
initReactFiberHooks()
end
return lazyInitRefs.resetHooksAfterThrowRef()
end
local ContextOnlyDispatcher = function(): Dispatcher
if not lazyInitRefs.ContextOnlyDispatcherRef then
initReactFiberHooks()
end
return lazyInitRefs.ContextOnlyDispatcherRef
end
local getIsUpdatingOpaqueValueInRenderPhaseInDEV = function(): boolean?
if not lazyInitRefs.getIsUpdatingOpaqueValueInRenderPhaseInDEVRef then
initReactFiberHooks()
end
return lazyInitRefs.getIsUpdatingOpaqueValueInRenderPhaseInDEVRef()
end
local createCapturedValue = __require(script.Parent.ReactCapturedValue).createCapturedValue
local pushToStack = ReactFiberStack.push
local popFromStack = ReactFiberStack.pop
local createCursor = ReactFiberStack.createCursor
local ReactProfilerTimer = __require(script.Parent["ReactProfilerTimer.new"])
local getComponentName = __require(Packages.Shared).getComponentName
local ReactStrictModeWarnings = __require(script.Parent["ReactStrictModeWarnings.new"])
local ReactCurrentFiber = __require(script.Parent.ReactCurrentFiber)
local ReactCurrentFiberCurrent = ReactCurrentFiber.current
local resetCurrentDebugFiberInDEV = ReactCurrentFiber.resetCurrentFiber
local setCurrentDebugFiberInDEV = ReactCurrentFiber.setCurrentFiber
local ReactErrorUtils = __require(Packages.Shared).ReactErrorUtils
local invokeGuardedCallback = ReactErrorUtils.invokeGuardedCallback
local hasCaughtError = ReactErrorUtils.hasCaughtError
local clearCaughtError = ReactErrorUtils.clearCaughtError
local onCommitRootDevTools =
__require(script.Parent["ReactFiberDevToolsHook.new"]).onCommitRoot
local onCommitRootTestSelector = __require(script.Parent.ReactTestSelectors).onCommitRoot
local enqueueTask = __require(Packages.Shared).enqueueTask
local doesFiberContain = __require(script.Parent.ReactFiberTreeReflection).doesFiberContain
local ReactCurrentDispatcher = ReactSharedInternals.ReactCurrentDispatcher
local ReactCurrentOwner = ReactSharedInternals.ReactCurrentOwner
local IsSomeRendererActing = ReactSharedInternals.IsSomeRendererActing
local captureCommitPhaseErrorOnRoot, flushPassiveMountEffects
local mod: { [string]: any } = {}
type ExecutionContext = number
local NoContext =
0b0000000
local BatchedContext =
0b0000001
local EventContext =
0b0000010
local DiscreteEventContext =
0b0000100
local LegacyUnbatchedContext =
0b0001000
local RenderContext =
0b0010000
local CommitContext =
0b0100000
local RetryAfterError =
0b1000000
exports.NoContext = NoContext
exports.RetryAfterError = RetryAfterError
type RootExitStatus = number
local RootExitStatus: { [string]: RootExitStatus } = {
Incomplete = 0,
FatalErrored = 1,
Errored = 2,
Suspended = 3,
SuspendedWithDelay = 4,
Completed = 5,
}
local executionContext: ExecutionContext = NoContext
local workInProgressRoot: FiberRoot? = nil
local workInProgress: Fiber? = nil
local workInProgressRootRenderLanes: Lanes = ReactFiberLane.NoLanes
exports.subtreeRenderLanes = ReactFiberLane.NoLanes
local subtreeRenderLanesCursor: StackCursor<Lanes> = createCursor(ReactFiberLane.NoLanes)
local workInProgressRootExitStatus: RootExitStatus = RootExitStatus.Incomplete
local workInProgressRootFatalError: any = nil
local workInProgressRootIncludedLanes: Lanes = ReactFiberLane.NoLanes
local ReactFiberWorkInProgress = __require(script.Parent.ReactFiberWorkInProgress)
local workInProgressRootSkippedLanes: (value: Lanes?) -> Lanes =
ReactFiberWorkInProgress.workInProgressRootSkippedLanes
local workInProgressRootUpdatedLanes: Lanes = ReactFiberLane.NoLanes
local workInProgressRootPingedLanes: Lanes = ReactFiberLane.NoLanes
local mostRecentlyUpdatedRoot: FiberRoot | nil = nil
local globalMostRecentFallbackTime: number = 0
local FALLBACK_THROTTLE_MS: number = 500
local workInProgressRootRenderTargetTime: number = math.huge
local RENDER_TIMEOUT_MS = 500
local nearestProfilerOnStack: Fiber | nil = nil
local function resetRenderTimer()
workInProgressRootRenderTargetTime = now() + RENDER_TIMEOUT_MS
end
exports.getRenderTargetTime = function(): number
return workInProgressRootRenderTargetTime
end
local hasUncaughtError = false
local firstUncaughtError = nil
local legacyErrorBoundariesThatAlreadyFailed: Set<any> | nil = nil
local rootDoesHavePassiveEffects: boolean = false
local rootWithPendingPassiveEffects: FiberRoot? = nil
local pendingPassiveEffectsRenderPriority: ReactPriorityLevel = NoSchedulerPriority
local pendingPassiveEffectsLanes: Lanes = ReactFiberLane.NoLanes
local rootsWithPendingDiscreteUpdates: Set<ReactInternalTypes.FiberRoot> | nil = nil
local NESTED_UPDATE_LIMIT = 50
local nestedUpdateCount: number = 0
local rootWithNestedUpdates: FiberRoot | nil = nil
local NESTED_PASSIVE_UPDATE_LIMIT = 50
local nestedPassiveUpdateCount: number = 0
local spawnedWorkDuringRender: nil | Array<Lane | Lanes> = nil
local currentEventTime: number = NoTimestamp
local currentEventWipLanes: Lanes = ReactFiberLane.NoLanes
local currentEventPendingLanes: Lanes = ReactFiberLane.NoLanes
local focusedInstanceHandle: nil | Fiber = nil
local shouldFireAfterActiveInstanceBlur: boolean = false
exports.getWorkInProgressRoot = function(): FiberRoot?
return workInProgressRoot
end
exports.requestEventTime = function()
if
bit32.band(executionContext, bit32.bor(RenderContext, CommitContext))
~= NoContext
then
return now()
end
if currentEventTime ~= NoTimestamp then
return currentEventTime
end
currentEventTime = now()
return currentEventTime
end
exports.requestUpdateLane = function(fiber: Fiber): Lane
local mode = fiber.mode
if bit32.band(mode, ReactTypeOfMode.BlockingMode) == ReactTypeOfMode.NoMode then
return SyncLane :: Lane
elseif bit32.band(mode, ReactTypeOfMode.ConcurrentMode) == ReactTypeOfMode.NoMode then
return if getCurrentPriorityLevel() == ImmediateSchedulerPriority
then SyncLane :: Lane
else SyncBatchedLane :: Lane
elseif
not ReactFeatureFlags.deferRenderPhaseUpdateToNextBatch
and bit32.band(executionContext, RenderContext) ~= NoContext
and workInProgressRootRenderLanes ~= ReactFiberLane.NoLanes
then
return pickArbitraryLane(workInProgressRootRenderLanes)
end
if currentEventWipLanes == ReactFiberLane.NoLanes then
currentEventWipLanes = workInProgressRootIncludedLanes
end
local isTransition = ReactFiberTransition.requestCurrentTransition()
~= ReactFiberTransition.NoTransition
if isTransition then
if currentEventPendingLanes ~= ReactFiberLane.NoLanes then
if mostRecentlyUpdatedRoot ~= nil then
currentEventPendingLanes = mostRecentlyUpdatedRoot.pendingLanes
else
currentEventPendingLanes = ReactFiberLane.NoLanes
end
end
return findTransitionLane(currentEventWipLanes, currentEventPendingLanes)
end
local schedulerPriority = getCurrentPriorityLevel()
local lane
if
bit32.band(executionContext, DiscreteEventContext) ~= NoContext
and schedulerPriority == UserBlockingSchedulerPriority
then
lane =
findUpdateLane(ReactFiberLane.InputDiscreteLanePriority, currentEventWipLanes)
else
local schedulerLanePriority = schedulerPriorityToLanePriority(schedulerPriority)
if ReactFeatureFlags.decoupleUpdatePriorityFromScheduler then
local currentUpdateLanePriority = getCurrentUpdateLanePriority()
if
schedulerLanePriority ~= currentUpdateLanePriority
and currentUpdateLanePriority ~= ReactFiberLane.NoLanePriority
then
if __DEV__ then
console.error(
"Expected current scheduler lane priority %s to match current update lane priority %s",
tostring(schedulerLanePriority),
tostring(currentUpdateLanePriority)
)
end
end
end
lane = findUpdateLane(schedulerLanePriority, currentEventWipLanes)
end
return lane
end
function requestRetryLane(fiber: Fiber): Lane
local mode = fiber.mode
if bit32.band(mode, ReactTypeOfMode.BlockingMode) == ReactTypeOfMode.NoMode then
return SyncLane :: Lane
elseif bit32.band(mode, ReactTypeOfMode.ConcurrentMode) == ReactTypeOfMode.NoMode then
return if getCurrentPriorityLevel() == ImmediateSchedulerPriority
then SyncLane :: Lane
else SyncBatchedLane :: Lane
end
if currentEventWipLanes == ReactFiberLane.NoLanes then
currentEventWipLanes = workInProgressRootIncludedLanes
end
return findRetryLane(currentEventWipLanes)
end
exports.scheduleUpdateOnFiber = function(
fiber: Fiber,
lane: Lane,
eventTime: number
): FiberRoot | nil
mod.checkForNestedUpdates()
local root = mod.markUpdateLaneFromFiberToRoot(fiber, lane)
if root == nil then
return nil
end
markRootUpdated(root, lane, eventTime)
if root == workInProgressRoot then
mod.warnAboutRenderPhaseUpdatesInDEV(fiber)
if
ReactFeatureFlags.deferRenderPhaseUpdateToNextBatch
or bit32.band(executionContext, RenderContext) == NoContext
then
workInProgressRootUpdatedLanes =
mergeLanes(workInProgressRootUpdatedLanes, lane)
end
if workInProgressRootExitStatus == RootExitStatus.SuspendedWithDelay then
mod.markRootSuspended(root, workInProgressRootRenderLanes)
end
end
local priorityLevel = getCurrentPriorityLevel()
if lane == SyncLane then
if
bit32.band(executionContext, LegacyUnbatchedContext) ~= NoContext
and bit32.band(executionContext, bit32.bor(RenderContext, CommitContext))
== NoContext
then
mod.schedulePendingInteractions(root, lane)
mod.performSyncWorkOnRoot(root)
else
ensureRootIsScheduled(root, eventTime)
mod.schedulePendingInteractions(root, lane)
if executionContext == NoContext then
resetRenderTimer()
flushSyncCallbackQueue()
end
end
else
if
bit32.band(executionContext, DiscreteEventContext) ~= NoContext
and (
priorityLevel == UserBlockingSchedulerPriority
or priorityLevel == ImmediateSchedulerPriority
)
then
if rootsWithPendingDiscreteUpdates == nil then
rootsWithPendingDiscreteUpdates = Set.new({ root })
else
rootsWithPendingDiscreteUpdates:add(root)
end
end
ensureRootIsScheduled(root, eventTime)
mod.schedulePendingInteractions(root, lane)
end
mostRecentlyUpdatedRoot = root
return root
end
mod.markUpdateLaneFromFiberToRoot = function(sourceFiber: Fiber, lane: Lane): FiberRoot?
sourceFiber.lanes = mergeLanes(sourceFiber.lanes, lane)
local alternate = sourceFiber.alternate
if alternate ~= nil then
alternate.lanes = mergeLanes(alternate.lanes, lane)
end
if __DEV__ then
if
alternate == nil
and bit32.band(
sourceFiber.flags,
bit32.bor(ReactFiberFlags.Placement, ReactFiberFlags.Hydrating)
)
~= ReactFiberFlags.NoFlags
then
mod.warnAboutUpdateOnNotYetMountedFiberInDEV(sourceFiber)
end
end
local node = sourceFiber
local parent = sourceFiber.return_
while parent ~= nil do
parent.childLanes = mergeLanes(parent.childLanes, lane)
alternate = parent.alternate
if alternate ~= nil then
alternate.childLanes = mergeLanes(alternate.childLanes, lane)
else
if __DEV__ then
if
bit32.band(
parent.flags,
bit32.bor(ReactFiberFlags.Placement, ReactFiberFlags.Hydrating)
) ~= ReactFiberFlags.NoFlags
then
mod.warnAboutUpdateOnNotYetMountedFiberInDEV(sourceFiber)
end
end
end
node = parent
parent = parent.return_
end
if node.tag == ReactWorkTags.HostRoot then
local root: FiberRoot = node.stateNode
return root
else
return nil
end
end
ensureRootIsScheduled = function(root: FiberRoot, currentTime: number)
local existingCallbackNode = root.callbackNode
markStarvedLanesAsExpired(root, currentTime)
local lanes
if root == workInProgressRoot then
lanes = workInProgressRootRenderLanes
else
lanes = ReactFiberLane.NoLanes
end
local nextLanes = getNextLanes(root, lanes)
local newCallbackPriority = returnNextLanesPriority()
if nextLanes == ReactFiberLane.NoLanes then
if existingCallbackNode ~= nil then
cancelCallback(existingCallbackNode)
root.callbackNode = nil
root.callbackPriority = ReactFiberLane.NoLanePriority
end
return
end
if existingCallbackNode ~= nil then
local existingCallbackPriority = root.callbackPriority
if existingCallbackPriority == newCallbackPriority then
return
end
cancelCallback(existingCallbackNode)
end
local newCallbackNode
if newCallbackPriority == ReactFiberLane.SyncLanePriority then
newCallbackNode = scheduleSyncCallback(function()
local profileRunning = RobloxReactProfiling.profileRootBeforeUnitOfWork(root)
local ret = mod.performSyncWorkOnRoot(root)
RobloxReactProfiling.profileRootAfterYielding(profileRunning)
return ret
end)
elseif newCallbackPriority == ReactFiberLane.SyncBatchedLanePriority then
newCallbackNode = scheduleCallback(ImmediateSchedulerPriority, function()
local profileRunning = RobloxReactProfiling.profileRootBeforeUnitOfWork(root)
local ret = mod.performSyncWorkOnRoot(root)
RobloxReactProfiling.profileRootAfterYielding(profileRunning)
return ret
end)
else
local schedulerPriorityLevel =
lanePriorityToSchedulerPriority(newCallbackPriority)
newCallbackNode = scheduleCallback(schedulerPriorityLevel, function()
local profileRunning = RobloxReactProfiling.profileRootBeforeUnitOfWork(root)
local ret = mod.performConcurrentWorkOnRoot(root)
RobloxReactProfiling.profileRootAfterYielding(profileRunning)
return ret
end)
end
root.callbackPriority = newCallbackPriority
root.callbackNode = newCallbackNode
end
mod.performConcurrentWorkOnRoot = function(root): (() -> ...any) | nil
currentEventTime = NoTimestamp
currentEventWipLanes = ReactFiberLane.NoLanes
currentEventPendingLanes = ReactFiberLane.NoLanes
invariant(
bit32.band(executionContext, bit32.bor(RenderContext, CommitContext)) == NoContext,
"Should not already be working."
)
local originalCallbackNode = root.callbackNode
local didFlushPassiveEffects = exports.flushPassiveEffects()
if didFlushPassiveEffects then
if root.callbackNode ~= originalCallbackNode then
return nil
else
end
end
local lanes = getNextLanes(
root,
if root == workInProgressRoot
then workInProgressRootRenderLanes
else ReactFiberLane.NoLanes
)
if lanes == ReactFiberLane.NoLanes then
return nil
end
local exitStatus = mod.renderRootConcurrent(root, lanes)
if
includesSomeLane(workInProgressRootIncludedLanes, workInProgressRootUpdatedLanes)
then
mod.prepareFreshStack(root, ReactFiberLane.NoLanes)
elseif exitStatus ~= RootExitStatus.Incomplete then
if exitStatus == RootExitStatus.Errored then
executionContext = bit32.bor(executionContext, RetryAfterError)
if root.hydrate then
root.hydrate = false
ReactFiberHostConfig.clearContainer(root.containerInfo)
end
lanes = getLanesToRetrySynchronouslyOnError(root)
if lanes ~= ReactFiberLane.NoLanes then
exitStatus = mod.renderRootSync(root, lanes)
end
end
if exitStatus == RootExitStatus.FatalErrored then
local fatalError = workInProgressRootFatalError
mod.prepareFreshStack(root, ReactFiberLane.NoLanes)
mod.markRootSuspended(root, lanes)
ensureRootIsScheduled(root, now())
error(fatalError)
end
local finishedWork: Fiber = root.current.alternate :: any
root.finishedWork = finishedWork
root.finishedLanes = lanes
mod.finishConcurrentRender(root, exitStatus, lanes)
end
ensureRootIsScheduled(root, now())
if root.callbackNode == originalCallbackNode then
return function()
local profileRunning = RobloxReactProfiling.profileRootBeforeUnitOfWork(root)
local ret = mod.performConcurrentWorkOnRoot(root)
RobloxReactProfiling.profileRootAfterYielding(profileRunning)
return ret
end
end
return nil :: any
end
local actingUpdatesScopeDepth = 0
local didWarnAboutUsingActInProd = false
function shouldForceFlushFallbacksInDEV()
return __DEV__ and actingUpdatesScopeDepth > 0
end
mod.finishConcurrentRender = function(root, exitStatus, lanes)
if
exitStatus == RootExitStatus.Incomplete
or exitStatus == RootExitStatus.FatalErrored
then
invariant(false, "Root did not complete. This is a bug in React.")
elseif exitStatus == RootExitStatus.Errored then
mod.commitRoot(root)
elseif exitStatus == RootExitStatus.Suspended then
mod.markRootSuspended(root, lanes)
if
includesOnlyRetries(lanes)
and not shouldForceFlushFallbacksInDEV()
then
local msUntilTimeout = globalMostRecentFallbackTime
+ FALLBACK_THROTTLE_MS
- now()
if msUntilTimeout > 10 then
local nextLanes = getNextLanes(root, ReactFiberLane.NoLanes)
if nextLanes ~= ReactFiberLane.NoLanes then
return
end
local suspendedLanes = root.suspendedLanes
if not isSubsetOfLanes(suspendedLanes, lanes) then
local eventTime = exports.requestEventTime()
markRootPinged(root, suspendedLanes, eventTime)
return
end
root.timeoutHandle = ReactFiberHostConfig.scheduleTimeout(function()
return mod.commitRoot(root)
end, msUntilTimeout)
return
end
end
mod.commitRoot(root)
elseif exitStatus == RootExitStatus.SuspendedWithDelay then
mod.markRootSuspended(root, lanes)
if includesOnlyTransitions(lanes) then
return
end
if not shouldForceFlushFallbacksInDEV() then
local mostRecentEventTime = ReactFiberLane.getMostRecentEventTime(root, lanes)
local eventTimeMs = mostRecentEventTime
local timeElapsedMs = now() - eventTimeMs
local msUntilTimeout = jnd(timeElapsedMs) - timeElapsedMs
if msUntilTimeout > 10 then
root.timeoutHandle = ReactFiberHostConfig.scheduleTimeout(function()
return mod.commitRoot(root)
end, msUntilTimeout)
return
end
end
mod.commitRoot(root)
elseif exitStatus == RootExitStatus.Completed then
mod.commitRoot(root)
else
invariant(false, "Unknown root exit status.")
end
end
mod.markRootSuspended = function(root, suspendedLanes)
suspendedLanes = removeLanes(suspendedLanes, workInProgressRootPingedLanes)
suspendedLanes = removeLanes(suspendedLanes, workInProgressRootUpdatedLanes)
ReactFiberLane.markRootSuspended(root, suspendedLanes)
end
mod.performSyncWorkOnRoot = function(root)
invariant(
bit32.band(executionContext, bit32.bor(RenderContext, CommitContext)) == NoContext,
"Should not already be working."
)
exports.flushPassiveEffects()
local lanes
local exitStatus
if
root == workInProgressRoot
and includesSomeLane(root.expiredLanes, workInProgressRootRenderLanes)
then
lanes = workInProgressRootRenderLanes
exitStatus = mod.renderRootSync(root, lanes)
if
includesSomeLane(
workInProgressRootIncludedLanes,
workInProgressRootUpdatedLanes
)
then
lanes = getNextLanes(root, lanes)
exitStatus = mod.renderRootSync(root, lanes)
end
else
lanes = getNextLanes(root, ReactFiberLane.NoLanes)
exitStatus = mod.renderRootSync(root, lanes)
end
if root.tag ~= LegacyRoot and exitStatus == RootExitStatus.Errored then
executionContext = bit32.bor(executionContext, RetryAfterError)
if root.hydrate then
root.hydrate = false
ReactFiberHostConfig.clearContainer(root.containerInfo)
end
lanes = getLanesToRetrySynchronouslyOnError(root)
if lanes ~= ReactFiberLane.NoLanes then
exitStatus = mod.renderRootSync(root, lanes)
end
end
if exitStatus == RootExitStatus.FatalErrored then
local fatalError = workInProgressRootFatalError
mod.prepareFreshStack(root, ReactFiberLane.NoLanes)
mod.markRootSuspended(root, lanes)
ensureRootIsScheduled(root, now())
error(fatalError)
end
local finishedWork: Fiber = root.current.alternate :: any
root.finishedWork = finishedWork
root.finishedLanes = lanes
mod.commitRoot(root)
ensureRootIsScheduled(root, now())
return nil
end
exports.flushRoot = function(root: FiberRoot, lanes: Lanes)
markRootExpired(root, lanes)
ensureRootIsScheduled(root, now())
if
bit32.band(executionContext, bit32.bor(RenderContext, CommitContext))
== NoContext
then
resetRenderTimer()
flushSyncCallbackQueue()
end
end
exports.getExecutionContext = function(): ExecutionContext
return executionContext
end
exports.flushDiscreteUpdates = function()
if
bit32.band(
executionContext,
bit32.bor(BatchedContext, RenderContext, CommitContext)
) ~= NoContext
then
if __DEV__ then
if bit32.band(executionContext, RenderContext) ~= NoContext then
console.error(
"unstable_flushDiscreteUpdates: Cannot flush updates when React is "
.. "already rendering."
)
end
end
return
end
mod.flushPendingDiscreteUpdates()
exports.flushPassiveEffects()
end
exports.deferredUpdates = function<A>(fn: () -> A): A
if ReactFeatureFlags.decoupleUpdatePriorityFromScheduler then
local previousLanePriority = getCurrentUpdateLanePriority()
local ok, result
if not __YOLO__ then
setCurrentUpdateLanePriority(ReactFiberLane.DefaultLanePriority)
ok, result =
xpcall(runWithPriority, describeError, NormalSchedulerPriority, fn)
else
ok = true
setCurrentUpdateLanePriority(ReactFiberLane.DefaultLanePriority)
result = runWithPriority(NormalSchedulerPriority, fn)
end
setCurrentUpdateLanePriority(previousLanePriority)
if ok then
return result
else
error(result)
end
else
return runWithPriority(NormalSchedulerPriority, fn)
end
end
mod.flushPendingDiscreteUpdates = function()
if rootsWithPendingDiscreteUpdates ~= nil then
local roots = rootsWithPendingDiscreteUpdates
rootsWithPendingDiscreteUpdates = nil
roots:forEach(function(root)
markDiscreteUpdatesExpired(root)
ensureRootIsScheduled(root, now())
end)
end
flushSyncCallbackQueue()
end
exports.batchedUpdates = function<A, R>(fn: (A) -> R, a: A): R
local prevExecutionContext = executionContext
executionContext = bit32.bor(executionContext, BatchedContext)
local ok, result
if not __YOLO__ then
ok, result = xpcall(fn, describeError, a)
else
ok = true
result = fn(a)
end
executionContext = prevExecutionContext
if executionContext == NoContext then
resetRenderTimer()
flushSyncCallbackQueue()
end
if ok then
return result
else
error(result)
end
end
exports.batchedEventUpdates = function<A, R>(fn: (A) -> R, a: A): R
local prevExecutionContext = executionContext
executionContext = bit32.bor(executionContext, EventContext)
local ok, result
if not __YOLO__ then
ok, result = xpcall(fn, describeError, a)
else
ok = true
result = fn(a)
end
executionContext = prevExecutionContext
if executionContext == NoContext then
resetRenderTimer()
flushSyncCallbackQueue()
end
if ok then
return result
else
error(result)
end
end
exports.discreteUpdates = function<A, B, C, D, R>(fn: (A, B, C, D) -> R, a: A, b: B, c: C, d: D): R
local prevExecutionContext = executionContext
executionContext = bit32.bor(executionContext, DiscreteEventContext)
if ReactFeatureFlags.decoupleUpdatePriorityFromScheduler then
local previousLanePriority = getCurrentUpdateLanePriority()
setCurrentUpdateLanePriority(ReactFiberLane.InputDiscreteLanePriority)
local ok, result = xpcall(
runWithPriority,
describeError,
UserBlockingSchedulerPriority,
function()
return fn(a, b, c, d)
end
)
setCurrentUpdateLanePriority(previousLanePriority)
executionContext = prevExecutionContext
if executionContext == NoContext then
resetRenderTimer()
flushSyncCallbackQueue()
end
if ok then
return result
else
error(result)
end
else
local ok, result = xpcall(
runWithPriority,
describeError,
UserBlockingSchedulerPriority,
function()
return fn(a, b, c, d)
end
)
executionContext = prevExecutionContext
if executionContext == NoContext then
resetRenderTimer()
flushSyncCallbackQueue()
end
if ok then
return result
else
error(result)
end
end
end
exports.unbatchedUpdates = function<A, R>(fn: (A) -> R, a: A): R
local prevExecutionContext = executionContext
executionContext = bit32.band(executionContext, bit32.bnot(BatchedContext))
executionContext = bit32.bor(executionContext, LegacyUnbatchedContext)
local ok, result
if not __YOLO__ then
ok, result = xpcall(fn, describeError, a)
else
ok = true
result = fn(a)
end
executionContext = prevExecutionContext
if executionContext == NoContext then
resetRenderTimer()
flushSyncCallbackQueue()
end
if ok then
return result
else
error(result)
end
end
exports.flushSync = function<A, R>(fn: (A) -> R, a: A): R
local prevExecutionContext = executionContext
if
(bit32.band(prevExecutionContext, bit32.bor(RenderContext, CommitContext)))
~= NoContext
then
if __DEV__ then
console.error(
"flushSync was called from inside a lifecycle method. React cannot "
.. "flush when React is already rendering. Consider moving this call to "
.. "a scheduler task or micro task."
)
end
return fn(a)
end
executionContext = bit32.bor(executionContext, BatchedContext)
if ReactFeatureFlags.decoupleUpdatePriorityFromScheduler then
local previousLanePriority = getCurrentUpdateLanePriority()
setCurrentUpdateLanePriority(ReactFiberLane.SyncLanePriority)
local ok, result
if not __YOLO__ then
if fn then
ok, result = xpcall(
runWithPriority,
describeError,
ImmediateSchedulerPriority,
function()
return fn(a)
end
)
else
ok = true
result = nil :: any
end
else
ok = true
setCurrentUpdateLanePriority(ReactFiberLane.SyncLanePriority)
if fn then
result = runWithPriority(ImmediateSchedulerPriority, function()
return fn(a)
end)
else
result = nil :: any
end
end
setCurrentUpdateLanePriority(previousLanePriority)
executionContext = prevExecutionContext
flushSyncCallbackQueue()
if not ok then
error(result)
end
return result
else
local ok, result
if not __YOLO__ then
if fn then
ok, result = xpcall(
runWithPriority,
describeError,
ImmediateSchedulerPriority,
function()
return fn(a)
end
)
else
ok = true
result = nil :: any
end
else
ok = true
if fn then
result = runWithPriority(ImmediateSchedulerPriority, function()
return fn(a)
end)
else
result = nil :: any
end
end
executionContext = prevExecutionContext
flushSyncCallbackQueue()
if not ok then
error(result)
end
return result
end
end
exports.flushControlled = function(fn: () -> any)
local prevExecutionContext = executionContext
executionContext = bit32.bor(executionContext, BatchedContext)
if ReactFeatureFlags.decoupleUpdatePriorityFromScheduler then
local previousLanePriority = getCurrentUpdateLanePriority()
setCurrentUpdateLanePriority(ReactFiberLane.SyncLanePriority)
local ok, result =
xpcall(runWithPriority, describeError, ImmediateSchedulerPriority, fn)
setCurrentUpdateLanePriority(previousLanePriority)
executionContext = prevExecutionContext
if executionContext == NoContext then
resetRenderTimer()
flushSyncCallbackQueue()
end
if not ok then
error(result)
end
else
local ok, result =
xpcall(runWithPriority, describeError, ImmediateSchedulerPriority, fn)
executionContext = prevExecutionContext
if executionContext == NoContext then
resetRenderTimer()
flushSyncCallbackQueue()
end
if not ok then
error(result)
end
end
end
exports.pushRenderLanes = function(fiber: Fiber, lanes: Lanes)
pushToStack(subtreeRenderLanesCursor, exports.subtreeRenderLanes, fiber)
exports.subtreeRenderLanes = mergeLanes(exports.subtreeRenderLanes, lanes)
workInProgressRootIncludedLanes = mergeLanes(workInProgressRootIncludedLanes, lanes)
end
exports.popRenderLanes = function(fiber: Fiber)
exports.subtreeRenderLanes = subtreeRenderLanesCursor.current
popFromStack(subtreeRenderLanesCursor, fiber)
end
mod.prepareFreshStack = function(root: FiberRoot, lanes: Lanes)
root.finishedWork = nil
root.finishedLanes = ReactFiberLane.NoLanes
local timeoutHandle = root.timeoutHandle
if timeoutHandle ~= ReactFiberHostConfig.noTimeout then
root.timeoutHandle = ReactFiberHostConfig.noTimeout
ReactFiberHostConfig.cancelTimeout(timeoutHandle)
end
if workInProgress ~= nil then
local interruptedWork = workInProgress.return_
while interruptedWork ~= nil do
unwindInterruptedWork(interruptedWork)
interruptedWork = interruptedWork.return_
end
end
workInProgressRoot = root
workInProgress = ReactFiber.createWorkInProgress(root.current, nil)
workInProgressRootRenderLanes = lanes
exports.subtreeRenderLanes = lanes
workInProgressRootIncludedLanes = lanes
workInProgressRootExitStatus = RootExitStatus.Incomplete
workInProgressRootFatalError = nil
workInProgressRootSkippedLanes(ReactFiberLane.NoLanes)
workInProgressRootUpdatedLanes = ReactFiberLane.NoLanes
workInProgressRootPingedLanes = ReactFiberLane.NoLanes
if ReactFeatureFlags.enableSchedulerTracing then
spawnedWorkDuringRender = nil
end
if __DEV__ then
ReactStrictModeWarnings.discardPendingWarnings()
end
end
mod.handleError = function(root, thrownValue): ()
while true do
local erroredWork = workInProgress
local ok, yetAnotherThrownValue = pcall(function()
resetContextDependencies()
resetHooksAfterThrow()
resetCurrentDebugFiberInDEV()
ReactCurrentOwner.current = nil
if erroredWork == nil or erroredWork.return_ == nil then
workInProgressRootExitStatus = RootExitStatus.FatalErrored
workInProgressRootFatalError = thrownValue
workInProgress = nil
return
end
if
ReactFeatureFlags.enableProfilerTimer
and bit32.band(
(erroredWork :: Fiber).mode,
ReactTypeOfMode.ProfileMode
)
~= 0
then
ReactProfilerTimer.stopProfilerTimerIfRunningAndRecordDelta(
erroredWork :: Fiber,
true
)
end
throwException(
root,
(erroredWork :: Fiber).return_,
erroredWork :: Fiber,
thrownValue,
workInProgressRootRenderLanes,
exports.onUncaughtError,
exports.renderDidError
)
mod.completeUnitOfWork(erroredWork)
end)
if not ok then
thrownValue = yetAnotherThrownValue
if workInProgress == erroredWork and erroredWork ~= nil then
erroredWork = erroredWork.return_
workInProgress = erroredWork
else
erroredWork = workInProgress
end
continue
end
return
end
end
mod.pushDispatcher = function()
local prevDispatcher = ReactCurrentDispatcher.current
ReactCurrentDispatcher.current = ContextOnlyDispatcher()
if prevDispatcher == nil then
return ContextOnlyDispatcher()
else
return prevDispatcher
end
end
mod.popDispatcher = function(prevDispatcher)
ReactCurrentDispatcher.current = prevDispatcher
end
mod.pushInteractions = function(root)
if ReactFeatureFlags.enableSchedulerTracing then
local prevInteractions: Set<Interaction>? = __interactionsRef.current
__interactionsRef.current = root.memoizedInteractions
return prevInteractions
end
return nil
end
mod.popInteractions = function(prevInteractions)
if ReactFeatureFlags.enableSchedulerTracing then
__interactionsRef.current = prevInteractions
end
end
exports.markCommitTimeOfFallback = function(): ()
globalMostRecentFallbackTime = now()
end
exports.markSkippedUpdateLanes = function(lane: Lane | Lanes): ()
ReactFiberWorkInProgress.markSkippedUpdateLanes(lane)
end
exports.renderDidSuspend = function(): ()
if workInProgressRootExitStatus == RootExitStatus.Incomplete then
workInProgressRootExitStatus = RootExitStatus.Suspended
end
end
exports.renderDidSuspendDelayIfPossible = function(): ()
if
workInProgressRootExitStatus == RootExitStatus.Incomplete
or workInProgressRootExitStatus == RootExitStatus.Suspended
then
workInProgressRootExitStatus = RootExitStatus.SuspendedWithDelay
end
if
workInProgressRoot ~= nil
and (
includesNonIdleWork(workInProgressRootSkippedLanes())
or includesNonIdleWork(workInProgressRootUpdatedLanes)
)
then
mod.markRootSuspended(workInProgressRoot, workInProgressRootRenderLanes)
end
end
exports.renderDidError = function()
if workInProgressRootExitStatus ~= RootExitStatus.Completed then
workInProgressRootExitStatus = RootExitStatus.Errored
end
end
exports.renderHasNotSuspendedYet = function(): boolean
return workInProgressRootExitStatus == RootExitStatus.Incomplete
end
mod.renderRootSync = function(root: FiberRoot, lanes: Lanes)
local prevExecutionContext = executionContext
executionContext = bit32.bor(executionContext, RenderContext)
local prevDispatcher = mod.pushDispatcher()
if workInProgressRoot ~= root or workInProgressRootRenderLanes ~= lanes then
mod.prepareFreshStack(root, lanes)
mod.startWorkOnPendingInteractions(root, lanes)
end
local prevInteractions = mod.pushInteractions(root)
if __DEV__ then
if enableDebugTracing then
DebugTracing.logRenderStarted(lanes)
end
end
if enableSchedulingProfiler then
SchedulingProfiler.markRenderStarted(lanes)
end
while true do
local ok, thrownValue
if not __YOLO__ then
ok, thrownValue = xpcall(mod.workLoopSync, describeError)
else
ok = true
mod.workLoopSync()
end
if not ok then
mod.handleError(root, thrownValue)
else
break
end
end
resetContextDependencies()
if ReactFeatureFlags.enableSchedulerTracing then
mod.popInteractions(prevInteractions)
end
executionContext = prevExecutionContext
mod.popDispatcher(prevDispatcher)
if workInProgress ~= nil then
invariant(
false,
"Cannot commit an incomplete root. This error is likely caused by a "
.. "bug in React. Please file an issue."
)
end
if __DEV__ then
if enableDebugTracing then
DebugTracing.logRenderStopped()
end
end
if enableSchedulingProfiler then
SchedulingProfiler.markRenderStopped()
end
workInProgressRoot = nil
workInProgressRootRenderLanes = ReactFiberLane.NoLanes
return workInProgressRootExitStatus
end
mod.workLoopSync = function()
while workInProgress ~= nil do
mod.performUnitOfWork(workInProgress)
end
end
mod.renderRootConcurrent = function(root: FiberRoot, lanes: Lanes)
local prevExecutionContext = executionContext
executionContext = bit32.bor(executionContext, RenderContext)
local prevDispatcher = mod.pushDispatcher()
if workInProgressRoot ~= root or workInProgressRootRenderLanes ~= lanes then
resetRenderTimer()
mod.prepareFreshStack(root, lanes)
mod.startWorkOnPendingInteractions(root, lanes)
end
local prevInteractions = mod.pushInteractions(root)
if __DEV__ then
if enableDebugTracing then
DebugTracing.logRenderStarted(lanes)
end
end
if enableSchedulingProfiler then
SchedulingProfiler.markRenderStarted(lanes)
end
while true do
local ok, thrownValue
if not __YOLO__ then
ok, thrownValue = xpcall(mod.workLoopConcurrent, describeError)
if ok then
thrownValue = "break"
end
else
ok = true
thrownValue = "break"
mod.workLoopConcurrent()
end
if thrownValue == "break" then
break
end
if not ok then
mod.handleError(root, thrownValue)
end
end
resetContextDependencies()
if ReactFeatureFlags.enableSchedulerTracing then
mod.popInteractions(prevInteractions)
end
mod.popDispatcher(prevDispatcher)
executionContext = prevExecutionContext
if __DEV__ then
if enableDebugTracing then
DebugTracing.logRenderStopped()
end
end
if workInProgress ~= nil then
if enableSchedulingProfiler then
SchedulingProfiler.markRenderYielded()
end
return RootExitStatus.Incomplete
else
if enableSchedulingProfiler then
SchedulingProfiler.markRenderStopped()
end
workInProgressRoot = nil
workInProgressRootRenderLanes = ReactFiberLane.NoLanes
return workInProgressRootExitStatus
end
end
mod.workLoopConcurrent = function()
while workInProgress ~= nil and not shouldYield() do
mod.performUnitOfWork(workInProgress)
end
end
mod.performUnitOfWork = function(unitOfWork: Fiber): ()
local profileRunning = RobloxReactProfiling.profileUnitOfWorkBefore(unitOfWork)
local current = unitOfWork.alternate
setCurrentDebugFiberInDEV(unitOfWork)
local next_
if
ReactFeatureFlags.enableProfilerTimer
and bit32.band(unitOfWork.mode, ReactTypeOfMode.ProfileMode)
~= ReactTypeOfMode.NoMode
then
ReactProfilerTimer.startProfilerTimer(unitOfWork)
next_ = mod.beginWork(current, unitOfWork, exports.subtreeRenderLanes)
ReactProfilerTimer.stopProfilerTimerIfRunningAndRecordDelta(unitOfWork, true)
else
next_ = mod.beginWork(current, unitOfWork, exports.subtreeRenderLanes)
end
resetCurrentDebugFiberInDEV()
unitOfWork.memoizedProps = unitOfWork.pendingProps
if next_ == nil then
mod.completeUnitOfWork(unitOfWork)
else
workInProgress = next_
end
ReactCurrentOwner.current = nil
RobloxReactProfiling.profileUnitOfWorkAfter(profileRunning)
end
mod.completeUnitOfWork = function(unitOfWork: Fiber)
local completedWork = unitOfWork
repeat
local current = completedWork.alternate
local returnFiber = completedWork.return_
if
bit32.band(completedWork.flags, ReactFiberFlags.Incomplete)
== ReactFiberFlags.NoFlags
then
setCurrentDebugFiberInDEV(completedWork)
local next_
if
not ReactFeatureFlags.enableProfilerTimer
or bit32.band(completedWork.mode, ReactTypeOfMode.ProfileMode)
== ReactTypeOfMode.NoMode
then
next_ = completeWork(current, completedWork, exports.subtreeRenderLanes)
else
ReactProfilerTimer.startProfilerTimer(completedWork)
next_ = completeWork(current, completedWork, exports.subtreeRenderLanes)
ReactProfilerTimer.stopProfilerTimerIfRunningAndRecordDelta(
completedWork,
false
)
end
resetCurrentDebugFiberInDEV()
if next_ ~= nil then
workInProgress = next_
return
end
else
local next_ = unwindWork(completedWork, exports.subtreeRenderLanes)
if next_ ~= nil then
next_.flags = bit32.band(next_.flags, ReactFiberFlags.HostEffectMask)
workInProgress = next_
return
end
if
ReactFeatureFlags.enableProfilerTimer
and bit32.band(completedWork.mode, ReactTypeOfMode.ProfileMode)
~= ReactTypeOfMode.NoMode
then
ReactProfilerTimer.stopProfilerTimerIfRunningAndRecordDelta(
completedWork,
false
)
local actualDuration = completedWork.actualDuration or 0
local child = completedWork.child
while child ~= nil do
actualDuration += child.actualDuration or 0
child = child.sibling
end
completedWork.actualDuration = actualDuration
end
if returnFiber ~= nil then
returnFiber.flags =
bit32.bor(returnFiber.flags, ReactFiberFlags.Incomplete)
returnFiber.subtreeFlags = ReactFiberFlags.NoFlags
returnFiber.deletions = nil
end
end
local siblingFiber = completedWork.sibling
if siblingFiber ~= nil then
workInProgress = siblingFiber
return
end
completedWork = returnFiber :: any
workInProgress = completedWork
until completedWork == nil
if workInProgressRootExitStatus == RootExitStatus.Incomplete then
workInProgressRootExitStatus = RootExitStatus.Completed
end
end
mod.commitRoot = function(root)
local renderPriorityLevel = getCurrentPriorityLevel()
runWithPriority(ImmediateSchedulerPriority, function()
RobloxReactProfiling.profileCommitBefore()
local ret = mod.commitRootImpl(root, renderPriorityLevel)
RobloxReactProfiling.profileCommitAfter()
return ret
end)
return nil
end
mod.commitRootImpl = function(root: FiberRoot, renderPriorityLevel)
repeat
exports.flushPassiveEffects()
until rootWithPendingPassiveEffects == nil
flushRenderPhaseStrictModeWarningsInDEV()
invariant(
bit32.band(executionContext, bit32.bor(RenderContext, CommitContext)) == NoContext,
"Should not already be working."
)
local finishedWork = root.finishedWork :: Fiber
local lanes = root.finishedLanes
if __DEV__ then
if enableDebugTracing then
DebugTracing.logCommitStarted(lanes)
end
end
if enableSchedulingProfiler then
SchedulingProfiler.markCommitStarted(lanes)
end
if finishedWork == nil then
if __DEV__ then
if enableDebugTracing then
DebugTracing.logCommitStopped()
end
end
if enableSchedulingProfiler then
SchedulingProfiler.markCommitStopped(root)
end
return nil
end
root.finishedWork = nil
root.finishedLanes = ReactFiberLane.NoLanes
invariant(
finishedWork ~= root.current,
"Cannot commit the same tree as before. This error is likely caused by "
.. "a bug in React. Please file an issue."
)
root.callbackNode = nil
local remainingLanes = mergeLanes(finishedWork.lanes, finishedWork.childLanes)
markRootFinished(root, remainingLanes)
if rootsWithPendingDiscreteUpdates ~= nil then
if
not hasDiscreteLanes(remainingLanes)
and rootsWithPendingDiscreteUpdates:has(root)
then
rootsWithPendingDiscreteUpdates:delete(root)
end
end
if root == workInProgressRoot then
workInProgressRoot = nil
workInProgress = nil
workInProgressRootRenderLanes = ReactFiberLane.NoLanes
else
end
local subtreeHasEffects = bit32.band(
finishedWork.subtreeFlags,
bit32.bor(
ReactFiberFlags.BeforeMutationMask,
ReactFiberFlags.MutationMask,
ReactFiberFlags.LayoutMask,
ReactFiberFlags.PassiveMask
)
) ~= ReactFiberFlags.NoFlags
local rootHasEffect = bit32.band(
finishedWork.flags,
bit32.bor(
ReactFiberFlags.BeforeMutationMask,
ReactFiberFlags.MutationMask,
ReactFiberFlags.LayoutMask,
ReactFiberFlags.PassiveMask
)
) ~= ReactFiberFlags.NoFlags
if subtreeHasEffects or rootHasEffect then
local previousLanePriority
if ReactFeatureFlags.decoupleUpdatePriorityFromScheduler then
previousLanePriority = getCurrentUpdateLanePriority()
setCurrentUpdateLanePriority(ReactFiberLane.SyncLanePriority)
end
local prevExecutionContext = executionContext
executionContext = bit32.bor(executionContext, CommitContext)
local prevInteractions = mod.pushInteractions(root)
ReactCurrentOwner.current = nil
focusedInstanceHandle = ReactFiberHostConfig.prepareForCommit(root.containerInfo)
shouldFireAfterActiveInstanceBlur = false
mod.commitBeforeMutationEffects(finishedWork)
focusedInstanceHandle = nil
if ReactFeatureFlags.enableProfilerTimer then
ReactProfilerTimer.recordCommitTime()
end
mod.commitMutationEffects(finishedWork, root, renderPriorityLevel)
if shouldFireAfterActiveInstanceBlur then
ReactFiberHostConfig.afterActiveInstanceBlur()
end
ReactFiberHostConfig.resetAfterCommit(root.containerInfo)
root.current = finishedWork
if __DEV__ then
if enableDebugTracing then
DebugTracing.logLayoutEffectsStarted(lanes)
end
end
if enableSchedulingProfiler then
SchedulingProfiler.markLayoutEffectsStarted(lanes)
end
if __DEV__ then
setCurrentDebugFiberInDEV(finishedWork)
invokeGuardedCallback(
nil,
recursivelyCommitLayoutEffects,
nil,
finishedWork,
root,
exports.captureCommitPhaseError,
exports.schedulePassiveEffectCallback
)
if hasCaughtError() then
local err = clearCaughtError()
captureCommitPhaseErrorOnRoot(finishedWork, finishedWork, err)
end
resetCurrentDebugFiberInDEV()
else
local ok, result
if not __YOLO__ then
ok, result = xpcall(
recursivelyCommitLayoutEffects,
describeError,
finishedWork,
root,
exports.captureCommitPhaseError,
exports.schedulePassiveEffectCallback
)
else
ok = true
recursivelyCommitLayoutEffects(
finishedWork,
root,
exports.captureCommitPhaseError,
exports.schedulePassiveEffectCallback
)
end
if not ok then
captureCommitPhaseErrorOnRoot(finishedWork, finishedWork, result)
end
end
if __DEV__ then
if enableDebugTracing then
DebugTracing.logLayoutEffectsStopped()
end
end
if enableSchedulingProfiler then
SchedulingProfiler.markLayoutEffectsStopped()
end
if
bit32.band(finishedWork.subtreeFlags, ReactFiberFlags.PassiveMask)
~= ReactFiberFlags.NoFlags
or bit32.band(finishedWork.flags, ReactFiberFlags.PassiveMask)
~= ReactFiberFlags.NoFlags
then
if not rootDoesHavePassiveEffects then
rootDoesHavePassiveEffects = true
scheduleCallback(NormalSchedulerPriority, function()
exports.flushPassiveEffects()
return nil
end)
end
end
requestPaint()
if ReactFeatureFlags.enableSchedulerTracing then
mod.popInteractions(prevInteractions)
end
executionContext = prevExecutionContext
if
ReactFeatureFlags.decoupleUpdatePriorityFromScheduler
and previousLanePriority ~= nil
then
setCurrentUpdateLanePriority(previousLanePriority)
end
else
root.current = finishedWork
if ReactFeatureFlags.enableProfilerTimer then
ReactProfilerTimer.recordCommitTime()
end
end
local rootDidHavePassiveEffects = rootDoesHavePassiveEffects
if rootDoesHavePassiveEffects then
rootDoesHavePassiveEffects = false
rootWithPendingPassiveEffects = root
pendingPassiveEffectsLanes = lanes
pendingPassiveEffectsRenderPriority = renderPriorityLevel
end
remainingLanes = root.pendingLanes
if remainingLanes ~= ReactFiberLane.NoLanes then
if ReactFeatureFlags.enableSchedulerTracing then
if spawnedWorkDuringRender ~= nil then
local expirationTimes = spawnedWorkDuringRender
spawnedWorkDuringRender = nil
for i = 1, #expirationTimes do
scheduleInteractions(
root,
expirationTimes[i],
root.memoizedInteractions
)
end
end
mod.schedulePendingInteractions(root, remainingLanes)
end
else
legacyErrorBoundariesThatAlreadyFailed = nil
end
if __DEV__ and enableDoubleInvokingEffects then
if not rootDidHavePassiveEffects then
commitDoubleInvokeEffectsInDEV(root.current, false)
end
end
if ReactFeatureFlags.enableSchedulerTracing then
if not rootDidHavePassiveEffects then
mod.finishPendingInteractions(root, lanes)
end
end
if remainingLanes == SyncLane then
if root == rootWithNestedUpdates then
nestedUpdateCount += 1
else
nestedUpdateCount = 0
rootWithNestedUpdates = root
end
else
nestedUpdateCount = 0
end
onCommitRootDevTools(finishedWork.stateNode, renderPriorityLevel)
if __DEV__ then
onCommitRootTestSelector()
end
ensureRootIsScheduled(root, now())
if hasUncaughtError then
hasUncaughtError = false
local error_ = firstUncaughtError
firstUncaughtError = nil
error(error_)
end
if bit32.band(executionContext, LegacyUnbatchedContext) ~= NoContext then
if __DEV__ then
if enableDebugTracing then
DebugTracing.logCommitStopped()
end
end
if enableSchedulingProfiler then
SchedulingProfiler.markCommitStopped(root)
end
return nil
end
flushSyncCallbackQueue()
if __DEV__ then
if enableDebugTracing then
DebugTracing.logCommitStopped()
end
end
if enableSchedulingProfiler then
SchedulingProfiler.markCommitStopped(root)
end
return nil
end
mod.commitBeforeMutationEffects = function(firstChild: Fiber)
local fiber = firstChild
while fiber ~= nil do
if fiber.deletions ~= nil then
mod.commitBeforeMutationEffectsDeletions(fiber.deletions)
end
if fiber.child ~= nil then
local primarySubtreeFlags =
bit32.band(fiber.subtreeFlags, ReactFiberFlags.BeforeMutationMask)
if primarySubtreeFlags ~= ReactFiberFlags.NoFlags then
mod.commitBeforeMutationEffects(fiber.child)
end
end
if __DEV__ then
setCurrentDebugFiberInDEV(fiber)
invokeGuardedCallback(nil, mod.commitBeforeMutationEffectsImpl, nil, fiber)
if hasCaughtError() then
local error_ = clearCaughtError()
exports.captureCommitPhaseError(fiber, fiber.return_, error_)
end
resetCurrentDebugFiberInDEV()
else
local ok, error_
if not __YOLO__ then
ok, error_ =
xpcall(mod.commitBeforeMutationEffectsImpl, describeError, fiber)
else
ok = true
mod.commitBeforeMutationEffectsImpl(fiber)
end
if not ok then
exports.captureCommitPhaseError(fiber, fiber.return_, error_)
end
end
fiber = fiber.sibling :: Fiber
end
end
mod.commitBeforeMutationEffectsImpl = function(fiber: Fiber)
local current = fiber.alternate
local flags = fiber.flags
if not shouldFireAfterActiveInstanceBlur and focusedInstanceHandle ~= nil then
if
fiber.tag == ReactWorkTags.SuspenseComponent
and ReactFiberCommitWork.isSuspenseBoundaryBeingHidden(current, fiber)
and doesFiberContain(fiber, focusedInstanceHandle)
then
shouldFireAfterActiveInstanceBlur = true
ReactFiberHostConfig.beforeActiveInstanceBlur()
end
end
if bit32.band(flags, ReactFiberFlags.Snapshot) ~= ReactFiberFlags.NoFlags then
setCurrentDebugFiberInDEV(fiber)
commitBeforeMutationEffectOnFiber(current, fiber)
resetCurrentDebugFiberInDEV()
end
if bit32.band(flags, ReactFiberFlags.Passive) ~= ReactFiberFlags.NoFlags then
if not rootDoesHavePassiveEffects then
rootDoesHavePassiveEffects = true
scheduleCallback(NormalSchedulerPriority, function()
exports.flushPassiveEffects()
return nil
end)
end
end
end
mod.commitBeforeMutationEffectsDeletions = function(deletions: Array<Fiber>)
for i = 1, #deletions do
local fiber = deletions[i]
if doesFiberContain(fiber, (focusedInstanceHandle :: any) :: Fiber) then
shouldFireAfterActiveInstanceBlur = true
ReactFiberHostConfig.beforeActiveInstanceBlur()
end
end
end
mod.commitMutationEffects = function(
firstChild: Fiber,
root: FiberRoot,
renderPriorityLevel: ReactPriorityLevel
)
local fiber = firstChild
while fiber ~= nil do
local deletions = fiber.deletions
if deletions ~= nil then
for _, childToDelete in deletions do
local ok, error_ = xpcall(
commitDeletion,
describeError,
root,
childToDelete,
fiber,
renderPriorityLevel
)
if not ok then
exports.captureCommitPhaseError(childToDelete, fiber, error_)
end
end
end
if fiber.child ~= nil then
local mutationFlags =
bit32.band(fiber.subtreeFlags, ReactFiberFlags.MutationMask)
if mutationFlags ~= ReactFiberFlags.NoFlags then
mod.commitMutationEffects(fiber.child, root, renderPriorityLevel)
end
end
if __DEV__ then
setCurrentDebugFiberInDEV(fiber)
invokeGuardedCallback(
nil,
mod.commitMutationEffectsImpl,
nil,
fiber,
root,
renderPriorityLevel
)
if hasCaughtError() then
local error_ = clearCaughtError()
exports.captureCommitPhaseError(fiber, fiber.return_, error_)
end
resetCurrentDebugFiberInDEV()
else
local ok, result
if not __YOLO__ then
ok, result = xpcall(
mod.commitMutationEffectsImpl,
describeError,
fiber,
root,
renderPriorityLevel
)
else
ok = true
mod.commitMutationEffectsImpl(fiber, root, renderPriorityLevel)
end
if not ok then
exports.captureCommitPhaseError(fiber, fiber.return_, result)
end
end
fiber = fiber.sibling :: Fiber
end
end
mod.commitMutationEffectsImpl = function(
fiber: Fiber,
root: FiberRoot,
renderPriorityLevel
)
local flags = fiber.flags
if bit32.band(flags, ReactFiberFlags.Ref) ~= 0 then
local current = fiber.alternate
if current ~= nil then
commitDetachRef(current)
end
end
local primaryFlags = bit32.band(
flags,
bit32.bor(
ReactFiberFlags.Placement,
ReactFiberFlags.Update,
ReactFiberFlags.Hydrating
)
)
if primaryFlags == ReactFiberFlags.Placement then
commitPlacement(fiber)
fiber.flags = bit32.band(fiber.flags, bit32.bnot(ReactFiberFlags.Placement))
elseif primaryFlags == ReactFiberFlags.PlacementAndUpdate then
commitPlacement(fiber)
fiber.flags = bit32.band(fiber.flags, bit32.bnot(ReactFiberFlags.Placement))
local current = fiber.alternate
commitWork(current, fiber)
elseif primaryFlags == ReactFiberFlags.Update then
local current = fiber.alternate
commitWork(current, fiber)
end
end
mod.commitMutationEffectsDeletions = function(
deletions: Array<Fiber>,
fiber: Fiber,
root: FiberRoot,
renderPriorityLevel
)
for _, childToDelete in deletions do
local ok, error_ = xpcall(
commitDeletion,
describeError,
root,
childToDelete,
fiber,
renderPriorityLevel
)
if not ok then
exports.captureCommitPhaseError(childToDelete, fiber, error_)
end
end
end
exports.schedulePassiveEffectCallback = function()
if not rootDoesHavePassiveEffects then
rootDoesHavePassiveEffects = true
scheduleCallback(NormalSchedulerPriority, function()
exports.flushPassiveEffects()
return nil
end)
end
end
local flushPassiveEffectsImpl
exports.flushPassiveEffects = function(): boolean
if pendingPassiveEffectsRenderPriority ~= NoSchedulerPriority then
local priorityLevel = if pendingPassiveEffectsRenderPriority
> NormalSchedulerPriority
then NormalSchedulerPriority
else pendingPassiveEffectsRenderPriority
pendingPassiveEffectsRenderPriority = NoSchedulerPriority
if ReactFeatureFlags.decoupleUpdatePriorityFromScheduler then
local previousLanePriority = getCurrentUpdateLanePriority()
setCurrentUpdateLanePriority(schedulerPriorityToLanePriority(priorityLevel))
local ok, result
if not __YOLO__ then
ok, result = xpcall(
runWithPriority,
describeError,
priorityLevel,
flushPassiveEffectsImpl
)
else
ok = true
setCurrentUpdateLanePriority(
schedulerPriorityToLanePriority(priorityLevel)
)
result = runWithPriority(priorityLevel, flushPassiveEffectsImpl)
end
setCurrentUpdateLanePriority(previousLanePriority)
if not ok then
error(result)
end
return result
else
return runWithPriority(priorityLevel, flushPassiveEffectsImpl)
end
end
return false
end
flushPassiveMountEffects = function(root, firstChild: Fiber): ()
local fiber = firstChild
while fiber ~= nil do
local prevProfilerOnStack = nil
if
ReactFeatureFlags.enableProfilerTimer
and ReactFeatureFlags.enableProfilerCommitHooks
then
if fiber.tag == ReactWorkTags.Profiler then
prevProfilerOnStack = nearestProfilerOnStack
nearestProfilerOnStack = fiber
end
end
local primarySubtreeFlags =
bit32.band(fiber.subtreeFlags, ReactFiberFlags.PassiveMask)
if fiber.child ~= nil and primarySubtreeFlags ~= ReactFiberFlags.NoFlags then
flushPassiveMountEffects(root, fiber.child)
end
if
bit32.band(fiber.flags, ReactFiberFlags.Passive) ~= ReactFiberFlags.NoFlags
then
if __DEV__ then
setCurrentDebugFiberInDEV(fiber)
invokeGuardedCallback(nil, commitPassiveMountOnFiber, nil, root, fiber)
if hasCaughtError() then
local error_ = clearCaughtError()
exports.captureCommitPhaseError(fiber, fiber.return_, error_)
end
resetCurrentDebugFiberInDEV()
else
local ok, error_
if not __YOLO__ then
ok, error_ =
xpcall(commitPassiveMountOnFiber, describeError, root, fiber)
else
ok = true
commitPassiveMountOnFiber(root, fiber)
end
if not ok then
exports.captureCommitPhaseError(fiber, fiber.return_, error_)
end
end
end
if
ReactFeatureFlags.enableProfilerTimer
and ReactFeatureFlags.enableProfilerCommitHooks
then
if fiber.tag == ReactWorkTags.Profiler then
if prevProfilerOnStack ~= nil then
prevProfilerOnStack.stateNode.passiveEffectDuration += fiber.stateNode.passiveEffectDuration
end
nearestProfilerOnStack = prevProfilerOnStack
end
end
fiber = fiber.sibling :: Fiber
end
end
local function flushPassiveUnmountEffects(firstChild: Fiber): ()
local fiber = firstChild
while fiber ~= nil do
local deletions = fiber.deletions
if deletions ~= nil then
for i = 1, #deletions do
local fiberToDelete = deletions[i]
mod.flushPassiveUnmountEffectsInsideOfDeletedTree(fiberToDelete, fiber)
if not (enableNewTreeCleanupPath and deletedTreeCleanUpLevel >= 2) then
mod.detachFiberAfterEffects(fiberToDelete)
end
end
if enableNewTreeCleanupPath then
if deletedTreeCleanUpLevel >= 1 then
local previousFiber = fiber.alternate
if previousFiber ~= nil then
local detachedChild = previousFiber.child
if detachedChild ~= nil then
previousFiber.child = nil
repeat
local detachedSibling = detachedChild.sibling
detachedChild.sibling = nil
detachedChild = detachedSibling
until detachedChild == nil
end
end
end
end
end
local child = fiber.child
if child ~= nil then
local passiveFlags =
bit32.band(fiber.subtreeFlags, ReactFiberFlags.PassiveMask)
if passiveFlags ~= ReactFiberFlags.NoFlags then
flushPassiveUnmountEffects(child)
end
end
local primaryFlags = bit32.band(fiber.flags, ReactFiberFlags.Passive)
if primaryFlags ~= ReactFiberFlags.NoFlags then
setCurrentDebugFiberInDEV(fiber)
commitPassiveUnmountOnFiber(fiber)
resetCurrentDebugFiberInDEV()
end
fiber = fiber.sibling :: Fiber
end
end
mod.flushPassiveUnmountEffectsInsideOfDeletedTree = function(
fiberToDelete: Fiber,
nearestMountedAncestor: Fiber
)
if
bit32.band(fiberToDelete.subtreeFlags, ReactFiberFlags.PassiveStatic)
~= ReactFiberFlags.NoFlags
or (enableNewTreeCleanupPath and deletedTreeCleanUpLevel >= 2)
then
local child = fiberToDelete.child
while child ~= nil do
local childSibling = child.sibling
mod.flushPassiveUnmountEffectsInsideOfDeletedTree(
child,
nearestMountedAncestor
)
child = childSibling
end
end
if
bit32.band(fiberToDelete.flags, ReactFiberFlags.PassiveStatic)
~= ReactFiberFlags.NoFlags
then
setCurrentDebugFiberInDEV(fiberToDelete)
commitPassiveUnmountInsideDeletedTreeOnFiber(
fiberToDelete,
nearestMountedAncestor
)
resetCurrentDebugFiberInDEV()
end
if enableNewTreeCleanupPath and deletedTreeCleanUpLevel >= 2 then
mod.detachFiberAfterEffects(fiberToDelete)
end
end
flushPassiveEffectsImpl = function()
if rootWithPendingPassiveEffects == nil then
return false
end
local root = rootWithPendingPassiveEffects :: FiberRoot
local lanes = pendingPassiveEffectsLanes
rootWithPendingPassiveEffects = nil
pendingPassiveEffectsLanes = ReactFiberLane.NoLanes
invariant(
bit32.band(executionContext, bit32.bor(RenderContext, CommitContext)) == NoContext,
"Cannot flush passive effects while already rendering."
)
if __DEV__ then
if enableDebugTracing then
DebugTracing.logPassiveEffectsStarted(lanes)
end
end
if enableSchedulingProfiler then
SchedulingProfiler.markPassiveEffectsStarted(lanes)
end
local prevExecutionContext = executionContext
executionContext = bit32.bor(executionContext, CommitContext)
local prevInteractions = mod.pushInteractions(root)
flushPassiveUnmountEffects(root.current)
flushPassiveMountEffects(root, root.current)
if __DEV__ then
if enableDebugTracing then
DebugTracing.logPassiveEffectsStopped()
end
end
if enableSchedulingProfiler then
SchedulingProfiler.markPassiveEffectsStopped(root)
end
if __DEV__ and enableDoubleInvokingEffects then
commitDoubleInvokeEffectsInDEV(root.current, true)
end
if ReactFeatureFlags.enableSchedulerTracing then
mod.popInteractions(prevInteractions)
mod.finishPendingInteractions(root, lanes)
end
executionContext = prevExecutionContext
flushSyncCallbackQueue()
if rootWithPendingPassiveEffects == nil then
nestedPassiveUpdateCount = 0
else
nestedPassiveUpdateCount = nestedPassiveUpdateCount + 1
end
return true
end
exports.isAlreadyFailedLegacyErrorBoundary = function(instance): boolean
return legacyErrorBoundariesThatAlreadyFailed ~= nil
and legacyErrorBoundariesThatAlreadyFailed:has(instance)
end
exports.markLegacyErrorBoundaryAsFailed = function(instance)
if legacyErrorBoundariesThatAlreadyFailed == nil then
legacyErrorBoundariesThatAlreadyFailed = Set.new({ instance })
else
legacyErrorBoundariesThatAlreadyFailed:add(instance)
end
end
local function prepareToThrowUncaughtError(error_)
if not hasUncaughtError then
hasUncaughtError = true
firstUncaughtError = error_
end
end
exports.onUncaughtError = prepareToThrowUncaughtError
captureCommitPhaseErrorOnRoot = function(rootFiber: Fiber, sourceFiber: Fiber, error_)
local errorInfo = createCapturedValue(error_, sourceFiber)
local update =
createRootErrorUpdate(rootFiber, errorInfo, SyncLane, exports.onUncaughtError)
enqueueUpdate(rootFiber, update)
local eventTime = exports.requestEventTime()
local root = mod.markUpdateLaneFromFiberToRoot(rootFiber, SyncLane)
if root ~= nil then
markRootUpdated(root, SyncLane, eventTime)
ensureRootIsScheduled(root, eventTime)
mod.schedulePendingInteractions(root, SyncLane)
end
end
exports.captureCommitPhaseError = function(
sourceFiber: Fiber,
nearestMountedAncestor,
error_
)
if sourceFiber.tag == ReactWorkTags.HostRoot then
captureCommitPhaseErrorOnRoot(sourceFiber, sourceFiber, error_)
return
end
local fiber = nil
if skipUnmountedBoundaries then
fiber = nearestMountedAncestor
else
fiber = sourceFiber.return_
end
while fiber ~= nil do
if fiber.tag == ReactWorkTags.HostRoot then
captureCommitPhaseErrorOnRoot(fiber, sourceFiber, error_)
return
else
if fiber.tag == ReactWorkTags.ClassComponent then
local ctor = fiber.type
local instance = fiber.stateNode
if
typeof(ctor.getDerivedStateFromError) == "function"
or (
typeof(instance.componentDidCatch) == "function"
and not exports.isAlreadyFailedLegacyErrorBoundary(instance)
)
then
local errorInfo = createCapturedValue(error_, sourceFiber)
local update = createClassErrorUpdate(fiber, errorInfo, SyncLane)
enqueueUpdate(fiber, update)
local eventTime = exports.requestEventTime()
local root = mod.markUpdateLaneFromFiberToRoot(fiber, SyncLane)
if root ~= nil then
markRootUpdated(root, SyncLane, eventTime)
ensureRootIsScheduled(root, eventTime)
mod.schedulePendingInteractions(root, SyncLane)
end
return
end
end
fiber = fiber.return_
end
end
end
exports.pingSuspendedRoot = function(
root: FiberRoot,
wakeable: Wakeable,
pingedLanes: Lanes
)
local pingCache = root.pingCache
if pingCache ~= nil then
pingCache[wakeable] = nil
end
local eventTime = exports.requestEventTime()
markRootPinged(root, pingedLanes, eventTime)
if
workInProgressRoot == root
and isSubsetOfLanes(workInProgressRootRenderLanes, pingedLanes)
then
if
workInProgressRootExitStatus == RootExitStatus.SuspendedWithDelay
or workInProgressRootExitStatus == RootExitStatus.Suspended
and includesOnlyRetries(workInProgressRootRenderLanes)
and now() - globalMostRecentFallbackTime < FALLBACK_THROTTLE_MS
then
mod.prepareFreshStack(root, ReactFiberLane.NoLanes)
else
workInProgressRootPingedLanes =
mergeLanes(workInProgressRootPingedLanes, pingedLanes)
end
end
ensureRootIsScheduled(root, eventTime)
mod.schedulePendingInteractions(root, pingedLanes)
end
function retryTimedOutBoundary(boundaryFiber: Fiber, retryLane: Lane)
if retryLane == ReactFiberLane.NoLane then
retryLane = requestRetryLane(boundaryFiber)
end
local eventTime = exports.requestEventTime()
local root = mod.markUpdateLaneFromFiberToRoot(boundaryFiber, retryLane)
if root ~= nil then
markRootUpdated(root, retryLane, eventTime)
ensureRootIsScheduled(root, eventTime)
mod.schedulePendingInteractions(root, retryLane)
end
end
exports.resolveRetryWakeable = function(boundaryFiber: Fiber, wakeable: Wakeable)
local retryLane = ReactFiberLane.NoLane
local retryCache
retryCache = boundaryFiber.stateNode
if retryCache ~= nil then
retryCache:delete(wakeable)
end
retryTimedOutBoundary(boundaryFiber, retryLane)
end
function jnd(timeElapsed: number): number
if timeElapsed < 120 then
return 120
elseif timeElapsed < 480 then
return 480
elseif timeElapsed < 1080 then
return 1080
elseif timeElapsed < 1920 then
return 1920
elseif timeElapsed < 3000 then
return 3000
elseif timeElapsed < 4320 then
return 4320
else
return math.ceil(timeElapsed / 1960) * 1960
end
end
mod.checkForNestedUpdates = function()
if nestedUpdateCount > NESTED_UPDATE_LIMIT then
nestedUpdateCount = 0
rootWithNestedUpdates = nil
invariant(
false,
"Maximum update depth exceeded. This can happen when a component "
.. "repeatedly calls setState inside componentWillUpdate or "
.. "componentDidUpdate. React limits the number of nested updates to "
.. "prevent infinite loops."
)
end
if __DEV__ then
if nestedPassiveUpdateCount > NESTED_PASSIVE_UPDATE_LIMIT then
nestedPassiveUpdateCount = 0
console.error(
"Maximum update depth exceeded. This can happen when a component "
.. "calls setState inside useEffect, but useEffect either doesn't "
.. "have a dependency array, or one of the dependencies changes on "
.. "every render."
)
end
end
end
function flushRenderPhaseStrictModeWarningsInDEV()
if __DEV__ then
ReactStrictModeWarnings.flushLegacyContextWarning()
if ReactFeatureFlags.warnAboutDeprecatedLifecycles then
ReactStrictModeWarnings.flushPendingUnsafeLifecycleWarnings()
end
end
end
function commitDoubleInvokeEffectsInDEV(fiber: Fiber, hasPassiveEffects: boolean)
if __DEV__ and enableDoubleInvokingEffects then
setCurrentDebugFiberInDEV(fiber)
invokeEffectsInDev(
fiber,
ReactFiberFlags.MountLayoutDev,
invokeLayoutEffectUnmountInDEV
)
if hasPassiveEffects then
invokeEffectsInDev(
fiber,
ReactFiberFlags.MountPassiveDev,
invokePassiveEffectUnmountInDEV
)
end
invokeEffectsInDev(
fiber,
ReactFiberFlags.MountLayoutDev,
invokeLayoutEffectMountInDEV
)
if hasPassiveEffects then
invokeEffectsInDev(
fiber,
ReactFiberFlags.MountPassiveDev,
invokePassiveEffectMountInDEV
)
end
resetCurrentDebugFiberInDEV()
end
end
function invokeEffectsInDev(
firstChild: Fiber,
fiberFlags: Flags,
invokeEffectFn: (fiber: Fiber) -> ()
): ()
if __DEV__ and enableDoubleInvokingEffects then
local fiber = firstChild
while fiber ~= nil do
if fiber.child ~= nil then
local primarySubtreeFlag = bit32.band(fiber.subtreeFlags, fiberFlags)
if primarySubtreeFlag ~= ReactFiberFlags.NoFlags then
invokeEffectsInDev(fiber.child, fiberFlags, invokeEffectFn)
end
end
if bit32.band(fiber.flags, fiberFlags) ~= ReactFiberFlags.NoFlags then
invokeEffectFn(fiber)
end
fiber = fiber.sibling :: Fiber
end
end
end
local didWarnStateUpdateForNotYetMountedComponent: any = nil
mod.warnAboutUpdateOnNotYetMountedFiberInDEV = function(fiber)
if __DEV__ then
if bit32.band(executionContext, RenderContext) ~= NoContext then
return
end
if
bit32.band(
fiber.mode,
bit32.bor(ReactTypeOfMode.BlockingMode, ReactTypeOfMode.ConcurrentMode)
) == 0
then
return
end
local tag = fiber.tag
if
tag ~= ReactWorkTags.IndeterminateComponent
and tag ~= ReactWorkTags.HostRoot
and tag ~= ReactWorkTags.ClassComponent
and tag ~= ReactWorkTags.FunctionComponent
and tag ~= ReactWorkTags.ForwardRef
and tag ~= ReactWorkTags.MemoComponent
and tag ~= ReactWorkTags.SimpleMemoComponent
and tag ~= ReactWorkTags.Block
then
return
end
local componentName = getComponentName(fiber.type) or "ReactComponent"
if didWarnStateUpdateForNotYetMountedComponent ~= nil then
if didWarnStateUpdateForNotYetMountedComponent[componentName] then
return
end
didWarnStateUpdateForNotYetMountedComponent[componentName] = true
else
didWarnStateUpdateForNotYetMountedComponent = { [componentName] = true }
end
local previousFiber = ReactCurrentFiber.current
local ok, result = pcall(function()
setCurrentDebugFiberInDEV(fiber)
console.error(
"Can't perform a React state update on a component that hasn't mounted yet. "
.. "This indicates that you have a side-effect in your render function that "
.. "asynchronously later calls tries to update the component. Move this work to "
.. "useEffect instead."
)
end)
if previousFiber then
setCurrentDebugFiberInDEV(fiber)
else
resetCurrentDebugFiberInDEV()
end
if not ok then
error(result)
end
end
end
if __DEV__ and ReactFeatureFlags.replayFailedUnitOfWorkWithInvokeGuardedCallback then
local dummyFiber = nil
mod.beginWork = function(current, unitOfWork, lanes)
local originalWorkInProgressCopy =
ReactFiber.assignFiberPropertiesInDEV(dummyFiber, unitOfWork)
local ok, result =
xpcall(originalBeginWork, describeError, current, unitOfWork, lanes)
if not ok then
local originalError = result
if
originalError ~= nil
and typeof(originalError) == "table"
and typeof(originalError.andThen) == "function"
then
error(originalError)
end
resetContextDependencies()
resetHooksAfterThrow()
unwindInterruptedWork(unitOfWork)
ReactFiber.assignFiberPropertiesInDEV(unitOfWork, originalWorkInProgressCopy)
if
ReactFeatureFlags.enableProfilerTimer
and bit32.band(unitOfWork.mode, ReactTypeOfMode.ProfileMode) ~= 0
then
ReactProfilerTimer.startProfilerTimer(unitOfWork)
end
invokeGuardedCallback(nil, originalBeginWork, nil, current, unitOfWork, lanes)
if hasCaughtError() then
local replayError = clearCaughtError()
error(replayError)
else
error(originalError)
end
end
return result
end
else
mod.beginWork = originalBeginWork
end
local didWarnAboutUpdateInRender = false
local didWarnAboutUpdateInRenderForAnotherComponent
if __DEV__ then
didWarnAboutUpdateInRenderForAnotherComponent = {}
end
mod.warnAboutRenderPhaseUpdatesInDEV = function(fiber: Fiber): ()
if __DEV__ then
if
ReactCurrentFiber.isRendering
and bit32.band(executionContext, RenderContext) ~= NoContext
and not getIsUpdatingOpaqueValueInRenderPhaseInDEV()
then
if
fiber.tag == ReactWorkTags.FunctionComponent
or fiber.tag == ReactWorkTags.ForwardRef
or fiber.tag == ReactWorkTags.SimpleMemoComponent
then
local renderingComponentName = (function()
return workInProgress
and getComponentName((workInProgress :: Fiber).type)
or "Unknown"
end)()
local dedupeKey = renderingComponentName
if didWarnAboutUpdateInRenderForAnotherComponent[dedupeKey] == nil then
didWarnAboutUpdateInRenderForAnotherComponent[dedupeKey] = true
local setStateComponentName = getComponentName(fiber.type)
or "Unknown"
console.error(
"Cannot update a component (`%s`) while rendering a "
.. "different component (`%s`). To locate the bad setState() call inside `%s`, "
.. "follow the stack trace as described in https://reactjs.org/link/setstate-in-render",
setStateComponentName,
renderingComponentName,
renderingComponentName
)
end
elseif fiber.tag == ReactWorkTags.ClassComponent then
if not didWarnAboutUpdateInRender then
console.error(
"Cannot update during an existing state transition (such as "
.. "within `render`). Render methods should be a pure "
.. "function of props and state."
)
didWarnAboutUpdateInRender = true
end
end
end
end
end
exports.IsThisRendererActing = { current = false }
exports.warnIfNotScopedWithMatchingAct = function(fiber: Fiber)
if __DEV__ then
if
ReactFiberHostConfig.warnsIfNotActing == true
and IsSomeRendererActing.current == true
and exports.IsThisRendererActing.current ~= true
then
local previousFiber = ReactCurrentFiber.current
local ok, result = pcall(function()
setCurrentDebugFiberInDEV(fiber)
console.error(
"It looks like you're using the wrong act() around your test interactions.\n"
.. "Be sure to use the matching version of act() corresponding to your renderer:\n\n"
.. "-- for react-roblox:\n"
.. "local React = __require(Packages.React)\n"
.. "-- ...\n"
.. "React.TestUtils.act(function() ... end)\n\n"
.. "-- for react-test-renderer:\n"
.. "local TestRenderer = __require(Packages.ReactTestRenderer)\n"
.. "-- ...\n"
.. "TestRenderer.act(function() ... end)"
)
end)
if previousFiber then
setCurrentDebugFiberInDEV(fiber)
else
resetCurrentDebugFiberInDEV()
end
if not ok then
error(result)
end
end
end
end
exports.warnIfNotCurrentlyActingEffectsInDEV = function(fiber: Fiber): ()
if __DEV__ then
if
ReactFiberHostConfig.warnsIfNotActing == true
and bit32.band(fiber.mode, ReactTypeOfMode.StrictMode) ~= ReactTypeOfMode.NoMode
and IsSomeRendererActing.current == false
and exports.IsThisRendererActing.current == false
then
console.error(
"An update to %s ran an effect, but was not wrapped in act(...).\n\n"
.. "When testing, code that causes React state updates should be "
.. "wrapped into act(...):\n\n"
.. "act(function()\n"
.. "  --[[ fire events that update state ]]\n"
.. "end)\n"
.. "--[[ assert on the output ]]\n\n"
.. "This ensures that you're testing the behavior the user would see "
.. "in the real client."
.. " Learn more at https://reactjs.org/link/wrap-tests-with-act",
getComponentName(fiber.type)
)
end
end
end
exports.warnIfNotCurrentlyActingUpdatesInDEV = function(fiber: Fiber): ()
if __DEV__ then
if
ReactFiberHostConfig.warnsIfNotActing == true
and executionContext == NoContext
and IsSomeRendererActing.current == false
and exports.IsThisRendererActing.current == false
then
local previousFiber = ReactCurrentFiberCurrent
local ok, result = pcall(function()
setCurrentDebugFiberInDEV(fiber)
console.error(
"An update to %s inside a test was not wrapped in act(...).\n\n"
.. "When testing, code that causes React state updates should be "
.. "wrapped into act(...):\n\n"
.. "act(function()\n"
.. "  --[[ fire events that update state ]]\n"
.. "end)\n"
.. "--[[ assert on the output ]]\n\n"
.. "This ensures that you're testing the behavior the user would see "
.. "in the client application."
.. " Learn more at https://reactjs.org/link/wrap-tests-with-act",
getComponentName(fiber.type)
)
end)
if previousFiber then
setCurrentDebugFiberInDEV(fiber)
else
resetCurrentDebugFiberInDEV()
end
if ok then
return result
end
end
end
return
end
local didWarnAboutUnmockedScheduler = false
exports.warnIfUnmockedScheduler = function(fiber: Fiber)
if __DEV__ then
if
didWarnAboutUnmockedScheduler == false
and Scheduler.unstable_flushAllWithoutAsserting == nil
then
if
bit32.band(fiber.mode, ReactTypeOfMode.BlockingMode) ~= 0
or bit32.band(fiber.mode, ReactTypeOfMode.ConcurrentMode) ~= 0
then
didWarnAboutUnmockedScheduler = true
console.error(
"In Concurrent or Sync modes, the 'scheduler' module needs to be mocked "
.. "to guarantee consistent behaviour across tests and client application. "
.. "For example, with Jest: \n"
.. "jest.mock('scheduler', function() return __require(Packages.Scheduler).unstable_mock end)\n\n"
.. "For more info, visit https://reactjs.org/link/mock-scheduler"
)
elseif ReactFeatureFlags.warnAboutUnmockedScheduler == true then
didWarnAboutUnmockedScheduler = true
console.error(
"Starting from React v18, the 'scheduler' module will need to be mocked "
.. "to guarantee consistent behaviour across tests and client applications. "
.. "For example, with Jest: \n"
.. "jest.mock('scheduler', function() return __require(Packages.Scheduler).unstable_mock end)\n\n"
.. "For more info, visit https://reactjs.org/link/mock-scheduler"
)
end
end
end
end
function computeThreadID(root: FiberRoot, lane: Lane | Lanes)
return lane * 1000 + root.interactionThreadID
end
exports.markSpawnedWork = function(lane: Lane | Lanes)
if not ReactFeatureFlags.enableSchedulerTracing then
return
end
if spawnedWorkDuringRender == nil then
spawnedWorkDuringRender = { lane }
else
table.insert(spawnedWorkDuringRender :: Array<number>, lane)
end
end
function scheduleInteractions(
root: FiberRoot,
lane: Lane | Lanes,
interactions: Set<Interaction>
)
if not ReactFeatureFlags.enableSchedulerTracing then
return
end
if interactions.size > 0 then
local pendingInteractionMap = root.pendingInteractionMap
local pendingInteractions = pendingInteractionMap:get(lane)
if pendingInteractions ~= nil then
interactions:forEach(function(interaction)
if not pendingInteractions:has(interaction) then
interaction.__count += 1
end
pendingInteractions:add(interaction)
end)
else
pendingInteractionMap:set(lane, Set.new(interactions))
for _, interaction in interactions do
interaction.__count += 1
end
end
local subscriber = __subscriberRef.current
if subscriber ~= nil then
local threadID = computeThreadID(root, lane)
subscriber.onWorkScheduled(interactions, threadID)
end
end
end
mod.schedulePendingInteractions = function(root: FiberRoot, lane: Lane | Lanes)
if not ReactFeatureFlags.enableSchedulerTracing then
return
end
scheduleInteractions(root, lane, __interactionsRef.current)
end
mod.startWorkOnPendingInteractions = function(root: FiberRoot, lanes: Lanes)
if not ReactFeatureFlags.enableSchedulerTracing then
return
end
local interactions: Set<Interaction> = Set.new()
root.pendingInteractionMap:forEach(function(scheduledInteractions, scheduledLane)
if includesSomeLane(lanes, scheduledLane) then
scheduledInteractions:forEach(function(interaction)
interactions:add(interaction)
end)
end
end)
root.memoizedInteractions = interactions :: any
if interactions.size > 0 then
local subscriber = __subscriberRef.current
if subscriber ~= nil then
local threadID = computeThreadID(root, lanes)
local ok, error_ =
xpcall(subscriber.onWorkStarted, describeError, interactions, threadID)
if not ok then
scheduleCallback(ImmediateSchedulerPriority, function()
error(error_)
end)
end
end
end
end
mod.finishPendingInteractions = function(root: FiberRoot, committedLanes)
if not ReactFeatureFlags.enableSchedulerTracing then
return
end
local remainingLanesAfterCommit = root.pendingLanes
local subscriber
local ok = true
local error_
if subscriber ~= nil and root.memoizedInteractions.size > 0 then
local threadID = computeThreadID(root, committedLanes)
subscriber = __subscriberRef.current
ok, error_ = xpcall(
subscriber.onWorkStopped,
describeError,
root.memoizedInteractions,
threadID
)
end
local pendingInteractionMap = root.pendingInteractionMap
pendingInteractionMap:forEach(function(scheduledInteractions, lane)
if not includesSomeLane(remainingLanesAfterCommit, lane) then
pendingInteractionMap:delete(lane)
scheduledInteractions:forEach(function(interaction)
interaction.__count -= 1
if subscriber ~= nil and interaction.__count == 0 then
local ok_, error__ = xpcall(
subscriber.onInteractionScheduledWorkCompleted,
describeError,
interaction
)
if not ok_ then
scheduleCallback(ImmediateSchedulerPriority, function()
error(error__)
end)
end
end
end)
end
end)
if not ok then
scheduleCallback(ImmediateSchedulerPriority, function()
error(error_)
end)
end
end
local isFlushingAct = false
local isInsideThisAct = false
local flushMockScheduler = Scheduler.unstable_flushAllWithoutAsserting
local isSchedulerMocked = typeof(flushMockScheduler) == "function"
local function flushActWork(): boolean
if flushMockScheduler ~= nil then
local prevIsFlushing = isFlushingAct
isFlushingAct = true
local ok, result = xpcall(flushMockScheduler, describeError)
isFlushingAct = prevIsFlushing
if not ok then
error(result)
else
return result
end
else
local prevIsFlushing = isFlushingAct
isFlushingAct = true
local ok, result = xpcall(function()
local didFlushWork = false
while exports.flushPassiveEffects() do
didFlushWork = true
end
return didFlushWork
end, describeError)
isFlushingAct = prevIsFlushing
if not ok then
error(result)
else
return result
end
end
end
local function flushWorkAndMicroTasks(onDone: (any?) -> ())
local ok, result = xpcall(flushActWork, describeError)
if ok then
ok, result = xpcall(enqueueTask, describeError, function()
if flushActWork() then
flushWorkAndMicroTasks(onDone)
else
onDone()
end
end)
end
if not ok then
onDone(result)
end
end
exports.act = function(callback: () -> Thenable<any>): Thenable<any>
if not (__DEV__ or ReactGlobals.__ROACT_17_MOCK_SCHEDULER__) then
if didWarnAboutUsingActInProd == false then
didWarnAboutUsingActInProd = true
console.error(
"act(...) is not supported in production builds of React, and might not behave as expected."
)
end
end
local previousActingUpdatesScopeDepth = actingUpdatesScopeDepth
actingUpdatesScopeDepth += 1
local previousIsSomeRendererActing = IsSomeRendererActing.current
local previousIsThisRendererActing = exports.IsThisRendererActing.current
local previousIsInsideThisAct = isInsideThisAct
IsSomeRendererActing.current = true
exports.IsThisRendererActing.current = true
isInsideThisAct = true
local function onDone()
actingUpdatesScopeDepth -= 1
IsSomeRendererActing.current = previousIsSomeRendererActing
exports.IsThisRendererActing.current = previousIsThisRendererActing
isInsideThisAct = previousIsInsideThisAct
if __DEV__ then
if actingUpdatesScopeDepth > previousActingUpdatesScopeDepth then
console.error(
"You seem to have overlapping act() calls, this is not supported. "
.. "Be sure to await previous act() calls before making a new one. "
)
end
end
end
local ok, result = xpcall(exports.batchedUpdates, describeError, callback)
if not ok then
onDone()
error(result)
end
if
result ~= nil
and typeof(result) == "table"
and typeof(result.andThen) == "function"
then
local called = false
if __DEV__ then
if typeof(Promise) ~= nil then
Promise.resolve():andThen(function() end):andThen(function()
if called == false then
console.error(
"You called act(Promise.new(function() --[[ ... ]] end)) without :await() or :expect(). "
.. "This could lead to unexpected testing behaviour, interleaving multiple act "
.. "calls and mixing their scopes. You should - act(function() Promise.new(function() --[[ ... ]] end):await() end);"
)
end
end)
end
end
return {
andThen = function<U>(self, resolve, reject)
called = true
return result:andThen(function()
if
actingUpdatesScopeDepth > 1
or (
isSchedulerMocked == true
and previousIsSomeRendererActing == true
)
then
onDone()
resolve()
return
end
flushWorkAndMicroTasks(function(err: any?)
onDone()
if err then
reject(err)
else
resolve()
end
end)
end, function(err)
onDone()
reject(err)
end)
end,
}
else
if __DEV__ then
if result ~= nil then
console.error(
"The callback passed to act(...) function "
.. "must return nil, or a Promise. You returned %s",
tostring(result)
)
end
end
local flushOk, flushResult = xpcall(function()
if
actingUpdatesScopeDepth == 1
and (isSchedulerMocked == false or previousIsSomeRendererActing == false)
then
flushActWork()
end
onDone()
end, describeError)
if not flushOk then
onDone()
error(flushResult)
end
return {
andThen = function<U>(self, resolve, reject_)
if __DEV__ then
console.error(
"Do not await the result of calling act(...) with sync logic, it is not a Promise."
)
end
resolve()
end,
}
end
end
mod.detachFiberAfterEffects = function(fiber: Fiber)
if enableNewTreeCleanupPath then
local alternate = fiber.alternate
if alternate ~= nil then
fiber.alternate = nil
mod.detachFiberAfterEffects(alternate)
end
end
if not (enableNewTreeCleanupPath and deletedTreeCleanUpLevel >= 2) then
fiber.child = nil
fiber.deletions = nil
fiber.dependencies = nil
fiber.memoizedProps = nil
fiber.memoizedState = nil
fiber.pendingProps = nil
fiber.sibling = nil
fiber.stateNode = nil
fiber.updateQueue = nil
if __DEV__ then
fiber._debugOwner = nil
end
else
fiber.child = nil
fiber.deletions = nil
fiber.sibling = nil
if __DEV__ then
fiber._debugOwner = nil
end
if deletedTreeCleanUpLevel >= 3 then
fiber.return_ = nil
fiber.dependencies = nil
fiber.memoizedProps = nil
fiber.memoizedState = nil
fiber.pendingProps = nil
fiber.stateNode = nil
fiber.updateQueue = nil
end
end
end
return exports
end
end)())
__register("ReactReconciler/ReactHookEffectTags", (function()
local script = __makeProxy({"ReactReconciler","ReactHookEffectTags"})
return function()
type HookFlags = number
return {
NoFlags = 0b000,
HasEffect = 0b001,
Layout = 0b010,
Passive = 0b100,
}
end
end)())
__register("ReactReconciler/ReactInternalTypes", (function()
local script = __makeProxy({"ReactReconciler","ReactInternalTypes"})
return function()
local Packages = script.Parent.Parent
local LuauPolyfill = __require(Packages.LuauPolyfill)
type Array<T> = LuauPolyfill.Array<T>
type Map<K, V> = LuauPolyfill.Map<K, V>
type Object = { [string]: any }
type SimpleSet<T> = { [T]: boolean }
type SimpleMap<K, V> = { [K]: V }
type Set<T> = LuauPolyfill.Set<T>
local ReactTypes = __require(Packages.Shared)
type Source = ReactTypes.Source
type RefObject = ReactTypes.RefObject
type ReactContext<T> = ReactTypes.ReactContext<T>
type MutableSourceVersion = ReactTypes.MutableSourceVersion
type MutableSource<Source> = ReactTypes.MutableSource<Source>
type MutableSourceSubscribeFn<Source, Snapshot> = ReactTypes.MutableSourceSubscribeFn<
Source,
Snapshot
>
type MutableSourceGetSnapshotFn<Source, Snapshot> = ReactTypes.MutableSourceGetSnapshotFn<
Source,
Snapshot
>
type SuspenseInstance = any
local ReactWorkTags = __require(script.Parent.ReactWorkTags)
type WorkTag = ReactWorkTags.WorkTag
local ReactTypeOfMode = __require(script.Parent.ReactTypeOfMode)
type TypeOfMode = ReactTypeOfMode.TypeOfMode
local ReactFiberFlags = __require(script.Parent.ReactFiberFlags)
type Flags = ReactFiberFlags.Flags
type LanePriority = number
type Lanes = number
type Lane = number
type LaneMap<T> = { [number]: T }
type Update<State> = {
eventTime: number,
lane: Lane,
tag: number,
payload: any,
callback: (() -> ...any)?,
next: Update<State>?,
}
type SharedQueue<State> = {
pending: Update<State>?,
}
type UpdateQueue<State> = {
baseState: State,
firstBaseUpdate: Update<State>?,
lastBaseUpdate: Update<State>?,
shared: SharedQueue<State>,
effects: Array<Update<State>>?,
}
type HookType =
"useState"
| "useReducer"
| "useContext"
| "useRef"
| "useBinding"
| "useEffect"
| "useLayoutEffect"
| "useCallback"
| "useMemo"
| "useImperativeHandle"
| "useDebugValue"
| "useDeferredValue"
| "useTransition"
| "useMutableSource"
| "useOpaqueIdentifier"
local ReactRootTags = __require(script.Parent.ReactRootTags)
type RootTag = ReactRootTags.RootTag
type TimeoutHandle = any
type NoTimeout = any
local Shared = __require(Packages.Shared)
type Wakeable = Shared.Wakeable
local Scheduler = __require(Packages.Scheduler)
type Interaction = Scheduler.Interaction
type ReactPriorityLevel = number
type ContextDependency<T> = {
context: ReactContext<T>,
observedBits: number,
next: ContextDependency<T> | nil,
}
type Dependencies = {
lanes: Lanes,
firstContext: ContextDependency<any> | nil,
}
type RoactStableKey = string | number
type Fiber = {
tag: WorkTag,
key: RoactStableKey?,
elementType: any,
type: any,
stateNode: any,
return_: Fiber | nil,
child: Fiber?,
sibling: Fiber?,
index: number,
ref: nil | ((handle: any) -> ()) | { _stringRef: string?, [string]: any } | RefObject,
pendingProps: any,
memoizedProps: any,
updateQueue: any,
memoizedState: any,
dependencies: Dependencies?,
mode: TypeOfMode,
flags: Flags,
subtreeFlags: Flags,
deletions: Array<Fiber>?,
nextEffect: Fiber?,
firstEffect: Fiber?,
lastEffect: Fiber?,
lanes: Lanes,
childLanes: Lanes,
alternate: Fiber?,
actualDuration: number?,
actualStartTime: number?,
selfBaseDuration: number?,
treeBaseDuration: number?,
_debugID: number?,
_debugSource: Source?,
_debugOwner: Fiber?,
_debugIsCurrentlyTiming: boolean?,
_debugNeedsRemount: boolean?,
_debugHookTypes: Array<HookType>?,
}
type SuspenseHydrationCallbacks = {
onHydrated: ((SuspenseInstance) -> ())?,
onDeleted: ((SuspenseInstance) -> ())?,
}
type FiberRoot = {
tag: RootTag,
containerInfo: any,
pendingChildren: any,
current: Fiber,
pingCache: SimpleMap<
Wakeable,
(SimpleSet<any> | SimpleMap<Wakeable, SimpleSet<any>>)
> | nil,
finishedWork: Fiber?,
timeoutHandle: TimeoutHandle | NoTimeout,
context: Object?,
pendingContext: Object?,
hydrate: boolean,
mutableSourceEagerHydrationData: Array<MutableSource<any> | MutableSourceVersion>?,
callbackNode: any,
callbackPriority: LanePriority,
eventTimes: LaneMap<number>,
expirationTimes: LaneMap<number>,
pendingLanes: Lanes,
suspendedLanes: Lanes,
pingedLanes: Lanes,
expiredLanes: Lanes,
mutableReadLanes: Lanes,
finishedLanes: Lanes,
entangledLanes: Lanes,
entanglements: LaneMap<Lanes>,
interactionThreadID: number,
memoizedInteractions: Set<Interaction>,
pendingInteractionMap: Map<Lane | Lanes, Set<Interaction>>,
hydrationCallbacks: SuspenseHydrationCallbacks?,
}
type BasicStateAction<S> = ((S) -> S) | S
type Dispatch<A> = (A) -> ()
type Dispatcher = Shared.Dispatcher
return {}
end
end)())
__register("ReactReconciler/ReactMutableSource.new", (function()
local script = __makeProxy({"ReactReconciler","ReactMutableSource.new"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local console = __require(Packages.Shared).console
type Array<T> = { [number]: T }
local exports = {}
local ReactTypes = __require(Packages.Shared)
type MutableSource<T> = ReactTypes.MutableSource<T>
type MutableSourceVersion = ReactTypes.MutableSourceVersion
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type FiberRoot = ReactInternalTypes.FiberRoot
local isPrimaryRenderer = __require(script.Parent.ReactFiberHostConfig).isPrimaryRenderer
local workInProgressSources: Array<MutableSource<any>> = {}
local rendererSigil
if ReactGlobals.__DEV__ then
rendererSigil = {}
end
exports.markSourceAsDirty = function(mutableSource: MutableSource<any>)
table.insert(workInProgressSources, mutableSource)
end
exports.resetWorkInProgressVersions = function()
for i, mutableSource in workInProgressSources do
if isPrimaryRenderer then
mutableSource._workInProgressVersionPrimary = nil
else
mutableSource._workInProgressVersionSecondary = nil
end
end
table.clear(workInProgressSources)
end
exports.getWorkInProgressVersion = function(
mutableSource: MutableSource<any>
): nil | MutableSourceVersion
if isPrimaryRenderer then
return mutableSource._workInProgressVersionPrimary
else
return mutableSource._workInProgressVersionSecondary
end
end
exports.setWorkInProgressVersion = function(
mutableSource: MutableSource<any>,
version_: MutableSourceVersion
)
if isPrimaryRenderer then
mutableSource._workInProgressVersionPrimary = version_
else
mutableSource._workInProgressVersionSecondary = version_
end
table.insert(workInProgressSources, mutableSource)
end
exports.warnAboutMultipleRenderersDEV = function(mutableSource: MutableSource<any>)
if ReactGlobals.__DEV__ then
if isPrimaryRenderer then
if mutableSource._currentPrimaryRenderer == nil then
mutableSource._currentPrimaryRenderer = rendererSigil
elseif mutableSource._currentPrimaryRenderer ~= rendererSigil then
console.error(
"Detected multiple renderers concurrently rendering the "
.. "same mutable source. This is currently unsupported."
)
end
else
if mutableSource._currentSecondaryRenderer == nil then
mutableSource._currentSecondaryRenderer = rendererSigil
elseif mutableSource._currentSecondaryRenderer ~= rendererSigil then
console.error(
"Detected multiple renderers concurrently rendering the "
.. "same mutable source. This is currently unsupported."
)
end
end
end
end
exports.registerMutableSourceForHydration = function(
root: FiberRoot,
mutableSource: MutableSource<any>
)
local getVersion = mutableSource._getVersion
local version_ = getVersion(mutableSource._source)
if root.mutableSourceEagerHydrationData == nil then
root.mutableSourceEagerHydrationData = { mutableSource, version_ }
else
end
end
return exports
end
end)())
__register("ReactReconciler/ReactPortal", (function()
local script = __makeProxy({"ReactReconciler","ReactPortal"})
return function()
local Packages = script.Parent.Parent
local REACT_PORTAL_TYPE = __require(Packages.Shared).ReactSymbols.REACT_PORTAL_TYPE
local ReactTypes = __require(Packages.Shared)
type ReactNodeList = ReactTypes.ReactNodeList
type ReactPortal = ReactTypes.ReactPortal
local function createPortal(
children: ReactNodeList,
containerInfo: any,
implementation: any,
key: string?
): ReactPortal
if key ~= nil then
key = tostring(key)
end
return {
["$$typeof"] = REACT_PORTAL_TYPE,
key = key,
children = children,
containerInfo = containerInfo,
implementation = implementation,
}
end
return {
createPortal = createPortal,
}
end
end)())
__register("ReactReconciler/ReactProfilerTimer.new", (function()
local script = __makeProxy({"ReactReconciler","ReactProfilerTimer.new"})
return function()
local Packages = script.Parent.Parent
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
local ReactFeatureFlags = __require(Packages.Shared).ReactFeatureFlags
local enableProfilerTimer = ReactFeatureFlags.enableProfilerTimer
local enableProfilerCommitHooks = ReactFeatureFlags.enableProfilerCommitHooks
local ReactWorkTags = __require(script.Parent.ReactWorkTags)
local Profiler = ReactWorkTags.Profiler
local Scheduler = __require(Packages.Scheduler)
local now = Scheduler.unstable_now
type ProfilerTimer = {
getCommitTime: () -> number,
recordCommitTime: () -> (),
startProfilerTimer: (Fiber) -> (),
stopProfilerTimerIfRunning: (Fiber) -> (),
stopProfilerTimerIfRunningAndRecordDelta: (Fiber) -> (),
}
local commitTime: number = 0
local layoutEffectStartTime: number = -1
local profilerStartTime: number = -1
local passiveEffectStartTime: number = -1
function getCommitTime(): number
return commitTime
end
function recordCommitTime(): ()
if not enableProfilerTimer then
return
end
commitTime = now()
end
function startProfilerTimer(fiber: Fiber): ()
if not enableProfilerTimer then
return
end
profilerStartTime = now()
if fiber.actualStartTime ~= nil and (fiber.actualStartTime :: number) < 0 then
fiber.actualStartTime = now()
end
end
function stopProfilerTimerIfRunning(fiber: Fiber): ()
if not enableProfilerTimer then
return
end
profilerStartTime = -1
end
function stopProfilerTimerIfRunningAndRecordDelta(
fiber: Fiber,
overrideBaseTime: boolean
): ()
if not enableProfilerTimer then
return
end
if profilerStartTime >= 0 then
local elapsedTime_ = now() - profilerStartTime
fiber.actualDuration += elapsedTime_
if overrideBaseTime then
fiber.selfBaseDuration = elapsedTime_
end
profilerStartTime = -1
end
end
function recordLayoutEffectDuration(fiber: Fiber): ()
if not enableProfilerTimer or not enableProfilerCommitHooks then
return
end
if layoutEffectStartTime >= 0 then
local elapsedTime_ = now() - layoutEffectStartTime
layoutEffectStartTime = -1
local parentFiber = fiber.return_
while parentFiber ~= nil do
if parentFiber.tag == Profiler then
local parentStateNode = parentFiber.stateNode
parentStateNode.effectDuration += elapsedTime_
break
end
parentFiber = parentFiber.return_
end
end
end
function recordPassiveEffectDuration(fiber: Fiber): ()
if not enableProfilerTimer or not enableProfilerCommitHooks then
return
end
if passiveEffectStartTime >= 0 then
local elapsedTime_ = now() - passiveEffectStartTime
passiveEffectStartTime = -1
local parentFiber = fiber.return_
while parentFiber ~= nil do
if parentFiber.tag == Profiler then
local parentStateNode = parentFiber.stateNode
if parentStateNode ~= nil then
parentStateNode.passiveEffectDuration += elapsedTime_
end
break
end
parentFiber = parentFiber.return_
end
end
end
function startLayoutEffectTimer(): ()
if not enableProfilerTimer or not enableProfilerCommitHooks then
return
end
layoutEffectStartTime = now()
end
function startPassiveEffectTimer(): ()
if not enableProfilerTimer or not enableProfilerCommitHooks then
return
end
passiveEffectStartTime = now()
end
function transferActualDuration(fiber: Fiber): ()
local child = fiber.child
while child do
fiber.actualDuration += child.actualDuration
child = child.sibling
end
end
return {
getCommitTime = getCommitTime,
recordCommitTime = recordCommitTime,
recordLayoutEffectDuration = recordLayoutEffectDuration,
recordPassiveEffectDuration = recordPassiveEffectDuration,
startLayoutEffectTimer = startLayoutEffectTimer,
startPassiveEffectTimer = startPassiveEffectTimer,
startProfilerTimer = startProfilerTimer,
stopProfilerTimerIfRunning = stopProfilerTimerIfRunning,
stopProfilerTimerIfRunningAndRecordDelta = stopProfilerTimerIfRunningAndRecordDelta,
transferActualDuration = transferActualDuration,
}
end
end)())
__register("ReactReconciler/ReactRootTags", (function()
local script = __makeProxy({"ReactReconciler","ReactRootTags"})
return function()
type RootTag = number
return {
LegacyRoot = 0,
BlockingRoot = 1,
ConcurrentRoot = 2,
}
end
end)())
__register("ReactReconciler/ReactStrictModeWarnings.new", (function()
local script = __makeProxy({"ReactReconciler","ReactStrictModeWarnings.new"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local console = __require(Packages.Shared).console
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
local ReactCurrentFiber = __require(script.Parent.ReactCurrentFiber)
local resetCurrentDebugFiberInDEV = ReactCurrentFiber.resetCurrentFiber
local setCurrentDebugFiberInDEV = ReactCurrentFiber.setCurrentFiber
local getComponentName = __require(Packages.Shared).getComponentName
local StrictMode = __require(script.Parent.ReactTypeOfMode).StrictMode
type Set<T> = { [T]: boolean }
type Array<T> = { [number]: T }
type Map<K, V> = { [K]: V }
type FiberArray = Array<Fiber>
type FiberToFiberComponentsMap = Map<Fiber, FiberArray>
local ReactStrictModeWarnings = {
recordUnsafeLifecycleWarnings = function(fiber: Fiber, instance: any) end,
flushPendingUnsafeLifecycleWarnings = function() end,
recordLegacyContextWarning = function(fiber: Fiber, instance: any) end,
flushLegacyContextWarning = function() end,
discardPendingWarnings = function() end,
}
if ReactGlobals.__DEV__ then
local findStrictRoot = function(fiber: Fiber): Fiber | nil
local maybeStrictRoot = nil
local node: Fiber? = fiber
while node ~= nil do
if bit32.band(node.mode, StrictMode) ~= 0 then
maybeStrictRoot = node
end
node = node.return_
end
return maybeStrictRoot
end
local setToSortedString = function(set): string
local array = {}
for key, value in set do
table.insert(array, key)
end
table.sort(array)
return table.concat(array, ", ")
end
local pendingComponentWillMountWarnings: Array<Fiber> = {}
local pendingUNSAFE_ComponentWillMountWarnings: Array<Fiber> = {}
local pendingComponentWillReceivePropsWarnings: Array<Fiber> = {}
local pendingUNSAFE_ComponentWillReceivePropsWarnings: Array<Fiber> = {}
local pendingComponentWillUpdateWarnings: Array<Fiber> = {}
local pendingUNSAFE_ComponentWillUpdateWarnings: Array<Fiber> = {}
local didWarnAboutUnsafeLifecycles = {}
ReactStrictModeWarnings.recordUnsafeLifecycleWarnings = function(
fiber: Fiber,
instance: any
)
if didWarnAboutUnsafeLifecycles[fiber.type] then
return
end
if
typeof(instance.componentWillMount) == "function"
then
table.insert(pendingComponentWillMountWarnings, fiber)
end
if
bit32.band(fiber.mode, StrictMode) ~= 0
and typeof(instance.UNSAFE_componentWillMount) == "function"
then
table.insert(pendingUNSAFE_ComponentWillMountWarnings, fiber)
end
if
typeof(instance.componentWillReceiveProps) == "function"
then
table.insert(pendingComponentWillReceivePropsWarnings, fiber)
end
if
bit32.band(fiber.mode, StrictMode) ~= 0
and typeof(instance.UNSAFE_componentWillReceiveProps) == "function"
then
table.insert(pendingUNSAFE_ComponentWillReceivePropsWarnings, fiber)
end
if
typeof(instance.componentWillUpdate) == "function"
then
table.insert(pendingComponentWillUpdateWarnings, fiber)
end
if
bit32.band(fiber.mode, StrictMode) ~= 0
and typeof(instance.UNSAFE_componentWillUpdate) == "function"
then
table.insert(pendingUNSAFE_ComponentWillUpdateWarnings, fiber)
end
end
ReactStrictModeWarnings.flushPendingUnsafeLifecycleWarnings = function()
local componentWillMountUniqueNames = {}
if #pendingComponentWillMountWarnings > 0 then
for i, fiber in pendingComponentWillMountWarnings do
componentWillMountUniqueNames[getComponentName(fiber.type) or "Component"] =
true
didWarnAboutUnsafeLifecycles[fiber.type] = true
end
table.clear(pendingComponentWillMountWarnings)
end
local UNSAFE_componentWillMountUniqueNames = {}
if #pendingUNSAFE_ComponentWillMountWarnings > 0 then
for i, fiber in pendingUNSAFE_ComponentWillMountWarnings do
UNSAFE_componentWillMountUniqueNames[getComponentName(fiber.type) or "Component"] =
true
didWarnAboutUnsafeLifecycles[fiber.type] = true
end
table.clear(pendingUNSAFE_ComponentWillMountWarnings)
end
local componentWillReceivePropsUniqueNames = {}
if #pendingComponentWillReceivePropsWarnings > 0 then
for i, fiber in pendingComponentWillReceivePropsWarnings do
componentWillReceivePropsUniqueNames[getComponentName(fiber.type) or "Component"] =
true
didWarnAboutUnsafeLifecycles[fiber.type] = true
end
table.clear(pendingComponentWillReceivePropsWarnings)
end
local UNSAFE_componentWillReceivePropsUniqueNames = {}
if #pendingUNSAFE_ComponentWillReceivePropsWarnings > 0 then
for i, fiber in pendingUNSAFE_ComponentWillReceivePropsWarnings do
UNSAFE_componentWillReceivePropsUniqueNames[getComponentName(fiber.type) or "Component"] =
true
didWarnAboutUnsafeLifecycles[fiber.type] = true
end
table.clear(pendingUNSAFE_ComponentWillReceivePropsWarnings)
end
local componentWillUpdateUniqueNames = {}
if #pendingComponentWillUpdateWarnings > 0 then
for i, fiber in pendingComponentWillUpdateWarnings do
componentWillUpdateUniqueNames[getComponentName(fiber.type) or "Component"] =
true
didWarnAboutUnsafeLifecycles[fiber.type] = true
end
table.clear(pendingComponentWillUpdateWarnings)
end
local UNSAFE_componentWillUpdateUniqueNames = {}
if #pendingUNSAFE_ComponentWillUpdateWarnings > 0 then
for i, fiber in pendingUNSAFE_ComponentWillUpdateWarnings do
UNSAFE_componentWillUpdateUniqueNames[getComponentName(fiber.type) or "Component"] =
true
didWarnAboutUnsafeLifecycles[fiber.type] = true
end
table.clear(pendingUNSAFE_ComponentWillUpdateWarnings)
end
if next(UNSAFE_componentWillMountUniqueNames) ~= nil then
local sortedNames = setToSortedString(UNSAFE_componentWillMountUniqueNames)
console.error(
"Using UNSAFE_componentWillMount in strict mode is not recommended and may indicate bugs in your code. "
.. "See https://reactjs.org/link/unsafe-component-lifecycles for details.\n\n"
.. "* Move code with side effects to componentDidMount, and set initial state in the constructor.\n"
.. "\nPlease update the following components: %s",
sortedNames
)
end
if next(UNSAFE_componentWillReceivePropsUniqueNames) ~= nil then
local sortedNames =
setToSortedString(UNSAFE_componentWillReceivePropsUniqueNames)
console.error(
"Using UNSAFE_componentWillReceiveProps in strict mode is not recommended "
.. "and may indicate bugs in your code. "
.. "See https://reactjs.org/link/unsafe-component-lifecycles for details.\n\n"
.. "* Move data fetching code or side effects to componentDidUpdate.\n"
.. "* If you're updating state whenever props change, "
.. "refactor your code to use memoization techniques or move it to "
.. "static getDerivedStateFromProps. Learn more at: https://reactjs.org/link/derived-state\n"
.. "\nPlease update the following components: %s",
sortedNames
)
end
if next(UNSAFE_componentWillUpdateUniqueNames) ~= nil then
local sortedNames = setToSortedString(UNSAFE_componentWillUpdateUniqueNames)
console.error(
"Using UNSAFE_componentWillUpdate in strict mode is not recommended "
.. "and may indicate bugs in your code. "
.. "See https://reactjs.org/link/unsafe-component-lifecycles for details.\n\n"
.. "* Move data fetching code or side effects to componentDidUpdate.\n"
.. "\nPlease update the following components: %s",
sortedNames
)
end
if next(componentWillMountUniqueNames) ~= nil then
local sortedNames = setToSortedString(componentWillMountUniqueNames)
console.warn(
"componentWillMount has been renamed, and is not recommended for use. "
.. "See https://reactjs.org/link/unsafe-component-lifecycles for details.\n\n"
.. "* Move code with side effects to componentDidMount, and set initial state in the constructor.\n"
.. "* Rename componentWillMount to UNSAFE_componentWillMount to suppress "
.. "this warning in non-strict mode. In React 18.x, only the UNSAFE_ name will work.\n"
.. "\nPlease update the following components: %s",
sortedNames
)
end
if next(componentWillReceivePropsUniqueNames) ~= nil then
local sortedNames = setToSortedString(componentWillReceivePropsUniqueNames)
console.warn(
"componentWillReceiveProps has been renamed, and is not recommended for use. "
.. "See https://reactjs.org/link/unsafe-component-lifecycles for details.\n\n"
.. "* Move data fetching code or side effects to componentDidUpdate.\n"
.. "* If you're updating state whenever props change, refactor your "
.. "code to use memoization techniques or move it to "
.. "static getDerivedStateFromProps. Learn more at: https://reactjs.org/link/derived-state\n"
.. "* Rename componentWillReceiveProps to UNSAFE_componentWillReceiveProps to suppress "
.. "this warning in non-strict mode. In React 18.x, only the UNSAFE_ name will work.\n"
.. "\nPlease update the following components: %s",
sortedNames
)
end
if next(componentWillUpdateUniqueNames) ~= nil then
local sortedNames = setToSortedString(componentWillUpdateUniqueNames)
console.warn(
"componentWillUpdate has been renamed, and is not recommended for use. "
.. "See https://reactjs.org/link/unsafe-component-lifecycles for details.\n\n"
.. "* Move data fetching code or side effects to componentDidUpdate.\n"
.. "* Rename componentWillUpdate to UNSAFE_componentWillUpdate to suppress "
.. "this warning in non-strict mode. In React 18.x, only the UNSAFE_ name will work.\n"
.. "\nPlease update the following components: %s",
sortedNames
)
end
end
local pendingLegacyContextWarning: FiberToFiberComponentsMap = {}
local didWarnAboutLegacyContext = {}
ReactStrictModeWarnings.recordLegacyContextWarning = function(
fiber: Fiber,
instance: any
)
local strictRoot = findStrictRoot(fiber)
if strictRoot == nil then
console.error(
"Expected to find a StrictMode component in a strict mode tree. "
.. "This error is likely caused by a bug in React. Please file an issue."
)
return
end
if didWarnAboutLegacyContext[fiber.type] then
return
end
local warningsForRoot = pendingLegacyContextWarning[strictRoot :: Fiber]
if
typeof(fiber.type) ~= "function"
and (
fiber.type.contextTypes ~= nil
or fiber.type.childContextTypes ~= nil
or (instance ~= nil and typeof(instance.getChildContext) == "function")
)
then
if warningsForRoot == nil then
warningsForRoot = {}
pendingLegacyContextWarning[strictRoot :: Fiber] = warningsForRoot
end
table.insert(warningsForRoot, fiber)
end
end
ReactStrictModeWarnings.flushLegacyContextWarning = function()
for strictRoot, fiberArray in pendingLegacyContextWarning do
if #fiberArray == 0 then
return
end
local firstFiber = fiberArray[1]
local uniqueNames = {}
for i, fiber in fiberArray do
uniqueNames[getComponentName(fiber.type) or "Component"] = true
didWarnAboutLegacyContext[fiber.type] = true
end
local sortedNames = setToSortedString(uniqueNames)
local ok, error_ = pcall(function()
setCurrentDebugFiberInDEV(firstFiber)
console.error(
"Legacy context API has been detected within a strict-mode tree."
.. "\n\nThe old API will be supported in all 16.x releases, but applications "
.. "using it should migrate to the new version."
.. "\n\nPlease update the following components: %s"
.. "\n\nLearn more about this warning here: https://reactjs.org/link/legacy-context",
sortedNames
)
end)
resetCurrentDebugFiberInDEV()
if not ok then
error(error_)
end
end
end
ReactStrictModeWarnings.discardPendingWarnings = function()
table.clear(pendingComponentWillMountWarnings)
table.clear(pendingUNSAFE_ComponentWillMountWarnings)
table.clear(pendingComponentWillReceivePropsWarnings)
table.clear(pendingUNSAFE_ComponentWillReceivePropsWarnings)
table.clear(pendingComponentWillUpdateWarnings)
table.clear(pendingUNSAFE_ComponentWillUpdateWarnings)
table.clear(pendingLegacyContextWarning)
end
end
return ReactStrictModeWarnings
end
end)())
__register("ReactReconciler/ReactTestSelectors", (function()
local script = __makeProxy({"ReactReconciler","ReactTestSelectors"})
return function()
local Packages = script.Parent.Parent
local LuauPolyfill = __require(Packages.LuauPolyfill)
type Set<T> = { [T]: boolean }
type Array<T> = LuauPolyfill.Array<T>
type Function = (...any) -> ...any
type Object = LuauPolyfill.Object
local ReactFiberHostConfig = __require(script.Parent.ReactFiberHostConfig)
local supportsTestSelectors = ReactFiberHostConfig.supportsTestSelectors
local exports = {}
type BoundingRect = {
x: number,
y: number,
width: number,
height: number,
}
local commitHooks: Array<Function> = {}
exports.onCommitRoot = function(): ()
if supportsTestSelectors then
for i, commitHook in commitHooks do
commitHook()
end
end
end
type IntersectionObserverOptions = Object
type ObserveVisibleRectsCallback = (
intersections: Array<{ ratio: number, rect: BoundingRect }>
) -> ()
return exports
end
end)())
__register("ReactReconciler/ReactTypeOfMode", (function()
local script = __makeProxy({"ReactReconciler","ReactTypeOfMode"})
return function()
type TypeOfMode = number
return {
NoMode = 0b00000,
StrictMode = 0b00001,
BlockingMode = 0b00010,
ConcurrentMode = 0b00100,
ProfileMode = 0b01000,
DebugTracingMode = 0b10000,
}
end
end)())
__register("ReactReconciler/ReactUpdateQueue.new", (function()
local script = __makeProxy({"ReactReconciler","ReactUpdateQueue.new"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local LuauPolyfill = __require(Packages.LuauPolyfill)
local Object = LuauPolyfill.Object
local __DEV__ = ReactGlobals.__DEV__
local __YOLO__ = ReactGlobals.__YOLO__
local console = __require(Packages.Shared).console
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
type Lane = ReactInternalTypes.Lane
type Lanes = ReactInternalTypes.Lanes
local ReactFiberLane = __require(script.Parent.ReactFiberLane)
local NoLane = ReactFiberLane.NoLane
local NoLanes = ReactFiberLane.NoLanes
local isSubsetOfLanes = ReactFiberLane.isSubsetOfLanes
local mergeLanes = ReactFiberLane.mergeLanes
local ReactFiberNewContext
local function enterDisallowedContextReadInDEV()
if not ReactFiberNewContext then
ReactFiberNewContext = __require(script.Parent["ReactFiberNewContext.new"]) :: any
end
ReactFiberNewContext.enterDisallowedContextReadInDEV()
end
local function exitDisallowedContextReadInDEV()
if not ReactFiberNewContext then
ReactFiberNewContext = __require(script.Parent["ReactFiberNewContext.new"]) :: any
end
ReactFiberNewContext.exitDisallowedContextReadInDEV()
end
local ReactFiberFlags = __require(script.Parent.ReactFiberFlags)
local Callback = ReactFiberFlags.Callback
local ShouldCapture = ReactFiberFlags.ShouldCapture
local DidCapture = ReactFiberFlags.DidCapture
local ReactFeatureFlags = __require(Packages.Shared).ReactFeatureFlags
local debugRenderPhaseSideEffectsForStrictMode =
ReactFeatureFlags.debugRenderPhaseSideEffectsForStrictMode
local ReactTypeOfMode = __require(script.Parent.ReactTypeOfMode)
local StrictMode = ReactTypeOfMode.StrictMode
local markSkippedUpdateLanes =
__require(script.Parent.ReactFiberWorkInProgress).markSkippedUpdateLanes
local describeError = __require(Packages.Shared).describeError
local ConsolePatchingDev = __require(Packages.Shared).ConsolePatchingDev
local disableLogs = ConsolePatchingDev.disableLogs
local reenableLogs = ConsolePatchingDev.reenableLogs
type Array<T> = { [number]: T }
type Update<T> = ReactInternalTypes.Update<T>
type UpdateQueue<T> = ReactInternalTypes.UpdateQueue<T>
type SharedQueue<T> = ReactInternalTypes.SharedQueue<T>
local exports = {}
local UpdateState = 0
exports.UpdateState = UpdateState
local ReplaceState = 1
exports.ReplaceState = ReplaceState
local ForceUpdate = 2
exports.ForceUpdate = ForceUpdate
local CaptureUpdate = 3
exports.CaptureUpdate = CaptureUpdate
local hasForceUpdate = false
local didWarnUpdateInsideUpdate
local currentlyProcessingQueue: SharedQueue<any>?
if __DEV__ then
didWarnUpdateInsideUpdate = false
currentlyProcessingQueue = nil
exports.resetCurrentlyProcessingQueue = function()
currentlyProcessingQueue = nil
end
end
local poolInitSize = 210
local updatePool = table.create(poolInitSize)
local updatePoolIndex = poolInitSize
for i = 1, poolInitSize do
updatePool[i] = {
eventTime = -1,
lane = -1,
tag = -1,
payload = nil,
callback = nil,
next = nil,
}
end
local function initializeUpdateQueue<State>(fiber: Fiber): ()
local queue: UpdateQueue<State> = {
baseState = fiber.memoizedState,
firstBaseUpdate = nil,
lastBaseUpdate = nil,
shared = {
pending = nil,
},
effects = nil,
}
fiber.updateQueue = queue
end
exports.initializeUpdateQueue = initializeUpdateQueue
local function cloneUpdateQueue<State>(current: Fiber, workInProgress: Fiber): ()
local queue: UpdateQueue<State> = workInProgress.updateQueue :: any
local currentQueue: UpdateQueue<State> = current.updateQueue :: any
if queue == currentQueue then
local clone: UpdateQueue<State> = table.clone(currentQueue)
workInProgress.updateQueue = clone
end
end
exports.cloneUpdateQueue = cloneUpdateQueue
local function createUpdate(
eventTime: number,
lane: Lane,
payload: any?,
callback: (() -> ...any)?
): Update<any>
if updatePoolIndex > 0 then
local update = updatePool[updatePoolIndex]
updatePool[updatePoolIndex] = nil
updatePoolIndex -= 1
update.eventTime = eventTime
update.lane = lane
update.tag = UpdateState
update.payload = payload
update.callback = callback :: any
return update :: Update<any>
end
local update = {
eventTime = eventTime,
lane = lane,
tag = UpdateState,
payload = payload,
callback = callback :: any,
next = nil,
}
return update :: Update<any>
end
exports.createUpdate = createUpdate
local function enqueueUpdate<State>(fiber: Fiber, update: Update<State>)
local updateQueue = fiber.updateQueue
if updateQueue == nil then
return
end
local sharedQueue: SharedQueue<State> = (updateQueue :: any).shared
local pending = sharedQueue.pending
if pending == nil then
update.next = update
else
update.next = pending.next
pending.next = update
end
sharedQueue.pending = update
if __DEV__ then
if currentlyProcessingQueue == sharedQueue and not didWarnUpdateInsideUpdate then
console.error(
"An update (setState, replaceState, or forceUpdate) was scheduled "
.. "from inside an update function. Update functions should be pure, "
.. "with zero side-effects. Consider using componentDidUpdate or a "
.. "callback."
)
didWarnUpdateInsideUpdate = true
end
end
end
exports.enqueueUpdate = enqueueUpdate
local function enqueueCapturedUpdate<State>(workInProgress: Fiber, capturedUpdate: Update<State>)
local queue: UpdateQueue<State> = workInProgress.updateQueue :: any
local current = workInProgress.alternate
if current ~= nil then
local currentQueue: UpdateQueue<State> = current.updateQueue :: any
if queue == currentQueue then
local newFirst = nil
local newLast = nil
local firstBaseUpdate = queue.firstBaseUpdate
if firstBaseUpdate ~= nil then
local update = firstBaseUpdate
repeat
local clone: Update<State> = {
eventTime = update.eventTime,
lane = update.lane,
tag = update.tag,
payload = update.payload,
callback = update.callback,
next = nil,
}
if newLast == nil then
newLast = clone
newFirst = clone
else
newLast.next = clone
newLast = clone
end
update = update.next :: Update<State>
until update == nil
if newLast == nil then
newLast = capturedUpdate
newFirst = capturedUpdate
else
newLast.next = capturedUpdate
newLast = capturedUpdate
end
else
newLast = capturedUpdate
newFirst = capturedUpdate
end
queue = {
baseState = currentQueue.baseState,
firstBaseUpdate = newFirst,
lastBaseUpdate = newLast,
shared = currentQueue.shared,
effects = currentQueue.effects,
}
workInProgress.updateQueue = queue
return
end
end
local lastBaseUpdate = queue.lastBaseUpdate
if lastBaseUpdate == nil then
queue.firstBaseUpdate = capturedUpdate
else
lastBaseUpdate.next = capturedUpdate
end
queue.lastBaseUpdate = capturedUpdate
end
exports.enqueueCapturedUpdate = enqueueCapturedUpdate
local function getStateFromUpdate<State>(
workInProgress: Fiber,
queue: UpdateQueue<State>,
update: Update<State>,
prevState: State,
nextProps: any,
instance: any
): any
local updateTag = update.tag
if updateTag == ReplaceState then
local payload = update.payload
if type(payload) == "function" then
if __DEV__ then
enterDisallowedContextReadInDEV()
end
local nextState = payload(prevState, nextProps)
if __DEV__ then
if
debugRenderPhaseSideEffectsForStrictMode
and bit32.band(workInProgress.mode, StrictMode) ~= 0
then
disableLogs()
local ok, result
if not __YOLO__ then
ok, result = xpcall(payload, describeError, prevState, nextProps)
else
ok = true
payload(prevState, nextProps)
end
reenableLogs()
if not ok then
error(result)
end
end
exitDisallowedContextReadInDEV()
end
return nextState
end
return payload
elseif updateTag == CaptureUpdate or updateTag == UpdateState then
if updateTag == CaptureUpdate then
workInProgress.flags = bit32.bor(
bit32.band(workInProgress.flags, bit32.bnot(ShouldCapture)),
DidCapture
)
end
local payload = update.payload
local partialState
if type(payload) == "function" then
if __DEV__ then
enterDisallowedContextReadInDEV()
end
partialState = payload(prevState, nextProps)
if __DEV__ then
if
debugRenderPhaseSideEffectsForStrictMode
and bit32.band(workInProgress.mode, StrictMode) ~= 0
then
disableLogs()
local ok, result
if not __YOLO__ then
ok, result = xpcall(payload, describeError, prevState, nextProps)
else
ok = true
payload(prevState, nextProps)
end
reenableLogs()
if not ok then
error(result)
end
end
exitDisallowedContextReadInDEV()
end
else
partialState = payload
end
if partialState == nil then
return prevState
end
return Object.assign({}, prevState, partialState)
elseif updateTag == ForceUpdate then
hasForceUpdate = true
return prevState
end
return prevState
end
exports.getStateFromUpdate = getStateFromUpdate
local function processUpdateQueue<State>(
workInProgress: Fiber,
props: any,
instance: any,
renderLanes: Lanes
): ()
local queue: UpdateQueue<State> = workInProgress.updateQueue :: any
hasForceUpdate = false
if __DEV__ then
currentlyProcessingQueue = queue.shared
end
local firstBaseUpdate = queue.firstBaseUpdate
local lastBaseUpdate = queue.lastBaseUpdate
local pendingQueue = queue.shared.pending
if pendingQueue ~= nil then
queue.shared.pending = nil
local lastPendingUpdate = pendingQueue
local firstPendingUpdate = lastPendingUpdate.next
lastPendingUpdate.next = nil
if lastBaseUpdate == nil then
firstBaseUpdate = firstPendingUpdate
else
lastBaseUpdate.next = firstPendingUpdate
end
lastBaseUpdate = lastPendingUpdate
local current = workInProgress.alternate
if current ~= nil then
local currentQueue: UpdateQueue<State> = current.updateQueue :: any
local currentLastBaseUpdate = currentQueue.lastBaseUpdate
if currentLastBaseUpdate ~= lastBaseUpdate then
if currentLastBaseUpdate == nil then
currentQueue.firstBaseUpdate = firstPendingUpdate
else
currentLastBaseUpdate.next = firstPendingUpdate
end
currentQueue.lastBaseUpdate = lastPendingUpdate
end
end
end
if firstBaseUpdate ~= nil then
local newState = queue.baseState
local newLanes = NoLanes
local newBaseState = nil
local newFirstBaseUpdate = nil
local newLastBaseUpdate = nil
local update = firstBaseUpdate
while true do
local updateLane = update.lane
local updateEventTime = update.eventTime
if not isSubsetOfLanes(renderLanes, updateLane) then
local clone: Update<State> = {
eventTime = updateEventTime,
lane = updateLane,
tag = update.tag,
payload = update.payload,
callback = update.callback,
next = nil,
}
if newLastBaseUpdate == nil then
newFirstBaseUpdate = clone
newLastBaseUpdate = clone
newBaseState = newState
else
newLastBaseUpdate.next = clone
newLastBaseUpdate = clone
end
newLanes = mergeLanes(newLanes, updateLane)
else
if newLastBaseUpdate ~= nil then
local clone: Update<State> = {
eventTime = updateEventTime,
lane = NoLane,
tag = update.tag,
payload = update.payload,
callback = update.callback,
next = nil,
}
newLastBaseUpdate.next = clone
newLastBaseUpdate = clone
end
newState = getStateFromUpdate(
workInProgress,
queue,
update,
newState,
props,
instance
)
local callback = update.callback
if
callback ~= nil
and update.lane ~= NoLane
then
workInProgress.flags = bit32.bor(workInProgress.flags, Callback)
local effects = queue.effects
if effects == nil then
queue.effects = { update }
else
table.insert(effects, update)
end
end
end
update = update.next :: Update<State>
if update == nil then
pendingQueue = queue.shared.pending
if pendingQueue == nil then
break
else
local lastPendingUpdate = pendingQueue
local firstPendingUpdate = (
lastPendingUpdate.next :: any
) :: Update<State>
lastPendingUpdate.next = nil
update = firstPendingUpdate
queue.lastBaseUpdate = lastPendingUpdate
queue.shared.pending = nil
end
end
end
if newLastBaseUpdate == nil then
newBaseState = newState
end
queue.baseState = (newBaseState :: any) :: State
queue.firstBaseUpdate = newFirstBaseUpdate
queue.lastBaseUpdate = newLastBaseUpdate
markSkippedUpdateLanes(newLanes)
workInProgress.lanes = newLanes
workInProgress.memoizedState = newState
end
if __DEV__ then
currentlyProcessingQueue = nil
end
end
exports.processUpdateQueue = processUpdateQueue
local function callCallback(callback, context)
if type(callback) ~= "function" then
error(
string.format(
"Invalid argument passed as callback. Expected a function. Instead "
.. "received: %s",
tostring(callback)
)
)
end
callback(context)
end
exports.resetHasForceUpdateBeforeProcessing = function()
hasForceUpdate = false
end
exports.checkHasForceUpdateAfterProcessing = function(): boolean
return hasForceUpdate
end
local function commitUpdateQueue<State>(
finishedWork: Fiber,
finishedQueue: UpdateQueue<State>,
instance: any
): ()
local effects = finishedQueue.effects
finishedQueue.effects = nil
if effects ~= nil then
for _, effect in effects do
local callback = effect.callback
if callback ~= nil then
callCallback(callback, instance)
end
table.clear(effect)
table.insert(updatePool, effect :: any)
updatePoolIndex += 1
end
end
end
exports.commitUpdateQueue = commitUpdateQueue
return exports
end
end)())
__register("ReactReconciler/ReactWorkTags", (function()
local script = __makeProxy({"ReactReconciler","ReactWorkTags"})
return function()
type WorkTag = number
return {
FunctionComponent = 0,
ClassComponent = 1,
IndeterminateComponent = 2,
HostRoot = 3,
HostPortal = 4,
HostComponent = 5,
HostText = 6,
Fragment = 7,
Mode = 8,
ContextConsumer = 9,
ContextProvider = 10,
ForwardRef = 11,
Profiler = 12,
SuspenseComponent = 13,
MemoComponent = 14,
SimpleMemoComponent = 15,
LazyComponent = 16,
IncompleteClassComponent = 17,
DehydratedFragment = 18,
SuspenseListComponent = 19,
FundamentalComponent = 20,
ScopeComponent = 21,
Block = 22,
OffscreenComponent = 23,
LegacyHiddenComponent = 24,
}
end
end)())
__register("ReactReconciler/RobloxReactProfiling", (function()
local script = __makeProxy({"ReactReconciler","RobloxReactProfiling"})
return function()
local Packages = script.Parent.Parent
local getComponentName = __require(Packages.Shared).getComponentName
local ReactWorkTags = __require(script.Parent.ReactWorkTags)
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
type FiberRoot = ReactInternalTypes.FiberRoot
local LEVEL_ROOTS_LOG_ONLY = 1
local LEVEL_ROOTS = 5
local LEVEL_FIBERS = 10
local loadedFlag, ReactMicroprofilerLevel = pcall(function()
return game:DefineFastInt("ReactMicroprofilerLevel5", 0)
end)
if not loadedFlag then
ReactMicroprofilerLevel = 0
end
type Marker = {
id: string,
startTime: number,
endTime: number,
}
type SamplerCallback = (Marker) -> ()
function noop(...: unknown) end
local enableRootSampling = false
local timerSamplingCallback: SamplerCallback | nil = nil
local numActiveProfilesInFrame = 0
if ReactMicroprofilerLevel >= LEVEL_ROOTS then
game:GetService("RunService").Heartbeat:Connect(function()
numActiveProfilesInFrame = 0
end)
end
local microprofiler = if ReactMicroprofilerLevel >= LEVEL_ROOTS
then {
profilebegin = function(...)
debug.profilebegin(...)
numActiveProfilesInFrame += 1
end,
profileend = function()
if numActiveProfilesInFrame > 0 then
debug.profileend()
numActiveProfilesInFrame -= 1
end
end,
}
else {
profilebegin = noop,
profileend = noop,
}
function startTimerSampling(timerSamplingCallbackFn: SamplerCallback)
if enableRootSampling then
warn("RobloxReactProfiling Timer Sampling already running.")
end
enableRootSampling = true
timerSamplingCallback = timerSamplingCallbackFn
end
function endTimerSampling()
enableRootSampling = false
timerSamplingCallback = nil
end
function getFirstStringKey(t: { any: any })
for key, _ in t do
if type(key) == "string" then
return key
end
end
return nil
end
function startTimer(marker: Marker)
if enableRootSampling then
marker.startTime = os.clock()
end
end
function endTimer(marker: Marker)
if enableRootSampling then
marker.endTime = os.clock()
if timerSamplingCallback then
timerSamplingCallback(marker)
end
end
end
function profileRootBeforeUnitOfWork(root: FiberRoot): Marker?
local rootFiber = root.current
local profileId = nil
if rootFiber then
if rootFiber.memoizedProps then
profileId = getFirstStringKey(rootFiber.memoizedProps)
end
if
profileId == nil
and rootFiber.stateNode
and rootFiber.stateNode.containerInfo
then
profileId = rootFiber.stateNode.containerInfo.Name
end
end
if profileId == "Folder" and rootFiber.child then
local fiber = rootFiber.child
local folderProfileId = nil
if fiber.memoizedProps then
folderProfileId = getFirstStringKey(fiber.memoizedProps)
end
if
folderProfileId == nil
and fiber.stateNode
and fiber.stateNode.containerInfo
then
folderProfileId = fiber.stateNode.containerInfo.Name
end
if folderProfileId ~= nil then
profileId = folderProfileId
end
end
if profileId ~= nil then
local marker = {
id = profileId,
startTime = 0,
endTime = 0,
}
startTimer(marker)
microprofiler.profilebegin(profileId)
return marker
end
return nil
end
function profileRootAfterYielding(marker: Marker?)
if marker then
endTimer(marker)
microprofiler.profileend()
end
end
function profileUnitOfWorkBefore(unitOfWork: Fiber)
local profileId = getComponentName(unitOfWork.type)
if unitOfWork.key then
profileId = tostring(unitOfWork.key) .. "=" .. (profileId or "?")
end
local rootName = nil
if unitOfWork.stateNode then
if
unitOfWork.tag == ReactWorkTags.HostComponent
or unitOfWork.tag == ReactWorkTags.HostText
then
local layerCollector =
unitOfWork.stateNode:FindFirstAncestorWhichIsA("LayerCollector")
if layerCollector then
rootName = "[" .. layerCollector:GetFullName() .. "] "
end
end
end
if rootName then
profileId = rootName .. " : " .. (profileId or "?")
end
if profileId ~= nil then
microprofiler.profilebegin(profileId)
return true
end
return false
end
function profileUnitOfWorkAfter(profileRunning: boolean)
if profileRunning then
microprofiler.profileend()
end
end
function profileCommitBefore()
microprofiler.profilebegin("Commit")
end
function profileCommitAfter()
microprofiler.profileend()
end
return {
startTimerSampling = startTimerSampling,
endTimerSampling = endTimerSampling,
profileRootBeforeUnitOfWork = if ReactMicroprofilerLevel >= LEVEL_ROOTS_LOG_ONLY
then profileRootBeforeUnitOfWork
else noop,
profileRootAfterYielding = if ReactMicroprofilerLevel >= LEVEL_ROOTS_LOG_ONLY
then profileRootAfterYielding
else noop,
profileUnitOfWorkBefore = if ReactMicroprofilerLevel >= LEVEL_FIBERS
then profileUnitOfWorkBefore
else noop,
profileUnitOfWorkAfter = if ReactMicroprofilerLevel >= LEVEL_FIBERS
then profileUnitOfWorkAfter
else noop,
profileCommitBefore = if ReactMicroprofilerLevel >= LEVEL_ROOTS
then profileCommitBefore
else noop,
profileCommitAfter = if ReactMicroprofilerLevel >= LEVEL_ROOTS
then profileCommitAfter
else noop,
}
end
end)())
__register("ReactReconciler/SchedulerWithReactIntegration.new", (function()
local script = __makeProxy({"ReactReconciler","SchedulerWithReactIntegration.new"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local LuauPolyfill = __require(Packages.LuauPolyfill)
local Array = LuauPolyfill.Array
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type ReactPriorityLevel = ReactInternalTypes.ReactPriorityLevel
local Scheduler = __require(Packages.Scheduler)
local ReactFeatureFlags = __require(Packages.Shared).ReactFeatureFlags
local decoupleUpdatePriorityFromScheduler =
ReactFeatureFlags.decoupleUpdatePriorityFromScheduler
local invariant = __require(Packages.Shared).invariant
local describeError = __require(Packages.Shared).describeError
local ReactFiberLane = __require(script.Parent.ReactFiberLane)
local SyncLanePriority = ReactFiberLane.SyncLanePriority
local getCurrentUpdateLanePriority = ReactFiberLane.getCurrentUpdateLanePriority
local setCurrentUpdateLanePriority = ReactFiberLane.setCurrentUpdateLanePriority
local Scheduler_runWithPriority = Scheduler.unstable_runWithPriority
local Scheduler_scheduleCallback = Scheduler.unstable_scheduleCallback
local Scheduler_cancelCallback = Scheduler.unstable_cancelCallback
local Scheduler_shouldYield = Scheduler.unstable_shouldYield
local Scheduler_requestPaint = Scheduler.unstable_requestPaint
local Scheduler_now = Scheduler.unstable_now
local Scheduler_getCurrentPriorityLevel = Scheduler.unstable_getCurrentPriorityLevel
local Scheduler_ImmediatePriority = Scheduler.unstable_ImmediatePriority
local Scheduler_UserBlockingPriority = Scheduler.unstable_UserBlockingPriority
local Scheduler_NormalPriority = Scheduler.unstable_NormalPriority
local Scheduler_LowPriority = Scheduler.unstable_LowPriority
local Scheduler_IdlePriority = Scheduler.unstable_IdlePriority
local ReactFiberSchedulerPriorities =
__require(script.Parent["ReactFiberSchedulerPriorities.roblox"])
local ImmediatePriority = ReactFiberSchedulerPriorities.ImmediatePriority
local UserBlockingPriority = ReactFiberSchedulerPriorities.UserBlockingPriority
local NormalPriority = ReactFiberSchedulerPriorities.NormalPriority
local LowPriority = ReactFiberSchedulerPriorities.LowPriority
local IdlePriority = ReactFiberSchedulerPriorities.IdlePriority
local NoPriority = ReactFiberSchedulerPriorities.NoPriority
type Array<T> = { [number]: T }
local flushSyncCallbackQueueImpl
type SchedulerCallback = (isSync: boolean) -> SchedulerCallback | nil
type SchedulerCallbackOptions = { timeout: number? }
local fakeCallbackNode = {}
local shouldYield = Scheduler_shouldYield
local requestPaint
if Scheduler_requestPaint ~= nil then
requestPaint = Scheduler_requestPaint
else
requestPaint = function() end
end
local syncQueue: Array<SchedulerCallback>? = nil
local immediateQueueCallbackNode: any? = nil
local isFlushingSyncQueue: boolean = false
local initialTimeMs: number = Scheduler_now()
local function now(): number
return Scheduler_now() - initialTimeMs
end
local function getCurrentPriorityLevel(): ReactPriorityLevel
local currentPriorityLevel = Scheduler_getCurrentPriorityLevel()
if currentPriorityLevel == Scheduler_ImmediatePriority then
return ImmediatePriority
elseif currentPriorityLevel == Scheduler_UserBlockingPriority then
return UserBlockingPriority
elseif currentPriorityLevel == Scheduler_NormalPriority then
return NormalPriority
elseif currentPriorityLevel == Scheduler_LowPriority then
return LowPriority
elseif currentPriorityLevel == Scheduler_IdlePriority then
return IdlePriority
else
invariant(false, "Unknown priority level.")
return NoPriority
end
end
function reactPriorityToSchedulerPriority(reactPriorityLevel)
if reactPriorityLevel == ImmediatePriority then
return Scheduler_ImmediatePriority
elseif reactPriorityLevel == UserBlockingPriority then
return Scheduler_UserBlockingPriority
elseif reactPriorityLevel == NormalPriority then
return Scheduler_NormalPriority
elseif reactPriorityLevel == LowPriority then
return Scheduler_LowPriority
elseif reactPriorityLevel == IdlePriority then
return Scheduler_IdlePriority
else
invariant(false, "Unknown priority level.")
return nil
end
end
local function runWithPriority<T...>(
reactPriorityLevel: ReactPriorityLevel,
fn: () -> T...
): ...any
local priorityLevel = reactPriorityToSchedulerPriority(reactPriorityLevel)
return Scheduler_runWithPriority(priorityLevel, fn)
end
local function scheduleCallback(
reactPriorityLevel: ReactPriorityLevel,
callback: SchedulerCallback,
options: SchedulerCallbackOptions | nil
)
local priorityLevel = reactPriorityToSchedulerPriority(reactPriorityLevel)
return Scheduler_scheduleCallback(priorityLevel, callback, options)
end
local function scheduleSyncCallback(callback: SchedulerCallback)
if syncQueue == nil then
syncQueue = { callback }
immediateQueueCallbackNode = Scheduler_scheduleCallback(
Scheduler_ImmediatePriority,
flushSyncCallbackQueueImpl
)
else
local coercedSyncQueue = syncQueue
table.insert(coercedSyncQueue, callback)
end
return fakeCallbackNode
end
local function cancelCallback(callbackNode: any)
if callbackNode ~= fakeCallbackNode then
Scheduler_cancelCallback(callbackNode)
end
end
local function flushSyncCallbackQueue(): boolean
if immediateQueueCallbackNode ~= nil then
local node = immediateQueueCallbackNode
immediateQueueCallbackNode = nil
Scheduler_cancelCallback(node)
end
return flushSyncCallbackQueueImpl()
end
flushSyncCallbackQueueImpl = function()
if not isFlushingSyncQueue and syncQueue ~= nil then
isFlushingSyncQueue = true
local i = 1
if decoupleUpdatePriorityFromScheduler then
local previousLanePriority = getCurrentUpdateLanePriority()
local ok = true
local result
if not ReactGlobals.__YOLO__ then
local isSync = true
local queue = syncQueue
setCurrentUpdateLanePriority(SyncLanePriority)
ok, result = xpcall(
runWithPriority,
describeError,
ImmediatePriority,
function(): ...any
for index, callback in queue do
i = index
repeat
callback = callback(isSync) :: any
until callback == nil
end
end
)
syncQueue = nil
else
ok = true
local isSync = true
local queue = syncQueue
setCurrentUpdateLanePriority(SyncLanePriority)
runWithPriority(ImmediatePriority, function(): ...any
for index, callback in queue do
i = index
repeat
callback = callback(isSync) :: any
until callback == nil
i += 1
end
end)
syncQueue = nil
end
setCurrentUpdateLanePriority(previousLanePriority)
isFlushingSyncQueue = false
if not ok then
if syncQueue ~= nil then
syncQueue = Array.slice(syncQueue, i + 1)
end
Scheduler_scheduleCallback(
Scheduler_ImmediatePriority,
flushSyncCallbackQueue
)
error(result)
end
else
local ok, result
if not ReactGlobals.__YOLO__ then
local isSync = true
local queue = syncQueue
ok, result = xpcall(
runWithPriority,
describeError,
ImmediatePriority,
function(): ...any
for index, callback in queue do
i = index
repeat
callback = callback(isSync) :: any
until callback == nil
end
end
)
syncQueue = nil
else
ok = true
local isSync = true
local queue = syncQueue
runWithPriority(ImmediatePriority, function(): ...any
for index, callback in queue do
i = index
repeat
callback = callback(isSync) :: any
until callback == nil
end
end)
syncQueue = nil
end
isFlushingSyncQueue = false
if not ok then
if syncQueue ~= nil then
syncQueue = Array.slice(syncQueue, i + 1)
end
Scheduler_scheduleCallback(
Scheduler_ImmediatePriority,
flushSyncCallbackQueue
)
error(result)
end
end
return true
else
return false
end
end
return {
ImmediatePriority = ImmediatePriority,
UserBlockingPriority = UserBlockingPriority,
NormalPriority = NormalPriority,
LowPriority = LowPriority,
IdlePriority = IdlePriority,
NoPriority = NoPriority,
getCurrentPriorityLevel = getCurrentPriorityLevel,
flushSyncCallbackQueue = flushSyncCallbackQueue,
runWithPriority = runWithPriority,
scheduleCallback = scheduleCallback,
scheduleSyncCallback = scheduleSyncCallback,
cancelCallback = cancelCallback,
now = now,
requestPaint = requestPaint,
shouldYield = shouldYield,
}
end
end)())
__register("ReactReconciler/SchedulingProfiler", (function()
local script = __makeProxy({"ReactReconciler","SchedulingProfiler"})
return function()
local exports = {}
local Packages = script.Parent.Parent
local LuauPolyfill = __require(Packages.LuauPolyfill)
local WeakMap = LuauPolyfill.WeakMap
type WeakMap<K, V> = LuauPolyfill.WeakMap<K, V>
local ReactFiberLane = __require(script.Parent.ReactFiberLane)
type Lane = ReactFiberLane.Lane
type Lanes = ReactFiberLane.Lanes
local ReactInternalTypes = __require(script.Parent.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber
type FiberRoot = ReactInternalTypes.FiberRoot
local ReactTypes = __require(Packages.Shared)
type Wakeable = ReactTypes.Wakeable
local ReactFeatureFlags = __require(Packages.Shared).ReactFeatureFlags
local enableSchedulingProfiler = ReactFeatureFlags.enableSchedulingProfiler
local ReactVersion = __require(Packages.Shared).ReactVersion
local getComponentName = __require(Packages.Shared).getComponentName
local supportsUserTiming = _G.performance ~= nil
local performance = _G.performance
or {
mark = function(str)
debug.profilebegin(str)
debug.profileend()
end,
}
function formatLanes(laneOrLanes: Lane | Lanes): string
return tostring(laneOrLanes)
end
type ProfilerEvent = number
type ProfilerEventCallback = (type: ProfilerEvent, root: FiberRoot?) -> ()
local profilerEventCallback: ProfilerEventCallback? = nil
local profilerEventTypes = {
CommitStart = 0,
CommitStop = 1,
LayoutEffectsStart = 2,
LayoutEffectsStop = 3,
PassiveEffectsStart = 4,
PassiveEffectsStop = 5,
RenderStart = 6,
RenderYield = 7,
RenderStop = 8,
} :: { [string]: ProfilerEvent }
if enableSchedulingProfiler then
if supportsUserTiming then
performance.mark("--react-init-" .. tostring(ReactVersion))
end
end
exports.markCommitStarted = function(lanes: Lanes): ()
if enableSchedulingProfiler then
if supportsUserTiming then
performance.mark("--commit-start-" .. formatLanes(lanes))
end
if profilerEventCallback then
profilerEventCallback(profilerEventTypes.CommitStart)
end
end
end
exports.markCommitStopped = function(root: FiberRoot): ()
if enableSchedulingProfiler then
if supportsUserTiming then
performance.mark("--commit-stop")
end
if profilerEventCallback then
profilerEventCallback(profilerEventTypes.CommitStop, root)
end
end
end
local wakeableIDs: WeakMap<Wakeable, number> = WeakMap.new()
local wakeableID: number = 0
function getWakeableID(wakeable: Wakeable): number
if not wakeableIDs:has(wakeable) then
wakeableIDs:set(wakeable, wakeableID)
wakeableID += 1
end
return wakeableIDs:get(wakeable)
end
exports.markComponentSuspended = function(fiber: Fiber, wakeable: Wakeable): ()
if enableSchedulingProfiler then
if supportsUserTiming then
local id = getWakeableID(wakeable)
local componentName = getComponentName(fiber.type) or "Unknown"
performance.mark(
"--suspense-suspend-" .. tostring(id) .. "-" .. componentName
)
wakeable:andThen(function()
performance.mark(
"--suspense-resolved-" .. tostring(id) .. "-" .. componentName
)
end, function()
performance.mark(
"--suspense-rejected-" .. tostring(id) .. "-" .. componentName
)
end)
end
end
end
exports.markLayoutEffectsStarted = function(lanes: Lanes): ()
if enableSchedulingProfiler then
if supportsUserTiming then
performance.mark("--layout-effects-start-" .. formatLanes(lanes))
end
if profilerEventCallback then
profilerEventCallback(profilerEventTypes.LayoutEffectsStart)
end
end
end
exports.markLayoutEffectsStopped = function(): ()
if enableSchedulingProfiler then
if supportsUserTiming then
performance.mark("--layout-effects-stop")
end
if profilerEventCallback then
profilerEventCallback(profilerEventTypes.LayoutEffectsStop)
end
end
end
exports.markPassiveEffectsStarted = function(lanes: Lanes): ()
if enableSchedulingProfiler then
if supportsUserTiming then
performance.mark("--passive-effects-start-" .. formatLanes(lanes))
end
if profilerEventCallback then
profilerEventCallback(profilerEventTypes.PassiveEffectsStart)
end
end
end
exports.markPassiveEffectsStopped = function(root: FiberRoot): ()
if enableSchedulingProfiler then
if supportsUserTiming then
performance.mark("--passive-effects-stop")
end
if profilerEventCallback then
profilerEventCallback(profilerEventTypes.PassiveEffectsStop, root)
end
end
end
exports.markRenderStarted = function(lanes: Lanes): ()
if enableSchedulingProfiler then
if supportsUserTiming then
performance.mark("--render-start-" .. formatLanes(lanes))
end
if profilerEventCallback then
profilerEventCallback(profilerEventTypes.RenderStart)
end
end
end
exports.markRenderYielded = function(): ()
if enableSchedulingProfiler then
if supportsUserTiming then
performance.mark("--render-yield")
end
if profilerEventCallback then
profilerEventCallback(profilerEventTypes.RenderYield)
end
end
end
exports.markRenderStopped = function(): ()
if enableSchedulingProfiler then
if supportsUserTiming then
performance.mark("--render-stop")
end
if profilerEventCallback then
profilerEventCallback(profilerEventTypes.RenderStop)
end
end
end
exports.markRenderScheduled = function(lane: Lane): ()
if enableSchedulingProfiler then
if supportsUserTiming then
performance.mark("--schedule-render-" .. formatLanes(lane))
end
end
end
exports.markForceUpdateScheduled = function(fiber: Fiber, lane: Lane): ()
if enableSchedulingProfiler then
if supportsUserTiming then
local componentName = getComponentName(fiber.type) or "Unknown"
performance.mark(
"--schedule-forced-update-" .. formatLanes(lane) .. "-" .. componentName
)
end
end
end
exports.markStateUpdateScheduled = function(fiber: Fiber, lane: Lane): ()
if enableSchedulingProfiler then
if supportsUserTiming then
local componentName = getComponentName(fiber.type) or "Unknown"
performance.mark(
"--schedule-state-update-" .. formatLanes(lane) .. "-" .. componentName
)
end
end
end
exports.profilerEventTypes = profilerEventTypes
exports.registerProfilerEventCallback = function(callback: ProfilerEventCallback)
if profilerEventCallback then
warn("SchedulingProfiler: Another event callback was already registered.")
end
profilerEventCallback = callback
end
return exports
end
end)())
__register("ReactRoblox/client/ReactRoblox", (function()
local script = __makeProxy({"ReactRoblox","client","ReactRoblox"})
return function()
local Packages = script.Parent.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local ReactTypes = __require(Packages.Shared)
type ReactNodeList = ReactTypes.ReactNodeList
local ReactRobloxHostTypes = __require(script.Parent["ReactRobloxHostTypes.roblox"])
type Container = ReactRobloxHostTypes.Container
local ReactRobloxRoot
ReactRobloxRoot = __require(script.Parent.ReactRobloxRoot)
local createRoot = ReactRobloxRoot.createRoot
local createBlockingRoot = ReactRobloxRoot.createBlockingRoot
local createLegacyRoot = ReactRobloxRoot.createLegacyRoot
local isValidContainer = ReactRobloxRoot.isValidContainer
local ReactReconciler = __require(script.Parent.Parent["ReactReconciler.roblox"])
local batchedUpdates = ReactReconciler.batchedUpdates
local flushSync = ReactReconciler.flushSync
local injectIntoDevTools = ReactReconciler.injectIntoDevTools
local flushPassiveEffects = ReactReconciler.flushPassiveEffects
local IsThisRendererActing = ReactReconciler.IsThisRendererActing
local createPortalImpl = ReactReconciler.createPortal
local ReactVersion = __require(Packages.Shared).ReactVersion
local invariant = __require(Packages.Shared).invariant
local ReactFeatureFlags = __require(Packages.Shared).ReactFeatureFlags
local enableNewReconciler = ReactFeatureFlags.enableNewReconciler
local ReactRobloxComponentTree = __require(script.Parent.ReactRobloxComponentTree)
local getInstanceFromNode = ReactRobloxComponentTree.getInstanceFromNode
local getNodeFromInstance = ReactRobloxComponentTree.getNodeFromInstance
local getFiberCurrentPropsFromNode = ReactRobloxComponentTree.getFiberCurrentPropsFromNode
local getClosestInstanceFromNode = ReactRobloxComponentTree.getClosestInstanceFromNode
local Event = __require(Packages.Shared).Event
local Change = __require(Packages.Shared).Change
local Tag = __require(Packages.Shared).Tag
local function createPortal(
children: ReactNodeList,
container: Container,
key: string?
): any
invariant(
isValidContainer(container),
"Target container is not a Roblox Instance."
)
return createPortalImpl(children, container, nil, key)
end
local Internals = {
Events = {
getInstanceFromNode = getInstanceFromNode,
getNodeFromInstance = getNodeFromInstance,
getFiberCurrentPropsFromNode = getFiberCurrentPropsFromNode,
flushPassiveEffects = flushPassiveEffects,
IsThisRendererActing = IsThisRendererActing,
},
}
local exports = {
createPortal = createPortal,
unstable_batchedUpdates = batchedUpdates,
flushSync = flushSync,
__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED = Internals,
version = ReactVersion,
createRoot = createRoot,
createBlockingRoot = createBlockingRoot,
createLegacyRoot = createLegacyRoot,
Event = Event,
Change = Change,
Tag = Tag,
unstable_isNewReconciler = enableNewReconciler,
act = function(_: () -> ()): ()
error(
"ReactRoblox.act is only available in testing environments, not "
.. "production. Enable the `__ROACT_17_MOCK_SCHEDULER__` global in your "
.. "test configuration in order to use `act`."
)
end,
}
if ReactGlobals.__ROACT_17_MOCK_SCHEDULER__ then
exports.act = ReactReconciler.act
end
local _foundDevTools = injectIntoDevTools({
findFiberByHostInstance = getClosestInstanceFromNode,
bundleType = if ReactGlobals.__DEV__ then 1 else 0,
version = ReactVersion,
rendererPackageName = "ReactRoblox",
})
if ReactGlobals.__DEV__ then
end
exports.robloxReactProfiling = ReactReconciler.robloxReactProfiling
exports.schedulingProfiler = ReactReconciler.schedulingProfiler
return exports
end
end)())
__register("ReactRoblox/client/ReactRobloxComponent", (function()
local script = __makeProxy({"ReactRoblox","client","ReactRobloxComponent"})
return function()
local Packages = script.Parent.Parent.Parent
local LuauPolyfill = __require(Packages.LuauPolyfill)
local Object = LuauPolyfill.Object
local RobloxComponentProps = __require(script.Parent.roblox.RobloxComponentProps)
local ReactRobloxHostTypes = __require(script.Parent["ReactRobloxHostTypes.roblox"])
type HostInstance = ReactRobloxHostTypes.HostInstance
type Array<T> = { [number]: T }
type Object = { [any]: any }
local exports: { [string]: any } = {}
exports.setInitialProperties = RobloxComponentProps.setInitialProperties
local function diffProperties(
domElement: HostInstance,
tag: string,
lastRawProps: Object,
nextRawProps: Object,
rootContainerElement: HostInstance
): nil | Array<any>
local updatePayload = nil
local lastProps = lastRawProps
local nextProps = nextRawProps
for propKey, _ in lastProps do
if nextProps[propKey] ~= nil then
continue
end
updatePayload = updatePayload or table.create(2)
table.insert(updatePayload, propKey)
table.insert(updatePayload, Object.None)
end
for propKey, nextProp in nextProps do
local lastProp = if lastProps ~= nil then lastProps[propKey] else nil
if nextProp == lastProp then
continue
end
updatePayload = updatePayload or table.create(2)
table.insert(updatePayload, propKey)
table.insert(updatePayload, nextProp)
end
return updatePayload
end
exports.diffProperties = diffProperties
exports.updateProperties = RobloxComponentProps.updateProperties
exports.cleanupHostComponent = RobloxComponentProps.cleanupHostComponent
return exports
end
end)())
__register("ReactRoblox/client/ReactRobloxComponentTree", (function()
local script = __makeProxy({"ReactRoblox","client","ReactRobloxComponentTree"})
return function()
local Packages = script.Parent.Parent.Parent
local ReactRobloxHostTypes = __require(script.Parent["ReactRobloxHostTypes.roblox"])
type HostInstance = ReactRobloxHostTypes.HostInstance
type TextInstance = ReactRobloxHostTypes.TextInstance
type SuspenseInstance = ReactRobloxHostTypes.SuspenseInstance
type Container = ReactRobloxHostTypes.Container
type Props = ReactRobloxHostTypes.Props
local ReactInternalTypes = __require(Packages.ReactReconciler)
type Fiber = ReactInternalTypes.Fiber
local Shared = __require(Packages.Shared)
type ReactScopeInstance = Shared.ReactScopeInstance
local ReactWorkTags
local HostComponent
local HostText
local HostRoot
local SuspenseComponent
local getParentSuspenseInstance
local invariant = Shared.invariant
local exports: { [any]: any } = {}
local containerToRoot: { [Container]: Fiber } = {}
local instanceToFiber: { [HostInstance | SuspenseInstance | ReactScopeInstance]: Fiber } =
{}
local instanceToProps: { [HostInstance | SuspenseInstance]: Props } = {}
local randomKey = string.sub(tostring(math.random()), 3)
local internalInstanceKey = "__reactFiber$" .. randomKey
local internalContainerInstanceKey = "__reactContainer$" .. randomKey
exports.precacheFiberNode = function(
hostInst: Fiber,
node: HostInstance | SuspenseInstance | ReactScopeInstance
)
instanceToFiber[node] = hostInst
end
exports.uncacheFiberNode = function(
node: HostInstance | SuspenseInstance | ReactScopeInstance
)
instanceToFiber[node] = nil
instanceToProps[node] = nil
end
exports.markContainerAsRoot = function(hostRoot: Fiber, node: Container)
containerToRoot[node] = hostRoot
end
exports.unmarkContainerAsRoot = function(node: Container)
containerToRoot[node] = nil
end
exports.isContainerMarkedAsRoot = function(node: Container): boolean
return not not containerToRoot[node]
end
exports.getClosestInstanceFromNode = function(targetNode: Instance): Fiber?
local targetInst = instanceToFiber[targetNode]
if targetInst then
return targetInst
end
local parentNode = targetNode.Parent
while parentNode do
targetInst = instanceToFiber[parentNode]
if targetInst then
local alternate = targetInst.alternate
if
targetInst.child ~= nil
or (alternate ~= nil and alternate.child ~= nil)
then
if getParentSuspenseInstance == nil then
getParentSuspenseInstance = (__require(
script.Parent.ReactRobloxHostConfig
) :: any).getParentSuspenseInstance
end
local suspenseInstance = getParentSuspenseInstance(targetNode)
while suspenseInstance ~= nil do
local targetSuspenseInst = instanceToFiber[suspenseInstance]
if targetSuspenseInst then
return targetSuspenseInst
end
suspenseInstance = getParentSuspenseInstance(suspenseInstance)
end
end
return targetInst
end
targetNode = parentNode
parentNode = targetNode.Parent
end
return nil
end
exports.getInstanceFromNode = function(node): Fiber?
if ReactWorkTags == nil then
local ReactReconciler =
__require(script.Parent.Parent["ReactReconciler.roblox"]) :: any
ReactWorkTags = ReactReconciler.ReactWorkTags
HostComponent = ReactWorkTags.HostComponent
HostText = ReactWorkTags.HostComponent
HostRoot = ReactWorkTags.HostComponent
SuspenseComponent = ReactWorkTags.HostComponent
end
local inst = (node :: any)[internalInstanceKey]
or (node :: any)[internalContainerInstanceKey]
if inst then
if
inst.tag == HostComponent
or inst.tag == HostText
or inst.tag == SuspenseComponent
or inst.tag == HostRoot
then
return inst
else
return nil
end
end
return nil
end
exports.getNodeFromInstance = function(inst: Fiber): Instance | TextInstance
if inst.tag == HostComponent or inst.tag == HostText then
return inst.stateNode
end
invariant(false, "getNodeFromInstance: Invalid argument.")
error("getNodeFromInstance: Invalid argument.")
end
exports.getFiberCurrentPropsFromNode = function(
node: Instance | TextInstance | SuspenseInstance
): Props
return instanceToProps[node]
end
exports.updateFiberProps = function(node: Instance | SuspenseInstance, props: Props)
instanceToProps[node] = props
end
return exports
end
end)())
__register("ReactRoblox/client/ReactRobloxHostConfig", (function()
local script = __makeProxy({"ReactRoblox","client","ReactRobloxHostConfig"})
return function()
local function unimplemented(message: string)
print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
print("UNIMPLEMENTED ERROR: " .. tostring(message))
error("FIXME (roblox): " .. message .. " is unimplemented", 2)
end
local CollectionService = game:GetService("CollectionService")
local Packages = script.Parent.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local LuauPolyfill = __require(Packages.LuauPolyfill)
local inspect = LuauPolyfill.util.inspect
local console = __require(Packages.Shared).console
local Object = LuauPolyfill.Object
local setTimeout = LuauPolyfill.setTimeout
local clearTimeout = LuauPolyfill.clearTimeout
local ReactRobloxHostTypes = __require(script.Parent["ReactRobloxHostTypes.roblox"])
type RootType = ReactRobloxHostTypes.RootType
type Container = ReactRobloxHostTypes.Container
type HostInstance = ReactRobloxHostTypes.HostInstance
type SuspenseInstance = ReactRobloxHostTypes.SuspenseInstance
type TextInstance = ReactRobloxHostTypes.TextInstance
type Props = ReactRobloxHostTypes.Props
type Type = ReactRobloxHostTypes.Type
type HostContext = ReactRobloxHostTypes.HostContext
local ReactRobloxComponentTree = __require(script.Parent.ReactRobloxComponentTree)
local precacheFiberNode = ReactRobloxComponentTree.precacheFiberNode
local uncacheFiberNode = ReactRobloxComponentTree.uncacheFiberNode
local updateFiberProps = ReactRobloxComponentTree.updateFiberProps
local ReactRobloxComponent = __require(script.Parent.ReactRobloxComponent)
local setInitialProperties = ReactRobloxComponent.setInitialProperties
local diffProperties = ReactRobloxComponent.diffProperties
local updateProperties = ReactRobloxComponent.updateProperties
local cleanupHostComponent = ReactRobloxComponent.cleanupHostComponent
local ReactFeatureFlags = __require(Packages.Shared).ReactFeatureFlags
local enableCreateEventHandleAPI = ReactFeatureFlags.enableCreateEventHandleAPI
type Array<T> = { [number]: T }
type Object = { [any]: any }
local function recursivelyUncacheFiberNode(node: HostInstance)
if typeof(node :: any) ~= "Instance" then
return
end
uncacheFiberNode(node)
for _, child in node:GetDescendants() do
uncacheFiberNode(child)
end
end
local exports: { [any]: any } = {}
Object.assign(exports, __require(Packages.Shared).ReactFiberHostConfig.WithNoPersistence)
exports.getRootHostContext = function(rootContainerInstance: Container): HostContext
return rootContainerInstance.ClassName
end
exports.getChildHostContext = function(
parentHostContext: HostContext,
type: string,
rootContainerInstance: Container
): HostContext
return parentHostContext
end
exports.getPublicInstance = function(instance: Instance): any
return instance
end
exports.prepareForCommit = function(containerInfo: Container): Object?
local activeInstance = nil
if enableCreateEventHandleAPI then
unimplemented("enableCreateEventHandleAPI")
end
return activeInstance
end
exports.beforeActiveInstanceBlur = function()
if enableCreateEventHandleAPI then
unimplemented("enableCreateEventHandleAPI")
end
end
exports.afterActiveInstanceBlur = function()
if enableCreateEventHandleAPI then
unimplemented("enableCreateEventHandleAPI")
end
end
exports.resetAfterCommit = function(containerInfo: Container)
end
exports.createInstance = function(
type_: string,
props: Props,
rootContainerInstance: Container,
hostContext: HostContext,
internalInstanceHandle: Object
): HostInstance
local domElement = Instance.new(type_)
if internalInstanceHandle.key then
domElement.Name = internalInstanceHandle.key
else
local currentHandle = internalInstanceHandle.return_
while currentHandle do
if currentHandle.key then
domElement.Name = currentHandle.key
break
end
currentHandle = currentHandle.return_
end
end
precacheFiberNode(internalInstanceHandle, domElement)
updateFiberProps(domElement, props)
return domElement
end
exports.appendInitialChild = function(parentInstance: Instance, child: Instance)
child.Parent = parentInstance
end
exports.finalizeInitialChildren = function(
domElement: HostInstance,
type_: string,
props: Props,
rootContainerInstance: Container,
hostContext: HostContext
): boolean
setInitialProperties(domElement, type_, props, rootContainerInstance)
return false
end
local function prepareUpdate(
domElement: Instance,
type_: string,
oldProps: Props,
newProps: Props,
rootContainerInstance: Container,
hostContext: HostContext
): nil | Array<any>
return diffProperties(domElement, type_, oldProps, newProps, rootContainerInstance)
end
exports.prepareUpdate = prepareUpdate
exports.shouldSetTextContent = function(_type: string, _props: Props): boolean
return false
end
exports.createTextInstance = function(
text: string,
rootContainerInstance: Container,
hostContext: HostContext,
internalInstanceHandle: Object
): any
unimplemented("createTextInstance")
return nil
end
exports.isPrimaryRenderer = true
exports.warnsIfNotActing = true
exports.scheduleTimeout = setTimeout
exports.cancelTimeout = clearTimeout
exports.noTimeout = -1
exports.supportsMutation = true
exports.commitMount = function(
domElement: Instance,
type: string,
newProps: Props,
internalInstanceHandle: Object
)
unimplemented("commitMount")
end
exports.commitUpdate = function(
domElement: Instance,
updatePayload: Array<any>,
type_: string,
oldProps: Props,
newProps: Props,
internalInstanceHandle: Object
)
updateFiberProps(domElement, newProps)
updateProperties(domElement, updatePayload, oldProps)
end
local function checkTags(instance: Instance)
if typeof(instance :: any) ~= "Instance" then
console.warn("Could not check tags on non-instance %s.", inspect(instance))
return
end
if not instance:IsDescendantOf(game) then
if #CollectionService:GetTags(instance) > 0 then
console.warn(
'Tags applied to orphaned %s "%s" cannot be accessed via'
.. " CollectionService:GetTagged. If you're relying on tag"
.. " behavior in a unit test, consider mounting your test "
.. "root into the DataModel.",
instance.ClassName,
instance.Name
)
end
end
end
exports.appendChild = function(parentInstance: Instance, child: Instance)
child.Parent = parentInstance
if ReactGlobals.__DEV__ then
checkTags(child)
end
end
exports.appendChildToContainer = function(container: Container, child: Instance)
local parentNode = container
exports.appendChild(parentNode, child)
end
exports.insertBefore = function(
parentInstance: Instance,
child: Instance,
_beforeChild: Instance
)
child.Parent = parentInstance
if ReactGlobals.__DEV__ then
checkTags(child)
end
end
exports.insertInContainerBefore = function(
container: Container,
child: Instance,
beforeChild: Instance
)
local parentNode = container
exports.insertBefore(parentNode, child, beforeChild)
end
exports.removeChild = function(_parentInstance: Instance, child: Instance)
recursivelyUncacheFiberNode(child)
cleanupHostComponent(child)
child.Parent = nil
child:Destroy()
end
exports.removeChildFromContainer = function(_container: Container, child: Instance)
exports.removeChild(_container, child)
end
exports.clearSuspenseBoundary = function(
parentInstance: Instance,
suspenseInstance: SuspenseInstance
)
unimplemented("clearSuspenseBoundary")
end
exports.clearSuspenseBoundaryFromContainer = function(
container: Container,
suspenseInstance: SuspenseInstance
)
unimplemented("clearSuspenseBoundaryFromContainer")
end
exports.hideInstance = function(instance: Instance)
unimplemented("hideInstance")
end
exports.hideTextInstance = function(textInstance: TextInstance): ()
unimplemented("hideTextInstance")
end
exports.unhideInstance = function(instance: Instance, props: Props)
unimplemented("unhideInstance")
end
exports.unhideTextInstance = function(textInstance: TextInstance, text: string): ()
unimplemented("unhideTextInstance")
end
exports.clearContainer = function(container: Container)
local parentInstance = container
for _, child in parentInstance:GetChildren() do
exports.removeChild(parentInstance, child)
end
end
exports.preparePortalMount = function(portalInstance: Instance): ()
end
return exports
end
end)())
__register("ReactRoblox/client/ReactRobloxHostTypes.roblox", (function()
local script = __makeProxy({"ReactRoblox","client","ReactRobloxHostTypes.roblox"})
return function()
local Packages = script.Parent.Parent.Parent
local ReactReconciler = __require(Packages.ReactReconciler)
type FiberRoot = ReactReconciler.FiberRoot
local ReactTypes = __require(Packages.Shared)
type MutableSource<T> = ReactTypes.MutableSource<T>
type ReactNodeList = ReactTypes.ReactNodeList
type Array<T> = { [number]: T }
type Container = Instance
type HostInstance = Instance
type TextInstance = Instance
type SuspenseInstance = any
type Type = string
type Props = {
autoFocus: boolean?,
children: any,
disabled: boolean?,
hidden: boolean?,
suppressHydrationWarning: boolean?,
dangerouslySetInnerHTML: any,
style: { display: string, [any]: any }?,
bottom: number?,
left: number?,
right: number?,
top: number?,
[any]: any,
}
type HydratableInstance = Instance | SuspenseInstance
type PublicInstance = HostInstance
type HostContextDev = {
namespace: string,
ancestorInfo: any,
[any]: any,
}
type HostContextProd = string
type HostContext = HostContextDev | HostContextProd
type RootType = {
render: (self: RootType, children: ReactNodeList) -> (),
unmount: (self: RootType) -> (),
_internalRoot: any,
[any]: any,
}
type RootOptions = {
hydrate: boolean?,
hydrationOptions: {
onHydrated: (suspenseNode: any) -> ()?,
onDeleted: (suspenseNode: any) -> ()?,
mutableSources: Array<MutableSource<any>>?,
[any]: any,
}?,
[any]: any,
}
return {}
end
end)())
__register("ReactRoblox/client/ReactRobloxRoot", (function()
local script = __makeProxy({"ReactRoblox","client","ReactRobloxRoot"})
return function()
local Packages = script.Parent.Parent.Parent
local ReactRobloxHostTypes = __require(script.Parent["ReactRobloxHostTypes.roblox"])
type Container = ReactRobloxHostTypes.Container
type RootType = ReactRobloxHostTypes.RootType
type RootOptions = ReactRobloxHostTypes.RootOptions
local ReactGlobals = __require(Packages.ReactGlobals)
local ReconcilerTypes = __require(Packages.ReactReconciler)
type RootTag = ReconcilerTypes.RootTag
local ReactTypes = __require(Packages.Shared)
type MutableSource<T> = ReactTypes.MutableSource<T>
type ReactNodeList = ReactTypes.ReactNodeList
local ReactInternalTypes = __require(Packages.ReactReconciler)
type FiberRoot = ReactInternalTypes.FiberRoot
type Array<T> = { [number]: T }
local ReactRobloxComponentTree = __require(script.Parent.ReactRobloxComponentTree)
local markContainerAsRoot = ReactRobloxComponentTree.markContainerAsRoot
local unmarkContainerAsRoot = ReactRobloxComponentTree.unmarkContainerAsRoot
local ReactFiberReconciler = __require(script.Parent.Parent["ReactReconciler.roblox"])
local createContainer = ReactFiberReconciler.createContainer
local updateContainer = ReactFiberReconciler.updateContainer
local invariant = __require(Packages.Shared).invariant
local enableEagerRootListeners =
__require(Packages.Shared).ReactFeatureFlags.enableEagerRootListeners
local flushSync = ReactFiberReconciler.flushSync
local flushPassiveEffects = ReactFiberReconciler.flushPassiveEffects
local BlockingRoot = ReactFiberReconciler.ReactRootTags.BlockingRoot
local ConcurrentRoot = ReactFiberReconciler.ReactRootTags.ConcurrentRoot
local LegacyRoot = ReactFiberReconciler.ReactRootTags.LegacyRoot
local createRootImpl
local ReactRobloxRoot = {}
ReactRobloxRoot.__index = ReactRobloxRoot
function ReactRobloxRoot.new(container: Container, options: RootOptions?): RootType
local root: RootType = (setmetatable({}, ReactRobloxRoot) :: any) :: RootType
root._internalRoot = createRootImpl(container, ConcurrentRoot, options)
return root
end
local function createBlockingRoot(
container: Container,
tag: RootTag,
options: RootOptions?
): RootType
local root: RootType = (setmetatable({}, ReactRobloxRoot) :: any) :: RootType
root._internalRoot = createRootImpl(container, tag, options)
return root
end
function ReactRobloxRoot:render(children: ReactNodeList)
local root = self._internalRoot
updateContainer(children, root, nil)
end
function ReactRobloxRoot:unmount()
local root = self._internalRoot
local container = root.containerInfo
flushSync(function()
updateContainer(nil, root, nil, function()
unmarkContainerAsRoot(container)
end)
end)
flushPassiveEffects()
end
createRootImpl = function(container: Container, tag: RootTag, options: any)
local hydrate = options ~= nil and options.hydrate == true
local hydrationCallbacks = if options ~= nil then options.hydrationOptions else nil
local mutableSources = (
options ~= nil
and options.hydrationOptions ~= nil
and options.hydrationOptions.mutableSources
) or nil
local root = createContainer(container, tag, hydrate, hydrationCallbacks)
markContainerAsRoot(root.current, container)
if enableEagerRootListeners then
end
if mutableSources then
end
return root
end
local exports = {}
local function isValidContainer(node: any): boolean
return typeof(node) == "Instance"
end
exports.isValidContainer = isValidContainer
exports.createRoot = function(container: Container, options: RootOptions?): RootType
invariant(
isValidContainer(container),
"createRoot(...): Target container is not a Roblox Instance."
)
warnIfReactDOMContainerInDEV(container)
return ReactRobloxRoot.new(container, options)
end
exports.createBlockingRoot = function(
container: Container,
options: RootOptions?
): RootType
invariant(
isValidContainer(container),
"createRoot(...): Target container is not a Roblox Instance."
)
warnIfReactDOMContainerInDEV(container)
return createBlockingRoot(container, BlockingRoot, options)
end
exports.createLegacyRoot = function(container: Container, options: RootOptions?): RootType
return createBlockingRoot(container, LegacyRoot, options)
end
function warnIfReactDOMContainerInDEV(container)
if ReactGlobals.__DEV__ then
end
end
return exports
end
end)())
__register("ReactRoblox/client/roblox/getDefaultInstanceProperty", (function()
local script = __makeProxy({"ReactRoblox","client","roblox","getDefaultInstanceProperty"})
return function()
local Packages = script.Parent.Parent.Parent.Parent
local Symbol = __require(Packages.Shared).Symbol
local Nil = Symbol.named("Nil")
local _cachedPropertyValues = {}
local function tryPropertyName(instance, propertyName)
return instance[propertyName]
end
local function getDefaultInstanceProperty(className, propertyName)
local classCache = _cachedPropertyValues[className]
if classCache then
local propValue = classCache[propertyName]
if propValue == Nil then
return true, nil
end
if propValue ~= nil then
return true, propValue
end
else
classCache = {}
_cachedPropertyValues[className] = classCache
end
local created = Instance.new(className)
local ok, defaultValue = pcall(tryPropertyName, created, propertyName)
created:Destroy()
if ok then
if defaultValue == nil then
classCache[propertyName] = Nil
else
classCache[propertyName] = defaultValue
end
end
return ok, defaultValue
end
return getDefaultInstanceProperty
end
end)())
__register("ReactRoblox/client/roblox/RobloxComponentProps", (function()
local script = __makeProxy({"ReactRoblox","client","roblox","RobloxComponentProps"})
return function()
local CollectionService = game:GetService("CollectionService")
local Packages = script.Parent.Parent.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local LuauPolyfill = __require(Packages.LuauPolyfill)
local Object = LuauPolyfill.Object
local inspect = LuauPolyfill.util.inspect
local __DEV__ = ReactGlobals.__DEV__ :: boolean
local console = __require(Packages.Shared).console
local React = __require(Packages.React)
local ReactSymbols = __require(Packages.Shared).ReactSymbols
local SingleEventManager = __require(script.Parent.SingleEventManager)
type EventManager = SingleEventManager.EventManager
local Type = __require(Packages.Shared).Type
local getDefaultInstanceProperty = __require(script.Parent.getDefaultInstanceProperty)
local ReactRobloxHostTypes = __require(script.Parent.Parent["ReactRobloxHostTypes.roblox"])
type HostInstance = ReactRobloxHostTypes.HostInstance
local Tag = __require(Packages.React).Tag
type Array<T> = { [number]: T }
type Object = { [any]: any }
local instanceToEventManager: { [HostInstance]: EventManager } = {}
local instanceToBindings: { [HostInstance]: { [string]: any } } = {}
local applyPropsError = [[
Error applying initial props to Roblox Instance '%s' (%s):
%s
]]
local updatePropsError = [[
Error updating props on Roblox Instance '%s' (%s):
%s
]]
local updateBindingError = [[
Error updating binding or ref assigned to key %s of '%s' (%s).
Updated value:
%s
Error:
%s
%s
]]
local function identity(...)
return ...
end
local function setRobloxInstanceProperty(hostInstance, key, newValue): ()
if newValue == nil then
local success, _ = pcall(hostInstance.ResetPropertyToDefault, hostInstance, key)
if success then
return
end
local hostClass = hostInstance.ClassName
local _, defaultValue = getDefaultInstanceProperty(hostClass, key)
newValue = defaultValue
end
hostInstance[key] = newValue
end
local function removeBinding(hostInstance, key)
local bindings = instanceToBindings[hostInstance]
if bindings ~= nil then
local disconnect = bindings[key]
disconnect()
bindings[key] = nil
end
end
local function attachBinding(hostInstance, key, newBinding): ()
local function updateBoundProperty(newValue)
local success, errorMessage =
xpcall(setRobloxInstanceProperty, identity, hostInstance, key, newValue)
if not success then
local source = newBinding._source or "<enable DEV mode for stack>"
local fullMessage = string.format(
updateBindingError,
key,
hostInstance.Name,
hostInstance.ClassName,
tostring(newValue),
errorMessage,
source
)
console.error(fullMessage)
error(fullMessage, 0)
end
end
if instanceToBindings[hostInstance] == nil then
instanceToBindings[hostInstance] = {}
end
instanceToBindings[hostInstance][key] =
React.__subscribeToBinding(newBinding, updateBoundProperty)
updateBoundProperty(newBinding:getValue())
end
local function applyTags(hostInstance: Instance, oldTags: string?, newTags: string?)
if __DEV__ then
if newTags ~= nil and typeof(newTags) ~= "string" then
console.error(
"Type provided for ReactRoblox.Tag is invalid - tags should be "
.. "specified as a single string, with individual tags delimited "
.. "by spaces. Instead received:\n%s",
inspect(newTags)
)
return
end
end
local oldTagSet = {}
for str in string.gmatch(oldTags or "", "%S+") do
oldTagSet[str] = true
end
local newTagSet = {}
for str in string.gmatch(newTags or "", "%S+") do
newTagSet[str] = true
end
for tag, _ in oldTagSet do
if not newTagSet[tag] then
CollectionService:RemoveTag(hostInstance, tag)
end
end
for tag, _ in newTagSet do
if not oldTagSet[tag] then
CollectionService:AddTag(hostInstance, tag)
end
end
end
local function removeAllTags(hostInstance: Instance)
for _, tag in CollectionService:GetTags(hostInstance) do
CollectionService:RemoveTag(hostInstance, tag)
end
end
local function applyProp(hostInstance: Instance, key, newValue, oldValue): ()
local internalKeyType = Type.of(key)
if internalKeyType == Type.HostEvent or internalKeyType == Type.HostChangeEvent then
local eventManager = instanceToEventManager[hostInstance]
if eventManager == nil then
eventManager = (SingleEventManager.new(hostInstance) :: any) :: EventManager
instanceToEventManager[hostInstance] = eventManager
end
local eventName = key.name
if internalKeyType == Type.HostChangeEvent then
eventManager:connectPropertyChange(eventName, newValue)
else
eventManager:connectEvent(eventName, newValue)
end
return
end
local newIsBinding = typeof(newValue) == "table"
and newValue["$$typeof"] == ReactSymbols.REACT_BINDING_TYPE
local oldIsBinding = oldValue ~= nil
and typeof(oldValue) == "table"
and oldValue["$$typeof"] == ReactSymbols.REACT_BINDING_TYPE
if oldIsBinding then
removeBinding(hostInstance, key)
end
if newIsBinding then
attachBinding(hostInstance, key, newValue)
elseif key == Tag then
applyTags(hostInstance, oldValue, newValue)
else
setRobloxInstanceProperty(hostInstance, key, newValue)
end
end
local function applyProps(hostInstance: Instance, props: Object): ()
for propKey, value in props do
if propKey == "ref" or propKey == "children" then
continue
end
applyProp(hostInstance, propKey, value)
end
end
local function setInitialProperties(
domElement: HostInstance,
_tag: string,
rawProps: Object,
_rootContainerElement: HostInstance
): ()
local success, errorMessage = xpcall(applyProps, identity, domElement, rawProps)
if not success then
local fullMessage = string.format(
applyPropsError,
domElement.Name,
domElement.ClassName,
tostring(errorMessage)
)
console.error(fullMessage)
error(fullMessage, 0)
end
if instanceToEventManager[domElement] ~= nil then
instanceToEventManager[domElement]:resume()
end
end
local function safelyApplyProperties(
domElement: HostInstance,
updatePayload: Array<any>,
lastProps: Object
): ()
local updatePayloadCount = #updatePayload
for i = 1, updatePayloadCount, 2 do
local propKey = updatePayload[i]
local value = updatePayload[i + 1]
if value == Object.None then
value = nil
end
if propKey ~= "ref" and propKey ~= "children" then
applyProp(domElement, propKey, value, lastProps[propKey])
end
end
end
local function updateProperties(
domElement: HostInstance,
updatePayload: Array<any>,
lastProps: Object
): ()
if instanceToEventManager[domElement] ~= nil then
instanceToEventManager[domElement]:suspend()
end
local success, errorMessage =
xpcall(safelyApplyProperties, identity, domElement, updatePayload, lastProps)
if not success then
local fullMessage = string.format(
updatePropsError,
domElement.Name,
domElement.ClassName,
errorMessage
)
console.error(fullMessage)
error(fullMessage, 0)
end
if instanceToEventManager[domElement] ~= nil then
instanceToEventManager[domElement]:resume()
end
end
local _, FFlagReactFixBindingMemoryLeak = xpcall(function()
return game:DefineFastFlag("ReactFixBindingMemoryLeak", false)
end, function()
return true
end)
local function cleanupBindings(domElement: HostInstance)
local instanceBindings = instanceToBindings[domElement]
if instanceBindings ~= nil then
for _, disconnectBinding in instanceBindings do
disconnectBinding()
end
instanceToBindings[domElement] = nil
end
end
local function cleanupHostComponent(domElement: HostInstance)
if instanceToEventManager[domElement] ~= nil then
instanceToEventManager[domElement] = nil
end
if FFlagReactFixBindingMemoryLeak then
cleanupBindings(domElement)
else
if instanceToBindings[domElement] ~= nil then
instanceToBindings[domElement] = nil
end
end
if typeof(domElement :: any) ~= "Instance" then
return
end
removeAllTags(domElement)
for _, descElement in domElement:GetDescendants() do
if instanceToEventManager[descElement] ~= nil then
instanceToEventManager[descElement] = nil
end
if FFlagReactFixBindingMemoryLeak then
cleanupBindings(descElement)
else
if instanceToBindings[descElement] ~= nil then
instanceToBindings[descElement] = nil
end
end
removeAllTags(domElement)
end
end
return {
setInitialProperties = setInitialProperties,
updateProperties = updateProperties,
cleanupHostComponent = cleanupHostComponent,
_instanceToEventManager = instanceToEventManager,
_instanceToBindings = instanceToBindings,
}
end
end)())
__register("ReactRoblox/client/roblox/SingleEventManager", (function()
local script = __makeProxy({"ReactRoblox","client","roblox","SingleEventManager"})
return function()
local Packages = script.Parent.Parent.Parent.Parent
local console = __require(Packages.Shared).console
type Function = (...any) -> ...any
local CHANGE_PREFIX = "Change."
local EventStatus = {
Disabled = "Disabled",
Suspended = "Suspended",
Enabled = "Enabled",
}
type EventManager = {
connectPropertyChange: (self: any, eventName: string, newValue: any) -> (),
connectEvent: (self: any, eventName: string, newValue: any) -> (),
resume: (self: any) -> (),
suspend: (self: any) -> (),
}
local SingleEventManager = {}
SingleEventManager.__index = SingleEventManager
function SingleEventManager.new(instance: Instance): EventManager
local self = setmetatable({
_suspendedEventQueue = {},
_connections = {},
_listeners = {},
_status = EventStatus.Disabled,
_isResuming = false,
_instance = instance,
}, SingleEventManager)
return (self :: any) :: EventManager
end
function SingleEventManager:connectEvent(key, listener)
self:_connect(key, self._instance[key], listener)
end
function SingleEventManager:connectPropertyChange(key, listener)
local success, event =
pcall(self._instance.GetPropertyChangedSignal, self._instance, key)
if not success then
error(
string.format(
"Cannot get changed signal on property %q: %s",
tostring(key),
event
),
0
)
end
self:_connect(CHANGE_PREFIX .. key, event, listener)
end
function SingleEventManager:_connect(eventKey, event, listener)
if listener == nil then
if self._connections[eventKey] ~= nil then
self._connections[eventKey]:Disconnect()
self._connections[eventKey] = nil
end
self._listeners[eventKey] = nil
else
if self._connections[eventKey] == nil then
self._connections[eventKey] = event:Connect(function(...)
if self._status == EventStatus.Enabled then
self._listeners[eventKey](self._instance, ...)
elseif self._status == EventStatus.Suspended then
local argumentCount = select("#", ...)
table.insert(
self._suspendedEventQueue,
{ eventKey, argumentCount, ... }
)
end
end)
end
self._listeners[eventKey] = listener
end
end
function SingleEventManager:suspend()
self._status = EventStatus.Suspended
end
function SingleEventManager:resume()
if self._isResuming then
return
end
self._isResuming = true
for _, eventInvocation in self._suspendedEventQueue do
local listener = self._listeners[eventInvocation[1]]
local argumentCount = eventInvocation[2]
if listener ~= nil then
local listenerCo = coroutine.create(listener)
local success, result = coroutine.resume(
listenerCo,
self._instance,
unpack(eventInvocation, 3, 2 + argumentCount)
)
if not success then
console.warn("%s", result)
end
end
end
self._isResuming = false
self._status = EventStatus.Enabled
table.clear(self._suspendedEventQueue)
end
return SingleEventManager
end
end)())
__register("ReactRoblox/init", (function()
local script = __makeProxy({"ReactRoblox"})
return function()
local HostTypes = __require(script.client["ReactRobloxHostTypes.roblox"])
type RootType = HostTypes.RootType
return __require(script.client.ReactRoblox)
end
end)())
__register("ReactRoblox/ReactReconciler.roblox", (function()
local script = __makeProxy({"ReactRoblox","ReactReconciler.roblox"})
return function()
local Packages = script.Parent.Parent
local initializeReconciler = __require(Packages.ReactReconciler)
local ReactRobloxHostConfig = __require(script.Parent.client.ReactRobloxHostConfig)
return initializeReconciler(ReactRobloxHostConfig)
end
end)())
__register("ReactIs/init", (function()
local script = __makeProxy({"ReactIs"})
return function()
local Packages = script.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local console = __require(Packages.Shared).console
local exports = {}
local sharedReactSymbolsModule = __require(Packages.Shared).ReactSymbols
local REACT_CONTEXT_TYPE = sharedReactSymbolsModule.REACT_CONTEXT_TYPE
local REACT_ELEMENT_TYPE = sharedReactSymbolsModule.REACT_ELEMENT_TYPE
local REACT_FORWARD_REF_TYPE = sharedReactSymbolsModule.REACT_FORWARD_REF_TYPE
local REACT_FRAGMENT_TYPE = sharedReactSymbolsModule.REACT_FRAGMENT_TYPE
local REACT_LAZY_TYPE = sharedReactSymbolsModule.REACT_LAZY_TYPE
local REACT_MEMO_TYPE = sharedReactSymbolsModule.REACT_MEMO_TYPE
local REACT_PORTAL_TYPE = sharedReactSymbolsModule.REACT_PORTAL_TYPE
local REACT_PROFILER_TYPE = sharedReactSymbolsModule.REACT_PROFILER_TYPE
local REACT_PROVIDER_TYPE = sharedReactSymbolsModule.REACT_PROVIDER_TYPE
local REACT_STRICT_MODE_TYPE = sharedReactSymbolsModule.REACT_STRICT_MODE_TYPE
local REACT_SUSPENSE_TYPE = sharedReactSymbolsModule.REACT_SUSPENSE_TYPE
local REACT_SUSPENSE_LIST_TYPE = sharedReactSymbolsModule.REACT_SUSPENSE_LIST_TYPE
local isValidElementType = __require(Packages.Shared).isValidElementType
local REACT_BINDING_TYPE = sharedReactSymbolsModule.REACT_BINDING_TYPE
local SafeFlags = __require(Packages.SafeFlags)
local FFlagReactIsProtectedTypeOf =
SafeFlags.createGetFFlag("ReactIsProtectedTypeOf", false)()
local function typeOf(object: any)
if typeof(object) == "table" and object ~= nil then
local __typeof: any
if FFlagReactIsProtectedTypeOf then
local couldIndex
couldIndex, __typeof = pcall(function()
return object["$$typeof"]
end)
if not couldIndex then
return nil
end
else
__typeof = object["$$typeof"]
end
if __typeof == REACT_ELEMENT_TYPE then
local __type = object.type
if
__type == REACT_FRAGMENT_TYPE
or __type == REACT_PROFILER_TYPE
or __type == REACT_STRICT_MODE_TYPE
or __type == REACT_SUSPENSE_TYPE
or __type == REACT_SUSPENSE_LIST_TYPE
then
return __type
else
local __typeofType = __type
and typeof(__type) == "table"
and __type["$$typeof"]
if
__typeofType == REACT_CONTEXT_TYPE
or __typeofType == REACT_FORWARD_REF_TYPE
or __typeofType == REACT_LAZY_TYPE
or __typeofType == REACT_MEMO_TYPE
or __typeofType == REACT_PROVIDER_TYPE
then
return __typeofType
else
return __typeof
end
end
elseif
__typeof == REACT_PORTAL_TYPE
or __typeof == REACT_BINDING_TYPE
then
return __typeof
end
end
return nil
end
exports.typeOf = typeOf
local ContextConsumer = REACT_CONTEXT_TYPE
exports.ContextConsumer = ContextConsumer
local ContextProvider = REACT_PROVIDER_TYPE
exports.ContextProvider = ContextProvider
local Element = REACT_ELEMENT_TYPE
exports.Element = Element
local ForwardRef = REACT_FORWARD_REF_TYPE
exports.ForwardRef = ForwardRef
local Fragment = REACT_FRAGMENT_TYPE
exports.Fragment = Fragment
local Lazy = REACT_LAZY_TYPE
exports.Lazy = Lazy
local Memo = REACT_MEMO_TYPE
exports.Memo = Memo
local Portal = REACT_PORTAL_TYPE
exports.Portal = Portal
local Profiler = REACT_PROFILER_TYPE
exports.Profiler = Profiler
local StrictMode = REACT_STRICT_MODE_TYPE
exports.StrictMode = StrictMode
local Suspense = REACT_SUSPENSE_TYPE
exports.Suspense = Suspense
exports.Binding = sharedReactSymbolsModule.REACT_BINDING_TYPE
exports.isValidElementType = isValidElementType
local hasWarnedAboutDeprecatedIsAsyncMode = false
local hasWarnedAboutDeprecatedIsConcurrentMode = false
local function isAsyncMode(object: any)
if ReactGlobals.__DEV__ then
if not hasWarnedAboutDeprecatedIsAsyncMode then
hasWarnedAboutDeprecatedIsAsyncMode = true
console["warn"](
"The ReactIs.isAsyncMode() alias has been deprecated, "
.. "and will be removed in React 18+."
)
end
end
return false
end
exports.isAsyncMode = isAsyncMode
local function isConcurrentMode(object: any)
if ReactGlobals.__DEV__ then
if not hasWarnedAboutDeprecatedIsConcurrentMode then
hasWarnedAboutDeprecatedIsConcurrentMode = true
console["warn"](
"The ReactIs.isConcurrentMode() alias has been deprecated, "
.. "and will be removed in React 18+."
)
end
end
return false
end
exports.isConcurrentMode = isConcurrentMode
local function isContextConsumer(object: any)
return typeOf(object) == REACT_CONTEXT_TYPE
end
exports.isContextConsumer = isContextConsumer
local function isContextProvider(object: any)
return typeOf(object) == REACT_PROVIDER_TYPE
end
exports.isContextProvider = isContextProvider
local function isElement(object: any)
return typeof(object) == "table"
and object ~= nil
and object["$$typeof"] == REACT_ELEMENT_TYPE
end
exports.isElement = isElement
local function isForwardRef(object: any)
return typeOf(object) == REACT_FORWARD_REF_TYPE
end
exports.isForwardRef = isForwardRef
local function isFragment(object: any)
return typeOf(object) == REACT_FRAGMENT_TYPE
end
exports.isFragment = isFragment
local function isLazy(object: any)
return typeOf(object) == REACT_LAZY_TYPE
end
exports.isLazy = isLazy
local function isMemo(object: any)
return typeOf(object) == REACT_MEMO_TYPE
end
exports.isMemo = isMemo
local function isPortal(object: any)
return typeOf(object) == REACT_PORTAL_TYPE
end
exports.isPortal = isPortal
local function isProfiler(object: any)
return typeOf(object) == REACT_PROFILER_TYPE
end
exports.isProfiler = isProfiler
local function isStrictMode(object: any)
return typeOf(object) == REACT_STRICT_MODE_TYPE
end
exports.isStrictMode = isStrictMode
local function isSuspense(object: any)
return typeOf(object) == REACT_SUSPENSE_TYPE
end
exports.isSuspense = isSuspense
exports.isBinding = function(object: any)
return typeOf(object) == REACT_BINDING_TYPE
end
return exports
end
end)())
__register("RoactCompat/createFragment", (function()
local script = __makeProxy({"RoactCompat","createFragment"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local React = __require(Packages.React)
local warnOnce = __require(script.Parent.warnOnce)
return function(elements)
if ReactGlobals.__DEV__ and ReactGlobals.__COMPAT_WARNINGS__ then
warnOnce(
"createFragment",
"Please instead use:\n\tReact.createElement(React.Fragment, ...)"
)
end
return React.createElement(React.Fragment, nil, elements)
end
end
end)())
__register("RoactCompat/init", (function()
local script = __makeProxy({"RoactCompat"})
return function()
local Packages = script.Parent
local React = __require(Packages.React)
local ReactRoblox = __require(Packages.ReactRoblox)
local Shared = __require(Packages.Shared)
local RoactTree = __require(script.RoactTree)
return {
Component = React.Component,
PureComponent = React.PureComponent,
createElement = React.createElement,
createRef = React.createRef,
forwardRef = React.forwardRef,
createContext = React.createContext,
None = React.None,
mount = RoactTree.mount,
update = RoactTree.update,
unmount = RoactTree.unmount,
createFragment = __require(script.createFragment),
oneChild = __require(script.oneChild),
setGlobalConfig = __require(script.setGlobalConfig),
Portal = __require(script.Portal),
Ref = "ref",
Children = "children",
Event = Shared.Event,
Change = Shared.Change,
createBinding = React.createBinding,
joinBindings = React.joinBindings,
act = ReactRoblox.act,
}
end
end)())
__register("RoactCompat/oneChild", (function()
local script = __makeProxy({"RoactCompat","oneChild"})
return function()
local Packages = script.Parent.Parent
local React = __require(Packages.React)
local ReactGlobals = __require(Packages.ReactGlobals)
local warnOnce = __require(script.Parent.warnOnce)
local function oneChild(children)
if ReactGlobals.__DEV__ and ReactGlobals.__COMPAT_WARNINGS__ then
warnOnce(
"oneChild",
"You likely don't need this at all! If you were assigning children "
.. "via `React.oneChild(someChildren)`, you can simply use "
.. "`someChildren` directly."
)
end
if not children then
return nil
end
local key, child = next(children)
if not child then
return nil
end
local after = next(children, key)
if after then
error("Expected at most one child, had more than one child.", 2)
end
return React.Children.only(child)
end
return oneChild
end
end)())
__register("RoactCompat/Portal", (function()
local script = __makeProxy({"RoactCompat","Portal"})
return function()
local Packages = script.Parent.Parent
local ReactRoblox = __require(Packages.ReactRoblox)
local ReactGlobals = __require(Packages.ReactGlobals)
local warnOnce = __require(script.Parent.warnOnce)
local function PortalComponent(props)
if ReactGlobals.__DEV__ and ReactGlobals.__COMPAT_WARNINGS__ then
warnOnce("Roact.Portal", "Please use the createPortal API on ReactRoblox instead")
end
return ReactRoblox.createPortal(props.children, props.target)
end
return PortalComponent
end
end)())
__register("RoactCompat/RoactTree", (function()
local script = __makeProxy({"RoactCompat","RoactTree"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local LuauPolyfill = __require(Packages.LuauPolyfill)
local inspect = LuauPolyfill.util.inspect
local ReactRoblox = __require(Packages.ReactRoblox)
type RootType = ReactRoblox.RootType
local warnOnce = __require(script.Parent.warnOnce)
type RoactHandle = {
root: RootType,
key: string | number,
parent: any,
}
local function mount(element: any, parent: any, key: string?): RoactHandle
if ReactGlobals.__DEV__ and ReactGlobals.__COMPAT_WARNINGS__ then
warnOnce("mount", "Please use the createRoot API in ReactRoblox")
end
if parent ~= nil and typeof(parent) ~= "Instance" then
error(
string.format(
"Cannot mount element (`%s`) into a parent that is not a Roblox Instance (got type `%s`) \n%s",
(function()
if element then
return tostring(element.type)
end
return "<unknown>"
end)(),
typeof(parent),
(function()
if parent ~= nil then
return inspect(parent)
end
return ""
end)()
)
)
end
local root
if _G.__ROACT_17_COMPAT_LEGACY_ROOT__ then
root = ReactRoblox.createLegacyRoot(Instance.new("Folder"))
else
root = ReactRoblox.createRoot(Instance.new("Folder"))
end
if parent == nil then
local newParent = Instance.new("Folder")
newParent.Name = "Target"
parent = newParent
end
if key == nil then
if _G.__ROACT_17_COMPAT_LEGACY_ROOT__ then
key = "ReactLegacyRoot"
else
key = "ReactRoot"
end
end
if ReactGlobals.__ROACT_17_INLINE_ACT__ then
ReactRoblox.act(function()
root:render(ReactRoblox.createPortal({ [key] = element }, parent))
end)
else
root:render(ReactRoblox.createPortal({ [key] = element }, parent))
end
return {
root = root,
parent = parent,
key = key :: string,
}
end
local function update(roactHandle: RoactHandle, element)
if ReactGlobals.__DEV__ and ReactGlobals.__COMPAT_WARNINGS__ then
warnOnce("update", "Please use the createRoot API in ReactRoblox")
end
local key = roactHandle.key
local parent = roactHandle.parent
if ReactGlobals.__ROACT_17_INLINE_ACT__ then
ReactRoblox.act(function()
roactHandle.root:render(
ReactRoblox.createPortal({ [key :: string] = element }, parent)
)
end)
else
roactHandle.root:render(
ReactRoblox.createPortal({ [key :: string] = element }, parent)
)
end
return roactHandle
end
local function unmount(roactHandle: RoactHandle)
if ReactGlobals.__DEV__ and ReactGlobals.__COMPAT_WARNINGS__ then
warnOnce("unmount", "Please use the createRoot API in ReactRoblox")
end
if ReactGlobals.__ROACT_17_INLINE_ACT__ then
ReactRoblox.act(function()
roactHandle.root:unmount()
end)
else
roactHandle.root:unmount()
end
end
return {
mount = mount,
update = update,
unmount = unmount,
}
end
end)())
__register("RoactCompat/setGlobalConfig", (function()
local script = __makeProxy({"RoactCompat","setGlobalConfig"})
return function()
local Packages = script.Parent.Parent
local ReactGlobals = __require(Packages.ReactGlobals)
local warnOnce = __require(script.Parent.warnOnce)
return function(_config)
if ReactGlobals.__DEV__ and ReactGlobals.__COMPAT_WARNINGS__ then
warnOnce(
"setGlobalConfig",
"Roact 17 uses a `ReactGlobals.__DEV__` flag to enable development behavior. "
.. "If you're seeing this warning, you already have it enabled. "
.. "Please remove any redundant uses of `setGlobalConfig`."
)
end
end
end
end)())
__register("RoactCompat/warnOnce", (function()
local script = __makeProxy({"RoactCompat","warnOnce"})
return function()
local Packages = script.Parent.Parent
local console = __require(Packages.Shared).console
local warnedAbout = {}
local function warnOnce(name: string, message: string)
if not warnedAbout[name] then
console.warn(
"The legacy Roact API '%s' is deprecated, and will be removed "
.. "in a future release.\n\n%s",
name,
message
)
end
warnedAbout[name] = true
end
return warnOnce
end
end)())
__M["Scheduler/forks/SchedulerHostConfig.default"] = function()
local getCurrentTime = function() return os.clock() * 1000 end
local scheduledHostCallback = nil
local isMessageLoopRunning = false
local yieldInterval = 15
local deadline = 0
local function shouldYieldToHost()
return getCurrentTime() >= deadline
end
local function requestPaint() end
local performWorkUntilDeadline
performWorkUntilDeadline = function()
if scheduledHostCallback ~= nil then
local currentTime = getCurrentTime()
deadline = currentTime + yieldInterval
local cb = scheduledHostCallback
local ok, hasMore = pcall(cb, true, currentTime)
if not ok then
isMessageLoopRunning = false
scheduledHostCallback = nil
error(hasMore)
end
if not hasMore then
isMessageLoopRunning = false
scheduledHostCallback = nil
else
task.spawn(performWorkUntilDeadline)
end
else
isMessageLoopRunning = false
end
end
local function requestHostCallback(callback)
scheduledHostCallback = callback
if not isMessageLoopRunning then
isMessageLoopRunning = true
task.spawn(performWorkUntilDeadline)
end
end
local function cancelHostCallback()
scheduledHostCallback = nil
end
local timeouts = {}
local function requestHostTimeout(callback, ms)
local id = {}
timeouts[id] = true
task.delay((tonumber(ms) or 0) / 1000, function()
if timeouts[id] then
timeouts[id] = nil
callback(getCurrentTime())
end
end)
return id
end
local function cancelHostTimeout(id)
if id ~= nil then timeouts[id] = nil end
end
local function forceFrameRate(fps)
if fps and fps > 0 then yieldInterval = math.floor(1000 / fps) end
end
local function setSchedulerFlags() end
local function getSchedulerFlags() return {} end
return {
requestHostCallback = requestHostCallback,
cancelHostCallback = cancelHostCallback,
requestHostTimeout = requestHostTimeout,
cancelHostTimeout = cancelHostTimeout,
shouldYieldToHost = shouldYieldToHost,
requestPaint = requestPaint,
getCurrentTime = getCurrentTime,
forceFrameRate = forceFrameRate,
setSchedulerFlags = setSchedulerFlags,
getSchedulerFlags = getSchedulerFlags,
}
end
local __publicMap = {
React = "React",
ReactRoblox = "ReactRoblox",
ReactIs = "ReactIs",
RoactCompat = "RoactCompat",
Scheduler = "Scheduler",
Shared = "Shared",
LuauPolyfill = "LuauPolyfill",
Promise = "Promise",
Symbol = "Symbol",
ReactGlobals = "ReactGlobals",
}
local __publicCache = {}
return setmetatable({}, {
__index = function(_, k)
local v = __publicCache[k]
if v ~= nil then return v end
local id = __publicMap[k]
if not id then return nil end
v = __require(id)
__publicCache[k] = v
return v
end,
__iter = function() return next, __publicMap end,
})
