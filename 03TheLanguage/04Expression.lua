function f()
    return -1,-2,-3
end

tbl = {1, 2, 3, x = 99, [3] = 10, [100] = 100, f()}
for k,v in pairs(tbl) do
    print(k, v)
end

-- list of expression
function test(...)
    return ..., 1
end
print(test()) -- nil 1