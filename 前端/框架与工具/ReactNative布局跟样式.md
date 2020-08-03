# ReactNative布局跟样式

##### Style属性介绍

在React Native 中 样式其实使用第JavaScript 的样式来写的。所有的核心组件都接受名为 style属性。这些样式名基本上是遵循了 web 上的 CSS 的命名，只是按照 JS 的语法要求使用了驼峰命名法，例如将 'background-color'改为'backgroundColor'。
 style 属性 可以是一个普通的JavaScript 对象 ，这是最简单的用法，在代码实例中是很常见的，你可以传一个数组， 在传数组中的时候， 位置在后面的样式要比前面的样式的优先级要高一些。 这样就可以间接的实现样式的继承关系。 在实际开发中官方建议我们为了以后组件可维护性以及扩展性组件的样式采用StyleSheet.create的方式来声明。

###### 代码栗子：

```
import React, { Component } from 'react';
// 首先需要从react-native 里面导入 StyleSheet 这个组件
import { View, Text,StyleSheet } from 'react-native';

class TestStyle extends Component {
  constructor(props) {
    super(props);
    this.state = {
    };
  }

  render() {
    return (
      <View>
        <Text style ={styles.style1} > 样式式一 </Text>
        <Text style ={styles.style2} > 样式式二 </Text>
        <Text style ={[styles.style1,styles.style2]} > 样式式一根样式二的结合体 </Text>
      </View>
    );
  }
}

const styles = StyleSheet.create({
    style1 :{
        fontSize :20,  //字体大小
        color:'green' //字体颜色
    },
    style2 :{
        fontSize :10,
        color :'red'
    }
});
export default TestStyle;
```

##### 其他的栗子

