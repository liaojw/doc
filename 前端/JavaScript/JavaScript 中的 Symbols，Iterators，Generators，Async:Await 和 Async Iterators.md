# JavaScript 中的 Symbols，Iterators，Generators，Async/Await 和 Async Iterators

## Symbols 和众所周知的 Symbols

### Symbols

在 ES2015 中，一个新的（第6个）数据类型产生了，名为 `symbol`。

#### 为什么？

##### 原因 #1 ——添加向后兼容的新的内核特性

JavaScript 开发者和 ECMAScript 委员会（TC39）需要一种可以添加新的对象属性的方式，而不打破已有的方法，比如 `for ... in` 循环或者 JavaScript 方法 `Object.keys` 。

例如，如果我有一个对象，`var myObject = {firstName:'raja', lastName:'rao'} `，如果我执行  `Object.keys(myObject)` ，它将会返回 `[firstName, lastName]` 。

现在如果我添加一个属性，也就是在 `myObject` 添加 `newProperty` 属性 ，如果我执行  `Object.keys(myObject)` ，那么应该仍然返回之前的值，`[firstName, lastName]`，而不希望返回  `[firstName, lastName, newProperty]` 。那么应该如何做到这一点呢？

我们之前无法做到这一点，因此创建了一个名为 `Symbols` 的新数据类型。

如果你作为一个 symbol 来添加 `newProperty` ，那么 `Object.keys(myObject)` 会无视掉这个属性（由于它不会被识别），并仍然返回 `[firstName, lastName]` ！
##### 原因 #2 ——避免命名冲突
他们也希望保持这些属性的唯一性。通过这种方式，他们可以不断向全局添加新属性（并且可以添加对象属性），而不用担心命名冲突。

例如，你有一个对象，在对象中你正在添加一个自定义的 `toUpperCase` 到全局的 `Array.prototype` 。

现在想象一下，你加载了另一个库（或者说 ES2019 发布了），它有一个不同版本的`Array.prototype.toUpperCase` 。那么你的函数可能会由于命名冲突而崩溃。

```
Array.prototype.toUpperCase = function() {
var i;
for(i=0; i < this.length; i++) {
this[i] = this[i].toUpperCase();
}
return this;
};
var myArray = ['raja','rao'];
myArray.toUpperCase(); // ['RAJA','RAO']
```

那么你如何解决你可能不知道的这个命名冲突呢？这就是 Symbols 的用武之地了。它们在内部创建了独特的值，允许你创建添加属性而不用担心名称冲突。

##### 原因 #3 ——通过“众所周知（Well-known）” 的 Symbols 允许钩子（hooks）调用到内核方法
假设你想要一些核心函数，比如说用 `String.prototype.search` 来调用你的自定义函数。也就是说，  `'somestring'.searchh(myObject)`; 应该调用 `myObject` 的搜索函数并将 `'somestring'` 作为参数传入！我们如何做到这一点呢？

这就是 ES2015 提出的一系列全局 symbols ，即被称为“众所周知” 的 symbols 。而且只要你的对象有一个这样的 symbols 作为属性，你就能将内核函数重新定向来调用你自定义的函数！

关于这部分，我们现在不多说了，我会在本文稍后介绍所有细节。但首先，我们来了解一下Symbol如何工作。

#### 创建 Symbols
你可以通过调用名为 `Symbol` 全局的函数/对象创建一个 symbol 。这个函数返回了一个数据类型为  `symbol` 的值。

```
// mySymbol 也是一个 symbol 数据类型
var mySymbol = Symbol();
```

注意：Symbol 可能看起来像对象，因为它们有方法，但它们不是 – 它们是原语。你可以将它们视为与特定对象有某些相似之处的“特殊”对象，但这些对象不像常规对象。

例如：Symbols 具有与对象类似的方法，但与对象不同，它们是不可变的且唯一的。

#### Symbols 不能使用 “new” 关键字来创建
因为 symbols 不是对象，而 new 关键字应该返回了一个对象，我们不能使用 new 返回一个 symbols 数据类型。

```
var mySymbol = new Symbol(); //throws error
```

