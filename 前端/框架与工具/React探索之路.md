# React探索之路
## 关于setState？
### 1.调用setState后发生了什么?
当对象作为参数执行setState时，React内部会以一种对象合并的方式来批量更新组件的状态，类似于Object.assign(),把需要更新的state合并后放入状态队列，利用这个队列可以更加高效的批量更新state；当参数为函数时，React会将所有更新组成队列，并且按顺序来执行，这样避免了将state合并成一个对象的问题。之后会启动一个reconciliation调和过程，即创建一个新的 React Element tree（UI层面的对象表示）和之前的tree作比较，基于你传递给setState的对象找出发生的变化，最后更新DOM中需改动的部分。

### 2.setState为什么是异步的？
从一个例子来看setState的异步：

```
class App extends Component {
  constructor() {
    super();
    this.state = {
      counter: 0
    };
  }
  add(value){
    this.setState({
      counter: this.state.counter + value
    });
    console.log(this.state.counter);
    // 第一次点击console输出0
  }
  render() {
    return (
      <div>
        <p onClick={() => this.add(1)}>
          Click to change the value.
        </p>
      </div>
    );
  }
}
```

例如在上面的代码中，点击打印出来的counter值是0,setState之后并没有立即更新counter的值，那么如果确保拿到的counter是更新过的呢？有两种解决方法：

1.利用setState的第二个参数设置回调函数，setState更新后会触发这个callback函数；

```
add(value){
  this.setState({
    counter: this.state.counter+value
  }, () => {console.log(this.state.counter);});
}
```

2.利用setTimeout

```
setTimeout(() => {console.log(this.state.counter)}, 0)

```

官方的解释说可以把setState看作是一个请求，而不是更新的命令，为了获得更好的性能，React会把延迟更新操作，达到一次更新几个组件的目的；都知道React的setState是异步的

1. 保持内部的一致性，跟props一样；
2. 在许多情况下，setState的同步渲染效率不高，异步可以将几个更新合并，提高效率；
3. 并不仅仅是出于优化方面的考虑，可以利用异步特征去做其他的事，例如如果你的navigator足够快，你跳转到别的页面了，还是能继续执行异步操作；

