# Ajax知识体系大梳理
## 导读
Ajax 全称 Asynchronous JavaScript and XML, 即异步JS与XML. 它最早在IE5中被使用, 然后由Mozilla, Apple, Google推广开来. 典型的代表应用有 Outlook Web Access, 以及 GMail. 现代网页中几乎无ajax不欢. 前后端分离也正是建立在ajax异步通信的基础之上.

## 浏览器为Ajax做了什么
现代浏览器中, 虽然几乎全部支持ajax, 但它们的技术方案却分为两种:

① 标准浏览器通过 XMLHttpRequest 对象实现了ajax的功能. 只需要通过一行语句便可创建一个用于发送ajax请求的对象.

```
var xhr = new XMLHttpRequest();
```
② IE浏览器通过 XMLHttpRequest 或者 ActiveXObject 对象同样实现了ajax的功能.

### MSXML
鉴于IE系列各种 “神级” 表现, 我们先来看看IE浏览器风骚的走位.

IE下的使用环境略显复杂, IE7及更高版本浏览器可以直接使用BOM的 XMLHttpRequest 对象. MSDN传送门: Native XMLHTTPRequest object. IE6及更低版本浏览器只能使用 ActiveXObject 对象来创建 XMLHttpRequest 对象实例. 创建时需要指明一个类似”Microsoft.XMLHTTP”这样的ProgID. 而实际呢, windows系统环境下, 以下ProgID都应该可以创建XMLHTTP对象:

```
Microsoft.XMLHTTP
Microsoft.XMLHTTP.1.0
Msxml2.ServerXMLHTTP
Msxml2.ServerXMLHTTP.3.0
Msxml2.ServerXMLHTTP.4.0
Msxml2.ServerXMLHTTP.5.0
Msxml2.ServerXMLHTTP.6.0
Msxml2.XMLHTTP
Msxml2.XMLHTTP.3.0
Msxml2.XMLHTTP.4.0
Msxml2.XMLHTTP.5.0
Msxml2.XMLHTTP.6.0
```

简言之, Microsoft.XMLHTTP 已经非常老了, 主要用于提供对历史遗留版本的支持, 不建议使用.对于 MSXML4, 它已被 MSXML6 替代; 而 MSXML5 又是专门针对office办公场景, 在没有安装 Microsoft Office 2003 及更高版本办公软件的情况下, MSXML5 未必可用. 相比之下, MSXML6 具有比 MSXML3 更稳定, 更高性能, 更安全的优势, 同时它也提供了一些 MSXML3 中没有的功能, 比如说 XSD schema. 唯一遗憾的是, MSXML6 只在 vista 系统及以上才是默认支持的; 而 MSXML3 在 Win2k SP4及以上系统就是可用的. 因此一般情况下, MSXML3 可以作为 MSXML6 的优雅降级方案, 我们通过指定 PorgID 为 Msxml2.XMLHTTP 即可自动映射到 Msxml2.XMLHTTP.3.0. 如下所示:

```
var xhr = new ActiveXObject("Msxml2.XMLHTTP");// 即MSXML3,等同于如下语句
var xhr = new ActiveXObject("MSXML2.XMLHTTP.3.0");
```

亲测了 IE5, IE5.5, IE6, IE7, IE8, IE9, IE10, IE edge等浏览器, IE5及之后的浏览器均可以通过如下语句获取xhr对象:

```
var xhr = new ActiveXObject("Msxml2.XMLHTTP");// 即MSXML3
var xhr = new ActiveXObject("Microsoft.XMLHTTP");// 很老的api,虽然浏览器支持,功能可能不完善,故不建议使用
```

以上, 思路已经很清晰了, 下面给出个全兼容的方法.

### 全平台兼容的XMLHttpRequest对象

```
function getXHR(){
  var xhr = null;
  if(window.XMLHttpRequest) {
    xhr = new XMLHttpRequest();
  } else if (window.ActiveXObject) {
    try {
      xhr = new ActiveXObject("Msxml2.XMLHTTP");
    } catch (e) {
      try {
        xhr = new ActiveXObject("Microsoft.XMLHTTP");
      } catch (e) { 
        alert("您的浏览器暂不支持Ajax!");
      }
    }
  }
  return xhr;
}
```