#### Symbols 有“description(描述)”
Symbols 可以包含一个描述——它仅用于记录意图。

```
// mySymbol 变量现在拥有一个 "symbol" 唯一值，
//其描述为“some text”
const mySymbol = Symbol('some text');
```

#### Symbols 具有唯一性

```
const mySymbol1 = Symbol('some text');
const mySymbol2 = Symbol('some text');
mySymbol1 == mySymbol2 // false
```

#### 如果我们使用 “Symbol.for” 方法，Symbols 表现的像单例
如果不通过 `Symbol()` 创建 `Symbol` ，你可以调用 `Symbol.for(<key>)` 。它需要传一个 “key”（字符串）来创建一个 Symbol 。如果这个 `key` 对应的 symbol 已经存在了，就会简单返回之前的 symbol ！因此如果我们调用 `Symbol.for` 方法，它就会表现的像一个单例。

```
var mySymbol1 = Symbol.for('some key'); //creates a new symbol
var mySymbol2 = Symbol.for('some key'); // **returns the same symbol
mySymbol1 == mySymbol2 //true
```

使用 `.for` 的实际用例就是在一个地方创建一个 Symbol ，然后在其他地方访问相同的 Symbol 。

警告：`Symbol.for` 会使 symbol 不具有唯一性，因此如果 key 相同，你最后会重写里面的值。所以尽可能避免这种情况！

#### Symbol 的 “description(描述)” vs. “key(键)”
为了使事情更清楚，如果你不使用 Symbol.for，那么 Symbols 是唯一的。但是，如果你使用它，那么如果你的 key 不是唯一的，那么返回的 symbols 也不是唯一的。

```
var mySymbol1 = Symbol('some text'); //创建一个唯一的 symbols，描述为 some text
var mySymbol2 = Symbol('some text'); // 创建一个唯一的 symbols，描述为 some text
var mySymbol3 = Symbol.for('some text'); //创建一个唯一的 symbols，key 为 some text
var mySymbol4 = Symbol.for('some text'); //返回 存储在 mySymbol3 中相同的 symbols
// 只有下面这个表达式返回 true，因为他们都使用了相同的 key ，“some text”
mySymbol3 == mySymbol4 //true
//... 其他全部为不同的symbols
mySymbol1 == mySymbol2 //false
mySymbol1 == mySymbol3 //false
mySymbol1 == mySymbol4 //false
```

#### Symbols 可以是可以是对象属性键(名)
这是 Symbols 的一个非常奇特的地方——而且也是最令人费解。虽然他们看起来像一个对象，他们确是原语。我们可以像 String 一样将 symbol 作为一个属性键关联到一个对象上。

事实上，这也是使用 Symbols 的主要方式——作为对象属性！

```
const mySymbol =  Symbol('some car description')
const myObject =  {name:'bmw'}
myObject[mySymbol] = 'This is a car';
// ps: 用括号"[]" 添加 symbols 作为属性
console.log(myObject[mySymbol]) //'This is a car'
```

>注：使用 symbols 的对象属性称为“键属性”。

#### 括号操作符 vs. 点操作符
因为点操作符只能用于字符串属性，在这里你不能使用点操作符，因此你应该使用括号操作符。

```
let myCar = {name: 'BMW'};
let type = Symbol('store car type');
myCar[type] = 'A_luxury_Sedan';
let honk = Symbol('store honk function');
myCar[myFunction] = () => 'honk';
// 用法：
myCar.type;// error
myCar[type];//'store car type'
myCar.honk;// error
myCar[honk];// 'honk'
```

### 使用 Symbols 的三个主要原因——回顾

>现在我们回顾一下三个主要原因，来了解 Symbols 是如何工作的。

#### 原因 #1. 对于循环和其他的方法来说， Symbols 是不可见的
下面例子中的 for-in 循环遍历了对象 obj ，但是不知道（或者忽略了）prop3 和 prop4 ，因为它们是 symbols 。

