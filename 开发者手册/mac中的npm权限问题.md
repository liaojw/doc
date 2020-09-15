# mac中的npm权限问题

当我用create-react-app 初始化项目的时候老是报一个权限的错误

```
Error: EACCES: permission denied
```

## 1.修改npm默认目录的权限

##### 1、找到npm的目录路径：

```
npm config get prefix
1
```

对于很多系统，路径将会是 /usr/local.

警告：如果出来的路径仅是 /usr，请调到方法2，否则你可能会设置错误。

##### 2、将npm目录的拥有者修改为当前用户的名字（你账户的用户名）：

```
sudo chown -R $(whoami) $(npm config get prefix)/{lib/node_modules,bin,share}
1
```

这会改变npm及其他工具用到的子文件夹的权限（lib/node_modules, bin, and share）。

## 2.将npm默认目录定向到其他你具有读写权限的目录

很多时候你可能并不想改变npm所用的默认目录（如/usr）的拥有者，因为这可能会导致一些问题，比如你在与其他用户共用此系统时。
这时，你可以设置npm整个地去使用另一个目录。我将它设置为我的主文件夹下的一个隐藏的目录(command+shift+>可以查看隐藏文件和目录)。
1、创建一个目录用作全局安装：

```
mkdir ~/.npm-global
1
```

2、配置npm使用这个新目录：

```
npm config set prefix '~/.npm-global'
1
```

3、打开（没有就创建）一个“~/.profile”文件到你的全局目录下并添加下行代码（这一步不在命令行操作，而在你新创建的文件下添加）：

```
export PATH=~/.npm-global/bin:$PATH
1
```

4、返回命令行，更新系统变量：

```
source ~/.profile
```

