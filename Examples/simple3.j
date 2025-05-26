.class public simple3 
.super java/lang/Object

.method public static main([Ljava/lang/String;)V
 .limit locals 30 
 .limit stack 30

iconst_1
istore 1
iload 1
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println(I)V
iconst_3
iconst_4
iadd
istore 1
iload 1
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println(I)V
ldc 10.0
fstore 2
fload 2
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println(F)V
ldc 10.0
ldc 2.0
fadd
fstore 2
fload 2
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println(F)V
return
.end method