```
var obj = {};
obj['prop1'] = 1;
obj['prop2'] = 2;
// Lets add some symbols to the object using "brackets"
// (note: this MUST be via brackets)
var prop3 = Symbol('prop3');
var prop4 = Symbol('prop4');
obj['prop3'] = 3;
obj['prop4'] = 4;
for (var key in obj) {
console.log(key, '=', obj[key])
}
// The above loop prints...
// (doesn't know about props3 and prop4)
// prop1 = 1
// prop2 = 2
// however, you can access   props3 and prop4 directly via  brackets
console.log(obj[prop3]) //3
console.log(obj[prop4]) //4
```

下面是 `Object.keys` 和 `Object.getOwnPropertyNames` 忽略 Symbols 属性名的另一个示例。

```
const obj = {
name: 'raja'
};
//add some symbols..
obj[Symbol('store string')] = 'some string';
obj[Symbol('store fun')] = () => console.log('function');
// symbol key properties are ignored by many other methods
console.log(Object.keys(obj));//['name']
console.log(Object.getOwnPropertyNames(obj));//['name']
```

#### 原因 #2. Symbol 是唯一的
假设你需要一个名为 `Array.prototype.includes` 的全局 `Array` 对象。它将与JavaScript（ES2018）开箱即用的原生 `includes` 方法冲突。你该如何添加它才能不冲突呢？

首先，创建一个名为 includes 变量，给它分配一个 symbol 。然后使用括号表示法添加此变量（现在是一个 Symbol ）到全局 Array 中。分配任何一个你想要的函数。

最后使用括号表示法调用这个函数。但是请注意，你必须在括号里传递真实的 symbol 而不是一个字符串，类似于：`arr[includes]()` 。

```
var includes = Symbol('will store custom includes methods');
// Add it to global Attay.prototype
Array.prototype[includes] = () => console.log('inside includes funs');
//Usage:
var arr = [1, 2, 3];
// The following each call the ES2018 includes methods
console.log(arr.includes(1)); // true
console.log(arr['includes'](1)); // true; here is a string
// The following calls the custom includes methods
console.log(arr[includes]()); // 'inside includes funs'; here  includes is a symbol
```

#### 原因 #3. 众所周知的 Symbols（“全局”Symbols）
默认情况下，JavaScript 自动创建一堆 symbol 变量，并将他们分配给全局 `Symbol` 对象（是的，我们使用相同的 `Symbol()` 去创建 symbols ）。

在 ECMAScript 2015 中，这些 symbols 随后被添加到诸如数组和字符串等核心对象的核心方法，如  `String.prototype.search` 和 `String.prototype.replace` 。

举一些 Symbols 的例子：`Symbol.match`，  `Symbol.replace`，`Symbol.search`，`Symbol.iterator` 和 `Symbol.split`。

由于这些全局 Symbols 是全局且公开的，我们可以用核心的方法调用我们自定义函数而不是内部函数。

#### 举个例子：Symbol.search
例如，String 对象的 `String.prototype.search` 公共方法搜索一个 regExp 或字符串，并在发现索引的时候返回索引。

```
'rajarao'.search(/rao/); //4
'rajarao'.search('rao'); //4
```

在 ES2015 中，它首先检测是否在查询 regExp (RegExp对象) 时实现了 `Symbol.search` 方法。如果是的话，就调用这个函数并将工作交给它。而且像 RegExp 这样的核心对象实现了 `Symbol.search` 的 Symbol ，确实做了这个工作。

#### Symbol.search的内部工作原理（默认行为）

1. 解析 `'rajarao'.search('rao')`;
2. 将 “rajarao” 转成 String 对象 `new String(“rajarao”)`
3. 将 “rao” 转成 RegExp 对象 `new Regexp(“rao”)`
4. 调用 “rajarao” String 对象的 `search` 方法。
5. `search` 方法内部调用了 “rao” 对象的 `Symbol.search` 方法（将search返回给 “rao” 对象）并传进 “rajarao” 。就像这样：`"rao"[Symbol.search]("rajarao")`
6. `"rao"[Symbol.search]("rajarao")`将结果为 `4` 的索引返回到 `search`方法，最后，`search` 将 `4` 返回到我们的代码。

下面这段伪代码片段展示了代码内部是如何工作的：

