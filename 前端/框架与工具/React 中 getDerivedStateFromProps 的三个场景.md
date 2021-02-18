# React 中 getDerivedStateFromProps 的三个场景

React 16.3 开始，React 废弃了一些 API( `componentWillMount`, `componentWillReceiveProps`, and `componentWillUpdate`)，同时推出了一些新的 API 代替，包括 `getDerivedStateFromProps`。根据应用场景的不同， `getDerivedStateFromProps`的使用方式也不同。

## 一、半受控组件

虽然 React 官方不推荐半受控组件，当然从 API 设计和维护的角度考虑也是不推荐的。但是实际需求往往会出现用户不关心某个业务逻辑的内部实现，但是又希望在有需要的时候能完全控制内部的一些状态，这时候半受控组件是一个比较好的选择。

设计半受控组件的原则就是尽可能把控制权交给用户，即用户传了某个参数，就是用用户的参数；如果用户没有传参数，就是用组件内部的 `state`。在过去，这可能有些麻烦：

```
class SomeSearchableComponent extends Component {
 state = {
  search: props.search || '',
 };

 getSearch() {
  if (typeof this.props.search === 'string') {
   return this.props.search;
  }
  return this.state.search;
 }

 onChange = e => {
  const { onChange } = this.props;
  if (onChange) {
   onChange(e.target.value);
  } else {
   this.setState({
    search: e.target.value,
   });
  }
 };

 render() {
  return <input value={this.getSearch()} onChange={this.onChange} />;
 }
}
```

这里封装了一个 `getSearch`，但是它不能适用所有场景，我们在获取任何操作时都可能要去判断 `props`上的值。而使用 `getDerivedStateFromProps`就会直观一些：

```
class SomeSearchableComponent extends Component {
 state = {
  search: props.search || '',
 };

 onChange = e => {
  const { onChange } = this.props;
  if (onChange) {
   onChange(e.target.value);
  } else {
   this.setState({
    search: e.target.value,
   });
  }
 };

 static getDerivedStateFromProps(nextProps) {
  if (typeof nextProps.search === 'string') {
   return {
    search: nextProps.search,
   };
  }
  return null;
 }

 render() {
  const { search } = this.state;
  return <input value={search} onChange={this.onChange} />;
 }
}
```

鉴于 `getDerivedStateFromProps`的设计，我们可以安全的把 `props`的值都同步到 `state`上，这样在使用的时候只需要从 `state`上取值就好了。在这里，我们尽可能把控制权交给用户，只要用户传了 `props`就以 `props`的值为准，避免不同步的中间状态造成的问题。注意，在这里我们去判断 `props`上的字段是不是我们要的类型（在这里是 `string`）而不是判断 `props`上有没有这个字段，因为用户可能封装了一层组件，导致 `props`上有这个字段，但是它的值是 `undefined`，例如：

```
class CustomerComponent extends Component {
 render() {
  // 在用户的组件里，search也是可选字段，这会导致我们的组件`props`上有这个字段，但是它的值是`undefined`
  const { search } = this.props;
  return <SomeSearchableComponent search={search} />;
 }
}
```

## 二、带有中间状态的组件

第二种场景是一些组件需要在用户输入时有一个中间状态，当触发某个操作时再把中间结果提交给上层。以一个 `input`为例，在过去我们通过 `componentWillReceiveProps`在上层组件触发重绘时把数据同步到 `state`：

```
class SpecialInput extends Component {
 state = {
  value: this.props.value,
 };

 onChange = e => {
  this.setState({
   value: e.target.value,
  });
 };

 onBlur = e => {
  this.props.onChange(e.target.value);
 };

 componentWillReceiveProps(nextProps) {
  this.setState({
   value: nextProps.value,
  });
 }

 render() {
  const { value } = this.state;
  return (
   <input value={value} onChange={this.onChange} onBlur={this.onBlur} />
  );
 }
}
```

而上层组件更新和组件本身 `setState`都会触发 `getDerivedStateFromProps`，我们可以通过比较 `props`是不是同一个对象来知道这次更新是由上层触发的还是组件本身触发的，当 `props`不是同一个对象时，说明这次更新来自上层组件，例如：

```
class SpecialInput extends Component {
 state = {
  prevProps: this.props,
  value: this.props.value,
 };

 onChange = e => {
  this.setState({
   value: e.target.value,
  });
 };

 onBlur = e => {
  this.props.onChange(e.target.value);
 };

 static getDerivedStateFromProps(nextProps, { prevProps }) {
  if (nextProps !== prevProps) {
   return {
    prevProps: nextProps,
    value: nextProps.value,
   };
  }
  return null;
 }

 render() {
  const { value } = this.state;
  return (
   <input value={value} onChange={this.onChange} onBlur={this.onBlur} />
  );
 }
}
```

## 三、记忆

记忆(memorize)是一种简单常见的优化方式，通过脏检查两次传入的值是不是同一个来记忆结果。大部分情况下，不推荐使用 `getDerivedStateFromProps`。通常通过一个简单的帮助函数就可以完成这样的功能：

```
// 当然使用数组或者对象，并传入自定义的比较函数就可以实现记忆多个参数
function memorize(func) {
 let prev;
 let prevValue;
 let init = false;
 return param => {
  if (!init) {
   prevValue = func(param);
   prev = param;
   init = true;
  } else if (!Object.is(prev, param)) {
   prevValue = func(param);
   prev = param;
  }
  return prevValue;
 };
}

class SomeComponent extends Component {
 getBar = memorize(foo => {
  // ...
 });

 render() {
  const { foo } = this.props;
  const bar = this.getBar(foo);
  // ...
 }
}

```

而有些情况需要使用到 `getDerivedStateFromProps`，例如某个参数会影响组件的内部状态，这时候我们需要把前一次的值存在 `state`上，例如：

```
class SomeComponent extends Component {
 state = {
  prevType: this.props.type,
  // ...
 };

 static getDerivedStateFromProps({ type }, { prevType }) {
  if (type !== prevType) {
   return {
    prevType: type,
    // ...
   };
  }
  return null;
 }
}
```

## 使用 Hooks

React 16.8 稳定了 `HooksAPI`， `Hooks`在许多方面对比 `class`有巨大的优势，例如对于逻辑的复用，相对高阶组件不仅更方便灵活直观，性能也有很大的优势。

对于情况一，我们可以通过一些帮助函数实现：

```
function App(props) {
 const [search, setSearch] = useState('');
 function getSearch() {
  if (typeof props.search === 'string') {
   return props.search;
  }
  return search;
 }
}
```

对于第二种情况，我们可以借助一个 `ref`来实现：

```
function App(props) {
 const [value, setValue] = useState('');
 const propsRef = useRef(props);
 if (props !== propsRef.current) {
  setValue(props.value);
  propsRef.current = props;
 }
}
```

对于第三种情况，可以直接使用 `useMemo`。



```
function App({ type }) {
 const computed = useMemo(() => {
  // ...
 }, [type]);
}
```