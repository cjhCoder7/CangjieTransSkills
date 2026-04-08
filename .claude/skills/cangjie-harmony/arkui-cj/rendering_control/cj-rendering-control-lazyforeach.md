# LazyForEach：数据懒加载

<!--Del-->
> **说明：**
>
> 当前为Beta阶段。
<!--DelEnd-->

API参数说明见：[LazyForEach API参数说明](../../reference/arkui-cj/cj-state-rendering-lazyforeach.md)。

LazyForEach从提供的数据源中按需迭代数据，并在每次迭代过程中创建相应的组件。当在滚动容器中使用了LazyForEach，框架会根据滚动容器可视区域按需创建组件，当组件滑出可视区域外时，框架会进行组件销毁回收以降低内存占用

## 使用限制

- LazyForEach必须在容器组件内使用，仅有[List](../../reference/arkui-cj/cj-scroll-swipe-list.md)、[Grid](../../reference/arkui-cj/cj-scroll-swipe-grid.md)、[Swiper](../../reference/arkui-cj/cj-scroll-swipe-swiper.md)组件支持数据懒加载（可配置cachedCount属性，即只加载可视部分以及其前后少量数据用于缓冲），其他组件仍然是一次性加载所有的数据。
- LazyForEach依赖生成的键值判断是否刷新子组件，若键值不发生改变，则无法触发LazyForEach刷新对应的子组件。
- 容器组件内使用LazyForEach的时候，只能包含一个LazyForEach。以List为例，同时包含ListItem、ForEach、LazyForEach的情形是不推荐的；同时包含多个LazyForEach也是不推荐的。
- LazyForEach在每次迭代中，必须创建且只允许创建一个子组件；即LazyForEach的子组件生成函数有且只有一个根组件。
- 生成的子组件必须是允许包含在LazyForEach父容器组件中的子组件。
- 允许LazyForEach包含在if/else条件渲染语句中，也允许LazyForEach中出现if/else条件渲染语句。
- 键值生成器必须针对每个数据生成唯一的值，如果键值相同，将导致键值相同的UI组件渲染出现问题。
- LazyForEach必须使用DataChangeListener对象进行更新，对第一个参数dataSource重新赋值会异常；dataSource使用状态变量时，状态变量改变不会触发LazyForEach的UI刷新。
- 为了高性能渲染，通过DataChangeListener对象的onDataChange方法来更新UI时，需要生成不同于原来的键值来触发组件刷新。
- LazyForEach必须和@Reusable装饰器一起使用才能触发节点复用。使用方法：将[@Reusable](../paradigm/cj-macro-reusable.md)装饰在LazyForEach列表的组件上，见[使用规则](../paradigm/cj-macro-reusable.md)。

## 键值生成规则

在LazyForEach循环渲染过程中，系统会为每个item生成一个唯一且持久的键值，用于标识对应的组件。当这个键值变化时，ArkUI框架将视为该数组元素已被替换或修改，并会基于新的键值创建一个新的组件。

LazyForEach提供了一个名为keyGenerator的参数，这是一个函数，开发者可以通过它自定义键值的生成规则。如果开发者没有定义keyGenerator函数，则ArkUI框架会使用默认的键值生成函数，即{data: T, idx: Int64 => return "\${viewID} - \${idx} - \${uniqueKey_}"}, viewId在编译器转换过程中生成，同一个LazyForEach组件内其viewId是一致的。

## 组件创建规则