```
在ReactNative 只能使用css 的样式， 就是吧css的命名方式改成驼峰命名。

    'height' :  设置组件的高度
    'width'  :  设置组件的宽度
    'top'    :  是指组件相对于屏幕上方的距离，不是相对于其他组件的距离。
    'marginTop'  是指组件距离父组件的上方距离。
    'paddingTop' 是指组件内容居，内容边框的距离。
    "alignItems",居中对齐弹性盒的各项 <div> 元素

    例：alignItems:'center',
    -> stretch(项目被拉伸以适应容器)
    -> center(项目位于容器的中心)
    -> flex-start(项目位于容器的开头)
    -> flex-end(项目位于容器的结尾)
    -> baseline(项目位于容器的基线上)
    -> initial(设置该属性为它的默认值)
    -> inherit(从父元素继承该属性)
    "alignSelf",居中对齐弹性对象元素内的某个项

   例：alignSelf:'center',
   -> auto(默认值。元素继承了它的父容器的 align-items 属性。如果没有父容器则为 "stretch")
   -> stretch(项目被拉伸以适应容器)
   -> center(项目位于容器的中心)
   -> flex-start(项目位于容器的开头)
   -> flex-end(项目位于容器的结尾)
   -> baseline(项目位于容器的基线上)
   -> initial(设置该属性为它的默认值)
   -> inherit(从父元素继承该属性

    "backfaceVisibility",当元素不面向屏幕时是否可见
    例：backfaceVisibility:'visible'
    -> visible (背面是可见的)
    -> hidden  (背面是不可见的)

    "backgroundColor",背景色
    例：backgroundColor:'red'
    例：backgroundColor:'#cccccc'
    -> color   (指定背景颜色。在CSS颜色值近可能的寻找一个颜色值的完整列表)
    -> transparent (指定背景颜色应该是透明的。这是默认)
    -> inherit (指定背景颜色，应该从父元素继承)

    "borderBottomColor",底部边框颜色
    例：borderBottomColor:'red'
    例：borderBottomColor:'#cccccc'
    -> color   (指定背景颜色。在CSS 颜色值 查找颜色值的完整列表)
    -> transparent (指定边框的颜色应该是透明的。这是默认)
    - >inherit (指定边框的颜色，应该从父元素继承)

    "borderStyle",四个边框的样式
    例：borderStyle:'dotted'
    -> none    定义无边框。
    -> hidden  与 "none" 相同。不过应用于表时除外，对于表，hidden 用于解决边框冲突。
    -> dotted  定义点状边框。在大多数浏览器中呈现为实线。
    -> dashed  定义虚线。在大多数浏览器中呈现为实线。
    -> solid   定义实线。
    -> double  定义双线。双线的宽度等于 border-width 的值。
    -> groove  定义 3D 凹槽边框。其效果取决于 border-color 的值。
    -> ridge   定义 3D 垄状边框。其效果取决于 border-color 的值。
    -> inset   定义 3D inset 边框。其效果取决于 border-color 的值。
    -> outset  定义 3D outset 边框。其效果取决于 border-color 的值。
    -> inherit 规定应该从父元素继承边框样式。

    "flexDirection",设置 <div> 元素内弹性盒元素的方向为相反的顺序
    例：flexDirection:'column'
    -> row ((默认值。灵活的项目将水平显示，正如一个行一样)
    -> row-reverse (与 row 相同，但是以相反的顺序)
    -> column  (灵活的项目将垂直显示，正如一个列一样)
    -> column-reverse  (与 column 相同，但是以相反的顺序)
    -> initial (设置该属性为它的默认值。请参阅 initial)
    -> inherit (从父元素继承该属性。请参阅 inherit)

    "flexWrap",让弹性盒元素在必要的时候拆行
    例：flexWrap:'wrap'
    -> nowrap  (默认值。规定灵活的项目不拆行或不拆列)
    -> wrap    (规定灵活的项目在必要的时候拆行或拆列)
    -> wrap-reverse    (规定灵活的项目在必要的时候拆行或拆列，但是以相反的顺序)
    -> initial (设置该属性为它的默认值。请参阅 initial)
    -> inherit (从父元素继承该属性。请参阅 inherit)

    "fontWeight",文本的粗细
    例：fontWeight:'bold'
    -> normal  (默认值。定义标准的字符)
    -> bold    (定义粗体字符)
    -> bolder  (定义更粗的字符)
    -> lighter (定义更细的字符)
    -> 100    (定义由粗到细的字符。400 等同于 normal，而 700 等同于 bold)

    "justifyContent",在弹性盒对象的元素中的各项周围留有空白
    例：justifyContent:'space-between'
    -> flex-start  (默认值。项目位于容器的开头)
    -> flex-end    (项目位于容器的结尾)
    -> center  (项目位于容器的中心)
    -> space-between   (项目位于各行之间留有空白的容器内)
    -> space-around    (项目位于各行之前、之间、之后都留有空白的容器内)

    "textAlign",文本对齐方式
    例：textAlign:'left'
    -> left    把文本排列到左边。默认值：由浏览器决定。
    -> right   把文本排列到右边。
    -> center  把文本排列到中间。
    -> justify 实现两端对齐文本效果

    "textDecorationStyle",显示一条线的样式
    例：textDecorationStyle:'solid'
    -> solid   默认值。线条将显示为单线。
    -> double  线条将显示为双线。
    -> dotted  线条将显示为点状线。
    -> dashed  线条将显示为虚线。
    -> wavy    线条将显示为波浪线

    "position",定位
    例：position:'fixed'
    -> absolute    生成绝对定位的元素，相对于 static 定位以外的第一个父元素进行定位。元素的位置通过 "left", "top", "right" 以及 "bottom" 属性进行规定。
    -> fixed       生成绝对定位的元素，相对于浏览器窗口进行定位。元素的位置通过 "left", "top", "right" 以及 "bottom" 属性进行规定。
    -> relative    生成相对定位的元素，相对于其正常位置进行定位。因此，"left:20" 会向元素的 LEFT 位置添加 20 像素。
    -> static      默认值。没有定位，元素出现在正常的流中（忽略 top, bottom, left, right 或者 z-index 声明）

    "resizeMode",用户调整大小
    例：resizeMode:'cover'
    -> cover    等比拉伸
    -> strech   保持原有大小
    -> contain  图片拉伸  充满空间

    "textDecorationStyle",显示一条线的样式
    例：textDecorationStyle:'solid'
    -> solid   默认值。线条将显示为单线。
    -> double  线条将显示为双线。
    -> dotted  线条将显示为点状线。
    -> dashed  线条将显示为虚线。
    -> wavy    线条将显示为波浪线

    "textShadowColor",文字阴影颜色
    例：textShadowColor：'red'

    "textShadowOffset",文字阴影偏移量
    例：textShadowOffset:2

    "textShadowRadius",文字阴影圆角
    例：textShadowRadius:3

    "textDecorationColor",下划线文本中下划线的颜色
    例：textDecorationColor:'red'

    "overflow",设置overflow属性进行滚动
    例：overflow:'hidden'
    visible    (默认值。内容不会被修剪，会呈现在元素框之外)
    hidden (内容会被修剪，并且其余内容是不可见的)
    scroll (内容会被修剪，但是浏览器会显示滚动条以便查看其余的内容)

    "opacity",透明度级别
    例：opacity：0.5
```

