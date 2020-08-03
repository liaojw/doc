# SCSS
## 1. CSS预处理器

* 定义了一种新的专门的编程语言，编译后成正常的CSS文件。为CSS增加一些编程的特性，无需考虑浏览器的兼容问题，让CSS更加简洁，适应性更强，可读性更佳，更易于代码的维护等诸多好处。
* CSS预处理器语言：scss（sass）、LESS等；

## 2.Sass和SCSS的区别

* 文件扩展名不同：“.sass”和“.scss”；
* Sass是以严格缩进式语法规则来书写的，不带大括号和分号；而SCSS的语法和CSS书写语法类似。

## 3.Sass安装（Windows版）

* 先安装ruby：Ruby 的官网（[http://rubyinstaller.org/downloads](https://rubyinstaller.org/downloads/)）下载对应需要的 Ruby 版本
![](https://upload-images.jianshu.io/upload_images/2704790-e2013b530e44f14c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/635)
* 安装sass：
	* 方法一（通过命令安装sass）：打开命令终端，输入：gem install sass
	* 方法二（本地安装sass）：从[http://rubygems.org/gems/sass](http://rubygems.org/gems/sass) 下载sass安装包，然后在终端输入: “gem install <把下载的安装包拖到这里>” 然后直接额回车即可安装成功。

## 4.scss语法格式
css代码：

```
body {
        font: 100% Helvetica, sans-serif;
        color: #333;
    }
```

使用scss代码：

```
$font-stack: Helvetica, sans-serif;
    $primary-color: #333;
    body {
        font: 100% $font-stack;
        color: $primary-color;
    }
```

> tip:如果使用sass旧语法（sass语法），文件后缀名应为“.sass”；如果使用sass新语法（scss语法），文件后缀名应为".scss“语法，否则编译时编译不出来。

## 5. sass编译

### 5.1 sass编译的方法：

* 命令编译
* GUI工具编译
* 自动化编译

#### 5.1.1 sass命令编译（在命令终端输入sass指令来编译sass，最直接，最简单）

* 单文件编译：

```
sass <要编译的Sass文件路径>/style.scss:<要输出CSS文件路径>/style.css
```
* 多文件编译：
	
```
sass sass/:css/
```

上面的命令表示将项目中“sass”文件夹中所有“.scss”(“.sass”)文件编译成“.css”文件，并且将这些 CSS 文件都放在项目中“css”文件夹中。

* 缺点及解决方法：
	* 缺点：每次保存scss文件后都要重新编译太麻烦；
	* 解决方法：开启“watch”功能：

```
sass --watch <要编译的Sass文件路径>/style.scss:<要输出CSS文件路径>/style.css
```

* tip:文件路径不要带中文，如果有中文，watch功能无法正常使用。

## 6.sass嵌套输出方式nested
![](https://upload-images.jianshu.io/upload_images/2704790-8319cb0944a9602f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/488)

只要在编译的时候带上参数“ --style nested”:

```
sass --watch test.scss:test.css --style nested
```

## 7.sass展开输出方式expanded
![](https://upload-images.jianshu.io/upload_images/2704790-4357f5b04ed8c5e8.png?imageMogr2/auto-orient/strip|imageView2/2/w/485)

在编译的时候带上参数“ --style expanded”:

```
sass --watch test.scss:test.css --style expanded
```

## 8.sass展开输出方式compact
![](https://upload-images.jianshu.io/upload_images/2704790-d09e8edeb4ae45ed.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/700)

在编译的时候带上参数“ --style compact”:

```
sass --watch test.scss:test.css --style compact
```
## 9.sass展开输出方式compressed
![](https://upload-images.jianshu.io/upload_images/2704790-837d00eafe8a359b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/666)

在编译的时候带上参数“ --style compressed”:

```
sass --watch test.scss:test.css --style compressed
```

## 10.sass变量声明
$+变量名+：+变量值；

```
$width:200px;
```

## 11.普通变量和默认变量

* 普通变量声明后可以在全局范围内使用；
* 默认变量仅需在值后面加上!default 即可；
* 默认变量一般是用来设置默认值，然后根据需求来覆盖的，覆盖的方式是在默认变量之前重新声明下变量即可。默认变量的价值在进行组件化开发的时候会非常有用。

```
$baseLineHeight: 2;
$baseLineHeight: 1.5 !default;
body {
       line-height: $baseLineHeight;
}
```

编译后的CSS代码：

```
body {
	line-height:2;
}
```

## 12.局部变量和全局变量

* 局部变量：在元素里面声明的变量;
* 全局变量：在元素外面定义的变量；
* 全局变量的影子：和全局变量名字相同的局部变量叫做全局变量的影子。

```
$color:green;//全局变量
$width:200px;//全局变量
$height:200px;//全局变量
body {
    background-color:$color;//调用全局变量
}
div {
    $color:yellow;//定义局部变量，全局变量$color的影子
    .div {
    background-color:$color;//调用局部变量
    width:$width;//调用全局变量
    height:$height;//调用全局变量
    }
}
```

## 13.sass嵌套
### 13.1 选择器嵌套

```
<header>
    <nav>
        <a href="#">home</a>
        <a href="#">page</a>
    </nav>
</header>
```

css:

```
nav a {
        color:red;
    }
    header nav a {
        color:green;
    }
```

scss:

```
nav {
  a {
    color: red;
    
    header & {
      color:green;
    }
  }  
}
```

### 13.2 属性嵌套(有相同的属性前缀)
css:

```
.box {
     font-size: 12px;
     font-weight: bold;
}
```

scss:

```
.box {
  font: {
   size: 12px;
   weight: bold;
  }  
}
```

### 13.3 伪类嵌套
scss:

```
.clearfix{
&:before,
&:after {
    content:"";
    display: table;
  }
&:after {
    clear:both;
    overflow: hidden;
  }
}
```

css:

```
clearfix:before, .clearfix:after {
  content: "";
  display: table;
}
.clearfix:after {
  clear: both;
  overflow: hidden;
}
```

## 14. sass混合宏

### 14.1 声明混合宏

```
@mixin border-radius {
    -webkit-border-radius: 5px;
    border-radius: 5px;
}
```

@mixin :声明混合宏的关键词；
border-radius:混合宏的名称；
大括号内：复用的样式代码；

### 14.2 调用混合宏

```
@mixin border-radius{
    -webkit-border-radius: 3px;
    border-radius: 3px;
}//声明混合宏border-radius
button {
    @include border-radius;
}//调用混合宏border-radius
```

编译为CSS：

```
button {
  -webkit-border-radius: 3px;
  border-radius: 3px;
}
```

### 14.3 混合宏的参数

* 不带任何值的参数

```
@mixin border-radius($radius){
  -webkit-border-radius: $radius;
  border-radius: $radius;
}//声明一个带有参数$radius的混合宏
.box {
  @include border-radius(3px);//调用混合宏并给混合宏传参数“3px”
}
```

* 传一个带值参数（传入一个默认值）

```
@mixin border-radius($radius:3px){
  -webkit-border-radius: $radius;
  border-radius: $radius;
}//声明一个传入了默认参数值的混合宏
.btn {
  @include border-radius;//使用默认参数值的混合宏
}
.box { 
  @include border-radius(50%);//可以自己传入参数值
}
```

编译出来的CSS：

```
.btn {
  -webkit-border-radius: 3px;
  border-radius: 3px;
}
.box {
  -webkit-border-radius: 50%;
  border-radius: 50%;
}

```

* 传多个参数值

```
@mixin size($width,$height){
  width: $width;
  height: $height;
}
.box-center {
  @include size(500px,300px);
}
```

编译出来的css：

```
.box-center {
  width: 500px;
  height: 300px;
}
```

## 15.sass 继承
scss：

```
.btn {
  border: 1px solid #ccc;
  padding: 6px 10px;
  font-size: 14px;
}
.btn-primary {
  background-color: #f36;
  color: #fff;
  @extend .btn;
}
```

编译出来后：

```
.btn, .btn-primary {
  border: 1px solid #ccc;
  padding: 6px 10px;
  font-size: 14px;
 }
.btn-primary {
  background-color: #f36;
  color: #fff; 
}
```
> 在sass中的继承，可以继承类样式块中所有样式代码，而且编译出来的css会将选择器合并在一起，形成组合选择器。

## 16.sass占位符%
用占位符声明的代码，如果不被@extend调用就不会被编译。

```
%mt5 {
  margin-top: 5px;
}
%pt5{
  padding-top: 5px;
}
.btn {
  color:red;
}
```

编译后：

```
.btn {
    color:red;
}//%占位符声明的代码没有被编译产生css代码
```

使用@extend调用：

```
%mt5 {
  margin-top: 5px;
}
%pt5{
  padding-top: 5px;
}
.btn {
  @extend %mt5;//使用@extend调用占位符代码
  @extend %pt5;
}
.block {
  @extend %mt5;
  span {
    @extend %pt5;
  }
}
```

编译后的css代码：

```
.btn, .block {
  margin-top: 5px;
}
.btn, .block span {
  padding-top: 5px;
}
```

> 通过@extend调用的占位符，编译出来的代码会将相同的代码合并在一起，代码变得十分简洁。

## 17.sass插值

```
$properties: (margin, padding);
@mixin set-value($side, $value) {
    @each $prop in $properties {//对每个在$properties中的$prop,即$properties中的margin、padding
        #{$prop}-#{$side}: $value;//$prop连接参数$side，值为参数$value
    }
}
.login-box {
    @include set-value(top, 14px);//调用混合宏
}
```
编译出来的css：

```
.login-box {
  margin-top: 14px;
  padding-top: 14px; 
}
```

不可以：

```
$margin-big: 40px;
$margin-medium: 20px;
$margin-small: 12px;
@mixin set-value($size) {
    margin-top: $margin-#{$size};
}
.login-box {
    @include set-value(big);
}
```

也不可以：

```
@mixin updated-status {
    margin-top: 20px;
    background: #F00;
}
$flag: "status";
.navigation {
    @include updated-#{$flag};
}
```

可以在使用@extend时使用插值：

```
%updated-status {
    margin-top: 20px;
    background: #F00;
}
.selected-status {
    font-weight: bold;
}
$flag: "status";
.navigation {
    @extend %updated-#{$flag};
    @extend .selected-#{$flag};
}
```

## 18. sass 注释

* /*注释内容*/ :会在编译出来的css文件中显示
* //注释内容 ：不会在编译出来的css文件中显示

```
//定义一个占位符
%mt5 {
  margin-top: 5px;
}
/*调用一个占位符*/
.box {
  @extend %mt5;
}
```

编译出来的css：

```
.box {
  margin-top: 5px;
}
/*调用一个占位符*/
```

## 19. sass运算

### 19.1 sass 加法/减法
变量或属性中都可以做加法/减法运算

```
.box {
  width: 20px + 8in;
  height:20px - 5px;
}
```

编译出来的css：

```
.box {
  width: 788px;
  height:25px;
}
```

不用类型的单位做加法/减法会报错：

```
.box {
  width: 20px + 1em;//不同类型单位不能做加法
}
```
### 19.2 sass 乘法
这样子会有问题：

```
.box {
  width:10px * 2px;  
}
```

应该这样子：

```
.box {
  width: 10px * 2;
}
```

编译出来的css：

```
.box {
  width: 20px;
}
```

* 同加法减法一样，不同类型单位做乘法也会报错。

### 19.3 sass除法

* 如果除式中没有变量或者不是在一个数学表达式中（有加法减法等），就要将除式运算用小括号括起来，否则“/”不会被当做除号运算。

```
p {
  font: 10px/8px;             // 纯 CSS，不是除法运算
  $width: 1000px;
  width: $width/2;            // 使用了变量，是除法运算
  width: round(1.5)/2;        // 使用了函数，是除法运算
  height: (500px/2);          // 使用了圆括号，是除法运算
  margin-left: 5px + 8px/2px; // 使用了加（+）号，是除法运算
}
```

编译出来的css：

```
p {
  font: 10px/8px;//这种是无意义的css
  width: 500px;
  height: 250px;
  margin-left: 9px;
 }
```

* 除法中相同单位相除不会报错，会产生一个无单位的值：

```
.box {
  width: (1000px / 100px);
}
```

编译出来的css：

```
.box {
  width: 10;
}
```

### 19.4 sass 变量计算

```
$content-width: 720px;
$sidebar-width: 220px;
$gutter: 20px;
.container {
  width: $content-width + $sidebar-width + $gutter;
}
```

编译出来的css：

```
.container {
  width: 960px;
}
```

### 19.5 sass数字运算

```
.box {
  width: ((220px + 720px) - 11 * 20 ) / 12 ;  
}
```

编译出来的css：

```
.box {
  width: 60px;
}
```

### 19.6 sass颜色运算
所有算术运算都支持颜色值，并且是分段计算的。

```
p {
  color: #010203 + #040506;
}
```

计算公式为 01 + 04 = 05、02 + 05 = 07 和 03 + 06 = 09， 并且被合成为：

```
p {
  color: #050709;
}
```

* 数字和颜色一起运算：

```
p {
  color: #010203 * 2;
}
```

计算公式为 01 * 2 = 02、02 * 2 = 04 和 03 * 2 = 06， 并且被合成为：

```
p {
  color: #020406;
}
```

### 19.7 sass 字符运算
* 用“+”对字符串进行连接：

```
$content: "Hello" + "" + "Sass!";
.box:before {
  content: " #{$content} ";
}
```

编译出来的css：

```
.box:before {
  content: " Hello Sass! ";
}
```

* 可以使用“+”直接连接字符：

```
div {
  cursor: e + -resize;
}
```

编译出来的css：

```
div {
  cursor: e-resize;
}
```

* 有引号的字符串和没有引号的字符串相加，看哪个在“+”号的左边，如果有引号的在左边，结果为有引号的；如果没有引号的在左边，结果为没有引号的：

```
p:before {
  content: "Foo " + Bar;
  font-family: sans- + "serif";
}
```

编译出来的css：

```
p:before {
  content: "Foo Bar";
  font-family: sans-serif; }
```



 