```
// pseudo code for String class
class String {
constructor(value){
this.value=value;
}
search(obj) {
// call the obj's Symbol.search method and pass my value to is
obj[Symbol.search](this.value);
}
}
// pseudo code for RegExp class
class RegExp {
constructor(value){
this.value=value;
}
search(obj) {
// call the obj's Symbol.search method and pass my value to is
Symbol.search(string){
return string.indexOf(this.value);
}
}
}
// inner workings...
// 'rajarao'.search('rao'); 
// step1:  convert  'rajarao' to String Object... new String('rajarao');
// step2:  'rao' is a string, so convert it to RegExp object... new RegExp('rao');
// step3:  call 'rajarao's 'search' method and pass 'rao' object
// step4:  call 'rao' RegExp object's [Symbol.search]  method
// step5: return result
```

但是美妙之处在于，你不再需要传递RegExp。你可以传递任意实现了 `Symbol.search` 的对象，并返回任何你想要的，之后它还能继续工作。

让我们来看看。

#### 自定义String.search方法来调用我们的函数
下面这个例子展示了我们如何使用 `String.prototype.search` 调用我们 `Product` 类的 `search` 方法 —— 感谢 `Symbol.search` 这个全局 `Symbol` 。

```
class Product {
constructor(type) {
this.type = type;
}
// implement search funture
[Symbol.search](string) {
return string.indexOf(this.type) >= 0 ? 'FOUND' : 'NOT_FOUND';
}
}
var soapObj = new Product('soap');
'barsoap'.search(soapObj);//FOUND
'shampoo'.search(soapObj);//NOT_FOUND
```

#### Symbol.search 内部工作原理 (自定义行为)

解析 `'barsoap'.search(soapObj)`;

将 “barsoap” 转换为String对象 `new String("barsoap")`

由于 `soapObj` 已经是一个对象，所以不要做任何转换

调用 “barsoap” 字符串对象的 `search` 方法。

`search`方法在内部调用 “barsoap” 对象的 `Symbol.search` 方法（也就是说，它将 search 重新委托给 “barsoap” 对象）并传递 “barsoap” 。像这样：`soapObj[Symbol.search]("barsoap")`

`soapObj[Symbol.search]("barsoap")`将索引结果作为 `FOUND` 返回到 `search` 函数，最后，`search` 将 `FOUND` 返回给我们的代码。

##Iterators（迭代器）和 Iterables（可迭代对象）

### 为什么？
在几乎所有的应用程序中，我们都在不断处理数据列表，我们需要在浏览器或移动 app 中显示这些数据。通常我们会编写自己的方法来存储和提取这些数据。

但事实是，我们已经有了像 `for-of` 循环和 spread (展开)操作符（`…`）这样的标准方法来提取标准对象（如数组，字符串和map）中的数据集合。为什么我们不能为我们的对象使用这些标准方法呢？

在下面的例子中，我们不能使用 `for-of` 循环或 spread (展开)操作符来从我们的 `Users` 类中提取数据。我们必须使用自定义的 `get` 方法。

```
// BEFORE:
// We can't use standard 'for-of' loop or "..." spread operator
// to extract each user from Users.
class Users {
constructor(users) {
this.users = users;
}
get() {// this is not standard
return this.users;
}
}
const allUsers = new Users([
{name: 'raja'},
{name: 'john'},
{name: 'matt'}
]);
//allUsers.get() works ,but we can't do the following...
for (const user of Users) {
console.log(user)
}
// "TypeError:Users is no iterable"
// We also can't do the following...
[...allUsers];
// "TypeError:Users is no iterable"
```

但是，在我们自己的对象中可以使用这些现有方法不是更好吗？为了完成这个想法，我们需要有一些规则让所有的开发者都可以遵循并可以让他们的对象也使用这些现有的方法。

如果他们遵循这些规则来从他们的对象中取出数据，那么这些对象就称为“可迭代对象（iterables）”。

规则如下：

