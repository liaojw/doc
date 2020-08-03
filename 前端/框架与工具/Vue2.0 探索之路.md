# Vue2.0 探索之路
## 生命周期和钩子函数的一些理解

### 前言
在使用vue一个多礼拜后，感觉现在还停留在初级阶段，虽然知道怎么和后端做数据交互，但是对于**mounted**这个挂载还不是很清楚的。放大之，对**vue**的生命周期不甚了解。只知道简单的使用，而不知道为什么，这对后面的踩坑是相当不利的。

因为我们有时候会在几个钩子函数里做一些事情，什么时候做，在哪个函数里做，我们不清楚。

于是我开始先去搜索，发现**vue2.0**的生命周期没啥文章。大多是1.0的版本介绍。最后还是找到一篇不错的（会放在最后）

### vue生命周期简介
![](https://segmentfault.com/img/bVEo3w?w=1200&h=2800)
![](https://segmentfault.com/img/bVEs9x?w=847&h=572)

咱们从上图可以很明显的看出现在vue2.0都包括了哪些生命周期的函数了。

### 生命周期探究
对于执行顺序和什么时候执行，看上面两个图基本有个了解了。下面我们将结合代码去看看钩子函数的执行

> ps:下面代码可以直接复制出去执行

```
<!DOCTYPE html>
<html>
<head>
    <title></title>
    <script type="text/javascript" src="https://cdn.jsdelivr.net/vue/2.1.3/vue.js"></script>
</head>
<body>

<div id="app">
     <p>{{ message }}</p>
</div>

<script type="text/javascript">
    
  var app = new Vue({
      el: '#app',
      data: {
          message : "xuxiao is boy" 
      },
       beforeCreate: function () {
                console.group('beforeCreate 创建前状态===============》');
               console.log("%c%s", "color:red" , "el     : " + this.$el); //undefined
               console.log("%c%s", "color:red","data   : " + this.$data); //undefined 
               console.log("%c%s", "color:red","message: " + this.message)  
        },
        created: function () {
            console.group('created 创建完毕状态===============》');
            console.log("%c%s", "color:red","el     : " + this.$el); //undefined
               console.log("%c%s", "color:red","data   : " + this.$data); //已被初始化 
               console.log("%c%s", "color:red","message: " + this.message); //已被初始化
        },
        beforeMount: function () {
            console.group('beforeMount 挂载前状态===============》');
            console.log("%c%s", "color:red","el     : " + (this.$el)); //已被初始化
            console.log(this.$el);
               console.log("%c%s", "color:red","data   : " + this.$data); //已被初始化  
               console.log("%c%s", "color:red","message: " + this.message); //已被初始化  
        },
        mounted: function () {
            console.group('mounted 挂载结束状态===============》');
            console.log("%c%s", "color:red","el     : " + this.$el); //已被初始化
            console.log(this.$el);    
               console.log("%c%s", "color:red","data   : " + this.$data); //已被初始化
               console.log("%c%s", "color:red","message: " + this.message); //已被初始化 
        },
        beforeUpdate: function () {
            console.group('beforeUpdate 更新前状态===============》');
            console.log("%c%s", "color:red","el     : " + this.$el);
            console.log(this.$el);   
               console.log("%c%s", "color:red","data   : " + this.$data); 
               console.log("%c%s", "color:red","message: " + this.message); 
        },
        updated: function () {
            console.group('updated 更新完成状态===============》');
            console.log("%c%s", "color:red","el     : " + this.$el);
            console.log(this.$el); 
               console.log("%c%s", "color:red","data   : " + this.$data); 
               console.log("%c%s", "color:red","message: " + this.message); 
        },
        beforeDestroy: function () {
            console.group('beforeDestroy 销毁前状态===============》');
            console.log("%c%s", "color:red","el     : " + this.$el);
            console.log(this.$el);    
               console.log("%c%s", "color:red","data   : " + this.$data); 
               console.log("%c%s", "color:red","message: " + this.message); 
        },
        destroyed: function () {
            console.group('destroyed 销毁完成状态===============》');
            console.log("%c%s", "color:red","el     : " + this.$el);
            console.log(this.$el);  
               console.log("%c%s", "color:red","data   : " + this.$data); 
               console.log("%c%s", "color:red","message: " + this.message)
        }
    })
</script>
</body>
</html>
```

#### create 和 mounted 相关
咱们在**chrome**浏览器里打开，**F12**看**console**就能发现

> **beforecreated**：el 和 data 并未初始化
>  
> **created**:完成了 data 数据的初始化，el没有
> 
> **beforeMount**：完成了 el 和 data 初始化 
> 
> **mounted** ：完成挂载


另外在标红处，我们能发现el还是 {{message}}，这里就是应用的 **Virtual DOM**（虚拟Dom）技术，先把坑占住了。到后面**mounted**挂载的时候再把值渲染进去。

![](https://segmentfault.com/img/bVHMfj?w=588&h=475)

#### update 相关
这里我们在 chrome console里执行以下命令

```
app.message= 'yes !! I do';
```

下面就能看到data里的值被修改后，将会触发update的操作。

![](https://segmentfault.com/img/bVHMfY?w=584&h=609)

#### destroy 相关
有关于销毁，暂时还不是很清楚。我们在console里执行下命令对 vue实例进行销毁。销毁完成后，我们再重新改变message的值，vue不再对此动作进行响应了。但是原先生成的dom元素还存在，可以这么理解，执行了destroy操作，后续就不再受vue控制了。

```
app.$destroy();
```

![](https://segmentfault.com/img/bVHMgS?w=659&h=625)

### 生命周期总结

> **beforecreate** : 举个栗子：可以在这加个loading事件 
> 
> **created** ：在这结束loading，还做一些初始化，实现函数自执行 
> 
> **mounted** ： 在这发起后端请求，拿回数据，配合路由钩子做一些事情
> 
> **beforeDestory**： 你确认删除XX吗？ destoryed ：当前组件已被删除，清空相关内容

## vuex入门教程和思考
### Vuex是什么

> Vuex 是一个专为 Vue.js 应用程序开发的状态管理模式。它采用集中式存储管理应用的所有组件的状态，并以相应的规则保证状态以一种可预测的方式发生变化。

就我的直观理解 **vuex**类似于维护了一个全局的 **Map**对象。你可以往里存放 **key-value**。然后所有的state数据操作都方法化，保证操作的可追踪和数据的干净。

### Vuex应用场景
其实对于vuex的应用场景一开始我有点误区，因为我把它当做了一个从始至终类似于 localstorage的存在。后来发现一刷新页面，vuex中的state存放的数据会丢失。因为它只是在当前页面初始化生成的一个实例，你一刷新页面所有数据重新生成，数据就没了。

**所以，vuex只能用于单个页面中不同组件（例如兄弟组件）的数据流通。**

想必大家在想项目中啥情况会用到vuex吧。官方是说到了时间你自然知道啥时候用了，因为小项目加入vuex，代码成本比较高，你得写各种action，mutation，dispatch交互。你自个儿都会恶心掉。

只有项目大了，组件多了，你需要一个状态机来解决同一个页面内不同组件之间的数据交流。就比如说我下面例子中的 todolist中，todo输入框是一个组件，todolist展示框也是一个组件，他们同属于一个页面，你用传统的 event bus是很不方便的解决这个问题的。

还有就是子组件想改变父组件的情况下，就比如我们最近做的一个项目里的动态表单，其中一个是做了弹出框选择职业类，选完还得回填到父组件，以前的方式，你可能需要写很多的event bus去拦截事件，现在你可以用vuex去很清晰的解决这个问题，修改vuex里的值，父组件自动更新。

![](https://segmentfault.com/img/bVLr5p?w=250&h=212)

### Vuex基础概念

> Vuex 官方文档：[https://vuex.vuejs.org/zh-cn/](https://vuex.vuejs.org/zh-cn/)

#### State
vuex的单一状态树，使用一个对象就包含了应用层的所有状态。我的理解是，state是vuex自己维护的一份状态数据。数据的格式需要你根据业务去设计哟~~下面是我简单设计的todolist的state状态树。

![](https://segmentfault.com/img/bVLkUc?w=230&h=249)

#### Getters
getters属性主要是对于state中数据的一种过滤，属于一种加强属性。比如你在做一个todolist，对于已完成的，你可以写一个doneTodoList的属性，在外面直接调用。其实他就是对于action和mutations的一个简化。不然你写一个doneTodoList功能，你还得写对应的action和mutation，费劲啊。

所以，总结一下，**一些简单或通用的操作可以抽取到getters上来，方便在应用中引用。**
![](https://segmentfault.com/img/bVLkUD?w=528&h=266)

#### Actions
action,动作。对于store中数据的修改操作动作在action中提交。其实action和mutation类似，但是action提交是mutation，并不直接修改数据，而是触发mutation修改数据。

![](https://segmentfault.com/img/bVLkUV?w=356&h=297)

#### Mutations
更改 Vuex 的 store 中的状态的唯一方法是提交 mutation。mutation中写有修改数据的逻辑。另外**mutation里只能执行同步操作。**

![](https://segmentfault.com/img/bVLkUL?w=315&h=219)

#### Module
**module**,模块化。
因为随着后面的业务逻辑的增多，把**vuex**分模块的开发会使得代码更加简洁清晰明了，比如登录一个模块，产品一个模块，这样后面改动起来也简单嘛。
下图的 **todo**目录就是一个**module**，下面的 **actions.js**,**mutations.js**就和外面的一样。

![](https://segmentfault.com/img/bVLkVE?w=225&h=238)

### 代码实践
####  引入vuex依赖

````
npm install vuex
````

#### 目录结构
![](https://segmentfault.com/img/bVILKW?w=219&h=253)

> store.js 将vuex维护的所有数据导出供外部使用。
> 
> mutation_type.js 维护操作类型的常量字段。

#### main.js加载
![](https://segmentfault.com/img/bVILMd?w=474&h=380)

#### 页面使用
1.读取store里的值：

> this.$store.state.字段名如果有moudle的话，假设叫 login,那么取值又要变了，加上module名this.$store.state.login.mobile

2.发起操作请求:
> this.$store.dispatch('action中的方法名' , '参数');参数你可以随便传json

3.getters的用法
> this.$store.getters.filterDoned。filterDoned 是在todo 里写的一个getters方法

## vue-router入门教程和总结
### 安装和引入

首先我们先安装依赖

```
npm install vue-router
```

紧接着项目引入，看下面的图噢，非常清晰，代码就自己敲吧。

![](https://segmentfault.com/img/bVOD2k?w=575&h=349)

#### router.js 的配置
首先引入 **vue-router**组件，**Vue.use**是用来加载全局组件的。那下面我们就开始看看这个**VueRouter**的写法和配置吧。

##### mode:

> 默认为hash，但是用hash模式的话，页面地址会变成被加个#号比较难看
> 
> http://localhost:8080/#/linkParams/xuxiao
> 
> 所以一般我们会采用 history模式，它会使得我们的地址像平常一样。http://localhost:8080/linkParams/xuxiao

##### base

> 应用的基路径。例如，如果整个单页应用服务在 /app/ 下，然后 base 就应该设为 "/app/"
> 
> 一般写成 __dirname，在webpack中有配置。

##### routes

> routes就是我们的大核心了，里面包含我们所有的页面配置。
> 
> path 很简单，就是我们的访问这个页面的路径
> 
> name 给这个页面路径定义一个名字，当在页面进行跳转的时候也可以用名字跳转，要唯一哟
> 
> component 组件，就是咱们在最上面引入的 import ...了，当然这个组件的写法还有一种懒加载

懒加载的方式，我们就不需要再用**import**去引入组件了，直接如下即可。懒加载的好处是当你访问到这个页面的时候才会去加载相关资源，这样的话能提高页面的访问速度。

**component: resolve => require(['./page/linkParamsQuestion.vue'], resolve)**

![](https://segmentfault.com/img/bVOEsg?w=726&h=462)

### router的使用
#### router传参数

在我们的平时开发跳转里，很明显，传参数是必要的。那么在vue-router中如何跳转，如何传参数呢。请看下面。

##### 1.路由匹配参数

首先在路由配置文件**router.js**中做好配置。标红出就是对 **/linkParams/**的路径做拦截，这种类型的链接后面的内容会被**vue-router**映射成**name**参数。

![](https://segmentfault.com/img/bVOD2O?w=271&h=145)

代码中获取**name**的方式如下：

```
let name = this.$route.params.name; // 链接里的name被封装进了 this.$route.params
```
##### 2.Get请求传参
这个明明实在不好形容啊。不过真的是和Get请求一样。你完全可以在链接后加上?进行传参。

样例：**http://localhost:8080/linkParamsQuestion?age=18**
项目里获取：

```
let age = this.$route.query.age; //问号后面参数会被封装进 this.$route.query;
```
### 编程式导航
这里就开始利用**vue-router**讲发起跳转了。其实也非常简单，主要利用 `<router-link>`来创建可跳转链接，还可以在方法里利用 `this.$router.push('xxx')`来进行跳转。

样例： `<router-link to="/linkParams/xuxiao">`点我不会怀孕`</router-link>`

上面的这个**router-link**就相当于加了个可跳转属性。

至于**this.$router.push**这里直接用官网的荔枝了

```
// 字符串,这里的字符串是路径path匹配噢，不是router配置里的name
this.$router.push('home')

// 对象
this.$router.push({ path: 'home' })

// 命名的路由 这里会变成 /user/123
this.$router.push({ name: 'user', params: { userId: 123 }})

// 带查询参数，变成 /register?plan=private
this.$router.push({ path: 'register', query: { plan: 'private' }})
```

###  导航钩子
导航钩子函数，主要是在导航跳转的时候做一些操作，比如可以做**登录的拦截**，而钩子函数根据其生效的范围可以分为 **全局钩子函数**、**路由独享钩子函数**和**组件内钩子函数**。

#### 全局钩子函数
可以直接在路由配置文件**router.js**里编写代码逻辑。可以做一些全局性的路由拦截。

```
router.beforeEach((to, from, next)=>{
  //do something
  next();
});
router.afterEach((to, from, next) => {
    console.log(to.path);
});
```
每个钩子方法接收三个参数：

* **to: Route:** 即将要进入的目标 路由对象
* **from: Route:** 当前导航正要离开的路由
* **next: Function:** 一定要调用该方法来 resolve 这个钩子。执行效果依赖 next 方法的调用参数。
* **next(): **进行管道中的下一个钩子。如果全部钩子执行完了，则导航的状态就是 confirmed （确认的）。
	* **next(false):** 中断当前的导航。如果浏览器的 URL 改变了（可能是用户手动或者浏览器后退按钮），那么 URL 地址会重置到 from 路由对应的地址。
	* **next('/')** 或者 **next({ path: '/' }):** 跳转到一个不同的地址。当前的导航被中断，然后进行一个新的导航。

**确保要调用 next 方法，否则钩子就不会被 resolved。**

#### 路由独享钩子函数
可以做一些单个路由的跳转拦截。在配置文件编写代码即可

```
const router = new VueRouter({
  routes: [
    {
      path: '/foo',
      component: Foo,
      beforeEnter: (to, from, next) => {
        // ...
      }
    }
  ]
})
```

#### 组件内钩子函数
更细粒度的路由拦截，只针对一个进入某一个组件的拦截。

```
const Foo = {
  template: `...`,
  beforeRouteEnter (to, from, next) {
    // 在渲染该组件的对应路由被 confirm 前调用
    // 不！能！获取组件实例 `this`
    // 因为当钩子执行前，组件实例还没被创建
  },
  beforeRouteUpdate (to, from, next) {
    // 在当前路由改变，但是该组件被复用时调用
    // 举例来说，对于一个带有动态参数的路径 /foo/:id，在 /foo/1 和 /foo/2 之间跳转的时候，
    // 由于会渲染同样的 Foo 组件，因此组件实例会被复用。而这个钩子就会在这个情况下被调用。
    // 可以访问组件实例 `this`
  },
  beforeRouteLeave (to, from, next) {
    // 导航离开该组件的对应路由时调用
    // 可以访问组件实例 `this`
  }
}
```

#### 钩子函数使用场景
其实路由钩子函数在项目开发中用的并不是非常多，一般用于登录态的校验，没有登录跳转到登录页；权限的校验等等。当然随着项目的开发进展，也会有更多的功能可能用钩子函数实现会更好，我们知道有钩子函数这个好东西就行了，下次遇到问题脑海就能浮现，噢，这个功能用钩子实现会比较棒。我们的目的就达到了。当然，有兴趣的可以再去研究下源码的实现。开启下脑洞。

### 其他知识点
#### 滚动行为

在利用vue-router去做跳转的时候，到了新页面如果对页面的滚动条位置有要求的话，可以利用下面这个方法。

```
const router = new VueRouter({
  routes: [...],
  scrollBehavior (to, from, savedPosition) {
    // return 期望滚动到哪个的位置
  }
})
```

**scrollBehavior** 方法接收 **to** 和 **from** 路由对象。第三个参数 **savedPosition** 当且仅当 **popstate** 导航 (**mode**为 **history** 通过浏览器的 前进/后退 按钮触发) 时才可用。这里就不细致的讲了，文档都有也非常简单，记住有这个东西就行。

```
//所有路由新页面滚动到顶部：
scrollBehavior (to, from, savedPosition) {
  return { x: 0, y: 0 }
}

//如果有锚点
scrollBehavior (to, from, savedPosition) {
  if (to.hash) {
    return {
      selector: to.hash
    }
  }
}
```

#### 路由元信息
这个概念非常简单，就是在路由配置里有个属性叫 **meta**，它的数据结构是一个对象。你可以放一些**key-value**进去，方便在钩子函数执行的时候用。

举个例子，你要配置哪几个页面需要登录的时候，你可以在**meta**中加入一个 **requiresAuth**标志位。

```
const router = new VueRouter({
  routes: [
    {
      path: '/foo',
      component: Foo,
      meta: { requiresAuth: true }
    }
  ]
})
```

然后在 全局钩子函数 **beforeEach**中去校验目标页面是否需要登录。

```
router.beforeEach((to, from, next) => {
  if (to.matched.some(record => record.meta.requiresAuth)) {
    //校验这个目标页面是否需要登录
    if (!auth.loggedIn()) {  
      next({
        path: '/login',
        query: { redirect: to.fullPath }
      })
    } else {
      next()
    }
  } else {
    next() // 确保一定要调用 next()
  }
})
```

> 这个**auth.loggedIn**方法是外部引入的，你可以先写好一个校验是否登录的方法，再**import**进 **router.js**中去判断。









