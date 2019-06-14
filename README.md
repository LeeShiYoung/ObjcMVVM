
### 理解MVVM
**MVVM** 和 **MVC** 的构建方式很相似，甚至可以说在同一个项目中同时使用这两种架构都不会有任何违和感。**MVVM** 可以看作是 **MVC** 的衍生版，其承担 **MVC** 架构下的 **Controller** 的一部分职责，这部分职责也就是 **ViewModel** 所需要做的事情。在 **MVVM** 中 **Model** 和 **View** 之间的通信，是通过 **ViewModel** 构建的一条数据管道，**ViewModel** 将 **View** 所要展示的 **Model** 层的数据，转化为最终所需要的版本，**View**  直接来拿展示。当然这种管道的构建最好通过响应式框架： [ReactiveObjc](https://github.com/ReactiveCocoa/ReactiveObjC)、[RxSwift](https://github.com/ReactiveX/RxSwift)。 同样，两种架构同样都是 **Controller** 充分了解程序各组件，并将他们构建和连接起来。但相比起 **MVC** ，**MVVM** 有以下几点不同：

- **Model** 由 **ViewModel** 持有，并不是 **Controller**
- 需建立起 **ViewModel** 和 **View** 之间的绑定关系

> 本文不会使用响应式框架构建绑定关系，而是通过原生API：**KVO**+**KVC** 的方式构建。
### 功能封装
* #### Controller 基类
    众所周知，在 **MVVM** 架构中，**Controller** 是需持有 **ViewModel** 的。所以构建基类，建立一个 **ViewModel** 属性是非常有必要的。这样所有继承自 **基类 Controller** 的子控制器都会拥有 **ViewModel** 。
    ```objc
    @interface MVVMGenericsController<ViewModelType: id<ViewModelProtocol>> : UIViewController

    @property (nonatomic, strong) ViewModelType viewModel;

    @end
    ```
    首先，**基类 Controller** 是泛型的（鉴于 Objective-C 中泛型的功能不想 Swift 那么强大，这里仅仅起到个标记的作用，帮助编译器推断 ViewModel 类型），暂且叫它 **MVVMGenericsController** ，其 **ViewModel** 类型需要实现 **ViewModelProtocol** 协议，暂且忽略这个协议，目前来说，不会对阅读代码产生任何影响。其次，定义了 **viewModel** 属性。
    
    
* #### 绑定时机
    上文说到，**MVVM** 的关键在于构建 **ViewModel** 和 **View** 之间的管道，建立绑定关系。既然这样，可以在 **Controller** 中设定一个自动回调方法，在某个时机将其触发并在方法当中构建绑定关系。
    ```objc
     - (void)bind:(id<ViewModelProtocol>)viewModel {     }
    ```
    那么，在何时触发这个方法呢？在触发 `bind:` 方法之前，需要确定 **View** 和 **ViewModel** 都不为空（这里的 View 指代，需要显示数据的控件，如 Controller 中的 UITableView，ViewModelProtocol 协议后面会讲到），因为需要在这个方法中建立绑定关系，所以必须保证二者是有值的。一般来说，控制器中子控件的创建，是放在 `- (void)viewDidLoad` 或者 `- (void)loadView` 方法里面，所以可以在这两个方法之后调用的 `- (void)viewWillAppear:(BOOL)animated` 响应 `bind:` 方法。当然，在每个控制器中都去手动添加 `[self bind]` 这样的代码，无疑很麻烦。可以通过 iOS 黑魔法：**hook** 操作实现自动调用。
    ```objc
    @implementation UIViewController (Binding)

    + (void)load {
         [self hookOrigInstanceMenthod:@selector(viewWillAppear:) newInstanceMenthod:@selector(mvvm_viewWillAppear:)];
    }

    - (void)mvvm_viewWillAppear:(BOOL)animated {
       [self mvvm_viewWillAppear:animated];
    
       if (!self.isAlreadyBind) {
            if ([self isKindOfClass:[MVVMGenericsController class]]) {
                objc_msgSend((MVVMGenericsController *)self, @selector(bindTransfrom));
            }   
           self.isAlreadyBind = YES;
        }
    }

    - (void)setIsAlreadyBind:(BOOL)isAlreadyBind {
        objc_setAssociatedObject(self, &kIsAlreadyBind, @(isAlreadyBind), OBJC_ASSOCIATION_ASSIGN);
    }

    - (BOOL)isAlreadyBind {
        return !(objc_getAssociatedObject(self, &kIsAlreadyBind) == nil);
    }

    - (void)bindTransfrom {}
    
    @end
    ```
    首先， **hook** 操作是在扩展当中实现的。在 `+ (void)load ` 方法当中将自定义的方法和系统的 `viewWillAppear:` 交换。`+ (void)load ` 是在程序编译加载阶段由系统调用，并且只会调用一次，并且在 main 函数之前。故这里是部署 **hook** 最理想的地方。其次，在这个扩展当中关联了 **isAlreadyBind** 属性，目的使一个 **Controller** 在销毁之前只触发一次 `bind:` 方法。再次，通过 `isKindOfClass` 判断当前类是不是 `MVVMGenericsController` 的子类，如果是，就发送 `bindTransfrom` 消息，`bindTransfrom` 仅仅是个空方法，不出意外，永远不会调用到这里，它仅仅是让编译器不出现让人厌烦的黄色警告。
* #### MVVMGenericsController 的实现部分
    在 **MVVMGenericsController** 才是实现 `bindTransfrom：` 的地方，因为它才是被真正发出的消息。
    ```objc
    @implementation MVVMGenericsController

    - (void)bindTransfrom {
        if ([self conformsToProtocol:@protocol(ViewBinder)] && [self respondsToSelector:@selector(bind:)]) {
            if ([self.viewModel conformsToProtocol:@protocol(ViewModelProtocol)]) {
            [((id <ViewBinder>)self) bind:self.viewModel];
                return;
            }
        }
    }

    @end
    ```
    `<ViewBinder>` 协议提供了上文提到的，`- (void)bind:(id<ViewModelProtocol>)viewModel` 方法
    ```objc
    @protocol ViewBinder <NSObject>

    - (void)bind:(id<ViewModelProtocol>)viewModel; 

    @end
    ```
    首先会判断当前控制器是否实现了 `ViewBinder` 协议并且是否能响应 `bind:` 方法，如果能则派发 `bind:` ，参数是 **ViewModel**。**ViewModel** 的赋值是在控制器的自定义构造方法中，或者在 `- (void)viewWillAppear:` 之前。一旦没有在合适的位置赋值，这里会是 **nil** 。
* #### 实现绑定接口
    这里的绑定功能是响应式的，通过观察属性的改变立即得到反馈。当然，通过代理也可以实现，但响应式无疑是最轻量级的。在这里是借助 [KVOController](https://github.com/facebook/KVOController) + 系统原生API **KVC** 实现的。一个对象的某个属性被观察后，一旦它发生值的改变，立即将它的结果通过 **KVC** 赋值给另一个对象的某一个属性，这即是建立绑定的过程。这里给 **NSObject** 扩展一些方法：
    ```objc
    @implementation NSObject (Binder)

    - (void)bind:(NSString *)sourceKeyPath to:(id)target at:(NSString *)targetKeyPath {
        [self.KVOController observe:self keyPath:sourceKeyPath options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            id newValue = change[NSKeyValueChangeNewKey];
            if ([self verification:newValue]) {
                [target setValue:newValue forKey:targetKeyPath];
            }
        }];
    }
    
    - (BOOL)verification:(id)newValue {
     if ([newValue isEqual: [NSNull null]]) {
         return NO;
      }
      return YES;
    }

    @end
    ```
    `sourceKeyPath`: 被观察对象属性的 **keyPath**、`target`: 目标对象，即被观察到的值赋值给的对象、`at`：目标对象的属性 **keyPath**。在 **Objective-C** 中没有没有像 **Swift** 当中的 `\Foo.bar` 的 **KeyPath** 功能，所以这里的键路径只能是字符串。

### 实现一个案例
- #### ViewModel
    毫无疑问，**ViewModel** 是 **MVVM** 的核心部件。一个复杂功能的模块，**ViewModel** 可能会有很大篇幅的代码。**ViewModel** 应包含一个功能模块的大部分业务逻辑，一个具有交互功能的页面，无疑需要状态的支持。所以 **ViewModel** 将数据加工好后通过 **State** 抛出给外部。另一部分，外部通过 **Action** 通知 **ViewModel** 需要做的事情。

    所以，一个 **ViewModel** 主要由两部分组成 **Action** 和 **State** ：
    ```objc
    @interface DemoViewModel : NSObject<ViewModelProtocol> // 只是个空协议
    
    // Action
    - (void)changeTitle;
    
    // State
    @property (nonatomic, copy, readonly) NSString *title;
    
    // Model
    @property (nonatomic, copy, readonly) NSArray *titleArray;

    @end
    ```
    注意：这里的 **title**（也就是 **State** ）是 `readonly` 的，要严格采用这种方式，因为一个 **State** 仅仅是 **只读** 的就够了。
    ```objc
    @interface DemoViewModel()

    @property (nonatomic, copy, readwrite) NSString *title;

    @end

    @implementation DemoViewModel

    - (instancetype)init {
          self = [super init];
          if (self) {
              _titleArray = @[@"MVC", @"MVVM", @"SWift", @"ReactNative"];
             _title = _titleArray[1];
          }
         return self;
    }

    - (void)changeTitle {
          self.title = _titleArray[[self randomFloatBetween:0 andLargerFloat:4]];
    }

    @end
    ```
    在 **ViewModel** 的实现部分中将 **title** 重置为 **readwrite** ，因为要通过 **changeTitle**（也就是 **Action**）改变 **title** 的值。
    
- #### Controller
    **Controller** 的职责是将各组件连接起来，在这里构建起 **View** <-> **ViewModel** 的管道，当然，这个管道是双向的，也就是 **双向绑定** 。
    ```objc
    @interface DemoViewController : MVVMGenericsController<DemoViewModel *><ViewBinder>

    @end
    ```
    首先，将 **MVVMGenericsController** 作为父类，因 **MVVMGenericsController** 中定义了泛型 **ViewModelType** ，在这里需要指定 **ViewModel** 的具体类型 `<DemoViewModel *>`。其次，实现了 `<ViewBinder>` 协议，该协议提供 `- (void)bind:(DemoViewModel *)viewModel` 方法。
    ```objc
    @interface DemoViewController ()

    @property (nonatomic, strong) UILabel *titleLabel;

    @end

    @implementation DemoViewController

    - (void)bind:(DemoViewModel *)viewModel {
         [viewModel bind:@"title" to:self.titleLabel at:@"text"];
    }

    - (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
         [self.viewModel changeTitle];
    }
    
    ```
    在 `- (void)bind:(DemoViewModel *)viewModel` 方法中，建立了 `ViewModel` 的 `title` 同 `titleLabel` 的 `text` 的绑定关系，在这里真正将 **ViewModel** 同 **View** 的管道打通。
    
    在 `- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event` 方法中，调用了 **ViewModel** 的 `- (void)changeTitle` 方法，目的是改变 `title` 的值，而一旦 `title` 值改变，`bind:` 方法就会监听到值的改变并且将 **新的值** 赋值给 **titleLabel.text**。这样就形成了一个单向的数据信息流动。如下图：
    
    ![](https://user-gold-cdn.xitu.io/2019/6/14/16b56691cf2f5766?w=658&h=888&f=png&s=94033)
    一个原则：**State** 的改变需通过 **Action**。
    
    到此为止，一个简单的 **MVVM** 搭建完毕。当然，可以有很多的 **State** 也可以有很多的 **Action** 。只要遵守这个规则，一个 **响应式** 、**单向数据流** 的应用就诞生了。
    
### 解除引用循环
很不幸的说，`[viewModel bind:@"title" to:self.titleLabel at:@"text"];` 这段代码会产生一个引用循环：**viewModel** 通过 **KVO** 观察了自己的 **title** 属性。这样 **KVOController** 无法自动移除观察者，所以要手动移除，当然，这个过程是在背后操作的：
```objc
const void* const kIsCallPop = &kIsCallPop;

@implementation UIViewController (RetainCircle)

+ (void)load {
    [self hookOrigInstanceMenthod:@selector(viewDidDisappear:) newInstanceMenthod:@selector(mvvm_viewDidDisappear:)];
}

- (void)mvvm_viewDidDisappear:(BOOL)animated {
    [self mvvm_viewDidDisappear:animated];
    
    if ([objc_getAssociatedObject(self, kIsCallPop) boolValue]) {
        if ([self isKindOfClass:[MVVMGenericsController class]] && [((MVVMGenericsController *)self).viewModel conformsToProtocol:@protocol(ViewModelProtocol)]) {
            NSObject *vm = ((MVVMGenericsController *)self).viewModel;
            [vm.KVOController unobserveAll];
        }
    }
}

@end

@implementation UINavigationController (RetainCircle)

+ (void)load {
    [self hookOrigInstanceMenthod:@selector(popViewControllerAnimated:) newInstanceMenthod:@selector(mvvm_popViewControllerAnimated:)];
}

- (UIViewController *)mvvm_popViewControllerAnimated:(BOOL)animated {
    UIViewController* popViewController = [self mvvm_popViewControllerAnimated:animated];
    objc_setAssociatedObject(popViewController, kIsCallPop, @(YES), OBJC_ASSOCIATION_RETAIN);
    return popViewController;
}
```
同样是通过方法交换，很简单，代码不解释了。

### 结束
通过阅读这篇文章，对 **MVVM** 是否有了一个全新的认识呢？当然这套代码还有很多不完善的地方，但不影响阅读，不影响对代码的理解。我想这样就够了。

就是这些，这里是
