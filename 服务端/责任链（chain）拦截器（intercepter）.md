# 责任链（chain）/拦截器（intercepter）

## 前言

责任连是web比较常用的设计模式（比如在request拦截，在内容过滤...），在android和ios中的比较核心部分也用到了这个设计模式（触摸拦截）

## 应用场景

比如现在服务器收到一个请求（request）,我们要过滤请求中的一些关键的字眼。比如现在`content = "<scrpit> 法伦功一定要灭掉，尼玛的，你妈的。中国政府真的太好了，呵呵，呵呵";`

### 场景一、把content的粗口`尼玛` `你妈`和敏感字眼`法伦功`过来掉

好，开工，首先我们把main方法写好，如下：

##### main.java

```java
/**
 * Created by liangjunjie on 16/7/21.
 */
public class Main {
    public static void main(String[] argus){
        //要被过滤的内容
        String content = "<scrpit> 法伦功一定要灭掉，尼玛的，你妈的。中国政府真的太好了，呵呵，呵呵";
        //过滤后的内容
        String filterContent = Filter.doFilter(content);
        //输出内容
        System.out.print(filterContent);
    }
}
```

然后我们再写Filter代码

#### Filter.java

```java
/**
 * Created by liangjunjie on 16/7/21.
 */
public class Filter {
    public static String doFilter(String content) {
        return content.replace("法伦功", "flg")
                .replace("尼玛", "xx")
                .replace("你妈", "xx");
    }
}
```

