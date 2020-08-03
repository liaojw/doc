# prototype与__proto__
## 概念

1. **prototype** 是函数(function) 的一个属性, 它指向函数的原型.
2. **\_\_proto__** 是对象的内部属性, 它指向构造器的原型, 对象依赖它进行原型链查询.

## 栗子 
我们来吃个栗子帮助消化下:

```
function Person(name){
  this.name = name;
}
var p1 = new Person('louis');

console.log(Person.prototype);//Person原型 {constructor: Person(name),__proto__: Object}
console.log(p1.prototype);//undefined

console.log(Person.__proto__);//空函数, function(){}
console.log(p1.__proto__ == Person.prototype);//true
```

吃栗子时我们发现, Person.prototype(原型) 默认拥有两个属性:

* constructor 属性, 指向构造器, 即Person本身
* \_\_proto__ 属性, 指向一个空的Object 对象

而p1作为非函数对象, 自然就没有 prototype 属性; 此处佐证了概念1

下面来看看__proto__属性:

Person.__proto__ 属性 指向的是一个空函数( function(){} ), 待会儿我们再来研究这个空函数.

p1.__proto__ 属性 指向的是 构造器(Person) 的原型, 即 Person.prototype. 此处佐证了概念2

这里我们发现: 原型链查询时, 正是通过这个属性(__proto__) 链接到构造器的原型, 从而实现查询的层层深入.

对 概念1 不太理解的同学, 说明你们不会吃栗子, 咱们忽略他们. 对 概念2 不太理解的同学, 我们来多吃几个栗子, 边吃边想:

```
var obj = {name: 'jack'},
    arr = [1,2,3],
    reg = /hello/g,
    date = new Date,
    err = new Error('exception');

console.log(obj.__proto__  === Object.prototype); // true
console.log(arr.__proto__  === Array.prototype);  // true
console.log(reg.__proto__  === RegExp.prototype); // true
console.log(date.__proto__ === Date.prototype);   // true
console.log(err.__proto__  === Error.prototype);  // true
```

可见, 以上通过 对象字面量 和 new + JS引擎内置构造器() 创建的对象, 无一例外, 它们的__proto__ 属性全部指向构造器的原型(prototype). 充分佐证了 概念2 .

## \_\_proto__
刚才留下了一个问题: Person.__proto__ 指向的是一个空函数, 下面我们来看看这个空函数究竟是什么.

```
console.log(Person.__proto__ === Function.prototype);//true
```
Person 是构造器也是函数(function), Person的__proto__ 属性自然就指向 函数(function)的原型, 即 Function.prototype.

这说明了什么呢?

我们由 “特殊” 联想到 “通用” , 由Person构造器联想一般的构造器.

这说明 **所有的构造器都继承于Function.prototype** (此处我们只是由特殊总结出了普适规律, 并没有给出证明, 请耐心看到后面) , 甚至包括根构造器Object及Function自身。所有构造器都继承了Function.prototype的属性及方法。如length、call、apply、bind（ES5）等. 如下:

```
console.log(Number.__proto__   === Function.prototype); // true
console.log(Boolean.__proto__  === Function.prototype); // true
console.log(String.__proto__   === Function.prototype); // true
console.log(Object.__proto__   === Function.prototype); // true
console.log(Function.__proto__ === Function.prototype); // true
console.log(Array.__proto__    === Function.prototype); // true
console.log(RegExp.__proto__   === Function.prototype); // true
console.log(Error.__proto__    === Function.prototype); // true
console.log(Date.__proto__     === Function.prototype); // true
```

JavaScript中有内置(build-in)构造器/对象共计13个（ES5中新加了JSON），这里列举了可访问的9个构造器。剩下如Global不能直接访问，Arguments仅在函数调用时由JS引擎创建，Math，JSON是以对象形式存在的，无需new。由于任何对象都拥有 \_\_proto__ 属性指向构造器的原型. 即它们的 \_\_proto__ 指向Object对象的原型(Object.prototype)。如下所示:

