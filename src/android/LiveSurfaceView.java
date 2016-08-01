package xwang.cordova.vcloud.livestreaming;

import android.content.Context;
import android.util.AttributeSet;

import com.netease.LSMediaCapture.lsSurfaceView;

public class LiveSurfaceView extends lsSurfaceView {

  private int previewWidth;
  private int previewHeight;
  private float ratio;

  public LiveSurfaceView(Context context) {
    super(context);
  }

  public LiveSurfaceView(Context context, AttributeSet attrs) {
    super(context, attrs);
  }

  public LiveSurfaceView(Context context, AttributeSet attrs, int defStyle) {
    super(context, attrs, defStyle);
  }

  public void setPreviewSize(int width, int height) {
    int screenW = getResources().getDisplayMetrics().widthPixels;
    int screenH = getResources().getDisplayMetrics().heightPixels;
    if (screenW < screenH) {
      previewWidth = width < height ? width : height;
      previewHeight = width >= height ? width : height;
    }
    else {
      previewWidth = width > height ? width : height;
      previewHeight = width <= height ? width : height;
    }
    ratio = previewHeight / (float) previewWidth;
    previewWidth = screenW;
    previewHeight = screenH;
    requestLayout();
  }

  @Override
  protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
    int previewW     = MeasureSpec.getSize(widthMeasureSpec);
    int previewWMode = MeasureSpec.getMode(widthMeasureSpec);
    int previewH     = MeasureSpec.getSize(heightMeasureSpec);
    int previewHMode = MeasureSpec.getMode(heightMeasureSpec);

    int measuredWidth  = 0;
    int measuredHeight = 0;

    int defineWidth  = 0;
    int defineHeight = 0;

    if (previewWidth > 0 && previewHeight > 0) {
      measuredWidth = defineWidth(previewW, previewWMode);

      measuredHeight = (int) (measuredWidth * ratio);
      if (previewHMode != MeasureSpec.UNSPECIFIED && measuredHeight > previewH) {
        measuredWidth = (int) (previewH / ratio);
        measuredHeight = previewH;
      }

      defineWidth = defineWidth(previewW, previewWMode);
      defineHeight = defineHeight(previewH, previewHMode);

      if(defineHeight*1.0/defineWidth > ratio)
      {
        measuredHeight = defineHeight(previewH, previewHMode);
        measuredWidth = (int) (measuredHeight/ratio);
      }
      else
      {
        measuredWidth = defineWidth(previewW, previewWMode);
        measuredHeight = (int) (measuredWidth*ratio);
      }

      setMeasuredDimension(measuredWidth, measuredHeight);
    }
    else {
      super.onMeasure(widthMeasureSpec, heightMeasureSpec);
    }
  }

  protected int defineWidth(int previewW, int previewWMode) {
    int measuredWidth;
    if (previewWMode == MeasureSpec.UNSPECIFIED) {
      measuredWidth = previewWidth;
    }
    else if (previewWMode == MeasureSpec.EXACTLY) {
      measuredWidth = previewW;
    }
    else {
      measuredWidth = Math.min(previewW, previewWidth);
    }
    return measuredWidth;
  }

  protected int defineHeight(int previewH, int previewHMode) {
    int measuredHeight;
    if (previewHMode == MeasureSpec.UNSPECIFIED) {
      measuredHeight = previewHeight;
    }
    else if (previewHMode == MeasureSpec.EXACTLY) {
      measuredHeight = previewH;
    }
    else {
      measuredHeight = Math.min(previewH, previewHeight);
    }
    return measuredHeight;
  }

}