1. 主对象/类应该存储一些数据。
2. 主对象/类必须有全局的“众所周知的” symbol ，即 `symbol.iterator` 作为它的属性，然后按照从规则 #3 到 #6 的每条规则来实现一个特有的方法。
3. `symbol.iterator` 方法必须返回另一个对象 —— 一个“迭代器(iterator)”对象。
4. “迭代器(iterator)”对象必须有一个名为 `next` 的方法。
5. `next` 方法应该可以访问存储在规则 #1 的数据。
6. 如果我们调用 `iteratorObj.next()` ，应该返回存储在规则 #1 中的数据，如果想返回更多的值使用格式 `{value:&lt;stored data&gt;, done: false}` ，如果不想返回其他更多的值则使用格式 `{done: true}` 。

如果循序了所有的这 6 条规则，规则 #1 中的主对象就被称为“可迭代对象(iterable)”。它返回的对象称为“迭代器(iterator)”。

我们来看一下我们如何让我们的 Users 对象作为可迭代对象：

```
//AFTER:
//User is an "iterable",because it implementsa "Symbol.iterator" method
//that returns an object with "next" method and returns values as per rules.
class Users {
constructor(users) {
this.users = users;
}
// Have Symbol.iterator symbol as a property that stores a method
[Symbol.iterator]() {
let i = 0;
let users = this.users;
//this returned object is called an "iterator"
return {
next() {
if (i < users.length) {
return { done: false, value: users[i++] };
}
return { done: true };
},
};
}
}
//allUsers is called an "iterarable"
const allUsers = new Users([
{ name: 'raja' },
{ name: 'john' },
{ name: 'matt' },
]);
//allUsersIterator is called an "iterator"
const allUsersIterator = allUsers[Symbol.iterator]();
//next method returns the next value in the stored data
allUsersIterator.next();//{done:false,value:{name:'raja'}}
allUsersIterator.next();//{done:false,value:{name:'john'}}
allUsersIterator.next();//{done:false,value:{name:'matt'}}
//Using in for-of loop
for (const u of allUsers) {
console.log(u.name);
}
//prints.,raja,john,matt
//Using in spread operator
console.log([...allUsers]);
//prints..[{name:'raja1},{name:'john'},{name:'matt'}]
```

重要提示：如果我们传递一个 `iterable (allUsers)` for-of 循环或者展开标识符，他们内部调用 `&lt;iterable&gt;[Symbol.iterator]()` 来获取迭代器（就像 allUsersIterator ），然后使用迭代器来取出数据。

因此在某种程度上，所有这些规则都有一种标准方法来返回一个 `iterator` 对象。

## Generator(生成器)函数
### 为什么？
两个主要原因如下：

1. 提供 iterables(可迭代对象) 的高级抽象
2. 提供新的流程控制来改善“回调地狱”之类的情况。

下面我们详细说明。

### 理由 #1 ——iterables(可迭代对象)的包装器
为了使我们的类/对象编程一个 `iterable`(可迭代对象) ，除了通过遵循所有这些规则，我们还可以通过简单地创建一些称为“Generator(生成器)”的函数来简化这些操作。

关于生成器的一些要点如下：

1. 生成器函数在类中有一个新的 `*&lt;myGenerator&gt;` 语法，而且生成器函数有语法  `function * myGenerator(){}` 。
2. 调用生成器 `myGenerator()` 返回一个 `generator` 对象，它也实现了`iterator`协议（规则），因此我们可以使用它作为一个可以直接使用的 `iterator` 返回值。
3. 生成器使用一个特有的 `yield` 声明来返回数据。
4. `yield` 语句跟踪以前的调用，并从它停止的地方继续。
5. 如果你在一个循环中使用 `yield` ，每次我们在迭代器调用 `next()` 方法的时候，它会只运行一次。

#### 示例一：
下面的代码向您展示了如何使用生成器方法（`*getIterator()`）而不是使用 `Symbol.iterator`方法并实现遵循所有规则的 `next` 方法。

