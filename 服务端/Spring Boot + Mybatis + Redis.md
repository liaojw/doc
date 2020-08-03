# Spring Boot + Mybatis + Redis二级缓存开发指南
## 背景
Spring-Boot因其提供了各种开箱即用的插件，使得它成为了当今最为主流的Java Web开发框架之一。Mybatis是一个十分轻量好用的ORM框架。Redis是当今十分主流的分布式key-value型数据库，在web开发中，我们常用它来缓存数据库的查询结果。
###本文的示例代码可在Github中下载：[https://github.com/Lovelcp/spring-boot-mybatis-with-redis/tree/master](https://github.com/Lovelcp/spring-boot-mybatis-with-redis/tree/master)

## 环境

* 开发环境：mac 10.11
* ide：Intellij 2017.1
* jdk：1.8
* Spring-Boot：1.5.3.RELEASE
* Redis：3.2.9
* Mysql：5.7



## Spring-Boot

### 新建项目
首先，我们需要初始化我们的Spring-Boot工程。通过Intellij的Spring Initializer，新建一个Spring-Boot工程变得十分简单。首先我们在Intellij中选择New一个Project：

![http://static.codeceo.com/images/2017/05/481994d2fc0fd97f851ab54b8762c22a.jpg](http://static.codeceo.com/images/2017/05/481994d2fc0fd97f851ab54b8762c22a.jpg)

然后在选择依赖的界面，勾选Web、Mybatis、Redis、Mysql、H2：

![http://static.codeceo.com/images/2017/05/6217da6a9156fdabc0c8d09585205a8c.jpg](http://static.codeceo.com/images/2017/05/6217da6a9156fdabc0c8d09585205a8c.jpg)

新建工程成功之后，我们可以看到项目的初始结构如下图所示：

![http://static.codeceo.com/images/2017/05/48d35fcb18a880c73e3679f9b11cb116.jpg](http://static.codeceo.com/images/2017/05/48d35fcb18a880c73e3679f9b11cb116.jpg)

Spring Initializer已经帮我们自动生成了一个启动类——`SpringBootMybatisWithRedisApplication`。该类的代码十分简单：

```
@SpringBootApplication
public class SpringBootMybatisWithRedisApplication {
	public static void main(String[] args) {
		SpringApplication.run(SpringBootMybatisWithRedisApplication.class, args);
	}
}
```

`@SpringBootApplication`注解表示启用Spring Boot的自动配置特性。好了，至此我们的项目骨架已经搭建成功，感兴趣的读者可以通过Intellij启动看看效果。

### 新建API接口
接下来，我们要编写Web API。假设我们的Web工程负责处理商家的产品（Product）。我们需要提供根据product id返回product信息的get接口和更新product信息的put接口。首先我们定义Product类，该类包括产品id，产品名称name以及价格price：

```
public class Product implements Serializable {
    private static final long serialVersionUID = 1435515995276255188L;
    private long id;
    private String name;
    private long price;
    // getters setters
}
```

然后我们需要定义Controller类。由于Spring Boot内部使用Spring MVC作为它的Web组件，所以我们可以通过注解的方式快速开发我们的接口类：

```
@RestController
@RequestMapping("/product")
public class ProductController {
    @GetMapping("/{id}")
    public Product getProductInfo(
            @PathVariable("id")
                    Long productId) {
        // TODO
        return null;
    }
    @PutMapping("/{id}")
    public Product updateProductInfo(
            @PathVariable("id")
                    Long productId,
            @RequestBody
                    Product newProduct) {
        // TODO
        return null;
    }
}
```

我们简单介绍一下上述代码中所用到的注解的作用：

* `@RestController`：表示该类为Controller，并且提供Rest接口，即所有接口的值以Json格式返回。该注解其实是`@Controller`和`@ResponseBody`的组合注解，便于我们开发[REST API](http://www.codeceo.com/article/rest-api.html)。
* `@RequestMapping`、`@GetMapping`、`@PutMapping`：表示接口的URL地址。标注在类上的`@RequestMapping`注解表示该类下的所有接口的URL都以`/product`开头。`@GetMapping`表示这是一个Get HTTP接口，`@PutMapping`表示这是一个Put HTTP接口。
* `@PathVariable`、`@RequestBody`：表示参数的映射关系。假设有个Get请求访问的是`/product/123`，那么该请求会由`getProductInfo`方法处理，其中URL里的123会被映射到productId中。同理，如果是Put请求的话，请求的body会被映射到`newProduct`对象中。

这里我们只定义了接口，实际的处理逻辑还未完成，因为product的信息都存在数据库中。接下来我们将在项目中集成mybatis，并且与数据库做交互。

### 集成Mybatis
#### 配置数据源
首先我们需要在配置文件中配置我们的数据源。我们采用mysql作为我们的数据库。这里我们采用yaml作为我们配置文件的格式。我们在resources目录下新建application.yml文件：

```
spring:
  # 数据库配置
  datasource:
    url: jdbc:mysql://{your_host}/{your_db}
    username: {your_username}
    password: {your_password}
    driver-class-name: org.gjt.mm.mysql.Driver
```

由于Spring Boot拥有自动配置的特性，我们不用新建一个DataSource的配置类，Sping Boot会自动加载配置文件并且根据配置文件的信息建立数据库的连接池，十分便捷。

> 笔者推荐大家采用yaml作为配置文件的格式。xml显得冗长，properties没有层级结构，yaml刚好弥补了这两者的缺点。这也是Spring Boot默认就支持yaml格式的原因。

#### 配置Mybatis
我们已经通过Spring Initializer在pom.xml中引入了`mybatis-spring-boot-starte`库，该库会自动帮我们初始化mybatis。首先我们在application.yml中指定mybatis的配置文件：

```
# mybatis配置
mybatis:
  config-location: classpath:mybatis-config.xml
```

然后我们在resources目录下新建`mybatis-config.xml`文件。在配置文件中，我们需要指定Product类以及mapper文件的路径：

```
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <typeAliases>
        <package name="com.wooyoo.learning.dao.domain"/>
    </typeAliases>
    <mappers>
        <mapper resource="mappers/ProductMapper.xml"/>
    </mappers>
</configuration>
```

接下来，我们再在resourses目录下新建mappers目录，并且新建`ProductMapper.xml`文件，编写操作products表的SQL语句（该文件的内容请参考笔者在前文贴的[Github仓库地址](https://github.com/Lovelcp/spring-boot-mybatis-with-redis/tree/master)）。最后，再在代码中定义`ProductMapper`类：

```
@Mapper
public interface ProductMapper {
    Product select(
            @Param("id")
                    long id);
    void update(Product product);
}
```

> Spring Boot之所以这么流行，最大的原因是它自动配置的特性。开发者只需要关注组件的配置（比如数据库的连接信息），而无需关心如何初始化各个组件，这使得我们可以集中精力专注于业务的实现，简化开发流程。

#### 访问数据库
完成了Mybatis的配置之后，我们就可以在我们的接口中访问数据库了。我们在`ProductController`下通过`@Autowired`引入mapper类，并且调用对应的方法实现对product的查询和更新操作，这里我们以查询接口为例：

```
@RestController
@RequestMapping("/product")
public class ProductController {
    @Autowired
    private ProductMapper productMapper;
    @GetMapping("/{id}")
    public Product getProductInfo(
            @PathVariable("id")
                    Long productId) {
        return productMapper.select(productId);
    }
    // 避免篇幅过长，省略updateProductInfo的代码
}
```

然后在你的mysql中插入几条product的信息，就可以运行该项目看看是否能够查询成功了。

至此，我们已经成功地在项目中集成了Mybatis，增添了与数据库交互的能力。但是这还不够，一个现代化的Web项目，肯定会上缓存加速我们的数据库查询。接下来，将介绍如何科学地将Redis集成到Mybatis的二级缓存中，实现数据库查询的自动缓存。

### 集成Redis
#### 配置Redis
同访问数据库一样，我们需要配置Redis的连接信息。在application.yml文件中增加如下配置：

```
spring:
  redis:
    # redis数据库索引（默认为0），我们使用索引为3的数据库，避免和其他数据库冲突
    database: 3
    # redis服务器地址（默认为localhost）
    host: localhost
    # redis端口（默认为6379）
    port: 6379
    # redis访问密码（默认为空）
    password:
    # redis连接超时时间（单位为毫秒）
    timeout: 0
    # redis连接池配置
    pool:
      # 最大可用连接数（默认为8，负数表示无限）
      max-active: 8
      # 最大空闲连接数（默认为8，负数表示无限）
      max-idle: 8
      # 最小空闲连接数（默认为0，该值只有为正数才有作用）
      min-idle: 0
      # 从连接池中获取连接最大等待时间（默认为-1，单位为毫秒，负数表示无限）
      max-wait: -1
```

上述列出的都为常用配置，读者可以通过注释信息了解每个配置项的具体作用。由于我们在pom.xml中已经引入了`spring-boot-starter-data-redis`库，所以Spring Boot会帮我们自动加载Redis的连接，具体的配置类`org.springframework.boot.autoconfigure.data.redis.RedisAutoConfiguration`。通过该配置类，我们可以发现底层默认使用Jedis库，并且提供了开箱即用的`redisTemplate`和`stringTemplate`。

#### 将Redis作为二级缓存
Mybatis的二级缓存原理本文不再赘述，读者只要知道，Mybatis的二级缓存可以自动地对数据库的查询做缓存，并且可以在更新数据时同时自动地更新缓存。

实现Mybatis的二级缓存很简单，只需要新建一个类实现`org.apache.ibatis.cache.Cache`接口即可。

该接口共有以下五个方法：

* `String getId()`：mybatis缓存操作对象的标识符。一个mapper对应一个mybatis的缓存操作对象。
* `void putObject(Object key, Object value)`：将查询结果塞入缓存。
* `Object getObject(Object key)`：从缓存中获取被缓存的查询结果。
* `Object removeObject(Object key)`：从缓存中删除对应的key、value。只有在回滚时触发。一般我们也可以不用实现，具体使用方式请参考：`org.apache.ibatis.cache.decorators.TransactionalCache`。
* `void clear()`：发生更新时，清除缓存。
* `int getSize()`：可选实现。返回缓存的数量。
* `ReadWriteLock getReadWriteLock()`：可选实现。用于实现原子性的缓存操作。

接下来，我们新建`RedisCache`类，实现`Cache`接口：

```
public class RedisCache implements Cache {
    private static final Logger logger = LoggerFactory.getLogger(RedisCache.class);
    private final ReadWriteLock readWriteLock = new ReentrantReadWriteLock();
    private final String id; // cache instance id
    private RedisTemplate redisTemplate;
    private static final long EXPIRE_TIME_IN_MINUTES = 30; // redis过期时间
    public RedisCache(String id) {
        if (id == null) {
            throw new IllegalArgumentException("Cache instances require an ID");
        }
        this.id = id;
    }
    @Override
    public String getId() {
        return id;
    }
    /**
     * Put query result to redis
     *
     * @param key
     * @param value
     */
    @Override
    @SuppressWarnings("unchecked")
    public void putObject(Object key, Object value) {
        RedisTemplate redisTemplate = getRedisTemplate();
        ValueOperations opsForValue = redisTemplate.opsForValue();
        opsForValue.set(key, value, EXPIRE_TIME_IN_MINUTES, TimeUnit.MINUTES);
        logger.debug("Put query result to redis");
    }
    /**
     * Get cached query result from redis
     *
     * @param key
     * @return
     */
    @Override
    public Object getObject(Object key) {
        RedisTemplate redisTemplate = getRedisTemplate();
        ValueOperations opsForValue = redisTemplate.opsForValue();
        logger.debug("Get cached query result from redis");
        return opsForValue.get(key);
    }
    /**
     * Remove cached query result from redis
     *
     * @param key
     * @return
     */
    @Override
    @SuppressWarnings("unchecked")
    public Object removeObject(Object key) {
        RedisTemplate redisTemplate = getRedisTemplate();
        redisTemplate.delete(key);
        logger.debug("Remove cached query result from redis");
        return null;
    }
    /**
     * Clears this cache instance
     */
    @Override
    public void clear() {
        RedisTemplate redisTemplate = getRedisTemplate();
        redisTemplate.execute((RedisCallback) connection -> {
            connection.flushDb();
            return null;
        });
        logger.debug("Clear all the cached query result from redis");
    }
    @Override
    public int getSize() {
        return 0;
    }
    @Override
    public ReadWriteLock getReadWriteLock() {
        return readWriteLock;
    }
    private RedisTemplate getRedisTemplate() {
        if (redisTemplate == null) {
            redisTemplate = ApplicationContextHolder.getBean("redisTemplate");
        }
        return redisTemplate;
    }
}
```

讲解一下上述代码中一些**关键点**：

* 自己实现的二级缓存，必须要有一个带id的构造函数，否则会报错。
* 我们使用Spring封装的`redisTemplate`来操作Redis。网上所有介绍redis做二级缓存的文章都是直接用jedis库，但是笔者认为这样不够Spring Style，而且，`redisTemplate`封装了底层的实现，未来如果我们不用jedis了，我们可以直接更换底层的库，而不用修改上层的代码。更方便的是，使用`redisTemplate`，我们不用关心redis连接的释放问题，否则新手很容易忘记释放连接而导致应用卡死。
* 需要注意的是，这里不能通过autowire的方式引用`redisTemplate`，因为`RedisCache`并不是Spring容器里的bean。所以我们需要手动地去调用容器的`getBean`方法来拿到这个bean，具体的实现方式请参考Github中的代码。
* 我们采用的redis序列化方式是默认的jdk序列化。所以数据库的查询对象（比如Product类）需要实现`Serializable`接口。

这样，我们就实现了一个优雅的、科学的并且具有Spring Style的Redis缓存类。

#### 开启二级缓存
接下来，我们需要在`ProductMapper.xml`中开启二级缓存：

```
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.wooyoo.learning.dao.mapper.ProductMapper">
    <!-- 开启基于redis的二级缓存 -->
    <cache type="com.wooyoo.learning.util.RedisCache"/>
    <select id="select" resultType="Product">
        SELECT * FROM products WHERE id = #{id} LIMIT 1
    </select>
    <update id="update" parameterType="Product" flushCache="true">
        UPDATE products SET name = #{name}, price = #{price} WHERE id = #{id} LIMIT 1
    </update>
</mapper>
```

`<cache type="com.wooyoo.learning.util.RedisCache"/>`表示开启基于redis的二级缓存，并且在update语句中，我们设置`flushCache`为`true`，这样在更新product信息时，能够自动失效缓存（本质上调用的是clear方法）。

### 测试
#### 配置H2内存数据库
至此我们已经完成了所有代码的开发，接下来我们需要书写单元测试代码来测试我们代码的质量。我们刚才开发的过程中采用的是mysql数据库，而一般我们在测试时经常采用的是内存数据库。这里我们使用H2作为我们测试场景中使用的数据库。

要使用H2也很简单，只需要跟使用mysql时配置一下即可。在application.yml文件中：

```
---
spring:
  profiles: test
  # 数据库配置
  datasource:
    url: jdbc:h2:mem:test
    username: root
    password: 123456
    driver-class-name: org.h2.Driver
    schema: classpath:schema.sql
    data: classpath:data.sql
```

为了避免和默认的配置冲突，我们用`---`另起一段，并且用`profiles: test`表明这是test环境下的配置。然后只要在我们的测试类中加上`@ActiveProfiles(profiles = "test")`注解来启用test环境下的配置，这样就能一键从mysql数据库切换到h2数据库。

在上述配置中，schema.sql用于存放我们的建表语句，data.sql用于存放insert的数据。这样当我们测试时，h2就会读取这两个文件，初始化我们所需要的表结构以及数据，然后在测试结束时销毁，不会对我们的mysql数据库产生任何影响。这就是内存数据库的好处。另外，别忘了在pom.xml中将h2的依赖的scope设置为test。

> 使用Spring Boot就是这么简单，无需修改任何代码，轻松完成数据库在不同环境下的切换。

#### 编写测试代码
因为我们是通过Spring Initializer初始化的项目，所以已经有了一个测试类——`SpringBootMybatisWithRedisApplicationTests`。

Spring Boot提供了一些方便我们进行Web接口测试的工具类，比如`TestRestTemplate`。然后在配置文件中我们将log等级调成DEBUG，方便观察调试日志。具体的测试代码如下：

```
@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles(profiles = "test")
public class SpringBootMybatisWithRedisApplicationTests {
    @LocalServerPort
    private int port;
    @Autowired
    private TestRestTemplate restTemplate;
    @Test
    public void test() {
        long productId = 1;
        Product product = restTemplate.getForObject("http://localhost:" + port + "/product/" + productId, Product.class);
        assertThat(product.getPrice()).isEqualTo(200);
        Product newProduct = new Product();
        long newPrice = new Random().nextLong();
        newProduct.setName("new name");
        newProduct.setPrice(newPrice);
        restTemplate.put("http://localhost:" + port + "/product/" + productId, newProduct);
        Product testProduct = restTemplate.getForObject("http://localhost:" + port + "/product/" + productId, Product.class);
        assertThat(testProduct.getPrice()).isEqualTo(newPrice);
    }
}
```

在上述测试代码中：

* 我们首先调用get接口，通过assert语句判断是否得到了预期的对象。此时该product对象会存入redis中。
* 然后我们调用put接口更新该product对象，此时redis缓存会失效。
* 最后我们再次调用get接口，判断是否获取到了新的product对象。如果获取到老的对象，说明缓存失效的代码执行失败，代码存在错误，反之则说明我们代码是OK的。

> 书写单元测试是一个良好的编程习惯。虽然会占用你一定的时间，但是当你日后需要做一些重构工作时，你就会感激过去写过单元测试的自己

#### 查看测试结果
我们在Intellij中点击执行测试用例，测试结果如下：

![http://static.codeceo.com/images/2017/05/c20f3dad0fcfe8d3d97bd961447897f0.jpg](http://static.codeceo.com/images/2017/05/c20f3dad0fcfe8d3d97bd961447897f0.jpg)

真棒，显示的是绿色，说明测试用例执行成功了。

### 总结
本篇文章介绍了如何通过Spring Boot、Mybatis以及Redis快速搭建一个现代化的Web项目，并且同时介绍了如何在Spring Boot下优雅地书写单元测试来保证我们的代码质量。当然这个项目还存在一个问题，那就是mybatis的二级缓存只能通过flush整个DB来实现缓存失效，这个时候可能会把一些不需要失效的缓存也给失效了，所以具有一定的局限性。

## 参考资料

* [http://www.baeldung.com/spring-data-redis-tutorial](http://www.baeldung.com/spring-data-redis-tutorial)
* [http://chrisbaileydeveloper.com/projects/spring-boot-redis-heroku-demo/](http://chrisbaileydeveloper.com/projects/spring-boot-redis-heroku-demo/)
* [http://docs.spring.io/spring-data/redis/docs/1.6.2.RELEASE/reference/html/](http://docs.spring.io/spring-data/redis/docs/1.6.2.RELEASE/reference/html/)
* [http://blog.didispace.com/springbootredis/](http://blog.didispace.com/springbootredis/)