在确定键值生成规则后，LazyForEach的第二个参数itemGenerator函数会根据组件创建规则为数据源的每个数组项创建组件。组件的创建包括两种情况：[LazyForEach首次渲染](#首次渲染)和[LazyForEach非首次渲染](#非首次渲染)。

### 首次渲染

#### 生成不同键值

在LazyForEach首次渲染时，会根据上述键值生成规则为数据源的每个数组项生成唯一键值，并创建相应的组件。

<!-- code_check_manual -->

```cangjie
/** BasicDataSource代码见文档末尾附件: 泛型类型数组的BasicDataSource代码 **/

class MyDataSource <: BasicDataSource<String> {
    public MyDataSource(let data: ArrayList<String>) {
        super(data)
    }
}

@Entry
@Component
public class EntryView {
    let dataSource: MyDataSource = MyDataSource(ArrayList<String>())
    let random: Random = Random(3)
    @State var message: String = ""

    protected override func aboutToAppear() {
        for (i in 0..100) {
            let index = this.dataSource.totalCount()
            dataSource.data.add(i.toString())
            dataSource.notifyDataAdd(index)
        }
    }

    public func build(): Unit {
        Column() {
            Row() {
                Text(this.message).width(300.px)
            }
            List(space: 3) {
                LazyForEach(dataSource, itemGenerator: { item: String, index: Int64 =>
                        ListItem() {
                            Text("item[${index}]: ${item}").fontSize(30).onAppear({=> this.message="appear:" + item})
                        }
                    }, keyGenerator: { item: String, index: Int64 => item}
                )
            }.cachedCount(5)

        }.height(100.percent).height(100.percent)
    }
}
```

在上述代码中，键值生成规则是keyGenerator函数的返回值item。在LazyForEach循环渲染时，其为数据源数组项依次生成键值item[0]: 0、item[1]: 1 ... item[100]: 100，并创建对应的ListItem子组件渲染到界面上。

运行效果如下图所示。

**图1** LazyForEach正常首次渲染

![lazyforeach-2](figures/lazyforeach-2.gif)

#### 键值相同时错误渲染

当不同数据项生成的键值相同时，框架的行为是不可预测的。例如，在以下代码中，LazyForEach渲染的数据项键值均相同，在滑动过程中，LazyForEach会对划入划出当前页面的子组件进行预加载，而新建的子组件和销毁的原子组件具有相同的键值，框架可能存在取用缓存错误的情况，导致子组件渲染有问题。

<!-- code_check_manual -->

```cangjie
/** BasicDataSource代码见文档末尾附件: 泛型类型数组的BasicDataSource代码 **/

class MyDataSource <: BasicDataSource<String> {
    public MyDataSource(let data: ArrayList<String>) {
        super(data)
    }
}

@Entry
@Component
public class EntryView {
    let dataSource: MyDataSource = MyDataSource(ArrayList<String>())
    @State var message: String = ""

    protected override func aboutToAppear() {
        for (i in 0..100) {
            let index = this.dataSource.totalCount()
            dataSource.data.add(i.toString())
            dataSource.notifyDataAdd(index)
        }
    }

    public func build(): Unit {
        Column() {
            Row() {
                Text(this.message).width(300.px)
            }
            List(space: 3) {
                LazyForEach(dataSource, itemGenerator: { item: String, index: Int64 =>
                        ListItem() {
                            Text("item[${index}]: ${item}").fontSize(30).onAppear({=> this.message="appear:" + item})
                        }
                    }, keyGenerator: { item: String, index: Int64 =>  return "samekey"}
                )
            }.cachedCount(5)

        }.height(100.percent).height(100.percent)
    }
}
```

运行效果如下图所示。

**图2** LazyForEach存在相同键值

![lazyforeach-3](./figures/lazyforeach-3.gif)

### 非首次渲染

当LazyForEach数据源发生变化，需要再次渲染时，开发者应根据数据源的变化情况调用listener对应的接口，通知LazyForEach做相应的更新，各使用场景如下。

#### 添加数据

<!-- code_check_manual -->

```cangjie
/** BasicDataSource代码见文档末尾附件: 泛型类型数组的BasicDataSource代码 **/

class MyDataSource <: BasicDataSource<String> {
    public MyDataSource(let data: ArrayList<String>) {
        super(data)
    }

    public func pushData(str: String): Unit {
        this.data.add(str)
        this.notifyDataAdd(this.data.size - 1)
    }
}

@Entry
@Component
public class EntryView {
    let dataSource: MyDataSource = MyDataSource(ArrayList<String>())
    let random: Random = Random(3)

    public func build(): Unit {
        Column() {
            Row() {
                Button("load Data").onClick({ =>
                    for (i in 0..10) {
                        dataSource.pushData(i.toString())
                    }
                })

                Button("add Data").onClick({ =>
                    // 点击追加子组件
                    dataSource.pushData(dataSource.totalCount().toString())
                })
            }
            List(space: 3) {
                LazyForEach(dataSource, itemGenerator: { item: String, index: Int64 =>
                        ListItem() {
                            Text("item[${index}]: ${item}").fontSize(30)
                        }
                    }
                )
            }.cachedCount(5)

        }.height(100.percent).height(100.percent)
    }
}
```

当单击“add Data”按钮时，首先会调用数据源dataSource的pushData方法，该方法会在数据源末尾添加数据并调用notifyDataAdd方法。在notifyDataAdd方法内又会调用listenerItem.onDataAdd方法，该方法会通知LazyForeach在该处有数据添加，LazyForeach便会在该索引处新建子组件。

运行效果如下图所示。

**图3** LazyForEach添加数据

![lazyforeach-1](./figures/lazyforeach-1.gif)

#### 删除数据

<!-- code_check_manual -->

```cangjie
/** BasicDataSource代码见文档末尾附件: 泛型类型数组的BasicDataSource代码 **/

class MyDataSource <: BasicDataSource<String> {
    public MyDataSource(let data: ArrayList<String>) {
        super(data)
    }

    public func pushData(str: String): Unit {
        this.data.add(str)
        this.notifyDataAdd(this.data.size - 1)
    }

    public func deleteData(index: Int64): Unit {
        this.data.remove(at: index)
        this.notifyDataDelete(index)
    }

    public func getAllData(): ArrayList<String> {
        return data
    }
}

@Entry
@Component
public class EntryView {
    let dataSource: MyDataSource = MyDataSource(ArrayList<String>())

    func findIndex(arrayList: ArrayList<String>, value: String): Int64 {
        for (i in 0..arrayList.size) {
            if (arrayList[i]==value) {
                return i
            }
        }
        return -1
    }

    public func build(): Unit {
        Column() {
            Row() {
                Button("load Data").onClick({ =>
                    for (i in 0..100) {
                        dataSource.pushData(i.toString())
                    }
                })
            }
            List(space: 3) {
                LazyForEach(dataSource, itemGenerator: { item: String, index: Int64 =>
                        ListItem() {
                            Text("item[${index}]: ${item}").fontSize(30)
                        }.onClick({ _ =>
                            // 点击删除子组件
                            this.dataSource.deleteData(findIndex(this.dataSource.getAllData(),item))
                        })
                    }, keyGenerator: { item: String, index: Int64 => return item}
                )
            }.cachedCount(5)

        }.height(100.percent).height(100.percent)
    }
}
```

当单击ListItem元素时，首先会调用数据源dataSource的deleteData方法，该方法会在数据源末尾添加数据并调用notifyDataDelete方法。在notifyDataDelete方法内又会调用listenerItem.onDataDelete方法，该方法会通知LazyForeach在该处有数据添加，LazyForeach便会在该索引处删除子组件。

运行效果如下图所示。

**图4** LazyForEach删除数据

![lazyforeach-4](./figures/lazyforeach-4.gif)

#### 交换数据

<!-- code_check_manual -->

```cangjie
/** BasicDataSource代码见文档末尾附件: 泛型类型数组的BasicDataSource代码 **/

class MyDataSource <: BasicDataSource<String> {
    public MyDataSource(let data: ArrayList<String>) {
        super(data)
    }

    public func pushData(str: String): Unit {
        this.data.add(str)
        this.notifyDataAdd(this.data.size - 1)
    }

    public func deleteData(index: Int64): Unit {
        this.data.remove(at: index)
        this.notifyDataDelete(index)
    }

    public func getAllData(): ArrayList<String> {
        return data
    }

    public func moveData(from: Int64, to: Int64): Unit {
        let temp: String = this.data[from]
        this.data[from] = this.data[to]
        this.data[to] = temp
        this.notifyDataMove(from, to)
    }
}

@Entry
@Component
public class EntryView {
    let dataSource: MyDataSource = MyDataSource(ArrayList<String>())
    var moved: ArrayList<Int64> = ArrayList<Int64>()

    func findIndex(arrayList: ArrayList<String>, value: String): Int64 {
        for (i in 0..arrayList.size) {
            if (arrayList[i]==value) {
                return i
            }
        }
        return -1
    }

    public func build(): Unit {
        Column() {
            Row() {
                Button("load Data").onClick({ =>
                    for (i in 0..100) {
                        dataSource.pushData(i.toString())
                    }
                })
            }
            List(space: 3) {
                LazyForEach(dataSource, itemGenerator: { item: String, index: Int64 =>
                        ListItem() {
                            Text("item[${index}]: ${item}").fontSize(30)
                        }.onClick({ _ =>
                            this.moved.add(findIndex(this.dataSource.getAllData(),item))
                            if (this.moved.size == 2) {
                                // 点击交换子组件
                                this.dataSource.moveData(this.moved[0], this.moved[1])
                                this.moved.clear()
                            }
                        })
                    }, keyGenerator: { item: String, index: Int64 => return item}
                )
            }.cachedCount(5)

        }.height(100.percent).height(100.percent)
    }
}
```

当首次点击LazyForEach的子组件时，在moved成员变量内存入要移动的数据索引，再次点击LazyForEach另一个子组件时，将首次点击的子组件移到此处。调用数据源dataSource的moveData方法，该方法会将数据源对应数据移动到预期的位置并调用notifyDataMove方法。在notifyDataMove方法内会又调用listenerItem.onDataMove方法，该方法通知LazyForEach在该处有数据需要移动，LazyForEach便会将from和to索引处的子组件进行位置调换。

运行效果如下图所示。

**图5** LazyForEach交换数据

![lazyforeach-5](./figures/lazyforeach-5.gif)

#### 改变单个数据

<!-- code_check_manual -->

```cangjie
/** BasicDataSource代码见文档末尾附件: 泛型类型数组的BasicDataSource代码 **/

class MyDataSource <: BasicDataSource<String> {
    public MyDataSource(let data: ArrayList<String>) {
        super(data)
    }

    public func pushData(str: String): Unit {
        this.data.add(str)
        this.notifyDataAdd(this.data.size - 1)
    }

    public func deleteData(index: Int64): Unit {
        this.data.remove(at: index)
        this.notifyDataDelete(index)
    }

    public func getAllData(): ArrayList<String> {
        return data
    }

    public func moveData(from: Int64, to: Int64): Unit {
        let temp: String = this.data[from]
        this.data[from] = this.data[to]
        this.data[to] = temp
        this.notifyDataMove(from, to)
    }

    public func changeData(index: Int64, str: String): Unit {
        this.data[index]=str
        this.notifyDataChange(index)
    }
}

@Entry
@Component
public class EntryView {
    let dataSource: MyDataSource = MyDataSource(ArrayList<String>())

    func findIndex(arrayList: ArrayList<String>, value: String): Int64 {
        for (i in 0..arrayList.size) {
            if (arrayList[i]==value) {
                return i
            }
        }
        return -1
    }

    public func build(): Unit {
        Column() {
            Row() {
                Button("load Data").onClick({ =>
                    for (i in 0..100) {
                        dataSource.pushData(i.toString())
                    }
                })
            }
            List(space: 3) {
                LazyForEach(dataSource, itemGenerator: { item: String, index: Int64 =>
                        ListItem() {
                            Text("item[${index}]: ${item}").fontSize(30)
                        }.onClick({ _ =>
                            this.dataSource.changeData(findIndex(this.dataSource.getAllData(), item), item+"0")
                    })
                }, keyGenerator: { item: String, index: Int64 => return item})

        }.cachedCount(5)

        }.height(100.percent).height(100.percent)
    }
}
```

当单击LazyForEach的子组件时，首先改变当前数据，然后调用数据源dataSource的changeData方法，在该方法内会调用notifyDataChange方法。在notifyDataChange方法内会又调用listenerItem.onDataChange方法，该方法通知LazyForEach组件该处有数据发生变化，LazyForEach便会在对应索引处重建子组件。

运行效果如下图所示。

**图6** LazyForEach改变单个数据

![lazyforeach-6](./figures/lazyforeach-6.gif)

#### 改变多个数据

<!-- code_check_manual -->

```cangjie
/** BasicDataSource代码见文档末尾附件: 泛型类型数组的BasicDataSource代码 **/

class MyDataSource <: BasicDataSource<String> {
    public MyDataSource(let data: ArrayList<String>) {
        super(data)
    }

    public func pushData(str: String): Unit {
        this.data.add(str)
        this.notifyDataAdd(this.data.size - 1)
    }

    public func reloadData(): Unit {
        this.notifyDataReload()
    }

    public func modifyAllData(): Unit {
        for (i in 0..this.data.size) {
            this.data[i] += "0"
        }
    }
}

@Entry
@Component
public class EntryView {
    let dataSource: MyDataSource = MyDataSource(ArrayList<String>())

    func findIndex(arrayList: ArrayList<String>, value: String): Int64 {
        for (i in 0..arrayList.size) {
            if (arrayList[i]==value) {
                return i
            }
        }
        return -1
    }

    public func build(): Unit {
        Column() {
            Row() {
                Button("load Data").onClick({ =>
                    for (i in 0..100) {
                        dataSource.pushData(i.toString())
                    }
                })
            }
            List(space: 3) {
                LazyForEach(dataSource, itemGenerator: { item: String, index: Int64 =>
                        ListItem() {
                            Text("item[${index}]: ${item}").fontSize(30)
                        }.onClick({ _ =>
                            this.dataSource.modifyAllData()
                            this.dataSource.reloadData()
                    })
                }, keyGenerator: { item: String, index: Int64 => return item+index.toString()})
        }.cachedCount(5)

        }.height(100.percent).height(100.percent)
    }
}
```

当单击LazyForEach的子组件时，首先调用dataSource的modifyAllData方法改变了数据源中的所有数据，然后调用数据源的reloadData方法，在该方法内会调用notifyDataReload方法。在notifyDataReload方法内会又调用listenerItem.onDataReloaded方法，通知LazyForEach需要重建所有子节点。LazyForEach会将原所有数据项和新所有数据项一一做键值比对，若有相同键值则使用缓存，若键值不同则重新构建。

运行效果如下图所示。

**图7** LazyForEach改变多个数据

![lazyforeach-7](figures/lazyforeach-7.gif)

#### 精准批量修改数据

<!-- code_check_manual -->

```cangjie
/** BasicDataSource代码见文档末尾附件: 泛型类型数组的BasicDataSource代码 **/

class MyDataSource <: BasicDataSource<String> {
    var data: ArrayList<String> = ArrayList<String>(['0', '0', 'Hello a', 'Hello b', 'Hello c', 'Hello d', 'Hello e',
                                                    'Hello f', 'Hello g', 'Hello h', 'Hello i', 'Hello j', 'Hello k',
                                                    'Hello l', 'Hello m', 'Hello n', 'Hello o', 'Hello p',
                                                    'Hello q', 'Hello r'])
    public MyDataSource() {
        super(data)
    }

    public func pushData(str: String): Unit {
        this.data.add(str)
        this.notifyDataAdd(this.data.size - 1)
    }

    public func operateData(): Unit {
        this.data[4]=this.data[1]
        this.data.remove(at: 1)

        let temp: String = this.data[4]
        this.data[4] = this.data[6]
        this.data[6] = temp

        this.data.add(all: ["Hello 1", "Hello 2"], at: 8)

        this.data.remove(at: 10)
        this.data.remove(at: 11)
        this.notifyDatasetChange(ArrayList<DataOperation>([
                DataMoveOperation(from: 1, to: 3),
                DataExchangeOperation(start: 4, end: 6),
                DataAddOperation(8, count: 2, key: "", keys: [""]),
                DataDeleteOperation(10, count: 2)
            ]))
    }
}

@Entry
@Component
public class EntryView {
    let dataSource: MyDataSource = MyDataSource()

    public func build(): Unit {
        Column() {
            Row() {
                Button("change Data").onClick({ =>
                    this.dataSource.operateData()
                })
            }
            List(space: 3) {
                LazyForEach(dataSource, itemGenerator: { item: String, index: Int64 =>
                        ListItem() {
                            Text("${item}").fontSize(30)
                        }
                }, keyGenerator: { item: String, index: Int64 => return item+index.toString()})
        }.cachedCount(5)

        }.height(100.percent).height(100.percent)
    }
}
```

当单击LazyForEach的子组件时，首先调用dataSource的modifyAllData方法改变了数据源中的所有数据，然后调用数据源的reloadData方法，在该方法内会调用notifyDataReload方法。在notifyDataReload方法内会又调用listener.onDataReloaded方法，通知LazyForEach需要重建所有子节点。LazyForEach会将原所有数据项和新所有数据项一一做键值比对，若有相同键值则使用缓存，若键值不同则重新构建。

运行效果如下图所示。

**图8** LazyForEach改变多个数据

![lazyforeach-8](figures/lazyforeach-8.gif)

第二个例子，直接给数组赋值，operations直接从比较原数组和新数组得到。

<!-- code_check_manual -->

```cangjie
/** BasicDataSource代码见文档末尾附件: 泛型类型数组的BasicDataSource代码 **/

class MyDataSource <: BasicDataSource<String> {
    var data: ArrayList<String> = ArrayList<String>(['Hello a', 'Hello b', 'Hello c', 'Hello d',
                                                    'Hello e', 'Hello f', 'Hello g', 'Hello h'])
    public MyDataSource() {
        super(data)
    }

    public func operateData(): Unit {
        this.data = ArrayList<String>(['Hello a', 'Hello 1', 'Hello 2', 'Hello b', 'Hello c', 'Hello e',
                                    'Hello d', 'Hello f', 'Hello g', 'Hello h'])
        this.notifyDatasetChange(ArrayList<DataOperation>([
                DataAddOperation(1, count: 2, key: "", keys: []),
                DataExchangeOperation(start: 3, end: 4)
            ]))
    }
}

@Entry
@Component
public class EntryView {
    let dataSource: MyDataSource = MyDataSource()

    public func build(): Unit {
        Column() {
            Row() {
                Button("change Data").onClick({ =>
                    this.dataSource.operateData()
                })
            }
            List(space: 3) {
                LazyForEach(dataSource, itemGenerator: { item: String, index: Int64 =>
                        ListItem() {
                            Text("${item}").fontSize(30)
                        }
                }, keyGenerator: { item: String, index: Int64 => return item+index.toString()})
        }.cachedCount(5)

        }.height(100.percent).height(100.percent)
    }
}
```

**图9** LazyForEach改变多个数据

![lazyforeach-9](figures/lazyforeach-9.gif)

使用该接口时有如下注意事项。

1. onDatasetChange与其它操作数据的接口不能混用。
2. 传入onDatasetChange的operations，其中每一项operation的index均从修改前的原数组内寻找。因此，operations中的index跟操作Datasource中的index不总是一一对应的，而且不能是负数。

第一个例子清楚地显示了这一点：

```cangjie
// 修改之前的数组
["Hello a","Hello b","Hello c","Hello d","Hello e","Hello f","Hello g","Hello h","Hello i","Hello j","Hello k","Hello l","Hello m","Hello n","Hello o","Hello p","Hello q","Hello r"]
// 修改之后的数组
["Hello a","Hello c","Hello d","Hello b","Hello g","Hello f","Hello e","Hello h","Hello 1","Hello 2","Hello i","Hello j","Hello m","Hello n","Hello o","Hello p","Hello q","Hello r"]
```

"Hello b" 从第2项变成第4项，因此第一个 operation 为 DataMoveOperation(from: 1, to: 3)。

"Hello e" 跟 "Hello g" 对调了，而 "Hello e" 在修改前的原数组中的 index=4，"Hello g" 在修改前的原数组中的 index=6, 因此第二个 operation 为 DataExchangeOperation(start: 4, end: 6),。

"Hello 1","Hello 2" 在 "Hello h" 之后插入，而 "Hello h" 在修改前的原数组中的 index=7，因此第三个 operation 为 DataAddOperation(8, count: 2, key: "", keys: [])。

"Hello k","Hello l" 被删除了，而 "Hello k" 在原数组中的 index=10，因此第四个 operation 为 DataDeleteOperation(10, count: 2)。

1. 调用一次onDatasetChange，一个index对应的数据只能被操作一次，若被操作多次，LazyForEach仅使第一个操作生效。
2. 部分操作可以由开发者传入键值，LazyForEach不会再去重复调用keygenerator获取键值，需要开发者保证传入的键值的正确性。
3. 若本次操作集合中有RELOAD操作，则其余操作全不生效。

#### 改变数据子属性

若仅靠LazyForEach的刷新机制，当item变化时若想更新子组件，需要将原来的子组件全部销毁再重新构建，在子组件结构较为复杂的情况下，靠改变键值去刷新渲染性能较低。因此框架提供了[@Observed](../state_management/cj-macro-observed-and-publish.md)与[@Link](../state_management/cj-macro-link.md)机制进行深度观测，可以做到仅刷新使用了该属性的组件，提高渲染性能。开发者可根据其自身业务特点选择使用哪种刷新方式。

<!-- code_check_manual -->

```cangjie
/** BasicDataSource代码见文档末尾附件: 泛型类型数组的BasicDataSource代码 **/

@Observed
public class StringData {
    @Publish var message: String
}

class MyDataSource <: BasicDataSource<StringData> {
    public var data: ArrayList<StringData> = ArrayList<StringData>()
    public MyDataSource() {
        super(this.data)
    }

    public func pushData(stringData: StringData): Unit {
        this.data.add(stringData)
        this.notifyDataAdd(this.data.size - 1)
    }
}

@Component
class ChildComponent {
    @Link var data: StringData
    func build() {
        Row() {
            Text(this.data.message).fontSize(50)
        }
    }
}

@Entry
@Component
public class EntryView {
    let dataSource: MyDataSource = MyDataSource()

    protected override func aboutToAppear() {
        for (i in 0..20) {
              this.dataSource.pushData(StringData(message: "Hello ${i}"))
        }
    }

    public func build(): Unit {
        Column() {
            List(space: 3) {
                LazyForEach(dataSource, itemGenerator: { item: StringData, index: Int64 =>
                        ListItem() {
                            ChildComponent(data: item)
                        }.onClick({ _ => item.message += "0"})
                }, keyGenerator: { item: StringData, index: Int64 => return index.toString()})
        }.cachedCount(5)

        }.height(100.percent).height(100.percent)
    }
}
```

此时点击LazyForEach子组件改变item.message时，重渲染依赖的是ChildComponent的@Link成员变量对其子属性的监听，此时框架只会刷新Text(this.data.message)，不会去重建整个ListItem子组件。

**图10** LazyForEach改变数据子属性

![lazyforeach-10](figures/lazyforeach-10.gif)

## 常见使用问题

### 渲染结果非预期

<!-- code_check_manual -->

```cangjie
/** BasicDataSource代码见文档末尾附件: 泛型类型数组的BasicDataSource代码 **/

class MyDataSource <: BasicDataSource<String> {
    public var data: ArrayList<String> = ArrayList<String>()
    public MyDataSource() {
        super(this.data)
    }

    public func pushData(stringData: String): Unit {
        this.data.add(stringData)
        this.notifyDataAdd(this.data.size - 1)
    }

    public func deleteData(index: Int64): Unit {
        this.data.remove(at: index)
        this.notifyDataDelete(index)
    }
}

@Entry
@Component
public class EntryView {
    let dataSource: MyDataSource = MyDataSource()

    protected override func aboutToAppear() {
        for (i in 0..20) {
              this.dataSource.pushData("Hello ${i}")
        }
    }

    public func build(): Unit {
        Column() {
            List(space: 3) {
                LazyForEach(dataSource, itemGenerator: { item: String, index: Int64 =>
                        ListItem() {
                            Text(item)
                                .fontSize(50)
                        }.onClick({ _ =>
                            // 点击删除子组件
                            this.dataSource.deleteData(index)
                        })
                        .margin(left: 10, right: 10)
                }, keyGenerator: { item: String, index: Int64 => return item})
            }.cachedCount(5)
        }.height(100.percent)
        .width(100.percent)
    }
}
```

**图11** LazyForEach删除数据非预期

![lazyforeach-11](figures/lazyforeach-11.gif)

当多次点击子组件时，会发现删除的并不一定是单击的那个子组件。原因是当删除了某一个子组件后，位于该子组件对应的数据项之后的各数据项，其index均应减1，但实际上后续的数据项对应的子组件仍然使用的是最初分配的index，其itemGenerator中的index并没有发生变化，所以删除结果和预期不符。

修复代码如下所示。

<!-- code_check_manual -->

```cangjie
/** BasicDataSource代码见文档末尾附件: 泛型类型数组的BasicDataSource代码 **/

class MyDataSource <: BasicDataSource<String> {
    public var data: ArrayList<String> = ArrayList<String>()
    public MyDataSource() {
        super(this.data)
    }

    public func pushData(stringData: String): Unit {
        this.data.add(stringData)
        this.notifyDataAdd(this.data.size - 1)
    }

    public func deleteData(index: Int64): Unit {
        this.data.remove(at: index)
        this.notifyDataDelete(index)
    }

    public func reloadData(): Unit {
        this.notifyDataReload()
    }
}

@Entry
@Component
public class EntryView {
    let dataSource: MyDataSource = MyDataSource()

    protected override func aboutToAppear() {
        for (i in 0..20) {
              this.dataSource.pushData("Hello ${i}")
        }
    }

    public func build(): Unit {
        Column() {
            List(space: 3) {
                LazyForEach(dataSource, itemGenerator: { item: String, index: Int64 =>
                        ListItem() {
                            Text(item)
                                .fontSize(50)
                        }.onClick({ _ =>
                            // 点击删除子组件
                            this.dataSource.deleteData(index)
                            // 重置所有子组件的index索引
                            this.dataSource.reloadData()
                        })
                        .margin(left: 10, right: 10)
                }, keyGenerator: { item: String, index: Int64 => return item + index.toString()})
            }.cachedCount(5)
        }.height(100.percent)
        .width(100.percent)
    }
}
```

在删除一个数据项后调用reloadData方法，重建后面的数据项，以达到更新index索引的目的。要保证reloadData方法重建数据项，必须保证数据项能生成新的key。这里用了item + index.toString()保证被删除数据项后面的数据项都被重建。如果用item + DateTime.now().toString()替代，那么所有数据项都生成新的key，导致所有数据项都被重建。这种方法，效果是一样的，只是性能略差。

**图12** 修复LazyForEach删除数据非预期

![lazyforeach-12](figures/lazyforeach-12.gif)

### 在List内使用屏幕闪烁

在List的onScrollIndex方法中调用onDataReloaded有产生屏幕闪烁的风险。

<!-- code_check_manual -->

```cangjie
/** BasicDataSource代码见文档末尾附件: 泛型类型数组的BasicDataSource代码 **/

class MyDataSource <: BasicDataSource<String> {
    public MyDataSource(let data: ArrayList<String>) {
        super(data)
    }

    public func pushData(stringData: String): Unit {
        this.data.add(stringData)
        this.notifyDataAdd(this.data.size - 1)
    }

    public func operateData(): Unit {
        let totalCount = this.data.size
        let batch = 5
        for (i in totalCount..totalCount+batch) {
            this.data.add("Hello ${i}")
        }
        this.notifyDataReload()
    }
}

@Entry
@Component
public class EntryView {
    let dataSource: MyDataSource = MyDataSource(ArrayList<String>())

    protected override func aboutToAppear() {
        for (i in 0..10) {
            this.dataSource.pushData("Hello ${i}")
        }
    }

    public func build(): Unit {
        Column() {
            List(space: 3) {
                LazyForEach(dataSource, itemGenerator: { item: String, index: Int64 =>
                        ListItem() {
                            Text(item)
                                .width(100.percent)
                                .height(80)
                                .backgroundColor(Color.Gray)
                                .fontSize(30)
                        }.margin(left: 10, right: 10)
                    }
                )
            }.cachedCount(10)
            .onScrollIndex({start: Int32, end: Int32, center: Int32 =>
                if (Int64(end) == this.dataSource.totalCount() - 1) {
                        this.dataSource.operateData()
                }
            })

        }.height(100.percent).height(100.percent)
    }
}
```

当List下拉到底的时候，屏闪效果如下图。

![lazyforeach](figures/lazyforeach-13.gif)

用onDatasetChange代替onDataReloaded，不仅可以修复闪屏的问题，还能提升加载性能。

<!-- code_check_manual -->

```cangjie
/** BasicDataSource代码见文档末尾附件: 泛型类型数组的BasicDataSource代码 **/

class MyDataSource <: BasicDataSource<String> {
    public MyDataSource(let data: ArrayList<String>) {
        super(data)
    }

    public func pushData(stringData: String): Unit {
        this.data.add(stringData)
        this.notifyDataAdd(this.data.size - 1)
    }

    public func operateData(): Unit {
        let totalCount = this.data.size
        let batch = 5
        for (i in totalCount..totalCount+batch) {
            this.data.add("Hello ${i}")
        }
        this.notifyDatasetChange(ArrayList<DataOperation>([
                DataAddOperation(Int32(totalCount - 1), count: Int32(batch), key: "", keys: [""])
            ]))
    }
}

@Entry
@Component
public class EntryView {
    let dataSource: MyDataSource = MyDataSource(ArrayList<String>())

    protected override func aboutToAppear() {
        for (i in 0..10) {
            this.dataSource.pushData("Hello ${i}")
        }
    }

    public func build(): Unit {
        Column() {
            List(space: 3) {
                LazyForEach(dataSource, itemGenerator: { item: String, index: Int64 =>
                        ListItem() {
                            Text(item)
                                .width(100.percent)
                                .height(80)
                                .backgroundColor(Color.Gray)
                                .fontSize(30)
                        }.margin(left: 10, right: 10)
                    }
                )
            }.cachedCount(10)
            .onScrollIndex({start: Int32, end: Int32, center: Int32 =>
                if (Int64(end) == this.dataSource.totalCount() - 1) {
                        this.dataSource.operateData()
                }
            })

        }.height(100.percent).height(100.percent)
    }
}
```

![lazyforeach](figures/lazyforeach-14.gif)

## 附件

### 泛型类型数组的BasicDataSource代码

<!-- code_check_manual -->

```cangjie
// BasicDataSource实现了IDataSource接口，用于管理listener监听，以及通知LazyForEach数据更新
public open class BasicDataSource<T> <: IDataSource<T> {
    public BasicDataSource(let data_: ArrayList<T>) {}
    public var listenerOp: ArrayList<DataChangeListener> = ArrayList<DataChangeListener>()
    public func totalCount(): Int {
        return data_.size
    }
    public func getData(index: Int): T {
        return data_[index]
    }

    // 该方法为框架侧调用，为LazyForEach组件向其数据源处添加listener监听
    public func onRegisterDataChangeListener(listener: DataChangeListener): Unit {
        for (listeneritem in listenerOp) {
            if (refEq(listeneritem, listener)) {
                return
            }
        }
        listenerOp.add(listener)
    }

    // 该方法为框架侧调用，为对应的LazyForEach组件在数据源处去除listener监听
    public func onUnregisterDataChangeListener(listener: DataChangeListener): Unit {
        var index = 0
        while (index < listenerOp.size) {
            let listeneritem = listenerOp[index]
            if (refEq(listeneritem, listener)) {
                listenerOp.remove(at: index)
            } else {
                index++
            }
        }
    }

    // 通知LazyForEach组件需要重载所有子组件
    public func notifyDataReload(): Unit {
        for (listeneritem in listenerOp) {
            listeneritem.onDataReloaded()
        }
    }

    // 通知LazyForEach组件在index对应索引处数据有变化，需要重建该子组件
    public func notifyDataChange(index: Int64): Unit {
        for (listeneritem in listenerOp) {
            listeneritem.onDataChange(index)
        }
    }

    // 通知LazyForEach组件需要在index对应索引处添加子组件
    public func notifyDataAdd(index: Int64): Unit {
        for (listeneritem in listenerOp) {
            listeneritem.onDataAdd(index)
        }
    }

    // 通知LazyForEach组件需要在index对应索引处删除该子组件
    public func notifyDataDelete(index: Int64): Unit {
        for (listeneritem in listenerOp) {
            listeneritem.onDataDelete(index)
        }
    }

    // 通知LazyForEach组件将from索引和to索引处的子组件进行交换
    public func notifyDataMove(from: Int64, to: Int64): Unit {
        for (listeneritem in listenerOp) {
            listeneritem.onDataMove(from, to)
        }
    }

    public func notifyDatasetChange(operations: ArrayList<DataOperation>): Unit {
        for (listeneritem in listenerOp) {
            listeneritem.onDatasetChange(operations)
        }
    }
}
```
