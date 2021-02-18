# Mac下配置JAVA_HOME

##### 1、打开Termina

##### 2、查看已有PATH

```
cat ~/.bash_profile
```

以上为查找操作，若查不到JAVA_HOME，则可用下面语句插入profile

##### 3、使用工具命令```/usr/libexec/java_home```来定位JAVA_HOME

命令行中输入```/usr/libexec/java_home```，可以看到输出：

/Library/Java/JavaVirtualMachines/jdk-9.0.1.jdk/Contents/Home

这就是我机器上，java home的路径

##### 4、插入PATH

vi ~/.bash_profile，Insert以下语句：

export JAVA_HOME=```/usr/libexec/java_home```

##### 5、让配置立即生效

source ~/.bash_profile

##### 6、查看已插入的JAVA_HOME

echo $JAVA_HOME

 如果可以看到刚刚配置的PATH则插入成功！