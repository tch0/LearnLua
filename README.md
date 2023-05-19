# Lua学习

## Lua语法

介绍：
- Lua将过程式语法和基于关联数组和可扩展语义的数据描述结构结合起来。
- Lua被设计为一个库，使用C89编写。
- Lua分发程序中包含了一个宿主程序名为`lua`，这个程序使用Lua库提供了一个完整的独立的Lua解释器，可以用于交互式执行和命令行解释执行。
- 也可以直接使用这个库而从而将Lua嵌入项目，包含Lua库的头文件，然后通过其提供的C API来编译和执行Lua程序。这使Lua作为一个库工作，没有main程序，而是嵌入到宿主程序中。宿主程序可以调用一个Lua函数或者执行一段Lua程序、写入或者读取Lua变量、注册可以被Lua代码调用的C函数。

手册学习：[Manuals](Manuals/)

## Lua资料

官方资料：
- 5.4版本手册： https://www.lua.org/manual/5.4/manual.html
- 官方文档：[The Implementation of Lua 5.0](https://www.lua.org/doc/jucs05.pdf)
- [The Evolution of Lua](https://www.lua.org/doc/hopl.pdf)

非官方资料：
- [A No-Frills Introduction to Lua 5.1 VM Instructions](https://www.mcours.net/cours/pdf/hasclic3/hasssclic818.pdf)
- [Lua 5.3 Bytecode Reference](https://the-ravi-programming-language.readthedocs.io/en/latest/lua_bytecode_reference.html)

书籍：
- 官方书籍：[Programming in Lua](./Books/Programming_in_Lua_4th_edition_.pdf)，[中文版：Lua程序设计](https://read.douban.com/ebook/163679893/)。
- 国人书籍：[Lua设计与实现](https://github.com/lichuang/Lua-Source-Internal)，有条件可以支持实体版。
- 国人书籍：[自己动手实现Lua——虚拟机、编译器和标准库](https://book.douban.com/subject/30348061/)，使用go实现Lua虚拟机、编译器标准库，[随书代码](https://github.com/zxh0/luago-book)。
- 国人书籍：[Lua解释器构建：从虚拟机到编译器](https://book.douban.com/subject/36280421/)，[随书代码](https://github.com/Manistein/let-us-build-a-lua-interpreter)

其他资料：
- Lua教程 | 菜鸟教程：https://www.runoob.com/lua/lua-tutorial.html
- [知乎问题-如何学习 Lua VM 的源码？](https://www.zhihu.com/question/20617406)，几乎所有东西都有了，仔细阅读所有回答。