```
//Intead of making our object an Iterable,we can simply createa
//generator (function* syntax) and return an Iterator to extract data,
class Users {
constructor(users) {
this.users = users;
this.len = users.length;
}
//is a generator and Itreturns an Iterator!
* getIterator() {
for (let i in this.users) {
yield this.users[l];//although inside loop,"yield" runs only once per call
}
}
}
const allUsers = new Users([
{ name: 'raja' },
{ name: 'john' },
{ name: 'matt' },
]);
const allUsersIterator = allUsers.getIterator();
// //next method returns the next value in the stored data
console.log(allUsersIterator.next());//{done:false,value:{name:'raja'}}
console.log(allUsersIterator.next());//{done:false,value:{name:1john'}}
console.log(allUsersIterator.next());//{done:false,value:{name:'matt'}}
console.log(allUsersIterator.next());//{done:true,value:undefined>
//Using in for-of loop
for (const u of allUsersIterator) {
console.log(u.name);
}
//prints.,raja,john,matt
//Using in spread operator
console.log([...allUsersIterator]);
//prints..[{name:'raja'},{name:'john'},{name:'matt'}]
```

#### 示例2：
您可以进一步简化它。创建一个函数为生成器（使用 * 语法），并使用 yield 一次返回一个值，如下所示。

```
//Users is now a generator! and it returns an iterator
function* Users(users) {
for (let i in users) {
yield users[i++];//although inside loop,"yield" runs only once per next() call
}
}
//allUsers is now an Iterator!
const allUsers = Users([{ name: 'raja' }, { name: 'john' }, { name: 'matt' }]);
//next method returns the next value in the stored data
console.log(allUsers.next());//{done:false,value:{name:1raja1}}
console.log(allllsers.next());//{done:false,value:{name:1john1}}
console.log(allUsers.next());//{done:false,value:{name:1matt1}}
console.log(allllsers.next());//{done:true，value:undefined}
//Using in for-of loop 
for (const u of allUsers) {
console.log(u.name);
}
//prints..raja,john,matt
//Using in spread operator
console.log([...allUsers]);
//prints..[{name:1raja'}，{name:'john'}，{name:1matt1}]
```

重要提示：尽管上面的例子中，我使用了单词 “iterator” 来表示 `allUsers` ，但是它确实是一个  `generator`(生成器) 对象。

除了`next`方法之外，generator(生成器)还有 `throw` 和 `return` 等方法！但是出于实际目的，我们可以将返回的对象用作“iterator(迭代器)”。

### 理由 2 —— 提供更好更新的流程控制
提供新的流程控制可以帮助我们使用新的方式编写程序，也可以解决像“回调地狱”之类的问题。

注意，与普通函数不同，generator(生成器)函数可以 `yield` （存储函数的 `state` 和 `return` 值），并且在它 yielded 的时候就会准备着去获取额外的输入值。

在下图中，每次看到 `yield` 时，都可以返回该值。您可以使用  `generator.next(“some new value”)` ，并在 yielded 时将新值传递出去。

