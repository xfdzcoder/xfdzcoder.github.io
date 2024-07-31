---
url: /7224237482966319105
title: 'SpringMVC中整合的Jackson从请求体解析参数流程的源码分析'
date: 2024-03-22T16:35:09+08:00
draft: false
summary: ""
categories: [Java]
tags: ['top', 'ssm']
---

# SpringMVC中整合的Jackson从请求体解析参数流程的源码分析

环境：

springboot: 2.7.6

废话不多写，发车了。

还是从老熟人`DispatcherServlet` 的`doDispatch` 方法里的 `mv = ha.handle(processedRequest, response, mappedHandler.getHandler());`说起

![image-20221212223153973](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F31%2F11-16-43-fa9c94d2770679dfce965f4b0ffea9d5-202301052342717-c27b8f.png)

然后进入到`org.springframework.web.servlet.mvc.method.AbstractHandlerMethodAdapter#handle`

![image-20221212223552198](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F31%2F11-17-08-2a1bbb767dd189ad4d0479e549466685-202301052342432-44be7d.png)

这里的实际逻辑是在一个由其子类实现的方法中：`org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter#handleInternal`

![image-20221212223946853](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F31%2F11-16-47-9dbd6516c49f1ae589296c89fa7d6ffc-202301052342079-65a486.png)

这里大都是一样的，就不赘述了

![image-20221212224040501](SpringMVC中整合的Jackson从请求体解析参数流程的源码分析.assets/image-20221212224040501.png)

![image-20221212224100557](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F31%2F11-16-49-1d6b09d71717add48e92afe68101dba2-202301052342095-f8a8f1.png)

## 正文

在`org.springframework.web.method.support.InvocableHandlerMethod#invokeForRequest`中会根据方法参数获取对应的值，然后携带着需要的参数进行调用。这就是我们要分析的，Jackson是如何做到的？

