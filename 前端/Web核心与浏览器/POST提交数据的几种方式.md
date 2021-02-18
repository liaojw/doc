# POST提交数据的几种方式

提到HTTP使用`POST`请求提交数据的方式，第一反应就是以对象形式提交，如果是文件，则换成`formData`形式提交。除此之外好像还有个一长串的`x-www-form-urlencoded`，可这全是碎片化的知识点，毫无章法。最近做项目时用到了`axios`，详细的翻看了一下文档，有个地方引起了我的兴趣：`By default, axios serializes JavaScript objects to JSON. To send data in the application/x-www-form-urlencoded format instead, you can use one of the following options`。等等，这里说`axios`默认使用序列化的`JSON`发送数据，但如果你要使用`application/x-www-form-urlencoded`格式的话，可以使用`qs`库或者`new URLSearchParams()`。赶紧网上查阅资料，才发现自己遇到了知识盲点，现系统的总结一下这个小知识点。

## 概述

常用的HTTP请求方法有`GET`、`POST`、`PUT`、`DELETE`、`HEAD`、`OPTIONS`等。客户端发送一个HTTP请求到服务器，这个请求消息包括：请求行、请求头部、空行和请求数据：

```
<method> <request-url> <version>
<headers>

<entity-body>
```

我们使用`POST`发送的数据必须放在消息主体(entity-body)中，但是HTTP协议并没有规定使用什么样的编码方式来传送数据。这个编码方式前端可以自己来决定，但是数据发出去，还要服务端能解析成功才有意义。服务端自有不同的方法来解析不同编码格式的数据，而且服务端可以根据请求头(headers)内的`Content-Type`字段去获知编码方式，然后去解析数据。

## 几种常见的Content-Type类型

### application/x-www-form-urlencoded

`application/x-www-form-urlencoded`是一种比较常见的编码方式。我们在使用浏览器原生的`form`表单提交数据时，如果没有指定`enctype`属性，则默认会以该方式提交数据。

```
<form action="http://www.baidu.com" method="post">
  <input type="text" name="name">
  <input type="text" name="age">
  <button type="submit">提交</button>
</form>
```

在浏览里可以看到：

[![img](https://liyang0207.github.io/images/http-post-01.png)](https://liyang0207.github.io/images/http-post-01.png)

首先，我们看到请求头`Request Headers`内的`Content-Type`字段被设置为了`application/x-www-form-urlencoded`；其次，提交的数据按照`key1=value1&key2=value2`的方式进行了编码，服务端语言对这种编码方式有很好的支持。

### multipart/form-data

当我们在上传图片或者文件的时候，会用到这种编码方式。如果使用原生`form`表单，则需要将`enctype`设置为`multipart/form-data`进行提交。如果使用`ajax`库，则需要以`formData`的形式提交数据：

```
let _formData = new FormData();
_formData.append('file', file);
_formData.append('suffix', suffix);
_formData.append('perpetual', true);
_formData.append('applicationId', applicationId);
_formData.append('partyId', partyId);
api.saveHeadImg(_formData).then(console.log(res));
```

在浏览器中：

[![img](https://liyang0207.github.io/images/http-post-02.png)](https://liyang0207.github.io/images/http-post-02.png)

首先，请求头内`Content-Type`除了有`multipart/form-data;`外，额外生成了一个`boundary`字段，这个字段用来分割请求数据内的不同字段。在请求体内，数据字段每部分都是以`--boundary`开头，紧接着是内容描述信息，包括字段名称，字段值等。请求体最后以`--boundary—`标识结束。

### application/json

以`application/json`作为响应头或者请求头都非常常见。这种编码方式会告诉服务端提交的数据类型是序列化后的`JSON`字符串，前端在调接口提交数据时，直接以对象形式传递数据即可。

```
let params = {
  loanApplyNo: 'XTFQ201903270010',
  returnUrl: window.location.origin + '/loan/result',
};
api.saveData(params).then(console.log(res));
```

在浏览器端：

[![img](https://liyang0207.github.io/images/http-post-03.jpg)](https://liyang0207.github.io/images/http-post-03.jpg)

`axios`这个库默认就是使用序列化的`JSON`形式`POST`数据。但如果服务器端比较~~蛋疼~~的规定只接收`application/x-www-form-urlencoded`格式，则可以使用`qs`库或者[URLSearchParams ](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams)API来做转换处理：

```
const params = new URLSearchParams();
params.append('param1', 'value1');
params.append('param2', 'value2');
axios.post('/foo', params);

//或者
import qs from 'qs';
axios.post('/foo', qs.stringify({ 'bar': 123 }));
```

写到这里，想到`Angular4+`同样提供了 [HttpParams](https://angular.cn/api/common/http/HttpParams) 类来将普通对象转换为`application/x-www-form-urlencoded`。当时写`Angular`的时候还没意识到这一点，真是糊涂。

以上就是平时用到最多的三种`POST`数据类型，当然还有其他的编码格式，但是我暂时还未用到或者见到过。日后使用到其他格式类型，可以继续补充。