# Node环境变量 process.env
## 前言
这两天在和运维GG搞部署项目的事儿。

碰到一个问题就是，咱们的dev，uat，product环境的问题。

因为是前后端分离，所以在开发和部署的过程中会有对后端接口的域名的切换问题。折腾了一下午，查询了各种资料这才把这**Node**环境变量**process.env**给弄明白。

## Node环境变量
首先，咱们在做**react**、**vue**的单页应用开发的时候，相信大家对配置文件里的**process.env**并不眼生。

就是下面这些玩意儿。

![](https://segmentfault.com/img/bVXbr0?w=749&h=192)

从字面上看，就是这个 **env**属性，在 **development**和**production**不同环境上，配置会有些不同。

行，那下面我们开始看看这个所谓的 **process**到底是个什么东西。

> 文档：[http://nodejs.cn/api/process.html](http://nodejs.cn/api/process.html)
> 
> 官方解释：**process** 对象是一个 **global** （全局变量），提供有关信息，控制当前 **Node.js** 进程。作为一个对象，它对于 **Node.js** 应用程序始终是可用的，故无需使用 **require()**。

process（进程）其实就是存在nodejs中的一个全局变量。

然后呢，咱们可以通过这个所谓的进程能拿到一些有意思的东西。

不过我们今天主要是讲讲 **process.env**。

## process.env

> 官方: **process.env**属性返回一个包含用户环境信息的对象。
> 
> 文档：[http://nodejs.cn/api/process....](http://nodejs.cn/api/process.html#process_process_env)

很明显的一个使用场景，依靠这个我们就可以给服务器上打上一个标签。这样的话，我们就能根据不同的环境，做一些配置上的处理。比如开启 sourceMap，后端接口的域名切换等等。

```
你是 dev 环境
他是 uat 环境
她是 product 环境。
```

## 如何配置环境变量
### Windows配置
#### 临时配置
直接在cmd环境配置即可，查看环境变量，添加环境变量，删除环境变量。

```
#node中常用的到的环境变量是NODE_ENV，首先查看是否存在 
set NODE_ENV 
#如果不存在则添加环境变量 
set NODE_ENV=production 
#环境变量追加值 set 变量名=%变量名%;变量内容 
set path=%path%;C:\web;C:\Tools 
#某些时候需要删除环境变量 
set NODE_ENV=
```
#### 永久配置
右键(此电脑) -> 属性(R) -> 高级系统设置 -> 环境变量(N)...

### Linux配置
#### 临时
查看环境变量，添加环境变量，删除环境变量

```
#node中常用的到的环境变量是NODE_ENV，首先查看是否存在
echo $NODE_ENV
#如果不存在则添加环境变量
export NODE_ENV=production
#环境变量追加值
export path=$path:/home/download:/usr/local/
#某些时候需要删除环境变量
unset NODE_ENV
#某些时候需要显示所有的环境变量
env
```

#### 永久
打开配置文件所在

```
# 所有用户都生效
vim /etc/profile
# 当前用户生效
vim ~/.bash_profile
```

在文件末尾添加类似如下语句进行环境变量的设置或修改

```
# 在文件末尾添加如下格式的环境变量
export path=$path:/home/download:/usr/local/
export NODE_ENV = product
```

最后修改完成后需要运行如下语句令系统重新加载

```
# 修改/etc/profile文件后
source /etc/profile
# 修改~/.bash_profile文件后
source ~/.bash_profile
```

## 解决环境导致后端接口变换问题
搞清楚这个问题后，我们就可以在不同环境的机器上设置不同的 **NODE_ENV**，当然这个字段也不一定。
你也可以换成其他的**NODE_ENV_NIZUISHUAI**等等，反正是自定义的。

### 解决步骤
#### 1.修改代码里的后端地址配置
很简单，就是利用 **process.env.NODE_ENV**这个字段来判断。（**process**是**node**全局属性，直接用就行了）

![](https://segmentfault.com/img/bVXbBe?w=585&h=387)

#### 2.在linux上设置环境变量

```
export NODE_ENV=dev
```

然后你就可以去愉快的启动项目玩了。

## 说在最后
因为我现在这个项目 React 服务端渲染。所以后端的请求转发就没交给nginx进行处理。
像平常的纯单页应用，一般是用nginx进行请求转发的。

## Node.js的process模块
process模块用来与当前进程互动，可以通过全局变量process访问，不必使用require命令加载。它是一个EventEmitter对象的实例。

### 属性
process对象提供一系列属性，用于返回系统信息。

* process.pid：当前进程的进程号
* process.version：Node的版本，比如v0.10.18。
* process.platform：当前系统平台，比如Linux。
* process.title：默认值为“node”，可以自定义该值。
* process.argv：当前进程的命令行参数数组。
* process.env：指向当前shell的环境变量，比如process.env.HOME。
* process.execPath：运行当前进程的可执行文件的绝对路径。
* process.stdout：指向标准输出。
* process.stdin：指向标准输入。
* process.stderr：指向标准错误。

### stdout
process.stdout用来控制标准输出，也就是在命令行窗口向用户显示内容。它的write方法等同于console.log。

```
exports.log = function() {
    process.stdout.write(format.apply(this, arguments) + '\n');
};
```
### argv
process.argv返回命令行脚本的各个参数组成的数组。

先新建一个脚本文件argv.js。

```
// argv.js
 
console.log("argv: ",process.argv);
console.log("argc: ",process.argc);
```
在命令行下调用这个脚本，会得到以下结果。

```
node argv.js a b c
# [ 'node', '/path/to/argv.js', 'a', 'b', 'c' ]
```

上面代码表示，argv返回数组的成员依次是命令行的各个部分。要得到真正的参数部分，可以把argv.js改写成下面这样。

```
// argv.js
 
var myArgs = process.argv.slice(2);
console.log(myArgs);
```

### 方法
process对象提供以下方法：

* process.exit()：退出当前进程。
* process.cwd()：返回运行当前脚本的工作目录的路径。_
* process.chdir()：改变工作目录。
* process.nextTick()：将一个回调函数放在下次事件循环的顶部。

process.chdir()改变工作目录的例子。

```
process.cwd()
# '/home/aaa'
 
process.chdir('/home/bbb')
 
process.cwd()
# '/home/bbb'
```

process.nextTick()的例子，指定下次事件循环首先运行的任务。

```
process.nextTick(function () {
    console.log('Next event loop!');
});
```

上面代码可以用setTimeout改写，但是nextTick的效果更高、描述更准确。

```
setTimeout(function () {
   console.log('Next event loop!');
}, 0)
```

### 事件
#### exit事件

当前进程退出时，会触发exit事件，可以对该事件指定回调函数。这一个用来定时检查模块的状态的好钩子(hook)(例如单元测试),当主事件循环在执行完’exit’的回调函数后将不再执行,所以在exit事件中定义的定时器可能不会被加入事件列表.

```
process.on('exit', function () {
  fs.writeFileSync('/tmp/myfile', 'This MUST be saved on exit.');
});
```

#### uncaughtException事件
当前进程抛出一个没有被捕捉的意外时，会触发uncaughtException事件。

```
process.on('uncaughtException', function (err) {
   console.error('An uncaught error occurred!');
   console.error(err.stack);
 });
```
