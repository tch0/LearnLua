do
    local x = 1 -- local
    y = 1 --global
end
print(x) -- nil
print(y) -- 1

a = 1
b = 2
c = a + b
; (print or io.wrie)(c) -- ; is needed

-- Chunks
s = [[a = 101; b = 99; print("hello")]]

-- load chunk to a function (chunk is )
f = load(s, "test-chunk", "bt", _G)

f()
print(a, b)

-- assignment
a, b = b, a
print(a, b)

-- control structures
-- if
if true then print(true) elseif false then print(false) end
-- while
local i = 0
while i < 10 do
    io.write(i, " ")
    i = i + 1
end
print()

-- repeat until
i = 0
repeat
    io.write(i, " ")
    i = i + 1
until i == 10
print()
-- goto
function func()
    local i = 0
    ::start::
    io.write(i, " ")
    i = i + 1
    if (i < 10) then goto start end
    print()
    do return end -- return statment
    print()
end
func()

-- numerical for
for i = 0, 10, 1 do
    io.write(i, " ")
end
print()

-- generic for
tab = {"Alice", "Bob", "Kim", "Mike", ["Year"] = "2023"}
-- show all values
for k,v in pairs(tab) do
    print(k, v)
end
print()
-- only show interger indexed values which are : Alice, Bob, Kim, Mike
for k,v in ipairs(tab) do
    print(k, v)
end
print()

-- implement pairs
function mypairs(tbl, key)
    local function iterator(tbl, key)
        return next(tbl, key)
    end
    return iterator, tbl, nil
end
for k,v in mypairs(tab) do
    print(k, v)
end
print()

-- implement ipairs
function myipairs(tbl, key)
    local function iterator(tbl, key)
        local k, v = next(tbl, key)
        while (k ~= nil and type(k) ~= "number") do
            k, v = next(tbl, k)
        end
        return k, v
    end
    return iterator, tbl, nil
end
for k,v in myipairs(tab) do
    print(k, v)
end
print()