## ajax有没有破坏js单线程机制
对于这个问题, 我们先看下浏览器线程机制. 一般情况下, 浏览器有如下四种线程:

* GUI渲染线程
* javascript引擎线程
* 浏览器事件触发线程
* HTTP请求线程

那么这么多线程, 它们究竟是怎么同js引擎线程交互的呢?

通常, 它们的线程间交互以事件的方式发生, 通过事件回调的方式予以通知. 而事件回调, 又是以先进先出的方式添加到任务队列 的末尾 , 等到js引擎空闲时, 任务队列 中排队的任务将会依次被执行. 这些事件回调包括 setTimeout, setInterval, click, ajax异步请求等回调.

**浏览器中, js引擎线程会循环从 任务队列 中读取事件并且执行, 这种运行机制称作 Event Loop (事件循环).**

对于一个ajax请求, js引擎首先生成 XMLHttpRequest 实例对象, open过后再调用send方法. 至此, 所有的语句都是同步执行. 但从send方法内部开始, 浏览器为将要发生的网络请求创建了新的http请求线程, 这个线程独立于js引擎线程, 于是网络请求异步被发送出去了. 另一方面, js引擎并不会等待 ajax 发起的http请求收到结果, 而是直接顺序往下执行.

当ajax请求被服务器响应并且收到response后, 浏览器事件触发线程捕获到了ajax的回调事件 onreadystatechange (当然也可能触发onload, 或者 onerror等等) . 该回调事件并没有被立即执行, 而是被添加到 任务队列 的末尾. 直到js引擎空闲了, 任务队列 的任务才被捞出来, 按照添加顺序, 挨个执行, 当然也包括刚刚append到队列末尾的 onreadystatechange 事件.

在 onreadystatechange 事件内部, 有可能对dom进行操作. 此时浏览器便会挂起js引擎线程, 转而执行GUI渲染线程, 进行UI重绘(repaint)或者回流(reflow). 当js引擎重新执行时, GUI渲染线程又会被挂起, GUI更新将被保存起来, 等到js引擎空闲时立即被执行.

以上整个ajax请求过程中, 有涉及到浏览器的4种线程. 其中除了 GUI渲染线程 和 js引擎线程 是互斥的. 其他线程相互之间, 都是可以并行执行的. 通过这样的一种方式, ajax并没有破坏js的单线程机制.

## ajax与setTimeout排队问题
通常, ajax 和 setTimeout 的事件回调都被同等的对待, 按照顺序自动的被添加到 任务队列 的末尾, 等待js引擎空闲时执行. 但请注意, 并非xhr的所有回调执行都滞后于setTImeout的回调. 请看如下代码:

```
setTimeout(function(){
  console.log('setTimeout');
},0);
var resolve;
new Promise(function(r){
  resolve = r;
}).then(function(){
  console.log('promise nextTick');
});
resolve();

function ajax(url, method){
  var xhr = getXHR();
  xhr.onreadystatechange = function(){
      console.log('xhr.readyState:' + this.readyState);
  }
  xhr.onloadstart = function(){
      console.log('onloadStart');
  }
  xhr.onload = function(){
      console.log('onload');
  }
  xhr.open(method, url, true);
  xhr.setRequestHeader('Cache-Control',3600);
  xhr.send();
}
ajax('http://louiszhai.github.io/docImages/ajax01.png','GET');
console.warn('这里的log并不是最先打印出来的.');
```
上述代码执行结果如下图:

![http://louiszhai.github.io/docImages/ajax27.png](http://louiszhai.github.io/docImages/ajax27.png)

由于ajax异步, setTimeout及Promise本应该最先被执行, 然而实际上, 一次ajax请求, 并非所有的部分都是异步的, 至少”readyState==1”的 onreadystatechange 回调以及 onloadstart 回调就是同步执行的. 因此它们的输出排在最前面.

##XMLHttpRequest 属性解读
首先在Chrome console下创建一个 XMLHttpRequest 实例对象xhr. 如下所示:

![http://louiszhai.github.io/docImages/ajax01.png](http://louiszhai.github.io/docImages/ajax01.png)

### inherit
试运行以下代码.

```
var xhr = new XMLHttpRequest(),
    i=0;
for(var key in xhr){
    if(xhr.hasOwnProperty(key)){
       i++;
   }
}
console.log(i);//0
console.log(XMLHttpRequest.prototype.hasOwnProperty('timeout'));//true
```

可见, XMLHttpRequest 实例对象没有自有属性. 实际上, 它的所有属性均来自于 XMLHttpRequest.prototype .

追根溯源, XMLHttpRequest 实例对象具有如下的继承关系. (下面以a<<b表示a继承b)

xhr << XMLHttpRequest.prototype << XMLHttpRequestEventTarget.prototype << EventTarget.prototype << Object.prototype

由上, xhr也具有Object等原型中的所有方法. 如toString方法.

```
xhr.toString();//"[object XMLHttpRequest]"
```

通常, 一个xhr实例对象拥有10个普通属性+9个方法

### readyState
只读属性, readyState属性记录了ajax调用过程中所有可能的状态. 它的取值简单明了, 如下:

```

readyState	对应常量		描述
0 			(未初始化)		xhr.UNSENT	请求已建立, 但未初始化(此时未调用open方法)
1 			(初始化)		xhr.OPENED	请求已建立, 但未发送 (已调用open方法, 但未调用send方法)
2 			(发送数据)		xhr.HEADERS_RECEIVED	请求已发送 (send方法已调用, 已收到响应头)
3 			(数据传送中)		xhr.LOADING	请求处理中, 因响应内容不全, 这时通过responseBody和responseText获取可能会出现错误
4 			(完成)		xhr.DONE	数据接收完毕, 此时可以通过通过responseBody和responseText获取完整的响应数据
```

注意, readyState 是一个只读属性, 想要改变它的值是不可行的.

### onreadystatechange
onreadystatechange事件回调方法在readystate状态改变时触发, 在一个收到响应的ajax请求周期中, onreadystatechange 方法会被触发4次. 因此可以在 onreadystatechange 方法中绑定一些事件回调, 比如:

```
xhr.onreadystatechange = function(e){
  if(xhr.readyState==4){
    var s = xhr.status;
    if((s >= 200 && s < 300) || s == 304){
      var resp = xhr.responseText;
      //TODO ...
    }
  }
}
```

注意: onreadystatechange回调中默认会传入Event实例, 如下:
![http://louiszhai.github.io/docImages/ajax02.png](http://louiszhai.github.io/docImages/ajax02.png)

### status
只读属性, status表示http请求的状态, 初始值为0. 如果服务器没有显式地指定状态码, 那么status将被设置为默认值, 即200.

### statusText
只读属性, statusText表示服务器的响应状态信息, 它是一个 UTF-16 的字符串, 请求成功且status==20X时, 返回大写的 OK . 请求失败时返回空字符串. 其他情况下返回相应的状态描述. 比如: 301的 Moved Permanently , 302的 Found , 303的 See Other , 307 的 Temporary Redirect , 400的 Bad Request , 401的 Unauthorized 等等.

### onloadstart
onloadstart事件回调方法在ajax请求发送之前触发, 触发时机在 readyState==1 状态之后, readyState==2 状态之前.

onloadstart方法中默认将传入一个ProgressEvent事件进度对象. 如下:

![](http://louiszhai.github.io/docImages/ajax03.png)

ProgressEvent对象具有三个重要的Read only属性.

* lengthComputable 表示长度是否可计算, 它是一个布尔值, 初始值为false.
* loaded 表示已加载资源的大小, 如果使用http下载资源, 它仅仅表示已下载内容的大小, 而不包括http headers等. 它是一个无符号长整型, 初始值为0.
* total 表示资源总大小, 如果使用http下载资源, 它仅仅表示内容的总大小, 而不包括http headers等, 它同样是一个无符号长整型, 初始值为0.

### onprogress
onprogress事件回调方法在 readyState==3 状态时开始触发, 默认传入 ProgressEvent 对象, 可通过 e.loaded/e.total 来计算加载资源的进度, 该方法用于获取资源的下载进度.

注意: 该方法适用于 IE10+ 及其他现代浏览器.

```
xhr.onprogress = function(e){
  console.log('progress:', e.loaded/e.total);
}
```

### onload
onload事件回调方法在ajax请求成功后触发, 触发时机在 readyState==4 状态之后.

想要捕捉到一个ajax异步请求的成功状态, 并且执行回调, 一般下面的语句就足够了:

```
xhr.onload = function(){
  var s = xhr.status;
  if((s >= 200 && s < 300) || s == 304){
    var resp = xhr.responseText;
    //TODO ...
  }
}
```

### onloadend
onloadend事件回调方法在ajax请求完成后触发, 触发时机在 readyState==4 状态之后(收到响应时) 或者 readyState==2 状态之后(未收到响应时).

onloadend方法中默认将传入一个ProgressEvent事件进度对象.

### timeout
timeout属性用于指定ajax的超时时长. 通过它可以灵活地控制ajax请求时间的上限. timeout的值满足如下规则:

* 通常设置为0时不生效.
* 设置为字符串时, 如果字符串中全部为数字, 它会自动将字符串转化为数字, 反之该设置不生效.
* 设置为对象时, 如果该对象能够转化为数字, 那么将设置为转化后的数字.

```
xhr.timeout = 0; //不生效
xhr.timeout = '123'; //生效, 值为123
xhr.timeout = '123s'; //不生效
xhr.timeout = ['123']; //生效, 值为123
xhr.timeout = {a:123}; //不生效
```

### ontimeout
ontimeout方法在ajax请求超时时触发, 通过它可以在ajax请求超时时做一些后续处理.

```
xhr.ontimeout = function(e) {
  console.error("请求超时!!!")
}
```

### response responseText
均为只读属性, response表示服务器的响应内容, 相应的, responseText表示服务器响应内容的文本形式.

### responseXML
只读属性, responseXML表示xml形式的响应数据, 缺省为null, 若数据不是有效的xml, 则会报错.

### responseType
responseType表示响应的类型, 缺省为空字符串, 可取 "arraybuffer" , "blob" , "document" , "json" , and "text" 共五种类型.

### responseURL
responseURL返回ajax请求最终的URL, 如果请求中存在重定向, 那么responseURL表示重定向之后的URL.

### withCredentials
withCredentials是一个布尔值, 默认为false, 表示跨域请求中不发送cookies等信息. 当它设置为true时, cookies , authorization headers 或者TLS客户端证书 都可以正常发送和接收. 显然它的值对同域请求没有影响.

但是务必要注意，withCredentials属性什么时机设置，XMLHttpRequest Living Standard（2017）中有明确的规定。

```
Setting the withCredentials attribute must run these steps:

If state is not unsent or opened, throw an InvalidStateError exception.
If the send() flag is set, throw an InvalidStateError exception.
Set the withCredentials attribute’s value to the given value.
```

这意味着，readyState为unset或者opened之前，是不能为xhr对象设置withCredentials属性的，实际上，新建的xhr对象，默认就是unset状态，因此这里没有问题。问题出在w3c 2011年的规范，当时是这么描述的：

```
On setting the withCredentials attribute these steps must be run:

If the state is not OPENED raise an INVALID_STATE_ERR exception and terminate these steps.
If the send() flag is true raise an INVALID_STATE_ERR exception and terminate these steps.
If the anonymous flag is true raise an INVALID_ACCESS_ERR exception and terminate these steps.
Set the withCredentials attribute’s value to the given value.
```

注意第一条，readyState为unset之前，为xhr对象设置withCredentials属性就会抛出INVALID_STATE_ERR错误。

目前，一些老的浏览器或webview仍然是参考w3c 2011年的规范，因此为了兼容，建议在readyState为opened状态之后才去设置withCredentials属性。

之前zepto.js就踩过这个坑，感兴趣不妨阅读前方有坑，请绕道——Zepto 中使用 CORS。

注意: 该属性适用于 IE10+, opera12+及其他现代浏览器。Android 4.3及以下版本的webview，采用的是w3c 2011的规范，请务必在open方法调用之后再设置withCredentials的值。

### abort
abort方法用于取消ajax请求, 取消后, readyState 状态将被设置为 0 (UNSENT). 如下, 调用abort 方法后, 请求将被取消.

![http://louiszhai.github.io/docImages/ajax04.png](http://louiszhai.github.io/docImages/ajax04.png)

### getResponseHeader
getResponseHeader方法用于获取ajax响应头中指定name的值. 如果response headers中存在相同的name, 那么它们的值将自动以字符串的形式连接在一起.

```
console.log(xhr.getResponseHeader('Content-Type'));//"text/html"
```

### getAllResponseHeaders

getAllResponseHeaders方法用于获取所有安全的ajax响应头, 响应头以字符串形式返回. 每个HTTP报头名称和值用冒号分隔, 如key:value, 并以\r\n结束.

```
xhr.onreadystatechange = function() {
  if(this.readyState == this.HEADERS_RECEIVED) {
    console.log(this.getAllResponseHeaders());
  }
}
//Content-Type: text/html"
```

以上, readyState === 2 状态时, 就意味着响应头已接受完整. 此时便可以打印出完整的 response headers.

### setRequestHeader
既然可以获取响应头, 那么自然也可以设置请求头, setRequestHeader就是干这个的. 如下:

```
//指定请求的type为json格式
xhr.setRequestHeader("Content-type", "application/json");
//除此之外, 还可以设置其他的请求头
xhr.setRequestHeader('x-requested-with', '123456');
```

### onerror
onerror方法用于在ajax请求出错后执行. 通常只在网络出现问题时或者ERR_CONNECTION_RESET时触发(如果请求返回的是407状态码, chrome下也会触发onerror).

### upload
upload属性默认返回一个 XMLHttpRequestUpload 对象, 用于上传资源. 该对象具有如下方法:

* onloadstart
* onprogress
* onabort
* onerror
* onload
* ontimeout
* onloadend

上述方法功能同 xhr 对象中同名方法一致. 其中, onprogress 事件回调方法可用于跟踪资源上传的进度.

```
xhr.upload.onprogress = function(e){
  var percent = 100 * e.loaded / e.total |0;
  console.log('upload: ' + precent + '%');
}
```

### overrideMimeType
overrideMimeType方法用于强制指定response 的 MIME 类型, 即强制修改response的 Content-Type . 如下, 服务器返回的response的 MIME 类型为 text/plain .

![http://louiszhai.github.io/docImages/ajax05.png](http://louiszhai.github.io/docImages/ajax05.png)

```
xhr.getResponseHeader('Content-Type');//"text/plain"
xhr.responseXML;//null
```

通过overrideMimeType方法将response的MIME类型设置为 text/xml;charset=utf-8 , 如下所示:

```
xhr.overrideMimeType("text/xml; charset = utf-8");
xhr.send();
```

此时虽然 response headers 如上图, 没有变化, 但 Content-Type 已替换为新值.

```
xhr.getResponseHeader('Content-Type');//"text/xml; charset = utf-8"
```
此时, xhr.responseXML 也将返回DOM对象, 如下图.

![http://louiszhai.github.io/docImages/ajax06.png](http://louiszhai.github.io/docImages/ajax06.png)

## XHR一级
XHR1 即 XMLHttpRequest Level 1. XHR1时, xhr对象具有如下缺点:

* 仅支持文本数据传输, 无法传输二进制数据.
* 传输数据时, 没有进度信息提示, 只能提示是否完成.
* 受浏览器 同源策略 限制, 只能请求同域资源.
* 没有超时机制, 不方便掌控ajax请求节奏.

## XHR二级
XHR2 即 XMLHttpRequest Level 2. XHR2针对XHR1的上述缺点做了如下改进:

* 支持二进制数据, 可以上传文件, 可以使用FormData对象管理表单.
* 提供进度提示, 可通过 xhr.upload.onprogress 事件回调方法获取传输进度.
* 依然受 同源策略 限制, 这个安全机制不会变. XHR2新提供 Access-Control-Allow-Origin 等headers, 设置为 * 时表示允许任何域名请求, 从而实现跨域CORS访问(有关CORS详细介绍请耐心往下读).
* 可以设置timeout 及 ontimeout, 方便设置超时时长和超时后续处理

这里就H5新增的FormData对象举个例.

```
//可直接创建FormData实例
var data = new FormData();
data.append("name", "louis");
xhr.send(data);
//还可以通过传入表单DOM对象来创建FormData实例
var form = document.getElementById('form');
var data = new FormData(form);
data.append("password", "123456");
xhr.send(data);
```
目前, 主流浏览器基本上都支持XHR2, 除了IE系列需要IE10及更高版本. 因此IE10以下是不支持XHR2的.

那么问题来了, IE7, 8,9的用户怎么办? 很遗憾, 这些用户是比较尴尬的. 对于IE8,9而言, 只有一个阉割版的 XDomainRequest 可用,IE7则没有. 估计IE7用户只能哭晕在厕所了
##XDomainRequest
XDomainRequest 对象是IE8,9折腾出来的, 用于支持CORS请求非成熟的解决方案. 以至于IE10中直接移除了它, 并重新回到了 XMLHttpRequest 的怀抱.

XDomainRequest 仅可用于发送 GET和 POST 请求. 如下即创建过程.

```
var xdr = new XDomainRequest();
```

xdr具有如下属性:

* timeout
* responseText

如下方法:

* open: 只能接收Method,和url两个参数. 只能发送异步请求.
* send
* abort

如下事件回调:

* onprogress
* ontimeout
* onerror
* onload

除了缺少一些方法外, XDomainRequest 基本上就和 XMLHttpRequest 的使用方式保持一致.

必须要明确的是:

* XDomainRequest 不支持跨域传输cookie.
* 只能设置请求头的Content-Type字段, 且不能访问响应头信息.

## ajax跨域请求
### 什么是CORS
CORS是一个W3C(World Wide Web)标准, 全称是跨域资源共享(Cross-origin resource sharing).它允许浏览器向跨域服务器, 发出异步http请求, 从而克服了ajax受同源策略的限制. 实际上, 浏览器不会拦截不合法的跨域请求, 而是拦截了他们的响应, 因此即使请求不合法, 很多时候, 服务器依然收到了请求.(Chrome和Firefox下https网站不允许发送http异步请求除外)

通常, 一次跨域访问拥有如下流程:

![http://louiszhai.github.io/docImages/cross-domain02.jpg](http://louiszhai.github.io/docImages/cross-domain02.jpg)

### 移动端CORS兼容性
当前几乎所有的桌面浏览器(Internet Explorer 8+, Firefox 3.5+, Safari 4+和 Chrome 3+)都可通过名为跨域资源共享的协议支持ajax跨域调用.

那么移动端兼容性又如何呢? 请看下图:

![http://louiszhai.github.io/docImages/ajax25.png](http://louiszhai.github.io/docImages/ajax25.png)

可见, CORS的技术在IOS Safari7.1及Android webview2.3中就早已支持, 即使低版本下webview的canvas在使用跨域的video或图片时会有问题, 也丝毫不影响CORS的在移动端的使用. 至此, 我们就可以放心大胆的去应用CORS了.

### CORS有关的headers
#### HTTP Response Header(服务器提供):

* Access-Control-Allow-Origin: 指定允许哪些源的网页发送请求.
* Access-Control-Allow-Credentials: 指定是否允许cookie发送.
* Access-Control-Allow-Methods: 指定允许哪些请求方法.
* Access-Control-Allow-Headers: 指定允许哪些常规的头域字段, 比如说 Content-Type.
* Access-Control-Expose-Headers: 指定允许哪些额外的头域字段, 比如说 X-Custom-Header.

该字段可省略. CORS请求时, xhr.getResponseHeader() 方法默认只能获取6个基本字段: Cache-Control、Content-Language、Content-Type、Expires、Last-Modified、Pragma . 如果需要获取其他字段, 就需要在Access-Control-Expose-Headers 中指定. 如上, 这样xhr.getResponseHeader(‘X-Custom-Header’) 才能返回X-Custom-Header字段的值.(该部分摘自阮一峰老师博客)

* Access-Control-Max-Age: 指定preflight OPTIONS请求的有效期, 单位为秒.

#### HTTP Request Header(浏览器OPTIONS请求默认自带):

* Access-Control-Request-Method: 告知服务器,浏览器将发送哪种请求, 比如说POST.
* Access-Control-Request-Headers: 告知服务器, 浏览器将包含哪些额外的头域字段.

#### 以下所有的header name 是被拒绝的:

* Accept-Charset
* Accept-Encoding
* Access-Control-Request-Headers
* Access-Control-Request-Method
* Connection
* Content-Length
* Cookie
* Cookie2
* Date
* DNT
* Expect
* Host
* Keep-Alive
* Origin
* Referer
* TE
* Trailer
* Transfer-Encoding
* Upgrade
* Via
* 包含以Proxy- 或 Sec- 开头的header name

### CORS请求
CORS请求分为两种, ① 简单请求; ② 非简单请求.

满足如下两个条件便是简单请求, 反之则为非简单请求.(CORS请求部分摘自阮一峰老师博客)

#### 请求是以下三种之一:

* HEAD
* GET
* POST

#### http头域不超出以下几种字段:

* Accept
* Accept-Language
* Content-Language
* Last-Event-ID
* Content-Type字段限三个值 application/x-www-form-urlencoded、multipart/form-data、text/plain

对于简单请求, 浏览器将发送一次http请求, 同时在Request头域中增加 Origin 字段, 用来标示请求发起的源, 服务器根据这个源采取不同的响应策略. 若服务器认为该请求合法, 那么需要往返回的 HTTP Response 中添加 Access-Control-* 等字段.( Access-Control-* 相关字段解析请阅读我之前写的CORS 跨域访问 )

对于非简单请求, 比如Method为POST且Content-Type值为 application/json 的请求或者Method为 PUT 或 DELETE 的请求, 浏览器将发送两次http请求. 第一次为preflight预检(Method: OPTIONS),主要验证来源是否合法. 值得注意的是:OPTION请求响应头同样需要包含 Access-Control-* 字段等. 第二次才是真正的HTTP请求. 所以服务器必须处理OPTIONS应答(通常需要返回20X的状态码, 否则xhr.onerror事件将被触发).

以上请求流程图为:

![http://louiszhai.github.io/docImages/cross-domain01.jpg](http://louiszhai.github.io/docImages/cross-domain01.jpg)

### HTML启用CORS
http-equiv 相当于http的响应头, 它回应给浏览器一些有用的信息,以帮助正确和精确地显示网页内容. 如下html将允许任意域名下的网页跨域访问.

```
<meta http-equiv="Access-Control-Allow-Origin" content="*">
```

### 图片启用CORS
通常, 图片允许跨域访问, 也可以在canvas中使用跨域的图片, 但这样做会污染画布, 一旦画布受污染, 将无法读取其数据. 比如无法调用 toBlob(), toDataURL() 或 getImageData()方法. 浏览器的这种安全机制规避了未经许可的远程服务器图片被滥用的风险.(该部分内容摘自 启用了 CORS 的图片 - HTML（超文本标记语言） | MDN)

因此如需在canvas中使用跨域的图片资源, 请参考如下apache配置片段(来自HTML5 Boilerplate Apache server configs).

```
<IfModule mod_setenvif.c>
    <IfModule mod_headers.c>
        <FilesMatch "\.(cur|gif|ico|jpe?g|png|svgz?|webp)$">
            SetEnvIf Origin ":" IS_CORS
            Header set Access-Control-Allow-Origin "*" env=IS_CORS
        </FilesMatch>
    </IfModule>
</IfModule>
```

## ajax文件上传
为了上传文件, 我们得先选中一个文件. 一个type为file的input框就够了.

```
<input id="input" type="file">
```

然后用FormData对象包裹📦选中的文件.

```
var input = document.getElementById("input"),
    formData = new FormData();
formData.append("file",input.files[0]);//key可以随意定义,只要后台能理解就行
```

定义上传的URL, 以及方法. github上我搭建了一个 node-webserver, 根据需要可以自行克隆下来npm start后便可调试本篇代码.

```
var url = "http://localhost:10108/test", method = "POST";
```

### js文件上传
封装一个用于发送ajax请求的方法.

```
function ajax(url, method, data){
  var xhr = null;
  if(window.XMLHttpRequest) {
    xhr = new XMLHttpRequest();
  } else if (window.ActiveXObject) {
    try {
      xhr = new ActiveXObject("Msxml2.XMLHTTP");
    } catch (e) {
      try {
        xhr = new ActiveXObject("Microsoft.XMLHTTP");
      } catch (e) { 
        alert("您的浏览器暂不支持Ajax!");
      }
    }
  }
  xhr.onerror = function(e){
    console.log(e);
  }
  xhr.open(method, url);
  try{
    setTimeout(function(){
      xhr.send(data);
    });
  }catch(e){
    console.log('error:',e);
  }
  return xhr;
}
```

上传文件并绑定事件.

```
var xhr = ajax(url, method, formData);
xhr.upload.onprogress = function(e){
  console.log("upload progress:", e.loaded/e.total*100 + "%");
};
xhr.upload.onload = function(){
  console.log("upload onload.");
};
xhr.onload = function(){
  console.log("onload.");
}
```

![http://louiszhai.github.io/docImages/ajax17.png](http://louiszhai.github.io/docImages/ajax17.png)

### fetch上传
fetch只要发送一个post请求, 并且body属性设置为formData即可. 遗憾的是, fetch无法跟踪上传的进度信息.

```
fetch(url, {
  method: method,
  body: formData
  }).then(function(res){
  console.log(res);
  }).catch(function(e){
  console.log(e);
});
```

## ajax请求二进制文件
### FileReader
处理二进制文件主要使用的是H5的FileReader.

PC支持性如下:

```
IE	Edge	Firefox	Chrome	  Safari	Opera
10	12	   3.6	       6	      6	   11.5
```

Mobile支持性如下:

```
IOS Safari	Opera Mini	Android Browser	Chrome/Android	UC/Android
7.1	-	4	53	11
```

以下是其API:

```
属性/方法名称	描述
error	表示读取文件期间发生的错误.
readyState	表示读取文件的状态.默认有三个值:0表示文件还没有加载;1表示文件正在读取;2表示文件读取完成.
result	读取的文件内容.
abort()	取消文件读取操作, 此时readyState属性将置为2.
readAsArrayBuffer()	读取文件(或blob对象)为类型化数组(ArrayBuffer), 类型化数组允许开发者以数组下标的方式, 直接操作内存, 由于数据以二进制形式传递, 效率非常高.
readAsBinaryString()	读取文件(或blob对象)为二进制字符串, 该方法已移出标准api, 请谨慎使用.
readAsDataURL()	读取文件(或blob对象)为base64编码的URL字符串, 与window.URL.createObjectURL方法效果类似.
readAsText()	读取文件(或blob对象)为文本字符串.
onload()	文件读取完成时的事件回调, 默认传入event事件对象. 该回调内, 可通过this.result 或 event.target.result获取读取的文件内容.
```

### ajax请求二进制图片并预览

```
var xhr = new XMLHttpRequest(),
    url = "http://louiszhai.github.io/docImages/ajax01.png";
xhr.open("GET", url);
xhr.responseType = "blob";
xhr.onload = function(){
  if(this.status == 200){
    var blob = this.response;
    var img = document.createElement("img");
    //方案一
    img.src = window.URL.createObjectURL(blob);//这里blob依然占据着内存
    img.onload = function() {
      window.URL.revokeObjectURL(img.src);//释放内存
    };
    //方案二
    /*var reader = new FileReader();
    reader.readAsDataURL(blob);//FileReader将返回base64编码的data-uri对象
    reader.onload = function(){
      img.src = this.result;
    }*/
    //方案三
    //img.src = url;//最简单方法
    document.body.appendChild(img);
  }
}
xhr.send();
```

### ajax请求二进制文本并展示

```
var xhr = new XMLHttpRequest();
xhr.open("GET","http://localhost:8080/Information/download.jsp?data=node-fetch.js");
xhr.responseType = "blob";
xhr.onload = function(){
  if(this.status == 200){
    var blob = this.response;
    var reader = new FileReader();
    reader.readAsBinaryString(blob);//该方法已被移出标准api,建议使用reader.readAsText(blob);
    reader.onload=function(){
      document.body.innerHTML = "<div>" + this.result + "</div>";
    }
  }
}
xhr.send();
```







