# setTimeout & setInterval

## 导读

设置web定时器应当是一个相当常见的需求, 实际上, 我们也有两大工具函数可以任意调用: setTimeout, setInterval. 然而 js 里却没有java的那种wait(), 定时又未必准时, 要想写个定时器还须得深入理解 setTimeout 和 setInterval 的运行原理才行.

## 运行原理

setTimeout 和 setInterval 并非异步调用, 所谓的”异步调用”, 只是因它们都往 js 引擎的 待处理任务队列 末尾插入代码, 看起来像”异步调用”而已.

那么如何计算插入的时间点呢? 自然要用到我们通常所说的 timer (也叫计时器), 当执行 setTimeout 和 setInterval 函数的时候, timer会根据设定好的时间点找到代码的插入点, 返回timer callback, 也就是我们设定的回调函数.

## setTimeout
语法1: setTimeout(func, millisec, [param1, param2, …])

语法2: setTimeout(code, millisec)

setTimeout() 方法在指定的时间后, 执行一次传入的函数. 可通过 window.clearTimeout 函数取消 setTimeout 操作.

### 基本用法

```
function fn(){
  console.log(+new Date());
}
setTimeout(fn, 1000);//1452405077119, 延迟1s后打印了当前的时间戳
setTimeout("console.log(+new Date())", 1000);//1452405077120, 延迟1s后执行了字符串中的语句
```
### js引擎的排队机制
javaScript的世界里只有一个线程, 从来就没有同时做两件事的能力, 因此setTimeout只是一种委托机制. 它告诉js 引擎, 帮它在指定的时间点将一段代码插入到 js 引擎的 待处理任务队列 末尾, 插入的代码并不能立即执行, 至少也要等到队列前面的代码全部执行完毕(如果队列刚好为空, 则是指定时间立即执行, 否则要等待队列前面的代码顺序执行完毕).

下面我们来通过栗子感受一下setTimeout是怎么排队的.

```
//假如我们要在输入框失去焦点时, 做一些事情, 然后重新获取焦点
$('input').blur(function(){
  //To do something...
  $(this).focus();
});
```

像上面这种写法在IE下是没有什么问题, 输入框失去焦点后马上就能获取焦点, 然而Firefox就没那么幸运了, 因为Firefox的focus只能出现在blur之后. 利用 setTimeout 的排队特点, 我们可以像下面这样实现:

```
$('input').blur(function(){
  //To do something...
  setTimeout(function(){
    $(this).focus();
  },0);
});
```

虽然 setTimeout 延时为0, 但获取焦点的语句并不会立即执行, 原因就在于 setTimeout 只是将获取焦点的语句插入到 js 引擎的 待处理任务队列 末尾, 它需要等待整个 blur 完全执行完才能发挥作用, 这样就保证了 focus 事件在 blur 事件之后发生了.

### 充当定时器
setTimeout 原本只能延迟一段时间执行一段代码, 如果我们将 setTimeout 写在函数内部, 并在 setTimeout 里调用函数本身, 这样就完成了简单的定时器. 如下:

```
function fn(i){
  if(!i) i = 0;
  ++i;
  if(i<10) setTimeout(fn,100,i);
  else console.log(i);
}
fn();//10, fn每隔100ms执行一次, 直到第10次, 因不符合条件(i=10), 退出定时器, 从而输出10
```
### this带来的问题
由setTimeout()调用的代码运行在与所在函数完全分离的执行环境上. 这会导致,这些代码中包含的 this 关键字会指向 window (或全局)对象.

```
var o = {fruit: "apple"};
o.shareFruit = function(){
  console.log(this.fruit);
}
o.shareFruit();//apple
setTimeout(o.shareFruit,1000);//undefined
setTimeout.call(o,o.shareFruit,1000);//Illegal operation on WrappedNative prototype object
```

甚至连 call 方法都没有办法改变当前作用域, 使用中要特别注意避免这个问题. 可参考如下方案:

```
setTimeout(o.shareFruit.bind(o), 1000);//apple
```

### 解决方案
下面我们来使用两个非原生的 setTimeout 和 setInterval 全局函数代替原生的, 使得它们能够借用 call 方法激活正确的作用域.