![http://newimg88.b0.upaiyun.com/newimg88/2018/07/1_uYrMy6BZQlDO11rS7wOJZg.png](http://newimg88.b0.upaiyun.com/newimg88/2018/07/1_uYrMy6BZQlDO11rS7wOJZg.png)

下面的例子更加具体地展示了流程控制如何工作：

```
function* generator(a, b) {
//return result of a + b;
//also store any *new* input in k (not the result of a + b) 
let k = yield a + b;
let m = yield a + b + k;
yield a + b + k + m;
}
var gen = generator(10, 20);
//Get me value of a + b...
//note: done is "false" because there are more "yield" statements left! 
console.log(gen.next()); //{ value: 30, done: false }
//...at this point, the function remains in the memory with values a and b 
//and if you call it again with some number, it starts where it left off.
//assign 50 to "k" and return result of a + b + k 
console.log(gen.next(50)); //{ value: 80, done: false }
//...at this point, the function remains in the memory with values a, b and k 
//and if you call it again with some number, it starts where it left off.
//assign 100 to "k" and return result of a+b+k+m 
console.log(gen.next(100)); //{ value: 80, done: false }
//...at this point, the function remains in the memory with a, b, k, and m 
//But since there are no more yield calls, it returns undefined.
//call next again
gen.next(); //{ value: undefined, done: true }
```

###生成器语法和用法
生成器函数可以通过下面的方法调用：

```
//SYNTAX AND USAGE...
//As Generator functions 
function* myGenerator() { }
//or..
function* myGenerator() { }
//or..
function* myGenerator() { }
//As Generator Methods
const myGenerator = function* () { }
//Generator arrow functions - ERROR 
//Can't use it with arrow function 
let generator = * () => { }
//Inside ES2015 class.. 
class myClass() {
*myGenerator() { }
}
//Inside object literal 
const myObject = {
*myGenerator(){ }
}
```

**我们可以在 “yield” 之后写更多的代码（不像 “return” 语句）**

就像 `return` 关键字，`yield` 关键字也会返回值——但是它允许在 yielding 之后还有代码！

```
function* myGenerator() {
let name = 'raja';
yield name;
console.log('you can do more stuff after yield')
}
//generator returns an iterator object 
const mylterator = myGenerator();
//call next() the first time..
//returns { value: 'raja1, done: false } 
console.log(myIterator.next());
//call next() the 2nd time..
//Prints: 'you can do more stuff after yield'
//and returns: { value: undefined, done: true } 
console.log(myIterator.next());
```

**你可以有多个 yields**

```
function* myGenerator() {
let name = 'raja';
yield name;
let lastName = 'rao';
yield lastName;
}
//generator returns an iterator object 
const mylterator = myGenerator();
//call next() the first time..
//returns { value: 'raja1, done: false } 
console.log(myIterator.next());
//call next( ) the 2nd time..
//returns: { value: 'rao1, done: false } 
console.log(myIterator.next());
```

**通过 “next” 方法来回给生成器传值**

iterators(迭代器)的 `next` 方法也可以将值传递给生成器，就像下面写的。

事实上，这个特性可以让生成器消除“回调地狱”。在这方面你会了解的更多一点。

这个特性也在库中大量使用，例如 [redux-saga](https://redux-saga.js.org/)。

在下面的示例中，我们使用空的 `next()` 调用调用迭代器来获取问题。然后，当我们第二次调用`next(23)`时，我们传递`23`作为值。

```
function* profUeGenerator() {
//first yield 'How old are you?' for the first next( ) call 
//Store the value from the 2nd next(<input>) value in answer 
let answer = yield 'How old are you?';
//based on the value stored in the answer, yield either 'adult' or 'child' 
if (answer > 18) {
yield 'adult';
} else {
yield 'child ';
}
}
//generator returns an iterator object 
const mylterator = profileGenerator();
console.log(myIterator.next()); //{ value: 'How old are you?', done: false }
console.log(myIterator.next(23)); //{ value: 'adult', done: false }
```

**生成器有助于消除“回调地狱”**

你知道如果我们有多个异步调用，我们会进入回调地狱。

下面的例子就展示了像“co”之类的库如何利用生成器特性，让我们通过 `next` 方法传值来帮助我们同步地写异步代码。

注意在第5步和第10步，`co` 函数如何通过 `next(result)` 将结果从 promise 传回给生成器

```
co(function* () {
let post = yield Post.findByID(10);
let comments = yield post.getComments();
console.log(post, comments);
}).catch(function (err) {
console.error(err);
});
//Step 1: The "co" library takes the generator as argument, 
//Step 2: Calls the async code "Post.findByID(10)"
//Step 3: "Post.findByID(10)" returns a Promise 
//Step 4: Waits for the Promise to resolve,
//Step 5: Once the Promise returns result, calls "next(result)" 
//Step 6: Stores the result in "post" variable.
//Step 7: Calls the async code "post.getComments( )";
//Step 8: "post.getComments( )" returns a Promise 
//Step 9: Waits for the Promise to resolve
//Step 10: Once the Promise returns result, calls "next(result)" 
//Step 11: Stores the result in "comments" variable.
//Step 12: console.log(post, comments);
```

好的，我们来讨论异步/等待。

##异步/等待
###为什么?
就像你之前看到的，生成器有助于消除“回调地狱”，但是你需要一些像 `co` 一样的第三方的库才能完成。但是“回调地狱”仍然是一个大问题，ECMAScript 委员会决定只为生成器的这个问题创建一个封装，同时提出了新的关键字 `async/await` 。

生成器和异步/等待的区别如下：

1. 异步/等待使用 await 而不是 yield 。
2. await 只对 Promises 有用。
3. 它使用 `async` 函数关键字而不是 `function*` 。

因此 `async/await` 是 Generators(生成器) 的一个重要子集，它包含了一个新的语法糖（`Syntactic sugar`）。

`async` 关键字告诉 JavaScript 编译器对这种函数区别对待。在函数中无论何时编译器只要遇到 `await` 关键字，编译器都会暂停。假定 `await` 后面的表达式返回了一个 `promise` ，而且在程序继续向下走之前一直等 `promise` 被处理或者被拒绝。

在下面的例子中，`getAmount` 函数调用了两个异步函数 `getUser` 和 `getBankBalance` 。我们在一个 promise 中也可以这么做，但是使用 `async await` 更加优雅且简单。

```
//Instead of..
//ES2015 Promise
function getAmount(userId) {
getUser(userId)
.then(getBankBalance)
.then(amount => {
console.log(amount);
});
}
//Use..
//ES2017
async function getAmount2(userId) {
var user = await getUser(userId);
var amount = await getBankBalance(user);
console.log(amount);
}
getAmount('1'); // $1,000
getAmount2('1'); // $1,000
function getUser(userId) {
return new Promise(resolve => {
setTimeout(() => {
resolve('john');
}, 1000);
});
}
function getBankBalance(user) {
return new Promise((resolve, reject) => {
setTimeout(() => {
if (user == 'john') {
resolve('$1,000');
} else {
reject('unknown user');
}
}, 1000);
});
}
```

##异步迭代器
###为什么？
我们在循环中需要调用异步函数的情况非常常见。因此在 ES2018（已完成提案），TC39 委员会提出了新的 Symbol 的 `Symbol.asyncIterator` ，以及一个新的 `for-await-of` 结构来帮助我们简化对异步函数循环。

普通 Iterator(迭代器) 对象和异步迭代器对象的主要区别如下：

####迭代器对象
迭代器对象的 `next()` 方法返回了像 `{value: ‘some val’, done: false}` 这样的值

用法：`iterator.next() //{value: ‘some val’, done: false}`

####异步迭代器对象
异步迭代器对象的 `next()` 方法返回了一个 `Promise` ，解析后为  `{value: ‘some val’, done: false}` 这样的内容

用法：`iterator.next().then(({ value, done })=> {//{value: ‘some val’, done: false}}`

下面的例子展示了 `for-await-of` 是如何工作的，以及你怎么才能使用它。

```
const promises = [
new Promise(resolve => resolve(1)),
new Promise(resolve => resolve(2)),
new Promise(resolve => resolve(3)),
];
//you can simply loop over an array of functions 
//that return promise and get the value in the loop 
async function test() {
for await (const p of promises) {
console.log(p);
}
}
test(); //1 ,2 3
```

##总结
**Symbols** —— 提供全局唯一的数据类型。你主要将他们用作为对象属性添加新的行为，以免破坏  `Object.keys` 和 `for-in` 循环等标准方法。

**众所周知的Symbols** —— 由JavaScript自动生成的Symbols，可以在我们自定义对象中实现核心方法。

**Iterables(可迭代对象)** —— 任何存储数据集合的对象，遵循特定规则以至于我们可以使用标准的  `for-of` 循环和`...`展开标识符从中取出数据。

**Iterators(迭代器)** —— 有迭代返回并有 `next` 方法——这是实际从 `iterable` 中获取数据的方法。

**Generators(生成器)** —— 为 Iterables 提供更高阶抽象方法。他们还提供新的控制流程，可以解决像回调地狱这样的问题并为像`Async/Await`这样的事情提供构建块。

**Async/Await(异步/等待)** —— 为生成器提供高阶抽象方法，来专门解决回调地狱问题。

**Async Iterators(异步迭代器)** —— ES2018年的新功能，可以帮助循环访问异步函数数组，来获取每个异步函数的结果，就像一个普通的循环。



