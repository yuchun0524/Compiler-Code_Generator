# Compiler-Code_Generator

## 環境需求
建議作業系統: Ubuntu 18.04  
安裝Flex Bison(lex和yacc要用): $ sudo apt install flex bison  
安裝JRE(為了執行程式): $ sudo apt install default-jre 
需要Jasmin(資料夾內已有)

## 程式目的
1、把 C-like的語言(此處為μGO)編譯成 Java assembly code  
2、Jasmin 把 Java assembly code 轉成 Java bytecode  
3、最後讓 JVM 執行產生的 Java bytecode 即可得到程式結果  

## 執行方式
### 查看個別測資結果
```   
$ make clean  /*清除從執行 $ make 之後產生的檔案*/
$ make mycompiler  /*執行後得到可執行檔 mycompiler */
$ ./mycompiler < input/in01_arithmetic.go /* < 後為測資 執行後可得到對應的.j檔*/
$ make Main.class
$ make run  /*印出程式結果*/
```
### 查看整體結果
```
$ python3 judge/judge.py
```
