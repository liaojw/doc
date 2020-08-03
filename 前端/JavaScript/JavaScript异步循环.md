# JavaScript异步循环

```javascript
let dishes = [{name: 'fish1', time: 1}, {name: 'fish2', time: 2}, {name: 'fish3', time: 3}];

let	handle = e => {
  console.log('开始做' + e.name);
  return new Promise(resolve => {
    setTimeout(() => {
      console.log('做好了' + e.name);
      resolve();
    }, e.time * 1000);
  });
};
```

### 1、线性处理

```javascript
(async () => {
	for (let e of dishes) {
		await handle(e);
	}
});
```

###2、并行处理

```javascript
(async () => {
	const promises = dishes.map(handle);
	await Promise.all(promises);
	console.log('Done!');
});
```

