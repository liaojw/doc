# React v16 生命周期详解

由于这次生命周期 API 有点复杂，我将这些方法分为四个部分：安装（Mounting），更新（Updating），卸载（Unmounting）和异常（Error）

## Mounting - 组件的挂载

> ├── [**constructor**](https://reactjs.org/docs/react-component.html#constructor)
>
> ├── [**static getDerivedStateFromProps**](https://reactjs.org/docs/react-component.html#static-getderivedstatefromprops)
>
> ├── [**render**](https://reactjs.org/docs/react-component.html#render)
>
> ├── [**componentDidMount**](https://reactjs.org/docs/react-component.html#componentdidmount)

### constructor

> 如果您的组件是 Class Component，则调用的第一就是组件构造函数。 这不适用于 Functional Component。

相关构造函数可能是如下形式

```javascript
class MyComponent extends Component {
  constructor(props) {
    super(props);
    this.state = {
      counter: 0,
    };
  }
}
```

构造函数的参数为 props，**你可以利用 `super` 来传入**。

在构造函数中，你可以初始化 state、设定默认值。甚至你可以依据 props 来创建 state。

```js
class MyComponent extends Component {
  constructor(props) {
    super(props);
    this.state = {
      counter: props.initialCounterValue,
    };
  }
}
```

**注意**，现在构造函数是可选的，如果您的 Babel 设置支持 class fields，就可以像这样初始化状态：

**这种方法是被大家所提倡的**。 你仍然可以根据 props 创建 state：

```
class MyComponent extends Component {
  state = {
    counter: this.props.initialCounterValue,
  };
}
```

但是，如果需要使用 ref ，就仍需要构造函数。

```
class Grid extends Component {
  constructor(props) {
    super(props);
    this.state = {
      blocks: [],
    };
    // 在 constructor 中创建 ref
    this.grid = React.createRef();
  }
}
```

我们需要构造函数来调用 createRef，以创建对 **HTMLElement** 元素的引用。还可以使用构造函数进行函数绑定，这也是可选的

```
class Grid extends Component {
  constructor(props) {
    super(props);
    this.state = {
      blocks: [],
    };
    // 1
    this.handleChange.bind(this)
  }
  // 2 等同于 1
  handleChange = () => {}
}
```

**constructor总结：** 构造函数的最常法：设置 state，创建 ref 和方法绑定。

### getDerivedStateFromProps

> 挂载时，getDerivedStateFromProps 是渲染前调用的最后一个方法

一般使用 getDerivedStateFromProps 可以根据初始 props 使用它来设置状态。

```
static getDerivedStateFromProps(props, state) {
  return { blocks: createBlocks(props.numberOfBlocks) };
}
// log {blocks: Array(20)}
console.log(this.state);
```

上述代码中依据 props.numberOfBlocks 来初始化期望的 state（函数return为状态）。

**注意：** 我们可以将此代码放在 constructor 中，与之相 getDerivedStateFromProps的优点是它更**直观** - 它仅用于设置状态，而构造函数有多种用途。

**总结：** getDerivedStateFromProps 的最常见用例（在mount期间）：根据初始props返回状态对象。

### render

完成所有渲染的工作。它返回实际组件的 JSX，使用React时，将花费大部分时间在这里。

渲染的最常见用例：返回 JSX 组件。

### componentDidMount

> 在第一次渲染组件之后，触发此方法。

如果需要加载数据，请在此处执行。 不要尝试在 constructor 中加载数据或渲染，原因，[react-interview-questions](https://tylermcginnis.com/react-interview-questions/).

> 由于AJAX是异步的，所以无法保证在组件挂载之前 AJAX 请求完成解析。 如果确实如此，那就意味着你要在未挂载的组件上尝试 setState，这不仅不起作用，而且 React 报错。 在componentDidMount中执行 AJAX 将保证有一个要更新的组件。

componentDidMount 触发时，组件已完成第一 render，所以可以进行一些操作：

- 在刚刚渲染的 `<canvas>` 元素上进行绘制
- 访问 DOM 节点
- 添加事件侦听器

基本上，在这里你可以做所有依赖 DOM 的设置，并开始获得你需要的所有数据，例如

```
componentDidMount() {
    // 利用 ref 访问 dom 元素
    this.bricks = initializeGrid(this.grid.current);
    this.interval = setInterval(() => {
      // ajax 获取数据
      this.addBlocks();
    }, 2000);
  }
}
```

**总结：** 调用 AJAX 以加载组件的数据。

## Updating - 组件的更新

> ├── [**static getDerivedStateFromProps**](https://reactjs.org/docs/react-component.html#static-getderivedstatefromprops)
>
> ├── [**shouldComponentUpdate**](https://reactjs.org/docs/react-component.html#shouldcomponentupdate)
>
> ├── [**render**](https://reactjs.org/docs/react-component.html#render)
>
> ├── [**getSnapshotBeforeUpdate**](https://reactjs.org/docs/react-component.html#getsnapshotbeforeupdate)
>
> ├── [**componentDidUpdate**](https://reactjs.org/docs/react-component.html#shouldcomponentupdate)

### getDerivedStateFromProps

> 是的，再来一次。 现在，它更有用了。

如果您需要根据 props 来更新 state，可以通过 return 新的状态对象来完成该任务。

**注，不建议依据 props 来处理 state**，也就是说，只有逼不得已才使用该方法。 以下是一些例子：

- 当 video 、audio 的 source 改变时，需要重置元素；
- Server 资源更新后需要恢复 UI 元素；
- 当内容改变时关闭相关元素。

即使有上述情况，通常也有更好的方法。 但是 getDerivedStateFromProps 可以情况变得更坏。

**总结：** getDerivedStateFromProps 一般用于 props 不足以支撑业务时，利用它来更新 state。

### **shouldComponentUpdate**

> 典型的 React 哲学，当一个组件收到新的 State 或 Props时，它应该更新。

但我们的组件有点困惑，它不确定是否要进行更新。

shouldComponentUpdate 方法的第一个参数为 nextProps，第二个参数为 nextState。shouldComponentUpdate 返回一个布尔值，用于控制组件是否更新。

shouldComponentUpdate 赋予我们一项能力，只有在你关心的 props 改变时组件会才更新。

**总结：** 可以准确地控制组件重新渲染的时间，常用于优化 React，[具体](https://medium.freecodecamp.org/react-binding-patterns-5-approaches-for-handling-this-92c651b5af56)。

### render - 同上

### getSnapshotBeforeUpdate

> 新添加的方法，触发时刻在 render 之后，最新的渲染输出提交给 DOM 之前。

调用渲染和最后显示更改之间可能会有延迟， 如果你需要获取 DOM 改变之前的一些信息时，可以利用这个钩子函数。

从渲染到提交这个过程是异步的，所以如果在 componentWillUpdate 访问 DOM 信息，在 componentDidUpdate 使用时，该信息可能发生了修改，这一部分以官网的例子来说明

```
class ScrollingList extends React.Component {
  listRef = React.createRef();

  getSnapshotBeforeUpdate(prevProps, prevState) {
    // 如果在列表中添加新项目
    // 获取列表的当前高度，以便我们稍后调整滚动
    if (prevProps.list.length < this.props.list.length) {
      return this.listRef.current.scrollHeight;
    }
    return null;
  }

  componentDidUpdate(prevProps, prevState, snapshot) {
    // 如果我们 snapshot 的值不为空，说明添加了新项目
    // 调整滚动，以便这些新项目不会将旧项目推出可视区域
    if (snapshot !== null) {
      this.listRef.current.scrollTop +=
        this.listRef.current.scrollHeight - snapshot;
    }
  }

  render() {
    return (
      <div ref={this.listRef}>{/* ...contents... */}</div>
    );
  }
}
```

**总结：** 查看当前 DOM 的某些属性，并将该值传递给componentDidUpdat。

### componentDidUpdate

> 所有的改变都已经提交给 DOM。

componentDidUpdate 包含三个参数，之前的 props、state，以及 getSnapshotBeforeUpdate 的返回值，具体如上述例子。

**总结：** 对已经改变的 Dom 作出相关响应。

## Unmounting

### componentWillUnmount

> 组件快要结束了。

在组件注销之前，它会询问您是否有任何最后一刻的请求。

您可以在此处取消任何传出网络请求，或删除与该组件关联的所有事件侦听器。

基本上，清理任何事情都只涉及有问题的组件 - 当它消失时，它应该完全消失。

**总结：** 清除事件监听、定时器等，防止内存泄漏。

## Errors

### getDerivedStateFromError

> 发生了一些异常。

它能够捕捉在他们的子组件树中任意地方的 JavaScript 错误，记录这些错误。当我们要展示一个 error 页面时，可以利用它来完成。

```
static getDerivedStateFromError(error) {
  return { hasError: true };
}
```

**注意：** 您必须返回更新的状态对象。 不要将此方法用于任何副作用。 而是使用下面的 componentDidCatch。

**总结：** 依据错误信息来修改组件的 state，同时展示出 error 页面。

### componentDidCatch

> 与上面非常相似，因为它在子组件中发生错误时被触发。

与 getDerivedStateFromError 区别在于不是为了响应错误而更新状态，可以执行任何副作用，例如记录错误。

```
componentDidCatch(error, info) {
  sendErrorLog(error, info);
}
```

**注意：** componentDidCatch 仅会捕获渲染/生命周期方法中的错误。 如果在单击处理程序中引发错误，则不会捕获它。

通常只在特殊的地方使用错误边界组件的 componentDidCatch。 这些组件包装子树的唯一目的是捕获和记录错误。

```
class ErrorBoundary extends Component {
  state = { errorMessage: null };
  static getDerivedStateFromError(error) {
    return { errorMessage: error.message };
  }
  componentDidCatch(error, info) {
    console.log(error, info);
  }
  render() {
    if (this.state.errorMessage) {
      return <h1>Oops! {this.state.errorMessage}</h1>;
    }
    return this.props.children;
  }
}
```

**总结：** 捕获、打印出错误信息。

