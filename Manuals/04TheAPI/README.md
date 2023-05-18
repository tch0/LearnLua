<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [4. C API](#4-c-api)
  - [4.1 栈](#41-%E6%A0%88)
  - [4.2 C Closures](#42-c-closures)
  - [4.3 Registry注册表](#43-registry%E6%B3%A8%E5%86%8C%E8%A1%A8)
  - [4.4 C中的错误处理](#44-c%E4%B8%AD%E7%9A%84%E9%94%99%E8%AF%AF%E5%A4%84%E7%90%86)
  - [4.5 在C中处理yield](#45-%E5%9C%A8c%E4%B8%AD%E5%A4%84%E7%90%86yield)
  - [4.6 类型与函数](#46-%E7%B1%BB%E5%9E%8B%E4%B8%8E%E5%87%BD%E6%95%B0)
  - [4.7 调试接口](#47-%E8%B0%83%E8%AF%95%E6%8E%A5%E5%8F%A3)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# 4. C API

- 这一节介绍Lua的C语言API，用于宿主程序中和Lua程序进行交流。
- 所有的API和相关类型都定义在[lua.h](https://github.com/lua/lua/blob/master/lua.h)中。
- 集成Lua源码的选择：
    - 可以选择将Lua（C源码）作为C++编译使用C++ABI，那么直接使用C++编译器编译即可。
    - 如果需要将Lua作为C编译使用C的ABI，那么在C++中调用时CABI的函数需要对所有声明加上`extern "C"`，这一步需要自己来做。加入头文件`lua.hpp`，和其他Lua头文件放到一个目录即可。这个文件在官网下载Lua时是自带的（但源码中没有）。没有直接在Lua头文件中添加`extern "C"`是因为Lua的源码同样可以作为C++编译，留给了用户自己选择。
    ```C++
    // lua.hpp
    extern "C" {
    #include "lua.h"
    #include "lualib.h"
    #include "lauxlib.h"
    }
    ```
    - 一般纯C语言写的库的惯用做法都是用C编译器编译，通过C++调用时声明为`extern "C"`，也就是说无论什么语言调用都使用C ABI。通过检测`__cplusplus`宏来做：
    ```C++
    // begining of file
    #ifdef __cplusplus
    extern "C" {
    #endif

    // end of file
    #ifdef __cplusplus
    }
    #endif
    ```
- 下面所说的函数，可能并不是一个真正的函数，比如API中可能通过宏来提供。除非显式说明，每一个这种宏都只使用每个参数一次（除非是第一个Lua State参数），所以调用的参数不要用任何副作用。
- 大多数Lua的C API都不检查参数有效性和一致性，可以通过编译Lua时定义宏`LUA_USE_APICHECK`来做检查。
- Lua库是完全可重入的，没有任何全局变量。将所有需要的信息放在一个动态的数据结构中，成为Lua State。
- 每个Lua State有一个或者多个thread（线程？），对应于独立的或者合作的Lua执行代码。类型`lua_State`保存了这个线程，同样在线程中也可以访问到这个`lua_State`。
- 库中每个函数的第一个参数都是`lua_State*`，除了`lua_newstate`（创建指向主线程的新状态）。

## 4.1 栈

- Lua使用一个虚拟栈来传递值到C以及从C中接收值。这个栈每个元素都是一个Lua value（nil, number, string, etc）。
- 可以通过传入API中的lua状态参数获取到这个栈。
- Lua中调用C函数时，调用的函数被分配一个新栈，独立于其他所有活跃的正在运行的栈。这个栈初始时包含了所有传给C函数的参数，这也是C函数中用来存放Lua的临时值以及保存返回给主调函数的返回值的地方（见`lua_CFunction`）。
- API中访问栈的操作并不需要严格按照栈的要求，先出栈再访问，而是可以按照索引访问任意元素。`1`表示栈底，负索引则表示相对栈顶的相对位置。
    - 更具体来说，如果栈有n个元素，索引`1`表示第一个（推入栈中的）元素（栈底），索引`n`表示栈顶也就是最后一个元素。同样`-1`指向栈顶，`-n`指向栈底。

栈的大小：
- 如果你和Lua API交互，那么你需要对栈溢出负责。当调用任何API时，需要保证栈中有足够空间保存所有结果。
- 其中有一个例外：C中调用没有固定数量参数的Lua函数时（`lua_call`），Lua会保证栈有足够空间保存所有结果，但不保证有额外空间。在这种调用中压栈之前需要使用`lua_checkstack`。
- Lua中调用C函数时，保证栈中至少有`LUA_MINSTACK`个元素空间，这是可以安全压入的空间，默认值是20。所以通常不需要担心栈不够用。如果担心不够，压入新元素前使用`lua_checkstack`进行检查。

合法索引：
- API中接受栈索引的函数只能在合法索引下工作。
- 合法索引是指该位置保存了可修改的Lua值的索引。包含`1~n -1~-n`以及一些伪索引，伪索引（pesudo-indeices）表示一些能够在C代码中访问但是不在栈中的位置。通常用来访问注册表或者C函数中的upvalue。
- 对这些函数来说不合法的索引会被视作其中包含一个虚拟的类型`LUA_TNONE`，表现得像一个`nil`。

字符串指针：
- 一些API返回一个指向栈中Lua字符串的指针（`const char*`）。`lua_pushfstring lua_pushlstring lua_pushstring lua_tolstring`以及辅助库中的`luaL_checklstring luaL_checkstring luaL_tolstring`。
- 同行来说，Lua的垃圾收集会回收内存并使指针失效。为了安全访问这些指针，这些API保证任何指向栈索引中的字符串的指针不会失效，直到对应字符串被从栈中移除（可以被移动到其他索引）。当索引是伪索引时，保证在函数调用期间都存在。
- 某些调试接口也返回字符串指针，也保证在主调函数活跃期间字符串指针不会失效。
- 除了这些保证之外，没有额外保证，垃圾收集可能在回收内部字符串的内存使指针失效。

## 4.2 C Closures

- 当一个C函数创建的时候，可以将一些值关联在其之上，创建出一个C闭包（C closure，见`lua_pushcclosure`）。这些值称为**upvalues**（Lua函数中能访问到的外部局部变量也叫upvalue）。这些值可以在函数调用的任何时候被访问到。
- C函数调用时，这些upvalues放在了特定的伪索引下，这些伪索引通过`lua_upvalueindex`创建。第一个是`lua_upvalueindex(1)`以此类推。超过当前upovalue数目的伪索引都是可接受但是不合法的。
- C闭包中可以更改对应upvalue的值。

## 4.3 Registry注册表

- Lua提供了一个注册表（Registry），一个预定义的表，可以被C代码使用以存储任何他需要的Lua值。
- 这个表总是可以通过伪索引`LUA_REGISTRYINDEX`访问。
- 任何C库都可以在这个表中存储数据，但是必须要选择和其他库不同的键名。通常来说，应该讲库名称包含在键里面（或者使用一个轻量userdata的C对象地址或者任何代码中创建的Lua对象作为键），以避免冲突。
- 并且以下划线以及大写字母开头的字符串键由Lua保留，用户不应该使用。
- 整数键被引用机制（reference machanism，`luaL_ref`）保留，不应该用于其他用途。
- 当创建Lua State时，注册表中就保存了一些预定义的值。这些预定义的值是整数索引，作为常数定义在`lua.h`中。
    - `LUA_RIDX_MAINTHREAD`：这个索引中保存这个状态的main thread（即和state一起创建的那个）。
    - `LUA_RIDX_GLOBALS`：这个索引中保存全局环境。

## 4.4 C中的错误处理

- 在C中，Lua使用C语言的`longjmp`机制处理错误（如果用C++编译则使用异常机制）。搜索源码中的`LUAI_THROW`查看细节。
- 当Lua中发生一个错误时，这个错误会抛出，在C中他会做一个long jump，在保护环境中使用`setjmp`设置恢复点，任何错误的`longjmp`都会跳转到最近活跃的恢复点。
- 在C中可以使用`lua_error`显式抛出一个错误。
- API中的大多函数都可能抛出错误，比如内存错误。
- 在保护环境外抛出错误，将会调用一个panic函数（通过`lua_atpanic`设置），其中会调用`abort`终止宿主程序。可以自己设置panic函数，在其中不返回而是long jump到Lua外的恢复点可以避免终止宿主程序。
- `lua.h`中定义了一些状态码，API使用这些状态码来表示不同的错误：
```
LUA_OK (0): no errors.
LUA_ERRRUN: a runtime error.
LUA_ERRMEM: memory allocation error. For such errors, Lua does not call the message handler.
LUA_ERRERR: error while running the message handler.
LUA_ERRSYNTAX: syntax error during precompilation.
LUA_YIELD: the thread (coroutine) yields.
LUA_ERRFILE: a file-related error; e.g., it cannot open or read the file.
```

## 4.5 在C中处理yield

- Lua内部使用`longjmp`处理协程的yield。因此如果一个C函数`foo`调用了一个API，并且这个API中yield了（直接或者间接），那么Lua再也不能回到`foo`了，因为`longjmp`会移除栈帧。
- 为了避免这种情况，当yield跨越API边界时，Lua会抛出一个错误，除了函数`lua_yieldk lua_callk lua_pcallk`。这些函数会接收一个参数`k`作为continuation function，用来恢复yield后的协程执行。
- 关于continuation function的更多细节见文档。

## 4.6 类型与函数

```
int lua_absindex (lua_State *L, int idx);                       转换索引为等价的绝对索引
typedef void * (*lua_Alloc) (void *ud,                          Lua使用的内存分配函数类型
                             void *ptr,
                             size_t osize,
                             size_t nsize);
void lua_arith (lua_State *L, int op);                          执行栈顶两个（或者一个）操作数的算术或者按位运算，弹出操作数，将结果压入栈顶
lua_CFunction lua_atpanic (lua_State *L, lua_CFunction panicf); 设置panic函数并返回旧的
void lua_call (lua_State *L, int nargs, int nresults);          调用Lua函数
void lua_callk (lua_State *L,                                   就像lua_call，但允许调用的函数yield
                int nargs,
                int nresults,
                lua_KContext ctx,
                lua_KFunction k);
typedef int (*lua_CFunction) (lua_State *L);                    用于Lua中调用的C函数类型
int lua_checkstack (lua_State *L, int n);                       检查栈中的额外空间
void lua_close (lua_State *L);                                  关闭所有to-be-closed变量，回收内存
void lua_closeslot (lua_State *L, int index);                   关闭给定索引的to-be-closed变量
int lua_closethread (lua_State *L, lua_State *from);            关闭一个线程
int lua_compare (lua_State *L, int index1, int index2, int op); 执行两个Lua值的比较运算
void lua_concat (lua_State *L, int n);                          连接运算，连接栈顶n个值
void lua_copy (lua_State *L, int fromidx, int toidx);           拷贝一个元素，从一个索引到另一个
void lua_createtable (lua_State *L, int narr, int nrec);        创建新表并压入栈中
int lua_dump (lua_State *L,                                     将以Lua函数dump成一个二进制chunk
                        lua_Writer writer,
                        void *data,
                        int strip);
int lua_error (lua_State *L);                                   抛出lua错误
int lua_gc (lua_State *L, int what, ...);                       控制垃圾收集行为，执行垃圾收集、停止、统计等
lua_Alloc lua_getallocf (lua_State *L, void **ud);              得到给定状态的垃圾收集函数
int lua_getfield (lua_State *L, int index, const char *k);      获取栈中的表的给定域
void *lua_getextraspace (lua_State *L);                         获取Lua状态的底层内存指针
int lua_getglobal (lua_State *L, const char *name);             获取全局变量的值，压入栈顶
int lua_geti (lua_State *L, int index, lua_Integer i);          获取栈中的表的给定整数索引处的值
int lua_getmetatable (lua_State *L, int index);                 获取特定值的元表
int lua_gettable (lua_State *L, int index);                     获取栈中的表中的值
int lua_gettop (lua_State *L);                                  获取栈顶元素索引
int lua_getiuservalue (lua_State *L, int index, int n);         获取full userdata关联第n个user value
void lua_insert (lua_State *L, int index);                      移动栈顶元素到给定索引
typedef ... lua_Integer;                                        Lua整数类型，默认是long long
int lua_isboolean (lua_State *L, int index);                    判断栈的特定位置是否是一个布尔
int lua_iscfunction (lua_State *L, int index);                  判断元素是否是c函数
int lua_isfunction (lua_State *L, int index);                   判断是否是Lua函数，下面都是类型判断
int lua_isinteger (lua_State *L, int index);
int lua_islightuserdata (lua_State *L, int index);
int lua_isnil (lua_State *L, int index);
int lua_isnone (lua_State *L, int index);                       判断索引是否合法
int lua_isnoneornil (lua_State *L, int index);
int lua_isnumber (lua_State *L, int index);
int lua_isstring (lua_State *L, int index);
int lua_istable (lua_State *L, int index);
int lua_isthread (lua_State *L, int index);
int lua_isyieldable (lua_State *L);
typedef ... lua_KContext;                                       continuation-function contexts的类型，数值类型，能够存储指针的类型
typedef int (*lua_KFunction) (lua_State *L, int status, lua_KContext ctx);  continuation-function的类型
void lua_len (lua_State *L, int index);                         长度，等价于Lua中的#运算符
int lua_load (lua_State *L,                                     加载一个Lua Chunk
              lua_Reader reader,
              void *data,
              const char *chunkname,
              const char *mode);
lua_State *lua_newstate (lua_Alloc f, void *ud);                创建新的state，并返回它的主线程
void lua_newtable (lua_State *L);                               创建一个新的空表，压入栈中
lua_State *lua_newthread (lua_State *L);                        创建一个新线程，压入栈中
void *lua_newuserdatauv (lua_State *L, size_t size, int nuvalue);   创建新的full user data
int lua_next (lua_State *L, int index);                         栈中弹出索引，并压入对应键值
typedef ... lua_Number;                                         Lua中的float类型
int lua_numbertointeger (lua_Number n, lua_Integer *p);         转换float为整数
int lua_pcall (lua_State *L, int nargs, int nresults, int msgh);    保护模式调用一个函数
int lua_pcallk (lua_State *L,                                   就像lua_pcall，允许调用函数yield
                int nargs,
                int nresults,
                int msgh,
                lua_KContext ctx,
                lua_KFunction k);
void lua_pop (lua_State *L, int n);                             出栈n个元素，实现为宏
void lua_pushcclosure (lua_State *L, lua_CFunction fn, int n);  压入一个C闭包到栈中
void lua_pushcfunction (lua_State *L, lua_CFunction f);         压入一个C函数到栈中
const char *lua_pushfstring (lua_State *L, const char *fmt, ...);   压入格式化字符串
void lua_pushglobaltable (lua_State *L);                        压入全局环境
void lua_pushinteger (lua_State *L, lua_Integer n);             压入整数，下面都是压入各种值
void lua_pushlightuserdata (lua_State *L, void *p);
const char *lua_pushliteral (lua_State *L, const char *s);
const char *lua_pushlstring (lua_State *L, const char *s, size_t len);
void lua_pushnil (lua_State *L);
void lua_pushnumber (lua_State *L, lua_Number n);
const char *lua_pushstring (lua_State *L, const char *s);
int lua_pushthread (lua_State *L);
void lua_pushvalue (lua_State *L, int index);
const char *lua_pushvfstring (lua_State *L,
                              const char *fmt,
                              va_list argp);
int lua_rawequal (lua_State *L, int index1, int index2);        判断两个值是否primitively equal（不会调用__eq元方法）
int lua_rawget (lua_State *L, int index);                       类似于 lua_gettable，但不会调用元方法
int lua_rawgeti (lua_State *L, int index, lua_Integer n);
int lua_rawgetp (lua_State *L, int index, const void *p);
lua_Unsigned lua_rawlen (lua_State *L, int index);
void lua_rawset (lua_State *L, int index);
void lua_rawseti (lua_State *L, int index, lua_Integer i);
void lua_rawsetp (lua_State *L, int index, const void *p);
typedef const char * (*lua_Reader) (lua_State *L,               lua_load使用的reader函数
                                    void *data,
                                    size_t *size);
void lua_register (lua_State *L, const char *name, lua_CFunction f);    设置C函数为全局变量name的新值
void lua_remove (lua_State *L, int index);                      移除给定元素，移动后面的元素
void lua_replace (lua_State *L, int index);                     用栈顶元素替换给定元素，出栈
int lua_resetthread (lua_State *L);                             已废弃
int lua_resume (lua_State *L, lua_State *from, int nargs,       恢复协程
                          int *nresults);
void lua_rotate (lua_State *L, int idx, int n);                 旋转栈中元素
void lua_setallocf (lua_State *L, lua_Alloc f, void *ud);       设置内存分配函数
void lua_setfield (lua_State *L, int index, const char *k);     t[k] = v，设置域
void lua_setglobal (lua_State *L, const char *name);            设置全局变量
void lua_seti (lua_State *L, int index, lua_Integer n);
int lua_setiuservalue (lua_State *L, int index, int n);
int lua_setmetatable (lua_State *L, int index);
void lua_settable (lua_State *L, int index);
void lua_settop (lua_State *L, int index);
void lua_setwarnf (lua_State *L, lua_WarnFunction f, void *ud);
typedef struct lua_State lua_State;                             Lua状态类型
int lua_status (lua_State *L);                                  返回线程L状态
size_t lua_stringtonumber (lua_State *L, const char *s);        字符串到整数
int lua_toboolean (lua_State *L, int index);                    转到布尔
lua_CFunction lua_tocfunction (lua_State *L, int index);        转换一个值为C函数
void lua_toclose (lua_State *L, int index);                     标记一个索引为to-be-closed slot
lua_Integer lua_tointeger (lua_State *L, int index);
lua_Integer lua_tointegerx (lua_State *L, int index, int *isnum);
const char *lua_tolstring (lua_State *L, int index, size_t *len);
lua_Number lua_tonumber (lua_State *L, int index);
lua_Number lua_tonumberx (lua_State *L, int index, int *isnum);
const void *lua_topointer (lua_State *L, int index);
const char *lua_tostring (lua_State *L, int index);
lua_State *lua_tothread (lua_State *L, int index);
void *lua_touserdata (lua_State *L, int index);
int lua_type (lua_State *L, int index);                         获取类型
const char *lua_typename (lua_State *L, int tp);                将lua_type返回值转换成字符串
typedef ... lua_Unsigned;                                       整数类型
int lua_upvalueindex (int i);                                   返回第i个upvalue的索引
lua_Number lua_version (lua_State *L);                          lua版本
typedef void (*lua_WarnFunction) (void *ud, const char *msg, int tocont);   lua警告函数，lua中的warn会调用
void lua_warning (lua_State *L, const char *msg, int tocont);   发起一个lua警告
typedef int (*lua_Writer) (lua_State *L,                        lua_dump的writer函数类型
                           const void* p,
                           size_t sz,
                           void* ud);
void lua_xmove (lua_State *from, lua_State *to, int n);         交换两个线程中的值
int lua_yield (lua_State *L, int nresults);                     yield
int lua_yieldk (lua_State *L,                                   挂起一个协程
                int nresults,
                lua_KContext ctx,
                lua_KFunction k);
```

## 4.7 调试接口

```
typedef struct lua_Debug {
  int event;
  const char *name;           /* (n) */
  const char *namewhat;       /* (n) */
  const char *what;           /* (S) */
  const char *source;         /* (S) */
  size_t srclen;              /* (S) */
  int currentline;            /* (l) */
  int linedefined;            /* (S) */
  int lastlinedefined;        /* (S) */
  unsigned char nups;         /* (u) number of upvalues */
  unsigned char nparams;      /* (u) number of parameters */
  char isvararg;              /* (u) */
  char istailcall;            /* (t) */
  unsigned short ftransfer;   /* (r) index of first value transferred */
  unsigned short ntransfer;   /* (r) number of transferred values */
  char short_src[LUA_IDSIZE]; /* (S) */
  /* private part */
  other fields
} lua_Debug;                                保存函数或者活跃记录的各种信息的结构
lua_Hook lua_gethook (lua_State *L);        返回特定钩子函数
int lua_gethookcount (lua_State *L);        返回钩子函数数量
int lua_gethookmask (lua_State *L);
int lua_getinfo (lua_State *L, const char *what, lua_Debug *ar);        获取一个特定函数或者函数调用的信息
const char *lua_getlocal (lua_State *L, const lua_Debug *ar, int n);
int lua_getstack (lua_State *L, int level, lua_Debug *ar);
const char *lua_getupvalue (lua_State *L, int funcindex, int n);
typedef void (*lua_Hook) (lua_State *L, lua_Debug *ar);                 调试钩子函数类型
void lua_sethook (lua_State *L, lua_Hook f, int mask, int count);       设置钩子函数
const char *lua_setlocal (lua_State *L, const lua_Debug *ar, int n);    设置局部变量
const char *lua_setupvalue (lua_State *L, int funcindex, int n);
void *lua_upvalueid (lua_State *L, int funcindex, int n);               返回一个upvalue的唯一id
void lua_upvaluejoin (lua_State *L, int funcindex1, int n1,
                                    int funcindex2, int n2);
```