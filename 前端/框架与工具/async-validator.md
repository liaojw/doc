# async-validator

## 概述

表单异步验证，github: [async-validator](https://github.com/yiminghe/async-validator)

安装：

```
npm i async-validator -S
```

## 基本使用

这里使用了 Vue 的方式：

```
<template>
    <div>
        <input v-model="form.name">
        <p>{{message.name}}</p>
        <input v-model="form.age">
        <p>{{message.age}}</p>
        <button @click="submit">submit</button>
    </div>
</template>
import Schema from 'async-validator'
let validator = null
export default {
    data () {
        return {
            // 表单对象
            form: {
                name: '张三',
                age: '18'
            },
            // 校验规则
            rules: {
                name: { // 一条校验规则
                    required: true,
                    message: '姓名为必填项'
                },
                age: [ // 多条校验规则
                    {
                        required: true,
                        message: '年龄为必填项'
                    },
                    {
                        validator (rule, value, callback) {
                            value < 18
                                ? callback(new Error('未成年人不符合条件'))
                                : callback()
                        }
                    }
                ]
            },
            // 错误提示
            message: {
                name: '',
                age: ''
            }
        }
    },
    created () {
        // 实例化构造函数表示创建一个校验器，参数为校验规则对象
        validator = new Schema(this.rules)
    },
    methods: {
        // 提交
        submit () {
            this.clearMessage()
            validator.validate(this.form, {
                firstFields: true
            }).then(() => {
                // 校验通过
                console.log('ok')
            }).catch(({ errors }) => {
                // 校验未通过
                // 显示错误信息
                for (let { field, message } of errors) this.message[field] = message
            })
        },
        // 清空校验错误提示
        clearMessage () {
            for (let key in this.message) this.message[key] = ''
        }
    }
}
```

## rules

校验规则，每个校验属性对应要校验的表单对象

- `type` {String}：内置校验类型，可选值如下
  - `string`：必须是 string 类型，默认类型
  - `number`：必须是 number 类型
  - `boolean`：必须是 boolean 类型
  - `method`：必须是 function 类型
  - `regexp`：必须是 regexp 类型
  - `integer`：必须是整数类型
  - `float`：必须是浮点数类型
  - `array`：必须是 array 类型
  - `object`：必须是 object 类型
  - `enum`：必须出现在 `enmu` 指定的值中
  - `date`：必须是 date 类型
  - `url`：必须是 url 类型
  - `hex`：必须是 16 进制类型
  - `email`：必须是 email 类型
  - `any`：任意类型
- `required` {Boolean}：是否必填
- `pattern` {Regexp}：需要符合的正则
- `min` {Number}：最小值，对于字符串和数组会与 `length` 比较，对于数字会直接与值比较
- `max` {Number}：最大值，比较规则同上
- `len` {Number}：指定长度，比较规则同上，优先级高于 `min` 和 `max`
- `enum` {Array}：指定的值，配合 `type: 'enum'` 使用
- `whitespace` {Boolean}：是否值不能都是空格
- `fields` {Object}：嵌套规则，必须在父规则上指定 `required`，否则不会校验
- `defaultField` {Object/Array}：`fields` 属性的扩展，校验 `object` 和 `array` 类型中所有的值
- `transform` {Function}：校验前对值进行转换，函数的参数为当前值，返回值为改变后的值
- `message`：校验提示信息，可以任意类型，例如 string、JSX、函数的返回值
- `validator` {Function}：自定义校验函数，参数依次如下
  - `rule`：当前校验字段在 rules 中所对应的校验规则
  - `value`：当前校验字段的值
  - `callback`：校验完成时的回调，传入 `Error` 或 `ErrorArray` 表示校验失败，不传即为成功
    - 如果校验是同步的直接返回 `false` 或 `Error/ErrorArray` 也可以
  - `source`：校验对象
  - `options`：配置项，属性如下
    - `messages`：校验错误提示信息，会被合并到默认的提示信息中
- `asyncValidator` {Function}：自定义异步校验函数，参数同 `validator`

## validate 方法

校验方法：

```
function (source, [options], callback): Promise
```

- `source` {Object}：需要校验的对象
- `options` {Object}：配置项
  - `first` {Boolean}：第一个未通过校验的字段发生错误就调用 `callback`，即不再继续校验剩余字段
  - `firstFields` {Boolean/StringArray}：多条校验规则的配置
    - Boolean：每个字段的第一个规则发生错误就调用 `callback`，即不再继续校验该字段的剩余规则
    - StringArray：指定字段的第一个规则发生错误就调用 `callback`
  - `suppressWarning` {Boolean}：是否禁止无效值的内部警告
- `callback(errors, fields)` {Function}：校验完成时的回调，若 `errors` 存在表示校验失败，否则校验成功

返回的 Promise：

- `then()`：校验通过的回调
- `catch({ errors, fields })`：校验失败的回调
  - `errors` {Array}：所有校验错误的 `Error` 数组
  - `fields` {Object}：所有校验错误的对象，键名为校验字段名，键值为 `Error` 数组

## messages 方法

```
async-validator` 内部有些内置常用的英语校验提示，如果不指定校验规则中的 `message`，默认就是使用内置的英语提示
使用 `messages` 方法可以自定义默认校验提示，`%s` 为校验的字段名，所有可修改的字段见项目源码 `src/messages.js
validator.messages({
    required: '%s 必填'
})
```

## FAQ

### 如何关闭校验错误时的控制台警告

```
Schema.warning = () => {}
```

### 如何校验值为 true

```
{
  type: 'enum',
  enum: [true]
}
```