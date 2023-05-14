<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [3. 语言核心](#3-%E8%AF%AD%E8%A8%80%E6%A0%B8%E5%BF%83)
  - [3.1 词法约定](#31-%E8%AF%8D%E6%B3%95%E7%BA%A6%E5%AE%9A)
  - [3.2 变量](#32-%E5%8F%98%E9%87%8F)
  - [3.3 语句](#33-%E8%AF%AD%E5%8F%A5)
  - [3.4 表达式](#34-%E8%A1%A8%E8%BE%BE%E5%BC%8F)
  - [3.5 可见性规则](#35-%E5%8F%AF%E8%A7%81%E6%80%A7%E8%A7%84%E5%88%99)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# 3. 语言核心

这个章节描述词法、语法、语义。使用EBNF描述语法。
- `{a}`表示0个或者多个a。
- `[a]`表示0个或者1个a。

首先完整的Lua语法(EBNF)：
```EBNF
chunk ::= block
block ::= {stat} [retstat]
stat ::=  ';' | 
    varlist '=' explist | 
    functioncall | 
    label | 
    break | 
    goto Name | 
    do block end | 
    while exp do block end | 
    repeat block until exp | 
    if exp then block {elseif exp then block} [else block] end | 
    for Name '=' exp ',' exp [',' exp] do block end | 
    for namelist in explist do block end | 
    function funcname funcbody | 
    local function Name funcbody | 
    local attnamelist ['=' explist] 
attnamelist ::=  Name attrib {',' Name attrib}
attrib ::= ['<' Name '>']
retstat ::= return [explist] [';']
label ::= '::' Name '::'
funcname ::= Name {'.' Name} [':' Name]
varlist ::= var {',' var}
var ::=  Name | prefixexp '[' exp ']' | prefixexp '.' Name 
namelist ::= Name {',' Name}
explist ::= exp {',' exp}
exp ::=  nil | false | true | Numeral | LiteralString | '...' | functiondef | 
    prefixexp | tableconstructor | exp binop exp | unop exp 
prefixexp ::= var | functioncall | '(' exp ')'
functioncall ::=  prefixexp args | prefixexp ':' Name args 
args ::=  '(' [explist] ')' | tableconstructor | LiteralString 
functiondef ::= function funcbody
funcbody ::= '(' [parlist] ')' block end
parlist ::= namelist [',' '...'] | '...'
tableconstructor ::= '{' [fieldlist] '}'
fieldlist ::= field {fieldsep field} [fieldsep]
field ::= '[' exp ']' '=' exp | Name '=' exp | exp
fieldsep ::= ',' | ';'
binop ::=  '+' | '-' | '*' | '/' | '//' | '^' | '%' | 
    '&' | '~' | '|' | '>>' | '<<' | '..' | 
    '<' | '<=' | '>' | '>=' | '==' | '~=' | 
    and | or
unop ::= '-' | not | '#' | '~'
```

## 3.1 词法约定

- Lua是形式自由的语言，首先忽略token之间的空格和注释。除非他们是两个token之间的分隔符。将ASCII中的空格、LF、CR、水平和垂直制表符视为空格。
- 标识符（identfiers或者names）：和C类似，字母数字下划线，数字不能作为开头。不能是保留字，用作变量名、表的键名、标签名。
- 下列关键字是保留字不能用作标识符：
```
and       break     do        else      elseif    end
false     for       function  goto      if        in
local     nil       not       or        repeat    return
then      true      until     while
```
- Lua是大小写敏感的。 按照惯例，程序员应避免与关键字仅大小写区别的标识符，并且应该避免创建以一个或者两个下划线开头的标识符。
- 下列字符串也被视为token：
```
+     -     *     /     %     ^     #
&     ~     |     <<    >>    //
==    ~=    <=    >=    <     >     =
(     )     {     }     [     ]     ::
;     :     ,     .     ..    ...
```
- 单引号或者双引号用于短字符串字面量（short literal string）：
    - 其中可以有转义字符：`\a \b \f \n \r \t \v \\ \" \'`。
    - 还有一个有用的转义字符`\z`表示跳过后续的空格字符，包括换行。可以用在长字符串中一行的末尾，代码多行表示但是却不将换行包括在字符串中。
    - 可以在短字符串中指定任何字节，包括空字符`\0`。
    - 类似于C，可以通过指定ASCII编码来指定字符`\xXX \ddd`。
    - 可以通过`\u{XXX}`将UTF-8编码插入到字符串中，`{}`是必须的，`XXX`是一个或者多个Unicode码点。
- 字符串字面量可以定义为长格式：
    - 通过长括号：`[[ ]]`，`[=[ ]=]`，`[==[ ]==]`分为多个等级，从level0到任意级。
    - 其中可以包含任意字符序列，但是不能包含使用到的这一级长括号。
    - 字符串可以有多行，并且不对转义序列进行转义，而是保持原始含义。类似于C++的原始字符串字面量。
    - `[[`后和`]]`前是换行而不是其他字符则忽略这个换行。
- 数值常量可以写作一个可选小数部分和一个可选十进制指数部分，使用`e E`。也可以使用`0x 0X`定义十六进制常量。十六进制依然可以有可选小数部分和可选的二进制指数，使用`p P`。比如`0x1.fp10`是合法的，表示`0x1f/16 * 2^10`。
- 有基数和指数的常量表示一个`float`。如果它的值是一个整数，那么是一个`integer`。
- 行注释：`--`。
- 多行注释：`--[[ --]]`。

## 3.2 变量

- 变量是存放值的位置，三种变量：全局（global）、局部（local）、表的域（table fields）。
- 一个单独的标识符可以表示一个全局、局部变量或者一个形参名称（这是一个特定种类的局部变量）。
```EBNF
var ::= Name
```
- 所有未显式声明为`local`的变量都假设为全局。局部变量具有词法作用域，比如函数内部定义的仅在函数内部可见。
- 对变量第一次赋值之前，它的值是`nil`。
- `[]`用来进行索引。
```EBNF
var ::= prefixexp '[' exp ']'
```
- 通过索引对表项的访问，这个操作的含义可以通过元表的修改。
- `var.Name`仅仅是`var["Name"]`的语法糖。
```EBNF
var ::= prefixexp '.' Name
```
- 对全局变量`x`的访问等价于`_ENV.x`。因为Lua块（Chunk）的编译方式，`_ENV`本身并不是全局的（它只是外部的）。

## 3.3 语句

包括：块、赋值、控制结构、函数调用、变量声明。

**块（Blocks）**：
- 块是一个语句列表：
```EBNF
block ::= {stat}
```
- Lua可以有空语句，可以使用`;`分隔语句：
```EBNF
stat ::= ';'
```
- 因为`;`并非强制使用，所以由于括号的使用下列代码可能会有歧义：
    ```Lua
    a = b + c
    (print or io.write)("done")
    ```
    - 可以解释为：
    ```Lua
    a = b + c(print or io.write)("done")
    a = b + c; (print or io.write)("done")
    ```
    - Lua总是解释为前者，也就是括号优先解析为函数调用，如果有歧义则必须使用`;`分隔语句。
    - 我了避免这种歧义，最好在语句开头就是括号时，前面加一个分号：
    ```Lua
    ; (print or io.write)("done")
    ```
- 也可以显式用`do end`声明一个语句：
```EBNF
stat ::= do block end
```
- 显式块在控制变量作用域时很有用。

**块（Chunks）**：
- Lua的编译单元也叫块，不过是Chunk这个块，语法上就是一个Block：
```EBNF
chunk ::= block
```
- Lua将一个Chunk视为一个匿名函数的函数体，这个函数有可变的参数数量。
- 所有一个Chunk可以定义局部变量、接受参数、返回值，并且编译时加入一个唯一外部变量`_ENV`作为环境。
- 一个Chunk可以被存储在一个文件中或者一个宿主程序中的字符串中，为了执行一个Chunk，Lua需要先加载它，预编译为虚拟机指令，然后在虚拟机中解释执行预编译后的指令。
- 一个Chunk也可以被预编译为二进制形式，使用宿主程序`luac`即可编译，查看`string.dump`以获取细节。程序的源码形式和编译后形式是等价可互换的，Lua会自动检测文件形式。见`load`函数。

**赋值（Assignment）**：
- Lua允许多重赋值，左边可以是一个变量列表，右边可以是一个表达式列表。通过逗号分隔。
```EBNF
stat ::= varlist '=' explist
varlist ::= var {',' var}
explist ::= exp {',' exp}
```
- 如果左边变量的值被用在右边的表达式中，Lua保证所有左边变量的读取在赋值之前：
```Lua
i = 3
i, a[i] = i+1, 20 -- result : a[3] = 20
x, y = y, x -- exchange x and y
```
- 对table域的复制可能因为元表`__newindex`被修改含义。

**控制结构（control structures）**：
- `if while repeat`：
```EBNF
stat ::= while exp do block end
stat ::= repeat block until exp
stat ::= if exp then block {elseif exp then block} [else block] end
```
- 控制结果的条件表达式可以返回任何类型。`false nil`视为假，其余所有值（包括数值0和空字符串）都视为真。
- 其中repeat中的条件可以引用块内部定义的局部变量。
- `goto`语句：
```EBNF
stat ::= goto Name
stat ::= label
local ::= '::' Name '::'
```
- `break`终止其外层的`while repeat for`循环：
```EBNF
stat ::= break
```
- `return`语句：用来从函数或者chunk（被视为匿名函数）返回，可以返回多个值。只能是它所在的块内的最后一个语句。如果`return`需要被用在块中间，使用`do return end`，这是它是所在块的最后一个语句。
```EBNF
stat ::= return [explist] [';']
```

**For循环**：
- 数值`for`：
```EBNF
stat ::= for Name '=' exp ',' exp [',' exp] do block end
```
- 其中给定的`Name`是这个块内的局部变量，三个表达式分别是初值、限制、和增量。如果初值和增量都是整数，那么变量是整数，否则三个值都被转换为浮点数。
- 如果增量为正，那么`<=`的时候运行，为0会抛出错误，如果为负，那么`>=`时运行。
- 不应该在循环中更改循环变量的值。
- 例子：
```lua
-- print 0 to 10
for i = 0, 10, 1 do
    io.write(i, " ")
end
```
- 通用`for`：
```EBNF
stat ::= for namelist in explist do block end
namelist ::= Name {',' Name}
```
- 循环的求值过程细节：
    - 列表中的变量是`for`循环块内的局部变量，其中第一个称之为控制变量。
    - 首先对`explist`求值产生四个值：迭代函数、一个状态、一个控制变量的初值、一个关闭变量。
    - 在每一轮迭代时，Lua调用迭代函数，传入两个参数：状态和控制变量。结果将会被赋给循环变量（其中第一个作为控制变量，在下一轮中继续传入，初值是`explist`求值产生的第三个值）。
    - 如果控制变量变成了`nil`，那么循环结束，否则进入下一轮循环。
    - 关闭变量表现得像一个将要关闭的变量一样（to-be-closed variable），可以用在循环结束时释放资源，除此之外对循环没有任何干扰。
    - 在循环中不应该修改控制变量的值。
- 标准库提供函数`pairs ipairs`用来遍历`table`：
```Lua
-- generic for
tab = {"Alice", "Bob", "Kim", "Mike", ["Year"] = "2023"}
-- show all values
for k,v in pairs(tab) do
    print(k, v)
end
-- only show interger indexed values which are : Alice, Bob, Kim, Mike
for k,v in ipairs(tab) do
    print(k, v)
end
```
- 可以通过`next`函数（返回列表中下一个key和value，传入nil则返回第一个）实现`pairs`功能：
```Lua
function mypairs(tbl, key)
    local function iterator(tbl, key)
        return next(tbl, key)
    end
    return iterator, tbl, nil
end
for k,v in mypairs(tab) do
    print(k, v)
end
```
- 在其中跳过非数值类型的key就实现了`ipairs`：
```Lua
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
```

**函数调用**：
- 函数调用可以作为语句，此时丢弃返回值。
```EBNF
stat ::= functioncall
```

**本地变量声明**：
- 在一个块内任何地方都能够声明本地变量，可以在声明中初始化。
```EBNF
stat ::= local attnamelist ['=' explist]
attnamelist ::= Name attrib {',' Name attrib}
```
- 初始化和复合赋值语义相同，否则所有变量都初始化为`nil`。
- 每个变量名后都可以有一个可选的属性，一个放到`<>`中名称：
```EBNF
attrib ::= ['<' Name '>']
```
- 有两个合法的属性：`const close`
    - `const`表示常量，初始化后即不能赋值。
    - `close`则定义了一个将要关闭的变量（to-be-closed variable）。一个列表中仅能有一个这种变量。
- Chunk同样是Block，所以在一个显式的块外部也可以定义局部变量。
- 可见性规则后续解释。

**将要关闭的变量（To-be-closed variables）**：
- 一个将要关闭的变量表现得像一个本地常量一样，除了当变量离开作用域它的值会关闭这一点。
- 离开作用域有多种形式：块运行结束、通过`break goto return`退出块，或者抛出错误退出块。
- 这里的关闭一个值意味着会调用其`__close`元方法。调用时，值本身作为第一个参数传递，（如果是通过抛出错误退出的话）错误对象会作为第二个参数，如果没有错误，第二个参数是`nil`。
- 赋值给将要关闭的变量的值必须是一个`__close`元方法或者一个`false`。
- 如果多个值在同一时间离开作用域，会按照声明的逆序关闭。
- 如果运行关闭方法的时候抛出错误，会像普通代码一样被处理，并在错误处理后，其他等待的关闭方法同样会运行。
- 如果一个协程挂起但是从不恢复，一些变量可能永远不会离开作用域，也就不会被关闭。同理协程抛出错误时，不会进行栈回溯，所以也不会关闭任何变量。在这些情况下，可以使用`coroutine.close`关闭这些变量。如果协程是使用`coroutine.wrap`创建的，那么抛出错误时变量会关闭。

## 3.4 表达式

语法：
```EBNF
exp ::= prefixexp
exp ::= nil | false | true
exp ::= Numeral
exp ::= LiteralString
exp ::= functiondef
exp ::= tableconstructor
exp ::= '...'
exp ::= exp binop exp
exp ::= unop exp
prefixexp ::= var | functioncall | '(' exp ')'
```
- 数值常量`Numeral`和字符串字面量`LiteralString`在3.1说明。

**算术运算**：
- Lua支持下列算术运算：
```
+: addition
-: subtraction
*: multiplication
/: float division
//: floor division
%: modulo
^: exponentiation
-: unary minus
```
- 即加法、减法、乘法、除法、整除、取模、求幂、负号。
- 除了浮点指数和浮点除法之外，都遵循以下规则：
    - 如果两个操作数都是整数，那么执行整数运算，结果是一个整数。
    - 否则，如果两个操作数都是`nubmer`，那么先转换为`float`再进行运算，结果是一个浮点数。（字符串库支持将字符串转为`number`之后进行算术运算）
- 而求幂`^`和浮点除法`/`总是将操作数转换为浮点之后再运算，结果是浮点数。求幂操作使用C标准库的`pow`函数，对浮点数也能工作。
- 整除`//`是将除法的商向下（负无穷）取整，结果是整数，操作数可以是浮点。
- 求模`%`是取商为`//`结果的余数。
- 为了避免整数算术移除，执行整数回绕（理论上来说补码运算会自动这样做）。

**位运算**：
```
&: bitwise AND
|: bitwise OR
~: bitwise exclusive OR
>>: right shift
<<: left shift
~: unary bitwise NOT
```
- 和C语言不同的是，按位异或变成了`~`，其他都没有差别。因为`^`被求幂用掉了。
- 所有的按位运算都先将操作数转换为整数，结果是整数。
- 左移右移操作都是补零，也就是说都是无符号移位。

**类型转换**：
- Lua会在运行时在某些类型之间执行自动类型转换：
    - 位运算将浮点转为整数。
    - 求幂和浮点除法将整数转为浮点。
    - 其他算术运算混合了浮点和整数操作数时，将整数转为浮点。
    - C API还可以根据需要将浮点转为整数、整数转为浮点。
    - 字符串拼接除了字符串还可以将`number`作为参数。
- 执行整数转浮点时，如果浮点能够精确表示这个整数，那么就是结果。如果不能，那么会选择最近的表示（可能大也可能小），这种转换不会失败。
- 从浮点转为整数，会检查浮点数是否能够精确表示为一个整数（也就是浮点数有一个整数值，且在整数范围内）。如果有，那么就是结果，没有的话转换失败。
- Lua中一些地方会在必要时将字符串转换为整数。字符串库会设置元方法试图将所有出现在数值运算中的字符串转换为`number`。如果失败，则会调用其他操作数的元方法（如果存在）或者抛出错误。按位运算不会进行这种转换。
- 实践原则：
    - 不要依赖于字符串到`number`的转换，并不是所有情况都会做。这些特性将来可能会被移除。
    - 将`number`转换为字符串最好使用`string.format`，而不是依赖隐式转换。

**关系运算**：
```
==: equality
~=: inequality
<: less than
>: greater than
<=: less or equal
>=: greater or equal
```
- 相比C语言，判不等变成了`~=`。
- 结果一定是`true false`。
- 判等运算：
    - 首先比较操作数类型，如果类型不同，结果为假。
    - 否则比较操作数的值，字符串则比较字符串内容。
    - `number`则是比较他们是否表示相同的数值。
    - `table userdata thread`则是按引用比较，只有指向同一个对象才相等。每个新创建的对象都与其他已创建不等。函数总是等于他自己，相同实现的函数可能等可能不等（取决于Lua内部细节）。
- 可以通过`__eq`元方法修改Lua比较`table userdata`的方式。
- 关系运算并不会将字符串和`number`互相转换。所以`t[0] t["0"]`含义完全不同，`"0" == 0`结果是`false`。
- `~=`的结果完全和`==`相反。
- `< > <= >=`的工作方式：
    - 如果都是`number`那么按照数值进行比较。
    - 如果都是字符串，那么按照当前本地字符集（current locale）进行比较。
    - 否则调用`__lt __le`进行比较。
    - `<= >=`的结果和`> <`相反。

**逻辑运算**：
- 即`and or not`，和控制结果类似，`false nil`视为假，其他为真。
- 逻辑非操作`not`结果是布尔类型。`and or`的结果则可以是非布尔类型。
- `and`：如果第一个操作数是`false nil`，那么结果是`false nil`，否则结果是第二个操作数。
- `or`：如果第一个操作数是`false nil`，那么结果是第二个操作数，否则结果是第一个操作数。
```
10 or 20            --> 10
10 or error()       --> 10
nil or "a"          --> "a"
nil and 10          --> nil
false and error()   --> false
false and nil       --> false
false or nil        --> nil
10 and 20           --> 20
```
- `and or`都是短路求值。

**连接运算**：
- 运算符`..`：
    - 如果两个操作数都是字符串或者`number`，那么`number`转为字符串（按照一个未指定的格式，最好使用`string.format`指定格式）。
    - 否则调用`__concat`元方法。

**长度运算符**：
- 用一元前缀运算符`#`表示。
- 字符串长度是它的字节数（当每个字符一字节时就是字符数量）。
- 对于`table`则返回`table`的边界（border），它满足下列条件：
```Lua
(border == 0 or t[border] ~= nil) and
(t[border + 1] == nil or border == math.maxinteger)
```
- 只要一个边界的表称为序列：
    - `{10, 20, 30, 40, 50}`就是一个序列，只有一个边界，为`5`。
    - `{10, 20, 30, nil, 50}`则不是序列，有两个边界`3 5`。
    - `{}`的边界是0。
- 当表`t`是序列时，`#t`返回其唯一边界，也就是其直觉上的序列长度。
- 当表`t`不是序列时，`#t`返回其中一个边界（依赖于内部Lua实现）。
- 表的边界计算由最坏logn的时间复杂度保证，n是其最大整数键。
- 除了字符串之外其他所有类型都可以通过元方法`__len`修改长度运算符行为。

**运算符优先级**：
- 从低到高：
```
or
and
<     >     <=    >=    ~=    ==
|
~
&
<<    >>
..
+     -
*     /     //    %
unary operators (not   #     -     ~)
^
```
- 求幂最高，然后和C语言类似：先是前缀一元运算符、算术运算符，然后位运算，最后关系运算、逻辑运算。

**表构造器（Table Constructors）**：
- 表构造器用来创建表，每次对表构造器的求值都返回一个新表。表构造器可以用来创建空表或者初始化其中一些域。
- 语法：
```EBNF
tableconstructor ::= '{' [fieldlist] '}'
fieldlist ::= field {fieldsep field} [fieldsep]
field ::= '[' exp ']' '=' exp | Name '=' exp | exp
fieldsep ::= ',' | ';'
```
- 表构造器中条目`[exp1] = exp2`将会添加在表中添加键值对`exp1, exp2`。
- `name = exp`则等价于`["name"] = exp`。
- `exp`形式的条目使用整数作为索引，等价于`[i] = exp`。`i`是从1开始的连续整数。其他格式的条目不影响索引的连续增长。
- 其中的赋值顺序是不确定的。
- 如果其中的最后一个表达式是`exp`形式，并且这个表达式的结果是一个表达式列表，那么这些值依次按顺序加入列表。如果在中间，那么只有第一个值会加入列表。
- `, ;`作为分隔符，末尾也可以有分隔符。

**函数调用**：
- 语法：
```EBNF
functioncall ::= prefixexp args
functioncall ::= prefixexp ':' Name args
args ::= '(' [explist] ')'
args ::= tableconstructor
args ::= LiteralString
prefixexp ::= var | functioncall | '(' exp ')'
```
- 函数调用中，首先对前缀表达式`prefixexp`和参数了表`args`求值。如果`prefixexp`是函数类型，那么使用参数进行调用。
- 如果不是函数类型，那么调用`prefixexp`的`__call`元方法，传入`prefixexp`的值本身作为第一个参数，`args`跟在后面。
- 第二个形式：`prefixexp ':' Name args`也被视作函数调用。`v:name(args)`仅仅是`v.name(v, args)`的语法糖，但是其中的`v`只会求值一次。
- 参数类表的后两种形式：可以省略括号。
    - 当是一个表构造器时，将这个表作为唯一参数传递。
    - 字符串字面量作为作为参数时，则是这个字符串作为唯一参数。
    - 当然最好还是加上括号，为了可读性与避免歧义。
- `return functioncall`形式成为尾调用，Lua会进行必要的尾递归优化。

**函数定义**：
- 语法：
```EBNF
functiondef ::= function funcbody
funcbody ::= '(' [parlist] ')' block end
parlist ::= namelist [‘,’ ‘...’] | ‘...’
namelist ::= Name {',' Name}
```
- 函数定义会得到一个函数，可以用下面语法糖简化函数定义：
```EBNF
stat ::= function funcname funcbody
stat ::= local function Name funcbody
funcname ::= Name {'.' Name} [':' Name]
```
- 翻译规则：
```Lua
function f() body end
-- translates to
f = function() body end

function t.a.b.c.f() body end
-- translates to
t.a.b.c.f = function() obyd end

local function f() body end
-- translates to
local f; f = function() body end
-- not to
local f = function() body end 
-- This only makes a difference when the body of the function contains references to f (when f is a recursive function)
```
- 函数定义是一个可执行表达式，它的类型是`function`。
- 当Lua预编译一个Chunk时，所有函数体都会被预编译，但是他们还没有被创建。当Lua执行函数定义时，函数才会被实例化。这个函数（或者叫闭包）就是表达式的值。
- 函数参数就像是被实参初始化的函数体内的局部变量。
- 当Lua函数被调用时，会将实参列表长度调整到与形参列表一致。除非是可变参数函数，也就是形参列表以`...`结尾时。
- 可变参数函数不会调整参数列表，而是将所有参数通过`...`（可变参数表达式，vararg expression）传入。这个表达式的值就是这些额外参数，类似于返回多个值的函数。在函数体内也可以通过`...`访问这些额外参数。
- 例子：
```
function f(a, b) end
function g(a, b, ...) end
function r() return 1,2,3 end

CALL             PARAMETERS

f(3)             a=3, b=nil
f(3, 4)          a=3, b=4
f(3, 4, 5)       a=3, b=4
f(r(), 10)       a=1, b=10
f(r())           a=1, b=2

g(3)             a=3, b=nil, ... -->  (nothing)
g(3, 4)          a=3, b=4,   ... -->  (nothing)
g(3, 4, 5, 8)    a=3, b=4,   ... -->  5  8
g(5, r())        a=5, b=1,   ... -->  2  3
```
- 函数体内通过`return`返回，如果达到函数末尾，但是没有`return`语句，那么没有返回值。
- 函数返回值数量是有限制的，取决于实现，但是保证大于1000。
- `:`作为一个语法糖，会隐式传入一个当前函数作为第一个参数：
```Lua
function t.a.b.c:f (params) body end
-- translates to
t.a.b.c.f = function(params) body end
```

**表达式列表，多结果表达式，和调整（adjustment）**：
- 函数调用和可变参数表达式都可以是多个值。这种表达式成为**多结果表达式**（multires expression）。
- 当多结果表达式用在表达式列表中最后一个元素式，所有结果都被加到表达式列表中。如果不是最后一个表达式，那么只会加入第一个值到表达式列表中（如果多结果表达式中没有值，那么加入的就是`nil`）。
- Lua中可以使用表达式列表的地方：
    - 返回值：`return e1,e2,e3`。
    - 列表构造器：`{e1,e2,e3}`。
    - 函数实参：`foor(e1,e2,e3)`。
    - 多重赋值：`a,b,c = e1,e2,e3`。
    - 本地变量声明（的初始化）：`local a,b,c = e1,e2,e3`。
    - 通用`for`的初始值：`for k in e1,e2,e3 do ... end`。
- 对于后面四种情况，表达式列表都需要调整到（ajusted to）特定长度：参数长度、变量数量、通用`for`循环中正好四个值。不够的使用`nil`来补，多的直接丢弃。
- 例子：
```
print(x, f())      -- prints x and all results from f().
print(x, (f()))    -- prints x and the first result from f().
print(f(), x)      -- prints the first result from f() and x.
print(1 + f())     -- prints 1 added to the first result from f().
local x = ...      -- x gets the first vararg argument.
x,y = ...          -- x gets the first vararg argument,
                   -- y gets the second vararg argument.
x,y,z = w, f()     -- x gets w, y gets the first result from f(),
                   -- z gets the second result from f().
x,y,z = f()        -- x gets the first result from f(),
                   -- y gets the second result from f(),
                   -- z gets the third result from f().
x,y,z = f(), g()   -- x gets the first result from f(),
                   -- y gets the first result from g(),
                   -- z gets the second result from g().
x,y,z = (f())      -- x gets the first result from f(), y and z get nil.
return f()         -- returns all results from f().
return x, ...      -- returns x and all received vararg arguments.
return x,y,f()     -- returns x, y, and all results from f().
{f()}              -- creates a list with all results from f().
{...}              -- creates a list with all vararg arguments.
{f(), 5}           -- creates a list with the first result from f() and 5.
```

## 3.5 可见性规则

- 简而言之，和C语言很类似，局部变量的作用域从它的声明持续到包含它的最内部的块结束。
- 里层作用域中局部变量会覆盖外层的同名局部变量和全局变量。
- 对于`local x = x`，后面的`x`此时还没有被声明，是外层作用域中的。
- 被内部函数使用的变量被称为upvalue，或者叫外部本地变量（external local variable）。
