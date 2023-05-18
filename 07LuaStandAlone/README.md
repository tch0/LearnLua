<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [7. Lua宿主程序](#7-lua%E5%AE%BF%E4%B8%BB%E7%A8%8B%E5%BA%8F)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# 7. Lua宿主程序

- Lua虽然被设计为一个扩展语言，用来嵌入宿主C程序中。但也可以作为一个独立的语言。
- Lua源码中提供了`lua`程序作为解释器，调用lua核心库。
- 使用：
```
lua [options] [script [args]]

options:
-e stat: execute string stat;
-i: enter interactive mode after running script;
-l mod: "require" mod and assign the result to global mod;
-l g=mod: "require" mod and assign the result to global g;
-v: print version information;
-E: ignore environment variables;
-W: turn warnings on;
--: stop handling options;
-: execute stdin as a file and stop handling options.
```
- 更多细节见: https://www.lua.org/manual/5.4/manual.html#7