```
// Enable the passage of the 'this' object through the JavaScript timers

var __nativeST__ = window.setTimeout, __nativeSI__ = window.setInterval;

window.setTimeout = function (vCallback, nDelay) {
  var oThis = this, aArgs = Array.prototype.slice.call(arguments, 2);
  return __nativeST__(vCallback instanceof Function ? function () {
    vCallback.apply(oThis, aArgs);
  } : vCallback, nDelay);
};

window.setInterval = function (vCallback, nDelay) {
  var oThis = this, aArgs = Array.prototype.slice.call(arguments, 2);
  return __nativeSI__(vCallback instanceof Function ? function () {
    vCallback.apply(oThis, aArgs);
  } : vCallback, nDelay);
};

//再运行以下代码将能正确执行
setTimeout.call(o,o.shareFruit,1000);//apple
```

## setInterval
语法1: setInterval(func, millisec, [param1, param2, …])

语法2: setInterval(code, millisec)

setInterval() 方法按照指定的周期(以毫秒为单位)来调用函数或表达式. 可通过 window.clearInterval 函数取消 setInterval 操作.

### 基本用法
setInterval 与 setTimeout 不同, 它会周期性的去调用函数或者表达式, 直到它本身被取消. 如下:

```
var i = 0;
function fn(){
  ++i;
}
var timer = setInterval(fn,100);//设置了一个定时器, 每100ms执行一次fn函数
setTimeout(function(){
  window.clearInterval(timer);
  console.log(i);
},2000);//两秒后清除定时器, 并打印i的值
//20, 可见2s后fn刚好被执行了20次
```

### 它真的可以作为定时器吗
实际上 setInterval 真的能作为定时器, 准确无误的在指定间隔时间内执行函数 fn 吗?

答案是 no. 请看下面栗子:
```
var i = 0;
function fn(){
  ++i;
}
var timer = setInterval(fn,2);//设置了一个定时器, 将时间间隔减少至2ms
setTimeout(function(){
  window.clearInterval(timer);
  console.log(i);
},2000);//两秒后清除定时器, 并打印i的值
//501, 可见2s后fn只是被执行了501次(为什么不是1000次?)
```

以上 fn 应该被执行 2000 次, 实际上才执行501次, 这是为什么呢?

原来, js 引擎在指定时间点往 待处理消息队列 插入代码片段这种机制有个特点, js引擎只允许有一份未执行的process代码(相当于fn), 对上述代码为而言, 每当1ms来临时, js引擎先判断队列中有没有process代码, 如果 fn 函数执行时间大于1ms, 这就意味着fn尚未被执行完, 定时就来了, 然后定时候着, 静静地等待 fn的执行, 这种情况下引擎队列中就可能存在尚未执行的process代码, 如果有则本次插入的时间点就被无情的跳过.

由此可见, 上述代码中, fn 函数被无情的跳过了499次. 我们也可以据此计算出运行一次 fn 函数大致需要2000/501~ = 4ms. 而当我们将上述 timer 的时间间隔设置为4ms时, fn 刚好被执行了 500 次.

因此上面的这段代码并不可靠, 下面我们来看一个更为可靠的版本:

```
var i = 0,timer;
function fn(){
  if(++i >= 1000){//fn调用1000次后自动退出
    console.log(i);
    return;
  }
  timer = setTimeout(arguments.callee, 4);//设置延时2ms后执行自身
}
fn();
setTimeout(function(){
  console.log(i)
  window.clearTimeout(timer);
},2000);//384
```

可见, 2s之后取消定时器时, fn被执行了384次,如果仅仅希望fn被执行1000次后退出, 删除最后一个setTimeout即可. 此时, 本次fn调用 与 下次调用, 间隔时间将大于或者等于2ms. 这样既保证了调用次数, 又基本保证了调用间隔.

实际上, 上述测试中有个很大的问题. **HTML5标准规定了setTimeout 最短运行间隔是4ms**, 如果低于这个值, 则会自动按4ms间隔运行. **老版本浏览器一般将这个最短间隔设置为10ms**. 将上述 setTimeout 方法第二个参数设置为4, 测试发现, 刚好运行384次. 在老版IE浏览器中测试, 发现运行198次, 接近200次, 也验证了老版浏览器10ms的时间间隔.

注: IE9 及更早版本的IE 浏览器不支持它们第一个语法中的向回调函数中传参数的功能. 如需支持, 请参考兼容写法, 或者借用 Function.prototype.bind 函数, 如下:

```
setTimeout(function(arg1){}.bind(undefined, 10), 1000);
```

