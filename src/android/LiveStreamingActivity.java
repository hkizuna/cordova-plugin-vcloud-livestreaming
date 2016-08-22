package xwang.cordova.vcloud.livestreaming;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.hardware.Camera;
import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.method.ScrollingMovementMethod;
import android.text.style.ForegroundColorSpan;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import __PACKAGE_NAME__.R;
import com.netease.LSMediaCapture.*;
import com.netease.LSMediaCapture.lsMediaCapture.*;

import java.io.File;
import java.io.FileOutputStream;
import java.util.Calendar;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.Semaphore;


@SuppressWarnings({"deprecation", "unused"})
public class LiveStreamingActivity extends Activity implements lsMessageHandler{
  public static final int CAMERA_POSITION_BACK = 0;
  public static final int CAMERA_ORIENTATION_LANDSCAPE = 1;
  public static final int LS_VIDEO_CODEC_AVC = 0;
  public static final int LS_AUDIO_CODEC_AAC = 0;
  public static final int RTMP = 1;
  public static final int HAVE_AV = 2;

  public static final int STREAMING_QUALITY_MEDIUM = 0;
  public static final int STREAMING_QUALITY_HIGH = 1;
  public static final int STREAMING_QUALITY_SUPER = 2;

  private String mLogPath = null;
  private static Context mContext;
  private String mUrl;
  private String mTitle;
  private LiveSurfaceView mStreamingView;
  private FrameLayout mControlOverlay;
  private RelativeLayout mTopView;
  private RelativeLayout mBottomView;
  private Button mBackBtn;
  private TextView mTitleLabel;
  private ImageButton mPlayBtn;
  private ImageButton mFlashBtn;
  private ImageButton mCameraBtn;
  private ImageButton mQualityBtn;

  private ImageButton mMicBtn;
  private ProgressBar mBlowLevelProgress;
  private ImageButton mChannelBtn;
  private ImageButton mSnapshotBtn;
  private static TextView mChannelText;
  private boolean isChannelHide = false;
  public static Handler UIHandler = new Handler(Looper.getMainLooper());

  private boolean isHide = false;
  private boolean flashOn = false;
  private boolean micOn = true;

  private lsMediaCapture mLSMediaCapture = null;
  private LSLiveStreamingParaCtx mLSLiveStreamingParaCtx = null;

  private boolean mStreamingOn;
  private boolean mStreamingStarted;
  private boolean mPreviewOn;
  private int mPreviewWidth;
  private int mPreviewHeight;
  private int mPreviewBitrate;

  private Thread mCameraThread;
  private Looper mCameraLooper;
  private Camera mCamera;

  private int mCameraPosition = CAMERA_POSITION_BACK;
  private int mQuality = STREAMING_QUALITY_SUPER;
  private int mSelectedQuality = STREAMING_QUALITY_SUPER;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    mContext = this;
    mUrl = getIntent().getStringExtra("url");
    mTitle = getIntent().getStringExtra("title");

