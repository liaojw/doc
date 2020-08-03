# Immutable.js 基础操作

## Immutable 是什么？

* Immutable数据就是一旦创建，就不能更改的数据。
* 每当对Immutable对象进行修改的时候，就会返回一个新的Immutable对象，以此来保证数据的不可变。

## Immutable 的几种数据类型

1. `List`: 有序索引集，类似JavaScript中的Array。
2. `Map`: 无序索引集，类似JavaScript中的Object。
3. `Set`: 没有重复值的集合。
4. `Record`: 跟普通JS对象差不多。1、只是每个key都有一个默认值，可被覆盖。2、当删除一个key时，只是将其value置为默认值，该属性不会从对象上删除。3、key是固定的，一旦创建后就不会增加或减少。4、可以通过点运算来获取对象的属性

用的最多就是List和Map，所以在这里主要介绍这两种数据类型的API。

## API的使用

### 1.fromJS()

作用：将一个js数据转换为Immutable类型的数据。

用法：`fromJS(value, converter)`

简介：value是要转变的数据，converter是要做的操作。第二个参数可不填，默认情况会将数组准换为List类型，将对象转换为Map类型，其余不做操作。

代码实现：

```
const obj = Immutable.fromJS({a:'123',b:'234'})
```

### 2.toJS()

作用：将一个Immutable数据转换为JS类型的数据。

用法：`immutableValue.toJS()`

### 3.is()

作用：对两个对象进行比较。

用法：`is(map1,map2)`

简介：和js中对象的比较不同，在js中比较两个对象比较的是地址，但是在Immutable中比较的是这个对象`hashCode`和`valueOf`，只要两个对象的`hashCode`相等，值就是相同的，避免了深度遍历，提高了性能。

代码实现：

```
import { Map, is } from 'immutable'
const map1 = Map({ a: 1, b: 1, c: 1 })
const map2 = Map({ a: 1, b: 1, c: 1 })
map1 === map2   //false
Object.is(map1, map2) // false
is(map1, map2) // true
```

### 4.List 和 Map

#### 创建

- 直接用fromJS将原生转成 List 或 Map
- 构造函数List、Map

```
const list = List([1,2,3])
const map = Map({a:1,b:2})
```

#### 取值/设值/删除/ 清空/大小 get/set/delete/clear/size (size为属性，其他为方法)

- 用 toJS 转原生后再操作
- get(key)

```
list.get(0)  // 1
map.get('a')  // 1
```

* getIn([]) 对嵌套对象或数组取值，传参为数组，表示位置

```
let abs = Immutable.fromJS({a: {b:2}});
abs.getIn(['a', 'b']) // 2
abs.getIn(['a', 'c']) // 子级没有值

let arr = Immutable.fromJS([1 ,2, 3, {a: 5}]);
arr.getIn([3, 'a']); // 5
arr.getIn([3, 'c']); // 子级没有值
```

### 5. 使用注意点

#### 1.变量命名

非常值得注意的一个点。因为可能引用了其他的库或者文件,使得代码里存在immutable数据和非immutable数据。所以immutable变量需要加上 $$ 前缀来区分

#### 2.API上的习惯

赋值操作之后要修改原数据记得要赋值。不然无法更新数据。

```
$$data = $$data.set("hello","immutable")
```

#### 3.为了性能和节省内存, Immutable.js 会努力避免创建新的对象。如果没有数据变化发生的话。

```
const { Map } = require('immutable')
const originalMap = Map({ a: 1, b: 2, c: 3 })
const updatedMap = originalMap.set('b', 2)
updatedMap === originalMap // return ture
```

如上代码虽然进行了一顿操作。然而数据并没有改变。所以updatedMap和originalMap还是指向了同一个对象。

```
const updatedMap = originalMap.set('b', 4)
updatedMap === originalMap
// return false
```

此时返回false

## 关于 React 的更新

```
import { is } from 'immutable';
shouldComponentUpdate: (nextProps, nextState) => {
  return !(this.props === nextProps || is(Map(this.props), Map(nextProps))) ||
         !(this.state === nextState || is(Map(this.state), Map(nextState)));
}
```

## immutable 优势和使用场景

主要优势：
1、节省CPU
避免深拷贝，复杂对象比较
2、节省内存
结构共享，复用已有结构
3、lazy 操作

```
var oddSquares = Immutable.Seq.of(1,2,3,4,5,6,7,8).filter(function(x) {
	console.log('Immutable对象的filter执行');
	return x % 2;
}).map(x => x * x);

var jsSquares = [1,2,3,4,5,6,7,8].filter(function(x) {
	console.log('原生数组对象的filter执行');
	return x % 2;
}).map(x => x * x);
```

这段代码的意思就是，数组先取奇数，然后再对基数进行平方操作，然后在console.log第2个数，同样的代码，用immutable的seq对象来实现，filter只执行了3次，但原生执行了8次。  其实原理就是，用seq创建的对象，其实代码块没有被执行，只是被声明了，代码在get(1)的时候才会实际被执行，取到index=1的数之后，后面的就不会再执行了，所以在filter时，第三次就取到了要的数，从4-8都不会再执行  想想，如果在实际业务中，数据量非常大，如在我们点餐业务中，商户的菜单列表可能有几百道菜，一个array的长度是几百，要操作这样一个array，如果应用惰性操作的特性，会节省非常多的性能
 使用场景：
 对于数据结构复杂，操作很多的使用immutable比较合适。

## 优势

* 不可变对象，降低了 Mutable 带来的复杂度

```
foo={a: 1};
 bar=foo; 
bar.a=2
// foo.a 也变为了2
```

虽然这样做可以节约内存，但当应用复杂后，这就造成了非常大的隐患，Mutable 带来的优点变得得不偿失。为了解决这个问题，一般的做法是使用 shallowCopy（浅拷贝）或 deepCopy（深拷贝）来避免被修改，但这样做造成了 CPU (额外的拷贝操作)和内存(拷贝所需)的浪费。
 Immutable 特点是：持久化数据结构 && 结构共享

* 节省内存

```
import { Map} from 'immutable';
let a = Map({
  select: 'users',
  filter: Map({ name: 'Cam' })
})
let b = a.set('select', 'people');

a === b; // false
a.get('filter') === b.get('filter'); // true
```

* 用 cusor 访问嵌套较深的数据

```
import Immutable from 'immutable';
import Cursor from 'immutable/contrib/cursor';

let data = Immutable.fromJS({ a: { b: { c: 1 } } });
// 让 cursor 指向 { c: 1 }
let cursor = Cursor.from(data, ['a', 'b'], newData => {
  // 当 cursor 或其子 cursor 执行 update 时调用
  console.log(newData);
});

cursor.get('c'); // 1
cursor = cursor.update('c', x => x + 1);
cursor.get('c'); // 2
```

## 劣势

- 增加学习成本
- 增加资源大小 immutable.js 压缩后16K
- 容易和原生对象混淆

## React 相关

Immutable.is 比较的是两个对象的 hashCode 或 valueOf（对于 JavaScript 对象）。由于 immutable 内部使用了 Trie 数据结构来存储，只要两个对象的 hashCode 相等，值就是一样的。这样的算法避免了深度遍历比较，性能非常好。

可使用 Immutable.is 来减少 React 重复渲染，提高性能。当传递基本数据类型的属性给子组件时，子组件使用PureComponent即可；但是如果需要传递数组或对象给子组件，这时就需要用到 Immutable,在子组件的shouldComponentUpdate中用Immutable.is 比较新旧对象从而减少无意义的渲染。



