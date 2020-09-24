# [Grid布局完全指南](https://www.html.cn/archives/8510)

CSS Grid 布局是 CSS 中最强大的布局系统。与 flexbox 的一维布局系统不同，CSS Grid 布局是一个二维布局系统，也就意味着它可以同时处理列和行。通过将 CSS 规则应用于 **父元素** (成为 Grid Container 网格容器)和其 **子元素**（成为 Grid Items 网格项），你就可以轻松使用 Grid(网格) 布局。

## 简介

CSS Grid(网格) 布局（又称为 “Grid(网格)” ），是一个二维的基于网格的布局系统，它的目标是完全改变我们基于网格的用户界面的布局方式。CSS 一直用来布局我们的网页，但一直以来都存在这样或那样的问题。一开始我们用表格（table），然后是浮动（float），再是定位（postion）和内嵌块（inline-block），但是所有这些方法本质上都是只是 hack 而已，并且遗漏了很多重要的功能（例如垂直居中）。Flexbox 的出现很大程度上改善了我们的布局方式，但它的目的是为了解决更简单的一维布局，而不是复杂的二维布局（实际上 Flexbox 和 Grid 能协同工作，而且配合得非常好）。Grid(网格) 布局是第一个专门为解决布局问题而创建的 CSS 模块，只要我们一直在制作网站，我们就一直要讨论这些问题。

