# Java 文件——流（Stream）的基本介绍

### 1. 流 Stream

Java中（绝大部分编程语言类似）文件一般不是单独处理，而是视为输入输出(I/O)设备的一种。
 Java使用统一的概念来处理所有的IO。包括键盘，终端，网络等。

- JavaIO的基本类位于java.io包下。

| Stream           | 含义           |
| ---------------- | -------------- |
| InputStream      | 表示输入流     |
| OutputStream     | 表示输出流     |
| FileInputStream  | 表示文件输入流 |
| FileOutputStream | 表示文件输出流 |

有了流的概念,就有了很多面向流的函数，输入输出都是抽象的流，提供流的加密、压缩等功能。
 一些实际上不是IO的数据源和目的地也转换成了流，以便参与流的整体概念体系的协作。
 例如，字节数组ByteArrayInputStream/ByteArrayOutputStream

### 2. 装饰器设计模式

基本的流按照字节读写，没有缓冲区，性能底下。Java使用装饰器模式引入很多装饰类对基本的流增加功能。
 一个装饰类一般只关注一个方面的功能。所以实际使用中经常需要使用多个装饰类。

Java中有很多装饰类。对流提供过滤功能有两个基类：FilterInputStream/FilterOutputSteam.
 过滤功能的装饰器对流提供一些功能包装，输入输出都是流。
 流的装饰器类成对出现，分别对应输入和输出流。
 FilterInputStream/FilterOutputSteam有很多子类，这里只列出出入的子类，输出的子类类似：

| FilterInputStream的子类 | 功能                             |
| ----------------------- | -------------------------------- |
| BufferedInputStream     | 对流起缓冲作用                   |
| DataInputStream         | 按照8种基本类型对流读写          |
| GZipInputStream         | 对流提供压缩功能                 |
| ZipInputStream          | 对流提供压缩功能                 |
| PrintStream             | 将基本类型，对象输出为字符串表示 |

### 3. Reader/Writer

以InputStream/OutputStream 为基类的流基本都是以二进制形式处理数据。
 不能方便的处理文本文件，没有编码概念。能方便的按字符处理文本的基类是Reader/Writer。

这两个类也有很多子类。

| Reader/Writer 的子类                | 功能                                          |
| ----------------------------------- | --------------------------------------------- |
| FileReader/FileWriter               | 读/写文件                                     |
| BufferedReader/BufferedWriter       | 缓冲读/写                                     |
| CharArrayReader/CharArrayWriter     | 将字符数组包装成流                            |
| StringReader/StringWriter           | 将字符串包装成流                              |
| InputStreamReader/InputStreamWriter | 转换InputStream/OutputStream和Reader/Writer   |
| PrintWrite                          | 输出Write中的基本类型，对象输出为其字符串表示 |

大部分情况下，使用流或者Reader/Writer读写文件内容。但Java还提供乐一个独立的可以随机读写文件的类RandomAccessFile。用于大小已知的文件。开发中用的较少。
 一些系统程序中用的较多。

以上介绍的类都是操作数据本身，而数据保存的载体，Java使用File类来表示，提供文件路径，文件元数据，临时文件，权限管理等功能。

### 4. Nio

上面的类都是位于`java.io`包下，Java中还有一个关于IO的操作包`java.nio`,`nio`的意思是New IO。
 它有缓冲区和通道的概念。

缓冲和通道概念更像是操作系统的概念。利用缓冲区和通道往往可以达成和流类似的目的，某些操作性能也更高，

例如：通道可以利用操作系统和硬件提供的DMA(direct memory access 直接内存存取)机制直接将数据从硬盘复制到网卡(不需要程序和CPU的参与)。

NIO还支持一些比较底层的功能。如 内存映射文件(常用)、文件加锁、自定义文件系统、非阻塞式IO,异步IO等。

### 5. Serialization/Deserialization 序列化 反序列化

Serialization 序列化：是指将内存中的java对象持久的保存到一个流中。
 Deserialization 反序列：是指将流中的对象恢复到java内存。

一般有两个用途：一个是对象持久化；另一个是网络远程调用。

Java主要通过interface `Serializable` 和class `ObjectInputStream/ObjectOutputStream`提供对序列化的支持。

Java的默认序列化有一些缺点：序列化后的形式较大浪费空间，序列化和反序列化的性能较低，java独有的格式，不能与其他语言交互。

#### 5.1 Xml/Json

Java对象可以序列化为xml格式,xml格式比较笨重，现在更多的使用Json格式。

