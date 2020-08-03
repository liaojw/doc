# Vue.js 中使用第三方库
在诸多 Vue.js 应用中, jQuery, Lodash, Moment, Axios, Async等都是一些非常有用的 JavaScript 库. 但随着项目越来越复杂, 可能会采取组件化和模块化的方式来组织代码, 还可能要使应用支持不同环境下的服务端渲染. 除非你找到了一个简单而又健壮的方式来引入这些库供不同的组件和模块使用, 不然, 这些第三方库的管理会给你带来一些麻烦

## 1、第三方库引入

### 全局变量
在项目中添加第三方库的最简单方式是讲其作为一个全局变量, 挂载到 window 对象上

* entry.js

```
window._ = require('lodash');
```
* MyComponent.vue

```
export default {
  created() {
    console.log(_.isEmpty() ? 'Lodash everywhere!' : 'Uh oh..');
  }
}
```
这种方式不适合于服务端渲染, 因为服务端没有 window 对象, 是 undefined, 当试图去访问属性时会报错.
### 在每个文件中引入
另一个简单的方式是在每一个需要该库的文件中导入

* MyComponent.vue

```
import _ from 'lodash';
 
export default {
  created() {
    console.log(_.isEmpty() ? 'Lodash is available here!' : 'Uh oh..');
  }
}
```
这种方式是允许的, 但是比较繁琐, 并且带来的问题是: 你必须记住在哪些文件引用了该库, 如果项目不再依赖这个库时, 得去找到每一个引用该库的文件并删除该库的引用. 如果构建工具没设置正确, 可能导致该库的多份拷贝被引用
### 优雅的方式
在 Vuejs 项目中使用 JavaScript 库的一个优雅方式是讲其代理到 Vue 的原型对象上去. 按照这种方式, 我们引入 Moment 库:

* entry.js

```
import moment from 'moment';
Object.defineProperty(Vue.prototype, '$moment', { value: moment });
```
由于所有的组件都会从 Vue 的原型对象上继承它们的方法, 因此在所有组件/实例中都可以通过 this.$moment: 的方式访问 Moment 而不需要定义全局变量或者手动的引入.

* MyNewComponent.vue

```
export default {
  created() {
    console.log('The time is ' . this.$moment().format("HH:mm"));
  }
}
```
接下来就了解下这种方式的工作原理.
#### Object.defineProperty
一般而言, 可以按照下面的方式来给对象设置属性:

```
Vue.prototype.$moment = moment;
```
可以这样做, 但是 Object.defineProperty 允许我们通过一个 descriptor 来定义属性. Descriptor 运行我们去设置对象属性的一些底层(low-level)细节, 如是否允许属性可写? 是否允许属性在 for 循环中被遍历.

通常, 我们不会为此感到困扰, 因为大部分时候, 对于属性赋值, 我们不需要考虑这样的细节. 但这有一个明显的优点: **通过 descriptor 创建的属性默认是只读的.**

这就意味着, 一些处于迷糊状态的(coffee-deprived)开发者不能在组件内去做一些很愚蠢的事情, 就像这样:

```
this.$http = 'Assign some random thing to the instance method';
this.$http.get('/'); // TypeError: this.$http.get is not a function
```
此外, 试图给只读实例的方法重新赋值会得到 TypeError: Cannot assign to read only property 的错误.

#### $
你可能会注意到, 代理第三库的属性会有一个 $ 前缀, 也可能看到其它类似 $refs, $on, $mount 的属性和方式, 它们也有这个前缀.

这个不是强制要求, 给属性添加 $ 前缀是提供那些处于迷糊状态(coffee-deprived)的开发者这是一个公开的 API, 和 Vuejs 的一些内部属性和方法区分开来.

#### this
你还可能注意到, 在组件内是通过 this.libraryName 的方式来使用第三方库的, 当你知道它是一个实例方法时就不会感到意外了. 但与全局变量不同, 通过 this 来使用第三方库时, 必须确保 this 处于正确的作用域. 在回调方法中 this 的作用域会有不同, 但箭头式回调风格能保证 this 的作用域是正确的:

```
this.$http.get('/').then(res => {
  if (res.status !== 200) {
    this.$http.get('/') // etc
    // Only works in a fat arrow callback.
  }
});
```
### 插件
如果你想在多个项目中使用同一个库, 或者想将其分享给其他人, 可以将其写成一个插件:

```
import MyLibraryPlugin from 'my-library-plugin';
Vue.use(MyLibraryPlugin);
```
在应用的入口引入插件之后, 就可以在任何一个组件内像使用 Vue Router, Vuex 一样使用你定义的库了.
####写一个插件
首先, 创建一个文件用于编写自己的插件. 在示例中, 我会将 Axios 作为插件添加到项目中, 因而我给文件起名为 axios.js. 其次, 插件要对外暴露一个 install 方法, 该方法的第一个参数是 Vue 的构造函数:

* axios.js

```
export default {
  install: function(Vue) {
    // Do stuff
  }
}
```
可以使用先前将库添加到原型对象上的方法:

* axios.js

```
import axios from 'axios';
 
export default {
  install: function(Vue,) {
    Object.defineProperty(Vue.prototype, '$http', { value: axios });
  }
}
```
最后, 利用 Vue 的实例方法 use 将插件添加到项目中:

* entry.js

```
import AxiosPlugin from './axios.js';
Vue.use(AxiosPlugin);
 
new Vue({
  created() {
    console.log(this.$http ? 'Axios works!' : 'Uh oh..');
  }
})
```

#### 插件的可选参数
插件的 install 方法可以接受可选参数. 一些开发可能不喜欢将 Axios 实例命名为 $http, 因为这是 Vue Resource 提供的一个通用名字. 因而可以提供一个可选的参数允许他们随意命名:

* axios.js

```
import axios from 'axios';
 
export default {
  install: function(Vue, name = '$http') {
    Object.defineProperty(Vue.prototype, name, { value: axios });
  }
}
```

* entry.js

```
import AxiosPlugin from './axios.js';
Vue.use(AxiosPlugin, '$axios');
 
new Vue({
  created() {
    console.log(this.$axios ? 'Axios works!' : 'Uh oh..');
  }
})
```



## 2、引入jQuery
###通过npm安装依赖引入
安装

```
npm install jquery -S
```
修改webpack配置文件（build/webpack.base.conf.js）

```
var webpack = require("webpack") // 确保引入 webpack，后面会用到

module.exports = {
  ...
  resolve: {
    extensions: ['.js', '.vue', '.json'],
    modules: [
      resolve('src'),
      resolve('node_modules')
    ],
    alias: {
      'vue$': 'vue/dist/vue.common.js',
      'src': resolve('src'),
      'assets': resolve('src/assets'),
      'components': resolve('src/components'),  
      'jquery': 'jquery' 
    }
  },
  plugins: [
    //配置全局使用 jquery
    new webpack.ProvidePlugin({
        $: "jquery",
        jQuery: "jquery",
        jquery: "jquery",
        "window.jQuery": "jquery"
    })
  ]
}
```
### 手动载入
手动下载jquery 放在static 目录下，如：static/js/jquery.min.js

和npm不同的只是在第二步定义别名和插件位置：

```
alias: {
    'vue$': 'vue/dist/vue.common.js',
    'src': resolve('src'),
    'assets': resolve('src/assets'),
    'components': resolve('src/components'),
    // 2. 定义别名和插件位置
    "jquery": path.resolve(__dirname, '../static/js/jquery.min.js') 
}
```
手动载入的jQuery时，如果有jquery插件以来jQuery，会遇到不是一个实例的问题，导致jQuery插件无法使用

可以在webpack的配置文件中把它配置为全局变量即可
jquery直接在html中引入

```
<script src="./static/js/jquery.min.js"></script>
```
然后在webpack配置文件中配置为全局变量

```
externals: {
    jquery: 'window.$'
},
```

使用时则直接引入

