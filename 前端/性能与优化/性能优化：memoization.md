# 性能优化：memoization

`memoization`适用于递归计算场景，例如 [fibonacci 数值](http://en.wikipedia.org/wiki/Fibonacci_number) 的计算。 

```javascript
'use strict';

let n = process.env.N || 50;

console.log('process $', process.pid);
console.log('fibonacci recursive version with n = ', n);
let count = 0;
function fibonacci(n) {
  count++;
  //console.log(count);
  if (n == 0 || n == 1) {
    return n;
  } else {
    return fibonacci(n - 1) + fibonacci(n - 2);
  }
}
fibonacci(n);
console.log('process memory usage', process.memoryUsage());
console.log('final count', count);
```

如果使用这种递归的写法去计算第 50 个 fibonacci 数值，需要执行 40730022147 次。随着执行次数的增加，执行所需时间成指数上涨：

![img](https://gtms04.alicdn.com/tps/i4/TB1d7ebKpXXXXXdXVXXue9FUVXX-1917-2180.png)

`memoization`的技巧在于将计算过的结果『缓存』下来，避免重复计算带来的成本，例如将计算 fibonacci 的代码改写为如下形式：

```javascript
'use strict';

let N = process.env.N || 50;
let count = 0;

let fibonacci = (function() {
  let memo = {};
  function f(n) {
    count++;
    let value;
    if (n in memo) {
      value = memo[n];
    } else {
      if (n == 0 || n == 1) {
        value = n;
      } else {
        value = f(n - 1) + f(n - 2);
      }
      memo[n] = value;
    }
  }
  return f;
})();

fibonacci(N);

console.log('process memory usage', process.memoryUsage());
console.log('final count', count);
```

计算第 50 个 fibonacci 值只需要 99 次，执行时间为 0.06 秒，只有递归版本执行时间（546.41 秒）的万分之一，使用的内存（RSS 值 20111360）只有递归版本（RSS 值为 36757504）的 54%。

> 值得注意的是：这里闭包使用的`memo`对象有可能造成内存泄露。

![img](https://gtms01.alicdn.com/tps/i1/TB1Q88ZKpXXXXcmaXXX9gOTNXXX-1922-768.png)

### 处理多个参数

如果需要处理多个参数，需要把缓存的内容变成多维数据结构，或者把多个参数结合起来作为一个索引。

例如：

```javascript
'use strict';

let N = process.env.N || 50;

let fibonacci = (function() {
  let memo = {};
  function f(x, n) {
    let value;
    memo[x] = memo[x] || {};
    if (x in memo && n in memo[x]) {
      value = memo[x][n];
    } else {
      if (n == 0 || n == 1) {
        value = n;
      } else {
        value = f(n - 1) + f(n - 2);
      }
      memo[x][n] = value;
    }
    return value;
  }
  return f;
})();

fibonacci('a', N);
fibonacci('b', N);

console.log('process memory usage', process.memoryUsage());

```

上面执行了两次`fibonacci`函数，假设执行多次：

![img](https://gtms01.alicdn.com/tps/i1/TB1hgewKpXXXXXLXpXXASkp1VXX-1954-918.png)

可以看到内存的增长也是有限的，并且最终控制在了`22097920`这个值。下面是另一种处理多个参数的情况（将多个参数组成一个索引）：

```javascript
'use strict';

let N = process.env.N || 50;
let count;
let memo = {};
const slice = Array.prototype.slice;

let fibonacci = (function() {
  count = 0;
  function f(x, n) {
    count++;
    let args = slice.call(arguments);
    let value;
    memo[x] = memo[x] || {};
    if (args in memo) {
      value = memo[args];
    } else {
      if(n == 0 || n == 1) {
        value = n;
      } else {
        value = f(x, n - 1) + f(x, n - 2);
      }
      memo[args] = value;
    }
    return value;
  }
  return f;
})();

let result;
for (let i = 0; i < N; i++) {
  count = 0;
  result = fibonacci('#' + i, i);
  console.log('process memory usage', process.memoryUsage());
  console.log('final count', count);
  console.log('result of #' + i, result);
}
```

与上面版本相比，内存有所增加，速度有所下降：

![50 æ¬¡å¯¹æ¯](https://gtms02.alicdn.com/tps/i2/TB1x71oKpXXXXcEXpXXj7Qt5VXX-3824-2270.png)

![100 æ¬¡å¯¹æ¯](https://gtms03.alicdn.com/tps/i3/TB1TTt8KpXXXXc9XVXX4nXcUXXX-3832-2300.png)

![1000 æ¬¡å¯¹æ¯](https://gtms04.alicdn.com/tps/i4/TB18uugKpXXXXb9XFXXX9u8OXXX-3820-2304.png)

### 自动`memoization`

```javascript
function memoize(func) {
  let memo = {};
  let slice = Array.prototype.slice;
  return function() {
    let args = slice.call(arguments);
    if (args in memo) {
      return memo[args];
    } else {
      return memo[args] = func.apply(this, args);
    }
  };
}
```

但是需要注意的是，并不是所有函数都可以自动`memoization`，只有`referential transparency`（引用透明）的函数可以。所谓`referential transparency`的函数是指：函数的输出完全由其输入决定，且不会有副作用的函数。下面的函数就是一个反例：

```javascript
var bar = 1;

// foo 函数的结果还受到全局变量 bar 的影响
function foo(baz) {
  return baz + bar;
}

foo(1);
bar++;
foo(1);
```

对比自动`memoization`前后的两个版本：

![img](https://gtms02.alicdn.com/tps/i2/TB1soOyKpXXXXaPXVXX28mEJXXX-3814-420.png)

自动`memoization`处理后的版本有所提高，但相比手动完全`memoization`的版本效率还是差了很多。

其实`memoization`这个词来自人工智能研究领域，其词源为拉丁语`memorandum`，这个词的创造者为[Donald Michie](http://www.aiai.ed.ac.uk/~dm/dm.html)，这种函数的设计初衷是为了提升机器学习的性能。随着函数式编程语言（Functional Programming，简称 FP）的兴起，例如 JavaScript、Haskell 以及 Erlang，这种用法才变得越来越流行。在前端编程中，可以使用`memoization`去处理各种需要递归计算的场景，例如缓存 canvas 动画的计算结果。

上面自动`memoization`的结果并不理想，可以参考`underscore`和`lodash`的`memoize`来做优化。

使用[`lodash`的`memoize`](https://github.com/lodash/lodash/blob/145c3abb34ae327679d90d18804c7b955398c390/vendor/underscore/underscore.js#L777)方法

```javascript
/**
 * @filename: fibonacci-memoization-with-lodash.js
 */
'use strict';

let n = process.env.N || 50;
let _ = require('lodash');
let memoize = _.memoize;
let fibonacci = require('./fibonacci-recursive.js');

let newFibonacci = memoize(fibonacci);
let result = newFibonacci(n);
console.log('process memory usage', process.memoryUsage());
console.log('result', result);
```

对比结果：

![img](http://gtms01.alicdn.com/tps/i1/TB1pHCxKpXXXXcsXVXXT7Jp5pXX-3760-400.png)

可以看到`lodash`的`memoize`方法减少了一半执行时间。进一步优化：

```javascript
module.exports = function memoize(func, context) {
  function memoizeArg(argPos) {
    var cache = {};
    return function() {
      if (argPos == 0) {
        if (!(arguments[argPos] in cache)) {
          cache[arguments[argPos]] = func.apply(context, arguments);
        }
        return cache[arguments[argPos]];
      } else {
        if (!(arguments[argPos] in cache)) {
          cache[arguments[argPos]] = memoizeArg(argPos - 1);
        }
        return cache[arguments[argPos]].apply(this, arguments);
      }
    };
  }
  var arity = func.arity || func.length;
  return memoizeArg(arity - 1);
};
```

![img](http://gtms01.alicdn.com/tps/i1/TB1q4SZKpXXXXcRXXXXusZkMpXX-1918-320.png)

> 科普下：`function arity`指的是一个函数接受的参数个数，这是一个被废弃的属性，现在应使用`Function.prototype.length`。
> https://stackoverflow.com/questions/4848149/get-a-functions-arity

zakas 的版本更加快，甚至比我们将`fibonacci`手动`memoization`的版本还快：

```javascript
'use strict';
let n = process.env.N || 50;
let count = 0;

function memoizer(fundamental, cache) {
  cache = cache || {};
  let shell = function(arg) {
    if (!cache.hasOwnProperty(arg)) {
      cache[arg] = fundamental(shell, arg);
    }
    return cache[arg];
  };
  return shell;
}

let fibonacci = memoizer(function(recur, n) {
  count++;
  return recur(n - 1) + recur(n - 2);
}, {
  0: 0,
  1: 1
});

let result = fibonacci(n);
console.log('process memory usage', process.memoryUsage());
console.log('count', count);
console.log('result', result);

```

![img](http://gtms02.alicdn.com/tps/i2/TB1taHXKpXXXXXqXXXXHSJCLpXX-1916-570.png)

但是上面这些函数都存在问题，如果输入数目过大，会引发调用栈超过限制异常：`RangeError: Maximum call stack size exceeded`。

一种解决的方法就是将递归（`recursion`）修改为迭代（`iteration`）。例如下面这样的归并排序算法：

```javascript
'use strict';

let n = process.env.N || 100;
let isMemoized = process.env.M;
let test = [];

function merge(left, right) {
  let result = [];

  while (left.length > 0 && right.length > 0) {
    if (left[0] < right[0]) {
      result.push(left.shift());
    } else {
      result.push(right.shift());
    }
  }

  return result.concat(left).concat(right);
}

function mergeSort(items) {
  if (items.length == 1) {
    return items;
  } else {
    let middle = Math.floor(items.length / 2);
    let left = items.slice(0, middle);
    let right = items.slice(middle);
    return merge(mergeSort(left), mergeSort(right));
  }
}

for (let i = 0; i < n; i++) {
  test.push(Math.random() * 10);
}

let result;
if (isMemoized) {
  let memoize = require('./zakas-memo.js');
  mergeSort = memoize(mergeSort);
  result = mergeSort(test);
} else {
  result = mergeSort(test);
}
console.log('process memory usage', process.memoryUsage());

```

![img](http://gtms01.alicdn.com/tps/i1/TB1L8uRKpXXXXbkXFXXDHvXMXXX-3822-622.png)

而上面的排序函数在经过`memoization`后虽然不会抛出`RangeError: Maximum call stack size exceeded`的异常，但是在极端情况下也会因为内存不够分配导致失败：

![img](https://gtms02.alicdn.com/tps/i2/TB1XrjXKpXXXXaxXXXXrdqLOXXX-1926-1882.png)

解决`RangeError: Maximum call stack size exceeded`异常的一种方法是将递归的代码改写为迭代的代码，例如`fibonacci`的递归式写法为：

```javascript
'use strict';

module.exports = function fibonacci(n) {
  n = parseInt(n);
  console.log('n = ', n);
  if (isNaN(n)) {
    return null;
  } else {
    let first = 0;
    let prev = 1;
    let sum;
    let count = 0;
    if (n <= 1) {
      sum = n;
    } else {
      for (let i = 2; i <= n; i++) {
        sum = first + prev;
        first = prev;
        prev = sum;
        console.log('i = ' + i + ':' + ' sum = ' + sum);
      }
    }
    return sum;
  }
};
```

### 他山之石

在 JavaScript 中我们是通过函数的形式来是实现函数的`memoization`，在 Python 中还可以用另一种被称为`decorator`的形式：

```javascript
#!/usr/bin/env python
def memoize(f):
    memo = {}
    def helper(x):
        if x not in memo:
            memo[x] = f(x)
        return memo[x]
    return helper

@memoize
def fib(n):
    if n == 0:
        return 0
    elif n == 1:
        return 1
    else:
        return fib(n - 1) + fib(n - 2)

print(fib(100))
```

