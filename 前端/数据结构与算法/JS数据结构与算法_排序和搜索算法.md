# [JS数据结构与算法_排序和搜索算法](https://segmentfault.com/a/1190000018665552)

## 一、准备

在进入正题之前，先准备几个基础的函数

**（1）交换数组两个元素**

```
function swap(arr, sourceIndex, targetIndex) {
  let temp = arr[sourceIndex];
  arr[sourceIndex] = arr[targetIndex];
  arr[targetIndex] = temp;
}
```

**（2）快速生成0~N的数组** [可点击查看更多生成方法](https://www.zhihu.com/question/41493194)

```
function createArr(length) {
  return Array.from({length}, (_, i) => i);
}
```

**（3）洗牌函数**

洗牌函数可快速打乱数组，常见的用法如切换音乐播放顺序

```
function shuffle(arr) {
  for (let i = 0; i < arr.length; i += 1) {
    const rand = Math.floor(Math.random() * (i + 1));
    if (rand !== i) {
      swap(arr, i, rand);
    }
  }
  return arr;
}
```

## 二、排序

常见排序算法可以分为两大类：

- **比较类排序**：通过比较来决定元素间的相对次序，由于其时间复杂度不能突破`O(nlogn)`，因此也称为非线性时间比较类排序
- **非比较类排序**：不通过比较来决定元素间的相对次序，它可以突破基于比较排序的时间下界，以线性时间运行，因此也称为线性时间非比较类排序

![clipboard.png](https://segmentfault.com/img/bVbqtSz?w=1372&h=1090)

在本篇博客中，仅对比较类排序的几种排序方式进行学习介绍

### 2.1 冒泡排序

冒泡排序是所有排序算法中最简单的，通常也是我们学习排序的入门方法。但是，从运行时间的角度来看，冒泡排序是最差的一种排序方式。

**核心：比较任何两个相邻的项，如果第一个比第二个大，则交换它们**。元素项向上移动至正确的顺序，就好像气泡升至表面一样，冒泡排序因而得名

**动图：**

![图片描述](https://segmentfault.com/img/bVDcJN?w=826&h=257)

**注意：第一层遍历找出剩余元素的最大值，至指定位置【依次冒泡出最大值】**

**代码：**

```
function bubbleSort(arr) {
  const len = arr.length;
  for (let i = 0; i < len; i += 1) {
    for (let j = 0; j < len - 1 - i; j += 1) {
      if (arr[j] > arr[j + 1]) { // 比较相邻元素
        swap(arr, j, j + 1);
      }
    }
  }
  return arr;
}
```

### 2.2 选择排序

选择排序是一种原址比较排序算法。

**核心：首先在未排序序列中找到最小元素，存放到排序序列的起始位置，然后，再从剩余未排序元素中继续寻找最小元素，然后放到已排序序列的末尾。以此类推，直到所有元素均排序完毕**

**动图：**
![图片描述](https://segmentfault.com/img/bVDcJC?w=811&h=248)

**注意：第一层遍历找出剩余元素最小值的索引，然后交换当前位置和最小值索引值【依次找到最小值】**

**代码：**

```
function selectionSort(arr) {
  const len = arr.length;
  let minIndex;
  for (let i = 0; i < len - 1; i += 1) {
    minIndex = i;
    for (let j = i + 1; j < len; j += 1) {
      if (arr[minIndex] > arr[j]) {
        minIndex = j; // 寻找最小值对应的索引
      }
    }
    if (minIndex === i) continue;
    swap(arr, minIndex, i);
  }
  return arr;
}
```

### 2.3 插入排序

插入排序的比较顺序不同于冒泡排序和选择排序，插入排序的比较顺序是当前项向前比较。

**核心：通过构建有序序列，对于未排序数据，在已排序序列中从后向前扫描，找到相应位置并插入**

**动图：**
![图片描述](https://segmentfault.com/img/bVDcJz?w=811&h=505)

**注意：从第二项开始，依次向前比较，保证当前项以前的序列是顺序排列**

**代码：**

```
function insertionSort(arr) {
  const len = arr.length;
  let current, pointer;
  for (let i = 1; i < len; i += 1) {
    current = arr[i];
    pointer = i;
    while(pointer >= 0 && current < arr[pointer - 1]) { // 每次向前比较
      arr[pointer] = arr[pointer - 1]; // 前一项大于指针项，则向前移动一项
      pointer -= 1;
    }
    arr[pointer] = current; // 指针项还原成当前项
  }
  return arr;
}
```

### 2.4 归并排序

归并排序和快速排序相较于上面三种排序算法在实际中更具有可行性（在第四小节我们会通过实践复杂度来比较这几种排序算法）

> `JavaScript`的`Array`类定义了一个`sort`函数(`Array.prototype.sort`)用以排序`JavaScript`数组。`ECMAScript`没有定义用哪个排序算法，所以浏览器厂商可以自行去实现算法。例如，`Mozilla Firefox`使用**归并排序**作为`Array.prototype.sort`的实现，而`Chrome`使用了一个**快速排序**的变体

**归并排序是一种分治算法。其思想是将原始数组切分成较小的数组，直到每个小数组只有一 个位置，接着将小数组归并成较大的数组，直到最后只有一个排序完毕的大数组。因此需要用到递归**

**核心：归并排序，拆分成左右两块数组，分别排序后合并**

**动图：**
![图片描述](https://segmentfault.com/img/bVDcJA?w=811&h=505)

**注意：递归中最小的左右数组比较为单个元素的数组，因此在较上层多个元素对比时，左右两个数组一定是顺序的**

**代码：**

```
function mergeSort(arr) {
  const len = arr.length;

  if (len < 2) return arr; // 递归的终止条件
  const middle = Math.floor(len / 2); // 拆分左右数组
  const left = arr.slice(0, middle);
  const right = arr.slice(middle);
  
  return merge(mergeSort(left), mergeSort(right));
}

function merge(left, right) { // 将左右两侧比较后进行合并
  const ret = [];

  while (left.length && right.length) {
    if (left[0] > right[0]) {
      ret.push(right.shift());
    } else {
      ret.push(left.shift());
    }
  }

  while (left.length) {
    ret.push(left.shift());
  }
  while (right.length) {
    ret.push(right.shift());
  }

  return ret;
}
```

### 2.5 快速排序

快速排序也许是最常用的排序算法了。它的复杂度为`O(nlogn)`，且它的性能通常比其他的复 杂度为`O(nlogn)`的排序算法要好。和归并排序一样，**快速排序也使用分治的方法，将原始数组分为较小的数组**

**核心：分治算法，以参考值为界限，将比它小的和大的值拆开**

**动图：**
![图片描述](https://segmentfault.com/img/bVDcJB?w=811&h=252)

**注意：每一次遍历筛选出比基准点小的值**

**代码：**

```
function quickSort(arr, left = 0, right = arr.length - 1) {
  // left和right默认为数组首尾
  if (left < right) {
    let partitionIndex = partition(arr, left, right);
    quickSort(arr, left, partitionIndex - 1);
    quickSort(arr, partitionIndex + 1, right);
  }
  return arr;
}

function partition(arr, left, right) {
  let pivot = left;
  let index = left + 1; // 满足比较条件的依次放在分割点后

  for (let i = index; i <= right; i += 1) {
    if (arr[i] < arr[pivot]) {
      swap(arr, i, index);
      index += 1;
    }
  }
  swap(arr, index - 1, pivot); // 交换顺序时，以最后一位替换分隔项
  return index - 1;
}
```

## 三、搜索算法

### 3.1 顺序搜索

顺序或线性搜索是最基本的搜索算法。它的机制是，将每一个数据结构中的元素和我们要找的元素做比较。**顺序搜索是最低效的一种搜索算法。**

```
function findItem(item, arr) {
  for (let i = 0; i < arr.length; i += 1) {
    if (item === arr[i]) {
      return i;
    }
  }
  return -1;
}
```

### 3.2 二分搜索

二分搜索要求被搜索的数据结构已排序。以下是该算法遵循的步骤：

1. 选择数组的中间值
2. 如果选中值是待搜索值，那么算法执行完毕
3. 如果待搜索值比选中值要小，则返回步骤1在选中值左边的子数组中寻找
4. 如果待搜索值比选中值要大，则返回步骤1在选中值右边的子数组中寻找

```
function binarySearch(item, arr) {
  arr = quickSort(arr); // 排序

  let low = 0;
  let high = arr.length - 1;
  let mid;

  while (low <= high) {
    min = Math.floor((low + high) / 2);
    if (arr[mid] < item) {
      low = mid + 1;
    } else if (arr[mid] > item) {
      high = mid - 1;
    } else {
      return mid;
    }
  }
  return -1;
}
```

## 四、算法复杂度

### 4.1 理解大O表示法

**大O表示法用于描述算法的性能和复杂程度**。分析算法时，时常遇到一下几类函数

![clipboard.png](https://segmentfault.com/img/bVbqtU4?w=1564&h=510)

**（1）O(1)**

```
function increment(num){
    return ++num;
}
```

**执行时间和参数无关**。因此说，上述函数的复杂度是`O(1)`(常数)

**（2）O(n)**

以`顺序搜索函数`为例，查找元素需要遍历整个数组，直到找到该元素停止。**函数执行的总开销取决于数组元素的个数(数组大小)，而且也和搜索的值有关**。但是函数复杂度取决于最坏的情况：如果数组大小是10，开销就是10；如果数组大小是1000，开销就是1000。这种函数的时间复杂度是`O(n)`，n是(输入)数组的大小

**（3）O(n2)**

以`冒泡排序`为例，在未优化的情况下，每次排序均需进行`n*n`次执行。时间复杂度为`O(n2)`

> 时间复杂度`O(n)`的代码只有一层循环，而`O(n2)`的代码有双层嵌套循环。如 果算法有三层遍历数组的嵌套循环，它的时间复杂度很可能就是`O(n3)`

### 4.2 时间复杂度比较

**（1）常用数据结构时间复杂度**

![clipboard.png](https://segmentfault.com/img/bVbqtU6?w=1758&h=658)

**（2）排序算法时间复杂度**

![clipboard.png](https://segmentfault.com/img/bVbqtU7?w=1768&h=828)