XML/JSON都是文本格式，便于人阅读，但占用空间相对较大。在只用于网络远程调用的情况下，有很多其他的更高效的格式，比如ProtoBuf、Thrift,MessagePack.
 其中，MessagePack是二进制形式的JSON,更小更快。

### 6. 二进制文件和字节流

二进制读写流的类的有：

| 类名                                       | 说明                                         |
| ------------------------------------------ | -------------------------------------------- |
| InputStream/OutputStream                   | 抽象基类                                     |
| FileInputStream/FileOutputStream           | 输入源和输出目标是文件的流                   |
| ByteArrayInputStream/ByteArrayOutputStream | 输入源和输出目标是字节数组的流               |
| DataInputStream/DateOutputStream           | 装饰类，按照基本类型和字符串而非是字节读写流 |
| BufferedInputStream/BufferedOutputStream   | 装饰类，对输入输出流提供缓冲功能             |

#### 6.1 InputStream/OutputStream 抽象基类

##### 先介绍`InputStream`

6.1.1 InputStream的主要方法是 `public abstract int read() throw IOException`。

该抽象方法的一般实现是从流中读取下一个字节，返回取值范围是-1,0~255的int类型。
 当读取到流的结尾时返回`-1`,如果流中没有数据，`read()`方法会阻塞知道数据到来、流关闭或异常出现。

6.1.2 InputStream还有 `public int read(byte b[]) throws IOException` 方法，可以一次性读取多个字节。

- 读入的字节放入参数数组`b[]`中。返回读入的实际字节个数。实际字节个数小于(流读完了而没有读满)等于数组b的长度。
   如果刚开始读取就读到末尾则返回`-1`。否则该方法会尽力读取至少一个字节，如果流中没有字节则阻塞。
- 非抽象方法，有默认实现：循环读取一个字节的read方法，但是子类的实现一边更为高效。
- 流读取结束后都应该调用`close()`方法关闭释放资源。所以一般放入finally语句中。
   `close()`方法自身也可能抛出异常，但通常可以捕获并忽略。

6.1.3 InputStream中还定义了如下方法：



```java
1. public long skip(long n) throws IOException
2. public int available() throws IOException
3. public synchronized void mark(int readlimit)
4. public boolean markSupported()
5. public synchronized void reset() throws IOException
```

- `skip(long n)`方法跳过输入流中的n个字节,返回实际跳过的字节个数(流中剩余的字节个数可能小于n).
- `avaiable()` 返回下一次不需要阻塞就能读取到的大概字节个数，一般用在从网络读取数据时等到有足够数据才去读，防止阻塞。

一般的流都是一次性读取的，且只能按照输出的这一个方向读取，但是有时候希望能够先看下后面的内容，根据情况再重新读取。

比如处理一个未知的二进制文件，不确定其类型，我们可能可以通过流的前几十个字节判断其类型。然后重置到流开头。交给相应的代码处理。

InputStream定义了三个方法，用于支持从读过的流中重复读取：`mark reset markSupported`
 具体步骤是

1. 先使用 `mark(int readlimit)`将当前位置标记下来，readlimit表示往后可以读取的最多字节数。读取一些字节后(需要小于readlimit，否则标记失效)。
2. 调用`reset()`方法重置到mark标记的位置，

不是所有的流都支持mark reset方法。是否支持可以通过调用markSupported方法查看返回值确认。

InputStream 默认实现是不支持的，FileInputStream不支持，但`BufferedInputStream`和`ByteArrayInputStream`支持。

##### 接下来介绍 `OutputStream`

6.1.4 `OutputStream`的基本(主要)方法是 `public abstract void write(int b) throws IOException`
 向六中写入一个Byte字节，参数虽然是int,但只会用到最低的8bit(1Byte=8bit).

6.1.5 `OutputStream`还有两个批量写入的方法



```java
public void write(byte b[]) throws IOException
public void write(byte b[], int off, int len) throws IOException 
```

第二个方法，第一个写入的字节是b[off],写入个数len,最后一个是b[off+len-1].

6.1.6 `OutputStream`还有两个方法 flush close



```java
public void flush() throws IOException
public void close() throws IOException
```

`flush()`方法只对有缓冲的流起作用，其将流中缓冲而未实际写入的数据进行实际写入。
 比如在`BufferedOutputStream`中，调用flush方法会将其缓冲区的内容写到其装饰的流中，并调用该流的flush方法。
 基类OutputStream没有缓冲，flush方法为空。
 FileOutputStream没有缓冲，没有flush方法。

`close()`方法一般会先调用`flush()`方法，然后再释放占用的资源。
 同`InputOutStream`一样，`close()`方法应该放在finally块中。