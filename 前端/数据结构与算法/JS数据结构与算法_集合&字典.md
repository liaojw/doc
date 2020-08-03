# [JS数据结构与算法_集合&字典](https://segmentfault.com/a/1190000018046833)

## 一、集合`Set`

### 1.1 集合数据结构

> 集合`set`是一种包含不同元素的数据结构。集合中的元素成为成员。集合的两个最重要特性是：**集合中的成员是无序的；集合中不允许相同成员存在**

计算机中的集合与数学中集合的概念相同，有一些概念我们必须知晓：

- 不包含任何成员的集合称为**空集**；包含一切可能的成员为**全集**
- 如果两个成员完全相同，则称为**两个集合相等**
- 如果一个集合中所有的成员都属于另一个集合，则前一个集合被称为后一个集合的**子集**

另外还有**交集**/**并集**/**差集**，下面会一一实现

### 1.2 集合的实现

一般集合包含下面几个方法：

- `add` 向集合添加一个新的项
- `remove` 从集合移除一个值
- `has` 如果值在集合中，返回`true`，否则返回`false`
- `clear` 移除集合中的所有项
- `size` 返回集合所包含元素的数量。与数组的length属性类似
- `values` 返回一个包含集合中所有值的数组
- `union` 两个集合的并集
- `intersection` 两个集合的交集
- `difference` 两个集合的差集
- `isSubsetOf` 判断是否为子集

