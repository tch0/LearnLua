-- single line comment
--[[
multiline comments
--]]

function hello()
    print("hello")
end

print("hello,world!")
print(type(nil)) -- nil
print(type(0)) -- number
print(type(1.1)) -- number
print(type("hello")) -- string
print(type(true)) -- boolean

a = {[hello] = hello}
print(type(a)) -- table
print(type(a.hello)) -- function
print(type(type)) -- function