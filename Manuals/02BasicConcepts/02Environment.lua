a = {}
print(_ENV.a)
print(a)
print(_ENV)
_ENV._ENV = {} -- a new variable _ENV in _ENV environment
print(a)
print(_ENV) -- the external _ENV environment
print(_ENV.a)
print(_ENV._ENV) -- the nested new _ENV in this chunk
print(_ENV._ENV.a) -- nil
print(_G) -- _ENV is equal to _G by default

_ENV.b = {}
print(b)
print(_ENV.b)
print(_ENV == _G) -- true

load()