> 就这样，我们完成了过滤粗口的功能。
> 结果如下：
>
> ![image_1ao67qt292fi1cj4dk93cbn09.png-36.9kB](http://static.zybuluo.com/Vankain/rlzo6oc66f8uo88924jk0ztu/image_1ao67qt292fi1cj4dk93cbn09.png)
>
> image_1ao67qt292fi1cj4dk93cbn09.png-36.9kB

### 场景二、把content的敏感字眼`政府`也过滤掉

看到这个场景，感觉很简单，main.java不用动，只要把fiter.java改一改就可以。

#### Fiter.java

```java
/**
 * Created by liangjunjie on 16/7/21.
 */
public class Filter {
    public static String doFilter(String content) {
        return content.replace("法伦功", "flg")
                .replace("尼玛", "xx")
                .replace("你妈", "xx")
                .replace("政府", "zf");
    }
}
```

> 输出结果如下：
>
> ![image_1ao67tvvl1jlg1tgr18741fdc1ukom.png-37kB](http://static.zybuluo.com/Vankain/jwriwjssqobqrun20dr89u9q/image_1ao67tvvl1jlg1tgr18741fdc1ukom.png)
>
> image_1ao67tvvl1jlg1tgr18741fdc1ukom.png-37kB

### 场景三、把content的特殊字符标签`<scrpit>`过滤掉,防止别人搞乱我们的网站

按照上面的操作，只要在fiter.java增加`replace("<scrpit>", "");`就可以。

但是看到这里，我们该反思，这种做法会给我们带来很多问题：

- 问题1：难道我们就每次新增过滤需求，我们就去改Filter的代码？这违背了设计的`开放扩展，关闭修改`的原则，这样改很容易出bug。
- 问题二：如果现在有1000个要过滤的词，那么是不是在那里加上1000个呢？
- 问题三：假如我有些词语在一些地方要过滤，在另外的地方又不用过滤呢？（**比如聊天时候，我为了让用户能淋漓尽致地表达他的情绪，我们能可以让他发粗口，在发帖子的时候，我们就把他粗口关键词过滤掉**）

解决方法：

- 第一：我们应该把过滤的规则（词语）交给main设定，这样子，可扩展性就大大增加，也关闭了对实现类的修改。
- 第二：可以增加一个配置文件。（以下不解决这个设计模式外的问题）
- 第三：我们应该把这些过滤的词语进行分类，这样子就能很好地自由组合，可扩展性大大增加。

为了以上的三个问题，我们重新设计了一下main.java

#### 这个链条流程就是这样

![image_1ao6at2hnb03e6s18l31igr1b651g.png-33.6kB](http://static.zybuluo.com/Vankain/5sxgshwf8fvoqxjy5ugc8cu6/image_1ao6at2hnb03e6s18l31igr1b651g.png)

image_1ao6at2hnb03e6s18l31igr1b651g.png-33.6kB

#### main.java

```java
/**
 * Created by liangjunjie on 16/7/21.
 */
public class Main {
    public static void main(String[] argus) {
        //要被过滤的内容
        String content = "<scrpit> 法伦功一定要灭掉，尼玛的，你妈的。中国政府真的太好了，呵呵，呵呵";
        //新建一个『过滤链条』
        FilterChain filterChain = new FilterChain();
        //在过滤链条中添加过滤规则
        filterChain.addFilter(new FuckFilter())
                .addFilter(new SensitiveFilter());
        //过滤后的内容
        String filterContent = filterChain.doChainFilter(content);
        //输出内容
        System.out.print(filterContent);
    }
}
```

#### Filter.java - 不再是具体类了，是一个接口

```java
/**
 * Created by liangjunjie on 16/7/21.
 */
public interface Filter {
    String doFilter(String content);
}
```

#### 再看看出现的新类，FilterChain，FuckFilter，SensitiveFilter

#### FilterChain.java - 过滤链（拦截链）

```java
/**
 * Created by liangjunjie on 16/7/21.
 */
public class FilterChain {
    public List<Filter> mFilters = new ArrayList<>();


    public FilterChain addFilter(Filter filter){
        mFilters.add(filter);
        return this;
    }

    public String doChainFilter(String content) {
        for(Filter filter : mFilters){
            content = filter.doFilter(content);
        }
        return content;
    }
}
```

#### FuckFilter.java - 粗口过滤器

```java
/**
 * Created by liangjunjie on 16/7/21.
 */
public class FuckFilter implements Filter {
    @Override
    public String doFilter(String content) {
        return content.replace("尼玛", "xx")
                .replace("你妈", "xx");
    }
}
```

#### SensitiveFilter.java - 敏感字词过滤器

```java
/**
 * Created by liangjunjie on 16/7/21.
 */
public class SensitiveFilter implements Filter {
    @Override
    public String doFilter(String content) {
        return content
                .replace("法伦功", "flg")
                .replace("政府", "zf");
    }
}
```

> 运行结果：
>
> ![image_1ao68fi8l1foj1m0l4g5lspvli13.png-34kB](http://static.zybuluo.com/Vankain/mcc1cvah5urvigpjg96uq85z/image_1ao68fi8l1foj1m0l4g5lspvli13.png)
>
> image_1ao68fi8l1foj1m0l4g5lspvli13.png-34kB

> 这样子，以后我们要新增不同种类的过滤器，我们直接新建一个类就可以（比如过滤特殊标签`<scprit>`，我们新建一个TagFilter.java就可以，这里不再列出具体的实现）。

> 现在的修改解决了上面遗留的问题，

1. 每次增加或删除过滤的词语，不用再去修改具体的实现类。
2. 可以根据业务自由组合过滤规则。

### 场景四、我们现在要求，过滤链中能添加一个过滤链，改怎么改呢？需求入下图：![image_1ao6b538v17q61jn0k0hhho14gn1t.png-48.4kB](http://static.zybuluo.com/Vankain/yls6j8jobrloxqmvq45a0v2r/image_1ao6b538v17q61jn0k0hhho14gn1t.png)image_1ao6b538v17q61jn0k0hhho14gn1t.png-48.4kB

出现了这个功能，我们可以看看具体main.java就可以这样写了：

#### main.java

```java
/**
 * Created by liangjunjie on 16/7/21.
 */
public class Main {
    public static void main(String[] argus) {
        //要被过滤的内容
        String content = "<scrpit> 法伦功一定要灭掉，尼玛的，你妈的。中国政府真的太好了，呵呵，呵呵";
        //新建一个『过滤链条』
        FilterChain filterChain = new FilterChain();
        //在过滤链条中添加过滤规则
        filterChain.addFilter(new FuckFilter())
                .addFilter(new SensitiveFilter());
        //在一个过滤链中加上一个过滤链
        FilterChain filterChain1 = new FilterChain();
        filterChain1.addFilter(new TagFilter())
                .addFilter(filterChain);
        //过滤后的内容
        String filterContent = filterChain1.doFilter(content);
        //输出内容
        System.out.print(filterContent);
    }
}
```

#### FilterChain.java 现在这个类都继承Filter接口就可以

```java
/**
 * Created by liangjunjie on 16/7/21.
 */
public class FilterChain implements Filter {
    public List<Filter> mFilters = new ArrayList<>();
    
    public FilterChain addFilter(Filter filter){
        mFilters.add(filter);
        return this;
    }

    @Override
    public String doFilter(String content) {
        for(Filter filter : mFilters){
            content = filter.doFilter(content);
        }
        return content;
    }
}
```

> 这样就实现具体的过滤链上新增过滤链，也很好理解，因为过滤链也属于一个过滤规则，所以过滤链也实现Filter接口。

## 局部小结：

上面我们实现了过滤器的效果，但是这还不是责任链的全部，再来看一个需求。

### 场景六、一般有request过滤，就会又response过滤

![image_1ao6ds6it3ro108ackdqgm19qr2a.png-38.7kB](http://static.zybuluo.com/Vankain/yah5tqnmhontabmwxr5ihaj9/image_1ao6ds6it3ro108ackdqgm19qr2a.png)

image_1ao6ds6it3ro108ackdqgm19qr2a.png-38.7kB

上面我们实现了request过滤了。上面我们如果现在我们要实现response过滤呢？先看看结果（response规则把敏感词语代替掉---，把粗口代替掉++）：



![image_1ao6e032mmhjfoh1m0uq5b1tne2n.png-50.9kB](http://static.zybuluo.com/Vankain/j1toozul2exy742oft6gsu5n/image_1ao6e032mmhjfoh1m0uq5b1tne2n.png)

image_1ao6e032mmhjfoh1m0uq5b1tne2n.png-50.9kB

### 看看一下代码

#### main.java

```java
/**
 * Created by liangjunjie on 16/7/21.
 */
public class Main {
    public static void main(String[] argus) {
        //要被过滤的内容
        String content = "<scrpit> 法伦功一定要灭掉，尼玛的，你妈的。中国政府真的太好了，呵呵，呵呵";
        //请求和应答
        Request request = new Request();
        request.setRequestStr(content);
        Response response = new Response();
        response.setResponseStr(content);
        //新建一个『过滤链条』
        FilterChain filterChain = new FilterChain();
        //在过滤链条中添加过滤规则
        filterChain.addFilter(new FuckFilter())
                .addFilter(new SensitiveFilter());

        //过滤后的内容
        filterChain.doFilter(request, response);
        //输出内容
        System.out.println(request.getRequestStr());
        System.out.println(response.getResponseStr());

    }
}
```

#### Filter接口更改

```java
/**
 * Created by liangjunjie on 16/7/21.
 */
public interface Filter {
    void doFilter(Request request, Response response);
}
```

#### 其他实现接口的类 SensitiveFilter.java

```java
/**
 * Created by liangjunjie on 16/7/21.
 */
public class SensitiveFilter implements Filter {

    @Override
    public void doFilter(Request request, Response response) {
        String requestFilterStr = request.getRequestStr()
                .replace("法伦功", "flg")
                .replace("政府", "zf");
        request.setRequestStr(requestFilterStr);

        String responseFilterStr = response.getResponseStr()
                .replace("法伦功", "---")
                .replace("政府", "--");
        response.setResponseStr(responseFilterStr + "|SensitiveFilter");
    }
}
```

#### FuckFilter.java

```java
/**
 * Created by liangjunjie on 16/7/21.
 */
public class FuckFilter implements Filter {

    @Override
    public void doFilter(Request request, Response response) {
            String requestFilterStr = request.getRequestStr()
                    .replace("尼玛", "xx")
                    .replace("你妈", "xx");
            request.setRequestStr(requestFilterStr);

            String responseFilterStr = response.getResponseStr()
                    .replace("尼玛", "++")
                    .replace("你妈", "++");
            response.setResponseStr(responseFilterStr + "|FuckFilter");
    }

}
```

#### FilterChain.java

```java
/**
 * Created by liangjunjie on 16/7/21.
 */
public class FilterChain implements Filter {
    public List<Filter> mFilters = new ArrayList<>();


    public FilterChain addFilter(Filter filter){
        mFilters.add(filter);
        return this;
    }


    @Override
    public void doFilter(Request request, Response response) {
        for(Filter filter : mFilters){
            filter.doFilter(request, response);
        }
    }
}
```

#### request

```java
public class Request {
    String requestStr;
    public String getRequestStr() {
        return requestStr;
    }

    public void setRequestStr(String requestStr) {
        this.requestStr = requestStr;
    }
}
```

#### response

```java
public class Response {
    String responseStr;
    public String getResponseStr() {
        return responseStr;
    }

    public void setResponseStr(String responseStr) {
        this.responseStr = responseStr;
    }
}
```

> 可以看到结果是：
>
> ![image_1ao6e032mmhjfoh1m0uq5b1tne2n.png-50.9kB](http://static.zybuluo.com/Vankain/j1toozul2exy742oft6gsu5n/image_1ao6e032mmhjfoh1m0uq5b1tne2n.png)
>
> image_1ao6e032mmhjfoh1m0uq5b1tne2n.png-50.9kB

### 场景七，更换response的过滤顺序

在上面的例子里，不知道你有没有发现response的过滤是跟request过滤的顺序一样的，如下图：

![image_1ao6ekgl7e1g184114qh17nm1ehq34.png-48.7kB](http://static.zybuluo.com/Vankain/e75zkj3hi3m5jokqkdaaasti/image_1ao6ekgl7e1g184114qh17nm1ehq34.png)

image_1ao6ekgl7e1g184114qh17nm1ehq34.png-48.7kB


假如现在需求是这样，response的处理跟request的处理倒序，如下图需求：

![image_1ao6eockd137o1kjo1b6616nqqb23h.png-54.7kB](http://static.zybuluo.com/Vankain/b3oav1j4beb10zk2kjovo04l/image_1ao6eockd137o1kjo1b6616nqqb23h.png)

image_1ao6eockd137o1kjo1b6616nqqb23h.png-54.7kB


可以看到上图的顺序，request 的时候是，再到，回来的时候是调转的，先, 再到。这样就形成一个过滤栈了，安卓的事件分发就是这样做的。以下是具体代码（安卓的事件分发跟以下代码有点出入，但是原理是一样的，后面有解释）：

#### main.java

```java
/**
 * Created by liangjunjie on 16/7/21.
 */
public class Main {
    public static void main(String[] argus) {
        //要被过滤的内容
        String content = "<scrpit> 法伦功一定要灭掉，尼玛的，你妈的。中国政府真的太好了，呵呵，呵呵";
        Request request = new Request();
        request.setRequestStr(content);
        Response response = new Response();
        response.setResponseStr(content);
        //新建一个『过滤链条』
        FilterChain filterChain = new FilterChain();
        //在过滤链条中添加过滤规则
        filterChain.addFilter(new FuckFilter())
                .addFilter(new SensitiveFilter());

        //过滤后的内容
        filterChain.doFilter(request, response, filterChain);
        //输出内容
        System.out.println(request.getRequestStr());
        System.out.println(response.getResponseStr());

    }
}
```

#### request.java

```java
public class Request {
    String requestStr;

    public String getRequestStr() {
        return requestStr;
    }

    public void setRequestStr(String requestStr) {
        this.requestStr = requestStr;
    }
}
```

#### response.java

```java
public class Response {
    String responseStr;

    public String getResponseStr() {
        return responseStr;
    }

    public void setResponseStr(String responseStr) {
        this.responseStr = responseStr;
    }

}
```

#### FilterChain.java

```java
/**
 * Created by liangjunjie on 16/7/21.
 */
public class FilterChain implements Filter {
    public List<Filter> mFilters = new ArrayList<>();
    public int index = 0;


    public FilterChain addFilter(Filter filter){
        mFilters.add(filter);
        return this;
    }


    @Override
    public void doFilter(Request request, Response response, Filter chain) {
        if(index == mFilters.size()) return;
        Filter filter = mFilters.get(index);
        index ++;
        filter.doFilter(request, response, this);
    }

}
```

#### Filter.java

```java
/**
 * Created by liangjunjie on 16/7/21.
 */
public interface Filter {
    void doFilter(Request request, Response response, Filter chainFilter);
}
```

#### FuckFilter.java

```java
/**
 * Created by liangjunjie on 16/7/21.
 */
public class FuckFilter implements Filter {

    @Override
    public void doFilter(Request request, Response response, Filter chainFilter) {
           String requestFilterStr = request.getRequestStr()
                .replace("尼玛", "xx")
                .replace("你妈", "xx");
        request.setRequestStr(requestFilterStr);

        chainFilter.doFilter(request, response, chainFilter);
//
        String responseFilterStr = response.getResponseStr()
                .replace("尼玛", "++")
                .replace("你妈", "++");
        response.setResponseStr(responseFilterStr + "|FuckFilter");
    }
}
```

#### SensitiveFilter.java

```java
/**
 * Created by liangjunjie on 16/7/21.
 */
public class SensitiveFilter implements Filter {

    @Override
    public void doFilter(Request request, Response response, Filter chainFilter) {
        String requestFilterStr = request.getRequestStr()
                .replace("法伦功", "flg")
                .replace("政府", "zf");
        request.setRequestStr(requestFilterStr);

        chainFilter.doFilter(request, response, chainFilter);

        String responseFilterStr = response.getResponseStr()
                .replace("法伦功", "---")
                .replace("政府", "--");
        response.setResponseStr(responseFilterStr + "|SensitiveFilter");
    }
}
```

安卓跟上面例子不同的是，安卓是父控件和子控件的一层一层拦截，他们都会调用下一个控件的 dispatchEvent ，递归调用。而上面例子的拦截器是没有安卓中的父子关系，所以有那么一点点区别。