![image-20221212224328373](https://cdn.jsdelivr.net/gh/zrgzs/images@main/images/2024%2F07%2F31%2F11-16-52-b309da8b703b4b1eaefa90b7dd345330-202301052342473-ba24cf.png)

其中获取参数值就是用这个方法：

### `org.springframework.web.method.support.InvocableHandlerMethod#getMethodArgumentValues`

源码如下：

```java
	/**
	 * 获取当前请求的方法参数值，检查提供的参数值并返回到配置的参数解析器。 生成的数组将传递给doInvoke。 
	自: 5.1.2
	 */
	protected Object[] getMethodArgumentValues(NativeWebRequest request, @Nullable ModelAndViewContainer mavContainer,
			Object... providedArgs) throws Exception {

		// 获取参数列表
		MethodParameter[] parameters = getMethodParameters();
		// 如果参数列表为空则直接返回空参
        if (ObjectUtils.isEmpty(parameters)) {
			return EMPTY_ARGS;
		}

        // 新建一个数组用于存放参数
		Object[] args = new Object[parameters.length];
		// 循环遍历每个参数
        for (int i = 0; i < parameters.length; i++) {
            // 获取参数
			MethodParameter parameter = parameters[i];
            // 初始化参数名称发现器（不知道是个啥）
			parameter.initParameterNameDiscovery(this.parameterNameDiscoverer);
            // 查找提供的参数
			args[i] = findProvidedArgument(parameter, providedArgs);
			if (args[i] != null) {
				continue;
			}
            // 判断是否有转换器支持处理该参数
			if (!this.resolvers.supportsParameter(parameter)) {
				throw new IllegalStateException(formatArgumentError(parameter, "No suitable resolver"));
			}
			try {
                // 使用转换器获取参数
				args[i] = this.resolvers.resolveArgument(parameter, mavContainer, request, this.dataBinderFactory);
			}
			catch (Exception ex) {
				// Leave stack trace for later, exception may actually be resolved and handled...
				if (logger.isDebugEnabled()) {
					String exMsg = ex.getMessage();
					if (exMsg != null && !exMsg.contains(parameter.getExecutable().toGenericString())) {
						logger.debug(formatArgumentError(parameter, exMsg));
					}
				}
				throw ex;
			}
		}
		return args;
```

### `org.springframework.web.method.support.HandlerMethodArgumentResolverComposite#resolveArgument`

```java
	/**
	对已注册的HandlerMethodArgumentResolver进行迭代，并调用支持它的HandlerMethod Argument解析器。 
	抛出: IllegalArgumentException–如果找不到合适的参数解析器
	 */
	@Override
	@Nullable
	public Object resolveArgument(MethodParameter parameter, @Nullable ModelAndViewContainer mavContainer,
			NativeWebRequest webRequest, @Nullable WebDataBinderFactory binderFactory) throws Exception {

        // 获取转换器
		HandlerMethodArgumentResolver resolver = getArgumentResolver(parameter);
		if (resolver == null) {
			throw new IllegalArgumentException("Unsupported parameter type [" +
					parameter.getParameterType().getName() + "]. supportsParameter should be called first.");
		}
        // 开始转换
        // 此处使用的是 org.springframework.web.servlet.mvc.method.annotation.RequestResponseBodyMethodProcessor#resolveArgument
		return resolver.resolveArgument(parameter, mavContainer, webRequest, binderFactory);
```

### `org.springframework.web.servlet.mvc.method.annotation.RequestResponseBodyMethodProcessor#resolveArgument`

```java
	/**
	如果验证失败，则引发MethodArgumentNotValidException。 
	抛出: HttpMessageNotReadableException–如果RequestBody。required（）为true，并且没有正文内容，或者没有合适的转换器来读取内容
	 */
	@Override
	public Object resolveArgument(MethodParameter parameter, @Nullable ModelAndViewContainer mavContainer,
			NativeWebRequest webRequest, @Nullable WebDataBinderFactory binderFactory) throws Exception {

        // 如果参数是 Optional 类型则解除嵌套
		parameter = parameter.nestedIfOptional();
        // 从消息转换其中读取参数
        // 从此入
		Object arg = readWithMessageConverters(webRequest, parameter, parameter.getNestedGenericParameterType());
		// ...

		return adaptArgumentIfNecessary(arg, parameter);
```

### `org.springframework.web.servlet.mvc.method.annotation.RequestResponseBodyMethodProcessor#readWithMessageConverters`

```java
	@Override
	protected <T> Object readWithMessageConverters(NativeWebRequest webRequest, MethodParameter parameter,
			Type paramType) throws IOException, HttpMediaTypeNotSupportedException, HttpMessageNotReadableException {

		HttpServletRequest servletRequest = webRequest.getNativeRequest(HttpServletRequest.class);
		Assert.state(servletRequest != null, "No HttpServletRequest");
		ServletServerHttpRequest inputMessage = new ServletServerHttpRequest(servletRequest);

        // 通过读取给定的HttpInputMessage，创建所需参数类型的方法参数值。
		Object arg = readWithMessageConverters(inputMessage, parameter, paramType);
		// ...
		return arg;
	}
```

### `org.springframework.web.servlet.mvc.method.annotation.AbstractMessageConverterMethodArgumentResolver#readWithMessageConverters(org.springframework.http.HttpInputMessage, org.springframework.core.MethodParameter, java.lang.reflect.Type)`

```java
	/**
	通过读取给定的HttpInputMessage，创建所需参数类型的方法参数值。 
	形参: 
		inputMessage–表示当前请求参数的HTTP输入消息–方法参数描述符
		targetType–目标类型，不一定与方法参数类型相同，例如，对于HttpEntity 。 
	返回值: 创建的方法参数值 
	抛出: 
		IOException–如果读取请求失败 
		HttpMediaTypeNotSupportedException–如果找不到合适的消息转换器 
	*/
	@SuppressWarnings("unchecked")
	@Nullable
	protected <T> Object readWithMessageConverters(HttpInputMessage inputMessage, MethodParameter parameter,
			Type targetType) throws IOException, HttpMediaTypeNotSupportedException, HttpMessageNotReadableException {

		MediaType contentType;
		boolean noContentType = false;
		try {
            // 获取请求头中的 ContentType
			contentType = inputMessage.getHeaders().getContentType();
		}
		catch (InvalidMediaTypeException ex) {
			throw new HttpMediaTypeNotSupportedException(ex.getMessage());
		}
        // 如果没有定义 ContentType 则默认为 application/octet-stream
		if (contentType == null) {
			noContentType = true;
			contentType = MediaType.APPLICATION_OCTET_STREAM;
		}

        // 获取参数的包含类对象（不知道是个啥）
		Class<?> contextClass = parameter.getContainingClass();
		// 获取要转换的目标对象
        Class<T> targetClass = (targetType instanceof Class ? (Class<T>) targetType : null);
        
		if (targetClass == null) {
			ResolvableType resolvableType = ResolvableType.forMethodParameter(parameter);
			targetClass = (Class<T>) resolvableType.resolve();
		}

        // 获取请求方法
		HttpMethod httpMethod = (inputMessage instanceof HttpRequest ? ((HttpRequest) inputMessage).getMethod() : null);
		// 初始化请求体
        Object body = NO_VALUE;

		EmptyBodyCheckingHttpInputMessage message = null;
		try {
			message = new EmptyBodyCheckingHttpInputMessage(inputMessage);

            // 遍历所有消息转换器
			for (HttpMessageConverter<?> converter : this.messageConverters) {
				Class<HttpMessageConverter<?>> converterType = (Class<HttpMessageConverter<?>>) converter.getClass();
				GenericHttpMessageConverter<?> genericConverter =
						(converter instanceof GenericHttpMessageConverter ? (GenericHttpMessageConverter<?>) converter : null);
                
                // 判断标准转换器是否支持
                // 从此入
				if (genericConverter != null ? genericConverter.canRead(targetType, contextClass, contentType) :
						(targetClass != null && converter.canRead(targetClass, contentType))) {
					if (message.hasBody()) {
						HttpInputMessage msgToUse =
								getAdvice().beforeBodyRead(message, parameter, targetType, converterType);
						body = (genericConverter != null ? genericConverter.read(targetType, contextClass, msgToUse) :
								((HttpMessageConverter<T>) converter).read(targetClass, msgToUse));
						body = getAdvice().afterBodyRead(body, msgToUse, parameter, targetType, converterType);
					}
					else {
						body = getAdvice().handleEmptyBody(null, message, parameter, targetType, converterType);
					}
					break;
				}
			}
		}
		catch (IOException ex) {
			throw new HttpMessageNotReadableException("I/O error while reading input message", ex, inputMessage);
		}
		// ...

		return body;
	}
```

### `org.springframework.http.converter.json.AbstractJackson2HttpMessageConverter#canRead(java.lang.reflect.Type, java.lang.Class<?>, org.springframework.http.MediaType)`

```java
@Override
	public boolean canRead(Type type, @Nullable Class<?> contextClass, @Nullable MediaType mediaType) {
        // 首先判断该媒体类型是否被支持
		if (!canRead(mediaType)) {
			return false;
		}
        // 获取 Java 类型
		JavaType javaType = getJavaType(type, contextClass);
        // 根据 Java 类型选择合适的 ObjectMapper
		ObjectMapper objectMapper = selectObjectMapper(javaType.getRawClass(), mediaType);
        // 如果没有合适的 ObjectMapper 则返回 null
		if (objectMapper == null) {
			return false;
		}
        
		AtomicReference<Throwable> causeRef = new AtomicReference<>();
		
        // 判断 ObjectMapper 是否能够反序列化该类型
        // 从此入
        if (objectMapper.canDeserialize(javaType, causeRef)) {
			return true;
		}
		// ...
		return false;
	}
```

### `com.fasterxml.jackson.databind.ObjectMapper#canDeserialize(com.fasterxml.jackson.databind.JavaType, java.util.concurrent.atomic.AtomicReference<java.lang.Throwable>)`

```java
    /**
    方法类似于canDeserialize（JavaType），但它可以返回在尝试构造序列化程序时抛出的实际Throwable：这可能有助于确定实际问题是什么。 
    自: 2.3
    */
	public boolean canDeserialize(JavaType type, AtomicReference<Throwable> cause)
    {
        // 创建一个反序列化器上下文对象，然后判断是否有反序列化器可以反序列化该类型
        return createDeserializationContext(null,
                getDeserializationConfig()).hasValueDeserializerFor(type, cause);
    }
```

### `com.fasterxml.jackson.databind.DeserializationContext#hasValueDeserializerFor`

```java
    /**
    方法，用于检查是否可以找到给定类型的反序列化程序。 
    形参: 
    	type–检查原因的类型–（可选）如果由于异常无法找到反序列化程序，则将引用设置为根本原因（以查找失败原因）
    自: 2.3
    */
	public boolean hasValueDeserializerFor(JavaType type, AtomicReference<Throwable> cause) {
        try {
            // 从缓存中查找是否有反序列化器支持该类型
            return _cache.hasValueDeserializerFor(this, _factory, type);
        } catch (DatabindException e) {
            if (cause != null) {
                cause.set(e);
            }
        } catch (RuntimeException e) {
            if (cause == null) { // earlier behavior
                throw e;
            }
            cause.set(e);
        }
        return false;
    }
```

### `com.fasterxml.jackson.databind.deser.DeserializerCache#hasValueDeserializerFor`

```java
    /**
    调用方法以确定提供程序是否能够使用根引用（即不通过数组或集合中的字段或成员身份）找到给定类型的反序列化程序
    */
	public boolean hasValueDeserializerFor(DeserializationContext ctxt,
            DeserializerFactory factory, JavaType type)
        throws JsonMappingException
    {
        /* Note: mostly copied from findValueDeserializer, except for
         * handling of unknown types
         */
        // 从缓存中查找反序列化器
        JsonDeserializer<Object> deser = _findCachedDeserializer(type);
        if (deser == null) {
            // 找不到则创建并缓存该反序列化器
            deser = _createAndCacheValueDeserializer(ctxt, factory, type);
        }
        return (deser != null);
    }
```

### `com.fasterxml.jackson.databind.deser.DeserializerCache#_createAndCacheValueDeserializer`

```java
	/**
	方法，该方法将尝试为给定类型创建反序列化程序，并在必要时对其进行解析和缓存 
	形参: 
		ctxt–当前活动的反序列化上下文类型–要反序列化的属性类型
	*/
	protected JsonDeserializer<Object> _createAndCacheValueDeserializer(DeserializationContext ctxt,
            DeserializerFactory factory, JavaType type)
        throws JsonMappingException
    {
        /* Only one thread to construct deserializers at any given point in time;
         * limitations necessary to ensure that only completely initialized ones
         * are visible and used.
         */
        // 加锁，防止重复创建反序列化器
        synchronized (_incompleteDeserializers) {
            // Ok, then: could it be that due to a race condition, deserializer can now be found?
            // 双重检查，判断是否已经有线程创建好了反序列化器
            JsonDeserializer<Object> deser = _findCachedDeserializer(type);
            if (deser != null) {
                return deser;
            }
            // 判断是否有正在创建，但是尚未完全创建的反序列化器
            int count = _incompleteDeserializers.size();
            // Or perhaps being resolved right now?
            if (count > 0) {
                deser = _incompleteDeserializers.get(type);
                if (deser != null) {
                    return deser;
                }
            }
            // Nope: need to create and possibly cache
            try {
                // 创建并缓存反序列化器
                return _createAndCache2(ctxt, factory, type);
            } finally {
                // also: any deserializers that have been created are complete by now
                if (count == 0 && _incompleteDeserializers.size() > 0) {
                    _incompleteDeserializers.clear();
                }
            }
        }
    }
```

### `com.fasterxml.jackson.databind.deser.DeserializerCache#_createAndCache2`

```java
	/**
	处理实际构造（通过工厂）和缓存（中间和最终）的方法
	*/
	protected JsonDeserializer<Object> _createAndCache2(DeserializationContext ctxt,
            DeserializerFactory factory, JavaType type)
        throws JsonMappingException
    {
        JsonDeserializer<Object> deser;
        try {
            // 创建反序列化器
            deser = _createDeserializer(ctxt, factory, type);
        } catch (IllegalArgumentException iae) {
            // We better only expose checked exceptions, since those
            // are what caller is expected to handle
            ctxt.reportBadDefinition(type, ClassUtil.exceptionMessage(iae));
            deser = null; // never gets here
        }
        // ...
```

### `com.fasterxml.jackson.databind.deser.DeserializerCache#_createDeserializer`

```java
	/**
	方法，该方法负责检查每类型注释，找出完整类型，并找出要调用的实际工厂方法。
	*/
	@SuppressWarnings("unchecked")
    protected JsonDeserializer<Object> _createDeserializer(DeserializationContext ctxt,
            DeserializerFactory factory, JavaType type)
        throws JsonMappingException
    {
        // 获取配置
        final DeserializationConfig config = ctxt.getConfig();

        // 首先，我们需要使用抽象类型映射吗？
        if (type.isAbstract() || type.isMapLikeType() || type.isCollectionLikeType()) {
            type = factory.mapAbstractType(config, type);
        }
        BeanDescription beanDesc = config.introspect(type);
        // 那么：类型是否定义了要使用的显式反序列化程序以及注释？
        JsonDeserializer<Object> deser = findDeserializerFromAnnotation(ctxt,
                beanDesc.getClassInfo());
        if (deser != null) {
            return deser;
        }

        // 如果没有，可能需要检查更多的类型修改注释：
        JavaType newType = modifyTypeByAnnotation(ctxt, beanDesc.getClassInfo(), type);
        if (newType != type) {
            type = newType;
            beanDesc = config.introspect(newType);
        }

        // 我们可能还需要考虑生成器类型。。。
        Class<?> builder = beanDesc.findPOJOBuilder();
        if (builder != null) {
            return (JsonDeserializer<Object>) factory.createBuilderBasedDeserializer(
            		ctxt, type, beanDesc, builder);
        }

        // 或者是转换器？
        Converter<Object,Object> conv = beanDesc.findDeserializationConverter();
        if (conv == null) { // 不，只是以正常方式构建
            // 返回以正常方式构建的反序列化器
            return (JsonDeserializer<Object>) _createDeserializer2(ctxt, factory, type, beanDesc);
        }
        // ...
        return new StdDelegatingDeserializer<Object>(conv, delegateType,
                _createDeserializer2(ctxt, factory, delegateType, beanDesc));
    }
```

### `com.fasterxml.jackson.databind.deser.DeserializerCache#_createDeserializer2`

```java
protected JsonDeserializer<?> _createDeserializer2(DeserializationContext ctxt,
            DeserializerFactory factory, JavaType type, BeanDescription beanDesc)
        throws JsonMappingException
    {
        final DeserializationConfig config = ctxt.getConfig();
        // If not, let's see which factory method to use

        // 12-Feb-20202, tatu: Need to ensure that not only all Enum implementations get
        //    there, but also `Enum` -- latter wrt [databind#2605], polymorphic usage
    	// 判断是否为枚举类型    
    	if (type.isEnumType()) {
            return factory.createEnumDeserializer(ctxt, type, beanDesc);
        }
    	// 判断是否为容器类型，如集合，数组，哈希表等
        if (type.isContainerType()) {
            if (type.isArrayType()) {
                // ...
            }
            if (type.isMapLikeType()) {
                // ...
            }
            if (type.isCollectionLikeType()) {
                // ...
            }
        }
    	// 判断是否为 ReferenceType 的子类
        if (type.isReferenceType()) {
            // ...
        }
    	// 判断是否为 JSON 节点
        if (JsonNode.class.isAssignableFrom(type.getRawClass())) {
            // ...
        }
    	// 创建 Bean 的反序列化器
        return factory.createBeanDeserializer(ctxt, type, beanDesc);
    }
```

### `com.fasterxml.jackson.databind.deser.BeanDeserializerFactory#createBeanDeserializer`

```java
	/**
	方法，DeserializerCaches调用该方法为集合、映射、数组和枚举以外的类型创建新的反序列化程序
	*/
	@SuppressWarnings("unchecked")
    @Override
    public JsonDeserializer<Object> createBeanDeserializer(DeserializationContext ctxt,
            JavaType type, BeanDescription beanDesc)
        throws JsonMappingException
    {
        final DeserializationConfig config = ctxt.getConfig();
        // 首先：我们也可能有自定义覆盖：
        // 查找自定义的反序列化器
        JsonDeserializer<?> deser = _findCustomBeanDeserializer(type, config, beanDesc);
        if (deser != null) {
            // ...
            return (JsonDeserializer<Object>) deser;
        }
        // 还有一件事需要检查：我们是否有异常类型（Throwable或其子类）？如果是这样，需要稍微不同的处理。
        if (type.isThrowable()) {
            // ...
        }
        // Or, for abstract types, may have alternate means for resolution
        // (defaulting, materialization)

        // 29-Nov-2015, tatu: Also, filter out calls to primitive types, they are
        //    not something we could materialize anything for
        
        // 或者是 抽象的、基本的、枚举的 类型
        if (type.isAbstract() && !type.isPrimitive() && !type.isEnumType()) {
            // ...
        }
        // 否则，可能需要从超类检查标准类型的处理程序：
        deser = findStdDeserializer(ctxt, type, beanDesc);
        if (deser != null) {
            // ...
        }

        // 否则：该类是否可以是 Bean 类？如不是，则返回 null
        if (!isPotentialBeanType(type.getRawClass())) {
            return null;
        }
        // ...

        // 05-May-2020, tatu: [databind#2683] Let's actually pre-emptively catch
        //   certain types (for now, java.time.*) to give better error messages
        
        // 找到不支持的类型反序列化程序
        deser = _findUnsupportedTypeDeserializer(ctxt, type, beanDesc);
        if (deser != null) {
            // ...
        }

        // 使用泛型bean内省构建反序列化程序
        return buildBeanDeserializer(ctxt, type, beanDesc);
    }
```

### `com.fasterxml.jackson.databind.deser.BeanDeserializerFactory#buildBeanDeserializer`

```java
@SuppressWarnings("unchecked")
    public JsonDeserializer<Object> buildBeanDeserializer(DeserializationContext ctxt,
            JavaType type, BeanDescription beanDesc)
        throws JsonMappingException
    {
        // First: check what creators we can use, if any
        ValueInstantiator valueInstantiator;
        /* 04-Jun-2015, tatu: To work around [databind#636], need to catch the
         *    issue, defer; this seems like a reasonable good place for now.
         *   Note, however, that for non-Bean types (Collections, Maps) this
         *   probably won't work and needs to be added elsewhere.
         */
        try {
            // 找到值实例化器
            valueInstantiator = findValueInstantiator(ctxt, beanDesc);
        } catch (NoClassDefFoundError error) {
            return new ErrorThrowingDeserializer(error);
        } catch (IllegalArgumentException e0) {
            // 05-Apr-2017, tatu: Although it might appear cleaner to require collector
            //   to throw proper exception, it doesn't actually have reference to this
            //   instance so...
            throw InvalidDefinitionException.from(ctxt.getParser(),
                    ClassUtil.exceptionMessage(e0),
                   beanDesc, null)
                .withCause(e0);
        }
        BeanDeserializerBuilder builder = constructBeanDeserializerBuilder(ctxt, beanDesc);
        builder.setValueInstantiator(valueInstantiator);
         // And then setters for deserializing from JSON Object
        addBeanProps(ctxt, beanDesc, builder);
        addObjectIdReader(ctxt, beanDesc, builder);

        // managed/back reference fields/setters need special handling... first part
        addBackReferenceProperties(ctxt, beanDesc, builder);
        addInjectables(ctxt, beanDesc, builder);
        
        final DeserializationConfig config = ctxt.getConfig();
        if (_factoryConfig.hasDeserializerModifiers()) {
            for (BeanDeserializerModifier mod : _factoryConfig.deserializerModifiers()) {
                builder = mod.updateBuilder(config, beanDesc, builder);
            }
        }
        JsonDeserializer<?> deserializer;

        if (type.isAbstract() && !valueInstantiator.canInstantiate()) {
            deserializer = builder.buildAbstract();
        } else {
            deserializer = builder.build();
        }
        // may have modifier(s) that wants to modify or replace serializer we just built
        // (note that `resolve()` and `createContextual()` called later on)
        if (_factoryConfig.hasDeserializerModifiers()) {
            for (BeanDeserializerModifier mod : _factoryConfig.deserializerModifiers()) {
                deserializer = mod.modifyDeserializer(config, beanDesc, deserializer);
            }
        }
        return (JsonDeserializer<Object>) deserializer;
    }
```

### `com.fasterxml.jackson.databind.deser.BasicDeserializerFactory#findValueInstantiator`

```java
@Override
    public ValueInstantiator findValueInstantiator(DeserializationContext ctxt,
            BeanDescription beanDesc)
        throws JsonMappingException
    {
        final DeserializationConfig config = ctxt.getConfig();

        ValueInstantiator instantiator = null;
        //...
        		// 创建默认的值实例化器
                instantiator = _constructDefaultValueInstantiator(ctxt, beanDesc);
            //...
        }

        // finally: anyone want to modify ValueInstantiator?
        if (_factoryConfig.hasValueInstantiators()) {
            for (ValueInstantiators insts : _factoryConfig.valueInstantiators()) {
                instantiator = insts.findValueInstantiator(config, beanDesc, instantiator);
                // let's do sanity check; easier to spot buggy handlers
                if (instantiator == null) {
                    ctxt.reportBadTypeDefinition(beanDesc,
						"Broken registered ValueInstantiators (of type %s): returned null ValueInstantiator",
						insts.getClass().getName());
                }
            }
        }
        if (instantiator != null) {
            instantiator = instantiator.createContextual(ctxt, beanDesc);
        }

        return instantiator;
    }
```

### `com.fasterxml.jackson.databind.deser.BasicDeserializerFactory#_constructDefaultValueInstantiator`

```java
protected ValueInstantiator _constructDefaultValueInstantiator(DeserializationContext ctxt,
            BeanDescription beanDesc)
        throws JsonMappingException
    {
        final CreatorCollectionState ccState;
        final ConstructorDetector ctorDetector;

        {
            //...
            
            // 从属性值查找创建者（不懂）
            Map<AnnotatedWithParams,BeanPropertyDefinition[]> creatorDefs = _findCreatorsFromProperties(ctxt,
                    beanDesc);
           //...
        }

        //...
        return ccState.creators.constructValueInstantiator(ctxt);
    }
```

### `com.fasterxml.jackson.databind.deser.BasicDeserializerFactory#_findCreatorsFromProperties`

```java
protected Map<AnnotatedWithParams,BeanPropertyDefinition[]> _findCreatorsFromProperties(DeserializationContext ctxt,
            BeanDescription beanDesc) throws JsonMappingException
    {
        Map<AnnotatedWithParams,BeanPropertyDefinition[]> result = Collections.emptyMap();
    	// 查找所有属性
        for (BeanPropertyDefinition propDef : beanDesc.findProperties()) {
            //...
        }
        return result;
    }
```

### `com.fasterxml.jackson.databind.introspect.BasicBeanDescription#findProperties`

```java
    @Override
    public List<BeanPropertyDefinition> findProperties() {
        return _properties();
    }
```

### `com.fasterxml.jackson.databind.introspect.BasicBeanDescription#_properties`

```java
    protected List<BeanPropertyDefinition> _properties() {
        if (_properties == null) {
            // 为空则创建
            _properties = _propCollector.getProperties();
        }
        return _properties;
    }
```

### `com.fasterxml.jackson.databind.introspect.POJOPropertiesCollector#getProperties`

```java
    public List<BeanPropertyDefinition> getProperties() {
        // 确保我们返回一个副本，以便调用方可以在需要时删除条目：
        // 获取所有属性
        Map<String, POJOPropertyBuilder> props = getPropertyMap();
        return new ArrayList<BeanPropertyDefinition>(props.values());
    }
```

### `com.fasterxml.jackson.databind.introspect.POJOPropertiesCollector#getPropertyMap`

```java
    protected Map<String, POJOPropertyBuilder> getPropertyMap() {
        if (!_collected) {
            // 收集所有属性
            collectAll();
        }
        return _properties;
    }
```

### `com.fasterxml.jackson.databind.introspect.POJOPropertiesCollector#collectAll`

重点到了

```java
protected void collectAll()
    {
        LinkedHashMap<String, POJOPropertyBuilder> props = new LinkedHashMap<String, POJOPropertyBuilder>();

        // 第一：收集基础数据
    	// 收集字段
        _addFields(props); // 注意：填充_fieldRenameMappings
        // 收集方法，如果是 getter setter 方法则会根据其方法规则设置对应的属性
    	_addMethods(props);
        // 25-Jan-2016, tatu: Avoid introspecting (constructor-)creators for non-static
        //    inner classes, see [databind#1502]
        if (!_classDef.isNonStaticInnerClass()) {
            _addCreators(props);
        }

        // Remove ignored properties, first; this MUST precede annotation merging
        // since logic relies on knowing exactly which accessor has which annotation
        // 移除不需要的属性
    	/*
    		注：里面会移除掉不可见的属性，也就是说 private 的属性方法都会被移除。所以字段名称实际上以通过解析 getter setter 方法得出的名称为准
    	*/
    	_removeUnwantedProperties(props);
        // ...
    }
```

获取属性到这里差不多就结束了。

