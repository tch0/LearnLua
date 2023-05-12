print(getmetatable("hello"))
s = "string"
print(getmetatable(s))

function addobj(a, b)
    return a.val + b.val
end

mt = {["__add"] = addobj} -- metatable
obj1 = {["val"] = 1}
setmetatable(obj1, mt)
obj2 = {["val"] = 2}
setmetatable(obj2, mt)
print(obj1 + obj2)