```
var $ = require('jquery');
```
或者直接使用官方推荐方法[expose-loade](https://link.zhihu.com/?target=https%3A//webpack.js.org/loaders/expose-loader/)

## 3、css
在vue-cli中使用sass、less来编写css样式，步骤十分简洁，因为vue-cli已经配置好了sass、less，我们要使用sass或者less直接下载两个模块，然后webpack会根据 lang 属性自动用适当的加载器去处理。

### CSS

* 直接上手写样式即可，使用css规则
* 引用外部css文件的写法

```
<style lang="css">  
 @import './index.css'  
</style>  
 或者  
<style lang="css" src="./index.css"></style> 
```

### 使用sass

* 安装sass模块

```
npm install node-sass --save-dev  
npm install sass-loader --save-dev
```
* 在组件的style部分使用内联写法

```
<template></template>
<script></script>
<style lang="scss" scoped>//在这个部分添加lang="scss"
 //sass样式  
</style>  
```
* 引用sass外部文件的写法

```
<style lang="scss" src="./index.scss"></style>
```
### 使用less

* 安装less模块

```
npm install less --save-dev  
npm install less-loader --save-dev 
```
* 在组件的style部分使用内联写法

```
<template></template>
<script></script>
<style lang="less" scoped>//在这个部分添加lang="less"  
 //less样式  
</style>  
```
* 引用less外部文件的写法

```
<style lang="less" src="./index.less"></style>
```

## 4、安装echarts依赖

### 通过npm安装依赖引入
安装

```
npm install echarts -S
```
### 全局引入

* main.js

```
// 引入echarts
import echarts from 'echarts'

Vue.prototype.$echarts = echarts 
```
* Hello.vue

```
<div id="myChart" :style="{width: '300px', height: '300px'}"></div>
```

```
export default {
  name: 'hello',
  data () {
    return {
      msg: 'Welcome to Your Vue.js App'
    }
  },
  mounted(){
    this.drawLine();
  },
  methods: {
    drawLine(){
        // 基于准备好的dom，初始化echarts实例
        let myChart = this.$echarts.init(document.getElementById('myChart'))
        // 绘制图表
        myChart.setOption({
            title: { text: '在Vue中使用echarts' },
            tooltip: {},
            xAxis: {
                data: ["衬衫","羊毛衫","雪纺衫","裤子","高跟鞋","袜子"]
            },
            yAxis: {},
            series: [{
                name: '销量',
                type: 'bar',
                data: [5, 20, 36, 10, 10, 20]
            }]
        });
    }
  }
}
```
**注意**： 这里echarts初始化应在钩子函数mounted()中，这个钩子函数是在el 被新创建的 vm.$el 替换，并挂载到实例上去之后调用
### 按需引入
全局引入会将所有的echarts图表打包，导致体积过大，所以我觉得最好还是按需引入。

* Hello.vue

```
// 引入基本模板
let echarts = require('echarts/lib/echarts')
// 引入柱状图组件
require('echarts/lib/chart/bar')
// 引入提示框和title组件
require('echarts/lib/component/tooltip')
require('echarts/lib/component/title')
export default {
  name: 'hello',
  data() {
    return {
      msg: 'Welcome to Your Vue.js App'
    }
  },
  mounted() {
    this.drawLine();
  },
  methods: {
    drawLine() {
      // 基于准备好的dom，初始化echarts实例
      let myChart = echarts.init(document.getElementById('myChart'))
      // 绘制图表
      myChart.setOption({
        title: { text: 'ECharts 入门示例' },
        tooltip: {},
        xAxis: {
          data: ["衬衫", "羊毛衫", "雪纺衫", "裤子", "高跟鞋", "袜子"]
        },
        yAxis: {},
        series: [{
          name: '销量',
          type: 'bar',
          data: [5, 20, 36, 10, 10, 20]
        }]
      });
    }
  }
}
```
之所以使用 require 而不是 import，是因为 require 可以直接从 node_modules 中查找，而 import 必须把路径写全。
### 页面展示
![Demo IMG](http://img.blog.csdn.net/20170418111226520?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbXJfd3VjaA==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

