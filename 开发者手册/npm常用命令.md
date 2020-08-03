# npm常用命令

#### 1、显示所有可用命令

```bash
$ npm -l
```

#### 2、查看命令

```bash
$ npm help <command>
```

#### 3、查看安装目录

```bash
//查看本地安装的目录
$ npm root

//查看全局安装的目录
$ npm root -g
```

#### 4、查看当前安装的模块（包）

```bash
//查看本地安装的模块
$ npm ls

//查看全局安装的模块
$ npm ls -g --depth=0
```

#### 5、创建项目

> 初始化一个基于node的项目，会创建一个配置文件package.json（两种方式）:

```bash
 //1.一般情况下一路enter
 $ npm init

 //2.全部使用默认配置
 $ npm init --yes
```

#### 6、安装模块（包）

```bash
//全局安装
$ npm install 模块名 -g
//本地安装
$ npm install 模块名
//一次性安装多个
$ npm install 模块1 模块2 模块n --save

//安装运行时依赖包
$ npm install 模块名 --save
//安装开发时依赖包
$ npm install 模块名 --save-dev
```

#### 7、卸载模块（包）

```bash
//卸载本地模块
$ npm uninstall 模块名

//卸载全局模块
$ npm uninstall -g 模块名
```

#### 8、更新模块（包）

```bash
//更新本地模块
$ npm update 模块名

//更新全局模块
$ npm update 模块名 -g
```

#### 9、缓存清理

```bash
$ npm cache clean --force
```

