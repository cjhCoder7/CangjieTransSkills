package ohos_app_cangjie_entry.models

import std.random.Random

/// 习惯可选颜色枚举
public enum HabitColor {
    | Yellow
    | Purple
    | Cyan
    | Pink
    | Red
    | Orange
    | Jasmine
    | Green
    | Blue

    public operator func ==(right: HabitColor): Bool {
        match (this) {
            case Yellow  => match (right) { case Yellow  => true case _ => false }
            case Purple  => match (right) { case Purple  => true case _ => false }
            case Cyan    => match (right) { case Cyan    => true case _ => false }
            case Pink    => match (right) { case Pink    => true case _ => false }
            case Red     => match (right) { case Red     => true case _ => false }
            case Orange  => match (right) { case Orange  => true case _ => false }
            case Jasmine => match (right) { case Jasmine => true case _ => false }
            case Green   => match (right) { case Green   => true case _ => false }
            case Blue    => match (right) { case Blue    => true case _ => false }
        }
    }

    /// 返回颜色对应的资源名
    public prop resourceName: String {
        get() {
            match (this) {
                case Yellow => "habit_yellow"
                case Purple => "habit_purple"
                case Cyan   => "habit_cyan"
                case Pink   => "habit_pink"
                case Red    => "habit_red"
                case Orange => "habit_orange"
                case Jasmine=> "habit_jasmine"
                case Green  => "habit_green"
                case Blue   => "habit_blue"
            }
        }
    }

    /// 返回颜色对应的 hex 值
    public prop hexValue: String {
        get() {
            match (this) {
                case Yellow => "#FFE36D"
                case Purple => "#8B77EC"
                case Cyan   => "#51D1F0"
                case Pink   => "#FC97B3"
                case Red    => "#F97267"
                case Orange => "#FCA96F"
                case Jasmine=> "#DAEC69"
                case Green  => "#55F19F"
                case Blue   => "#4B93FF"
            }
        }
    }

    /// 返回颜色对应的 UInt32 值（ARGB 格式）
    public prop colorValue: UInt32 {
        get() {
            match (this) {
                case Yellow => 0xFFFFE36D
                case Purple => 0xFF8B77EC
                case Cyan   => 0xFF51D1F0
                case Pink   => 0xFFFC97B3
                case Red    => 0xFFF97267
                case Orange => 0xFFFCA96F
                case Jasmine=> 0xFFDAEC69
                case Green  => 0xFF55F19F
                case Blue   => 0xFF4B93FF
            }
        }
    }
}

/// 所有颜色值列表（enum 外定义）
public let allHabitColors: Array<HabitColor> = [
    HabitColor.Yellow, HabitColor.Purple, HabitColor.Cyan,
    HabitColor.Pink, HabitColor.Red, HabitColor.Orange,
    HabitColor.Jasmine, HabitColor.Green, HabitColor.Blue
]

/// 随机返回一个习惯颜色
public func randomHabitColor(): HabitColor {
    let index = Random().nextUInt64() % UInt64(allHabitColors.size)
    allHabitColors[Int64(index)]
}

/// 从字符串解析颜色，失败时返回 Blue
public func habitColorFromString(value: String): HabitColor {
    for (c in allHabitColors) {
        if (c.resourceName == value) {
            return c
        }
    }
    return HabitColor.Blue
}