### 3.setState的两种使用方式？
除了上面这种传入新的对象外，还可以使用方法作为参数来更新state
![](https://assets.wuxinhua.com/setState.jpg)

```
// 例子
  add(value){
    this.setState((prevState, props) => ({counter: prevState.counter+value}))
    console.log(this.state.counter);
  }
```

setState() 接受一個function(state, props)作為参数传入，两个参数对应的是之前的state和props,那为什么还要加入这一种方式呢？最主要的原因还是因为setState的异步更新，当我们传入对象的方式，并且多次调用setState方法的时候，实际上React做的是批量处理，React会合并这些Object，但是Object.assign在合并对象的时候，如果遇到keys相同，后面的values值会覆盖掉前面的，例如下面的示例代码，这是我理解的为什么调用三次setState目标值却只更新了一次的原因。

```
const a = {counter: 1},
	  b = {counter: 2},
	  c = { counter: 3};
const d = Object.assign({}, a, b, c);
console.log(d); // {counter: 3}
```

二者有什么区别主要的区别在于：

1. 如果是通过传入Object来计算next state,并不是安全的，this.props和this.state不是同步地被更新；
2. 如果在一个方法内多次调用setState()，并不会执行多次的setState，但是如果是传入的function,这些function会被React塞到队列中，并且按顺序依次执行，具体可以查看下面的代码例子；
3. 在function方式下，我们的更新操作就不一定需要写在当前Class里，并且如果我们需要额外的参数来计算或者操作下一步的state的时候，还可以使用闭包;

```
function multiplyAdd (value) {
  return function add( preState, props) {
    return {
      counter: preState.counter + value
    }
  }
}
```

## props和state的区别？
在React中，数据总是单向地自上往下流动，组件中的一些状态或者数据的管理有时让人很头疼，尤其是在设计一些组件的时候，props是properties的缩写，可以认为是组件的属性，他们从上级获取，并且是不能改变的，如果想要改变props值，只能在父级组件中修改，然后传递给子组件。

| 场景 | props | state |
| :----: | :----: | :----: |
| 是否可以从父组件中获取初始值 | 可以 | 可以 |
| 是否能被父组件改变 | 可以 | 不可以 |
| 是否设置默认值 | 可以 | 不可以 |
| 是否在组件里改变值 | 不可以 | 可以 |
| 能否给子组件设置初始值 | 可以 | 可以 |
| 能否在子组件里被改变值 | 可以 | 可以 |

### 总结：

1. props用于定义外部接口，使用state来存储控制当前页面逻辑的数据；
2. props的赋值是在父级组件，state赋值在当前组件内部；
3. props是不可变的，而state是可变的；
4. 使用props比state会有更好的性能；

## 组件的Render函数在何时被调用
如果单纯、侠义的回答这个问题，毫无疑问Render是在组件 `state` 发生改变时候被调用。无论是通过 `setState` 函数改变组件自身的`state`值，还是继承的 `props` 属性发生改变都会造成`render`函数被调用，即使改变的前后值都是一样的。

React组件中存在两类DOM，一类是众所周知的`Virtual DOM`，相信大家也耳熟能详了；另一类就是浏览器中的真实`DOM（Real DOM/Native DOM）`。`React`的`Render`函数被调用之后，React立即根据props或者state重新创建了一颗`Virtual DOM Tree`，虽然每一次调用时都重新创建，但因为在内存中创建DOM树其实是非常快且不影响性能的，所以这一步的开销并不大。而`Virtual DOM`的更新并不意味这`Real DOM`的更新，接下来的事情也是大家知道的，React采用算法将Virtual DOM和Real DOM进行对比，找出需要更新的最小步骤，此时`Real DOM`才可能发生修改。

## this.props.children是什么
它表示组件的所有子节点，值有三种可能：如果当前组件没有子节点，它就是 `undefined`;如果有一个子节点，数据类型是 `object` ；如果有多个子节点，数据类型就是 `array`。 React 提供一个工具方法 `React.Children` 来处理 `this.props.children` 。我们可以用 `React.Children.map` 来遍历子节点，而不用担心 `this.props.children` 的数据类型是 `undefined` 还是 `object`

## diff算法
传统 diff 算法的复杂度为 O(n^3)，显然这是无法满足性能要求的。React 通过制定大胆的策略，将 O(n^3) 复杂度的问题转换成 O(n) 复杂度的问题。 react的diff 策略：

* Web UI 中 DOM 节点跨层级的移动操作特别少，可以忽略不计。
* 拥有相同类的两个组件将会生成相似的树形结构，拥有不同类的两个组件将会生成不同的树形结构。
* 对于同一层级的一组子节点，它们可以通过唯一 id 进行区分。

基于以上三个前提策略，React 分别对 `tree diff、component diff 以及 element diff` 进行算法优化，事实也证明这三个前提策略是合理且准确的，它保证了整体界面构建的性能。

* tree diff 基于策略一，React 对树的算法进行了简洁明了的优化，即对树进行分层比较，两棵树只会对同一层次的节点进行比较。

既然 DOM 节点跨层级的移动操作少到可以忽略不计，针对这一现象，React 通过 updateDepth 对 Virtual DOM 树进行层级控制，只会对相同颜色方框内的 DOM 节点进行比较，即同一个父节点下的所有子节点。当发现节点已经不存在，则该节点及其子节点会被完全删除掉，不会用于进一步的比较。这样只需要对树进行一次遍历，便能完成整个 DOM 树的比较。

* component diff
	* 如果是同一类型的组件，按照原策略继续比较 virtual DOM tree。
	* 如果不是，则将该组件判断为 dirty component，从而替换整个组件下的所有子节点。
	* 对于同一类型的组件，有可能其 Virtual DOM 没有任何变化，如果能够确切的知道这点那可以节省大量的 diff 运算时间，因此 React 允许用户通过 shouldComponentUpdate() 来判断该组件是否需要进行 diff。
* element diff 允许开发者对同一层级的同组子节点，添加唯一 key 进行区分

## React 中 Element 与 Component 的区别是？
React Element 是描述屏幕上所见内容的数据结构，是对于 UI 的对象表述。典型的 React Element 就是利用 JSX 构建的声明式代码片然后被转化为createElement的调用组合。而 React Component 则是可以接收参数输入并且返回某个 React Element 的函数或者类。

## 在什么情况下你会优先选择使用 Class Component 而不是 Functional Component？
在组件需要包含内部状态或者使用到生命周期函数的时候使用 Class Component ，否则使用函数式组件

## React 中 refs 的作用是什么？
Refs 是 React 提供给我们的安全访问 DOM 元素或者某个组件实例的句柄。我们可以为元素添加ref属性然后在回调函数中接受该元素在 DOM 树中的句柄，该值会作为回调函数的第一个参数返回

## 无状态组件和状态组件？
### 有状态和无状态两种形式的组件：
#### Stateless Component（无状态组件）
只有Props,没有state，是的组件的数据流向更加简洁，组件也更方便测试。当你不需要使用组件的生命周期的时候，

#### Stateful Component（有状态组件）
Props和state都有使用，当你的需要再客户端保持一些数据的时候，二者会被用到；

### Class Components vs Functional Components

#### Class Components写法：

```
class Hello extends React.Component {
    constructor(props) {
        super(props);
    }
    render() {
      return(
            <div>
                Hello {props}
            </div>
        )
    }
}
```

#### Functional Components的写法：

```
const Hello = ( props ) => (<div>Hello{props}</div>)
```

## Virtual Dom的对比过程？
这个问题主要考察的是对React的Diff算法的了解，Diff算法究竟是如何工作的？

在React中最神奇的部分莫过于Virtual Dom以及diff算法，React利用这两个东西高效地解决了页面渲染的问题。
（暂略~）

## 关于React组件的生命周期？
手绘组件生命周期及钩子函数执行流程

![](http://assets.wuxinhua.com/react-lifecycle.jpeg)

React组件生命周期大致分为三个阶段：装载->更新->卸载，并且在每个阶段都提供了方法(也叫“hooks”钩子)，便于我们在这些函数中更新我们的UI和应用的状态。

### constuctor
当对象被创建的时候，construnctor会被调用，所以这里是最佳的地方用来初始化state,也是在组件里唯一的地方我们能够直接使用this.state来定义一个状态;

### componentWillMount
当props和state都设置好，React真正进入组件生命周期阶段，第一个函数是componentWillMount,这个方法和constructor一样都是只会被调用一次，会在第一次的render调用前执行，由于还没有执行render,所以我们拿不到dom,也拿不到refs。如果需要操作dom,这并不是一个合适的地方，我之前犯得的错误是在这个位置去做ajax请求，这一点会在下面这个问题中详细讲到。这个函数能起到什么作用？貌似并不大，props和state都定义好了，如果你需要根据props来设置state，或者在更新前修改state值，可以在这里来做。

### componentDidMount
componentDidMount与componentWillMount不同的地方在于componentWillMount浏览器和服务器端均可运行，而componentDidMount在服务器端无法运行

当组件更新在DOM上之后，componentDidMount会被执行，所以在这个函数适合做以下几个事情：

1. API接口数据的异步请求；
2. 例如一些需要使用到DOM的库(如D3.js)，可以在这里进行初始化;

### componentWillReceiveProps
根据this.props和nextProps比较props是否发生变化再调用setState这点都没问题，容易让人误解的地方在于它什么时候触发，它并不是props改变了会触发，即使props没有变，它仍然会执行(为什么？因为React也不知道你的props有没有发生变化，它需要在这个地方进行对比)，除非你的组件并没有传递下来的props，这个方法不会触发，如果我们需要在props发送变化时更新我们的state，那么这是个合适的地方。

### shouldComponentUpdate
shouldComponentUpdate是生命周期函数中比较重要的函数只有，在使用shouldComponentUpdate(nextProps,nextState)时, 值得注意的几点：

1. 在初始阶段和使用forceUpdate()时都不会执行；
2. 不用的时候默认返回true，一旦使用就必须给返回Boolean类型的值；
3. 当子组件的state发生变化时，即使父组件返回false，也不能阻止子组件re-render；
4. 出于性能的考虑，不建议在这个函数中使用JSON.stringify()来比较值是否改变；

### componentWillUpdate 和 componentDidUpdate
在使用React的过程中，我基本没有使用到这两个函数；如果shouldComponentUpdate的返回值是true，将会执行这两个函数，

### componentWillUnmount
在这个阶段，组件已经不再使用，需要从Dom中移除，在移除前会被执行，这个函数中可以用来做以下事情：

1. 例如登出时，清除跟用户相关的数据、auth tokend等
2. 清除setTimeout或者setInterval循环；

## 生命周期的哪个阶段异步请求数据？
为什么选择在componentDidMount函数中来执行ajax异步请求？
根据文档的描述，在componentWillMount改变state将不会引起rerenering,cunstructor也能起到同样的作用，由于这个这个函数有点让人摸不着头脑，所以React core组的成员在讨论是否可以在将来的版本移除掉这个函数issues#7671，但也有一个区别，就是在constructor中你不能使用setState；但是如果你使用flux框架(例如redux)来更新数据，你在这个地方请求数据，将不会出现问题。

如果你在这个函数绑定了事件处理，在componentWillUnMount里移除这些事件,在客户端端这一切能很好地运行，componentWillMount也会在服务端运行，但是componentWillUnMount将不会在服务端执行，所以这些事件永远不会被清除。
最主要的原因是：

1. 在componentWillUnMount中无法确保在执行render前已经获得了异步请求的数据，componentDidMount不存在这个问题；
2. 为了性能的需要，Fiber有了调度render执行顺序的能力，所以componentWillMount方法的执行变得不确定了；
3. 无法保证ajax请求在组件的更新阶段里成功返回数据，有可能当我们进行setState处理的时候，组件已经被销毁了；

## 什么是高阶组件(HOC)？
由于没有这方面的需求，在实际开发过程中没有封装过高阶组件，React的高阶组件HOC是Higher order components的缩写，可以理解为是React组件包裹另一个React组件。Hoc最好的学习例子是React-Redux源码中对connect的实现，Connect高阶组件，它是真正连接Redux和组件的东西，Provider在最顶层提供store，Connect通过context来接收store,并且把store中的state映射到射到组件props。简要地描述一下我理解的React-redux中connect的实现过程，源码较长，截取了其中的一部分： 大致的调用过程是：createConnect => connectAdvanced => wrapWithConnect => Connect组件，connect是一个高阶函数，也是一个柯里化函数，需要传入mapStateToProps、mapStateToProps等参数及组件，返回一个产生Component的函数（wrapWithConnect），wrapWithConnect生产出经过处理的Connect组件。

```
export default function connectAdvanced(
  selectorFactory,
  {
    getDisplayName = name => `ConnectAdvanced(${name})`,
    ....略
    renderCountProp = undefined,
    ...connectOptions
  } = {}
) {
  const subscriptionKey = storeKey + 'Subscription'
  const version = hotReloadingVersion++

  const contextTypes = {
    [storeKey]: storeShape,
    [subscriptionKey]: subscriptionShape,
  }
  const childContextTypes = {
    [subscriptionKey]: subscriptionShape,
  }

  return function wrapWithConnect(WrappedComponent) {
    const wrappedComponentName = WrappedComponent.displayName
      || WrappedComponent.name
      || 'Component'

    const displayName = getDisplayName(wrappedComponentName)

    const selectorFactoryOptions = {
      ...connectOptions,
      getDisplayName,
      methodName,
      WrappedComponent
    }
    ...略
    // 创建Connect组件
    class Connect extends Component {
        constructor(props, context) {
          super(props, context)
          this.state = {}
          this.renderCount = 0
          this.store = props[storeKey] || context[storeKey]
          this.setWrappedInstance = this.setWrappedInstance.bind(this)

          this.initSelector()
          this.initSubscription()
        }

        getChildContext() {
          const subscription = this.propsMode ? null : this.subscription
          return { [subscriptionKey]: subscription || this.context[subscriptionKey] }
        }
    }
    // 返回拓展过props的Connect
    return hoistStatics(Connect, WrappedComponent)
```

HOC提供了一些额外的能力来操作组件：例如操作Props，通过refs访问到组件实例，提取 state等，以下是高阶组件的一些使用场景：

1. 重用代码，当我们发现需要做很多重复的事情，写重复代码的时候，可以把公用的逻辑抽离到高阶组件中来；
2. 增加现有组件的行为，不想修改现有组件内部的逻辑，通过产生新的组件，并且实现自己需要的功能，对原组件也没有侵害；

## React如何处理事件绑定？
在React中处理事件与Dom中的处理很相似，但也有一些区别：

在HTML中：

```
<button onclick="activateLasers()">
  Activate Lasers
</button>
```

在JSX中：

```
<button onClick={activateLasers}>
  Activate Lasers
</button>
```

不同在于：

1. 在React中添加事件需要使用“camelCase”格式；
2. 无法使用return false的方式来阻止事件的一些默认行为，必须得使用preventDefault。
3. 在JSX中我们传递方法作为事件的参数，而不是一个字符串；

我们知道e.preventDefault是w3c定义的方法，在IE中得使用e.returnValue = false来阻止默认行为，那React是如何做到兼容的呢？

React使用了一个叫SyntheticEventd的对象，所有的事件继承至SyntheticEvent，并且它是跨浏览器的，它和浏览器的原生事件接口一样，包括提供stopPropagation() 和 preventDefault()方法来阻止冒泡和阻止默认行为。
SyntheticEvent的特点：

1. 跨浏览器
2. 为了性能问题，SyntheticEvent是重复利用的，无法再异步的情况下调用事件

##key如何选择？
关于key值的问题：

1. key值的作用？
2. 你会怎样设置key值？

刚刚接触写React代码的时候，如果没有设置key值或key值重复的情况，都会出现关于key值的warning警告，那key值起到什么作用？先来看看官方文档是怎么说的：

```
Keys help React identify which items have changed, are added, or are removed. Keys should be given to the elements inside the array to give the elements a stable identity:
```

翻译过来就是便于React用key值来标识哪些元素是改变的，新增的，或者移除的，如果。通常我的用法是使用每项的ID来作为key值，我的写法类似下面这种：

```
{todos.map((todo, index) =>
  <Todo
    {...todo}
    key={item.id || index}
  />
)}
```

但有时并不是所有数据项都具备ID这个字段，所所以我一般还会加上下标，官方提示说不建议使用index下标来做作为key值，它可能会对性能产生消极的作用并且可能对组件的状态造成影响。

1. 使用数据项中的ID；
2. 生成唯一标识字符串，例如使用shortid；
3. 使用index数组下标；

## Controlled Component 与 Uncontrolled Component 之间的区别是什么？
React 的核心组成之一就是能够维持内部状态的自治组件，不过当我们引入原生的HTML表单元素时（input,select,textarea 等），我们是否应该将所有的数据托管到 React 组件中还是将其仍然保留在 DOM 元素中呢？这个问题的答案就是受控组件与非受控组件的定义分割。受控组件（Controlled Component）代指那些交由 React 控制并且所有的表单数据统一存放的组件。譬如下面这段代码中username变量值并没有存放到DOM元素中，而是存放在组件状态数据中。任何时候我们需要改变username变量值时，我们应当调用setState函数进行修改。 而非受控组件（Uncontrolled Component）则是由DOM存放表单数据，并非存放在 React 组件中。我们可以使用 refs 来操控DOM元素。



