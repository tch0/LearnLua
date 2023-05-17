# Lua语法

Lua手册：https://www.lua.org/manual/5.4/manual.html

介绍：
- Lua将过程式语法和基于关联数组和可扩展语义的数据描述结构结合起来。
- Lua被设计为一个库，使用C89编写。
- Lua分发程序中包含了一个宿主程序名为`lua`，这个程序使用Lua库提供了一个完整的独立的Lua解释器，可以用于交互式执行和命令行解释执行。
- 也可以直接使用这个库而从而将Lua嵌入项目，包含Lua库的头文件，然后通过其提供的C API来编译和执行Lua程序。这使Lua作为一个库工作，没有main程序，而是嵌入到宿主程序中。宿主程序可以调用一个Lua函数或者执行一段Lua程序、写入或者读取Lua变量、注册可以被Lua代码调用的C函数。

目录：
- [2. 基本概念](02BasicConcepts/#2-%E5%9F%BA%E6%9C%AC%E6%A6%82%E5%BF%B5)
  - [2.1 值与类型](02BasicConcepts/#21-%E5%80%BC%E4%B8%8E%E7%B1%BB%E5%9E%8B)
  - [2.2 环境与全局环境](02BasicConcepts/#22-%E7%8E%AF%E5%A2%83%E4%B8%8E%E5%85%A8%E5%B1%80%E7%8E%AF%E5%A2%83)
  - [2.3 错误处理](02BasicConcepts/#23-%E9%94%99%E8%AF%AF%E5%A4%84%E7%90%86)
  - [2.4 元表和元方法](02BasicConcepts/#24-%E5%85%83%E8%A1%A8%E5%92%8C%E5%85%83%E6%96%B9%E6%B3%95)
  - [2.5 垃圾收集](02BasicConcepts/#25-%E5%9E%83%E5%9C%BE%E6%94%B6%E9%9B%86)
  - [2.6 协程](02BasicConcepts/#26-%E5%8D%8F%E7%A8%8B)
- [3. 语言核心](03TheLanguage/#3-%E8%AF%AD%E8%A8%80%E6%A0%B8%E5%BF%83)
  - [3.1 词法约定](03TheLanguage/#31-%E8%AF%8D%E6%B3%95%E7%BA%A6%E5%AE%9A)
  - [3.2 变量](03TheLanguage/#32-%E5%8F%98%E9%87%8F)
  - [3.3 语句](03TheLanguage/#33-%E8%AF%AD%E5%8F%A5)
  - [3.4 表达式](03TheLanguage/#34-%E8%A1%A8%E8%BE%BE%E5%BC%8F)
  - [3.5 可见性规则](03TheLanguage/#35-%E5%8F%AF%E8%A7%81%E6%80%A7%E8%A7%84%E5%88%99)
- [4. C API](04TheAPI/#4-c-api)
  - [4.1 栈](04TheAPI/#41-%E6%A0%88)
  - [4.2 C Closures](04TheAPI/#42-c-closures)
  - [4.3 Registry注册表](04TheAPI/#43-registry%E6%B3%A8%E5%86%8C%E8%A1%A8)
  - [4.4 C中的错误处理](04TheAPI/#44-c%E4%B8%AD%E7%9A%84%E9%94%99%E8%AF%AF%E5%A4%84%E7%90%86)
  - [4.5 在C中处理yield](04TheAPI/#45-%E5%9C%A8c%E4%B8%AD%E5%A4%84%E7%90%86yield)
  - [4.6 类型与函数](04TheAPI/#46-%E7%B1%BB%E5%9E%8B%E4%B8%8E%E5%87%BD%E6%95%B0)
  - [4.7 调试接口](04TheAPI/#47-%E8%B0%83%E8%AF%95%E6%8E%A5%E5%8F%A3)
- [5. 辅助库](05TheAuxiliaryLibrary/#5-%E8%BE%85%E5%8A%A9%E5%BA%93)
  - [5.1 函数和类型](05TheAuxiliaryLibrary/#51-%E5%87%BD%E6%95%B0%E5%92%8C%E7%B1%BB%E5%9E%8B)