# vue+amfe-flexible(手淘移动端适配方案)开发移动端

### 1.移动端适配所需依赖

```
cnpm install amfe-flexible -S
cnpm install postcss-pxtorem -S
复制代码
```

### 2.main.js配置

```
//引入
import 'amfe-flexible/index'
复制代码
```

### 3.vue.config.js

注意: vue-cli3.x默认是没有vue.config.js配置文件的,需要手动创建,位置在项目根目录

```
module.exports = {
    css: {
        loaderOptions: {
            postcss: {
                plugins: [
                    require('postcss-pxtorem')({ // 把px单位换算成rem单位
                        rootValue: 75, // 换算的基数(设计图750的根字体为75,如果设计图为640:则rootValue=64)
                        propList: ['*']
                    })
                ]
            }
        }
    },
    configureWebpack: config => {
        if (process.env.NODE_ENV === 'production') {
            // 为生产环境修改配置...
        } else {
            // 为开发环境修改配置...
        }
    }
}
复制代码
```

### 4.使用

> 在CSS样式中可直接书写750PX,既代表 整屏的宽度,如果设计图不是750的,可在vue.config.js中 rootValue属性,修改为设计图宽度即可,详见vue.config.js注释说明