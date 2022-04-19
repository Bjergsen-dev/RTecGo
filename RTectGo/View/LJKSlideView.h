//
//  LJKSlideView.h
//  RTectGo
//
//  Created by Apple on 2019/3/19.
//  Copyright © 2019年 zzcBjergsen. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LJKSlideViewDelegate <NSObject>

- (void)slideNeedDoSometing;

@end

@interface LJKSlideView : UIView

@property (nonatomic, weak)id<LJKSlideViewDelegate> delegate;

@property (nonatomic, copy)void(^slideNeedDoSometingBlock)();
//如果在上下文比较紧密的地方使用控件 可以使用block 这样比较方便获取上文中的内容 但是要注意循环引用的问题
//代理和block二选其一即可

@end


