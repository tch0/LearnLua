function hello()
    error("a test eror")
end

res, message = pcall(hello)
print(res)
if (not(res)) then
    print(message)
end

warn("@on") -- a control message to open the warning message print
warn("a warning occured")
warn("@off")
warn("a warning message that won't show")