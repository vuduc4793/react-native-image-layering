package com.imagelayering

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Environment
import android.util.Base64
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import java.io.File
import java.io.FileOutputStream
import java.util.UUID


class ImageLayeringModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return NAME
  }

  // Example method
  // See https://reactnative.dev/docs/native-modules-android
  @ReactMethod
  fun multiply(a: Double, b: Double, promise: Promise) {
    promise.resolve(a * b)
  }
  @ReactMethod
  fun imageLayering(image1Input: String, image2Input: String, promise: Promise) {
    mergeImagesAndSaveWithInput(image1Input, image2Input, promise)
  }



  private fun mergeImagesAndSaveWithInput(image1Input: String, image2Input: String, promise: Promise) {
    val image1 = getImageFromInput(image1Input)
    val image2 = getImageFromInput(image2Input)

    if (image1 != null && image2 != null) {
      mergeImagesAndSave(image1, image2, promise)
    } else {
      promise.reject("INPUT_ERROR", "Input image invalid")
      println("Error loading images from input")
    }
  }

  private fun getImageFromInput(imageInput: String): Bitmap? {
    var image: Bitmap? = null

    if (imageInput.startsWith("data:image")) {
      val base64String = imageInput.substringAfter(",")
      val decodedBytes = Base64.decode(base64String, Base64.DEFAULT)
      image = BitmapFactory.decodeByteArray(decodedBytes, 0, decodedBytes.size)
    } else {
      image = BitmapFactory.decodeFile(imageInput)
    }

    return image
  }

  private fun mergeImagesAndSave(image1: Bitmap, image2: Bitmap, promise: Promise) {
    val combinedImage = Bitmap.createBitmap(
      image2.width,
      image2.height,
      image1.config
    )

    val canvas = android.graphics.Canvas(combinedImage)
    canvas.drawBitmap(image1, 0f, 0f, null)
    canvas.drawBitmap(image2, 0f, 0f, null)
    val filePath = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES).absolutePath +
      "/RNImageLayering"
    val dir = File(filePath)
    if(!dir.exists()) {
      dir.mkdirs()
    }
    val file = File(dir, UUID.randomUUID().toString() + ".png")
    val fileOutputStream = FileOutputStream(file)
    try {
      combinedImage.compress(Bitmap.CompressFormat.PNG, 100, fileOutputStream)
      fileOutputStream.flush()
      fileOutputStream.close()
      val response = Arguments.createMap().apply {
        putString("path", file.absolutePath)
        putInt("width", image2.width)
        putInt("height", image2.height)
      }
      promise.resolve(response)
      println("Saved the merged image to: ${file.absolutePath}")
    } catch (e: Exception){
      promise.reject(e)
    }
  }
  companion object {
    const val NAME = "ImageLayering"
  }
}