有两个主要因素激发了我创建本指南的灵感。第一个是 Rachel Andrew 出色的书籍 [为 CSS Grid 布局做好准备](http://abookapart.com/products/get-ready-for-css-grid-layout)。这本书对 Grid 布局做了全面，清晰的介绍 ，也是本指南的基础。我强烈建议你购买并阅读。另一个灵感来自 Chris Coyier 的 [Flexbox 布局完整指南](https://www.html.cn/archives/8629)，这也是我学习 flexbox 首选的资源。这篇文章是帮助了很多人，这点从 Google “flexbox” 排名第一就可以看出来。你会发现那篇文章和我的文章有很多相似之处，为什么不跟随最好的文章呢？

本指南的目的是介绍存在于最新版本的规范中 Grid(网格) 概念。所以我不会覆盖过时的 IE 语法，而且随着规范的逐渐成熟，我会尽我最大的努力去更新这个指南。

## 基础知识和浏览器支持

首先，你必须使用 [`display: grid`](https://www.html.cn/archives/8510#prop-display) 将容器元素定义为一个 grid(网格) 布局，使用 [`grid-template-columns`](https://www.html.cn/archives/8510#prop-grid-template-columns-rows) 和 [`grid-template-rows`](https://www.html.cn/archives/8510#prop-grid-template-columns-rows) 设置 列 和 行 的尺寸大小，然后通过 [`grid-column`](https://www.html.cn/archives/8510#prop-grid-column-row) 和 [`grid-row`](https://www.html.cn/archives/8510#prop-grid-column-row) 将其子元素放入这个 grid(网格) 中。与 flexbox 类似，网格项（grid items）的源(HTML结构)顺序无关紧要。你的 CSS 可以以任何顺序放置它们，这使得使用 媒体查询（media queries）重新排列网格变得非常容易。定义整个页面的布局，然后完全重新排列布局以适应不同的屏幕宽度，这些都只需要几行 CSS ，想象一下就让人兴奋。Grid(网格) 布局是有史以来最强大的 CSS 模块之一。

截至2017年3月，许多浏览器都提供了对 CSS Grid 的原生支持，而且无需加浏览器前缀：Chrome（包括 Android ），Firefox，Edge，Safari（包括iOS）和 Opera 。 另一方面，Internet Explorer 10和11支持它，但是是一个过时的语法实现。 现在是时候使用 Grid 布局网页了！

这个浏览器支持 CSS Grid 的数据，来自 [Caniuse](http://caniuse.com/#feat=css-grid) ，你可以查看更多的细节。 数字表示支持以上功能的浏览器版本号。

### 桌面(Desktop) 浏览器

| Chrome | Opera | Firefox |     IE      | Edge | Safari |
| :----: | :---: | :-----: | :---------: | :--: | :----: |
|   57   |  44   |   52    | 11*(旧语法) |  16  |  10.1  |

### 手机(Mobile) / 平板(Tablet)浏览器

| iOS Safari | Opera Mobile | Opera Mini | Android | Android Chrome | Android Firefox |
| :--------: | :----------: | :--------: | :-----: | :------------: | :-------------: |
|    10.3    |      46      |     No     |   67    |       70       |       63        |

除了微软之外，浏览器厂商似乎还没有对 Grid(网格) 搞自己的一套实现（比如加前缀），直到规范完全成熟。这是一件好事，因为这意味着我们不必担心学习多个语法。

在生产中使用 Grid 只是时间问题。 但现在是学习的时候了。

## 重要术语

在深入了解 Grid 的概念之前，理解术语是很重要的。由于这里涉及的术语在概念上都很相似，如果不先记住 Grid 规范定义的含义，很容易混淆它们。但是别担心，术语并不多。

### 网格容器(Grid Container)

应用 `display: grid` 的元素。这是所有 网格项（grid item）的直接父级元素。在这个例子中，`container` 就是 **网格容器(Grid Container)**。

HTML 代码:

```HTML
<div class="container">  <div class="item item-1"></div>  <div class="item item-2"></div>  <div class="item item-3"></div></div>
```

### 网格项(Grid Item)

网格容器（Grid Container）的子元素（例如直接子元素）。这里 `item` 元素就是网格项(Grid Item)，但是 `sub-item` 不是。

HTML 代码:

```HTML
<div class="container">  <div class="item"></div>   <div class="item">    <p class="sub-item"></p>  </div>  <div class="item"></div></div>
```

### 网格线(Grid Line)

构成网格结构的分界线。它们既可以是垂直的（“列网格线(column grid lines)”），也可以是水平的（“行网格线(row grid lines)”），并位于行或列的任一侧。例如，这里的黄线就是一条列网格线。

![网格线(Grid Line)](https://www.html.cn/newimg88/2018/12/terms-grid-line.svg)

### 网格轨道(Grid Track)

两条相邻网格线之间的空间。你可以把它们想象成网格的列或行。下图是第二条和第三条 行网格线 之间的 网格轨道(Grid Track)。

![网格轨道(Grid Track)](https://www.html.cn/newimg88/2018/12/terms-grid-track.svg)

### 网格单元格(Grid Cell)

两个相邻的行和两个相邻的列网格线之间的空间。这是 Grid(网格) 系统的一个“单元”。下图是第 1 至第 2 条 行网格线 和第 2 至第 3 条 列网格线 交汇构成的 网格单元格(Grid Cell)。

![网格单元格(Grid Cell)](https://www.html.cn/newimg88/2018/12/terms-grid-cell.svg)

### 网格区域(Grid Area)

4条网格线包围的总空间。一个 网格区域(Grid Area) 可以由任意数量的 网格单元格(Grid Cell) 组成。下图是 行网格线1和3，以及列网格线1和3 之间的网格区域。

![网格区域(Grid Area)](https://www.html.cn/newimg88/2018/12/terms-grid-area.svg)

## Grid(网格) 属性目录

### 网格容器(Grid Container) 属性

- [display](https://www.html.cn/archives/8510#prop-display)
- [grid-template-columns](https://www.html.cn/archives/8510#prop-grid-template-columns-rows)
- [grid-template-rows](https://www.html.cn/archives/8510#prop-grid-template-columns-rows)
- [grid-template-areas](https://www.html.cn/archives/8510#prop-grid-template-areas)
- [grid-template](https://www.html.cn/archives/8510#prop-grid-template)
- [grid-column-gap](https://www.html.cn/archives/8510#prop-grid-column-row-gap)
- [grid-row-gap](https://www.html.cn/archives/8510#prop-grid-column-row-gap)
- [grid-gap](https://www.html.cn/archives/8510#prop-grid-gap)
- [justify-items](https://www.html.cn/archives/8510#prop-justify-items)
- [align-items](https://www.html.cn/archives/8510#prop-align-items)
- [place-items](https://www.html.cn/archives/8510#prop-place-items)
- [justify-content](https://www.html.cn/archives/8510#prop-justify-content)
- [align-content](https://www.html.cn/archives/8510#prop-align-content)
- [place-content](https://www.html.cn/archives/8510#prop-place-content)
- [grid-auto-columns](https://www.html.cn/archives/8510#prop-grid-auto-columns-rows)
- [grid-auto-rows](https://www.html.cn/archives/8510#prop-grid-auto-columns-rows)
- [grid-auto-flow](https://www.html.cn/archives/8510#prop-grid-auto-flow)
- [grid](https://www.html.cn/archives/8510#prop-grid)

### 网格项(Grid Items) 属性

- [grid-column-start](https://www.html.cn/archives/8510#prop-grid-column-row-start-end)
- [grid-column-end](https://www.html.cn/archives/8510#prop-grid-column-row-start-end)
- [grid-row-start](https://www.html.cn/archives/8510#prop-grid-column-row-start-end)
- [grid-row-end](https://www.html.cn/archives/8510#prop-grid-column-row-start-end)
- [grid-column](https://www.html.cn/archives/8510#prop-grid-column-row)
- [grid-row](https://www.html.cn/archives/8510#prop-grid-column-row)
- [grid-area](https://www.html.cn/archives/8510#prop-grid-area)
- [justify-self](https://www.html.cn/archives/8510#prop-justify-self)
- [align-self](https://www.html.cn/archives/8510#prop-align-self)
- [place-self](https://www.html.cn/archives/8510#prop-place-self)

## 父元素 网格容器(Grid Container) 属性

### display

将元素定义为网格容器，并为其内容建立新的 *网格格式上下文*。

值：

- `grid` ：生成一个块级网格
- `inline-grid` ：生成一个内联网格

CSS 代码:

```CSS
.container {  display: grid | inline-grid;}
```

注意：通过嵌套元素（也称为子网格，即 subgrid ）向下传递网格参数的能力已移至 [CSS Grid 规范的 Level 2 版本](https://www.w3.org/TR/css-grid-2/#subgrids)。这里有 [一个快速解释](https://css-tricks.com/grid-level-2-and-subgrid/)。

[回到目录](https://www.html.cn/archives/8510#table-of-contents)

### grid-template-columns / grid-template-rows

使用空格分隔的值列表，用来定义网格的列和行。这些值表示 网格轨道(Grid Track) 大小，它们之间的空格表示网格线。

值：
– `<track-size>`： 可以是长度值，百分比，或者等份网格容器中可用空间（使用 `fr` 单位）
– `<line-name>`：你可以选择的任意名称

CSS 代码:

```CSS
.container {  grid-template-columns: <track-size> ... | <line-name> <track-size> ...;  grid-template-rows: <track-size> ... | <line-name> <track-size> ...;}
```

示例：

当你在 网格轨道(Grid Track) 值之间留出空格时，网格线会自动分配正数和负数名称：

CSS 代码:

```CSS
.container {  grid-template-columns: 40px 50px auto 50px 40px;  grid-template-rows: 25% 100px auto;}
```

![网格线名称](https://www.html.cn/newimg88/2018/12/template-columns-rows-01.svg)

但是你可以明确的指定网格线(Grid Line)名称，例如 <line-name> 值。请注意网格线名称的括号语法：

CSS 代码:

```CSS
.container {  grid-template-columns: [first] 40px [line2] 50px [line3] auto [col4-start] 50px [five] 40px [end];  grid-template-rows: [row1-start] 25% [row1-end] 100px [third-line] auto [last-line];}
```

![网格线多个名称](https://www.html.cn/newimg88/2018/12/template-column-rows-02.svg)

请注意，一条网格线(Grid Line)可以有多个名称。例如，这里的第二条 行网格线(row grid lines) 将有两个名字：row1-end 和 row2-start ：

CSS 代码:

```CSS
.container {  grid-template-rows: [row1-start] 25% [row1-end row2-start] 25% [row2-end];}
```

如果你的定义包含多个重复值，则可以使用 `repeat()` 表示法来简化定义：

CSS 代码:

```CSS
.container {  grid-template-columns: repeat(3, 20px [col-start]);}
```

上面的代码等价于：

CSS 代码:

```CSS
.container {  grid-template-columns: 20px [col-start] 20px [col-start] 20px [col-start];}
```

如果多行共享相同的名称，则可以通过其网格线名称和计数来引用它们。

CSS 代码:

```CSS
.item {  grid-column-start: col-start 2;}
```

`fr` 单元允许你用等分网格容器剩余可用空间来设置 网格轨道(Grid Track) 的大小 。例如，下面的代码会将每个网格项设置为网格容器宽度的三分之一：

CSS 代码:

```CSS
.container {  grid-template-columns: 1fr 1fr 1fr;}
```

剩余可用空间是除去所有非灵活网格项 **之后** 计算得到的。在这个例子中，可用空间总量减去 50px 后，再给 `fr` 单元的值 3 等分：

CSS 代码:

```CSS
.container {  grid-template-columns: 1fr 50px 1fr 1fr;}
```

[回到目录](https://www.html.cn/archives/8510#table-of-contents)

### grid-template-areas

通过引用 [`grid-area`](https://www.html.cn/archives/8510#prop-grid-area) 属性指定的 网格区域(Grid Area) 名称来定义网格模板。重复网格区域的名称导致内容跨越这些单元格。一个点号（`.`）代表一个空单元格。这个语法本身可视作网格的可视化结构。

值：

- `<grid-area-name>`：由网格项的 [`grid-area`](https://www.html.cn/archives/8510#prop-grid-area) 指定的网格区域名称
- `.`（点号） ：代表一个空的网格单元
- `none`：不定义网格区域

CSS 代码:

```CSS
.container {  grid-template-areas:     "<grid-area-name> | . | none | ..."    "...";}
```

示例：

CSS 代码:

```CSS
.item-a {  grid-area: header;}.item-b {  grid-area: main;}.item-c {  grid-area: sidebar;}.item-d {  grid-area: footer;} .container {  grid-template-columns: 50px 50px 50px 50px;  grid-template-rows: auto;  grid-template-areas:     "header header header header"    "main main . sidebar"    "footer footer footer footer";}
```

上面的代码将创建一个 4 列宽 3 行高的网格。整个顶行将由 **header** 区域组成。中间一排将由两个 **main** 区域，一个是空单元格，一个 **sidebar** 区域组成。最后一行全是 **footer** 区域组成。

![网格区域名称模板](https://www.html.cn/newimg88/2018/12/dddgrid-template-areas.svg)

你的声明中的每一行都需要有相同数量的单元格。

你可以使用任意数量的相邻的 点`.` 来声明单个空单元格。 只要这些点`.`之间没有空隙隔开，他们就代表一个单独的单元格。

注意你 **不能** 用这个语法来命名网格线，只是命名 **网格区域** 。当你使用这种语法时，区域两端的网格线实际上会自动命名。如果你的网格区域的名字是 **foo**，该区域的起始行网格线 和 起始列网格线 的名称将为 **foo-start**，而最后一条行网格线 和 最后一条列网格线 的名称将为 **foo-end**。这意味着某些网格线可能有多个名字，如上例中最左边的网格线，它将有三个名称：header-start，main-start 和 footer-start 。

[回到目录](https://www.html.cn/archives/8510#table-of-contents)

### grid-template

用于定义 [`grid-template-rows`](https://www.html.cn/archives/8510#prop-grid-template-columns-rows) ，[`grid-template-columns`](https://www.html.cn/archives/8510#prop-grid-template-columns-rows) ，[`grid-template-areas`](https://www.html.cn/archives/8510#prop-grid-template-areas) 简写属性。

值：

- `none`：将所有三个属性设置为其初始值
- `<grid-template-rows> / <grid-template-columns>`：将 [`grid-template-columns`](https://www.html.cn/archives/8510#prop-grid-template-columns-rows) 和 [`grid-template-rows`](https://www.html.cn/archives/8510#prop-grid-template-columns-rows) 设置为相应地特定的值，并且设置[`grid-template-areas`](https://www.html.cn/archives/8510#prop-grid-template-areas)为`none`

CSS 代码:

```CSS
.container {  grid-template: none | <grid-template-rows> / <grid-template-columns>;}
```

这个属性也接受一个更复杂但非常方便的语法来指定三个上诉属性。这里有一个例子：

CSS 代码:

```CSS
.container {  grid-template:    [row1-start] "header header header" 25px [row1-end]    [row2-start] "footer footer footer" 25px [row2-end]    / auto 50px auto;}
```

等价于：

CSS 代码:

```CSS
.container {  grid-template-rows: [row1-start] 25px [row1-end row2-start] 25px [row2-end];  grid-template-columns: auto 50px auto;  grid-template-areas:     "header header header"     "footer footer footer";}
```

由于 [`grid-template`](https://www.html.cn/archives/8510#prop-grid-template) 不会重置 *隐式* 网格属性（[`grid-auto-columns`](https://www.html.cn/archives/8510#prop-grid-auto-columns-rows)， [`grid-auto-rows`](https://www.html.cn/archives/8510#prop-grid-auto-columns-rows)， 和 [`grid-auto-flow`](https://www.html.cn/archives/8510#prop-grid-auto-flow)），
这可能是你想在大多数情况下做的，建议使用 [`grid`](https://www.html.cn/archives/8510#prop-grid) 属性而不是 [`grid-template`](https://www.html.cn/archives/8510#prop-grid-template)。

[回到目录](https://www.html.cn/archives/8510#table-of-contents)

### grid-column-gap / grid-row-gap

指定网格线(grid lines)的大小。你可以把它想象为设置列/行之间间距的宽度。

值：

- `<line-size>` ：长度值

CSS 代码:

```CSS
.container {  grid-column-gap: <line-size>;  grid-row-gap: <line-size>;}
```

示例：

CSS 代码:

```CSS
.container {  grid-template-columns: 100px 50px 100px;  grid-template-rows: 80px auto 80px;   grid-column-gap: 10px;  grid-row-gap: 15px;}
```

![网格单元间距](https://www.html.cn/newimg88/2018/12/dddgrid-gap.svg)

只能在 列/行 之间创建间距，网格外部边缘不会有这个间距。

注意：这两个属性将删除 `grid-` 前缀，就是将 `grid-column-gap` 和 `grid-row-gap`重命名为 `column-gap` 和 `row-gap`。 Chrome 68+，Safari 11.2 Release 50+ 和Opera 54+ 已经支持无前缀的属性。

[回到目录](https://www.html.cn/archives/8510#table-of-contents)

### grid-gap

[`grid-column-gap`](https://www.html.cn/archives/8510#prop-grid-column-row-gap) 和 [`grid-row-gap`](https://www.html.cn/archives/8510#prop-grid-column-row-gap) 的简写语法

值：

- `<grid-row-gap> <grid-column-gap>`：长度值

CSS 代码:

```CSS
.container {  grid-gap: <grid-row-gap> <grid-column-gap>;}
```

示例：

CSS 代码:

```CSS
.container {  grid-template-columns: 100px 50px 100px;  grid-template-rows: 80px auto 80px;   grid-gap: 15px 10px;}
```

如果[`grid-row-gap`](https://www.html.cn/archives/8510#prop-grid-column-row-gap)没有定义，那么就会被设置为等同于 [`grid-column-gap`](https://www.html.cn/archives/8510#prop-grid-column-row-gap) 的值。例如下面的代码是等价的：

CSS 代码:

```CSS
.container{  /* 设置 grid-column-gap 和 grid-row-gap */    grid-column-gap: 10px;  grid-row-gap: 10px;    /* 等价于 */    grid-gap: 10px 10px;   /* 等价于 */    grid-gap: 10px;}
```

注意：这个属性将删除 `grid-` 前缀，就是将 `grid-gap` 重命名为 `gap`。 Chrome 68+，Safari 11.2 Release 50+ 和Opera 54+ 已经支持无前缀的属性。

[回到目录](https://www.html.cn/archives/8510#table-of-contents)

### justify-items

沿着 *inline*（行）轴线对齐网格项(grid items)（相反的属性是 [`align-items`](https://www.html.cn/archives/8510#prop-align-items) 沿着 *block*（列）轴线对齐）。此值适用于容器内的所有网格项。

值：

- `start`：将网格项对齐到其单元格的左侧起始边缘（左侧对齐）
- `end`：将网格项对齐到其单元格的右侧结束边缘（右侧对齐）
- `center`：将网格项对齐到其单元格的水平中间位置（水平居中对齐）
- `stretch`：填满单元格的宽度（默认值）

CSS 代码:

```CSS
.container {  justify-items: start | end | center | stretch;}
```

示例：

CSS 代码:

```CSS
.container {  justify-items: start;} 
```

![左对齐，justify-items 设置为 start 的例子](https://www.html.cn/newimg88/2018/12/justify-items-start.svg)

CSS 代码:

```CSS
.container{  justify-items: end;}
```

![右对齐，justify-items 设置为 end 的例子](https://www.html.cn/newimg88/2018/12/justify-items-end.svg)

CSS 代码:

```CSS
.container{  justify-items: center;}
```

![水平居中对齐，justify-items 设置为 center 的例子](https://www.html.cn/newimg88/2018/12/justify-items-center.svg)

CSS 代码:

```CSS
.container{  justify-items: stretch;}
```

![拉伸，justify-items 设置为 stretch 的例子](https://www.html.cn/newimg88/2018/12/justify-items-stretch.svg)

这些行为也可以通过每个单独网格项(grid items) 的 [`justify-self`](https://www.html.cn/archives/8510#prop-justify-self) 属性设置。

[回到目录](https://www.html.cn/archives/8510#table-of-contents)

### align-items

沿着 *block*（列）轴线对齐网格项(grid items)（相反的属性是 [`justify-items`](https://www.html.cn/archives/8510#prop-justify-items) 沿着 *inline*（行）轴线对齐）。此值适用于容器内的所有网格项。

值：

- `start`：将网格项对齐到其单元格的顶部起始边缘（顶部对齐）
- `end`：将网格项对齐到其单元格的底部结束边缘（底部对齐）
- `center`：将网格项对齐到其单元格的垂直中间位置（垂直居中对齐）
- `stretch`：填满单元格的高度（默认值）

CSS 代码:

```CSS
.container {  align-items: start | end | center | stretch;}
```

示例：

CSS 代码:

```CSS
.container {  align-items: start;}
```

![顶部对齐，align-items 设置为 start 的例子](https://www.html.cn/newimg88/2018/12/align-items-start.svg)

CSS 代码:

```CSS
.container {  align-items: end;}
```

![底部对齐，align-items 设置为 end 的例子](https://www.html.cn/newimg88/2018/12/align-items-end.svg)

CSS 代码:

```CSS
.container {  align-items: center;}
```

![垂直居中对齐，align-items 设置为 center 的例子](https://www.html.cn/newimg88/2018/12/align-items-center.svg)

CSS 代码:

```CSS
.container {  align-items: stretch;}
```

![拉伸，align-items 设置为 stretch 的例子](https://www.html.cn/newimg88/2018/12/align-items-stretch.svg)

这些行为也可以通过每个单独网格项(grid items) 的 [`align-self`](https://www.html.cn/archives/8510#prop-align-self) 属性设置。

[回到目录](https://www.html.cn/archives/8510#table-of-contents)

### place-items

`place-items` 是设置 `align-items` 和 `justify-items` 的简写形式。

值：

- `<align-items> <justify-items>`：第一个值设置 `align-items` 属性，第二个值设置 `justify-items` 属性。如果省略第二个值，则将第一个值同时分配给这两个属性。

除 Edge 之外的所有主要浏览器都支持 `place-items` 简写属性。

有关更多详细信息，请参阅[`align-items`](https://www.html.cn/archives/8510#prop-align-items) 和 [`justify-items`](https://www.html.cn/archives/8510#prop-justify-items)。

[回到目录](https://www.html.cn/archives/8510#table-of-contents)

### justify-content

有时，你的网格合计大小可能小于其 网格容器(grid container) 大小。 如果你的所有 网格项(grid items) 都使用像 `px` 这样的非灵活单位设置大小，就可能出现这种情况。在这种情况下，您可以设置网格容器内的网格的对齐方式。 此属性沿着 *inline*（行）轴线对齐网格（相反的属性是 [`align-content`](https://www.html.cn/archives/8510#prop-align-content) ，沿着 *block*（列）轴线对齐网格）。

值：

- `start`：将网格对齐到 网格容器(grid container) 的左侧起始边缘（左侧对齐）
- `end`：将网格对齐到 网格容器 的右侧结束边缘（右侧对齐）
- `center`：将网格对齐到 网格容器 的水平中间位置（水平居中对齐）
- `stretch`：调整 网格项(grid items) 的宽度，允许该网格填充满整个 网格容器 的宽度
- `space-around`：在每个网格项之间放置一个均匀的空间，左右两端放置一半的空间
- `space-between`：在每个网格项之间放置一个均匀的空间，左右两端没有空间
- `space-evenly`：在每个网格项目之间放置一个均匀的空间，左右两端放置一个均匀的空间

CSS 代码:

```CSS
.container {  justify-content: start | end | center | stretch | space-around | space-between | space-evenly;    }
```

示例：

CSS 代码:

```CSS
.container {  justify-content: start;}
```

![左侧对齐，justify-content 设置为 start 的例子](https://www.html.cn/newimg88/2018/12/justify-content-start.svg)

CSS 代码:

```CSS
.container {  justify-content: end;}
```

![右侧对齐，justify-content 设置为 end 的例子](https://www.html.cn/newimg88/2018/12/justify-content-end.svg)

CSS 代码:

```CSS
.container {  justify-content: center;}
```

![水平居中对齐，justify-content 设置为 center 的例子](https://www.html.cn/newimg88/2018/12/justify-content-center.svg)

CSS 代码:

```CSS
.container {  justify-content: stretch;}
```

![拉伸，justify-content 设置为 stretch 的例子](https://www.html.cn/newimg88/2018/12/justify-content-stretch.svg)

CSS 代码:

```CSS
.container {  justify-content: space-around;}
```

![justify-content 设置为 space-around 的例子](https://www.html.cn/newimg88/2018/12/justify-content-space-around.svg)

CSS 代码:

```CSS
.container {  justify-content: space-between;}
```

![justify-content 设置为 space-between 的例子](https://www.html.cn/newimg88/2018/12/justify-content-space-between.svg)

CSS 代码:

```CSS
.container {  justify-content: space-evenly;}
```

![justify-content 设置为 space-evenly 的例子](https://www.html.cn/newimg88/2018/12/justify-content-space-evenly.svg)

[回到目录](https://www.html.cn/archives/8510#table-of-contents)

### align-content

有时，你的网格合计大小可能小于其 网格容器(grid container) 大小。 如果你的所有 网格项(grid items) 都使用像 `px` 这样的非灵活单位设置大小，就可能出现这种情况。在这种情况下，您可以设置网格容器内的网格的对齐方式。 此属性沿着 *block*（列）轴线对齐网格（相反的属性是 [`justify-content`](https://www.html.cn/archives/8510#prop-justify-content) ，沿着 *inline*（行）轴线对齐网格）。

值：

- `start`：将网格对齐到 网格容器(grid container) 的顶部起始边缘（顶部对齐）
- `end`：将网格对齐到 网格容器 的底部结束边缘（底部对齐）
- `center`：将网格对齐到 网格容器 的垂直中间位置（垂直居中对齐）
- `stretch`：调整 网格项(grid items) 的高度，允许该网格填充满整个 网格容器 的高度
- `space-around`：在每个网格项之间放置一个均匀的空间，上下两端放置一半的空间
- `space-between`：在每个网格项之间放置一个均匀的空间，上下两端没有空间
- `space-evenly`：在每个网格项目之间放置一个均匀的空间，上下两端放置一个均匀的空间

CSS 代码:

```CSS
.container {  align-content: start | end | center | stretch | space-around | space-between | space-evenly;  }
```

示例：

CSS 代码:

```CSS
.container {  align-content: start; }
```

![顶部对齐，align-content 设置为 start 的例子](https://www.html.cn/newimg88/2018/12/align-content-start.svg)

CSS 代码:

```CSS
.container {  align-content: end;   }
```

![底部对齐，align-content 设置为 end 的例子](https://www.html.cn/newimg88/2018/12/align-content-end.svg)

CSS 代码:

```CSS
.container {  align-content: center;    }
```

![垂直居中对齐，align-content 设置为 center 的例子](https://www.html.cn/newimg88/2018/12/align-content-center.svg)

CSS 代码:

```CSS
.container {  align-content: stretch;   }
```

![拉伸，align-content 设置为 stretch 的例子](https://www.html.cn/newimg88/2018/12/align-content-stretch.svg)

CSS 代码:

```CSS
 .container {  align-content: space-around;  }
```

![align-content 设置为 space-around 的例子](https://www.html.cn/newimg88/2018/12/align-content-space-around.svg)

CSS 代码:

```CSS
.container {  align-content: space-between; }
```

![align-content 设置为 space-between 的例子](https://www.html.cn/newimg88/2018/12/align-content-space-between.svg)

CSS 代码:

```CSS
.container {  align-content: space-evenly;  }
```

![align-content 设置为 space-evenly 的例子](https://www.html.cn/newimg88/2018/12/align-content-space-evenly.svg)

[回到目录](https://www.html.cn/archives/8510#table-of-contents)

### place-content

`place-content` 是设置 `align-content` 和 `justify-content` 的简写形式。

值：

- `<align-content> <justify-content>`：第一个值设置 `align-content` 属性，第二个值设置 `justify-content` 属性。如果省略第二个值，则将第一个值同时分配给这两个属性。

除 Edge 之外的所有主要浏览器都支持 `place-content` 简写属性。

有关更多详细信息，请参阅[`align-content`](https://www.html.cn/archives/8510#prop-align-content) 和 [`justify-content`](https://www.html.cn/archives/8510#prop-justify-content)。

[回到目录](https://www.html.cn/archives/8510#table-of-contents)

### grid-auto-columns / grid-auto-rows

指定任何自动生成的网格轨道(grid tracks)（又名隐式网格轨道）的大小。当网格中的网格项多于单元格时，或者当网格项位于显式网格之外时，就会创建隐式轨道。（参见[显式网格和隐式网格之间的区别](https://www.html.cn/archives/10327)）

值：

- `<track-size>`：可以是长度值，百分比，或者等份网格容器中可用空间的分数（使用 `fr` 单位）

CSS 代码:

```CSS
.container {  grid-auto-columns: <track-size> ...;  grid-auto-rows: <track-size> ...;}
```

为了说明如何创建隐式网格轨道，请考虑一下以下的代码：

CSS 代码:

```CSS
.container {  grid-template-columns: 60px 60px;  grid-template-rows: 90px 90px}
```

![网格模板](https://www.html.cn/newimg88/2018/12/grid-auto-columns-rows-01.svg)

这将生成了一个 2×2 的网格。

但现在想象一下，你使用 [`grid-column`](https://www.html.cn/archives/8510#prop-grid-column-row) 和 [`grid-row`](https://www.html.cn/archives/8510#prop-grid-column-row) 来定位你的网格项，像这样：

CSS 代码:

```CSS
.item-a {  grid-column: 1 / 2;  grid-row: 2 / 3;}.item-b {  grid-column: 5 / 6;  grid-row: 2 / 3;}
```

![隐式网格轨道示例](https://www.html.cn/newimg88/2018/12/grid-auto-columns-rows-02.svg)

我们告诉 `.item-b` 从第 5 条列网格线开始到第 6 条列网格线结束，*但我们从来没有定义过 第5 或 第6 列网格线*。
因为我们引用的网格线不存在，所以创建宽度为 0 的隐式网格轨道以填补空缺。我们可以使用 [`grid-auto-columns`](https://www.html.cn/archives/8510#prop-grid-auto-columns-rows) 和 [`grid-auto-rows`](https://www.html.cn/archives/8510#prop-grid-auto-columns-rows) 来指定这些隐式轨道的大小：

CSS 代码:

```CSS
.container {  grid-auto-columns: 60px;} 
```

![隐式网格轨道示例](https://www.html.cn/newimg88/2018/12/grid-auto-columns-rows-03.svg)

[回到目录](https://www.html.cn/archives/8510#table-of-contents)

### grid-auto-flow

如果你有一些没有明确放置在网格上的网格项(grid items)，**自动放置算法** 会自动放置这些网格项。该属性控制自动布局算法如何工作。

值：

- `row`：告诉自动布局算法依次填充每行，根据需要添加新行 （默认）
- `column`：告诉自动布局算法依次填入每列，根据需要添加新列
- `dense`：告诉自动布局算法在稍后出现较小的网格项时，尝试填充网格中较早的空缺

CSS 代码:

```CSS
.container {  grid-auto-flow: row | column | row dense | column dense}
```

请注意，`dense` 只会更改网格项的可视顺序，并可能导致它们出现乱序，这对可访问性不利。

示例：

考虑以下 HTML :

HTML 代码:

```HTML
<section class="container">  <div class="item-a">item-a</div>  <div class="item-b">item-b</div>  <div class="item-c">item-c</div>  <div class="item-d">item-d</div>  <div class="item-e">item-e</div></section>
```

你定义一个有 5 列和 2 行的网格，并将 [`grid-auto-flow`](https://www.html.cn/archives/8510#prop-grid-auto-flow) 设置为 `row`（也就是默认值）：

CSS 代码:

```CSS
.container {  display: grid;  grid-template-columns: 60px 60px 60px 60px 60px;  grid-template-rows: 30px 30px;  grid-auto-flow: row;}
```

将网格项放在网格上时，只能为其中的两个指定位置：

CSS 代码:

```CSS
.item-a {  grid-column: 1;  grid-row: 1 / 3;}.item-e {  grid-column: 5;  grid-row: 1 / 3;}
```

因为我们把 [`grid-auto-flow`](https://www.html.cn/archives/8510#prop-grid-auto-flow) 设成了 `row` ，所以我们的网格看起来会是这样。**注意** 我们没有进行定位的网格项（`item-b`，`item-c`，`item-d`）会这样排列在可用的行中：

![自动放置算法](https://www.html.cn/newimg88/2018/12/grid-auto-flow-01.svg)

相反地，如果我们把 [`grid-auto-flow`](https://www.html.cn/archives/8510#prop-grid-auto-flow) 设成了 `column` ，那么 `item-b`，`item-c`，`item-d` 会沿着列向下排列：

CSS 代码:

```CSS
.container {  display: grid;  grid-template-columns: 60px 60px 60px 60px 60px;  grid-template-rows: 30px 30px;  grid-auto-flow: column;}
```

![自动放置算法](https://www.html.cn/newimg88/2018/12/grid-auto-flow-02.svg)

[回到目录](https://www.html.cn/archives/8510#table-of-contents)

## grid

在一个声明中设置所有以下属性的简写： [`grid-template-rows`](https://www.html.cn/archives/8510#prop-grid-template-columns-rows), [`grid-template-columns`](https://www.html.cn/archives/8510#prop-grid-template-columns-rows), [`grid-template-areas`](https://www.html.cn/archives/8510#prop-grid-template-areas), [`grid-auto-rows`](https://www.html.cn/archives/8510#prop-grid-auto-columns-rows), [`grid-auto-columns`](https://www.html.cn/archives/8510#prop-grid-auto-columns-rows), 和 [`grid-auto-flow`](https://www.html.cn/archives/8510#prop-grid-auto-flow) 。（注意：您只能在单个网格声明中指定显式或隐式网格属性）。

值：

- `none`：将所有子属性设置为其初始值。
- `<grid-template>`：与[`grid-template`](https://www.html.cn/archives/8510#prop-grid-template) 简写的工作方式相同。
- `<grid-template-rows> / [ auto-flow && dense? ] <grid-auto-columns>? `：将[`grid-template-rows`](https://www.html.cn/archives/8510#prop-grid-template-columns-rows) 设置为指定的值。 如果 `auto-flow` 关键字位于斜杠的右侧，则会将 [`grid-auto-flow`](https://www.html.cn/archives/8510#prop-grid-auto-flow) 设置为 `column`。 如果另外指定了 `dense` 关键字，则自动放置算法使用 “dense” 算法。 如果省略 [`grid-auto-columns`](https://www.html.cn/archives/8510#prop-grid-auto-columns-rows) ，则将其设置为 `auto`。
- `[ auto-flow && dense? ] <grid-auto-rows>? / <grid-template-columns>`：将 [`grid-template-columns`](https://www.html.cn/archives/8510#prop-grid-template-columns-rows) 设置为指定值。 如果 `auto-flow` 关键字位于斜杠的左侧，则会将[`grid-auto-flow`](https://www.html.cn/archives/8510#prop-grid-auto-flow) 设置为 `row` 。 如果另外指定了 `dense` 关键字，则自动放置算法使用 “dense” 打包算法。 如果省略 [`grid-auto-rows`](https://www.html.cn/archives/8510#prop-grid-auto-columns-rows) ，则将其设置为 `auto`。

例子：

以下两个代码块是等效的：

CSS 代码:

```CSS
.container {  grid: 100px 300px / 3fr 1fr;}
```

CSS 代码:

```CSS
.container {  grid-template-rows: 100px 300px;  grid-template-columns: 3fr 1fr;}
```

以下两个代码块是等效的：

CSS 代码:

```CSS
.container {  grid: auto-flow / 200px 1fr;}
```

CSS 代码:

```CSS
.container {  grid-auto-flow: row;  grid-template-columns: 200px 1fr;}
```

以下两个代码块是等效的：

CSS 代码:

```CSS
.container {  grid: auto-flow dense 100px / 1fr 2fr;}
```

CSS 代码:

```CSS
.container {  grid-auto-flow: row dense;  grid-auto-rows: 100px;  grid-template-columns: 1fr 2fr;}
```

以下两个代码块是等效的：

CSS 代码:

```CSS
.container {  grid: 100px 300px / auto-flow 200px;}
```

CSS 代码:

```CSS
.container {  grid-template-rows: 100px 300px;  grid-auto-flow: column;  grid-auto-columns: 200px;}
```

它也接受一个更复杂但相当方便的语法来一次设置所有内容。您可以指定 [`grid-template-areas`](https://www.html.cn/archives/8510#prop-grid-template-areas)，[`grid-template-rows`](https://www.html.cn/archives/8510#prop-grid-template-columns-rows)和[`grid-template-columns`](https://www.html.cn/archives/8510#prop-grid-template-columns-rows)，并所有其他的子属性都被设置为它们的初始值。这么做可以在它们网格区域内相应地指定网格线名字和网格轨道的大小。用最简单的例子来描述：

CSS 代码:

```CSS
.container {  grid: [row1-start] "header header header" 1fr [row1-end]        [row2-start] "footer footer footer" 25px [row2-end]        / auto 50px auto;}
```

等价于：

CSS 代码:

```CSS
.container {  grid-template-areas:     "header header header"    "footer footer footer";  grid-template-rows: [row1-start] 1fr [row1-end row2-start] 25px [row2-end];  grid-template-columns: auto 50px auto;    }
```

[回到目录](https://www.html.cn/archives/8510#table-of-contents)

## 子元素 网格项(Grid Items) 属性

> 注意：`float`，`display: inline-block`，`display: table-cell`，`vertical-align` 和 `column-*` 属性对网格项无效。

### grid-column-start / grid-column-end / grid-row-start / grid-row-end

通过引用特定网格线(grid lines) 来确定 网格项(grid item) 在网格内的位置。 [`grid-column-start`](https://www.html.cn/archives/8510#prop-grid-column-row-start-end) / [`grid-row-start`](https://www.html.cn/archives/8510#prop-grid-column-row-start-end) 是网格项开始的网格线，[`grid-column-end`](https://www.html.cn/archives/8510#prop-grid-column-row-start-end) / [`grid-row-end`](https://www.html.cn/archives/8510#prop-grid-column-row-start-end) 是网格项结束的网格线。

值：

- `<line>` ：可以是一个数字引用一个编号的网格线，或者一个名字来引用一个命名的网格线
- `span <number>` ：该网格项将跨越所提供的网格轨道数量
- `span <name>` ：该网格项将跨越到它与提供的名称位置
- `auto`：表示自动放置，自动跨度，默认会扩展一个网格轨道的宽度或者高度

CSS 代码:

```CSS
.item {  grid-column-start: <number> | <name> | span <number> | span <name> | auto  grid-column-end: <number> | <name> | span <number> | span <name> | auto  grid-row-start: <number> | <name> | span <number> | span <name> | auto  grid-row-end: <number> | <name> | span <number> | span <name> | auto}
```

示例：

CSS 代码:

```CSS
.item-a {  grid-column-start: 2;  grid-column-end: five;  grid-row-start: row1-start  grid-row-end: 3;}
```

![网格项位置，grid-column-start，grid-column-end，grid-row-start，grid-row-end 的示例](https://www.html.cn/newimg88/2018/12/grid-column-row-start-end-01.svg)

CSS 代码:

```CSS
.item-b {  grid-column-start: 1;  grid-column-end: span col4-start;  grid-row-start: 2  grid-row-end: span 2}
```

![网格项位置，grid-column-start，grid-column-end，grid-row-start，grid-row-end 的示例](https://www.html.cn/newimg88/2018/12/grid-column-row-start-end-02.svg)

如果没有声明指定 [`grid-column-end`](https://www.html.cn/archives/8510#prop-grid-column-row-start-end) / [`grid-row-end`](https://www.html.cn/archives/8510#prop-grid-column-row-start-end)，默认情况下，该网格项将占据 1 个轨道。

项目可以相互重叠。您可以使用 `z-index` 来控制它们的重叠顺序。

[回到目录](https://www.html.cn/archives/8510#table-of-contents)

### grid-column / grid-row

分别为 [`grid-column-start`](https://www.html.cn/archives/8510#prop-grid-column-row-start-end) + [`grid-column-end`](https://www.html.cn/archives/8510#prop-grid-column-row-start-end) 和 [`grid-row-start`](https://www.html.cn/archives/8510#prop-grid-column-row-start-end) + [`grid-row-end`](https://www.html.cn/archives/8510#prop-grid-column-row-start-end) 的简写形式。

值：

- `<start-line> / <end-line>`：每个网格项都接受所有相同的值，作为普通书写的版本，包括跨度

CSS 代码:

```CSS
.item {  grid-column: <start-line> / <end-line> | <start-line> / span <value>;  grid-row: <start-line> / <end-line> | <start-line> / span <value>;}
```

示例：

CSS 代码:

```CSS
.item-c {  grid-column: 3 / span 2;  grid-row: third-line / 4;}
```

![网格项位置简写形式](https://www.html.cn/newimg88/2018/12/grid-column-row.svg)

如果没有声明分隔线结束位置，则该网格项默认占据 1 个网格轨道。

[回到目录](https://www.html.cn/archives/8510#table-of-contents)

### grid-area

为网格项提供一个名称，以便可以 被使用网格容器 [`grid-template-areas`](https://www.html.cn/archives/8510#prop-grid-template-areas) 属性创建的模板进行引用。 另外，这个属性可以用作[`grid-row-start`](https://www.html.cn/archives/8510#prop-grid-column-row-start-end) + [`grid-column-start`](https://www.html.cn/archives/8510#prop-grid-column-row-start-end) + [`grid-row-end`](https://www.html.cn/archives/8510#prop-grid-column-row-start-end) + [`grid-column-end`](https://www.html.cn/archives/8510#prop-grid-column-row-start-end) 的简写。

值：

- `<name>`：你所选的名称
- `<row-start> / <column-start> / <row-end> / <column-end>`：数字或分隔线名称

CSS 代码:

```CSS
.item {  grid-area: <name> | <row-start> / <column-start> / <row-end> / <column-end>;}
```

示例：

作为为网格项分配名称的一种方法：

CSS 代码:

```CSS
.item-d {  grid-area: header}
```

作为[`grid-row-start`](https://www.html.cn/archives/8510#prop-grid-column-row-start-end) + [`grid-column-start`](https://www.html.cn/archives/8510#prop-grid-column-row-start-end) + [`grid-row-end`](https://www.html.cn/archives/8510#prop-grid-column-row-start-end) + [`grid-column-end`](https://www.html.cn/archives/8510#prop-grid-column-row-start-end) 属性的简写形式

CSS 代码:

```CSS
.item-d {    grid-area: 1 / col4-start / last-line / 6}
```

![网格区域](https://www.html.cn/newimg88/2018/12/grid-area.svg)

[回到目录](https://www.html.cn/archives/8510#table-of-contents)

### justify-self

沿着 *inline*（行）轴线对齐网格项（ 相反的属性是 [`align-self`](https://www.html.cn/archives/8510#prop-align-self) ，沿着 *block*（列）轴线对齐）。此值适用于单个网格项内的内容。

值：

- `start`：将网格项对齐到其单元格的左侧起始边缘（左侧对齐）
- `end`：将网格项对齐到其单元格的右侧结束边缘（右侧对齐）
- `center`：将网格项对齐到其单元格的水平中间位置（水平居中对齐）
- `stretch`：填满单元格的宽度（默认值）

CSS 代码:

```CSS
.item {  justify-self: start | end | center | stretch;}
```

示例：

CSS 代码:

```CSS
.item-a {  justify-self: start;}
```

![左对齐，将 justify-self 设置为 start 的例子](https://www.html.cn/newimg88/2018/12/justify-self-start.svg)

CSS 代码:

```CSS
.item-a {  justify-self: end;}
```

![右对齐，将 justify-self 设置为 end 的例子](https://www.html.cn/newimg88/2018/12/justify-self-end.svg)

CSS 代码:

```CSS
.item-a {  justify-self: center;}
```

![水平居中对齐，将 justify-self 设置为 center 的例子](https://www.html.cn/newimg88/2018/12/justify-self-center.svg)

CSS 代码:

```CSS
.item-a {  justify-self: stretch;}
```

![填充宽度，将 justify-self 设置为 stretch 的例子](https://www.html.cn/newimg88/2018/12/justify-self-stretch.svg)

要为网格中的所有网格项设置 行轴线(row axis) 线上对齐方式，也可以在 网格容器 上设置 [`justify-items`](https://www.html.cn/archives/8510#prop-justify-items) 属性。

[回到目录](https://www.html.cn/archives/8510#table-of-contents)

### align-self

沿着 *block*（列）轴线对齐网格项(grid items)（ 相反的属性是 [`justify-self`](https://www.html.cn/archives/8510#prop-justify-self) ，沿着 *inline*（行）轴线对齐）。此值适用于单个网格项内的内容。

值：

- `start`：将网格项对齐到其单元格的顶部起始边缘（顶部对齐）
- `end`：将网格项对齐到其单元格的底部结束边缘（底部对齐）
- `center`：将网格项对齐到其单元格的垂直中间位置（垂直居中对齐）
- `stretch`：填满单元格的高度（默认值）

CSS 代码:

```CSS
.item{  align-self: start | end | center | stretch;}
```

示例：

CSS 代码:

```CSS
.item-a {    align-self: start;}
```

![顶部对齐，将 align-self 设置为 start 的例子](https://www.html.cn/newimg88/2018/12/align-self-start.svg)

CSS 代码:

```CSS
.item-a {  align-self: end;}
```

![底部对齐，将 align-self 设置为 end 的例子](https://www.html.cn/newimg88/2018/12/align-self-end.svg)

CSS 代码:

```CSS
.item-a {    align-self: center;}
```

![垂直居中对齐，将 align-self 设置为 center 的例子](https://www.html.cn/newimg88/2018/12/align-self-center.svg)

CSS 代码:

```CSS
.item-a {    align-self: stretch;}
```

![填充高度，将 align-self 设置为 stretch 的例子](https://www.html.cn/newimg88/2018/12/align-self-stretch.svg)

要为网格中的所有网格项设置 列轴线(column axis) 上的对齐方式，也可以在 网格容器 上设置 [`align-items`](https://www.html.cn/archives/8510#prop-align-items) 属性。

### place-self

`place-self` 是设置 `align-self` 和 `justify-self` 的简写形式。

值：

- `auto` – 布局模式的 “默认” 对齐方式。
- `<align-self> <justify-self>`：第一个值设置 `align-self` 属性，第二个值设置 `justify-self` 属性。如果省略第二个值，则将第一个值同时分配给这两个属性。

示例：

CSS 代码:

```CSS
.item-a {  place-self: center;}
```

![居中，将 place-self 设置为 center 的例子](https://www.html.cn/newimg88/2018/12/place-self-center.svg)

CSS 代码:

```CSS
.item-a {  place-self: center stretch;}
```

![居中，将 place-self 设置为 center stretch 的例子](https://www.html.cn/newimg88/2018/12/place-self-center-stretch.svg)

除 Edge 之外的所有主要浏览器都支持 `place-self` 简写属性。

[回到目录](https://www.html.cn/archives/8510#table-of-contents)

## 动画（Animation）

根据 CSS Grid 布局模块 Level 1 规范，有 5 个可应用动画的网格属性：

- `grid-gap`， `grid-row-gap`，`grid-column-gap` 作为长度，百分比或 calc。
- `grid-template-columns`，`grid-template-rows` 作为长度，百分比或 calc 的简单列表，只要列表中长度、百分比或calc组件的值不同即可。

### 浏览器支持CSS网格属性

截至今天（2018年5月7日），在测试的几个浏览器中仅实现 `(grid-)gap`，`(grid-)row-gap`，`(grid-)column-gap` 的动画。

浏览器支持可设置动画的网格属性：

|                 浏览器                 | (grid-)gap, (grid-)row-gap, (grid-)column-gap | grid-template-columns | grid-template-rows |
| :------------------------------------: | :-------------------------------------------: | :-------------------: | :----------------: |
|    Firefox 55+, Firefox 53+ Mobile     |                       ✅                       |           ❌           |         ❌          |
|             Safari 11.0.2              |                       ❌                       |           ❌           |         ❌          |
|               Chrome 66+               |                       ✅                       |           ❌           |         ❌          |
| Chrome for Android 66+, Opera Mini 33+ |                       ✅                       |           ❌           |         ❌          |
|                Edge 16+                |                       ✅                       |           ❌           |         ❌          |