```
console.log(Math.__proto__ === Object.prototype);  // true
console.log(JSON.__proto__ === Object.prototype);  // true
```

如上所述, 既然所有的构造器都来自于Function.prototype, 那么Function.prototype 到底是什么呢?

## Function.prototype
我们借用 typeof 运算符来看看它的类型.

```
console.log(typeof Function.prototype) // "function"
```

实际上, Function.prototype也是唯一一个typeof XXX.prototype为 “function”的prototype。其它的构造器的prototype都是一个对象。如下:

```
console.log(typeof Number.prototype)   // object
console.log(typeof Boolean.prototype)  // object
console.log(typeof String.prototype)   // object
console.log(typeof Object.prototype)   // object
console.log(typeof Array.prototype)    // object
console.log(typeof RegExp.prototype)   // object
console.log(typeof Error.prototype)    // object
console.log(typeof Date.prototype)     // object
```

## JS中函数是一等公民
既然Function.prototype 的类型是函数, 那么它会拥有 \_\_proto__ 属性吗, Function.prototype.__proto__ 会指向哪里呢? 会指向对象的原型吗? 请看下方:
```
console.log(Function.prototype.__proto__ === Object.prototype) // true
```
透过上方代码, 且我们了解到: Function.prototype 的类型是函数, 也就意味着一个函数拥有 \_\_proto__ 属性, 并且该属性指向了对象(Object)构造器的原型. 这意味着啥?

根据我们在 概念2 中了解到的: \_\_proto__ 是对象的内部属性, 它指向构造器的原型.

这意味着 Function.prototype 函数 拥有了一个对象的内部属性, 并且该属性还恰好指向对象构造器的原型. 它是一个对象吗? 是的, 它一定是对象. 它必须是.

实际上, JavaScript的世界观里, 函数也是对象, 函数是一等公民.

这说明所有的构造器既是函数也是一个普通JS对象，可以给构造器添加/删除属性等。同时它也继承了Object.prototype上的所有方法：toString、valueOf、hasOwnProperty等。

##Object.prototype
函数的 \_\_proto__ 属性指向 Function.prototype, 如: Person.__proto__ —> Function.prototype

Function.prototype 函数的 \_\_proto__ 属性指向 Object.prototype, 如: Function.prototype.__proto__ —> Object.prototype.

那么Object.prototype.__proto__ 指向什么呢?

```
console.log(Object.prototype.__proto__ === null);//true
```
由于已经到顶, JS世界的源头一片荒芜, 竟然什么都没有! 令人嗟叹不已.

都说一图胜千言, 我也不能免俗. 下面附一张 stackoverflow 上的图:

![](http://louiszhai.github.io/docImages/prototype.png)

这张图也指出:

* Object.__proto__ == Function.prototype,
* Function.__proto__ == Function.prototype.

```
//虽然上面做过测试, 我们还是再次测试下
console.log(Object.__proto__   == Function.prototype);//true
console.log(Function.__proto__ == Function.prototype);//true
```
由于对象构造器 (Object) 也是构造器, 又构造器都是函数, 又函数是一等公民, 函数也是对象.

故, 对象构造器 (Object) 拥有3种身份:

* 构造器
* 函数
* 对象

推而广之, 所有构造器都拥有上述3种身份.

由于构造器是 对象 (身份3), 理所当然拥有 \_\_proto__ 属性, 且该属性一定指向其构造器的原型, 也就是指向 函数 (身份2) 构造器(Function)的原型, 即 Function.prototype. 于是我们证明了上面那句 **所有的构造器都继承于Function.prototype** (身份1).

注: 上面代码中用到的 \_\_proto__ 目前在IE6/7/8/9中并不支持。IE9中可以使用Object.getPrototypeOf(ES5)获取对象的内部原型。



