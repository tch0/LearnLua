<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [6. Lua标准库](#6-lua%E6%A0%87%E5%87%86%E5%BA%93)
  - [6.1 基本函数](#61-%E5%9F%BA%E6%9C%AC%E5%87%BD%E6%95%B0)
  - [6.2 协程控制](#62-%E5%8D%8F%E7%A8%8B%E6%8E%A7%E5%88%B6)
  - [6.3 模块](#63-%E6%A8%A1%E5%9D%97)
  - [6.4 字符串操作](#64-%E5%AD%97%E7%AC%A6%E4%B8%B2%E6%93%8D%E4%BD%9C)
  - [6.5 UTF-8支持](#65-utf-8%E6%94%AF%E6%8C%81)
  - [6.6 表操作](#66-%E8%A1%A8%E6%93%8D%E4%BD%9C)
  - [6.7 数学函数](#67-%E6%95%B0%E5%AD%A6%E5%87%BD%E6%95%B0)
  - [6.8 输入输出设施](#68-%E8%BE%93%E5%85%A5%E8%BE%93%E5%87%BA%E8%AE%BE%E6%96%BD)
  - [6.9 操作系统设施](#69-%E6%93%8D%E4%BD%9C%E7%B3%BB%E7%BB%9F%E8%AE%BE%E6%96%BD)
  - [6.10 调试库](#610-%E8%B0%83%E8%AF%95%E5%BA%93)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# 6. Lua标准库

- Lua标准库以Lua函数形式提供，在C中使用C API实现。其中一些函数提供了语言相关的必要服务(`type getmetatable`)，一些提供了外部服务，比如IO。
- 所有库都是用C API实现，而不是提供为一个分离的C模块。
- 如果一个函数可能失败，那么使用`not status`来测试，而不是`status == nil`。
- Lua标准库包括：
    - 基本库
    - 携程库
    - 包管理库
    - 字符串操作
    - UTF-8支持
    - 表操作
    - 数学库
    - 输入输出
    - 操作系统设施
    - 调试设施
- 除了基本函数和包管理库，所有库函数都是以表的域的形式提供
- 为了能够访问这些库函数，C宿主程序中需要调用`luaL_openlibs`函数，这将会打开所有标准库。
- 也可以使用`lua_requireref`去调用`luaopen_base luaopen_package luaopen_coroutine luaopen_string luaopen_utf8 luaopen_table luaopen_math luaopen_io luaopen_os luaopen_debug`来单独打开每一个库。这些函数定义在`lualib.h`。

## 6.1 基本函数
- 基本库提供Lua核心函数
```
assert (v [, message])                      断言，如果v为false则会抛出一个错误
collectgarbage ([opt [, arg]])              垃圾收集器的通用接口，根据参数执行不同行为：收集、停止、重启、统计、状态获取等。
dofile ([filename])                         打开文件作为Chunk并执行
error (message [, level])                   抛出错误，这个函数不返回
_G                                          全局环境
getmetatable (object)                       获取元表，如果没有返回nil，如果对象的元表有__metatable域则返回它，如果没有返回对象的元表
ipairs (t)                                  返回三个值，(iterator function, table t, 0)，用于 for i,v in ipairs(t) do doby end，用来遍历表中的整数索引从1开始
load (chunk [, chunkname [, mode [, env]]]) 加载一个Chunk
loadfile ([filename [, mode [, env]]])      加载一个块，不过是从文件
next (table [, index])                      得到表的下一个域，用来遍历表
pairs (t)                                   遍历表的所有与，用在通用for循环中，如果有元方法__pairs则会优先调用它
pcall (f [, arg1, ···])                     保护模式下调用函数f，错误不会传播
print (···)                                 快速打印一个值，使用tostring同样规则将参数转换为字符串，非格式化打印，格式化请用string.format,io.write
rawequal (v1, v2)                           不调用__eq的情况下判等，返回布尔值
rawget (table, index)                       获取table[index]的原始值，不使用__index元值，table必须是表
rawlen (v)                                  获取原始长度，不会调用__len，返回正数，比如是表或者字符串
rawset (table, index, value)                不使用__newindex元值，设置table[index]为value
select (index, ···)                         选择一部分index后的参数，索引可以为整数（负数从后往前数），可以为字符串#则返回长度
setmetatable (table, metatable)             设置元表
tonumber (e [, base])                       转number
tostring (v)                                转字符串，考虑元表__tostring, __name域
type (v)                                    类型
_VERSION                                    保存Lua版本的全局字符串变量
warn (msg1, ···)                            警告
xpcall (f, msgh [, arg1, ···])              调用函数
```

## 6.2 协程控制

- 定义在表`coroutine`中：
```
coroutine.close (co)                        关闭协程
coroutine.create (f)                        创建协程，协程类型是thread
coroutine.isyieldable ([co])                是否可以yield，除了主协程或者位于一个不可yield的C函数中的协程都可以yield
coroutine.resume (co [, val1, ···])         恢复协程执行
coroutine.running ()                        返回一个协程以及一个表示当前协程是否是主协程的布尔
coroutine.status (co)                       协程状态：running, suspended, normal, dead
coroutine.wrap (f)                          创建新协程并包装它
coroutine.yield (···)                       yield
```

## 6.3 模块

- 提供加载Lua模块的机制，导出一个函数到全局环境中`require`，其他所有东西都在表`package`中。
```
require (modname)                           加载模块，更多细节查看手册
package.config                              一些包管理的编译期配置，比如路径分隔符\/，分隔不同路径的字符等
package.cpath                               C Loader路径，使用环境变量LUA_CPATH_5_4、或者 LUA_CPATH或者定义在luaconf.h中的默认路径来初始化
package.loaded                              查询模块是否加载
package.loadlib (libname, funcname)         动态链接C库libname
package.path                                Lua Loader路径
package.searchers                           require用来查找路径的搜索器
package.searchpath (name, path [, sep [, rep]]) 在路径中搜索指定名称
```

## 6.4 字符串操作

- 第一个字符索引是1，索引可以为负（解释为反向索引），定义在表`string`中。
- 字符串元表中的`__index`指向`string`表。因此可以以面向对象的风格使用字符串函数。比如`string.byte(s,i)`可以写作`s:byte(i)`。
- 字符串库假设字符使用一个字节编码（这个编码可能不跨平台）。
```
string.byte (s [, i [, j]])                 得到字符内部数值编码
string.char (···)                           返回和参数数量等长的字符串，字符串中每个字符使用参数进行编码
string.dump (function [, strip])            得到函数的二进制表示的字符串（二进制块），可以使用load加载这个函数
string.find (s, pattern [, init [, plain]]) 模式匹配，字符串查找
string.format (formatstring, ···)           字符串格式化
string.gmatch (s, pattern [, init])         按模式遍历字符串，用于for循环
string.gsub (s, pattern, repl [, n])        按模式替换并返回新字符串
string.len (s)                              字符串长度
string.lower (s)                            字符串大写转小写
string.match (s, pattern [, init])          匹配字符串
string.pack (fmt, v1, v2, ···)              格式化之后按照二进制序列化并保存到字符串中，打包
string.packsize (fmt)                       对应string.pack得到的字符串长度
string.rep (s, n [, sep])                   重复一个字符串s n次，以sep分隔
string.reverse (s)                          翻转
string.sub (s, i [, j])                     子串
string.unpack (fmt, s [, pos])              解包
string.upper (s)                            转大写
```

**模式**：
- 用普通字符串描述，用在模式匹配相关的函数中`string.find string.gmatch string.gsub string.match`。
- 细节：
```
Character Class:
A character class is used to represent a set of characters. The following combinations are allowed in describing a character class:

x: (where x is not one of the magic characters ^$()%.[]*+-?) represents the character x itself.
.: (a dot) represents all characters.
%a: represents all letters.
%c: represents all control characters.
%d: represents all digits.
%g: represents all printable characters except space.
%l: represents all lowercase letters.
%p: represents all punctuation characters.
%s: represents all space characters.
%u: represents all uppercase letters.
%w: represents all alphanumeric characters.
%x: represents all hexadecimal digits.
%x: (where x is any non-alphanumeric character) represents the character x. This is the standard way to escape the magic characters. Any non-alphanumeric character (including all punctuation characters, even the non-magical) can be preceded by a '%' to represent itself in a pattern.
[set]: represents the class which is the union of all characters in set. A range of characters can be specified by separating the end characters of the range, in ascending order, with a '-'. All classes %x described above can also be used as components in set. All other characters in set represent themselves. For example, [%w_] (or [_%w]) represents all alphanumeric characters plus the underscore, [0-7] represents the octal digits, and [0-7%l%-] represents the octal digits plus the lowercase letters plus the '-' character.
You can put a closing square bracket in a set by positioning it as the first character in the set. You can put a hyphen in a set by positioning it as the first or the last character in the set. (You can also use an escape for both cases.)

The interaction between ranges and classes is not defined. Therefore, patterns like [%a-z] or [a-%%] have no meaning.

[^set]: represents the complement of set, where set is interpreted as above.
For all classes represented by single letters (%a, %c, etc.), the corresponding uppercase letter represents the complement of the class. For instance, %S represents all non-space characters.

The definitions of letter, space, and other character groups depend on the current locale. In particular, the class [a-z] may not be equivalent to %l.

Pattern Item:
A pattern item can be

a single character class, which matches any single character in the class;
a single character class followed by '*', which matches sequences of zero or more characters in the class. These repetition items will always match the longest possible sequence;
a single character class followed by '+', which matches sequences of one or more characters in the class. These repetition items will always match the longest possible sequence;
a single character class followed by '-', which also matches sequences of zero or more characters in the class. Unlike '*', these repetition items will always match the shortest possible sequence;
a single character class followed by '?', which matches zero or one occurrence of a character in the class. It always matches one occurrence if possible;
%n, for n between 1 and 9; such item matches a substring equal to the n-th captured string (see below);
%bxy, where x and y are two distinct characters; such item matches strings that start with x, end with y, and where the x and y are balanced. This means that, if one reads the string from left to right, counting +1 for an x and -1 for a y, the ending y is the first y where the count reaches 0. For instance, the item %b() matches expressions with balanced parentheses.
%f[set], a frontier pattern; such item matches an empty string at any position such that the next character belongs to set and the previous character does not belong to set. The set set is interpreted as previously described. The beginning and the end of the subject are handled as if they were the character '\0'.
Pattern:
A pattern is a sequence of pattern items. A caret '^' at the beginning of a pattern anchors the match at the beginning of the subject string. A '$' at the end of a pattern anchors the match at the end of the subject string. At other positions, '^' and '$' have no special meaning and represent themselves.

Captures:
A pattern can contain sub-patterns enclosed in parentheses; they describe captures. When a match succeeds, the substrings of the subject string that match captures are stored (captured) for future use. Captures are numbered according to their left parentheses. For instance, in the pattern "(a*(.)%w(%s*))", the part of the string matching "a*(.)%w(%s*)" is stored as the first capture, and therefore has number 1; the character matching "." is captured with number 2, and the part matching "%s*" has number 3.

As a special case, the capture () captures the current string position (a number). For instance, if we apply the pattern "()aa()" on the string "flaaap", there will be two captures: 3 and 5.

Multiple matches:
The function string.gsub and the iterator string.gmatch match multiple occurrences of the given pattern in the subject. For these functions, a new match is considered valid only if it ends at least one byte after the end of the previous match. In other words, the pattern machine never accepts the empty string as a match immediately after another match. As an example, consider the results of the following code:

     > string.gsub("abc", "()a*()", print);
     --> 1   2
     --> 3   3
     --> 4   4
The second and third results come from Lua matching an empty string after 'b' and another one after 'c'. Lua does not match an empty string after 'a', because it would end at the same position of the previous match.
```

打包和解包的格式化字符串：
```
The first argument to string.pack, string.packsize, and string.unpack is a format string, which describes the layout of the structure being created or read.

A format string is a sequence of conversion options. The conversion options are as follows:

<: sets little endian
>: sets big endian
=: sets native endian
![n]: sets maximum alignment to n (default is native alignment)
b: a signed byte (char)
B: an unsigned byte (char)
h: a signed short (native size)
H: an unsigned short (native size)
l: a signed long (native size)
L: an unsigned long (native size)
j: a lua_Integer
J: a lua_Unsigned
T: a size_t (native size)
i[n]: a signed int with n bytes (default is native size)
I[n]: an unsigned int with n bytes (default is native size)
f: a float (native size)
d: a double (native size)
n: a lua_Number
cn: a fixed-sized string with n bytes
z: a zero-terminated string
s[n]: a string preceded by its length coded as an unsigned integer with n bytes (default is a size_t)
x: one byte of padding
Xop: an empty item that aligns according to option op (which is otherwise ignored)
' ': (space) ignored
(A "[n]" means an optional integral numeral.) Except for padding, spaces, and configurations (options "xX <=>!"), each option corresponds to an argument in string.pack or a result in string.unpack.

For options "!n", "sn", "in", and "In", n can be any integer between 1 and 16. All integral options check overflows; string.pack checks whether the given value fits in the given size; string.unpack checks whether the read value fits in a Lua integer. For the unsigned options, Lua integers are treated as unsigned values too.

Any format string starts as if prefixed by "!1=", that is, with maximum alignment of 1 (no alignment) and native endianness.

Native endianness assumes that the whole system is either big or little endian. The packing functions will not emulate correctly the behavior of mixed-endian formats.

Alignment works as follows: For each option, the format gets extra padding until the data starts at an offset that is a multiple of the minimum between the option size and the maximum alignment; this minimum must be a power of 2. Options "c" and "z" are not aligned; option "s" follows the alignment of its starting integer.

All padding is filled with zeros by string.pack and ignored by string.unpack.
```

## 6.5 UTF-8支持

- 对UTF-8编码提供基本支持，提供在表`utf8`中。不提供UniCode的任何支持，所有相关操作比如字符分类、字符含义等都没有支持。
- 略。

## 6.6 表操作

- 提供于表`table`中。
```
table.concat (list [, sep [, i [, j]]])         拼接所有项为字符串
table.insert (list, [pos,] value)               插入
table.move (a1, f, e, t [,a2])                  移动
table.pack (···)                                打包到一个新表中
table.remove (list [, pos])                     移除元素
table.sort (list [, comp])                      原地排序
table.unpack (list [, i [, j]])                 返回所有元素
```

## 6.7 数学函数

- 函数和常量提供在表`math`中。
```
math.abs (x)
math.acos (x)
math.asin (x)
math.atan (y [, x])
math.ceil (x)
math.cos (x)
math.deg (x)
math.exp (x)
math.floor (x)
math.fmod (x, y)
math.huge
math.log (x [, base])
math.max (x, ···)
math.maxinteger
math.min (x, ···)
math.mininteger
math.modf (x)
math.pi
math.rad (x)
math.random ([m [, n]])
math.randomseed ([x [, y]])
math.sin (x)
math.sqrt (x)
math.tan (x)
math.tointeger (x)
math.type (x)
math.ult (m, n)
```

## 6.8 输入输出设施

- IO库提供两种不同风格的文件控制，第一种使用隐式的文件句柄，他们的文件句柄设置为默认输出输出文件。第二种使用显式文件句柄。
- 隐式文件操作在表`io`中提供。
- 显式文件句柄由`io.open`返回，然后操作提供为文件句柄的方法。
- 文件句柄提供了元方法`__gc __close`当调用时会关闭文件。
- 表`io`有三个预定义文件句柄`io.stdin io.stdout io.stderr`。IO库不会关闭这些文件句柄。
```
io.close ([file])
io.flush ()
io.input ([file])
io.lines ([filename, ···])
io.open (filename [, mode])
io.output ([file])
io.popen (prog [, mode])
io.read (···)
io.tmpfile ()
io.type (obj)
io.write (···)
file:close ()
file:flush ()
file:lines (···)
file:read (···)
file:seek ([whence [, offset]])
file:setvbuf (mode [, size])
file:write (···)
```

## 6.9 操作系统设施

- 在表`os`中提供：
```
os.clock ()
os.date ([format [, time]])
os.difftime (t2, t1)
os.execute ([command])
os.exit ([code [, close]])
os.getenv (varname)
os.remove (filename)
os.rename (oldname, newname)
os.setlocale (locale [, category])
os.time ([table])
os.tmpname ()
```

## 6.10 调试库

- 当使用调试库时，需要极其小心，调试库中的一些函数违背了对于Lua代码的基本假设。
- 一些函数可能有性能问题。
- 在表`table`中提供，所有第一个参数为thread的函数都可以省略，以当前thread作为默认。
```
debug.debug ()
debug.gethook ([thread])
debug.getinfo ([thread,] f [, what])
debug.getlocal ([thread,] f, local)
debug.getmetatable (value)
debug.getregistry ()
debug.getupvalue (f, up)
debug.getuservalue (u, n)
debug.sethook ([thread,] hook, mask [, count])
debug.setlocal ([thread,] level, local, value)
debug.setmetatable (value, table)
debug.setupvalue (f, up, value)
debug.setuservalue (udata, value, n)
debug.traceback ([thread,] [message [, level]])
debug.upvalueid (f, n)
debug.upvaluejoin (f1, n1, f2, n2)
```