    initUI();
    initMediaCapture();
    initBlowLevelDetection();
  }

  private void initUI() {
    getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    requestWindowFeature(Window.FEATURE_NO_TITLE);
    setContentView(R.layout.activity_livestreaming);

    mStreamingView = (LiveSurfaceView) findViewById(R.id.streamingView);
    mStreamingView.setOnClickListener(mOnClickEvent);

    mControlOverlay = (FrameLayout) findViewById(R.id.controlOverlay);
    mControlOverlay.setOnClickListener(mOnClickEvent);

    mTopView = (RelativeLayout) findViewById(R.id.topView);

    mBackBtn = (Button) findViewById(R.id.backBtn);
    mBackBtn.setOnClickListener(mOnClickEvent);

    mTitleLabel = (TextView) findViewById(R.id.titleLabel);
    mTitleLabel.setText(mTitle);

    mBottomView = (RelativeLayout) findViewById(R.id.bottomView);

    mPlayBtn = (ImageButton) findViewById(R.id.playBtn);
    mPlayBtn.setOnClickListener(mOnClickEvent);

    mFlashBtn = (ImageButton) findViewById(R.id.flashBtn);
    mFlashBtn.setOnClickListener(mOnClickEvent);

    mCameraBtn = (ImageButton) findViewById(R.id.cameraBtn);
    mCameraBtn.setOnClickListener(mOnClickEvent);

    mQualityBtn = (ImageButton) findViewById(R.id.qualityBtn);
    mQualityBtn.setOnClickListener(mOnClickEvent);

    mMicBtn = (ImageButton) findViewById(R.id.micBtn);
    mMicBtn.setOnClickListener(mOnClickEvent);

    mBlowLevelProgress = (ProgressBar) findViewById(R.id.blowLevelProgress);

    mChannelBtn = (ImageButton) findViewById(R.id.channelBtn);
    mChannelBtn.setOnClickListener(mOnClickEvent);

    mSnapshotBtn = (ImageButton) findViewById(R.id.snapshotBtn);
    mSnapshotBtn.setOnClickListener(mOnClickEvent);

    mChannelText = (TextView) findViewById(R.id.channelText);
    mChannelText.setMovementMethod(new ScrollingMovementMethod());
  }

  private void initMediaCapture() {
    initCameraSupportResolution(mQuality, mCameraPosition);
    mLSMediaCapture = new lsMediaCapture(this, mContext, mPreviewWidth, mPreviewHeight);
    mStreamingView.setPreviewSize(mPreviewWidth, mPreviewHeight);
    mStreamingOn = false;
    mPreviewOn = false;
    mStreamingStarted = false;
    initLog();
    initParaCtx(mPreviewWidth, mPreviewHeight, mPreviewBitrate);

    if (mLSMediaCapture != null) {
      mLSMediaCapture.startVideoPreview(mStreamingView, mLSLiveStreamingParaCtx.sLSVideoParaCtx.cameraPosition.cameraPosition);
      boolean ret = mLSMediaCapture.initLiveStream(mUrl, mLSLiveStreamingParaCtx);
      if (ret) {
        Log.d("LSMediaCapture", "initLiveStream succeed.");
      }
      else {
        Log.d("LSMediaCapture", "initLiveStream failed.");
      }
    }
  }

  private void initCameraSupportResolution(int quality, int cameraPosition) {
    List<Camera.Size> sizes = getCameraSupportSize(cameraPosition);
    switch (quality) {
      case STREAMING_QUALITY_MEDIUM:
        mPreviewWidth = 320;
        mPreviewHeight = 240;
        mPreviewBitrate = 250000;
        break;
      case STREAMING_QUALITY_HIGH:
        mPreviewWidth = 640;
        mPreviewHeight = 480;
        mPreviewBitrate = 600000;
        break;
      case STREAMING_QUALITY_SUPER:
        mPreviewWidth = 1280;
        mPreviewHeight = 720;
        mPreviewBitrate = 1500000;
        break;
    }
  }

  private void initLog() {
    if (mLSMediaCapture != null) {
      getLogPath();
      mLSMediaCapture.setTraceLevel(0, mLogPath);
    }
  }

  private void initParaCtx(int width, int height, int bitrate) {
    mLSLiveStreamingParaCtx = mLSMediaCapture.new LSLiveStreamingParaCtx();
    mLSLiveStreamingParaCtx.eHaraWareEncType = mLSLiveStreamingParaCtx.new HardWareEncEnable();
    mLSLiveStreamingParaCtx.eOutFormatType = mLSLiveStreamingParaCtx.new OutputFormatType();
    mLSLiveStreamingParaCtx.eOutStreamType = mLSLiveStreamingParaCtx.new OutputStreamType();
    mLSLiveStreamingParaCtx.sLSAudioParaCtx = mLSLiveStreamingParaCtx.new LSAudioParaCtx();
    mLSLiveStreamingParaCtx.sLSAudioParaCtx.codec = mLSLiveStreamingParaCtx.sLSAudioParaCtx.new LSAudioCodecType();
    mLSLiveStreamingParaCtx.sLSVideoParaCtx = mLSLiveStreamingParaCtx.new LSVideoParaCtx();
    mLSLiveStreamingParaCtx.sLSVideoParaCtx.codec = mLSLiveStreamingParaCtx.sLSVideoParaCtx.new LSVideoCodecType();
    mLSLiveStreamingParaCtx.sLSVideoParaCtx.cameraPosition = mLSLiveStreamingParaCtx.sLSVideoParaCtx.new CameraPosition();
    mLSLiveStreamingParaCtx.sLSVideoParaCtx.interfaceOrientation = mLSLiveStreamingParaCtx.sLSVideoParaCtx.new CameraOrientation();

    mLSLiveStreamingParaCtx.eHaraWareEncType.hardWareEncEnable = false;
    mLSLiveStreamingParaCtx.eOutStreamType.outputStreamType = HAVE_AV;
    mLSLiveStreamingParaCtx.eOutFormatType.outputFormatType = RTMP;

    mLSLiveStreamingParaCtx.sLSAudioParaCtx.samplerate = 44100;
    mLSLiveStreamingParaCtx.sLSAudioParaCtx.bitrate = 64000;
    mLSLiveStreamingParaCtx.sLSAudioParaCtx.frameSize = 2048;
    mLSLiveStreamingParaCtx.sLSAudioParaCtx.audioEncoding = AudioFormat.ENCODING_PCM_16BIT;
    mLSLiveStreamingParaCtx.sLSAudioParaCtx.channelConfig = AudioFormat.CHANNEL_IN_MONO;
    mLSLiveStreamingParaCtx.sLSAudioParaCtx.codec.audioCODECType = LS_AUDIO_CODEC_AAC;

    mLSLiveStreamingParaCtx.sLSVideoParaCtx.cameraPosition.cameraPosition = CAMERA_POSITION_BACK;
    mLSLiveStreamingParaCtx.sLSVideoParaCtx.interfaceOrientation.interfaceOrientation = CAMERA_ORIENTATION_LANDSCAPE;
    mLSLiveStreamingParaCtx.sLSVideoParaCtx.fps = 20;
    mLSLiveStreamingParaCtx.sLSVideoParaCtx.bitrate = bitrate;
    mLSLiveStreamingParaCtx.sLSVideoParaCtx.codec.videoCODECType = LS_VIDEO_CODEC_AVC;
    mLSLiveStreamingParaCtx.sLSVideoParaCtx.width = width;
    mLSLiveStreamingParaCtx.sLSVideoParaCtx.height = height;
  }

  public static void addChannelMessage(final String name, final String message) {
    UIHandler.post(new Runnable() {
      @Override
      public void run() {
        Spannable spannable = new SpannableString(name + ": " + message + "\n");
        spannable.setSpan(new ForegroundColorSpan(Color.rgb(28,236,253)), 0, name.length(),  Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
        mChannelText.append(spannable);

        final int scrollAmount = mChannelText.getLayout().getLineTop(mChannelText.getLineCount()) - mChannelText.getHeight();
        if (scrollAmount > 0)
          mChannelText.scrollTo(0, scrollAmount);
        else
          mChannelText.scrollTo(0, 0);
      }
    });
  }

  View.OnClickListener mOnClickEvent = new View.OnClickListener() {
    @Override
    public void onClick(View view) {
      if (view.getId() == R.id.backBtn) {
        onDestroy();
        finish();
      }
      else if (view.getId() == R.id.playBtn) {
        if (mLSMediaCapture != null) {
          if (mStreamingOn) {
            new AlertDialog.Builder(mContext)
              .setTitle("是否结束此次直播")
              .setPositiveButton("确定", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                  mLSMediaCapture.stopLiveStreaming();
                }
              })
              .setNegativeButton("取消", null)
              .show();
          }
          else {
            if (mStreamingStarted) {
              mLSMediaCapture.restartLiveStream();
            }
            else {
              mLSMediaCapture.startLiveStreaming();
            }
          }
        }
      }
      else if (view.getId() == R.id.flashBtn) {
        if (mLSMediaCapture != null) {
          flashOn = !flashOn;
          mLSMediaCapture.setCameraFlashPara(flashOn);
        }
      }
      else if (view.getId() == R.id.cameraBtn) {
        if (mLSMediaCapture != null) {
          mLSMediaCapture.switchCamera();
          if (mCameraPosition == 0) {
            mCameraPosition = 1;
          }
          else {
            mCameraPosition = 0;
          }
        }
      }
      else if (view.getId() == R.id.qualityBtn) {
        if (mStreamingOn) {
          new AlertDialog.Builder(mContext)
            .setTitle("推流中不可切换推流品质")
            .setPositiveButton("确定", null)
            .show();
        }
        else {
          final String[] qualities = {"标清", "高清", "超清"};
          new AlertDialog.Builder(mContext)
            .setTitle("请选择推流品质")
            .setPositiveButton("确定", new DialogInterface.OnClickListener() {
              @Override
              public void onClick(DialogInterface dialog, int which) {
                if (mQuality != mSelectedQuality) {
                  //clear();
                  //initMediaCapture();
                }
              }
            })
            .setNegativeButton("取消", null)
            .setSingleChoiceItems(qualities, 2, new DialogInterface.OnClickListener() {
              @Override
              public void onClick(DialogInterface dialog, int which) {
                mSelectedQuality = which;
              }
            })
            .show();
        }
      }
      else if (view.getId() == R.id.micBtn) {
        if (mStreamingOn) {
          micOn = !micOn;
          if (micOn) {
            mMicBtn.setImageResource(R.drawable.mic_on);
            mLSMediaCapture.resumeAudioLiveStream();
          }
          else {
            mMicBtn.setImageResource(R.drawable.mic_off);
            mLSMediaCapture.pauseAudioLiveStream();
          }
        }
        else {
          new AlertDialog.Builder(mContext)
            .setTitle("推流开始后才可关闭声音")
            .setPositiveButton("确定", null)
            .show();
        }
      }
      else if (view.getId() == R.id.channelBtn) {
        isChannelHide = !isChannelHide;
        if (isChannelHide) {
          mChannelText.setVisibility(View.INVISIBLE);
        }
        else {
          mChannelText.setVisibility(View.VISIBLE);
        }
      }
      else if (view.getId() == R.id.snapshotBtn) {
        if (mStreamingOn) {
          mLSMediaCapture.enableScreenShot();
        }
        else {
          new AlertDialog.Builder(mContext)
            .setTitle("推流开始后才可截图")
            .setPositiveButton("确定", null)
            .show();
        }
      }
      else if (view.getId() == R.id.controlOverlay) {
        hide();
      }
      else if (view.getId() == R.id.streamingView) {
        show();
      }
    }
  };

  public void show() {
    isHide = false;
    mControlOverlay.setVisibility(View.VISIBLE);
    mPlayBtn.setVisibility(View.VISIBLE);
    mTopView.setVisibility(View.VISIBLE);
    mBottomView.setVisibility(View.VISIBLE);
  }

  public void hide() {
    isHide = true;
    mControlOverlay.setVisibility(View.INVISIBLE);
    mPlayBtn.setVisibility(View.INVISIBLE);
    mTopView.setVisibility(View.INVISIBLE);
    mBottomView.setVisibility(View.INVISIBLE);
  }

  @Override
  protected void onStart() {
    super.onStart();
  }

  @Override
  protected void onRestart() {
    super.onRestart();
  }

  @Override
  protected void onResume() {
    super.onResume();
  }

  @Override
  protected void onPause() {
    super.onPause();
  }

  @Override
  protected void onStop() {
    super.onStop();
  }

  @Override
  protected void onDestroy() {
    clear();
    stopBlowLevelDetection();
    super.onDestroy();
  }

  private void clear() {
    if (mLSMediaCapture != null && mStreamingOn) {
      if (mPreviewOn) {
        mLSMediaCapture.stopVideoPreview();
        mLSMediaCapture.destroyVideoPreview();
      }
      mLSMediaCapture.stopLiveStreaming();
      mLSMediaCapture.uninitLsMediaCapture(false);
      mLSMediaCapture = null;
    }
    else if (mLSMediaCapture != null && mPreviewOn) {
      mLSMediaCapture.stopVideoPreview();
      mLSMediaCapture.destroyVideoPreview();
      mLSMediaCapture.uninitLsMediaCapture(true);
      mLSMediaCapture = null;
    }
    else if (mLSMediaCapture != null) {
      mLSMediaCapture.uninitLsMediaCapture(true);
      mLSMediaCapture = null;
    }
  }

  private void getLogPath()
  {
    try {
      if (Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED)) {
        mLogPath = Environment.getExternalStorageDirectory() + "/log/";
      }
    } catch (Exception e) {
    }
  }

  private void openCamera(final int cameraPosition) {
    final Semaphore lock = new Semaphore(0);
    final RuntimeException[] exception = new RuntimeException[1];
    mCameraThread = new Thread(new Runnable() {
      @Override
      public void run() {
        Looper.prepare();
        mCameraLooper = Looper.myLooper();
        try {
          mCamera = Camera.open(cameraPosition);
        } catch (RuntimeException e) {
          exception[0] = e;
        } finally {
          lock.release();
          Looper.loop();
        }
      }
    });
    mCameraThread.start();
    lock.acquireUninterruptibly();
  }

  private void lockCamera() {
    try {
      mCamera.reconnect();
    } catch (Exception e) {
    }
  }

  private void releaseCamera() {
    if (mCamera != null) {
      lockCamera();
      mCamera.setPreviewCallback(null);
      mCamera.stopPreview();
      mCamera.release();
      mCamera = null;
    }
  }

  private List<Camera.Size> getCameraSupportSize(int cameraPosition) {
    openCamera(cameraPosition);
    if(mCamera != null) {
      Camera.Parameters param = mCamera.getParameters();
      List<Camera.Size> previewSizes = param.getSupportedPreviewSizes();
      releaseCamera();
      return previewSizes;
    }
    return null;
  }

  private File savePhoto(byte[] screenShotByteBuffer) {
    File retVal = null;

    try {
      Calendar c = Calendar.getInstance();
      String date = "" + c.get(Calendar.DAY_OF_MONTH)
        + c.get(Calendar.MONTH)
        + c.get(Calendar.YEAR)
        + c.get(Calendar.HOUR_OF_DAY)
        + c.get(Calendar.MINUTE)
        + c.get(Calendar.SECOND);

      String deviceVersion = Build.VERSION.RELEASE;
      int check = deviceVersion.compareTo("2.3.3");

      File folder;
      if (check >= 1) {
        folder = Environment
          .getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES);

        if(!folder.exists()) {
          folder.mkdirs();
        }
      } else {
        folder = Environment.getExternalStorageDirectory();
      }

      File imageFile = new File(folder, "snapshot_" + date.toString() + ".jpg");

      FileOutputStream out = new FileOutputStream(imageFile);
      out.write(screenShotByteBuffer);
      out.flush();
      out.close();

      retVal = imageFile;
    } catch (Exception e) {
    }
    return retVal;
  }

  public void getScreenShotByteBuffer(byte[] screenShotByteBuffer) {
    File imageFile = savePhoto(screenShotByteBuffer);
    if (imageFile != null) {
      scanPhoto(imageFile);
      Toast.makeText(mContext, "截图成功", Toast.LENGTH_SHORT).show();
    }
    else {
      Toast.makeText(mContext, "截图失败", Toast.LENGTH_SHORT).show();
    }
  }

  private void scanPhoto(File imageFile)
  {
    Intent mediaScanIntent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
    Uri contentUri = Uri.fromFile(imageFile);
    mediaScanIntent.setData(contentUri);
    mContext.sendBroadcast(mediaScanIntent);
  }

  private Timer blowLevelTimer;
  private AudioRecord audioRecorder;
  private int blowLevel;
  private int minBufferSize;
  class BlowLevelDetectTask extends TimerTask {
    @Override
    public void run() {
      short[] buffer = new short[minBufferSize];
      audioRecorder.read(buffer, 0, minBufferSize);
      for (short s : buffer) {
        if (Math.abs(s) > 20000) {
          blowLevel = Math.abs(s);
          break;
        }
      }

      if (micOn) {
        mBlowLevelProgress.setProgress(blowLevel);
      }
      else {
        mBlowLevelProgress.setProgress(0);
      }
      // Log.d("BlowLevelDetection", ""+ blowLevel);
    }
  }

  private void initBlowLevelDetection() {
    minBufferSize = AudioRecord.getMinBufferSize(8000,AudioFormat.CHANNEL_CONFIGURATION_MONO, AudioFormat.ENCODING_PCM_16BIT);
    audioRecorder = new AudioRecord(MediaRecorder.AudioSource.MIC, 8000,AudioFormat.CHANNEL_CONFIGURATION_MONO, AudioFormat.ENCODING_PCM_16BIT, minBufferSize);
    blowLevel = 0;
    mBlowLevelProgress.setMax(33000);
    mBlowLevelProgress.setProgress(0);
    audioRecorder.startRecording();
    blowLevelTimer = new Timer();
    blowLevelTimer.schedule(new BlowLevelDetectTask(), 0, 500);
  }

  private void stopBlowLevelDetection() {
    if (blowLevelTimer != null) {
      blowLevelTimer.cancel();
    }
  }

  @Override
  public void handleMessage(int message, Object o) {
    Log.d("lsMessageHandler", "" + message);
    switch (message) {
      case lsMessageHandler.MSG_START_LIVESTREAMING_FINISHED:
        if (!mStreamingOn) {
          mStreamingOn = true;
          mStreamingStarted = true;
          mPlayBtn.setImageResource(R.drawable.pause);
          Toast.makeText(mContext, "直播已开始", Toast.LENGTH_SHORT).show();
        }
        break;
      case lsMessageHandler.MSG_STOP_LIVESTREAMING_FINISHED:
        if (mStreamingOn) {
          mStreamingOn = false;
          mPlayBtn.setImageResource(R.drawable.play);
          Toast.makeText(mContext, "直播已结束", Toast.LENGTH_SHORT).show();
        }
        break;
      case lsMessageHandler.MSG_START_PREVIEW_FINISHED:
        mPreviewOn = true;
        break;
      case lsMessageHandler.MSG_SCREENSHOT_FINISHED:
        getScreenShotByteBuffer((byte[]) o);
        break;
    }
  }
}