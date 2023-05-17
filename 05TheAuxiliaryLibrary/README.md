<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [5. 辅助库](#5-%E8%BE%85%E5%8A%A9%E5%BA%93)
  - [5.1 函数和类型](#51-%E5%87%BD%E6%95%B0%E5%92%8C%E7%B1%BB%E5%9E%8B)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# 5. 辅助库

- 位于`luaxlib.h`中，前缀`luaL_`。
- 提供了一些方便的函数用于C和Lua的交互。相对API来说提供更高层次和通用任务的接口。
- 辅助库中的函数都基于基本API编写，所有事情都能够通过基本API完成。
- 一些函数是用来检查C函数参数的。
- `luaL_check*`如果检查未通过会抛出错误。

## 5.1 函数和类型

```
void luaL_addchar (luaL_Buffer *B, char c);                 添加字符到buffer
const void luaL_addgsub (luaL_Buffer *B, const char *s,     添加字符串s到buffer，替换p为r
                         const char *p, const char *r);
void luaL_addlstring (luaL_Buffer *B, const char *s, size_t l);
void luaL_addsize (luaL_Buffer *B, size_t n);
void luaL_addstring (luaL_Buffer *B, const char *s);
void luaL_addvalue (luaL_Buffer *B);
void luaL_argcheck (lua_State *L,                           检查条件是否满足
                    int cond,
                    int arg,
                    const char *extramsg);
int luaL_argerror (lua_State *L, int arg, const char *extramsg);
void luaL_argexpected (lua_State *L,
                       int cond,
                       int arg,
                       const char *tname);
typedef struct luaL_Buffer luaL_Buffer;                     字符串buffer类型
char *luaL_buffaddr (luaL_Buffer *B);                       buffer的内部地址
void luaL_buffinit (lua_State *L, luaL_Buffer *B);          初始化buffer
size_t luaL_bufflen (luaL_Buffer *B);                       buffer长度
char *luaL_buffinitsize (lua_State *L, luaL_Buffer *B, size_t sz);
void luaL_buffsub (luaL_Buffer *B, int n);                  移除特定字节
int luaL_callmeta (lua_State *L, int obj, const char *e);   调用元表
void luaL_checkany (lua_State *L, int arg);                 检查类型
lua_Integer luaL_checkinteger (lua_State *L, int arg);
const char *luaL_checklstring (lua_State *L, int arg, size_t *l);
lua_Number luaL_checknumber (lua_State *L, int arg);
int luaL_checkoption (lua_State *L,
                      int arg,
                      const char *def,
                      const char *const lst[]);
void luaL_checkstack (lua_State *L, int sz, const char *msg);
const char *luaL_checkstring (lua_State *L, int arg);
void luaL_checktype (lua_State *L, int arg, int t);
void *luaL_checkudata (lua_State *L, int arg, const char *tname);
void luaL_checkversion (lua_State *L);
int luaL_dofile (lua_State *L, const char *filename);       加载并运行特定文件
int luaL_dostring (lua_State *L, const char *str);          记载并运行特定字符串
int luaL_error (lua_State *L, const char *fmt, ...);        抛出错误，带格式化字符串
int luaL_execresult (lua_State *L, int stat);
int luaL_fileresult (lua_State *L, int stat, const char *fname);
int luaL_getmetafield (lua_State *L, int obj, const char *e);
int luaL_getmetatable (lua_State *L, const char *tname);
int luaL_getsubtable (lua_State *L, int idx, const char *fname);
const char *luaL_gsub (lua_State *L,
                       const char *s,
                       const char *p,
                       const char *r);
lua_Integer luaL_len (lua_State *L, int index);
int luaL_loadbuffer (lua_State *L,                          加载buffer到一个Lua Chunk
                     const char *buff,
                     size_t sz,
                     const char *name);
int luaL_loadfile (lua_State *L, const char *filename);
int luaL_loadfilex (lua_State *L, const char *filename,
                                            const char *mode);
int luaL_loadstring (lua_State *L, const char *s);
void luaL_newlib (lua_State *L, const luaL_Reg l[]);
void luaL_newlibtable (lua_State *L, const luaL_Reg l[]);
int luaL_newmetatable (lua_State *L, const char *tname);
lua_State *luaL_newstate (void);
void luaL_openlibs (lua_State *L);
T luaL_opt (L, func, arg, dflt);
lua_Integer luaL_optinteger (lua_State *L,
                             int arg,
                             lua_Integer d);
const char *luaL_optlstring (lua_State *L,
                             int arg,
                             const char *d,
                             size_t *l);
lua_Number luaL_optnumber (lua_State *L, int arg, lua_Number d);
const char *luaL_optstring (lua_State *L,
                            int arg,
                            const char *d);
char *luaL_prepbuffer (luaL_Buffer *B);
void luaL_pushfail (lua_State *L);
void luaL_pushresult (luaL_Buffer *B);
void luaL_pushresultsize (luaL_Buffer *B, size_t sz);
int luaL_ref (lua_State *L, int t);
typedef struct luaL_Reg {
  const char *name;
  lua_CFunction func;
} luaL_Reg;
void luaL_requiref (lua_State *L, const char *modname,
                    lua_CFunction openf, int glb);
void luaL_setfuncs (lua_State *L, const luaL_Reg *l, int nup);
void luaL_setmetatable (lua_State *L, const char *tname);
typedef struct luaL_Stream {                            标准IO库使用的文件流句柄
  FILE *f;
  lua_CFunction closef;
} luaL_Stream;
void *luaL_testudata (lua_State *L, int arg, const char *tname);
const char *luaL_tolstring (lua_State *L, int idx, size_t *len);
void luaL_traceback (lua_State *L, lua_State *L1, const char *msg,
                     int level);
int luaL_typeerror (lua_State *L, int arg, const char *tname);
const char *luaL_typename (lua_State *L, int index);
void luaL_unref (lua_State *L, int t, int ref);
void luaL_where (lua_State *L, int lvl);
```