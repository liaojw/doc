# Mouseenter与Mouseover事件？

## mouseenter与mouseover的异同？

> 要说清楚mouseenter与mouseover有什么不同，也许可以从两方面去讲。

* 是否支持冒泡
* 事件的触发时机

先来看一张图,对这两个事件有一个简单直观的感受。

![](http://odssgnnpf.bkt.clouddn.com/QQ20170605-204232@2x.png)

### 再看看官网对mouseenter的解释

> The event fires only if the mouse pointer is outside the boundaries of the object and the user moves the mouse pointer inside the boundaries of the object. If the mouse pointer is currently inside the boundaries of the object, for the event to fire, the user must move the mouse pointer outside the boundaries of the object and then back inside the boundaries of the object.

大概意思是说：当鼠标从元素的边界之外移入元素的边界之内时，事件被触发。而当鼠标本身在元素边界内时，要触发该事件，必须先将鼠标移出元素边界外，再次移入才能触发

> Unlike the onmouseover event, the onmouseenter event does not bubble.

大概意思是：和mouseover不同的是，mouseenter不支持事件冒泡

### 由于mouseenter不支持事件冒泡，导致在一个元素的子元素上进入或离开的时候会触发其mouseover和mouseout事件，但是却不会触发mouseenter和mouseleave事件

![](http://odssgnnpf.bkt.clouddn.com/undefeind.gif)

我们给左右两边的ul分别添加了`mouseover`和`mouseenter`事件，当鼠标进入左右两边的ul时，`mouseover`和`mouseenter`事件都触发了，但是当移入各自的子元素li的时候，触发了左边ul上的`mouseover`事件，然而右边ul的`mouseenter`事件没有被触发。

造成以上现象本质上是`mouseenter`事件不支持冒泡所致。

## 如何模拟mouseenter事件。

> 可见mouseover事件因其具有冒泡的性质，在子元素内移动的时候，频繁被触发，如果我们不希望如此，可以使用mouseenter事件代替之，但是早期只有ie浏览器支持该事件，虽然现在大多数高级浏览器都支持了mouseenter事件，但是难免会有些兼容问题，所以如果可以自己手动模拟，那就太好了。

关键因素: **relatedTarget** 要想手动模拟mouseenter事件，需要对mouseover事件触发时的事件对象event属性relatedTarget了解。

* relatedTarget事件属性返回与事件的目标节点相关的节点。
* 对于mouseover事件来说，该属性是鼠标指针移到目标节点上时所离开的那个节点。
* 对于mouseout事件来说，该属性是离开目标时，鼠标指针进入的节点。
* 对于其他类型的事件来说，这个属性没有用。

重新回顾一下文章最初的那张图，根据上面的解释，对于ul上添加的mouseover事件来说，relatedTarget只可能是

* ul的父元素wrap(移入ul时,此时也是触发mouseenter事件的时候, 其实不一定，后面会说明)，
* 或者ul元素本身(在其子元素上移出时)，
* 又或者是子元素本身(直接从子元素A移动到子元素B)。

![](http://odssgnnpf.bkt.clouddn.com/hahha2.png)

根据上面的描述，我们可以对relatedTarget的值进行判断：如果值不是目标元素，也不是目标元素的子元素，就说明鼠标已移入目标元素而不是在元素内部移动。

条件1： 不是目标元素很好判断e.relatedTarget !== target(目标元素)

条件2：不是目标元素的子元素，这个应该怎么判断呢？

## ele.contains

> 这里需要介绍一个新的api node.contains(otherNode) , 表示传入的节点是否为该节点的后代节点, 如果 otherNode 是 node 的后代节点或是 node 节点本身.则返回true , 否则返回 false

### 用法案例

```
<ul class="list">
  <li class="item">1</li>
  <li>2</li>
</ul>
<div class="test"></div>
```

```
let $list = document.querySelector('.list')
let $item = document.querySelector('.item')
let $test = document.querySelector('.test')

$list.contains($item) // true
$list.contains($test) // false
$list.contains($list) // true
```

那么利用contains这个api我们便可以很方便的验证条件2，接下来我们封装一个`contains(parent, node)`函数，专门用来判断`node`是不是`parent`的子节点

```
let contains = function (parent, node) {
  return parent !== node && parent.contains(node)
}
```

用我们封装过后的`contains`函数再去试试上面的例子

```
contains($list, $item) // true
contains($list, $test) // false
contains($list, $list) // false (主要区别在这里)
```

这个方法很方便地帮助我们解决了模拟mouseenter事件中的条件2，但是悲催的`ode.contains(otherNode)`,具有浏览器兼容性，在一些低级浏览器中是不支持的，为了做到兼容我们再来改写一下contains方法

```
let contains = docEle.contains ? function (parent, node) {
  return parent !== node && parent.contains(node)
} : function (parent, node) {
  let result = parent !== node

  if (!result) { // 排除parent与node传入相同的节点
    return result
  }

  if (result) {
    while (node && (node = node)) {
      if (parent === node) {
        return true
      }
    }
  }

  return false
}
```

说了这么多，我们来看看用`mouseover`事件模拟`mouseenter`的最终代码

```
// callback表示如果执行mouseenter事件时传入的回调函数

let emulateEnterOrLeave = function (callback) {
  return function (e) {
    let relatedTarget = e.relatedTarget
    if (relatedTarget !== this && !contains(this, relatedTarget)) {
      callback.apply(this, arguments)
    }
  }
}
```

### 模拟mouseenter与原生mouseenter事件效果对比

```
<div class="wrap">
  wrap, mouseenter
  <ul class="mouseenter list">
    count: <span class="count"></span>
    <li>1</li>
    <li>2</li>
    <li>3</li>
  </ul>
</div>

<div class="wrap">
  wrap, emulate mouseenter,用mouseover模拟实现mouseenter
  <ul class="emulate-mouseenter list">
    count: <span class="count"></span>
    <li>1</li>
    <li>2</li>
    <li>3</li>
  </ul>
</div>
```

```
.wrap{
  width: 50%;
  box-sizing: border-box;
  float: left;
}

.wrap, .list{
  border: solid 1px green;
  padding: 30px;
  margin: 30px 0;
}

.list{
  border: solid 1px red;
}

.list li{
  border: solid 1px blue;
  padding: 10px;
  margin: 10px;
}

.count{
  color: red;
}
```

```
let $mouseenter = document.querySelector('.mouseenter')
let $emulateMouseenter = document.querySelector('.emulate-mouseenter')
let $enterCount = document.querySelector('.mouseenter .count')
let $emulateMouseenterCounter = document.querySelector('.emulate-mouseenter .count')

let addCount = function (ele, start) {
  return function () {
    ele = ++start
  }
}

let docEle = document.documentElement
  let contains = docEle.contains ? function (parent, node) {
    return parent !== node && parent.contains(node)
  } : function (parent, node) {
  let result = parent !== node

  if (!result) {
    return result
  }

  if (result) {
    while (node && (node = node)) {
      if (parent === node) {
        return true
      }
    }
  }

  return false
}

let emulateMouseenterCallback = addCount($emulateMouseenterCounter, 0)

let emulateEnterOrLeave = function (callback) {
  return function (e) {
    let relatedTarget = e.relatedTarget
    if (relatedTarget !== this && !contains(this, relatedTarget)) {
      callback.apply(this, arguments)
    }
  }
}

$mouseenter.addEventListener('mouseenter', addCount($enterCount, 0), false)
$emulateMouseenter.addEventListener('mouseover', emulateEnterOrLeave(emulateMouseenterCallback), false)
```

![](http://odssgnnpf.bkt.clouddn.com/emulateMouseenter2.gif)

### 好了，我们已经通过mouseove事件完整的模拟了mouseenter事件，但是反过头来看看
对于ul上添加的mouseover事件来说，relatedTarget只可能是

* ul的父元素wrap(移入ul时,此时也是触发mouseenter事件的时候, 其实不一定，后面会说明)，
* 或者ul元素本身(在其子元素上移出时)，
* 又或者是子元素本身(直接从子元素A移动到子元素B)。

我们通过排查2和3，最后只留下1，也就是mouseenter与mouseover事件一起触发的时机。既然这样我们为什么不像这样判断呢？

```
target.addEventListener('mouseover', function (e) {
  if (e.relatedTarget === this) {
    // 执行mouseenter的回调要做的事情  
  }
}, false)
```

这样不是更加简单吗？，何必要折腾通过排查2和3来做？

原因是，target的父元素有一定的占位空间的时后，我们这样写是没有太大问题的，但是反之，这个时候`e.relatedTarget`就可能是target元素的父元素，又祖先元素中的某一个。我们无法准确判断e.relatedTarget到底是哪个元素。所以通过排除2和3应该是个更好的选择。

## 用mouseout模拟mouseleave事件

> 当mouseout被激活时，relatedTarget表示鼠标离开目标元素时，进入了哪个元素，我们同样可以对relatedTarget的值进行判断：如果值不是目标元素，也不是目标元素的子元素，就说明鼠标已移出目标元素

我们同样可以用上面封装的函数完成

```
// callback表示如果执行mouseenter事件时传入的回调函数

let emulateEnterOrLeave = function (callback) {
  return function (e) {
    let relatedTarget = e.relatedTarget
    if (relatedTarget !== this && !contains(this, relatedTarget)) {
      callback.apply(this, arguments)
    }
  }
}
```

