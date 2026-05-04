/**
 * Created on 2025-08-19
 */
package ohos_app_cangjie_entry.common

import ohos.base.*
import ohos.state_macro_manage.*
import cj_res_entry.app

/*
 * The config of Image Rotate animation.
 */
public class RotatePosition {
 public static let X:Float32 = 0.0;
 public static let Y:Float32 = 0.0;
 public static let Z:Float32 = 1.0;
};

/*
 * The config is a option of Slider which control speed.
 */
public class SliderSpeed {
  public static let MIN = 1.0;
  public static let MAX = 20.0;
  public static let STEP = 2.0;
};

/*
 * The mode display the different styles of Slider.
 */
public class SliderMode {
  public static let SPEED = 1;
  public static let SCALE = 2;
};

public class Constants {

     /*
   * The font size of app.
   */
  public static let FONT_SIZE = 14;
  /*
   * The layout weight of slider.
   */
  public static let LAYOUT_WEIGHT: Int32 = 1;
  /**
   * The percentage of 100.
   */
  public static let PERCENTAGE_100 = 100.percent;
  /**
   * The delay time of interval to slider speed.
   */
  public static let DELAY_TIME = 15;
  /**
   * The color of slider.
   */
  public static let SLIDER_SKIN = @r(app.color.slider_color);
  /**
   * The time of slider interval.
   */
  public static let INTERVAL = 0;
  /**
   * The speed of slider interval.
   */
  public static let SPEED:Float32 = 5.0;
  /**
   * The margin value of the windmill image.
   */
  public static let WEIGHT_BLANK_IMAGE = 15.percent;
  /**
   * The top margin value of slider panel.
   */
  public static let PANEL_MARGIN_TOP = 4.percent;
  /**
   * The bottom margin value of slider panel.
   */
  public static let PANEL_MARGIN_BOTTOM = 5.percent;
  /**
   * The size of the windmill image.
   */
  public static let IMAGE_SIZE = 150;
  /**
   * The angle of the windmill image.
   */
  public static let ANGLE: Float32 = 0.0;
  /**
   * The default size of the windmill image.
   */
  public static let IMAGE_SIZE_INITIAL:Float32 = 1.0;
  /**
   * The text config of panel component.
   */
  public static let FRACTION_DIGITS = 1;
  /**
   * The padding of panel component title.
   */
  public static let TITLE_PADDING = 5;
  /**
   * The margin of panel component title.
   */
  public static let TITLE_MARGIN_HORIZONTAL = 10;
  /**
   * The bottom margin of panel component text.
   */
  public static let SPEED_MARGIN_BOTTOM = 6;
  /**
   * The margin of slider.
   */
  public static let SLIDER_MARGIN_HORIZONTAL = 11;
  /**
   * The radius of panel.
   */
  public static let PANEL_RADIUS = 24;
  /**
   * The width of panel image.
   */
  public static let PANEL_IMAGE_WIDTH = 19;
  /**
   * The height of panel image.
   */
  public static let PANEL_IMAGE_HEIGHT = 16;
  /**
   * The height of panel big image.
   */
  public static let PANEL_IMAGE_BIG_HEIGHT = 18;
  /**
   * The width of panel big image.
   */
  public static let PANEL_IMAGE_BIG_WIDTH = 22;
  /**
   * The width of panel.
   */
  public static let PANEL_WIDTH = 98.percent;
  /**
   * The font size of panel left.
   */
  public static let PANEL_FONT_SIZE = 20;
  /**
   * The font size of panel end.
   */
  public static let PANEL_END_FONT_SIZE = 24;
  /**
   * The scale text of panel.
   */
  public static let PANEL_HOLDER = 'A';
  /**
   * The height of panel.
   */
  public static let PANEL_HEIGHT = 100;
  /**
   * The padding of panel.
   */
  public static let PANEL_PADDING = 10;
  /**
   * The margin of panel.
   */
  public static let PANEL_MARGIN = 10;

  /*
   * The config is a option of Slider which control scale.
   */
  public static let MIN: Float64 = 0.5;

  public static let MAX: Float64 = 2.5;

  public static let STEP: Float64 = 0.1;


}