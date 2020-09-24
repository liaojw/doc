# 什么是 RegExp？

 

* RegExp 是正则表达式（Regular expression）的缩写，作用是对字符串执行模式匹配。
* 通常用于格式验证、正则替换、查找子串等
* 各种编程语言的正则表达式基本相同，不同的语言可能会有一些细小的差别
* RegExp入门：[http://www.w3school.com.cn/js/js_obj_regexp.asp](http://www.w3school.com.cn/js/js_obj_regexp.asp)
* 完整的 RegExp 对象参考手册：[http://www.w3school.com.cn/jsref/jsref_obj_regexp.asp](http://www.w3school.com.cn/jsref/jsref_obj_regexp.asp)

#  RegExp 语法

```
// 直接实例化
var reg = new RegExp(pattern [, flags]);
// 隐式创建(推荐)
var reg = /pattern/flags;
```
参数 pattern 是一个字符串，指定了正则表达式的模式或其他正则表达式。

参数 [, flags] 是一个可选的字符串，包含属性 “g”（global ）、”i” （ignoreCase）和 “m”（multiline）。

ECMAScript 标准化之前，不支持 m 属性。如果 pattern 是正则表达式，而不是字符串，则必须省略该参数。

|修饰符|描述|
|-----|---|
|i|执行对大小写的不明感|
|g|执行全局匹配（查找所有匹配而非在找到第一个匹配后停止）|
|m|执行多行匹配|

# 概念：子表达式
在正则表达式中，使用括号括起来的内容是一个子表达式，子表达式匹配到的内容会被系统捕获至缓冲区，使用\n（n：数字）来反向引用系统的第n号缓冲区的内容。 

场景：后面的内容要求与前面的一致，可以使用子表达式

```
// 查找连续相同的四个数字
var str = "1212ab45677778cd";
var reg = /(\d)\1\1\1/gi;
console.log(str.match(reg));
// OUTPUT:7777
```

# 概念：方括号（字符簇）

```
var str = "Is this all there is?";
var patt1 = /[a-h]/g;
document.write(str.match(patt1));
// OUTPUT:h,a,h,e,e
```
|方括号|作用|
|-----|---|
|[abc]|查找方括号之间的任何字符|
|[^abc]|查找任何不在方括号之间的字符|
|[0-9]|查找任何从 0 至 9 的数字，同 \d|
|[a-z]|查找任何从小写 a 到小写 z 的字符|
|[A-Z]|查找任何从大写 A 到大写 Z 的字符|
|[A-z]|查找任何从大写 A 到小写 z 的字符|
|[0-9a-zA-Z]|查找0-9，a-z，A-Z|

# 概念：元字符
元字符（Metacharacter）是拥有特殊含义的字符：

\ | 转义符 （、）、/、\

| | 选择匹配符，可以匹配多个规则

. | 查找单个字符，除了换行和行结束符

\w | 查找单词字符，字符 ( 字母 ，数字，下划线_ )

\W | 查找非单词字符

\d | 查找数字

\D | 查找非数字字符

\s | 查找空白字符，空格

\S | 查找非空白字符

\b | 匹配单词边界

\B | 匹配非单词边界

\0 | 查找 NUL 字符

\n | 查找换行符

\f | 查找换页符

\r | 查找回车符

\t | 查找制表符

\v | 查找垂直制表符

\xxx | 查找以八进制数 xxx 规定的字符

\xdd | 查找以十六进制数 dd 规定的字符

\uxxxx | 查找以十六进制数 xxxx 规定的 Unicode 字符

#概念：量词
|量词|作用|
|---|---|
|n+|匹配任何包含至少一个 n 的字符串，同 {1,}|
|n*|匹配任何包含零个或多个 n 的字符串，同 {0,}|
|n?|匹配任何包含零个或一个 n 的字符串，同 {0,1}|
|n{X}|匹配包含 X 个 n 的序列的字符串|
|n{X,Y}|匹配包含 X 至 Y 个 n 的序列的字符串|
|n{X,}|匹配包含至少 X 个 n 的序列的字符串|
|n$|匹配任何结尾为 n 的字符串|
|^n|匹配任何开头为 n 的字符串。注意 /[^a] / 和 /^ [a]/是不一样的，前者是排除的，后者是代表首位|
|(?=n)|匹配任何其后紧接指定字符串 n 的字符串，正向预查|
|(?!n)|匹配任何其后没有紧接指定字符串 n 的字符串，反向预查|

# RegExp 对象方法
## test() 
test() 方法检索字符串中是否存在指定的值。返回值是 true 或 false

```
var patt1 = new RegExp('e');
console.log(patt1.test('some text'));
// OUTPUT:true
var patt2 = new RegExp('ee');
console.log(patt2.test('some text'));
// OUTPUT:false
```

```
// 判断是不是QQ号
// 1 首位不能是0  ^[1-9]
// 2 必须是 [5, 11] 位的数字 \d{4, 9}
var str = '80583600';
var regexp = /^[1-9][0-9]{4,10}$/gim;
if (regexp.test(str)) {
    alert('is');
} else {
    alert('no');
}
```

## exec()
exec() 方法检索字符串中的指定值。返回值是被找到的值。如果没有发现匹配，则返回 null

```
var patt1 = new RegExp('e');
console.log(patt1.exec('some text'));
// OUTPUT:e
var patt2 = new RegExp('ee');
console.log(patt2.exec('some text'));
// OUTPUT:null
```

## compile()
compile() 既可以改变检索模式，也可以添加或删除第二个参数

```
var patt1=new RegExp("e");
document.write(patt1.test("The best things in life are free")); // true
// 改变了检索模式
patt1.compile("eee");
document.write(patt1.test("The best things in life are free")); // false
```

# 支持正则表达式的 String 对象的方法
## search 检索与正则表达式相匹配的值

```
var str = "Visit W3School!"
console.log(str.search(/W3School/))
// OUTPUT:6
```

## match 找到一个或多个正则表达式的匹配

```
var str="1 plus 2 equal 3"
console.log(str.match(/\d+/g))
// OUTPUT:1,2,3
```

## replace 替换与正则表达式匹配的子串

```
var str = "Visit Microsoft!"
console.log(str.replace(/Microsoft/, "W3School"));
// OUTPUT:Visit W3School!
```

```
// 找重复项最多的字符个数
var str = 'g21ss4aeba_ersb43sgnnsssstht6sss60snnsj8resw0_ss';
// split : 将字符串转化为数组
// sort : 对数组排序，ASCII
// join : 将数组转化为字符串
var str_new = str.split('').sort().join('');
document.write(str + '<br>');
document.write(str.split('') + '<br>');
document.write(str.split('').sort() + '<br>');
document.write(str.split('').sort().join('') + '<br>');
// 匹配字符，且重复这个字符，重复次数至少一次。
var regexp = /(\w)\1+/g;
var index = 0;
var value = '';
str_new.replace(regexp, function($0, $1) {
    // document.write($0);
    // document.write($1);
    if (index < $0.length) {
        index = $0.length;
        value = $1;
    }
});
document.write('重复项最多的字符是：' + value + '，个数是：' + index);
// OUTPUT:
// 0012344668__aabbeeegghjnnnnrrssssssssssssssssttw
// 重复项最多的字符是：s，个数是：16
```

## split 把字符串分割为字符串数组

```
var str = "How are you doing today?"
document.write(str.split(/\s+/));
// OUTPUT:How,are,you,doing,today?
```

>##经验：
>1.检验格式（邮箱格式、IP格式）是否正确，用test()

>2.抓取星期（如所有手机号），用exec()、match()

>3.替换敏感词汇，用replace()

# 常见的 正则表达式 校验

```
// 常见的 正则表达式 校验
// QQ号、手机号、Email、是否是数字、去掉前后空格、是否存在中文、邮编、身份证、URL、日期格式、IP
var myRegExp = {
    // 检查字符串是否为合法QQ号码
    isQQ: function(str) {
        // 1 首位不能是0  ^[1-9]
        // 2 必须是 [5, 11] 位的数字  \d{4, 9}
        var reg = /^[1-9][0-9]{4,9}$/gim;
        if (reg.test(str)) {
            console.log('QQ号码格式输入正确');
            return true;
        } else {
            console.log('请输入正确格式的QQ号码');
            return false;
        }
    },
    // 检查字符串是否为合法手机号码
    isPhone: function(str) {
        var reg = /^(0|86|17951)?(13[0-9]|15[012356789]|18[0-9]|14[57]|17[678])[0-9]{8}$/;
        if (reg.test(str)) {
            console.log('手机号码格式输入正确');
            return true;
        } else {
            console.log('请输入正确格式的手机号码');
            return false;
        }
    },
    // 检查字符串是否为合法Email地址
    isEmail: function(str) {
        var reg = /^\w+((-\w+)|(\.\w+))*\@[A-Za-z0-9]+((\.|-)[A-Za-z0-9]+)*\.[A-Za-z0-9]+$/;
        // var reg = /^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/;
        if (reg.test(str)) {
            console.log('Email格式输入正确');
            return true;
        } else {
            console.log('请输入正确格式的Email');
            return false;
        }
    },
    // 检查字符串是否是数字
    isNumber: function(str) {
        var reg = /^\d+$/;
        if (reg.test(str)) {
            console.log(str + '是数字');
            return true;
        } else {
            console.log(str + '不是数字');
            return false;
        }
    },
    // 去掉前后空格
    trim: function(str) {
        var reg = /^\s+|\s+$/g;
        return str.replace(reg, '');
    },
    // 检查字符串是否存在中文
    isChinese: function(str) {
        var reg = /[\u4e00-\u9fa5]/gm;
        if (reg.test(str)) {
            console.log(str + ' 中存在中文');
            return true;
        } else {
            console.log(str + ' 中不存在中文');
            return false;
        }
    },
    // 检查字符串是否为合法邮政编码
    isPostcode: function(str) {
        // 起始数字不能为0，然后是5个数字  [1-9]\d{5}
        var reg = /^[1-9]\d{5}$/g;
        // var reg = /^[1-9]\d{5}(?!\d)$/;
        if (reg.test(str)) {
            console.log(str + ' 是合法的邮编格式');
            return true;
        } else {
            console.log(str + ' 是不合法的邮编格式');
            return false;
        }
    },
    // 检查字符串是否为合法身份证号码
    isIDcard: function(str) {
        var reg = /^(^[1-9]\d{7}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}$)|(^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])((\d{4})|\d{3}[Xx])$)$/;
        if (reg.test(str)) {
            console.log(str + ' 是合法的身份证号码');
            return true;
        } else {
            console.log(str + ' 是不合法的身份证号码');
            return false;
        }
    },
    // 检查字符串是否为合法URL
    isURL: function(str) {
        var reg = /^https?:\/\/(([a-zA-Z0-9_-])+(\.)?)*(:\d+)?(\/((\.)?(\?)?=?&?[a-zA-Z0-9_-](\?)?)*)*$/i;
        if (reg.test(str)) {
            console.log(str + ' 是合法的URL');
            return true;
        } else {
            console.log(str + ' 是不合法的URL');
            return false;
        }
    },
    // 检查字符串是否为合法日期格式 yyyy-mm-dd
    isDate: function(str) {
        var reg = /^[1-2][0-9][0-9][0-9]-[0-1]{0,1}[0-9]-[0-3]{0,1}[0-9]$/;
        if (reg.test(str)) {
            console.log(str + ' 是合法的日期格式');
            return true;
        } else {
            console.log(str + ' 是不合法的日期格式，yyyy-mm-dd');
            return false;
        }
    },
    // 检查字符串是否为合法IP地址
    isIP: function(str) {
        // 1.1.1.1  四段  [0 , 255]
        // 第一段不能为0
        // 每个段不能以0开头
        //
        // 本机IP: 58.50.120.18 湖北省荆州市 电信
        var reg = /^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$/gi;
        if (reg.test(str)) {
            console.log(str + ' 是合法的IP地址');
            return true;
        } else {
            console.log(str + ' 是不合法的IP地址');
            return false;
        }
    }
}
// 测试
// console.log(myRegExp.isQQ('80583600'));
// console.log(myRegExp.isPhone('17607160722'));
// console.log(myRegExp.isEmail('80583600@qq.com'));
// console.log(myRegExp.isNumber('100a'));
// console.log(myRegExp.trim('  100  '));
// console.log(myRegExp.isChinese('baixiaoming'));
// console.log(myRegExp.isChinese('小明'));
// console.log(myRegExp.isPostcode('412345'));
// console.log(myRegExp.isIDcard('42091119940927001X'));
// console.log(myRegExp.isURL('https://www.baidu.com/'));
// console.log(myRegExp.isDate('2017-4-4'));
// console.log(myRegExp.isIP('1.0.0.0'));
```

## 一、校验数字的表达式

```
数字：^[0-9]*$
n位的数字：^\d{n}$
至少n位的数字：^\d{n,}$
m-n位的数字：^\d{m,n}$
零和非零开头的数字：^(0|[1-9][0-9]*)$
非零开头的最多带两位小数的数字：^([1-9][0-9]*)+(.[0-9]{1,2})?$
带1-2位小数的正数或负数：^(\-)?\d+(\.\d{1,2})?$
正数、负数、和小数：^(\-|\+)?\d+(\.\d+)?$
有两位小数的正实数：^[0-9]+(.[0-9]{2})?$
有1~3位小数的正实数：^[0-9]+(.[0-9]{1,3})?$
非零的正整数：^[1-9]\d*$ 或 ^([1-9][0-9]*){1,3}$ 或 ^\+?[1-9][0-9]*$
非零的负整数：^\-[1-9][]0-9"*$ 或 ^-[1-9]\d*$
非负整数：^\d+$ 或 ^[1-9]\d*|0$
非正整数：^-[1-9]\d*|0$ 或 ^((-\d+)|(0+))$
非负浮点数：^\d+(\.\d+)?$ 或 ^[1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0$
非正浮点数：^((-\d+(\.\d+)?)|(0+(\.0+)?))$ 或 ^(-([1-9]\d*\.\d*|0\.\d*[1-9]\d*))|0?\.0+|0$
正浮点数：^[1-9]\d*\.\d*|0\.\d*[1-9]\d*$ 或 ^(([0-9]+\.[0-9]*[1-9][0-9]*)|([0-9]*[1-9][0-9]*\.[0-9]+)|([0-9]*[1-9][0-9]*))$
负浮点数：^-([1-9]\d*\.\d*|0\.\d*[1-9]\d*)$ 或 ^(-(([0-9]+\.[0-9]*[1-9][0-9]*)|([0-9]*[1-9][0-9]*\.[0-9]+)|([0-9]*[1-9][0-9]*)))$
浮点数：^(-?\d+)(\.\d+)?$ 或 ^-?([1-9]\d*\.\d*|0\.\d*[1-9]\d*|0?\.0+|0)$
```

## 二、校验字符的表达式

```
汉字：^[\u4e00-\u9fa5]{0,}$
英文和数字：^[A-Za-z0-9]+$ 或 ^[A-Za-z0-9]{4,40}$
长度为3-20的所有字符：^.{3,20}$
由26个英文字母组成的字符串：^[A-Za-z]+$
由26个大写英文字母组成的字符串：^[A-Z]+$
由26个小写英文字母组成的字符串：^[a-z]+$
由数字和26个英文字母组成的字符串：^[A-Za-z0-9]+$
由数字、26个英文字母或者下划线组成的字符串：^\w+$ 或 ^\w{3,20}$
中文、英文、数字包括下划线：^[\u4E00-\u9FA5A-Za-z0-9_]+$
可以输入含有^%&',;=?$\"等字符：[^%&',;=?$\x22]+
禁止输入含有~的字符：[^~\x22]+
```

## 特殊需求表达式

```
Email地址：^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$
域名：[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(/.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+/.?
InternetURL：[a-zA-z]+://[^\s]* 或 ^http://([\w-]+\.)+[\w-]+(/[\w-./?%&=]*)?$
手机号码：^(13[0-9]|14[5|7]|15[0|1|2|3|5|6|7|8|9]|18[0|1|2|3|5|6|7|8|9])\d{8}$
电话号码("XXX-XXXXXXX"、"XXXX-XXXXXXXX"、"XXX-XXXXXXX"、"XXX-XXXXXXXX"、"XXXXXXX"和"XXXXXXXX)：^(\(\d{3,4}-)|\d{3.4}-)?\d{7,8}$
国内电话号码(0511-4405222、021-87888822)：\d{3}-\d{8}|\d{4}-\d{7}
身份证号(15位、18位数字)：^\d{15}|\d{18}$
身份证号: /^\d{6}(18|19|20)?\d{2}(0[1-9]|1[012])(0[1-9]|[12]\d|3[01])\d{3}(\d|[xX])$/
短身份证号码(数字、字母x结尾)：^([0-9]){7,18}(x|X)?$ 或 ^\d{8,18}|[0-9x]{8,18}|[0-9X]{8,18}?$
帐号是否合法(字母开头，允许5-16字节，允许字母数字下划线)：^[a-zA-Z][a-zA-Z0-9_]{4,15}$
密码(以字母开头，长度在6~18之间，只能包含字母、数字和下划线)：^[a-zA-Z]\w{5,17}$
强密码(必须包含大小写字母和数字的组合，不能使用特殊字符，长度在8-10之间)：^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,10}$
日期格式：^\d{4}-\d{1,2}-\d{1,2}
一年的12个月(01～09和1～12)：^(0?[1-9]|1[0-2])$
一个月的31天(01～09和1～31)：^((0?[1-9])|((1|2)[0-9])|30|31)$
xml文件：^([a-zA-Z]+-?)+[a-zA-Z0-9]+\\.[x|X][m|M][l|L]$
中文字符的正则表达式：[\u4e00-\u9fa5]
双字节字符：[^\x00-\xff]    (包括汉字在内，可以用来计算字符串的长度(一个双字节字符长度计2，ASCII字符计1))
空白行的正则表达式：\n\s*\r    (可以用来删除空白行)
HTML标记的正则表达式：<(\S*?)[^>]*>.*?</\1>|<.*? />    (网上流传的版本太糟糕，上面这个也仅仅能部分，对于复杂的嵌套标记依旧无能为力)
首尾空白字符的正则表达式：^\s*|\s*$或(^\s*)|(\s*$)    (可以用来删除行首行尾的空白字符(包括空格、制表符、换页符等等)，非常有用的表达式)
腾讯QQ号：[1-9][0-9]{4,}    (腾讯QQ号从10000开始)
中国邮政编码：[1-9]\d{5}(?!\d)    (中国邮政编码为6位数字)
IP地址：\d+\.\d+\.\d+\.\d+    (提取IP地址时有用)
IP地址：((?:(?:25[0-5]|2[0-4]\\d|[01]?\\d?\\d)\\.){3}(?:25[0-5]|2[0-4]\\d|[01]?\\d?\\d))
```

## 钱的输入
```
1.有四种钱的表示形式我们可以接受:"10000.00" 和 "10,000.00", 和没有 "分" 的 "10000" 和 "10,000"：^[1-9][0-9]*$
2.这表示任意一个不以0开头的数字,但是,这也意味着一个字符"0"不通过,所以我们采用下面的形式：^(0|[1-9][0-9]*)$
3.一个0或者一个不以0开头的数字.我们还可以允许开头有一个负号：^(0|-?[1-9][0-9]*)$
4.这表示一个0或者一个可能为负的开头不为0的数字.让用户以0开头好了.把负号的也去掉,因为钱总不能是负的吧.下面我们要加的是说明可能的小数部分：^[0-9]+(.[0-9]+)?$
5.必须说明的是,小数点后面至少应该有1位数,所以"10."是不通过的,但是 "10" 和 "10.2" 是通过的：^[0-9]+(.[0-9]{2})?$
6.这样我们规定小数点后面必须有两位,如果你认为太苛刻了,可以这样：^[0-9]+(.[0-9]{1,2})?$
7.这样就允许用户只写一位小数.下面我们该考虑数字中的逗号了,我们可以这样：^[0-9]{1,3}(,[0-9]{3})*(.[0-9]{1,2})?$
8.1到3个数字,后面跟着任意个 逗号+3个数字,逗号成为可选,而不是必须：^([0-9]+|[0-9]{1,3}(,[0-9]{3})*)(.[0-9]{1,2})?$
备注：这就是最终结果了,别忘了"+"可以用"*"替代如果你觉得空字符串也可以接受的话(奇怪,为什么?)最后,别忘了在用函数时去掉去掉那个反斜杠,一般的错误都在这里
```





