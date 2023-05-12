# Lua语法

Lua手册：https://www.lua.org/manual/5.4/manual.html

介绍：
- Lua将过程式语法和基于关联数组和可扩展语义的数据描述结构结合起来。
- Lua被设计为一个库，使用C89编写。
- Lua分发程序中包含了一个宿主程序名为`lua`，这个程序使用Lua库提供了一个完整的独立的Lua解释器，可以用于交互式执行和命令行解释执行。
- 也可以直接使用这个库而从而将Lua嵌入项目，包含Lua库的头文件，然后通过其提供的C API来编译和执行Lua程序。这是Lua作为一个库工作，没有main程序，嵌入到宿主程序中。宿主程序可以调用一个Lua函数或者执行一段Lua程序、写入或者读取Lua变量、注册可以被Lua代码调用的C函数。

目录：
- [2. 基本概念](02BasicConcepts/#2-%E5%9F%BA%E6%9C%AC%E6%A6%82%E5%BF%B5)
  - [2.1 值与类型](02BasicConcepts/#21-%E5%80%BC%E4%B8%8E%E7%B1%BB%E5%9E%8B)
  - [2.2 环境与全局环境](02BasicConcepts/#22-%E7%8E%AF%E5%A2%83%E4%B8%8E%E5%85%A8%E5%B1%80%E7%8E%AF%E5%A2%83)
  - [2.3 错误处理](02BasicConcepts/#23-%E9%94%99%E8%AF%AF%E5%A4%84%E7%90%86)
  - [2.4 元表和元方法](02BasicConcepts/#24-%E5%85%83%E8%A1%A8%E5%92%8C%E5%85%83%E6%96%B9%E6%B3%95)
  - [2.5 垃圾收集](02BasicConcepts/#25-%E5%9E%83%E5%9C%BE%E6%94%B6%E9%9B%86)
  - [2.6 协程](02BasicConcepts/#26-%E5%8D%8F%E7%A8%8B)
