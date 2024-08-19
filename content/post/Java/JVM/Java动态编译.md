---
url: /7230462713250488320
title: 'Java动态编译'
date: 2024-08-17T14:37:33+08:00
draft: false
summary: ""
categories: [Java]
tags: ['JVM']
---

<hr>
先贴代码，没多少，主要是得进行 Debug 阅读源码，理解编译流程。

### 成果

- 实现了动态的、完全在内存中的编译 Java 源代码，没有操作本地文件的 IO 消耗。
- 通过自定义类加载器实现了从字节数组加载类，而不是从文件，减少了不必要的 IO 操作。
- 通过自定义 `JavaFileObject` 实现了直接编译存储在 String 中的源代码，而不是通过 `Processor` 类去执行 `javac` 命令来编译文件。

JDK 环境：

```java
java version "21.0.1" 2023-10-17 LTS
Java(TM) SE Runtime Environment (build 21.0.1+12-LTS-29)
Java HotSpot(TM) 64-Bit Server VM (build 21.0.1+12-LTS-29, mixed mode, sharing)
```

自定义编译器测试

```java
package versions.java21.dynamic_compiler._03;

import javax.tools.*;
import java.io.IOException;
import java.io.StringWriter;
import java.lang.reflect.InvocationTargetException;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;


/**
 * @author: xfdzcoder
 */
public class CustomCompiler {

    public static void main(String[] args) {
        String codeFormat = """
                public class Main {
                    public static void main(String[] args) {
                        System.out.println("Hello World %d !");
                    }
                }
                """;


        JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
        try (StringSourceFileManager sourceFileManager = new StringSourceFileManager()) {

            StringWriter out = new StringWriter();
            DiagnosticCollector<JavaFileObject> diagnostics = new DiagnosticCollector<>();
            List<StringSourceFileObject> fileObjectList = new LinkedList<>();

            for (int i = 0; i < 10; i++) {
                String packageName = "sandbox.java_" + i;
                String code = String.format("package %s;" + codeFormat, packageName, i);

                fileObjectList.add(new StringSourceFileObject(packageName, "Main", code));
            }
            JavaCompiler.CompilationTask task = compiler.getTask(out, sourceFileManager, diagnostics, Collections.singleton("-proc:none"), null, fileObjectList);

            if (task.call()) {
                System.out.println("Compilation succeeded");

                ByteArrayClassLoader classLoader = new ByteArrayClassLoader();

                try {

                    for (StringSourceFileObject fileObject : fileObjectList) {
                        System.out.println("fileObject.getFullClassName(): " + fileObject.getFullClassName());
                        System.out.println("fileObject.getByteCode().length: " + fileObject.getByteCode().length);

                        Class<?> clz = classLoader.loadClassFromByteArray(fileObject.getFullClassName(), fileObject.getByteCode());
                        System.out.println("clz.getName(): " + clz.getName());
                        System.out.println("System.identityHashCode(clz): " + System.identityHashCode(clz));
                        clz.getMethod("main", String[].class).invoke(null, (Object) new String[0]);
                        System.out.println();

                    }
                } catch (ClassNotFoundException e) {
                    System.out.println(e.getMessage());
                } catch (InvocationTargetException | IllegalAccessException | NoSuchMethodException e) {
                    throw new RuntimeException(e);
                }
            } else {
                List<Diagnostic<? extends JavaFileObject>> diagnosticList = diagnostics.getDiagnostics();
                diagnosticList.forEach(System.out::println);
                System.out.println(out);
            }

        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

}
```

自定义类加载器，从字节数组加载类。

```java
package io.github.xfdzcoder.noj.framework.sandbox.java.complier;

/**
 * 字节数组类加载器
 *
 * @author: xfdzcoder
 */
public final class ByteArrayClassLoader extends ClassLoader {
    
    static {
        registerAsParallelCapable();
    }

    Class<?> loadClassFromByteArray(String name, byte[] byteCode) throws ClassNotFoundException {
        if (name == null || byteCode == null || name.isEmpty() || byteCode.length == 0) {
            throw new ClassNotFoundException("name or byteCode is null or empty");
        }
        synchronized (getClassLoadingLock(name)) {
            return defineClass(name, byteCode, 0, byteCode.length);
        }
    }
}

```

自定义文件管理器，重写方法使其用我们后面自定义的文件对象。

```java
package versions.java21.dynamic_compiler._03;

import javax.tools.*;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Locale;

/**
 * 它管理存储在字符串中的源代码
 *
 * @author: xfdzcoder
 */
public class StringSourceFileManager extends ForwardingJavaFileManager<StandardJavaFileManager> {

    public StringSourceFileManager() {
        super(ToolProvider.getSystemJavaCompiler().getStandardFileManager(new DiagnosticCollector<>(), Locale.getDefault(), StandardCharsets.UTF_8));
    }

    @Override
    public JavaFileObject getJavaFileForOutput(Location location, String className, JavaFileObject.Kind kind, FileObject sibling) throws IOException {
        if (kind == JavaFileObject.Kind.CLASS && sibling instanceof StringSourceFileObject sourceFileObject) {
            return sourceFileObject;
        }
        return super.getJavaFileForOutput(location, className, kind, sibling);
    }
}
```

自定义 Java 文件对象，表示存储在字符串中的源代码

```java
package versions.java21.dynamic_compiler._03;

import javax.tools.SimpleJavaFileObject;
import java.io.ByteArrayOutputStream;
import java.io.FilterOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URI;
import java.nio.CharBuffer;

/**
 * 它表示存储在字符串中的源代码
 *
 * @author: xfdzcoder
 */
public class StringSourceFileObject extends SimpleJavaFileObject {

    private final String fullClassName;

    /**
     * 源代码
     */
    private final String code;

    private byte[] byteCode;

    public StringSourceFileObject(String packageName, String className, String code) {
        super(
                URI.create("string:///" + packageName.replace('.', '/') + "/" + className + Kind.SOURCE.extension),
                Kind.SOURCE
        );
        this.code = code;
        this.fullClassName = packageName + "." + className;
    }

    public byte[] getByteCode() {
        return byteCode == null || byteCode.length == 0 ? null : byteCode;
    }

    public String getFullClassName() {
        return fullClassName == null || fullClassName.isEmpty() ? null : fullClassName;
    }

    @Override
    public CharBuffer getCharContent(boolean ignoreEncodingErrors) {
        return CharBuffer.wrap(code);
    }

    @Override
    public OutputStream openOutputStream() {
        return new FilterOutputStream(new ByteArrayOutputStream()) {
            @Override
            public void close() throws IOException {
                ByteArrayOutputStream byteCodeStream = (ByteArrayOutputStream) out;
                byteCode = byteCodeStream.toByteArray();
                out.close();
            }
        };
    }
}
```

