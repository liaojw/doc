# HTML localstorage
## HTML API
localstorage在浏览器的API有两个：`localStorage`和`sessionStorage`，存在于window对象中：`localStorage`对应`window.localStorage`，`sessionStorage`对应`window.sessionStorage`。
`localStorage`和`sessionStorage`的区别主要是在于其生存期。

## 基本使用方法

```
localStorage.setItem("b","isaac");//设置b为"isaac"
var b = localStorage.getItem("b");//获取b的值,为"isaac"
var a = localStorage.key(0); // 获取第0个数据项的键名，此处即为“b”
localStorage.removeItem("b");//清除c的值
localStorage.clear();//清除当前域名下的所有localstorage数据
```

## 作用域
![https://sfault-image.b0.upaiyun.com/379/307/3793073884-56950753e65db](https://sfault-image.b0.upaiyun.com/379/307/3793073884-56950753e65db)

* 这里的`作用域`指的是：如何隔离开不同页面之间的localStorage（总不能在百度的页面上能读到腾讯的localStorage吧，哈哈哈）。
* `localStorage`只要在相同的协议、相同的主机名、相同的端口下，就能读取/修改到同一份localStorage数据。
* `sessionStorage`比`localStorage`更严苛一点，除了协议、主机名、端口外，还要求在同一窗口（也就是浏览器的标签页）下。

## 生存期
`localStorage`理论上来说是永久有效的，即不主动清空的话就不会消失，即使保存的数据超出了浏览器所规定的大小，也不会把旧数据清空而只会报错。但需要注意的是，在移动设备上的浏览器或各`Native App`用到的`WebView`里，`localStorage`都是不可靠的，可能会因为各种原因（比如说退出App、网络切换、内存不足等原因）被清空。

`sessionStorage`的生存期顾名思义，类似于`session`，只要关闭浏览器（也包括浏览器的标签页），就会被清空。由于`sessionStorage`的生存期太短，因此应用场景很有限，但从另一方面来看，不容易出现异常情况，比较可靠。

## 数据结构
localstorage为标准的键值对（Key-Value,简称KV）数据类型，简单但也易扩展，只要以某种编码方式把想要存储进localstorage的对象给转化成字符串，就能轻松支持。举点例子：把对象转换成json字符串，就能让存储对象了；把图片转换成DataUrl（base64），就可以存储图片了。另外对于键值对数据类型来说，“键是唯一的”这个特性也是相当重要的，重复以同一个键来赋值的话，会覆盖上次的值。

## 过期时间
很遗憾，localstorage原生是不支持设置过期时间的，想要设置的话，就只能自己来封装一层逻辑来实现：

```
function set(key,value){
  var curtime = new Date().getTime();//获取当前时间
  localStorage.setItem(key,JSON.stringify({val:value,time:curtime}));//转换成json字符串序列
}
function get(key,exp)//exp是设置的过期时间
{
  var val = localStorage.getItem(key);//获取存储的元素
  var dataobj = JSON.parse(val);//解析出json对象
  if(new Date().getTime() - dataobj.time > exp)//如果当前时间-减去存储的元素在创建时候设置的时间 > 过期时间
  {
    console.log("expires");//提示过期
  }
  else{
    console.log("val="+dataobj.val);
  }
}
```

## 容量限制
目前业界基本上统一为5M，已经比cookies的4K要大很多了，省着点用吧骚年。

## 域名限制
由于浏览器的安全策略，localstorage是无法跨域的，也无法让子域名继承父域名的localstorage数据，这点跟cookies的差别还是蛮大的。

## 异常处理
localstorage在目前的浏览器环境来说，还不是完全稳定的，可能会出现各种各样的bug，一定要考虑好异常处理。我个人认为localstorage只是资源本地化的一种优化手段，不能因为使用localstorage就降低了程序的可用性，那种只是在console里输出点错误信息的异常处理我是绝对反对的。localstorage的异常处理一般用`try/catch`来捕获/处理异常。

## 如何测试用户当前浏览器是否支持localstorage
目前普遍的做法是检测`window.localStorage`是否存在，但某些浏览器存在bug，虽然“支持”localstorage，但在实际过程中甚至可能出现无法setItem()这样的低级bug。因此我建议，可以通过在`try/catch`结构里`set/get`一个测试数据有无出现异常来判断该浏览器是否支持localstorage，当然测试完后记得删掉测试数据哦。

## 浏览器兼容性

| Feature | Chrome | Firefox | Internet Explorer | Opera | Safari | Android |Opera Mobile|Safari Mobile|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|localStorage|4|3.5|8|10.50|4|2.1|11|iOS 3.2|
|sessionStorage|5|2|8|10.50|4|2.1|11|iOS 3.2|

## 如何调试
在chrome开发者工具里的`Resources - Local Storage`面板以及`Resources - Session Storage`面板里，可以看到当前域名下的localstorage数据。

![http://img.blog.csdn.net/20151207121707655](http://img.blog.csdn.net/20151207121707655)

## 在ios设备上无法重复setItem()

> 另外，在iPhone/iPad上有时设置setItem()时会出现诡异的QUOTA_EXCEEDED_ERR错误，这时一般在setItem之前，先removeItem()就ok了。

## 相关插件推荐

* [store.js](https://github.com/marcuswestin/store.js)
* [mozilla/localForage](https://github.com/jaicab/localFont)
* [localFont](https://github.com/jaicab/localFont)

## 参考文章

* [W3C - Web Storage](http://www.w3.org/TR/webstorage/#storage)
* [HTML5 LocalStorage 本地存储](http://www.cnblogs.com/xiaowei0705/archive/2011/04/19/2021372.html)
* [MDN - Window.localStorage](https://developer.mozilla.org/zh-CN/docs/Web/API/Window/localStorage)
