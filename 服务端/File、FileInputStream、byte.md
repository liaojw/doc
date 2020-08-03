# File、FileInputStream、byte
## 1、将File、FileInputStream 转换为byte数组：

```
File file = new File("file.txt");
InputStream input = new FileInputStream(file);
byte[] byt = new byte[input.available()];
input.read(byt);
```
## 2、将byte数组转换为InputStream：

```
byte[] byt = new byte[1024];
InputStream input = new ByteArrayInputStream(byt);
```
## 3、将byte数组转换为File：

```
File file = new File("");
OutputStream output = new FileOutputStream(file);
BufferedOutputStream bufferedOutput = new BufferedOutputStream(output);
bufferedOutput.write(byt);
```
## 4、MultipartFile file转换

```
MultipartFile file=new MultipartFile();
InputStream inputStream = file.getInputStream();
String name = file.getOriginalFilename();
File tmpFile = File.createTempFile(name, ".jpg");
FileUtils.copyInputStreamToFile(inputStream, tmpFile);
tmpFile.delete();
```
