//
//  UITextField+Utilities.h
//  Safe Gale
//
//  Created by Chase Acton on 3/27/16.
//  Copyright © 2016 Tapgods. All rights reserved.
//

#import <UIKit/UIKit.h>

/** @enum ShakeDirection
 *
 * Enum that specifies the direction of the shake
 */
typedef NS_ENUM(NSInteger, ShakeDirection) {
    /** Shake left and right */
    ShakeDirectionHorizontal,
    /** Shake up and down */
    ShakeDirectionVertical
};

@interface UITextField (Utilities)

- (void)addLeftPadding;
- (void)setBorderColor:(nonnull UIColor *)color;
- (void)showError;

#pragma mark - Shake

/** Shake the UITextField
 *
 * Shake the text field with default values
 */
- (void)shake;

/** Shake the UITextField
 *
 * Shake the text field a given number of times
 *
 * @param times The number of shakes
 * @param delta The width of the shake
 */
- (void)shake:(int)times withDelta:(CGFloat)delta;

/** Shake the UITextField
 *
 * Shake the text field a given number of times
 *
 * @param times The number of shakes
 * @param delta The width of the shake
 * @param handler A block object to be executed when the shake sequence ends
 */
- (void)shake:(int)times withDelta:(CGFloat)delta completion:(nullable void (^)(void))handler;

/** Shake the UITextField at a custom speed
 *
 * Shake the text field a given number of times with a given speed
 *
 * @param times The number of shakes
 * @param delta The width of the shake
 * @param interval The duration of one shake
 */
- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval;

/** Shake the UITextField at a custom speed
 *
 * Shake the text field a given number of times with a given speed
 *
 * @param times The number of shakes
 * @param delta The width of the shake
 * @param interval The duration of one shake
 * @param handler A block object to be executed when the shake sequence ends
 */
- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval completion:(nullable void (^)(void))handler;

/** Shake the UITextField at a custom speed
 *
 * Shake the text field a given number of times with a given speed
 *
 * @param times The number of shakes
 * @param delta The width of the shake
 * @param interval The duration of one shake
 * @param direction of the shake
 */
- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval shakeDirection:(ShakeDirection)shakeDirection;

/** Shake the UITextField at a custom speed
 *
 * Shake the text field a given number of times with a given speed
 *
 * @param times The number of shakes
 * @param delta The width of the shake
 * @param interval The duration of one shake
 * @param direction of the shake
 * @param handler A block object to be executed when the shake sequence ends
 */
- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval shakeDirection:(ShakeDirection)shakeDirection completion:(nullable void (^)(void))handler;

@end