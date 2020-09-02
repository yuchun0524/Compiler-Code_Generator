.source hw3.j
.class public Main
.super java/lang/Object
.method public static main([Ljava/lang/String;)V
.limit stack 100
.limit locals 100
ldc 0
istore 0
L_for_begin1:
ldc 0
istore 0
L_for_begin1:
ldc 10
ifeq EXIT_1
iload 0
ldc 1
iadd
istore 0
goto L_for_begin1
L_cmp_1:
iload 0
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println(I)V
goto L_add_1
EXIT_1:
ldc 3
newarray int
astore 1
aload 1
ldc 0
ldc 1
ldc 2
iadd
iastore
aload 1
ldc 1
aload 1
ldc 0
iaload
ldc 1
isub
iastore
aload 1
ldc 2
aload 1
ldc 1
iaload
ldc 3
idiv
iastore
aload 1
ldc 2
iaload
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println(I)V
ldc 3
ldc 4
ldc 5
ldc 8
ineg
iadd
imul
isub
ldc 10
ldc 7
idiv
isub
ldc 4
ineg
ldc 3
irem
isub
ifgt L_cmp_1
iconst_0
goto L_cmp_2
L_cmp_1:
iconst_1
L_cmp_2:
iconst_1
iconst_1
ixor
iconst_0
iconst_1
ixor
iconst_1
ixor
iand
ior
ifne L_cmp_3
ldc "false"
goto L_cmp_4
L_cmp_3:
ldc "true"
L_cmp_4:
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V
ldc 3
newarray float
astore 2
aload 2
ldc 0
ldc 1.100000
ldc 2.100000
fadd
fastore
aload 2
ldc 0
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println(I)V
ldc 0
istore 3
ldc 2
iload 3
swap
iadd
istore 3
L_for_begin1:
ldc 0
iload 3
swap
isub
ifgt L_cmp_5
iconst_0
goto L_cmp_6
L_cmp_5:
iconst_1
L_cmp_6:
ifeq EXIT_1
iload 3
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println(I)V
iload 3
ldc 1
isub
istore 3
ldc 0
iload 3
swap
isub
ifne L_cmp_7
goto EXIT_1
L_cmp_7:
ldc 3.140000
fstore 4
ldc 1.000000
fload 4
fadd
f2i
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println(F)V
ldc "If x != "
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
ldc 0
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println(I)V
fload 4
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println(F)V
goto EXIT_2
EXIT_1:
goto L_add_1
EXIT_1:
ldc 6.600000
fstore 5
ldc "If x == "
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
ldc 0
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println(I)V
fload 5
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/println(F)V
ldc 0
istore 6
L_for_begin1:
ldc 1
istore 6
L_for_begin1:
ldc 3
iload 6
swap
isub
ifle L_cmp_8
goto EXIT_3
L_add_1:
iload 6
ldc 1
iadd
istore 6
goto L_for_begin1
L_cmp_1:
iload 3
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(I)V
ldc "*"
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
iload 6
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(I)V
ldc "="
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
iload 3
iload 6
imul
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(I)V
ldc "\t"
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
goto L_add_1
EXIT_1:
   return
.end method