下面将基于对象实现基础的集合（数组和队列也可实现集合，[点击查看](https://github.com/lxyc/algorithm_study_notes)）

```
class Set {
  constructor() {
    this._items = {};
    this._length = 0;
  }
  // 添加成员时，如果已有成员则不操作。以[value: value]的形式存储在对象中
  add(value) {
    if (this.has(value)) return false;
    this._items[value] = value;
    this._length += 1;
    return true;
  }
  // 移除成员时，如果没有对应成员则不操作
  remove(value) {
    if (!this.has(value)) return false;
    delete this._items[value];
    this._length -= 1;
    return true;
  }

  values() {
    return Object.values(this._items);
  }

  has(value) {
    return this._items.hasOwnProperty(value);
  }

  clear() {
    this._items = {};
    this._length = 0;
  }

  size() {
    return this._length;
  }

  isEmpty() {
    return !this._length;
  }
}
```

![clipboard.png](https://segmentfault.com/img/bVbnSUR?w=1366&h=880)

**（1）并集的实现**

将两个集合中的元素依次添加至新的集合中，并返回改集合

```
// 并集
union(otherSet) {
  const unionSet = new Set();

  const values = this.values();
  values.forEach(item => unionSet.add(item));

  const otherValues = otherSet.values();
  otherValues.forEach(item => unionSet.add(item));

  return unionSet;
}
```

**（2）交集的实现**

以集合A作为参考，遍历集合B依次对比成员，B中的成员存在A中则添加至新集合C中，最后返回C

```
// 交集
intersection(otherSet) {
  const intersectionSet = new Set();

  const values = this.values();
  values.forEach(item => {
    if (otherSet.has(item)) {
      intersectionSet.add(item);
    }
  })

  return intersectionSet;
}
```

**（3）差集的实现**

以集合A作为参考，遍历集合B依次对比成员，B中的成员不存在A中则添加至新集合C中，最后返回C

```
// 差集
difference(otherSet) {
  const differenceSet = new Set();

  const values = this.values();
  values.forEach(item => {
    if (!otherSet.has(item)) {
      differenceSet.add(item);
    }
  })

  return differenceSet;
}
```

**注意：A.difference(B)与B.difference(A)计算参考不同**

**（4）子集的实现**

以集合A作为参考，遍历集合B依次对比成员，B中的所有成员均存在A中则为其子集，否则不是

```
// 子集
isSubsetOf(otherSet) {
  if (this.size() > otherSet.size()) return false;

  const values = this.values();
  for (let i = 0; i < values.length; i += 1) {
    const item = values[i];
    if (!otherSet.has(item)) return false;
  }

  return true;
}
```

### 1.3 `ES6`中的`Set`

> `ES6`中提供了新的[数据结构`Set`](http://es6.ruanyifeng.com/#docs/set-map)，它类似于数组，但是成员的值都是唯一的，没有重复的值

提供了一下几个方法：

- `add(value)` 添加某个值，返回`Set`结构本身
- `delete(value)` 删除某个值，返回一个布尔值，表示删除是否成功
- `has(value)` 返回一个布尔值，表示该值是否为`Set`的成员
- `clear()` 清除所有成员，没有返回值
- `size` 属性，返回成员总数

**创建：**

- 直接通过数组创建：`new Set([1,2,3,4])`
- 先实例再添加：`const set = new Set(); set.add(1);`

**遍历：**

- `keys()` 返回键名的遍历器
- `values()` 返回键值的遍历器
- `entries()` 返回键值对的遍历器
- `forEach()`/`for-of` 使用回调函数遍历每个成员

## 二、字典`Dictionary`

### 2.1 字典数据结构

> 集合表示一组互不相同的元素(不重复的元素)。在字典中，存储的是`键-值对`，其中键名是用来查询特定元素的。字典和集合很相似，集合以`值-值对`的形式存储元素，字典则是以`键-值对`的形式来存储元素。字典也称作`映射`

类比：电话号码簿里的名字和电话号码。要找一个电话时，先找名字，名字找到了，紧挨着他的电话号码也就想找到了，这里的**键是指你用来查找的东西，值时查找得到的结果**

### 2.2 字典的实现

一般字典包括下面几种方法：

- `set(key,value)` 向字典中添加新元素
- `remove(key)` 通过使用键值来从字典中移除键值对应的数据值
- `has(key)` 如果某个键值存在于这个字典中，则返回`true`，反之则返回`false`
- `get(key)` 通过键值查找特定的数值并返回
- `clear()` 将这个字典中的所有元素全部删除
- `size()` 返回字典所包含元素的数量。与数组的`length`属性类似
- `keys()` 将字典所包含的所有键名以数组形式返回
- `values()` 将字典所包含的所有数值以数组形式返回

下面将基于对象实现基础的字典

```
class Dictionary {
  constructor() {
    this._table = {};
    this._length = 0;
  }

  set(key, value) {
    if (!this.has(key)) {
      this._length += 1;
    }
    this._table[key] = value;
  }

  has(key) {
    return this._table.hasOwnProperty(key);
  }

  remove(key) {
    if (this.has(key)) {
      delete this._table[key];
      this._length -= 1;
      return true;
    }
    return false;
  }

  get(key) {
    return this._table[key];
  }

  clear() {
    this._table = {};
    this._length = 0;
  }

  size() {
    return this._length;
  }

  keys() {
    return Object.keys(this._table);
  }

  values() {
    return Object.values(this._table);
  }
}
```

这里添加成员时，并未考虑`key`为对象的情况，以至于会出现如下情况：

```
const obj = {};
obj[{a: 1}] = 1;
obj[{a: 2}] = 2;

console.log(obj[{a: 1}]); // 2

// 对象形式的键会以其toSting方法的结果存储
obj; // {[object Object]: 2}
```

在ES6中支持`key`值为对象形式的字典数据结构`Map`，其提供的方法如下：

提供了一下几个方法：

- `set(key, value)` `set`方法设置键名`key`对应的键值为`value`，然后返回整个`Map`结构
- `get(key)` `get`方法读取`key`对应的键值，如果找不到`key`，返回`undefined`
- `delete(value)` 删除某个值，返回一个布尔值，表示删除是否成功
- `has(value)` 返回一个布尔值，表示该值是否为`Map`的成员
- `clear()` 清除所有成员，没有返回值
- `size` 属性，返回成员总数

**创建：**

- 直接通过数组创建：`const map = new Map([ ['name', '张三'], ['title', 'Author'] ]);`
- 先实例再添加：`const map = new Map();`

**遍历：**

- `keys()` 返回键名的遍历器
- `values()` 返回键值的遍历器
- `entries()` 返回键值对的遍历器
- `forEach()`/`for-of` 使用回调函数遍历每个成员

## 三、哈希表/散列表

### 3.1 哈希表数据结构

> 散列表也叫哈希表（`HashTable`也叫`HashMap`），是`Dictionary`类的一种散列表实现方式

**（1）哈希表有何特殊之处：**

数组的特点是寻址方便，插入和删除困难；而链表的特点是寻址困难，插入和删除方便。哈希表正是综合了两者的优点，实现了寻址方便，插入删除元素也方便的数据结构

**（2）哈希表实现原理**

哈希表就是把`Key`通过一个**固定的算法函数**既所谓的**哈希函数**转换成一个整型数字，然后将该数字对数组长度进行取余，取余结果就当作数组的下标，将`value`存储在以该数字为下标的数组空间里。而当使用哈希表进行查询的时候，就是再次使用哈希函数将`key`转换为对应的数组下标，并定位到该空间获取`value`，如此一来，就可以充分利用到数组的定位性能进行数据定位

下面是将`key`中每个字母的`ASCII`值之和作为数组的索引（哈希函数）的图例：

![clipboard.png](https://segmentfault.com/img/bVbnSU8?w=816&h=286)

**（3）数组的长度为什么选择质数**

书中有如下说明：

> 散列函数的选择依赖于键值的数据类型。如果键是整数，最简单的散列函数就是以数组的长度对键取余。在一些情况下，比如数组的长度为10，而键值都是10的倍数时，就不推荐使用这种方式了。这也是数组的长度为什么要是质数的原因之一。如果键是随机的整数，而散列函数应该更均匀地分布这些键，这种散列方式称为`除留余数法`

### 3.2 哈希表的实现

我们为哈希表实现下面几个方法：

- `hashMethod` 哈希函数，将字符串转换成索引
- `put` 添加键值
- `get` 由键获取值
- `remove` 移除键

```
class HashTable {
  constructor() {
    this._table = [];
  }

  // 哈希函数【社区中实践较好的简单哈希函数】
  hashMethod(key) {
    if (typeof key === 'number') return key;

    let hash = 5381;
    for (let i = 0; i < key.length; i += 1) {
      hash = hash * 33 + key.charCodeAt(i);
    }
    return hash % 1013;
  }

  put(key, value) {
    const pos = this.hashMethod(key);
    this._table[pos] = value;
  }

  get(key) {
    const pos = this.hashMethod(key);
    return this._table[pos];
  }

  remove(key) {
    const pos = this.hashMethod(key);
    delete this._table[pos];
  }

  print() {
    this._table.forEach((item, index) => {
      if (item !== undefined) {
        console.log(index + ' --> ' + item);
      }
    })
  }
}
```

当然了，一个简单的哈希函数，将不同的字符串转换成整数时，很有可能会出现多个不同字符串转换后对应同一个整数，这个就需要进行冲突的处理

### 3.3 处理冲突的方法

**（1）分离链接**

> 分离链接法包括为散列表的每一个位置创建一个链表并将元素存储在里面。它是解决冲突的
> 最简单的方法，但是它在HashTable实例之外还需要额外的存储空间

![clipboard.png](https://segmentfault.com/img/bVbnSVf?w=797&h=417)

**（2）线性探查**

> 当想向表中某个位置加入一个新元素的时候，如果索引 为index的位置已经被占据了，就尝试index+1的位置。如果index+1的位置也被占据了，就尝试 index+2的位置，以此类推

![clipboard.png](https://segmentfault.com/img/bVbnSVm?w=483&h=594)

## 四、`bitMap`算法

### 4.1 `bitMap`数据结构

**bitMap数据结构常用于大量整型数据做去重和查询**，[《Bitmap算法》](https://www.seoxiehui.cn/article-45186-1.html)这篇文章中是基于Java语言及数据库优化进行解释的图文教程

`bitMap`是利用了二进制来描述状态的一种数据结构，下面介绍其简单的原理：

**（1）思考下面的问题**

街边有8栈路灯，编号分别是1 2 3 4 5 6 7 8 ，其中2号，5号，7号，8号路灯是亮着的，其余的都处于不亮的状态，请你设计一种简单的方法来表示这8栈路灯亮与不亮的状态。

```
路灯  1   2   3   4   5   6   7   8
状态  0   1   0   0   1   0   1   1
```

将状态转化为二进制`parseInt(1001011, 2);`结果为75。一个`Number`类型的值为32个字节，它可以表示32栈路灯的状态。这样在大数据量的处理中，`bitMap`就有很大的优势。

**（2）位运算介绍**

1. 按位与`&`: `3&7=3`【`011 & 111 --> 011`】
2. 按位或`|`: `3|7=7`【`011 | 111 --> 111`】
3. 左位移`<<`: `1<<3=8`【`1 --> 1000`】

**（3）实践**

一组数，内容以为 3,6,7,9，请用一个整数来表示这些四个数

```
var value = 0;
value = value | 1<<3; // 1000
value = value | 1<<6; // 1001000
value = value | 1<<7; // 11001000
value = value | 1<<9; // 1011001000
console.log(value); // 712
```

这样，十进制数712的二进制形式对应的位数为1的值便为数组中的树值

### 4.2 `bitMap`的实现

通过上面的介绍，我们可以实现一个简单的`bitMap`类，有下面两个方法：

- `addMember`添加成员
- `isExist`成员是否存在

分析：

1. 单个数值既能表示0~32的值，若以数组作为基础，`bitMap`能容纳的成员由数组长度决定`64*数组长度`
2. `addMember`添加成员：数组/位数向下取整表示所在索引，数组/位数取余表示所在二进制的位数
3. `isExist`成员是否存在：添加成员的反向计算

我们先实现基础读写位的方法

```
export const BIT_SIZE = 32;

// 设置位的值
export function setBit(bitMap, bit) {
  const arrIndex = Math.floor(bit / BIT_SIZE);
  const bitIndex = Math.floor(bit % BIT_SIZE);
  bitMap[arrIndex] |= (1 << bitIndex);
}

// 读取位的值
export function getBit(bitMap, bit) {
  const arrIndex = Math.floor(bit / BIT_SIZE);
  const bitIndex = Math.floor(bit % BIT_SIZE);
  return bitMap[arrIndex] & (1 << bitIndex);
}
```

进而根据上面的方法得到下面的类

```
class BitMap {
  constructor(size) {
    this._bitArr = Array.from({
      length: size
    }, () => 0);
  }

  addMember(member) {
    setBit(this._bitArr, member);
  }

  isExist(member) {
    const isExist = getBit(this._bitArr, member);
    return Boolean(isExist);
  }
}

// 验证
const bitMap = new BitMap(4);
const arr = [0, 3, 5, 6, 9, 34, 23, 78, 99];
for(var i = 0;i < arr.length;i++){
    bitMap.addMember(arr[i]);
}

console.log(bitMap.isExist(3)); // true
console.log(bitMap.isExist(7)); // false
console.log(bitMap.isExist(78)); // true
```

**注意：这种结构也有其局限性**

1. 数据集要求较为紧凑，`[1, 1000000]`这种结构空间利用过低，不利于发挥`bitMap`的优势
2. 仅对整数有效（当然，我们可以通过哈希函数将字符串转换为整型）

### 4.3 `bitMap`的应用

**（1）大数据排序**

**要求**：有多达10亿无序整数，已知最大值为15亿，请对这个10亿个数进行排序
**分析**：大数据的排序，传统的排序方式相对内存占用较大，使用`bitMap`仅占原内存的(JS中为1/64，Java中为1/32)

**实现**：模拟大数据实现，如下（最大值为99）

```
const arr = [0, 6, 88, 7, 73, 34, 10, 99, 22];
const MAX_NUMBER = 99;

const ret = [];
const bitMap = new BitMap(4);
arr.forEach(item => { bitMap.addMember(item); })

for (let i = 0; i <= MAX_NUMBER; i += 1) {
  if (bitMap.isExist(i)) ret.push(i);
}

console.log(ret); // [ 0, 6, 7, 10, 22, 34, 73, 88, 99 ]
```

**（2）两个集合取交集**

**要求**：两个数组，内容分别为[1, 4, 6, 8, 9, 10, 15], [6, 14, 9, 2, 0, 7]，请用BitMap计算他们的交集
**分析**：利用`isExist()`来筛选相同项
**实现**：

```
const arr1 = [1, 4, 6, 8, 9, 10, 15];
const arr2 = [6, 14, 9, 2, 0, 7];
const intersectionArr = []

const bitMap = new BitMap();
arr1.forEach(item => bitMap.addMember(item))

arr2.forEach(item => {
  if (bitMap.isExist(item)) {
    intersectionArr.push(item);
  }
})

console.log(intersectionArr); // [6, 9]
```

`BitMap`数据结构的用法原不止如此，我们可以通过`哈希函数`将字符串转换成整数，再进行处理。当然，我们应该始终牢记`BitMap`必须是相对较为紧密的数字，否则无法发挥`BitMap`的最大功效